# SET

Video prodüksiyon dünyasını tek çatı altında buluşturan mobil pazaryeri uygulaması. Müşteriler doğru ekibi bulur ve teklif gönderir; freelancer'lar yeteneklerini sergileyip iş alır.

> **Durum:** Erken geliştirme. UI iskeleti büyük ölçüde hazır, backend bağlantısı henüz yok (Firebase paketleri ekli, gerçek implementasyon bekliyor).

---

## Vizyon

Tasarım dili **sinematik**: koyu tema baskın, sıcak altın aksanlar, editöryel serif başlıklar (Cormorant Garamond), modern sans-serif (Space Grotesk + Inter) gövde metni. Premium prodüksiyon hissi yaratmak öncelikli.

---

## Kullanıcı Akışı

```
Splash (SET wordmark)
   ↓ 2 sn
Onboarding (3 sayfa, sinematik full-bleed)
   ↓ "Başla"
Login / Register
   ↓
Role Selection (2 sayfa, kaydırılabilir)
   ├── Hizmet Al  ───→ Client Home (5 sekme)
   └── Hizmet Ver ───→ Freelancer Onboarding (henüz işlenmedi)
```

### Hizmet Al — 5 Sekmeli Ana Akış

Bottom nav (varsayılan açılış sekmesi: **Ana Sayfa**):

| Sekme | İçerik |
|---|---|
| **Keşfet** | Stüdyo işlerinin portfolyo feed'i. Üst başlık + arama, filtre chip'leri (Tüm İşler / Video / Foto / CGI / VFX / AI — altın aktif rengi), 16:10 oranlı kart görselleri, başlık, stüdyo credit, beğeni/yorum/bookmark sayaçları. |
| **Sohbet** | Müşteri-freelancer yazışmaları. Şimdilik dummy thread listesi. |
| **Ana Sayfa** | Selamlama ("Merhaba, [İsim]") + büyük **"Projeni yaptır"** mega CTA butonu. |
| **Projelerim** | Açılmış projeler ve teklifler. Şimdilik empty-state placeholder. |
| **Profil** | Kullanıcı bilgileri, tema switch'i, rol değiştirme, çıkış. |

### "Projeni Yaptır" Akışı

```
Ana Sayfa → "Projeni yaptır" butonu
   ↓
Kategori Seçim (2x3 grid: Videographer, Sound Design, Video Edit, AI/CGI, Drone, Photographer)
   ↓
Kategoriye Göre Freelancer Listesi (alt alta kartlar — isim, kategori, lokasyon, rating, deneyim)
   ↓
Freelancer Detay (avatar, istatistikler, hakkında, reel grid, uzmanlık chip'leri)
   ↓
"Teklif Gönder" butonu → Send Offer ekranı (tutar + mesaj formu)
```

---

## Teknoloji

- **Flutter** (SDK ≥3.10.1)
- **GetX** — state management, navigation, dependency injection
- **Google Fonts** — Cormorant Garamond, Space Grotesk, Inter
- **Firebase** (core / auth / firestore / storage) — paketler ekli, henüz kullanılmıyor
- **GetStorage** — lokal anahtar/değer depolama (tema, onboarding flag, oturum)
- **Dio** — HTTP client (hazır, kullanım yok)
- **cached_network_image**, **flutter_svg**, **image_picker** — medya
- **intl** — tarih/sayı format
- **flutter_native_splash**, **flutter_launcher_icons** — derleme yardımcıları

---

## Klasör Yapısı

```
lib/
├── core/
│   ├── constants/       app_assets, app_strings
│   ├── theme/           app_colors, app_text_styles, app_theme, app_radius, app_spacing
│   ├── extensions/      context, string yardımcıları
│   └── utils/           validators, formatters
├── data/
│   ├── models/          user, freelancer, project, offer, message, work
│   ├── dummy/           geliştirme için sahte veri
│   ├── repositories/    auth, user, freelancer
│   └── services/        dio, firebase, storage
├── modules/
│   ├── app/             initial_binding, auth_controller, user_controller, theme_controller
│   ├── splash/          ilk açılış ekranı
│   ├── onboarding/      3 sayfalı sinematik tanıtım
│   ├── auth/login & register
│   ├── role_selection/  Hizmet Al / Hizmet Ver seçim ekranı
│   ├── client/          Hizmet Al akışının tüm modülleri
│   │   ├── home/                       5 sekmeli ana shell
│   │   │   └── tabs/                   discover, chat, home, projects, profile
│   │   ├── category_picker/            kategori seçim grid'i
│   │   ├── freelancers_by_category/    kategoriye göre freelancer listesi
│   │   ├── freelancer_detail/          freelancer profili
│   │   ├── send_offer/                 teklif gönderme formu
│   │   └── chat_detail/                tek konuşma ekranı
│   └── freelancer/      Hizmet Ver tarafı (onboarding + home — içerikleri henüz tasarlanmadı)
├── routes/              app_routes (sabitler) + app_pages (GetPage kayıtları)
├── widgets/             paylaşılan UI: set_button, set_card, set_chip, set_avatar,
│                        set_bottom_nav, set_text_field, set_hero_card, set_section_header,
│                        set_glass_app_bar
└── main.dart            uygulama girişi
```

Her ekran modülü GetX desenine uyar: `<screen>_view.dart` + `<screen>_controller.dart` + `<screen>_binding.dart`.

---

## Tema ve Tasarım Sistemi

**Renkler** (`lib/core/theme/app_colors.dart`)

| Token | Hex | Kullanım |
|---|---|---|
| `primary` | `#6EA8FF` | Brand mavi — butonlar, vurgu, icon aktif |
| `primaryDeep` | `#4F86E0` | Gradient eşi |
| `accentCyan` | `#6FE7DD` | İkincil aksan, eyebrow metinler |
| `accentGold` | `#D9B36A` | Sinematik altın — onboarding, Keşfet filtre chip aktif |
| `backgroundDark` | `#0B0F14` | Default arka plan |
| `surfaceDark` / `surfaceDarkElevated` | `#151B23` / `#1B232C` | Kartlar, sheet'ler |
| `success` / `warning` / `error` | `#34C77B` / `#E0A536` / `#E5484D` | Status |

**Tipografi** (`lib/core/theme/app_text_styles.dart`)

- `editorialDisplay` — Cormorant Garamond 56px, sinematik onboarding başlıkları
- `displayXL`, `heading1-3` — Space Grotesk
- `body1`, `body2`, `caption`, `button`, `eyebrow` — Inter
- `wordmark` — Space Grotesk, "SET" yazısı için sıkı letter-spacing

---

## Çalıştırma

```bash
git clone https://github.com/FurkanUST451/SET.git
cd SET
flutter pub get
flutter run
```

Cihaz / emülatör seçili olmalı. İlk açılışta dev davranışı: onboarding her seferinde gösteriliyor (aşağıda dev notu).

---

## Geliştirme Notları

- **Dev modda splash davranışı:** `lib/modules/splash/splash_controller.dart` şu an her açılışta onboarding'e yönlendiriyor (üzerinde çalışırken tasarımı sürekli görebilmek için). Tasarım netleştiğinde altındaki orijinal `hasOnboarded` mantığına dönülecek.
- **Backend yok:** Auth, freelancer listesi, teklif vb. işlemler `lib/data/dummy/dummy_data.dart`'tan besleniyor. `auth_repository.dart` mock yanıt üretiyor.
- **Hizmet Ver tarafı:** `lib/modules/freelancer/` altındaki dosyalar iskelet düzeyinde. Tasarım ve içerik üzerine henüz çalışılmadı.
- **Kategoriler:** İngilizce — `Videographer`, `Sound Design`, `Video Edit`, `AI/CGI`, `Drone`, `Photographer`. Freelancer ve kategori filtreleri bu string'lerle eşleşiyor.
- **Keşfet kart görselleri:** Henüz konulmadı — `WorkModel.coverImage` `null` ise koyu gradient + tipine göre dekoratif ikon + play butonu placeholder gösteriliyor.

---

## Firebase Entegrasyonu (TODO)

Proje Firebase paketlerini içerir ancak henüz `firebase_options.dart` üretilmemiştir. Bağlamak için:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Sonra `lib/data/services/firebase_service.dart` içindeki TODO yorumunu aktif edin ve `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` çağrısını ekleyin. Repository'lerdeki mock `Future.delayed` çağrıları gerçek FirebaseAuth / Firestore çağrılarıyla değiştirilmelidir.

---

## Beraber Çalışma

İki kişilik geliştirme için basit akış:

```bash
git pull --rebase origin main     # önce diğerinin commit'lerini al
# ... çalış, edit'le ...
git add -A
git commit -m "ne yaptın"
git push origin main
```

Aynı dosyaya aynı anda dokunmamaya özen göster. Çakışma çıkarsa `<<<<<<< ======= >>>>>>>` işaretli bloğu çöz, `git add <dosya>`, `git rebase --continue`.

Büyük bir feature için ayrı branch açıp PR ile main'e merge etmek daha güvenli — ama küçük değişiklikler için direkt main'de gitmek de yeterli.

---

## Yol Haritası

- [ ] Hizmet Ver (freelancer) tarafı: onboarding + home ekranları, portföy yükleme
- [ ] Firebase auth gerçek implementasyon
- [ ] Firestore ile freelancer, proje, teklif, mesaj koleksiyonları
- [ ] Firebase Storage ile portfolyo / avatar yükleme
- [ ] Push notification (FCM)
- [ ] Splash controller dev modunu kaldır
- [ ] Keşfet kart görselleri için asset pipeline
- [ ] App icon ve native splash config (`flutter_launcher_icons`, `flutter_native_splash`)
