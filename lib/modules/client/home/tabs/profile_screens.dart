import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/dummy/dummy_data.dart';
import '../../../../data/models/freelancer_model.dart';
import '../../../../data/repositories/freelancer_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../app/user_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kDivider = Color(0x12000000);
const _kDanger = Color(0xFFBE6A5A);
const _kCardBorder = Color(0x14000000);

// ─── Tipografi & ölçek ────────────────────────────────────────────────────────
double _scaleOf(BuildContext c) =>
    (MediaQuery.sizeOf(c).width / 390).clamp(0.85, 1.15).toDouble();

TextStyle _serif({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
}) =>
    GoogleFonts.cormorantGaramond(
        fontSize: size, fontWeight: weight, color: color, height: height);

TextStyle _mono({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
  double height = 1.4,
}) =>
    GoogleFonts.spaceMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height);

Widget _bottomSheetHandle(double s) => Container(
      width: 40 * s,
      height: 4 * s,
      decoration: BoxDecoration(
        color: _kCardBorder,
        borderRadius: BorderRadius.circular(4),
      ),
    );

// ─── Ortak scaffold ───────────────────────────────────────────────────────────
class _ProfileSubScaffold extends StatelessWidget {
  const _ProfileSubScaffold({
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12 * s, 8 * s, 20 * s, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back<void>(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8 * s),
                        child: Icon(Icons.arrow_back_rounded,
                            size: 22 * s, color: _kInk),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _serif(
                            size: 26 * s, weight: FontWeight.w600, color: _kInk),
                      ),
                    ),
                  ],
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * s),
                  child: Text(
                    subtitle!,
                    style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.3),
                  ),
                ),
              ],
              SizedBox(height: 18 * s),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(24 * s, 0, 24 * s, 40 * s),
                  children: children,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Ortak kart (keskin, düz) ─────────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(18 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: child,
    );
  }
}

// ─── Ortak etiketli alan ──────────────────────────────────────────────────────
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.obscure = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: c, width: w),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: _mono(
              size: 8 * s, weight: FontWeight.w700, color: _kMuted, spacing: 1.2),
        ),
        SizedBox(height: 7 * s),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          obscureText: obscure,
          cursorColor: _kGold,
          style: _mono(size: 11 * s, color: _kInk, spacing: 0.2, height: 1.3),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: _mono(size: 11 * s, color: _kMuted, spacing: 0.2),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
            border: border(Colors.black.withValues(alpha: 0.12)),
            enabledBorder: border(Colors.black.withValues(alpha: 0.12)),
            focusedBorder: border(_kGold, 1.4),
          ),
        ),
      ],
    );
  }
}

// ─── Ortak birincil buton (keskin) ────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 52 * s,
        color: danger ? _kDanger : _kGold,
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: _mono(
              size: 11 * s,
              weight: FontWeight.w700,
              color: Colors.white,
              spacing: 1.5),
        ),
      ),
    );
  }
}

void _toast(String msg) {
  Get.snackbar(
    '',
    msg,
    titleText: const SizedBox.shrink(),
    messageText: Text(
      msg,
      style: _mono(size: 11, weight: FontWeight.w600, color: Colors.white),
    ),
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: _kInk,
    borderRadius: 0,
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 2),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 1 · Profili Düzenle
// ══════════════════════════════════════════════════════════════════════════════
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _location;
  late final TextEditingController _language;

  @override
  void initState() {
    super.initState();
    final u = Get.find<UserController>().currentUser;
    _name = TextEditingController(text: u?.fullName ?? '');
    _bio = TextEditingController();
    _location = TextEditingController();
    _language = TextEditingController(text: 'Türkçe');
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _location.dispose();
    _language.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return _ProfileSubScaffold(
      title: 'Profili Düzenle',
      subtitle: 'Profilinde görünen bilgileri güncelle.',
      children: [
        _Card(
          child: Column(
            children: [
              _LabeledField(label: 'Ad Soyad', controller: _name, hint: 'Adını gir'),
              SizedBox(height: 16 * s),
              _LabeledField(
                  label: 'Biyografi',
                  controller: _bio,
                  hint: 'Kendinden kısaca bahset',
                  maxLines: 4),
              SizedBox(height: 16 * s),
              _LabeledField(
                  label: 'Konum', controller: _location, hint: 'Şehir, ülke'),
              SizedBox(height: 16 * s),
              _LabeledField(
                  label: 'Dil', controller: _language, hint: 'Konuştuğun diller'),
            ],
          ),
        ),
        SizedBox(height: 24 * s),
        _PrimaryButton(
          label: 'Değişiklikleri Kaydet',
          onTap: () {
            Get.back<void>();
            _toast('Profil bilgilerin kaydedildi');
          },
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 2 · E-posta & Telefon
// ══════════════════════════════════════════════════════════════════════════════
class ContactInfoScreen extends StatefulWidget {
  const ContactInfoScreen({super.key});

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  late final TextEditingController _email;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final u = Get.find<UserController>().currentUser;
    _email = TextEditingController(text: u?.email ?? '');
    _phone = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return _ProfileSubScaffold(
      title: 'E-posta & Telefon',
      subtitle: 'İletişim bilgilerini güncelle.',
      children: [
        _Card(
          child: Column(
            children: [
              _LabeledField(
                  label: 'E-posta',
                  controller: _email,
                  hint: 'ornek@mail.com',
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: 16 * s),
              _LabeledField(
                  label: 'Telefon',
                  controller: _phone,
                  hint: '+90 5xx xxx xx xx',
                  keyboardType: TextInputType.phone),
            ],
          ),
        ),
        SizedBox(height: 24 * s),
        _PrimaryButton(
          label: 'Kaydet',
          onTap: () {
            Get.back<void>();
            _toast('İletişim bilgilerin güncellendi');
          },
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 3 · Şifre Değiştir
// ══════════════════════════════════════════════════════════════════════════════
class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return _ProfileSubScaffold(
      title: 'Şifre Değiştir',
      subtitle: 'Hesabının güvenliği için güçlü bir şifre seç.',
      children: [
        _Card(
          child: Column(
            children: [
              _LabeledField(
                  label: 'Mevcut Şifre',
                  controller: _current,
                  hint: '••••••••',
                  obscure: true),
              SizedBox(height: 16 * s),
              _LabeledField(
                  label: 'Yeni Şifre',
                  controller: _next,
                  hint: '••••••••',
                  obscure: true),
              SizedBox(height: 16 * s),
              _LabeledField(
                  label: 'Yeni Şifre (Tekrar)',
                  controller: _confirm,
                  hint: '••••••••',
                  obscure: true),
            ],
          ),
        ),
        SizedBox(height: 24 * s),
        _PrimaryButton(
          label: 'Şifreyi Güncelle',
          onTap: () {
            if (_next.text.isEmpty || _next.text != _confirm.text) {
              _toast('Yeni şifreler eşleşmiyor');
              return;
            }
            Get.back<void>();
            _toast('Şifren güncellendi');
          },
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 4 · Bildirimler
// ══════════════════════════════════════════════════════════════════════════════
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _push = true;
  bool _email = true;
  bool _campaigns = false;
  bool _messages = true;

  @override
  Widget build(BuildContext context) {
    return _ProfileSubScaffold(
      title: 'Bildirimler',
      subtitle: 'Hangi bildirimleri almak istediğini seç.',
      children: [
        _Card(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            children: [
              _ToggleRow(
                label: 'Push Bildirimleri',
                sub: 'Anlık uygulama bildirimleri',
                value: _push,
                onChanged: (v) => setState(() => _push = v),
              ),
              _ToggleRow(
                label: 'E-posta Bildirimleri',
                sub: 'Özet ve güncellemeler',
                value: _email,
                onChanged: (v) => setState(() => _email = v),
              ),
              _ToggleRow(
                label: 'Yeni Mesajlar',
                sub: 'Freelancer mesaj gönderdiğinde',
                value: _messages,
                onChanged: (v) => setState(() => _messages = v),
              ),
              _ToggleRow(
                label: 'Kampanyalar',
                sub: 'Fırsat ve duyurular',
                value: _campaigns,
                onChanged: (v) => setState(() => _campaigns = v),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.sub,
    this.isLast = false,
  });

  final String label;
  final String? sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 10 * s),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: _serif(
                            size: 15 * s,
                            weight: FontWeight.w600,
                            color: _kInk)),
                    if (sub != null) ...[
                      SizedBox(height: 2 * s),
                      Text(sub!,
                          style:
                              _mono(size: 8 * s, color: _kTaupe, spacing: 0.2)),
                    ],
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.white,
                  activeTrackColor: _kGold,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.black12,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1, thickness: 1, indent: 10, endIndent: 10, color: _kDivider),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 5 · Dil & Bölge
// ══════════════════════════════════════════════════════════════════════════════
class LanguageRegionScreen extends StatefulWidget {
  const LanguageRegionScreen({super.key});

  @override
  State<LanguageRegionScreen> createState() => _LanguageRegionScreenState();
}

class _LanguageRegionScreenState extends State<LanguageRegionScreen> {
  final _languages = const ['Türkçe', 'English', 'Deutsch', 'Français', 'العربية'];
  String _selected = 'Türkçe';

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return _ProfileSubScaffold(
      title: 'Dil & Bölge',
      subtitle: 'Uygulama dilini seç.',
      children: [
        _Card(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            children: [
              for (int i = 0; i < _languages.length; i++) ...[
                InkWell(
                  onTap: () => setState(() => _selected = _languages[i]),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10 * s, vertical: 14 * s),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _languages[i],
                            style: _serif(
                                size: 16 * s,
                                weight: _selected == _languages[i]
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: _kInk),
                          ),
                        ),
                        if (_selected == _languages[i])
                          Icon(Icons.check_rounded, color: _kGold, size: 20 * s),
                      ],
                    ),
                  ),
                ),
                if (i < _languages.length - 1)
                  const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                      color: _kDivider),
              ],
            ],
          ),
        ),
        SizedBox(height: 24 * s),
        _PrimaryButton(
          label: 'Kaydet',
          onTap: () {
            Get.back<void>();
            _toast('Dil: $_selected');
          },
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 6 · Yardım Merkezi
// ══════════════════════════════════════════════════════════════════════════════
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faq = [
    ['Nasıl proje oluştururum?', 'Ana ekrandaki + butonuna dokunarak yeni bir brief oluşturabilirsin. Detayları girip yayınladığında freelancerlar teklif göndermeye başlar.'],
    ['Ödemeler nasıl işliyor?', 'İş tamamlandığında ödeme freelancer hesabına aktarılır. Onaylayana kadar tutar güvende tutulur.'],
    ['Bir freelancerla nasıl iletişime geçerim?', 'Freelancer profilindeki "Mesaj Gönder" butonuyla doğrudan yazışabilirsin.'],
    ['Hesabımı nasıl silerim?', 'Profil > Hesabı Sil bölümünden hesabını kalıcı olarak silebilirsin.'],
  ];

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return _ProfileSubScaffold(
      title: 'Yardım Merkezi',
      subtitle: 'Sık sorulan sorular.',
      children: [
        _Card(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            children: [
              for (final item in _faq)
                Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 12 * s),
                    childrenPadding: EdgeInsets.fromLTRB(12 * s, 0, 12 * s, 14 * s),
                    iconColor: _kGold,
                    collapsedIconColor: _kMuted,
                    title: Text(
                      item[0],
                      style: _serif(
                          size: 16 * s, weight: FontWeight.w600, color: _kInk),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item[1],
                          style:
                              _mono(size: 9 * s, color: _kTaupe, spacing: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 7 · Bize Ulaş
// ══════════════════════════════════════════════════════════════════════════════
class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return _ProfileSubScaffold(
      title: 'Bize Ulaş',
      subtitle: 'Sorunu veya önerini bize ilet, en kısa sürede dönüş yapalım.',
      children: [
        _Card(
          child: Column(
            children: [
              _LabeledField(
                  label: 'Konu', controller: _subject, hint: 'Kısa bir başlık'),
              SizedBox(height: 16 * s),
              _LabeledField(
                  label: 'Mesajın',
                  controller: _message,
                  hint: 'Detayları buraya yaz',
                  maxLines: 5),
            ],
          ),
        ),
        SizedBox(height: 24 * s),
        _PrimaryButton(
          label: 'Gönder',
          onTap: () {
            if (_message.text.trim().isEmpty) {
              _toast('Lütfen mesajını yaz');
              return;
            }
            Get.back<void>();
            _toast('Mesajın alındı, teşekkürler!');
          },
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 8 · Kullanım Koşulları
// ══════════════════════════════════════════════════════════════════════════════
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _sections = [
    ['1. Genel Koşullar', 'SET platformunu kullanarak bu koşulları kabul etmiş sayılırsın. Platform, hizmet alan ve freelancerları bir araya getiren bir aracıdır.'],
    ['2. Hesap Sorumluluğu', 'Hesabının güvenliğinden ve altında gerçekleşen tüm işlemlerden sen sorumlusun. Giriş bilgilerini kimseyle paylaşma.'],
    ['3. Ödemeler', 'Tüm ödemeler platform üzerinden güvenli şekilde işlenir. İş tamamlanana kadar tutar güvence altında tutulur.'],
    ['4. İçerik ve Davranış', 'Platformda paylaşılan içeriklerin yasalara uygun olması gerekir. Uygunsuz davranış hesabın askıya alınmasına yol açabilir.'],
    ['5. Değişiklikler', 'Bu koşullar zaman zaman güncellenebilir. Önemli değişikliklerde bilgilendirileceksin.'],
  ];

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return _ProfileSubScaffold(
      title: 'Kullanım Koşulları',
      subtitle: 'Son güncelleme: Temmuz 2026',
      children: [
        for (final sec in _sections) ...[
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sec[0],
                  style:
                      _serif(size: 17 * s, weight: FontWeight.w700, color: _kInk),
                ),
                SizedBox(height: 8 * s),
                Text(
                  sec[1],
                  style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.2),
                ),
              ],
            ),
          ),
          SizedBox(height: 12 * s),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 9 · Hesabı Sil
// ══════════════════════════════════════════════════════════════════════════════
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return _ProfileSubScaffold(
      title: 'Hesabı Sil',
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48 * s,
                height: 48 * s,
                color: _kDanger.withValues(alpha: 0.12),
                alignment: Alignment.center,
                child: Icon(Icons.warning_amber_rounded,
                    color: _kDanger, size: 26 * s),
              ),
              SizedBox(height: 14 * s),
              Text(
                'Hesabını silmek üzeresin',
                style:
                    _serif(size: 20 * s, weight: FontWeight.w600, color: _kInk),
              ),
              SizedBox(height: 8 * s),
              Text(
                'Bu işlem geri alınamaz. Tüm projelerin, mesajların ve profil bilgilerin kalıcı olarak silinir.',
                style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.2),
              ),
            ],
          ),
        ),
        SizedBox(height: 16 * s),
        InkWell(
          onTap: () => setState(() => _confirmed = !_confirmed),
          child: Row(
            children: [
              Checkbox(
                value: _confirmed,
                onChanged: (v) => setState(() => _confirmed = v ?? false),
                activeColor: _kDanger,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              Expanded(
                child: Text(
                  'Sonuçları anladım ve hesabımı silmek istiyorum.',
                  style: _mono(size: 9 * s, color: _kInk, spacing: 0.2),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16 * s),
        _PrimaryButton(
          label: 'Hesabı Kalıcı Olarak Sil',
          danger: true,
          onTap: _confirmed
              ? () {
                  Get.back<void>();
                  _toast('Hesap silme talebin alındı');
                }
              : () => _toast('Lütfen önce onay kutusunu işaretle'),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 10 · Freelancer Profili (avatara dokununca açılan sayfa)
// ══════════════════════════════════════════════════════════════════════════════
class FreelancerOwnProfileScreen extends StatefulWidget {
  const FreelancerOwnProfileScreen({super.key});

  @override
  State<FreelancerOwnProfileScreen> createState() =>
      _FreelancerOwnProfileScreenState();
}

class _FreelancerOwnProfileScreenState extends State<FreelancerOwnProfileScreen> {
  final FreelancerRepository _repo = Get.find<FreelancerRepository>();
  FreelancerModel? _freelancer;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = Get.find<UserController>().currentUser;
    if (u == null) return;
    final f = await _repo.fetchByUserId(u.id);
    if (!mounted) return;
    setState(() => _freelancer = f);
  }

  Future<void> _editPhoto() async {
    final u = Get.find<UserController>().currentUser;
    if (u == null) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${u.id}.jpg');
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();
      final base = _freelancer ??
          FreelancerModel(
            userId: u.id,
            name: u.name,
            surname: u.surname,
            categories: const [],
            bio: '',
            experience: 0,
            location: '',
            rating: 0,
          );
      final updated = base.copyWith(profileImageUrl: url);
      await _repo.upsertFreelancer(updated);
      if (!mounted) return;
      setState(() {
        _freelancer = updated;
        _uploadingPhoto = false;
      });
      _toast('Profil fotoğrafın güncellendi');
    } catch (_) {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
        _toast('Yükleme başarısız oldu, tekrar dene');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    final u = Get.find<UserController>().currentUser;
    final name = u?.fullName ?? 'Freelancer';
    final email = u?.email ?? '';
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final photoUrl = _freelancer?.profileImageUrl;

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12 * s, 8 * s, 20 * s, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back<void>(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8 * s),
                        child: Icon(Icons.arrow_back_rounded,
                            size: 22 * s, color: _kInk),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Text(
                      'Profil',
                      style: _serif(size: 26 * s, weight: FontWeight.w600, color: _kInk),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28 * s),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 96 * s,
                      height: 96 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.45),
                        border: Border.all(color: _kGold, width: 1.8),
                      ),
                      alignment: Alignment.center,
                      child: (photoUrl != null && photoUrl.isNotEmpty)
                          ? ClipOval(
                              child: SizedBox(
                                width: 92 * s,
                                height: 92 * s,
                                child: CachedNetworkImage(
                                  imageUrl: photoUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, _) => Text(
                                    initial,
                                    style: _serif(
                                        size: 34 * s, weight: FontWeight.w500, color: _kGold),
                                  ),
                                  errorWidget: (_, _, _) => Text(
                                    initial,
                                    style: _serif(
                                        size: 34 * s, weight: FontWeight.w500, color: _kGold),
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              initial,
                              style: _serif(size: 34 * s, weight: FontWeight.w500, color: _kGold),
                            ),
                    ),
                    Positioned(
                      right: -2 * s,
                      bottom: -2 * s,
                      child: GestureDetector(
                        onTap: _uploadingPhoto ? null : _editPhoto,
                        child: Container(
                          width: 30 * s,
                          height: 30 * s,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kGold,
                            border: Border.all(color: _kCream, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: _uploadingPhoto
                              ? SizedBox(
                                  width: 14 * s,
                                  height: 14 * s,
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Icon(Icons.edit, size: 14 * s, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16 * s),
              Center(
                child: Text(
                  name,
                  style: _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk),
                ),
              ),
              if (email.isNotEmpty) ...[
                SizedBox(height: 4 * s),
                Center(
                  child: Text(
                    email,
                    style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.2),
                  ),
                ),
              ],
              SizedBox(height: 36 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: _ProfileMenuRow(
                  scale: s,
                  icon: Icons.grid_view_rounded,
                  label: 'Portfolyo / Profil Düzenle',
                  sub: 'Hizmet alanları, deneyim, hakkımda ve projeler',
                  onTap: () => Get.to<void>(() => const FreelancerPortfolioEditScreen()),
                ),
              ),
              SizedBox(height: 12 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: _ProfileMenuRow(
                  scale: s,
                  icon: Icons.forum_outlined,
                  label: 'Etkileşimler',
                  sub: 'Yorumlar, oylamalar ve tamamlanan projeler',
                  onTap: () => Get.to<void>(() => const FreelancerInteractionsScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Profil ana sayfası menü satırı ────────────────────────────────────────────
class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({
    required this.scale,
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  final double scale;
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 16 * s),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
        ),
        child: Row(
          children: [
            Container(
              width: 38 * s,
              height: 38 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withValues(alpha: 0.14)),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16 * s, color: _kInk),
            ),
            SizedBox(width: 15 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: _serif(size: 14 * s, weight: FontWeight.w500, color: _kInk)),
                  SizedBox(height: 3 * s),
                  Text(sub, style: _mono(size: 8 * s, color: _kTaupe, spacing: 0.2)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16 * s, color: Colors.black.withValues(alpha: 0.22)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 11 · Portfolyo / Profil Düzenle (hizmet alanları, deneyim, hakkımda, projeler)
// ══════════════════════════════════════════════════════════════════════════════
class FreelancerPortfolioEditScreen extends StatefulWidget {
  const FreelancerPortfolioEditScreen({super.key});

  @override
  State<FreelancerPortfolioEditScreen> createState() =>
      _FreelancerPortfolioEditScreenState();
}

class _FreelancerPortfolioEditScreenState
    extends State<FreelancerPortfolioEditScreen> {
  final FreelancerRepository _repo = Get.find<FreelancerRepository>();
  final UserRepository _userRepo = Get.find<UserRepository>();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  List<String> _selectedCategories = [];
  int _experience = 0;
  List<PortfolioProject> _projects = [];
  FreelancerModel? _current;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final u = Get.find<UserController>().currentUser;
    if (u == null) {
      setState(() => _loading = false);
      return;
    }
    final f = await _repo.fetchByUserId(u.id);
    if (!mounted) return;
    setState(() {
      _current = f;
      _selectedCategories = f != null ? List<String>.from(f.categories) : <String>[];
      _experience = f?.experience ?? 0;
      _bioController.text = f?.bio ?? '';
      _projects = f != null ? List<PortfolioProject>.from(f.projects) : <PortfolioProject>[];
      _nameController.text = (f?.name.isNotEmpty ?? false) ? f!.name : u.name;
      _surnameController.text = f?.surname ?? u.surname ?? '';
      _locationController.text = f?.location ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final u = Get.find<UserController>().currentUser;
    if (u == null) return;
    setState(() => _saving = true);
    try {
      final name = _nameController.text.trim();
      final surname = _surnameController.text.trim();
      final base = _current ??
          FreelancerModel(
            userId: u.id,
            name: u.name,
            surname: u.surname,
            categories: const [],
            bio: '',
            experience: 0,
            location: '',
            rating: 0,
          );
      final updated = base.copyWith(
        name: name.isNotEmpty ? name : base.name,
        surname: surname,
        categories: List<String>.from(_selectedCategories),
        experience: _experience,
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        projects: List<PortfolioProject>.from(_projects),
      );
      await _repo.upsertFreelancer(updated);
      _current = updated;

      if (name.isNotEmpty && (name != u.name || surname != (u.surname ?? ''))) {
        final updatedUser = u.copyWith(
          name: name,
          surname: surname.isEmpty ? null : surname,
        );
        await _userRepo.upsertUser(updatedUser);
        Get.find<UserController>().setUser(updatedUser);
      }

      if (!mounted) return;
      Get.back<void>();
      _toast('Profilin güncellendi');
    } catch (_) {
      if (mounted) _toast('Bir şeyler ters gitti, tekrar dene');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openNameLocationSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final s = _scaleOf(ctx);
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Container(
          decoration: const BoxDecoration(color: _kCream),
          padding: EdgeInsets.fromLTRB(20 * s, 14 * s, 20 * s, bottom + 20 * s),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _bottomSheetHandle(s)),
                SizedBox(height: 14 * s),
                Text('Ad Soyad & Konum',
                    style: _serif(size: 20 * s, weight: FontWeight.w600, color: _kInk)),
                SizedBox(height: 4 * s),
                Text(
                  'Profilinde görünen kimlik bilgilerini güncelle.',
                  style: _mono(size: 8.5 * s, color: _kTaupe, spacing: 0.2),
                ),
                SizedBox(height: 16 * s),
                _LabeledField(label: 'Ad', controller: _nameController, hint: 'Adın'),
                SizedBox(height: 14 * s),
                _LabeledField(label: 'Soyad', controller: _surnameController, hint: 'Soyadın'),
                SizedBox(height: 14 * s),
                _LabeledField(
                  label: 'Konum',
                  controller: _locationController,
                  hint: 'Şehir, ülke',
                ),
                SizedBox(height: 20 * s),
                _PrimaryButton(label: 'Tamam', onTap: () => Navigator.of(ctx).pop()),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCategoriesSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final s = _scaleOf(ctx);
            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
              decoration: const BoxDecoration(color: _kCream),
              padding: EdgeInsets.fromLTRB(
                  20 * s, 10 * s, 20 * s, 20 * s + MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _bottomSheetHandle(s)),
                  SizedBox(height: 14 * s),
                  Text('Hizmet Alanları',
                      style: _serif(size: 20 * s, weight: FontWeight.w600, color: _kInk)),
                  SizedBox(height: 4 * s),
                  Text(
                    'Birden fazla seçebilirsin, eklemek veya çıkarmak için dokun.',
                    style: _mono(size: 8.5 * s, color: _kTaupe, spacing: 0.2),
                  ),
                  SizedBox(height: 16 * s),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8 * s,
                        runSpacing: 8 * s,
                        children: DummyData.categories.map((cat) {
                          final selected = _selectedCategories.contains(cat);
                          return InkWell(
                            onTap: () => setSheetState(() {
                              setState(() {
                                if (selected) {
                                  _selectedCategories.remove(cat);
                                } else {
                                  _selectedCategories.add(cat);
                                }
                              });
                            }),
                            child: Container(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 14 * s, vertical: 9 * s),
                              decoration: BoxDecoration(
                                color: selected ? _kGold.withValues(alpha: 0.14) : Colors.white,
                                border: Border.all(
                                  color: selected ? _kGold : _kCardBorder,
                                  width: selected ? 1.2 : 1,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: _mono(
                                  size: 9.5 * s,
                                  weight: selected ? FontWeight.w700 : FontWeight.w400,
                                  color: selected ? _kGold : _kInk,
                                  spacing: 0.3,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20 * s),
                  _PrimaryButton(label: 'Tamam', onTap: () => Navigator.of(ctx).pop()),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openExperienceSheet() {
    int temp = _experience;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final s = _scaleOf(ctx);
        return Container(
          height: 300 * s,
          decoration: const BoxDecoration(color: _kCream),
          child: Column(
            children: [
              SizedBox(height: 10 * s),
              _bottomSheetHandle(s),
              SizedBox(height: 10 * s),
              Text('Deneyim Yılı',
                  style: _serif(size: 18 * s, weight: FontWeight.w600, color: _kInk)),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 42 * s,
                  scrollController: FixedExtentScrollController(initialItem: _experience),
                  onSelectedItemChanged: (i) => temp = i,
                  children: List.generate(
                    41,
                    (i) => Center(
                      child: Text(
                        i == 0 ? '0 yıl' : '$i yıl',
                        style: _mono(size: 12 * s, color: _kInk, spacing: 0.2),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16 * s),
                child: _PrimaryButton(
                  label: 'Seç',
                  onTap: () {
                    setState(() => _experience = temp);
                    Navigator.of(ctx).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openBioSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final s = _scaleOf(ctx);
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Container(
          decoration: const BoxDecoration(color: _kCream),
          padding: EdgeInsets.fromLTRB(20 * s, 14 * s, 20 * s, bottom + 20 * s),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _bottomSheetHandle(s)),
                SizedBox(height: 14 * s),
                Text('Hakkımda',
                    style: _serif(size: 20 * s, weight: FontWeight.w600, color: _kInk)),
                SizedBox(height: 4 * s),
                Text(
                  'Kendinden kısaca bahset, hangi işlere odaklanıyorsun?',
                  style: _mono(size: 8.5 * s, color: _kTaupe, spacing: 0.2),
                ),
                SizedBox(height: 16 * s),
                _LabeledField(
                  label: 'Açıklama',
                  controller: _bioController,
                  hint: 'Örn. Reklam filmi ve müzik videosu yönetmenliği yapıyorum...',
                  maxLines: 6,
                ),
                SizedBox(height: 20 * s),
                _PrimaryButton(
                  label: 'Tamam',
                  onTap: () {
                    setState(() {});
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openProjectsManagerSheet() {
    final u = Get.find<UserController>().currentUser;
    if (u == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProjectsManagerSheet(
        initialProjects: _projects,
        userId: u.id,
        onChanged: (updated) => setState(() => _projects = updated),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12 * s, 8 * s, 20 * s, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back<void>(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8 * s),
                        child: Icon(Icons.arrow_back_rounded, size: 22 * s, color: _kInk),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: Text(
                        'Portfolyo / Profil Düzenle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Text(
                  'Profilinde görünen bilgileri güncelle.',
                  style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.3),
                ),
              ),
              SizedBox(height: 18 * s),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: EdgeInsets.fromLTRB(24 * s, 0, 24 * s, 24 * s),
                        children: [
                          _PortfolioSettingsRow(
                            scale: s,
                            icon: Icons.grid_view_rounded,
                            label: 'Hizmet Alanları',
                            sub: _selectedCategories.isEmpty
                                ? 'Henüz seçim yapılmadı'
                                : '${_selectedCategories.length} alan seçili',
                            onTap: _openCategoriesSheet,
                          ),
                          const Divider(height: 1, thickness: 1, color: _kDivider),
                          _PortfolioSettingsRow(
                            scale: s,
                            icon: Icons.timeline_outlined,
                            label: 'Deneyim Yılı',
                            sub: _experience == 0 ? '0 yıl' : '$_experience yıl',
                            onTap: _openExperienceSheet,
                          ),
                          const Divider(height: 1, thickness: 1, color: _kDivider),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _bioController,
                            builder: (_, value, _) => _PortfolioSettingsRow(
                              scale: s,
                              icon: Icons.edit_note_rounded,
                              label: 'Hakkımda',
                              sub: value.text.trim().isEmpty
                                  ? 'Henüz eklenmedi'
                                  : value.text.trim(),
                              onTap: _openBioSheet,
                            ),
                          ),
                          const Divider(height: 1, thickness: 1, color: _kDivider),
                          _PortfolioSettingsRow(
                            scale: s,
                            icon: Icons.photo_library_outlined,
                            label: 'Projelerin',
                            sub: _projects.isEmpty
                                ? 'Henüz proje eklenmedi'
                                : '${_projects.length} proje eklendi',
                            onTap: _openProjectsManagerSheet,
                          ),
                          const Divider(height: 1, thickness: 1, color: _kDivider),
                          AnimatedBuilder(
                            animation: Listenable.merge(
                                [_nameController, _surnameController, _locationController]),
                            builder: (_, _) {
                              final fullName =
                                  '${_nameController.text.trim()} ${_surnameController.text.trim()}'
                                      .trim();
                              final location = _locationController.text.trim();
                              final sub = [
                                if (fullName.isNotEmpty) fullName,
                                if (location.isNotEmpty) location,
                              ].join(' · ');
                              return _PortfolioSettingsRow(
                                scale: s,
                                icon: Icons.badge_outlined,
                                label: 'Ad Soyad & Konum',
                                sub: sub.isEmpty ? 'Henüz eklenmedi' : sub,
                                onTap: _openNameLocationSheet,
                              );
                            },
                          ),
                        ],
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24 * s, 12 * s, 24 * s, 16 * s),
                  child: _PrimaryButton(
                    label: _saving ? 'Kaydediliyor...' : 'Kaydet',
                    onTap: _saving ? () {} : _save,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Portfolyo ekranı satırı ──────────────────────────────────────────────────
class _PortfolioSettingsRow extends StatelessWidget {
  const _PortfolioSettingsRow({
    required this.scale,
    required this.icon,
    required this.label,
    required this.onTap,
    this.sub,
  });

  final double scale;
  final IconData icon;
  final String label;
  final String? sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18 * s),
        child: Row(
          children: [
            Container(
              width: 38 * s,
              height: 38 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withValues(alpha: 0.14)),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16 * s, color: _kInk),
            ),
            SizedBox(width: 15 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: _serif(size: 14 * s, weight: FontWeight.w500, color: _kInk)),
                  if (sub != null) ...[
                    SizedBox(height: 3 * s),
                    Text(
                      sub!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _mono(size: 8 * s, color: _kTaupe, spacing: 0.2),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16 * s, color: Colors.black.withValues(alpha: 0.22)),
          ],
        ),
      ),
    );
  }
}

// ─── Proje yöneticisi (sırala / ekle / sil) ────────────────────────────────────
class _ProjectsManagerSheet extends StatefulWidget {
  const _ProjectsManagerSheet({
    required this.initialProjects,
    required this.userId,
    required this.onChanged,
  });

  final List<PortfolioProject> initialProjects;
  final String userId;
  final ValueChanged<List<PortfolioProject>> onChanged;

  @override
  State<_ProjectsManagerSheet> createState() => _ProjectsManagerSheetState();
}

class _ProjectsManagerSheetState extends State<_ProjectsManagerSheet> {
  late List<PortfolioProject> _projects;

  @override
  void initState() {
    super.initState();
    _projects = List<PortfolioProject>.from(widget.initialProjects);
  }

  void _emit() => widget.onChanged(List<PortfolioProject>.from(_projects));

  Future<void> _openAddProjectSheet() async {
    final added = await showModalBottomSheet<PortfolioProject>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddProjectSheet(userId: widget.userId),
    );
    if (added != null) {
      setState(() => _projects.add(added));
      _emit();
    }
  }

  void _removeAt(int index) {
    setState(() => _projects.removeAt(index));
    _emit();
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _projects.removeAt(oldIndex);
      _projects.insert(newIndex, item);
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(color: _kCream),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10 * s),
          Center(child: _bottomSheetHandle(s)),
          Padding(
            padding: EdgeInsets.fromLTRB(20 * s, 14 * s, 20 * s, 0),
            child: Text('Projelerin',
                style: _serif(size: 20 * s, weight: FontWeight.w600, color: _kInk)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20 * s, 4 * s, 20 * s, 12 * s),
            child: Text(
              'Sürükleyerek sırasını değiştirebilirsin, ilk sıradaki proje önce görünür.',
              style: _mono(size: 8.5 * s, color: _kTaupe, spacing: 0.2),
            ),
          ),
          Expanded(
            child: _projects.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32 * s),
                      child: Text(
                        'Henüz proje eklemedin. Aşağıdaki butonla ilk projeni yükle.',
                        textAlign: TextAlign.center,
                        style: _mono(size: 9 * s, color: _kMuted, spacing: 0.2),
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    padding: EdgeInsets.symmetric(horizontal: 20 * s),
                    itemCount: _projects.length,
                    onReorder: _reorder,
                    itemBuilder: (ctx, i) {
                      final p = _projects[i];
                      return Padding(
                        key: ValueKey('proj-$i-${p.title}-${p.thumbnailUrl ?? ''}'),
                        padding: EdgeInsets.only(bottom: 10 * s),
                        child: _ProjectManagerRow(
                          order: i + 1,
                          project: p,
                          scale: s,
                          onDelete: () => _removeAt(i),
                          dragHandle: ReorderableDragStartListener(
                            index: i,
                            child: Icon(Icons.drag_handle_rounded,
                                size: 18 * s, color: Colors.black.withValues(alpha: 0.22)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 8 * s),
            child: InkWell(
              onTap: _openAddProjectSheet,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14 * s),
                decoration: BoxDecoration(border: Border.all(color: _kGold)),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 18 * s, color: _kGold),
                    SizedBox(width: 8 * s),
                    Text('Proje Yükle',
                        style: _mono(
                            size: 10 * s, weight: FontWeight.w700, color: _kGold, spacing: 0.4)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 20 * s),
            child: _PrimaryButton(label: 'Tamam', onTap: () => Navigator.of(context).pop()),
          ),
        ],
      ),
    );
  }
}

// ─── Proje sırası satırı ───────────────────────────────────────────────────────
class _ProjectManagerRow extends StatelessWidget {
  const _ProjectManagerRow({
    required this.order,
    required this.project,
    required this.scale,
    required this.onDelete,
    required this.dragHandle,
  });

  final int order;
  final PortfolioProject project;
  final double scale;
  final VoidCallback onDelete;
  final Widget dragHandle;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 22 * s,
            height: 22 * s,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(color: _kGold.withValues(alpha: 0.14), shape: BoxShape.circle),
            child: Text('$order',
                style: _mono(size: 9 * s, weight: FontWeight.w700, color: _kGold)),
          ),
          SizedBox(width: 10 * s),
          SizedBox(
            width: 44 * s,
            height: 44 * s,
            child: (project.thumbnailUrl != null && project.thumbnailUrl!.isNotEmpty)
                ? Image.network(project.thumbnailUrl!, fit: BoxFit.cover)
                : Container(
                    color: _kCardBorder,
                    alignment: Alignment.center,
                    child: Icon(Icons.image_outlined, size: 18 * s, color: _kTaupe),
                  ),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  project.title.isNotEmpty ? project.title : 'İsimsiz proje',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _serif(size: 14 * s, weight: FontWeight.w600, color: _kInk),
                ),
                if (project.jobType.isNotEmpty) ...[
                  SizedBox(height: 2 * s),
                  Text(
                    project.jobType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _mono(size: 8 * s, color: _kTaupe, spacing: 0.2),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.close, size: 16 * s, color: _kTaupe),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 4 * s),
          dragHandle,
        ],
      ),
    );
  }
}

// ─── Proje yükleme formu (görsel + bilgiler) ───────────────────────────────────
class _AddProjectSheet extends StatefulWidget {
  const _AddProjectSheet({required this.userId});
  final String userId;

  @override
  State<_AddProjectSheet> createState() => _AddProjectSheetState();
}

class _AddProjectSheetState extends State<_AddProjectSheet> {
  final _titleCtrl = TextEditingController();
  final _jobTypeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _videoCtrl = TextEditingController();

  File? _pickedImage;
  bool _uploading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _jobTypeCtrl.dispose();
    _descCtrl.dispose();
    _videoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty && _jobTypeCtrl.text.trim().isEmpty) {
      return;
    }
    setState(() => _uploading = true);
    try {
      String? thumbnailUrl;
      final file = _pickedImage;
      if (file != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('portfolio_thumbnails')
            .child(widget.userId)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(file);
        thumbnailUrl = await ref.getDownloadURL();
      }
      final project = PortfolioProject(
        title: _titleCtrl.text.trim(),
        jobType: _jobTypeCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        videoUrl: _videoCtrl.text.trim().isEmpty ? null : _videoCtrl.text.trim(),
        thumbnailUrl: thumbnailUrl,
      );
      if (!mounted) return;
      Navigator.of(context).pop(project);
    } catch (_) {
      if (mounted) {
        setState(() => _uploading = false);
        _toast('Yükleme başarısız oldu, tekrar dene');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(color: _kCream),
      padding: EdgeInsets.fromLTRB(20 * s, 14 * s, 20 * s, bottom + 20 * s),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _bottomSheetHandle(s)),
            SizedBox(height: 14 * s),
            Text('Proje Yükle', style: _serif(size: 20 * s, weight: FontWeight.w600, color: _kInk)),
            SizedBox(height: 4 * s),
            Text('Projene özel bir isim ve görsel ekle.',
                style: _mono(size: 8.5 * s, color: _kTaupe, spacing: 0.2)),
            SizedBox(height: 16 * s),
            InkWell(
              onTap: _uploading ? null : _pickImage,
              child: Container(
                width: double.infinity,
                height: 140 * s,
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _kCardBorder)),
                child: _pickedImage != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_pickedImage!, fit: BoxFit.cover),
                          Positioned(
                            right: 6 * s,
                            top: 6 * s,
                            child: GestureDetector(
                              onTap: () => setState(() => _pickedImage = null),
                              child: Container(
                                padding: EdgeInsets.all(4 * s),
                                decoration:
                                    const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: Icon(Icons.close, size: 14 * s, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 26 * s, color: _kGold),
                          SizedBox(height: 6 * s),
                          Text('Görsel Yükle',
                              style: _mono(
                                  size: 9 * s,
                                  weight: FontWeight.w700,
                                  color: _kGold,
                                  spacing: 0.4)),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 16 * s),
            _LabeledField(label: 'Proje Adı', controller: _titleCtrl, hint: 'Örn. Migros Reklam Filmi'),
            SizedBox(height: 14 * s),
            _LabeledField(label: 'İş Tanımı', controller: _jobTypeCtrl, hint: 'Reklam filmi'),
            SizedBox(height: 14 * s),
            _LabeledField(
              label: 'Kısa Açıklama',
              controller: _descCtrl,
              hint: 'Projeni kısaca anlat...',
              maxLines: 4,
            ),
            SizedBox(height: 14 * s),
            _LabeledField(
              label: 'Video Linki',
              controller: _videoCtrl,
              hint: 'YouTube, Vimeo veya video URL\'i',
            ),
            SizedBox(height: 20 * s),
            _PrimaryButton(
              label: _uploading ? 'Yükleniyor...' : 'Ekle',
              onTap: _uploading ? () {} : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 12 · Etkileşimler (müşteri yorumları, oylamalar, tamamlanan proje sayısı)
// ══════════════════════════════════════════════════════════════════════════════
class FreelancerInteractionsScreen extends StatefulWidget {
  const FreelancerInteractionsScreen({super.key});

  @override
  State<FreelancerInteractionsScreen> createState() =>
      _FreelancerInteractionsScreenState();
}

class _FreelancerInteractionsScreenState extends State<FreelancerInteractionsScreen> {
  final FreelancerRepository _repo = Get.find<FreelancerRepository>();
  FreelancerModel? _freelancer;
  bool _loading = true;

  static const _reviews = [
    ('M', 'Migros', 'Marka Filmi', 5.0, 'Harika bir iş çıkardı, tekrar çalışırız.'),
    ('B', 'Beko', 'Reklam Filmi', 4.9, 'Çok profesyonel ve zamanında teslim.'),
    ('A', 'Ajet', 'Tanıtım Filmi', 5.0, 'Kesinlikle tavsiye ederim.'),
    ('T', 'Türk Telekom', 'Kurumsal', 4.8, 'Kaliteli çekim, iletişimi çok iyiydi.'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = Get.find<UserController>().currentUser;
    if (u == null) {
      setState(() => _loading = false);
      return;
    }
    final f = await _repo.fetchByUserId(u.id);
    if (!mounted) return;
    setState(() {
      _freelancer = f;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    final rating = _freelancer?.rating ?? 0;
    final completedProjects = _freelancer?.projects.length ?? 0;

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12 * s, 8 * s, 20 * s, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back<void>(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8 * s),
                        child: Icon(Icons.arrow_back_rounded, size: 22 * s, color: _kInk),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Text(
                      'Etkileşimler',
                      style: _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Text(
                  'Müşterilerinden aldığın yorumlar ve oylamalar.',
                  style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.3),
                ),
              ),
              SizedBox(height: 18 * s),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: EdgeInsets.fromLTRB(24 * s, 0, 24 * s, 24 * s),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatBlock(
                                  scale: s,
                                  value: rating > 0 ? rating.toStringAsFixed(1) : '—',
                                  label: 'Ortalama Puan',
                                ),
                              ),
                              SizedBox(width: 10 * s),
                              Expanded(
                                child: _StatBlock(
                                  scale: s,
                                  value: '${_reviews.length}',
                                  label: 'Toplam Yorum',
                                ),
                              ),
                              SizedBox(width: 10 * s),
                              Expanded(
                                child: _StatBlock(
                                  scale: s,
                                  value: '$completedProjects',
                                  label: 'Tamamlanan Proje',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 26 * s),
                          Text(
                            'Yorumlar (${_reviews.length})',
                            style: _serif(size: 18 * s, weight: FontWeight.w600, color: _kInk),
                          ),
                          SizedBox(height: 12 * s),
                          ..._reviews.map((r) => Padding(
                                padding: EdgeInsets.only(bottom: 10 * s),
                                child: _InteractionReviewItem(
                                  scale: s,
                                  initials: r.$1,
                                  brand: r.$2,
                                  projectType: r.$3,
                                  rating: r.$4,
                                  comment: r.$5,
                                ),
                              )),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── İstatistik kutusu ──────────────────────────────────────────────────────────
class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.scale, required this.value, required this.label});

  final double scale;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 14 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: _serif(size: 22 * s, weight: FontWeight.w700, color: _kGold)),
          SizedBox(height: 4 * s),
          Text(
            label.toUpperCase(),
            style: _mono(size: 7 * s, weight: FontWeight.w700, color: _kMuted, spacing: 0.8),
          ),
        ],
      ),
    );
  }
}

// ─── Etkileşim yorumu kartı ──────────────────────────────────────────────────────
class _InteractionReviewItem extends StatelessWidget {
  const _InteractionReviewItem({
    required this.scale,
    required this.initials,
    required this.brand,
    required this.projectType,
    required this.rating,
    required this.comment,
  });

  final double scale;
  final String initials;
  final String brand;
  final String projectType;
  final double rating;
  final String comment;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.all(14 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38 * s,
            height: 38 * s,
            color: const Color(0xFFEADCBB),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: _mono(size: 12 * s, weight: FontWeight.w700, color: _kInk, spacing: 0.5),
            ),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$brand · $projectType',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _mono(size: 8 * s, color: _kTaupe, spacing: 0.3),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star_rounded,
                          size: 12 * s,
                          color: i < rating.round() ? _kGold : Colors.black12,
                        ),
                      ),
                    ),
                    SizedBox(width: 4 * s),
                    Text(
                      rating.toStringAsFixed(1),
                      style: _mono(size: 8 * s, weight: FontWeight.w700, color: _kInk, spacing: 0.3),
                    ),
                  ],
                ),
                SizedBox(height: 5 * s),
                Text(
                  comment,
                  style: _serif(size: 15 * s, weight: FontWeight.w500, color: _kInk),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
