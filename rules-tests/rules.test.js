/**
 * Deploy-oncesi manuel dogrulama scripti.
 * Calistirma: firebase emulators:exec ile (firestore + storage ayaga kalkar,
 * bu script calisir, sonra emulator kapanir).
 *
 *   firebase emulators:exec --only firestore,storage \
 *     "node rules-tests/rules.test.js"
 *
 * Test edilen 4 senaryo:
 *  1. Kendi videonu Storage'a yukleme -> basarili olmali
 *  2. Baskasinin work'unu silme -> reddedilmeli
 *  3. 100MB'i gecen dosya yukleme -> reddedilmeli
 *  4. Zorunlu alan eksik post olusturma -> reddedilmeli
 */
const fs = require("fs");
const path = require("path");
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");

const PROJECT_ID = "set-rules-test";
const OWNER_UID = "owner-uid";
const OTHER_UID = "other-uid";

let failures = 0;
let passed = 0;

async function check(label, fn) {
  try {
    await fn();
    passed++;
    console.log(`  OK   ${label}`);
  } catch (err) {
    failures++;
    console.log(`  FAIL ${label}`);
    console.log(`       -> ${err.message}`);
  }
}

function validWork(overrides = {}) {
  return {
    id: "work-1",
    title: "Test Proje",
    studio: "Test Stüdyo",
    type: "video",
    freelancerId: OWNER_UID,
    description: null,
    mediaUrl: "https://example.com/video.mp4",
    isVideo: true,
    createdAt: new Date().toISOString(),
    likes: 0,
    comments: 0,
    ...overrides,
  };
}

async function main() {
  const testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(
        path.resolve(__dirname, "../firestore.rules"),
        "utf8"
      ),
      host: "127.0.0.1",
      port: 8080,
    },
    storage: {
      rules: fs.readFileSync(
        path.resolve(__dirname, "../storage.rules"),
        "utf8"
      ),
      host: "127.0.0.1",
      port: 9199,
    },
  });

  console.log("\n=== FIRESTORE: works koleksiyonu ===");

  const ownerDb = testEnv.authenticatedContext(OWNER_UID).firestore();
  const otherDb = testEnv.authenticatedContext(OTHER_UID).firestore();

  await check(
    "1) Kendi work'ünü tüm zorunlu alanlarla oluşturma -> BAŞARILI olmalı",
    async () => {
      await assertSucceeds(
        ownerDb.collection("works").doc("work-1").set(validWork())
      );
    }
  );

  // Bir sonraki testler için sahibi olarak seed et (admin context, rules bypass).
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await ctx.firestore().collection("works").doc("work-1").set(validWork());
  });

  await check(
    "2) Başkasının work'ünü silme -> REDDEDİLMELİ",
    async () => {
      await assertFails(
        otherDb.collection("works").doc("work-1").delete()
      );
    }
  );

  await check(
    "2b) Sahibi kendi work'ünü silme -> BAŞARILI olmalı (kontrol testi)",
    async () => {
      await assertSucceeds(
        ownerDb.collection("works").doc("work-1").delete()
      );
    }
  );

  await check(
    "4) 'mediaUrl' eksik post oluşturma -> REDDEDİLMELİ",
    async () => {
      const data = validWork({ id: "work-2" });
      delete data.mediaUrl;
      await assertFails(
        ownerDb.collection("works").doc("work-2").set(data)
      );
    }
  );

  await check(
    "4b) 'type' eksik/geçersiz post oluşturma -> REDDEDİLMELİ",
    async () => {
      const data = validWork({ id: "work-3", type: "not-a-real-type" });
      await assertFails(
        ownerDb.collection("works").doc("work-3").set(data)
      );
    }
  );

  console.log("\n=== STORAGE: work_uploads ===");

  const ownerStorage = testEnv.authenticatedContext(OWNER_UID).storage();
  const otherStorage = testEnv.authenticatedContext(OTHER_UID).storage();

  const smallBuffer = Buffer.alloc(1024 * 1024, 1); // 1MB, gecerli boyut
  const tooBigBuffer = Buffer.alloc(101 * 1024 * 1024, 1); // 101MB, limit disi

  await check(
    "1) Kendi videonu (1MB, mp4) yükleme -> BAŞARILI olmalı",
    async () => {
      const ref = ownerStorage.ref(`work_uploads/${OWNER_UID}_work-1.mp4`);
      await assertSucceeds(
        ref.put(smallBuffer, { contentType: "video/mp4" })
      );
    }
  );

  await check(
    "2) Başkasının prefix'ine dosya yükleme -> REDDEDİLMELİ",
    async () => {
      const ref = otherStorage.ref(`work_uploads/${OWNER_UID}_work-9.mp4`);
      await assertFails(
        ref.put(smallBuffer, { contentType: "video/mp4" })
      );
    }
  );

  await check(
    "3) 100MB'ı geçen dosya (101MB) yükleme -> REDDEDİLMELİ",
    async () => {
      const ref = ownerStorage.ref(`work_uploads/${OWNER_UID}_work-big.mp4`);
      await assertFails(
        ref.put(tooBigBuffer, { contentType: "video/mp4" })
      );
    }
  );

  await check(
    "bonus) Whitelist dışı content-type (application/pdf) -> REDDEDİLMELİ",
    async () => {
      const ref = ownerStorage.ref(`work_uploads/${OWNER_UID}_work-doc.mp4`);
      await assertFails(
        ref.put(smallBuffer, { contentType: "application/pdf" })
      );
    }
  );

  await testEnv.cleanup();

  console.log(`\n${passed} test geçti, ${failures} test başarısız.\n`);
  if (failures > 0) {
    process.exitCode = 1;
  }
}

main().catch((err) => {
  console.error("Test scripti çalışırken beklenmeyen hata:", err);
  process.exitCode = 1;
});
