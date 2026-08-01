const {
  onDocumentCreated,
  onDocumentDeleted,
} = require("firebase-functions/v2/firestore");
const {
  onCall,
  onRequest,
  HttpsError,
} = require("firebase-functions/v2/https");
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
 * Keşfet beğeni/yorum sayaçları.
 *
 * works/{workId}.likes ve .comments alanları client'tan asla doğrudan
 * yazılamaz (bkz. firestore.rules) — client yalnızca works/{workId}/likes
 * ve works/{workId}/comments alt-koleksiyonlarına doküman ekler/siler, bu
 * dört tetikleyici de o değişiklikleri dinleyip sayacı Admin SDK ile
 * senkronize eder. Ebeveyn work dokümanı silinmişse (ör. kullanıcı işini
 * kaldırdı) update() NOT_FOUND fırlatır; bu beklenen bir durumdur, sessizce
 * loglanır.
 */
async function adjustWorkCounter(workId, field, delta) {
  try {
    await getFirestore()
      .collection("works")
      .doc(workId)
      .update({ [field]: FieldValue.increment(delta) });
  } catch (err) {
    logger.warn(
      `${field} sayaç güncellemesi atlandı (work: ${workId}): ${err.message}`
    );
  }
}

exports.onWorkLikeCreated = onDocumentCreated(
  { document: "works/{workId}/likes/{likeId}", region: "europe-west1" },
  (event) => adjustWorkCounter(event.params.workId, "likes", 1)
);

exports.onWorkLikeDeleted = onDocumentDeleted(
  { document: "works/{workId}/likes/{likeId}", region: "europe-west1" },
  (event) => adjustWorkCounter(event.params.workId, "likes", -1)
);

exports.onWorkCommentCreated = onDocumentCreated(
  { document: "works/{workId}/comments/{commentId}", region: "europe-west1" },
  (event) => adjustWorkCounter(event.params.workId, "comments", 1)
);

exports.onWorkCommentDeleted = onDocumentDeleted(
  { document: "works/{workId}/comments/{commentId}", region: "europe-west1" },
  (event) => adjustWorkCounter(event.params.workId, "comments", -1)
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
  // Paylaşım sayfası kimliksiz/herkese açık bir uç nokta olduğu için
  // uid yerine istemci IP'si anahtar olarak kullanılır (bkz. watchPage).
  watch_page: { max: 60, windowMs: 60 * 1000 },
};

// Sabit-pencere sayacın çekirdeği. Sonucu fırlatmak yerine döndürür ki hem
// callable fonksiyonlar (HttpsError fırlatarak) hem de watchPage gibi düz
// HTTP uç noktaları (kendi HTTP durum koduyla yanıt vererek) aynı mantığı
// kullanabilsin.
async function checkRateLimit(key, action) {
  const config = RATE_LIMITS[action];
  const db = getFirestore();
  const ref = db.collection("rate_limits").doc(`${key}_${action}`);
  const now = Date.now();

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.exists ? snap.data() : null;

    if (!data || now - data.windowStart > config.windowMs) {
      tx.set(ref, { windowStart: now, count: 1 });
      return { allowed: true };
    }

    if (data.count >= config.max) {
      const retryAfterSec = Math.ceil(
        (config.windowMs - (now - data.windowStart)) / 1000
      );
      return { allowed: false, retryAfterSec };
    }

    tx.update(ref, { count: FieldValue.increment(1) });
    return { allowed: true };
  });
}

async function enforceRateLimit(uid, action) {
  const result = await checkRateLimit(uid, action);
  if (!result.allowed) {
    throw new HttpsError(
      "resource-exhausted",
      `Çok fazla istek gönderdiniz. Lütfen ${result.retryAfterSec} saniye sonra tekrar deneyin.`
    );
  }
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

/**
 * Keşfet paylaşım sayfası — Firebase Hosting'de /w/{workId} rewrite'ı bu
 * fonksiyona bağlanır (bkz. firebase.json). Uygulamadaki "gönder" butonu
 * artık ham Storage linki yerine bu sayfanın linkini paylaşır.
 *
 * Bu uç nokta bilerek kimliksizdir: linki açan kişinin uygulamada oturumu
 * olmayabilir. Bu yüzden App Check zorunlu kılınamaz (App Check token'ı
 * uygulamanın kendisinden gelir) ve veri, client kurallarını bypass eden
 * Admin SDK ile sunucu tarafında okunur — ama yalnızca gösterilecek
 * alanlar (başlık/stüdyo/görsel) HTML'e basılır, dokümanın tamamı değil.
 */
// Uygulamadaki work_model.dart WorkType.label ile birebir aynı etiketler.
const WORK_TYPE_LABELS = {
  video: "VİDEO",
  photo: "FOTO",
  cgiVfx: "CGI&VFX",
  graphic: "GRAFİK",
  sound: "SES",
};

const WATCH_PAGE_STYLES = `
  :root { color-scheme: light; }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    min-height: 100vh;
    display: flex;
    justify-content: center;
    background: #FEFDFB;
    font-family: 'Cormorant Garamond', Georgia, serif;
    color: #35333F;
  }
  .page { width: 100%; max-width: 480px; padding-bottom: 56px; }
  .topstrip { padding: 22px 24px 14px; text-align: center; }
  .brand-label {
    font-family: 'Space Mono', 'Courier New', monospace;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 2px;
    color: #000000;
  }
  .divider { height: 1px; background: rgba(0, 0, 0, 0.07); margin: 0 24px; }
  .identity { padding: 22px 24px 16px; text-align: center; }
  .studio-name {
    display: block;
    font-size: 19px;
    font-weight: 600;
    margin-bottom: 5px;
  }
  .idline {
    font-family: 'Space Mono', 'Courier New', monospace;
    font-size: 10px;
    letter-spacing: 0.6px;
  }
  .idline .type { color: #D9A84E; font-weight: 700; }
  .idline .dot { margin: 0 6px; color: #000000; }
  .idline .quote { color: #000000; }
  .media-frame {
    padding: 0 24px;
    display: flex;
    justify-content: center;
  }
  .media {
    width: 100%;
    max-height: 65vh;
    border-radius: 14px;
    background: linear-gradient(135deg, #262430, #141219);
    display: block;
    margin: 0 auto;
    object-fit: contain;
  }
  .content { padding: 20px 24px 0; text-align: center; }
  h1 {
    font-size: 23px;
    font-weight: 500;
    font-style: italic;
    margin: 0 0 12px;
    line-height: 1.2;
  }
  .desc {
    font-family: 'Space Mono', 'Courier New', monospace;
    font-size: 12px;
    line-height: 1.8;
    letter-spacing: 0.2px;
    color: #9B8E7B;
    margin: 0;
    white-space: pre-line;
  }
  .message-wrap {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 60px 24px;
    text-align: center;
  }
  .message { font-size: 18px; color: #9B8E7B; margin: 0; }
`;

function escapeHtml(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function renderHtmlDocument({ title, head, body }) {
  return `<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>${escapeHtml(title)}</title>
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet" />
<style>${WATCH_PAGE_STYLES}</style>
${head || ""}
</head>
<body>
  <div class="page">
    <div class="topstrip"><span class="brand-label">SET · KEŞFET</span></div>
    <div class="divider"></div>
    ${body}
  </div>
</body>
</html>`;
}

function renderMessagePage(message) {
  return renderHtmlDocument({
    title: "SET · Keşfet",
    body: `<div class="message-wrap"><p class="message">${escapeHtml(message)}</p></div>`,
  });
}

function renderWatchPage(work, pageUrl) {
  const title = escapeHtml(work.title || "");
  const studio = escapeHtml(work.studio || "");
  const typeLabel = WORK_TYPE_LABELS[work.type] || "İŞ";
  const heading = `${studio} — «${title}»`;
  const description = work.description ? escapeHtml(work.description) : "";
  const ogDescription = escapeHtml(
    work.description || `${work.studio || "Bir SET stüdyosu"} tarafından paylaşıldı.`
  );
  const mediaUrl = escapeHtml(work.mediaUrl || "");
  const thumbnailUrl = work.thumbnailUrl ? escapeHtml(work.thumbnailUrl) : "";
  // Video işlerde önizleme kapağı varsa onu, foto işlerde ise mediaUrl'in
  // kendisini (zaten bir görsel) og:image olarak kullan.
  const ogImage = thumbnailUrl || (!work.isVideo ? mediaUrl : "");

  const mediaTag = work.isVideo
    ? `<video class="media" controls playsinline preload="metadata"${
        thumbnailUrl ? ` poster="${thumbnailUrl}"` : ""
      } src="${mediaUrl}"></video>`
    : `<img class="media" src="${mediaUrl}" alt="${title}" />`;

  const head = `
<meta property="og:type" content="video.other" />
<meta property="og:title" content="${escapeHtml(heading)}" />
<meta property="og:description" content="${ogDescription}" />
${ogImage ? `<meta property="og:image" content="${ogImage}" />` : ""}
<meta property="og:url" content="${escapeHtml(pageUrl)}" />
<meta name="twitter:card" content="summary_large_image" />`;

  const body = `
    <div class="identity">
      <span class="studio-name">${studio}</span>
      <div class="idline">
        <span class="type">${typeLabel}</span><span class="dot">·</span><span class="quote">«${title}»</span>
      </div>
    </div>
    <div class="media-frame">${mediaTag}</div>
    <div class="content">
      <h1>${title}</h1>
      ${description ? `<p class="desc">${description}</p>` : ""}
    </div>`;

  return renderHtmlDocument({ title: `${heading} · SET`, head, body });
}

function sendHtml(res, status, html) {
  res
    .status(status)
    .set("Content-Type", "text/html; charset=utf-8")
    .send(html);
}

exports.watchPage = onRequest(
  { region: "europe-west1" },
  async (req, res) => {
    const workId = (req.path.split("/w/")[1] || "").split("/")[0].split("?")[0];
    if (!workId) {
      sendHtml(res, 404, renderMessagePage("Bu içerik artık mevcut değil."));
      return;
    }

    const clientIp = req.ip || req.headers["x-forwarded-for"] || "unknown";
    const rate = await checkRateLimit(String(clientIp), "watch_page");
    if (!rate.allowed) {
      sendHtml(
        res,
        429,
        renderMessagePage(
          `Çok fazla istek. Lütfen ${rate.retryAfterSec} saniye sonra tekrar deneyin.`
        )
      );
      return;
    }

    try {
      const snap = await getFirestore().collection("works").doc(workId).get();
      if (!snap.exists) {
        sendHtml(res, 404, renderMessagePage("Bu içerik artık mevcut değil."));
        return;
      }
      const pageUrl = `https://${req.hostname}${req.path}`;
      res.set("Cache-Control", "public, max-age=300, s-maxage=600");
      sendHtml(res, 200, renderWatchPage(snap.data(), pageUrl));
    } catch (err) {
      logger.error(`watchPage render hatası (work: ${workId})`, err);
      sendHtml(res, 500, renderMessagePage("Bir şeyler ters gitti, tekrar dene."));
    }
  }
);
