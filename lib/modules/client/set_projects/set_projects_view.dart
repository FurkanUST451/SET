import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/utils/avatar_image.dart';
import '../../../routes/app_routes.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kDark = Color(0xFF23212B);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kCardBorder = Color(0x14000000);
const _kDivider = Color(0x12000000);
const _kTile = Color(0xFFF3EEE2);
const _kGreen = Color(0xFF5B8C6E);
const _kGoldSoft = Color(0xFFF1E4C6);

// ─── Koyu kahraman (hero) paleti ───────────────────────────────────────────────
const _kHeroBg = Color(0xFF14121A); // sayfa başı siyah zemin
const _kHeroCard = Color(0xFF211D29); // yönetici kartı (biraz daha açık)
const _kHeroBorder = Color(0x3DD9A84E); // ~%24 altın çerçeve
const _kHeroLine = Color(0x1AFFFFFF); // kart içi ince ayraç
const _kHeroCream = Color(0xFFF3ECDD); // koyu zeminde başlık/metin
const _kHeroMuted = Color(0xFF8B8694); // koyu zeminde ikincil metin
const _kOnline = Color(0xFF5FBF74); // çevrimiçi yeşili (koyu zemin)

// ─── Tipografi yardımcıları ───────────────────────────────────────────────────
TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
  bool italic = false,
}) =>
    AppFonts.display(
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
  double spacing = 0.5,
  double height = 1.4,
}) =>
    AppFonts.ui(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: spacing,
      height: height,
    );

class SetProjectsView extends StatelessWidget {
  const SetProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    final double s =
        (MediaQuery.sizeOf(context).width / 390).clamp(0.85, 1.15).toDouble();
    final double topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 110 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ══ KOYU HERO BÖLÜMÜ ═════════════════════════════════════════
                  _HeroSection(scale: s, topInset: topInset),

                  // ══ AÇIK İÇERİK BÖLÜMÜ ═══════════════════════════════════════
                  SizedBox(height: 24 * s),
                  _MetaCard(scale: s),

                  SizedBox(height: 24 * s),
                  _UpdateCard(scale: s),

                  SizedBox(height: 28 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * s),
                    child: _SectionHeader(scale: s, title: 'Ekip Durumu'),
                  ),
                  SizedBox(height: 14 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * s),
                    child: _TeamRow(scale: s),
                  ),

                  SizedBox(height: 28 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * s),
                    child: _SectionHeader(scale: s, title: 'Proje Dosyaları'),
                  ),
                  SizedBox(height: 14 * s),
                  Padding(
                    padding: EdgeInsets.only(left: 24 * s),
                    child: _FilesRow(scale: s),
                  ),

                  SizedBox(height: 24 * s),
                  _QuestionCard(scale: s),

                  SizedBox(height: 20 * s),
                  _NextStepCard(scale: s),
                ],
              ),
            ),

            // ══ SABİT ALT KATMAN: Düzenle + Yükle ═══════════════════════════════
            Positioned(
              left: 20 * s,
              right: 20 * s,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 14 * s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _EditPill(scale: s),
                      _UploadFab(scale: s),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Koyu hero bölümü ───────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.scale, required this.topInset});
  final double scale;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24 * s, topInset + 8 * s, 24 * s, 28 * s),
      decoration: BoxDecoration(
        color: _kHeroBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28 * s)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst bar
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back<void>(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(4 * s),
                  child: Icon(Icons.arrow_back_rounded,
                      size: 22 * s, color: _kHeroCream),
                ),
              ),
              Expanded(
                child: Center(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: 'SET ',
                          style: _ui(
                              size: 10 * s,
                              weight: FontWeight.w700,
                              color: _kHeroCream,
                              spacing: 2.5)),
                      TextSpan(
                          text: '· ',
                          style: _ui(
                              size: 10 * s,
                              weight: FontWeight.w700,
                              color: _kGold,
                              spacing: 2.5)),
                      TextSpan(
                          text: 'HALLETSİN',
                          style: _ui(
                              size: 10 * s,
                              weight: FontWeight.w700,
                              color: _kHeroCream,
                              spacing: 2.5)),
                    ]),
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.all(4 * s),
                    child: Icon(Icons.notifications_none_rounded,
                        size: 22 * s, color: _kHeroCream),
                  ),
                  Positioned(
                    top: 5 * s,
                    right: 5 * s,
                    child: Container(
                      width: 7 * s,
                      height: 7 * s,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: _kGold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 18 * s),

          // Dosya no
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(width: 28 * s, height: 1, color: _kHeroBorder),
              SizedBox(width: 10 * s),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: 'DOSYA NO ',
                      style: _ui(
                          size: 8 * s, color: _kHeroMuted, spacing: 1)),
                  TextSpan(
                      text: '· SH-2405-118',
                      style: _ui(
                          size: 8 * s,
                          weight: FontWeight.w700,
                          color: _kHeroCream,
                          spacing: 1)),
                ]),
              ),
            ],
          ),
          SizedBox(height: 18 * s),

          // Başlık
          Text('Cafe Tanıtım\nFilmi',
              style: _display(
                  size: 42 * s,
                  weight: FontWeight.w600,
                  color: _kHeroCream,
                  height: 1.0)),
          SizedBox(height: 16 * s),

          // Durum rozeti
          Row(
            children: [
              Container(width: 8 * s, height: 8 * s, color: _kGold),
              SizedBox(width: 8 * s),
              Text('EKİP KURULUYOR',
                  style: _ui(
                      size: 9 * s,
                      weight: FontWeight.w700,
                      color: _kGold,
                      spacing: 1.4)),
            ],
          ),
          SizedBox(height: 20 * s),

          // Yönetici kartı
          _ManagerCard(scale: s),
          SizedBox(height: 24 * s),

          // Süreç adımları
          _HeroStepper(scale: s),
        ],
      ),
    );
  }
}

// ─── Proje sorumlusu kartı (koyu) ───────────────────────────────────────────
class _ManagerCard extends StatelessWidget {
  const _ManagerCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: _kHeroCard,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: _kHeroBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 64 * s,
                      height: 64 * s,
                      child: buildAvatarImage(
                        placeholderAvatarFor('kadin', 'selin-a-pm'),
                        size: 64 * s,
                        placeholder: Container(
                          color: _kDark,
                          alignment: Alignment.center,
                          child: Text('SA',
                              style: AppFonts.display(
                                  fontSize: 20 * s,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 1 * s,
                    right: 1 * s,
                    child: Container(
                      width: 15 * s,
                      height: 15 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kOnline,
                        border: Border.all(color: _kHeroCard, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selin A.',
                        style: _display(
                            size: 26 * s,
                            weight: FontWeight.w600,
                            color: _kHeroCream)),
                    SizedBox(height: 3 * s),
                    Text('PROJE SORUMLUSU',
                        style: _ui(
                            size: 8 * s,
                            weight: FontWeight.w700,
                            color: _kGold,
                            spacing: 1.2)),
                    SizedBox(height: 7 * s),
                    Row(
                      children: [
                        Container(
                          width: 6 * s,
                          height: 6 * s,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: _kOnline),
                        ),
                        SizedBox(width: 6 * s),
                        Text('ŞU AN ONLINE',
                            style: _ui(
                                size: 8 * s, color: _kOnline, spacing: 0.8)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18 * s),
          Container(height: 1, color: _kHeroLine),
          SizedBox(height: 16 * s),
          Text('Süreç boyunca tek muhatabın.',
              style: _display(
                  size: 17 * s,
                  weight: FontWeight.w500,
                  color: _kHeroCream,
                  italic: true)),
          SizedBox(height: 16 * s),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.chatDetail,
                      arguments: {'name': 'Selin A.', 'mode': 'set'}),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 52 * s,
                    decoration: BoxDecoration(
                      color: _kGold,
                      borderRadius: BorderRadius.circular(12 * s),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 15 * s, color: _kBlack),
                        SizedBox(width: 9 * s),
                        Text('MESAJ GÖNDER',
                            style: _ui(
                                size: 10 * s,
                                weight: FontWeight.w700,
                                color: _kBlack,
                                spacing: 1)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12 * s),
              Container(
                width: 52 * s,
                height: 52 * s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12 * s),
                  border: Border.all(color: _kGold, width: 1.3),
                ),
                child: Icon(Icons.phone_outlined, size: 20 * s, color: _kGold),
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          Row(
            children: [
              Text('YANIT SÜRESİ · ORT. 12 DK',
                  style: _ui(size: 7.5 * s, color: _kHeroMuted, spacing: 0.5)),
              const Spacer(),
              Text('HAT · 7/24',
                  style: _ui(size: 7.5 * s, color: _kHeroMuted, spacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Süreç adımları (koyu zemin) ─────────────────────────────────────────────
enum _StepState { done, active, pending }

class _StepData {
  const _StepData(this.label, this.sub, this.icon, this.state);
  final String label;
  final String sub;
  final IconData icon;
  final _StepState state;
}

class _HeroStepper extends StatelessWidget {
  const _HeroStepper({required this.scale});
  final double scale;

  static const _steps = [
    _StepData('BRİEF', '23 MAY', Icons.check_rounded, _StepState.done),
    _StepData('PLANLAMA', '24 MAY', Icons.check_rounded, _StepState.done),
    _StepData('EKİP', 'ŞU AN', Icons.groups_rounded, _StepState.active),
    _StepData('ÇEKİM', '—', Icons.videocam_rounded, _StepState.pending),
    _StepData('KURGU', '—', Icons.content_cut_rounded, _StepState.pending),
    _StepData('TESLİM', '—', Icons.flag_rounded, _StepState.pending),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final double box = 36 * s;
    return LayoutBuilder(builder: (context, constraints) {
      final double cell = constraints.maxWidth / _steps.length;
      return Column(
        children: [
          SizedBox(
            height: box,
            child: Stack(
              children: [
                // bağlantı çizgisi
                Positioned(
                  left: cell / 2,
                  right: cell / 2,
                  top: box / 2,
                  child: Row(
                    children: List.generate(_steps.length - 1, (i) {
                      final reached = _steps[i + 1].state != _StepState.pending;
                      return Expanded(
                        child: Container(
                          height: 1,
                          color: reached ? _kGold : _kHeroLine,
                        ),
                      );
                    }),
                  ),
                ),
                Row(
                  children: _steps
                      .map((st) => Expanded(
                            child: Center(child: _stepMark(st, box, s)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * s),
          Row(
            children: _steps.map((st) {
              final active = st.state == _StepState.active;
              return Expanded(
                child: Column(
                  children: [
                    Text(st.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _ui(
                            size: 7.5 * s,
                            weight:
                                active ? FontWeight.w700 : FontWeight.w400,
                            color: st.state == _StepState.pending
                                ? _kHeroMuted
                                : _kHeroCream,
                            spacing: 0.4)),
                    SizedBox(height: 3 * s),
                    Text(st.sub,
                        textAlign: TextAlign.center,
                        style: _ui(
                            size: 7 * s,
                            color: active ? _kGold : _kHeroMuted,
                            spacing: 0.2)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _stepMark(_StepData st, double box, double s) {
    switch (st.state) {
      case _StepState.done:
        return Container(
          width: box,
          height: box,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kHeroBg,
            border: Border.all(color: _kGold, width: 1.4),
          ),
          child: Icon(Icons.check_rounded, size: 16 * s, color: _kGold),
        );
      case _StepState.active:
        return Container(
          width: box,
          height: box,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _kGold,
          ),
          child: Icon(st.icon, size: 17 * s, color: _kBlack),
        );
      case _StepState.pending:
        return Container(
          width: box,
          height: box,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kHeroBg,
            border: Border.all(color: _kHeroLine),
          ),
          child: Icon(st.icon, size: 16 * s, color: _kHeroMuted),
        );
    }
  }
}

// ─── Meta (bütçe / teslim / lokasyon) ───────────────────────────────────────
class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final cells = [
      (Icons.savings_outlined, 'BÜTÇE', '120.000 TL'),
      (Icons.event_outlined, 'TESLİM', '7 Gün'),
      (Icons.location_on_outlined, 'LOKASYON', 'Beşiktaş'),
    ];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 18 * s),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kCardBorder)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < cells.length; i++) ...[
            if (i > 0)
              Container(width: 1, height: 44 * s, color: _kDivider),
            Expanded(
              child: Column(
                children: [
                  Icon(cells[i].$1, size: 20 * s, color: _kInk),
                  SizedBox(height: 10 * s),
                  Text(cells[i].$2,
                      style: _ui(size: 7.5 * s, color: _kBlack, spacing: 1)),
                  SizedBox(height: 5 * s),
                  Text(cells[i].$3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _display(
                          size: 17 * s,
                          weight: FontWeight.w600,
                          color: _kInk)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Son güncelleme (açık kart) ─────────────────────────────────────────────
class _UpdateCard extends StatelessWidget {
  const _UpdateCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * s),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(color: _kCardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40 * s,
              height: 40 * s,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _kTile,
              ),
              child: Icon(Icons.description_rounded,
                  size: 19 * s, color: _kBlack),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Son Güncelleme',
                          style: _display(
                              size: 17 * s,
                              weight: FontWeight.w600,
                              color: _kInk)),
                      const Spacer(),
                      Text('2 saat önce',
                          style:
                              _ui(size: 7 * s, color: _kBlack, spacing: 0.3)),
                    ],
                  ),
                  SizedBox(height: 6 * s),
                  Text(
                      "Videographer shortlist tamamlandı. Bugün saat 18.00'e kadar ekip kesinleşecek.",
                      style: _ui(
                          size: 9 * s,
                          color: _kBlack,
                          spacing: 0.2,
                          height: 1.55)),
                ],
              ),
            ),
            SizedBox(width: 8 * s),
            Icon(Icons.chevron_right, size: 18 * s, color: _kGold),
          ],
        ),
      ),
    );
  }
}

// ─── Ekip durumu ────────────────────────────────────────────────────────────
class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.scale});
  final double scale;

  static const _members = [
    ('Videographer', 'Bulundu', true),
    ('Editor', 'Bulundu', true),
    ('Colorist', 'Aranıyor', false),
    ('Drone Op.', 'Aranıyor', false),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: _members.map((m) {
        final found = m.$3;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 10 * s),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6 * s),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56 * s,
                    child: Image.asset(
                      placeholderAvatarFor(null, m.$1),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 8 * s),
                Text(m.$1,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ui(
                        size: 7.5 * s,
                        weight: FontWeight.w700,
                        color: _kBlack,
                        spacing: 0.2)),
                SizedBox(height: 4 * s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 5 * s,
                        height: 5 * s,
                        color: found ? _kGreen : _kGold),
                    SizedBox(width: 4 * s),
                    Flexible(
                      child: Text(m.$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _ui(
                              size: 7 * s,
                              color: found ? _kGreen : _kGold,
                              spacing: 0.2)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Proje dosyaları ────────────────────────────────────────────────────────
class _FilesRow extends StatelessWidget {
  const _FilesRow({required this.scale});
  final double scale;

  static const _files = [
    (Icons.grid_view_rounded, 'Moodboard', '5.1 MB'),
    (Icons.picture_as_pdf_outlined, 'Brief', '2.4 MB'),
    (Icons.graphic_eq_rounded, 'Voice Note', '03:21'),
    (Icons.movie_outlined, 'Referanslar', '12 Dosya'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 128 * s,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 24 * s),
        itemCount: _files.length,
        separatorBuilder: (_, _) => SizedBox(width: 12 * s),
        itemBuilder: (_, i) {
          final f = _files[i];
          return SizedBox(
            width: 108 * s,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 108 * s,
                  height: 78 * s,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10 * s),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF3A342E), Color(0xFF211E1A)],
                    ),
                  ),
                  child: Icon(f.$1,
                      size: 26 * s,
                      color: Colors.white.withValues(alpha: 0.85)),
                ),
                SizedBox(height: 8 * s),
                Text(f.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ui(
                        size: 8 * s,
                        weight: FontWeight.w700,
                        color: _kBlack,
                        spacing: 0.2)),
                SizedBox(height: 2 * s),
                Text(f.$3,
                    style: _ui(size: 7 * s, color: _kBlack, spacing: 0.3)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── "Aklına takılan bir şey mi var?" kartı ─────────────────────────────────
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * s),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.chatDetail,
            arguments: {'name': 'Selin A.', 'mode': 'set'}),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14 * s),
          decoration: BoxDecoration(
            color: _kGold.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: _kGold.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 42 * s,
                      height: 42 * s,
                      child: buildAvatarImage(
                        placeholderAvatarFor('kadin', 'selin-a-pm'),
                        size: 42 * s,
                        placeholder: Container(
                          color: _kDark,
                          alignment: Alignment.center,
                          child: Text('SA',
                              style: AppFonts.display(
                                  fontSize: 14 * s,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 11 * s,
                      height: 11 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kGreen,
                        border: Border.all(color: _kCream, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aklına takılan bir şey mi var?',
                        style: _display(
                            size: 16 * s,
                            weight: FontWeight.w600,
                            color: _kInk)),
                    SizedBox(height: 3 * s),
                    Text('SELİN A. · PROJE SORUMLUSU',
                        style: _ui(
                            size: 7.5 * s,
                            weight: FontWeight.w700,
                            color: _kGold,
                            spacing: 0.6)),
                  ],
                ),
              ),
              SizedBox(width: 8 * s),
              Icon(Icons.chevron_right, size: 18 * s, color: _kGold),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Yaklaşan adım ──────────────────────────────────────────────────────────
class _NextStepCard extends StatelessWidget {
  const _NextStepCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * s),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 16 * s),
        decoration: BoxDecoration(
          color: _kGoldSoft,
          borderRadius: BorderRadius.circular(18 * s),
          border: Border.all(color: _kGold),
        ),
        child: Row(
          children: [
            Container(
              width: 44 * s,
              height: 44 * s,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _kGold,
              ),
              child: Icon(Icons.movie_filter_rounded,
                  size: 22 * s, color: _kBlack),
            ),
            SizedBox(width: 14 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('YAKLAŞAN ADIM',
                      style: _ui(
                          size: 7 * s,
                          color: _kBlack.withValues(alpha: 0.55),
                          spacing: 1.4)),
                  SizedBox(height: 4 * s),
                  Text('Çekim Planlaması',
                      style: _display(
                          size: 20 * s,
                          weight: FontWeight.w600,
                          color: _kInk)),
                  SizedBox(height: 2 * s),
                  Text('29 Mayıs 2024',
                      style: _ui(size: 8 * s, color: _kBlack, spacing: 0.3)),
                ],
              ),
            ),
            SizedBox(width: 10 * s),
            Container(
              width: 40 * s,
              height: 40 * s,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _kDark,
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  size: 18 * s, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sabit alt katman parçaları ─────────────────────────────────────────────
class _EditPill extends StatelessWidget {
  const _EditPill({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: _kInk,
        borderRadius: BorderRadius.circular(30 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tune_rounded, size: 14 * s, color: Colors.white),
          SizedBox(width: 8 * s),
          Text('Düzenle',
              style: _ui(
                  size: 9 * s,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  spacing: 0.5)),
        ],
      ),
    );
  }
}

class _UploadFab extends StatelessWidget {
  const _UploadFab({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 48 * s,
      height: 48 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: _kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(Icons.ios_share_rounded, size: 20 * s, color: _kInk),
    );
  }
}

// ─── Ortak parçalar ─────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.scale, required this.title});
  final double scale;
  final String title;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: [
        Text(title,
            style:
                _display(size: 22 * s, weight: FontWeight.w600, color: _kInk)),
        const Spacer(),
        Text('Tümünü Gör',
            style: _ui(size: 8 * s, color: _kBlack, spacing: 0.5)),
        SizedBox(width: 4 * s),
        Icon(Icons.chevron_right, size: 15 * s, color: _kGold),
      ],
    );
  }
}
