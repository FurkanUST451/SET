import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/avatar_image.dart';
import '../../../routes/app_routes.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFF6F4EF); // sayfa gövdesi
const _kBlackout = Color(0xFF000000); // muhatap bloğu ve alt kart
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF16150F); // krem üzeri başlık/gövde
const _kTaupe = Color(0xFF8E877B); // krem üzeri ikincil
const _kMuted = Color(0xFFB3ABA0); // krem üzeri pasif
const _kLine = Color(0x14000000); // krem üzeri hairline
const _kNightLine = Color(0xFF262626); // siyah üzeri hairline
const _kOnDarkSoft = Color(0xFF8C877E); // siyah üzeri ikincil
const _kOnline = Color(0xFF4CAF50);

// Mockup'taki portreler tek renk (siyah-beyaz) basılır.
const ColorFilter _kMono = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

// ─── Tipografi yardımcıları ───────────────────────────────────────────────────
TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w600,
  required Color color,
  double height = 1.0,
  bool italic = false,
}) => AppFonts.display(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
);

TextStyle _ui({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.4,
  double height = 1.4,
  bool italic = false,
}) => AppFonts.ui(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
  height: height,
  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
);

// ─── Sayfa ────────────────────────────────────────────────────────────────────

class SetProjectsView extends StatefulWidget {
  const SetProjectsView({super.key});

  @override
  State<SetProjectsView> createState() => _SetProjectsViewState();
}

class _SetProjectsViewState extends State<SetProjectsView> {
  // "Sıradaki adım" kartındaki tarih seçenekleri.
  int _selectedDate = -1; // -1: henüz seçim yok

  static const double _kPad = 24; // gövde yatay boşluğu (s ile çarpılır)

  @override
  Widget build(BuildContext context) {
    final double s = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.85, 1.15)
        .toDouble();
    final double topInset = MediaQuery.paddingOf(context).top;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _kCream,
        body: MediaQuery.withNoTextScaling(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset + 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Siyah üst blok: künye, başlık, sayaçlar ────────────────
                _HeaderBlock(scale: s, topInset: topInset),

                // ── Siyah muhatap bloğu ───────────────────────────────────
                _ManagerBlock(scale: s),

                // ── SÜREÇ ─────────────────────────────────────────────────
                SizedBox(height: 26 * s),
                _pad(s, _SectionRule(scale: s)),
                SizedBox(height: 14 * s),
                _pad(s, _SectionLabel(scale: s, text: 'SÜREÇ')),
                SizedBox(height: 10 * s),
                _pad(
                  s,
                  Text(
                    'Ekip kuruluyor.',
                    style: _display(size: 28 * s, color: _kInk),
                  ),
                ),
                SizedBox(height: 16 * s),
                _Timeline(scale: s, horizontalPadding: _kPad * s),

                // ── EKİP ──────────────────────────────────────────────────
                SizedBox(height: 26 * s),
                _pad(s, _SectionRule(scale: s)),
                SizedBox(height: 14 * s),
                _pad(
                  s,
                  Row(
                    children: [
                      _SectionLabel(scale: s, text: 'EKİP'),
                      const Spacer(),
                      _LinkText(scale: s, text: 'TÜMÜNÜ GÖR'),
                    ],
                  ),
                ),
                SizedBox(height: 10 * s),
                _pad(
                  s,
                  Text(
                    '4 kişiden 3\'ü onayladı.',
                    style: _display(size: 28 * s, color: _kInk),
                  ),
                ),
                SizedBox(height: 16 * s),
                _pad(s, _TeamList(scale: s)),

                // ── SON GÜNCELLEME ────────────────────────────────────────
                SizedBox(height: 26 * s),
                _pad(s, _SectionRule(scale: s)),
                SizedBox(height: 14 * s),
                _pad(s, _SectionLabel(scale: s, text: 'SON GÜNCELLEME')),
                SizedBox(height: 14 * s),
                _pad(s, _LastUpdate(scale: s)),
                SizedBox(height: 14 * s),
                _pad(
                  s,
                  Row(
                    children: [
                      const Spacer(),
                      _LinkText(scale: s, text: 'TÜM GÜNCELLEMELER (8)'),
                    ],
                  ),
                ),

                // ── DOSYALAR ──────────────────────────────────────────────
                SizedBox(height: 26 * s),
                _pad(s, _SectionRule(scale: s)),
                SizedBox(height: 14 * s),
                _pad(s, _SectionLabel(scale: s, text: 'DOSYALAR')),
                SizedBox(height: 6 * s),
                _pad(s, _FileList(scale: s)),

                // ── SIRADAKİ ADIM (siyah kart) ────────────────────────────
                SizedBox(height: 28 * s),
                _NextStepCard(
                  scale: s,
                  selected: _selectedDate,
                  onSelect: (i) => setState(() => _selectedDate = i),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _pad(double s, Widget child) => Padding(
    padding: EdgeInsets.symmetric(horizontal: _kPad * s),
    child: child,
  );
}

// ---------------------------------------------------------------------------
// Ortak küçük parçalar
// ---------------------------------------------------------------------------

/// Bölüm başlıklarının üstündeki kısa altın işaret.
class _SectionRule extends StatelessWidget {
  const _SectionRule({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) =>
      Container(height: 2 * scale, width: 28 * scale, color: _kGold);
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.scale, required this.text});
  final double scale;
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: _ui(
      size: 9.5 * scale,
      weight: FontWeight.w600,
      color: _kGold,
      spacing: 1.6,
    ),
  );
}

/// Sağa hizalı altın "… →" bağlantısı.
class _LinkText extends StatelessWidget {
  const _LinkText({required this.scale, required this.text});
  final double scale;
  final String text;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: _ui(
            size: 9.5 * s,
            weight: FontWeight.w600,
            color: _kGold,
            spacing: 1.4,
          ),
        ),
        SizedBox(width: 6 * s),
        Icon(Icons.arrow_forward_rounded, size: 12 * s, color: _kGold),
      ],
    );
  }
}

/// Mockup'taki kare, siyah-beyaz portre.
class _Portrait extends StatelessWidget {
  const _Portrait({
    required this.size,
    required this.gender,
    required this.seed,
  });

  final double size;
  final String gender;
  final String seed;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: const Color(0xFFDDD6CB),
      child: Icon(Icons.person, size: size * 0.5, color: _kTaupe),
    );
    final photo = ColorFiltered(
      colorFilter: _kMono,
      child: buildAvatarImage(
        placeholderAvatarFor(gender, seed),
        size: size,
        placeholder: placeholder,
      ),
    );
    return ClipRect(child: SizedBox(width: size, height: size, child: photo));
  }
}

// ---------------------------------------------------------------------------
// Üst blok — künye, başlık, sayaçlar
// ---------------------------------------------------------------------------

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({required this.scale, required this.topInset});
  final double scale;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      color: _kCream,
      padding: EdgeInsets.only(top: topInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Geri oku + dosya numarası
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s),
            child: SizedBox(
              height: 48 * s,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back<void>(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.only(right: 12 * s, top: 4 * s, bottom: 4 * s),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 22 * s,
                        color: _kInk,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'SH-2405-118',
                    style: _ui(
                      size: 10 * s,
                      weight: FontWeight.w500,
                      color: _kInk,
                      spacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s),
            child: Container(height: 1, color: _kLine),
          ),
          SizedBox(height: 22 * s),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROJE / 01',
                  style: _ui(
                    size: 9.5 * s,
                    weight: FontWeight.w600,
                    color: _kGold,
                    spacing: 1.6,
                  ),
                ),
                SizedBox(height: 10 * s),
                Text(
                  'Cafe Tanıtım\nFilmi',
                  style: _display(
                    size: 44 * s,
                    weight: FontWeight.w700,
                    color: _kInk,
                    height: 0.98,
                  ),
                ),
                SizedBox(height: 10 * s),
                Text(
                  'Tanıtım Filmi · İstanbul Avrupa',
                  style: _ui(size: 11.5 * s, color: _kTaupe, spacing: 0.2),
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * s),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s),
            child: Container(height: 1, color: _kLine),
          ),
          // Sayaçlar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _stat(s, '03/06', 'AŞAMA'),
                _divider(s),
                _stat(s, '12 GÜN', 'KALAN'),
                _divider(s),
                _stat(s, '48.000 ₺', 'BÜTÇE'),
              ],
            ),
          ),
          SizedBox(height: 22 * s),
        ],
      ),
    );
  }

  Widget _divider(double s) =>
      Container(width: 1, height: 44 * s, color: _kLine);

  Widget _stat(double s, String value, String label) => Expanded(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: _display(
                size: 25 * s,
                weight: FontWeight.w700,
                color: _kInk,
              ),
            ),
          ),
          SizedBox(height: 7 * s),
          Text(
            label,
            style: _ui(size: 8.5 * s, color: _kTaupe, spacing: 1.4),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Muhatap bloğu
// ---------------------------------------------------------------------------

class _ManagerBlock extends StatelessWidget {
  const _ManagerBlock({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      color: _kBlackout,
      padding: EdgeInsets.fromLTRB(24 * s, 18 * s, 24 * s, 22 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'TEK MUHATABIN',
                style: _ui(
                  size: 9.5 * s,
                  weight: FontWeight.w600,
                  color: _kGold,
                  spacing: 1.6,
                ),
              ),
              const Spacer(),
              Container(width: 7 * s, height: 7 * s, color: _kOnline),
              SizedBox(width: 7 * s),
              Text(
                'ŞU AN ONLINE',
                style: _ui(
                  size: 8.5 * s,
                  weight: FontWeight.w500,
                  color: Colors.white,
                  spacing: 1.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Portrait(size: 84 * s, gender: 'kadin', seed: 'selin-a-pm'),
              SizedBox(width: 16 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selin A.',
                      style: _display(
                        size: 28 * s,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 7 * s),
                    Text(
                      'Proje sorumlusu · 4 sa içinde döner',
                      style: _ui(
                        size: 10.5 * s,
                        color: _kOnDarkSoft,
                        spacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18 * s),
          Container(height: 1, color: _kNightLine),
          SizedBox(height: 14 * s),
          Text(
            'Süreç boyunca tek muhatabın benim.',
            style: _ui(
              size: 11.5 * s,
              color: _kOnDarkSoft,
              spacing: 0.2,
              italic: true,
            ),
          ),
          SizedBox(height: 16 * s),
          Row(
            children: [
              Expanded(
                flex: 53,
                child: GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.chatDetail,
                    arguments: {'name': 'Selin A.', 'mode': 'set'},
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 46 * s,
                    alignment: Alignment.center,
                    color: _kGold,
                    child: Text(
                      'MESAJ GÖNDER',
                      style: _ui(
                        size: 10.5 * s,
                        weight: FontWeight.w600,
                        color: _kBlackout,
                        spacing: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                flex: 43,
                child: GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 46 * s,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF3A3A3A)),
                    ),
                    child: Text(
                      'ARA',
                      style: _ui(
                        size: 10.5 * s,
                        weight: FontWeight.w600,
                        color: Colors.white,
                        spacing: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Süreç zaman çizelgesi
// ---------------------------------------------------------------------------

enum _StepState { done, current, upcoming }

class _Timeline extends StatelessWidget {
  const _Timeline({required this.scale, required this.horizontalPadding});
  final double scale;
  final double horizontalPadding;

  // (tarih, başlık, açıklama, durum)
  static const _steps = <(String, String, String, _StepState)>[
    (
      '24 MAY',
      'Brief',
      'Proje kapsamı, hedefler ve gereksinimler netleştirildi.',
      _StepState.done,
    ),
    (
      '25 MAY',
      'Planlama',
      'Ekip planı ve süreç takvimi oluşturuldu.',
      _StepState.done,
    ),
    (
      '28 MAY',
      'Ekip oluşumu',
      'Görüntü yönetmeni, editör ve ekip bir araya getiriliyor.',
      _StepState.current,
    ),
    (
      '02 HAZ',
      'Çekim',
      'Belirlenen lokasyonda çekim gerçekleştirilecek.',
      _StepState.upcoming,
    ),
    (
      '',
      'Kurgu',
      'Ham görüntüler kurgulanıp son haline getirilecek.',
      _StepState.upcoming,
    ),
    (
      '18 HAZ',
      'Teslim',
      'Tamamlanan proje teslim edilecek.',
      _StepState.upcoming,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final rows = <Widget>[];
    for (var i = 0; i < _steps.length; i++) {
      if (i > 0) {
        rows.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Container(height: 1, color: _kLine),
          ),
        );
      }
      rows.add(
        _TimelineRow(
          scale: s,
          horizontalPadding: horizontalPadding,
          step: _steps[i],
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.scale,
    required this.horizontalPadding,
    required this.step,
  });

  final double scale;
  final double horizontalPadding;
  final (String, String, String, _StepState) step;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final date = step.$1;
    final title = step.$2;
    final description = step.$3;
    final state = step.$4;

    final isCurrent = state == _StepState.current;
    final isUpcoming = state == _StepState.upcoming;

    final Color titleColor = isUpcoming ? _kMuted : _kInk;
    final Color dateColor = isUpcoming ? _kMuted : _kInk;
    final Color descColor = isUpcoming ? _kMuted : _kTaupe;
    final String status = switch (state) {
      _StepState.done => 'TAMAM',
      _StepState.current => 'ŞU AN',
      _StepState.upcoming => 'SIRADA',
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0x0DD9A84E) : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isCurrent ? _kGold : Colors.transparent,
            width: 2.5 * s,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding - (isCurrent ? 2.5 * s : 0),
        14 * s,
        horizontalPadding,
        14 * s,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58 * s,
            child: Text(
              date,
              style: _ui(
                size: 10 * s,
                weight: FontWeight.w600,
                color: dateColor,
                spacing: 0.8,
              ),
            ),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _ui(
                    size: 13 * s,
                    weight: FontWeight.w600,
                    color: titleColor,
                    spacing: 0.1,
                  ),
                ),
                SizedBox(height: 5 * s),
                Text(
                  description,
                  style: _ui(
                    size: 10.5 * s,
                    color: descColor,
                    spacing: 0.1,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * s),
          Padding(
            padding: EdgeInsets.only(top: 2 * s),
            child: Text(
              status,
              style: _ui(
                size: 8.5 * s,
                weight: FontWeight.w600,
                color: isCurrent ? _kGold : _kMuted,
                spacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ekip listesi
// ---------------------------------------------------------------------------

class _TeamList extends StatelessWidget {
  const _TeamList({required this.scale});
  final double scale;

  // (isim, rol, cinsiyet, onayladı mı)
  static const _members = <(String, String, String, bool)>[
    ('Selin D.', 'GÖRÜNTÜ YÖNETMENİ', 'kadin', true),
    ('Murat K.', 'KURGU & RENK', 'erkek', true),
    ('Kaan A.', 'IŞIK ŞEFİ', 'erkek', true),
    ('Deniz Y.', 'DRONE OPERATÖRÜ', 'erkek', false),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final rows = <Widget>[];
    for (var i = 0; i < _members.length; i++) {
      if (i > 0) rows.add(Container(height: 1, color: _kLine));
      final m = _members[i];
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12 * s),
          child: Row(
            children: [
              _Portrait(size: 46 * s, gender: m.$3, seed: 'set-team-${m.$1}'),
              SizedBox(width: 14 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.$1,
                      style: _ui(
                        size: 13 * s,
                        weight: FontWeight.w600,
                        color: _kInk,
                        spacing: 0.1,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      m.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _ui(
                        size: 8.5 * s,
                        weight: FontWeight.w600,
                        color: _kGold,
                        spacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10 * s),
              Text(
                m.$4 ? 'ONAYLADI' : 'BEKLİYOR',
                style: _ui(
                  size: 8.5 * s,
                  weight: FontWeight.w600,
                  color: m.$4 ? _kInk : _kGold,
                  spacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

// ---------------------------------------------------------------------------
// Son güncelleme
// ---------------------------------------------------------------------------

class _LastUpdate extends StatelessWidget {
  const _LastUpdate({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Portrait(size: 38 * s, gender: 'kadin', seed: 'selin-a-pm'),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Selin A.',
                    style: _ui(
                      size: 11.5 * s,
                      weight: FontWeight.w600,
                      color: _kInk,
                      spacing: 0.1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'BUGÜN · 14:32',
                    style: _ui(size: 8.5 * s, color: _kTaupe, spacing: 1),
                  ),
                ],
              ),
              SizedBox(height: 6 * s),
              Text(
                'Yönetmen ve görüntü yönetmeniyle toplantı gerçekleştirildi. '
                'Mekan keşfi 26 Mayıs\'ta yapılacak.',
                style: _ui(
                  size: 10.5 * s,
                  color: _kTaupe,
                  spacing: 0.1,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dosyalar
// ---------------------------------------------------------------------------

class _FileList extends StatelessWidget {
  const _FileList({required this.scale});
  final double scale;

  static const _files = <(String, String)>[
    ('Brief dokümanı', 'PDF · 240 KB'),
    ('Çekim takvimi', 'PDF · 180 KB'),
    ('Referans görseller', '12 DOSYA'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final rows = <Widget>[];
    for (var i = 0; i < _files.length; i++) {
      if (i > 0) rows.add(Container(height: 1, color: _kLine));
      final f = _files[i];
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14 * s),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  f.$1,
                  style: _ui(size: 12.5 * s, color: _kInk, spacing: 0.1),
                ),
              ),
              SizedBox(width: 10 * s),
              Text(
                f.$2,
                style: _ui(size: 9 * s, color: _kTaupe, spacing: 1),
              ),
            ],
          ),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

// ---------------------------------------------------------------------------
// Sıradaki adım — siyah kart
// ---------------------------------------------------------------------------

class _NextStepCard extends StatelessWidget {
  const _NextStepCard({
    required this.scale,
    required this.selected,
    required this.onSelect,
  });

  final double scale;
  final int selected;
  final ValueChanged<int> onSelect;

  static const _options = <(String, String)>[
    ('02 HAZ', 'SEÇENEK 1'),
    ('04 HAZ', 'SEÇENEK 2'),
    ('07 HAZ', 'SEÇENEK 3'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 8 * s),
      padding: EdgeInsets.fromLTRB(22 * s, 22 * s, 22 * s, 20 * s),
      color: _kBlackout,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIRADAKİ ADIM',
            style: _ui(
              size: 9.5 * s,
              weight: FontWeight.w600,
              color: _kGold,
              spacing: 1.6,
            ),
          ),
          SizedBox(height: 12 * s),
          Text(
            'Çekim tarihini onayla.',
            style: _display(
              size: 26 * s,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10 * s),
          Text(
            'Selin A. üç alternatif tarih önerdi.',
            style: _ui(size: 10.5 * s, color: _kOnDarkSoft, spacing: 0.2),
          ),
          SizedBox(height: 18 * s),
          Row(
            children: [
              for (var i = 0; i < _options.length; i++) ...[
                if (i > 0) SizedBox(width: 10 * s),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(i),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 58 * s,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected == i
                            ? const Color(0x1FD9A84E)
                            : Colors.transparent,
                        border: Border.all(
                          color: selected == i
                              ? _kGold
                              : const Color(0xFF3A3A3A),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _options[i].$1,
                            style: _ui(
                              size: 12.5 * s,
                              weight: FontWeight.w600,
                              color: Colors.white,
                              spacing: 0.4,
                            ),
                          ),
                          SizedBox(height: 5 * s),
                          Text(
                            _options[i].$2,
                            style: _ui(
                              size: 8 * s,
                              color: _kOnDarkSoft,
                              spacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 16 * s),
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 48 * s,
              alignment: Alignment.center,
              color: _kGold,
              child: Text(
                'TARİH SEÇ',
                style: _ui(
                  size: 10.5 * s,
                  weight: FontWeight.w600,
                  color: _kBlackout,
                  spacing: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
