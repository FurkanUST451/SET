import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/avatar_image.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000);
const _kCardBorder = Color(0x14000000);
const _kOnline = Color(0xFF4CAF50);

double _scaleOf(BuildContext c) =>
    (MediaQuery.sizeOf(c).width / 390).clamp(0.85, 1.15).toDouble();

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

// ---------------------------------------------------------------------------
// Dummy project data (used only for the legacy project detail demo)
// ---------------------------------------------------------------------------

class _ProjectData {
  const _ProjectData({
    required this.fileNo,
    required this.projectIndex,
    required this.title,
    required this.statusLabel,
    required this.budget,
    required this.deliveryDays,
    required this.location,
    required this.updateAuthor,
    required this.updateTime,
    required this.updateText,
  });

  final String fileNo;
  final String projectIndex;
  final String title;
  final String statusLabel;
  final String budget;
  final String deliveryDays;
  final String location;
  final String updateAuthor;
  final String updateTime;
  final String updateText;
}

const _allProjects = [
  _ProjectData(
    fileNo: 'SH-2405-118',
    projectIndex: 'PROJE / 01',
    title: 'Cafe Tanıtım Filmi',
    statusLabel: 'EKİP KURULUYOR',
    budget: '120.000 TL',
    deliveryDays: '7 Gün',
    location: 'Beşiktaş',
    updateAuthor: 'Selin A.',
    updateTime: 'BUGÜN · 14:32',
    updateText:
        'Yönetmen ve görüntü yönetmeniyle toplantı gerçekleştirildi. Mekan keşfi 26 Mayıs\'ta.',
  ),
];

// ---------------------------------------------------------------------------
// Static data
// ---------------------------------------------------------------------------

const _steps = [
  ('01', 'BRİF', '24 MAY', Icons.check_rounded, true),
  ('02', 'PLANLAMA', '25 MAY', Icons.check_rounded, true),
  ('03', 'EKİP\nOLUŞUMU', '', Icons.groups_rounded, false),
  ('04', 'ÇEKİM', '--', Icons.videocam_outlined, false),
  ('05', 'KURGU', '--', Icons.build_outlined, false),
  ('06', 'TESLİM', '--', Icons.flag_outlined, false),
];
const _currentStep = 2;

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

class ProjectDetailView extends StatelessWidget {
  const ProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    final args = Get.arguments as Map<String, dynamic>?;
    final index = (args?['index'] as int?) ?? 0;
    final project = _allProjects[index.clamp(0, _allProjects.length - 1)];

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(scale: s),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24 * s, 14 * s, 24 * s, 32 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dosya no + proje index
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DOSYA NO · ${project.fileNo}',
                            style: _ui(size: 10 * s, color: _kTaupe, spacing: 1),
                          ),
                          Text(
                            project.projectIndex,
                            style: _ui(
                                size: 10 * s,
                                weight: FontWeight.w700,
                                color: _kGold,
                                spacing: 1),
                          ),
                        ],
                      ),
                      SizedBox(height: 10 * s),
                      Text(
                        project.title,
                        style: _display(
                            size: 32 * s, weight: FontWeight.w600, color: _kInk),
                      ),
                      SizedBox(height: 14 * s),
                      Row(
                        children: [
                          Container(
                            width: 8 * s,
                            height: 8 * s,
                            decoration: const BoxDecoration(color: _kGold),
                          ),
                          SizedBox(width: 8 * s),
                          Text(
                            project.statusLabel,
                            style: _ui(
                                size: 10 * s,
                                weight: FontWeight.w700,
                                color: _kBlack,
                                spacing: 1.4),
                          ),
                        ],
                      ),
                      SizedBox(height: 20 * s),

                      // ── Proje Sorumlusu kartı ─────────────────────────────
                      _CornerFramed(
                        scale: s,
                        child: _ManagerCard(scale: s),
                      ),
                      SizedBox(height: 24 * s),

                      // ── Süreç adımları ────────────────────────────────────
                      _StepProgress(scale: s),
                      SizedBox(height: 24 * s),

                      // ── Bütçe / Teslim / Lokasyon ─────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              scale: s,
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'BÜTÇE',
                              value: project.budget,
                            ),
                          ),
                          Container(width: 1, height: 40 * s, color: _kCardBorder),
                          Expanded(
                            child: _StatItem(
                              scale: s,
                              icon: Icons.calendar_today_outlined,
                              label: 'TESLİM',
                              value: project.deliveryDays,
                            ),
                          ),
                          Container(width: 1, height: 40 * s, color: _kCardBorder),
                          Expanded(
                            child: _StatItem(
                              scale: s,
                              icon: Icons.location_on_outlined,
                              label: 'LOKASYON',
                              value: project.location,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24 * s),
                      Container(height: 1, color: _kCardBorder),
                      SizedBox(height: 18 * s),

                      // ── Güncelleme ─────────────────────────────────────────
                      Text(
                        'GÜNCELLEME',
                        style: _ui(size: 10 * s, color: _kBlack, spacing: 1.5),
                      ),
                      SizedBox(height: 14 * s),
                      Row(
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
                              placeholderAvatarFor('erkek', 'set-update-selin'),
                              size: 36 * s,
                              placeholder: Container(
                                width: 36 * s,
                                height: 36 * s,
                                color: const Color(0xFFEADCBB),
                                child: Icon(Icons.person,
                                    size: 20 * s, color: _kTaupe),
                              ),
                            ),
                          ),
                          SizedBox(width: 12 * s),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      project.updateAuthor,
                                      style: _ui(
                                          size: 13 * s,
                                          weight: FontWeight.w700,
                                          color: _kInk,
                                          spacing: 0.2),
                                    ),
                                    Text(
                                      project.updateTime,
                                      style: _ui(
                                          size: 13 * s,
                                          color: _kTaupe,
                                          spacing: 0.3),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6 * s),
                                Text(
                                  project.updateText,
                                  style: _ui(
                                      size: 15 * s,
                                      color: _kBlack,
                                      spacing: 0.2,
                                      height: 1.55),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Alt sabit bölüm ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(24 * s, 8 * s, 24 * s, 8 * s),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 50 * s,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _kInk, width: 1.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 15 * s, color: _kInk),
                              SizedBox(width: 8 * s),
                              Text(
                                'DÜZENLE',
                                style: _ui(
                                    size: 9 * s,
                                    weight: FontWeight.w700,
                                    color: _kInk,
                                    spacing: 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 50 * s,
                        height: 50 * s,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: _kInk, width: 1.2),
                        ),
                        child: Icon(Icons.ios_share_outlined,
                            size: 17 * s, color: _kInk),
                      ),
                    ),
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

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 48 * s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Get.back<void>(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(12 * s),
                child:
                    Icon(Icons.arrow_back_rounded, size: 22 * s, color: _kInk),
              ),
            ),
          ),
          Text(
            'SET · HALLETSİN',
            style: _ui(
                size: 10 * s, weight: FontWeight.w700, color: _kInk, spacing: 2),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 8 * s),
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 36 * s,
                  height: 36 * s,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _kCardBorder),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded,
                          size: 18 * s, color: _kInk),
                      Positioned(
                        top: 8 * s,
                        right: 9 * s,
                        child: Container(
                          width: 6 * s,
                          height: 6 * s,
                          decoration: const BoxDecoration(color: _kGold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
                        child: Icon(Icons.person,
                            size: 32 * s, color: _kTaupe),
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
                          size: 24 * s,
                          weight: FontWeight.w600,
                          color: _kInk),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      'PROJE SORUMLUSU',
                      style: _ui(
                          size: 10 * s,
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
                          style: _ui(size: 10 * s, color: _kTaupe, spacing: 0.8),
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
                  onTap: () => Get.toNamed(
                    '/client/chat-detail',
                    arguments: {'name': 'Selin A.'},
                  ),
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
          SizedBox(height: 14 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YANIT SÜRESİ · ORT. 12 DK',
                style: _ui(size: 10 * s, color: _kTaupe, spacing: 0.6),
              ),
              Text(
                'HAT · 7/24',
                style: _ui(size: 10 * s, color: _kTaupe, spacing: 0.6),
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
                child: _DottedLine(color: i - 1 < _currentStep
                    ? _kGold.withValues(alpha: 0.5)
                    : _kCardBorder),
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

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.scale,
    required this.index,
    required this.size,
  });
  final double scale;
  final int index;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final step = _steps[index];
    final label = step.$2;
    final dateLabel = step.$3;
    final icon = step.$4;
    final isDone = step.$5;
    final isCurrent = index == _currentStep;

    Widget circle;
    if (isDone) {
      circle = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF0E8DC),
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(Icons.check_rounded, size: 16 * s, color: _kInk),
      );
    } else if (isCurrent) {
      circle = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _kGold.withValues(alpha: 0.12),
          border: Border.all(color: _kGold, width: 1.4),
        ),
        child: Icon(icon, size: 16 * s, color: _kGold),
      );
    } else {
      circle = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _kCardBorder),
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
              size: 10 * s,
              weight: isCurrent ? FontWeight.w700 : FontWeight.w600,
              color: isCurrent ? _kGold : _kBlack,
              spacing: 0.4,
              height: 1.2,
            ),
          ),
          if (dateLabel.isNotEmpty) ...[
            SizedBox(height: 2 * s),
            Text(
              dateLabel,
              textAlign: TextAlign.center,
              style: _ui(
                size: 6.5 * s,
                color: isCurrent ? _kGold : _kTaupe,
                spacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat item
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
          style: _display(size: 22 * s, weight: FontWeight.w600, color: _kInk),
        ),
        SizedBox(height: 4 * s),
        Text(
          label,
          style: _ui(size: 10 * s, color: _kTaupe, spacing: 1),
        ),
      ],
    );
  }
}
