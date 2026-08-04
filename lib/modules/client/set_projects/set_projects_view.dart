import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/utils/avatar_image.dart';
import '../../../routes/app_routes.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kCardBorder = Color(0x14000000);
const _kOnline = Color(0xFF4CAF50);

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

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24 * s, 0, 24 * s, 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Geri oku — kendi satırında.
                    GestureDetector(
                      onTap: () => Get.back<void>(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4 * s),
                        child: Icon(Icons.arrow_back_rounded,
                            size: 22 * s, color: _kInk),
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    // Proje indeksi + dosya no — okun hemen altında, sayfa
                    // bu çizgiyle başlar.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'PROJE / 01',
                          style: _ui(
                              size: 8 * s,
                              weight: FontWeight.w700,
                              color: _kGold,
                              spacing: 1.4),
                        ),
                        SizedBox(width: 10 * s),
                        Expanded(
                            child: Container(height: 1, color: _kCardBorder)),
                        SizedBox(width: 10 * s),
                        Text(
                          'DOSYA NO · SH-2405-118',
                          style: _ui(size: 8 * s, color: _kTaupe, spacing: 1),
                        ),
                      ],
                    ),
                    SizedBox(height: 16 * s),

                    // Başlık
                    Text(
                      'Cafe Tanıtım\nFilmi',
                      style: _display(
                          size: 40 * s, weight: FontWeight.w600, color: _kInk),
                    ),
                    SizedBox(height: 16 * s),

                    // Durum rozeti
                    Row(
                      children: [
                        Container(
                          width: 8 * s,
                          height: 8 * s,
                          decoration: const BoxDecoration(color: _kGold),
                        ),
                        SizedBox(width: 8 * s),
                        Text(
                          'EKİP KURULUYOR',
                          style: _ui(
                              size: 9 * s,
                              weight: FontWeight.w700,
                              color: _kBlack,
                              spacing: 1.4),
                        ),
                      ],
                    ),
                    SizedBox(height: 20 * s),

                    // Proje sorumlusu kartı (köşe işaretli çerçeve)
                    _CornerFramed(scale: s, child: _ManagerCard(scale: s)),
                    SizedBox(height: 24 * s),

                    // Süreç adımları
                    _StepProgress(scale: s),
                    SizedBox(height: 24 * s),

                    // Bütçe / Teslim / Lokasyon
                    Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            scale: s,
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'BÜTÇE',
                            value: '120.000 TL',
                          ),
                        ),
                        Container(
                            width: 1, height: 40 * s, color: _kCardBorder),
                        Expanded(
                          child: _StatItem(
                            scale: s,
                            icon: Icons.calendar_today_outlined,
                            label: 'TESLİM',
                            value: '7 Gün',
                          ),
                        ),
                        Container(
                            width: 1, height: 40 * s, color: _kCardBorder),
                        Expanded(
                          child: _StatItem(
                            scale: s,
                            icon: Icons.location_on_outlined,
                            label: 'LOKASYON',
                            value: 'Beşiktaş',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24 * s),
                    Container(height: 1, color: _kCardBorder),
                    SizedBox(height: 18 * s),

                    // Güncelleme
                    Text(
                      'GÜNCELLEME',
                      style: _ui(size: 8 * s, color: _kBlack, spacing: 1.5),
                    ),
                    SizedBox(height: 14 * s),
                    _UpdateItem(scale: s),
                    SizedBox(height: 28 * s),

                    // Ekip Durumu
                    _SectionHeader(scale: s, title: 'Ekip Durumu'),
                    SizedBox(height: 14 * s),
                    _TeamRow(scale: s),
                    SizedBox(height: 28 * s),

                    // Proje Dosyaları
                    _SectionHeader(scale: s, title: 'Proje Dosyaları'),
                    SizedBox(height: 14 * s),
                    SizedBox(
                      height: 108 * s,
                      child: _FilesRow(scale: s),
                    ),
                    SizedBox(height: 24 * s),

                    // Aklına takılan bir şey mi var?
                    _QuestionCard(scale: s),
                    SizedBox(height: 16 * s),

                    // Yaklaşan adım
                    _NextStepCard(scale: s),
                  ],
                ),
              ),
            ),
          ),
      );
  }
}

// ---------------------------------------------------------------------------
// Köşe işaretli çerçeve (kart etrafında dekoratif L köşeler)
// ---------------------------------------------------------------------------

class _CornerFramed extends StatelessWidget {
  const _CornerFramed({required this.scale, required this.child});
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Stack(
      children: [
        child,
        Positioned(top: 0, left: 0, child: _corner(s, 0)),
        Positioned(top: 0, right: 0, child: _corner(s, 1)),
        Positioned(bottom: 0, left: 0, child: _corner(s, 2)),
        Positioned(bottom: 0, right: 0, child: _corner(s, 3)),
      ],
    );
  }

  // quadrant: 0 = top-left, 1 = top-right, 2 = bottom-left, 3 = bottom-right
  Widget _corner(double s, int quadrant) {
    final len = 12 * s;
    final isLeft = quadrant == 0 || quadrant == 2;
    final isTop = quadrant == 0 || quadrant == 1;
    return SizedBox(
      width: len,
      height: len,
      child: Stack(
        children: [
          Positioned(
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            child: Container(width: len, height: 1.4, color: _kGold),
          ),
          Positioned(
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            child: Container(width: 1.4, height: len, color: _kGold),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Proje sorumlusu kartı
// ---------------------------------------------------------------------------

class _ManagerCard extends StatelessWidget {
  const _ManagerCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kCardBorder),
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
                    child: buildAvatarImage(
                      placeholderAvatarFor('kadin', 'selin-a-pm'),
                      size: 60 * s,
                      placeholder: Container(
                        width: 60 * s,
                        height: 60 * s,
                        color: const Color(0xFFE8D5C0),
                        child:
                            Icon(Icons.person, size: 32 * s, color: _kTaupe),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 1 * s,
                    right: 1 * s,
                    child: Container(
                      width: 12 * s,
                      height: 12 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kOnline,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 14 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selin A.',
                      style: _display(
                          size: 22 * s, weight: FontWeight.w600, color: _kInk),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      'PROJE SORUMLUSU',
                      style: _ui(
                          size: 8 * s,
                          weight: FontWeight.w700,
                          color: _kGold,
                          spacing: 1),
                    ),
                    SizedBox(height: 4 * s),
                    Row(
                      children: [
                        Container(
                          width: 6 * s,
                          height: 6 * s,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: _kOnline),
                        ),
                        SizedBox(width: 5 * s),
                        Text(
                          'ŞU AN ONLINE',
                          style: _ui(size: 8 * s, color: _kTaupe, spacing: 0.8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18 * s),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: _kCardBorder)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * s),
                child: Container(
                  width: 5 * s,
                  height: 5 * s,
                  decoration: const BoxDecoration(color: _kGold),
                ),
              ),
              Expanded(child: Container(height: 1, color: _kCardBorder)),
            ],
          ),
          SizedBox(height: 16 * s),
          Text(
            'Süreç boyunca tek muhatabın.',
            style: _display(
                size: 15 * s,
                weight: FontWeight.w500,
                color: _kInk,
                italic: true),
          ),
          SizedBox(height: 16 * s),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.chatDetail,
                      arguments: {'name': 'Selin A.', 'mode': 'set'}),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48 * s,
                    color: _kGold,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 15 * s, color: Colors.white),
                        SizedBox(width: 8 * s),
                        Text(
                          'MESAJ GÖNDER',
                          style: _ui(
                              size: 9 * s,
                              weight: FontWeight.w700,
                              color: Colors.white,
                              spacing: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10 * s),
              GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 48 * s,
                  height: 48 * s,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _kInk, width: 1.2),
                  ),
                  child: Icon(Icons.call_outlined, size: 18 * s, color: _kInk),
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
// Süreç adımları
// ---------------------------------------------------------------------------

const _steps = [
  ('BRİF', '24 MAY', Icons.check_rounded, true),
  ('PLANLAMA', '25 MAY', Icons.check_rounded, true),
  ('EKİP\nOLUŞUMU', 'ŞU AN', Icons.groups_rounded, false),
  ('ÇEKİM', '--', Icons.videocam_rounded, false),
  ('KURGU', '--', Icons.content_cut_rounded, false),
  ('TESLİM', '--', Icons.flag_rounded, false),
];
const _currentStep = 2;

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final circleSize = 40.0 * s;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _steps.length; i++) ...[
          if (i != 0)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: circleSize / 2 - 0.5),
                child: _DottedLine(
                  color: i - 1 < _currentStep
                      ? _kGold.withValues(alpha: 0.5)
                      : _kCardBorder,
                ),
              ),
            ),
          _StepCircle(scale: s, index: i, size: circleSize),
        ],
      ],
    );
  }
}

class _DottedLine extends StatelessWidget {
  const _DottedLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count < 1 ? 1 : count,
            (_) => Container(width: dashWidth, height: 1.4, color: color),
          ),
        );
      },
    );
  }
}

class _StepCircle extends StatefulWidget {
  const _StepCircle({
    required this.scale,
    required this.index,
    required this.size,
  });
  final double scale;
  final int index;
  final double size;

  @override
  State<_StepCircle> createState() => _StepCircleState();
}

class _StepCircleState extends State<_StepCircle>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  bool get _isCurrent => widget.index == _currentStep;

  @override
  void initState() {
    super.initState();
    if (_isCurrent) {
      _pulse = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final size = widget.size;
    final step = _steps[widget.index];
    final label = step.$1;
    final icon = step.$3;
    final isDone = step.$4;
    final isCurrent = _isCurrent;

    Widget circle;
    if (isDone) {
      // Tamamlanmış adım — dolgun, düz renkli daire.
      circle = Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: _kGold,
        ),
        child: Icon(Icons.check_rounded, size: 18 * s, color: Colors.white),
      );
    } else if (isCurrent) {
      // Mevcut adım — dolgun daire + sinyal gibi yanıp sönen çerçeve.
      circle = AnimatedBuilder(
        animation: _pulse!,
        builder: (context, child) {
          final t = _pulse!.value;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kGold,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15 + 0.75 * t),
                width: 2.5 * s,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withValues(alpha: 0.45 * t),
                  blurRadius: 10 * s,
                  spreadRadius: 2 * s,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Icon(icon, size: 18 * s, color: Colors.white),
      );
    } else {
      circle = Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
        ),
        child: Icon(icon, size: 16 * s, color: _kMuted),
      );
    }

    return SizedBox(
      width: 52 * s,
      child: Column(
        children: [
          circle,
          SizedBox(height: 6 * s),
          Text(
            label,
            textAlign: TextAlign.center,
            style: _ui(
              size: 7 * s,
              weight: isCurrent ? FontWeight.w700 : FontWeight.w600,
              color: isCurrent ? _kGold : _kBlack,
              spacing: 0.4,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat item (bütçe / teslim / lokasyon)
// ---------------------------------------------------------------------------

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.scale,
    required this.icon,
    required this.label,
    required this.value,
  });
  final double scale;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      children: [
        Icon(icon, size: 18 * s, color: _kGold),
        SizedBox(height: 8 * s),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _display(size: 16 * s, weight: FontWeight.w600, color: _kInk),
        ),
        SizedBox(height: 4 * s),
        Text(
          label,
          style: _ui(size: 7.5 * s, color: _kTaupe, spacing: 1),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Son güncelleme
// ---------------------------------------------------------------------------

class _UpdateItem extends StatelessWidget {
  const _UpdateItem({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6 * s,
          height: 6 * s,
          margin: EdgeInsets.only(top: 6 * s),
          decoration: const BoxDecoration(color: _kGold),
        ),
        SizedBox(width: 12 * s),
        ClipOval(
          child: buildAvatarImage(
            placeholderAvatarFor('kadin', 'set-update-selin'),
            size: 36 * s,
            placeholder: Container(
              width: 36 * s,
              height: 36 * s,
              color: const Color(0xFFEADCBB),
              child: Icon(Icons.person, size: 20 * s, color: _kTaupe),
            ),
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selin A.',
                    style: _ui(
                        size: 10 * s,
                        weight: FontWeight.w700,
                        color: _kInk,
                        spacing: 0.2),
                  ),
                  Text(
                    'BUGÜN · 14:32',
                    style: _ui(size: 8 * s, color: _kTaupe, spacing: 0.3),
                  ),
                ],
              ),
              SizedBox(height: 6 * s),
              Text(
                'Yönetmen ve görüntü yönetmeniyle toplantı gerçekleştirildi. Mekan keşfi 26 Mayıs\'ta.',
                style: _ui(
                    size: 9.5 * s, color: _kBlack, spacing: 0.2, height: 1.55),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ortak bölüm başlığı
// ---------------------------------------------------------------------------

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
                _display(size: 20 * s, weight: FontWeight.w600, color: _kInk)),
        const Spacer(),
        Text('TÜMÜNÜ GÖR',
            style: _ui(
                size: 8 * s,
                weight: FontWeight.w700,
                color: _kGold,
                spacing: 1)),
        SizedBox(width: 4 * s),
        Icon(Icons.arrow_forward_rounded, size: 12 * s, color: _kGold),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ekip durumu
// ---------------------------------------------------------------------------

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
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipOval(
                      child: buildAvatarImage(
                        placeholderAvatarFor(null, m.$1),
                        size: 52 * s,
                        placeholder: Container(
                          width: 52 * s,
                          height: 52 * s,
                          color: const Color(0xFFE8D5C0),
                          child: Icon(Icons.person,
                              size: 26 * s, color: _kTaupe),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14 * s,
                        height: 14 * s,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: found ? _kOnline : _kGold,
                          border: Border.all(color: Colors.white, width: 1.4),
                        ),
                        child: Icon(
                          found ? Icons.check_rounded : Icons.search_rounded,
                          size: 8 * s,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
                SizedBox(height: 3 * s),
                Text(m.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ui(
                        size: 7 * s,
                        color: found ? _kOnline : _kGold,
                        spacing: 0.2)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Proje dosyaları
// ---------------------------------------------------------------------------

class _FilesRow extends StatelessWidget {
  const _FilesRow({required this.scale});
  final double scale;

  static const _files = [
    (Icons.grid_view_outlined, 'Moodboard', '5.1 MB'),
    (Icons.picture_as_pdf_outlined, 'Brief', '2.4 MB'),
    (Icons.mic_none_rounded, 'Voice Note', '03:21'),
    (Icons.folder_outlined, 'Referanslar', '12 Dosya'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _files.length,
      separatorBuilder: (_, _) => SizedBox(width: 12 * s),
      itemBuilder: (_, i) {
        final f = _files[i];
        return SizedBox(
          width: 88 * s,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 88 * s,
                height: 68 * s,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _kCardBorder),
                ),
                child: Icon(f.$1, size: 24 * s, color: _kGold),
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
                  style: _ui(size: 7 * s, color: _kTaupe, spacing: 0.3)),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Aklına takılan bir şey mi var?
// ---------------------------------------------------------------------------

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.chatDetail,
          arguments: {'name': 'Selin A.', 'mode': 'set'}),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _kGold),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipOval(
                  child: buildAvatarImage(
                    placeholderAvatarFor('kadin', 'selin-a-pm'),
                    size: 42 * s,
                    placeholder: Container(
                      width: 42 * s,
                      height: 42 * s,
                      color: const Color(0xFFE8D5C0),
                      child:
                          Icon(Icons.person, size: 22 * s, color: _kTaupe),
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
                      color: _kOnline,
                      border: Border.all(color: Colors.white, width: 1.5),
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
                          size: 15 * s,
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
    );
  }
}

// ---------------------------------------------------------------------------
// Yaklaşan adım
// ---------------------------------------------------------------------------

class _NextStepCard extends StatelessWidget {
  const _NextStepCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
      decoration: BoxDecoration(
        color: _kInk,
      ),
      child: Row(
        children: [
          Container(
            width: 40 * s,
            height: 40 * s,
            color: _kGold,
            child: Icon(Icons.movie_creation_outlined,
                size: 19 * s, color: Colors.white),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YAKLAŞAN ADIM',
                    style: _ui(
                        size: 7 * s,
                        color: Colors.white.withValues(alpha: 0.5),
                        spacing: 1.4)),
                SizedBox(height: 3 * s),
                Text('Çekim Planlaması',
                    style: _display(
                        size: 17 * s,
                        weight: FontWeight.w600,
                        color: Colors.white)),
                SizedBox(height: 2 * s),
                Text('29 Mayıs 2026',
                    style: _ui(
                        size: 8 * s,
                        color: Colors.white.withValues(alpha: 0.5),
                        spacing: 0.3)),
              ],
            ),
          ),
          SizedBox(width: 10 * s),
          Container(
            width: 36 * s,
            height: 36 * s,
            color: _kGold,
            child: Icon(Icons.arrow_forward_rounded,
                size: 17 * s, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
