const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

initializeApp();

/**
 * chats/{chatId}/messages altına yeni mesaj yazıldığında tetiklenir.
 *
 * İki yön de desteklenir:
 * - Freelancer mesaj atarsa → hizmet alana bildirim gider
 * - Hizmet alan mesaj atarsa → freelancer'a bildirim gider
 */
exports.onNewChatMessage = onDocumentCreated(
  {
    document: "chats/{chatId}/messages/{messageId}",
    region: "europe-west1",
  },
  async (event) => {
    const message = event.data ? event.data.data() : null;
    if (!message || !message.senderId) return;

    const db = getFirestore();
    const chatSnap = await db
      .collection("chats")
      .doc(event.params.chatId)
      .get();
    const chat = chatSnap.data();
    if (!chat) {
      logger.warn(`Chat bulunamadı: ${event.params.chatId}`);
      return;
    }

    // Göndereni belirle, karşı tarafa bildirim at
    let recipientId;
    let senderName;
    let notificationBody;
    let returnRoute;
    if (message.senderId === chat.freelancerId) {
      // Freelancer → hizmet alan
      recipientId = chat.clientId;
      senderName = chat.freelancerName || "Freelancer";
      notificationBody = `Teklif verdiğiniz ${senderName} size mesaj gönderdi.`;
      returnRoute = "/client/home";
    } else if (message.senderId === chat.clientId) {
      // Hizmet alan → freelancer
      recipientId = chat.freelancerId;
      senderName = chat.clientName || "Hizmet alan";
      notificationBody = `${senderName} size mesaj gönderdi.`;
      returnRoute = "/freelancer/home";
    } else {
      return;
    }
    if (!recipientId) return;

    const userSnap = await db.collection("users").doc(recipientId).get();
    const fcmToken = userSnap.get("fcmToken");
    if (!fcmToken) {
      logger.info(`Alıcının FCM token'ı yok: ${recipientId}`);
      return;
    }

    try {
      await getMessaging().send({
        token: fcmToken,
        notification: {
          title: "Yeni mesaj 📩",
          body: notificationBody,
        },
        data: {
          type: "chat_message",
          chatId: event.params.chatId,
          otherUserName: senderName,
          briefTitle: chat.briefTitle || "",
          returnRoute: returnRoute,
        },
        android: {
          priority: "high",
          notification: {
            defaultSound: true,
          },
        },
        apns: {
          payload: {
            aps: { sound: "default" },
          },
        },
      });
      logger.info(
        `Bildirim gönderildi → ${recipientId} (chat: ${event.params.chatId})`
      );
    } catch (err) {
      // Token geçersizse (uygulama silinmiş vb.) Firestore'dan temizle
      if (
        err.code === "messaging/registration-token-not-registered" ||
        err.code === "messaging/invalid-registration-token"
      ) {
        await userSnap.ref.update({ fcmToken: FieldValue.delete() });
        logger.info(`Geçersiz token silindi: ${recipientId}`);
      } else {
        logger.error("Bildirim gönderilemedi", err);
      }
    }
  }
);

/**
 * Basit rate limiting — Keşfet spam/maliyet koruması.
 *
 * Redis'e gerek yok: bu ölçekte Firestore üzerinde tek dokümanlık bir
 * sabit-pencere (fixed window) sayaç yeterli. Sayaç rate_limits/{uid}_{action}
 * dokümanında tutulur; firestore.rules bu koleksiyona client erişimini
 * tamamen kapatır, yalnızca bu Admin SDK kodu okuyup yazabilir.
 */
const RATE_LIMITS = {
  video_upload: { max: 3, windowMs: 60 * 1000 },
  // Like + yorum ortak kotayı paylaşır — ikisi de aynı spam riskini taşır.
  engagement: { max: 20, windowMs: 60 * 1000 },
};

// TODO(likes/comments sayaçları): works/{id}/likes ve works/{id}/comments
// alt-koleksiyonları var ama henüz bunları dinleyip works.likes / works.comments
// alanlarını güncelleyen bir trigger yok (firestore.rules bu alanları client'a
// kapatıyor). Like/yorum UI'ı yazılırken buraya onDocumentCreated/onDocumentDeleted
// tetikleyicileri eklenip FieldValue.increment(1) / increment(-1) ile sayaçlar
// senkronize edilmeli — aksi halde like/yorum sayıları arayüzde hep 0 görünür.

async function enforceRateLimit(uid, action) {
  const config = RATE_LIMITS[action];
  const db = getFirestore();
  const ref = db.collection("rate_limits").doc(`${uid}_${action}`);
  const now = Date.now();

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.exists ? snap.data() : null;

    if (!data || now - data.windowStart > config.windowMs) {
      tx.set(ref, { windowStart: now, count: 1 });
      return;
    }

    if (data.count >= config.max) {
      const retryAfterSec = Math.ceil(
        (config.windowMs - (now - data.windowStart)) / 1000
      );
      throw new HttpsError(
        "resource-exhausted",
        `Çok fazla istek gönderdiniz. Lütfen ${retryAfterSec} saniye sonra tekrar deneyin.`
      );
    }

    tx.update(ref, { count: FieldValue.increment(1) });
  });
}

/**
 * Video/görsel yüklemeden hemen önce client tarafından çağrılır.
 * Limit aşılırsa 'resource-exhausted' hatası fırlatır ve upload'ı durdurur.
 */
exports.checkVideoUploadLimit = onCall(
  { region: "europe-west1", enforceAppCheck: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Giriş yapmalısınız.");
    }
    await enforceRateLimit(request.auth.uid, "video_upload");
    return { allowed: true };
  }
);

/**
 * Like/yorum atmadan hemen önce client tarafından çağrılır.
 * Limit aşılırsa 'resource-exhausted' hatası fırlatır.
 */
exports.checkEngagementLimit = onCall(
  { region: "europe-west1", enforceAppCheck: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Giriş yapmalısınız.");
    }
    await enforceRateLimit(request.auth.uid, "engagement");
    return { allowed: true };
  }
);
