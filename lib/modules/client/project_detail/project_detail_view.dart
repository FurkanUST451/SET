import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// Dummy project data (used only for the legacy project detail demo)
// ---------------------------------------------------------------------------

enum _ProjectStatus { inProgress }

class _ProjectData {
  const _ProjectData({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.progress,
    required this.workers,
    required this.budget,
    required this.daysLeft,
    required this.gradientColors,
    required this.stage,
    required this.overview,
    required this.deadline,
    required this.startDate,
    required this.deliverables,
  });

  final String title;
  final String subtitle;
  final _ProjectStatus status;
  final double progress;
  final int workers;
  final String budget;
  final int daysLeft;
  final List<Color> gradientColors;
  final int stage;
  final String overview;
  final String deadline;
  final String startDate;
  final String deliverables;
}

const _allProjects = [
  _ProjectData(
    title: 'Cafe Tanıtım Filmi',
    subtitle: 'SET Halletsin · Ekip kuruluyor',
    status: _ProjectStatus.inProgress,
    progress: 0.42,
    workers: 3,
    budget: r'₺42.000',
    daysLeft: 7,
    gradientColors: [Color(0xFF2A1A08), Color(0xFF1A0D04)],
    stage: 0,
    overview:
        'Butik kafe için ürün ve atmosfer odaklı tanıtım filmi. SET ekibi çekim ve kurgu sürecini yönetiyor.',
    deadline: 'Haz 14',
    startDate: 'May 28',
    deliverables: '3 versiyon',
  ),
];

// ---------------------------------------------------------------------------
// Static data
// ---------------------------------------------------------------------------

const _steps = [
  (Icons.description_outlined, 'Brief', '23 May'),
  (Icons.event_note_outlined, 'Planlama', '24 May'),
  (Icons.people_outline_rounded, 'Ekip Kuruluyor', 'Şu An'),
  (Icons.videocam_outlined, 'Çekim', '–'),
  (Icons.content_cut_rounded, 'Kurgu', '–'),
  (Icons.flag_outlined, 'Teslim', '–'),
];

const _teamStatus = [
  ('Videographer', true),
  ('Editor', true),
  ('Colorist', false),
  ('Drone Operator', false),
];

const _files = [
  (Icons.picture_as_pdf_outlined, 'Moodboard.pdf', '5.1 MB', Color(0xFFB8860B)),
  (Icons.picture_as_pdf_outlined, 'Brief.pdf', '2.4 MB', Color(0xFFD4A843)),
  (Icons.mic_none_rounded, 'Voice Note', '03:21 · MP3', Color(0xFF8D6E63)),
  (Icons.folder_outlined, 'Referanslar', '12 Dosya', Color(0xFF6D4C41)),
];

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

class ProjectDetailView extends StatelessWidget {
  const ProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final index = (args?['index'] as int?) ?? 0;
    final project = _allProjects[index.clamp(0, _allProjects.length - 1)];
    const currentStep = 2;

    return Scaffold(
      backgroundColor: const Color(0xFFFEFDFB),
      body: Stack(
        children: [
          // ── Hero background image ──────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: 300,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(AppAssets.choosePageBg, fit: BoxFit.cover, cacheWidth: 1080),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xFFF5EBD8)],
                      stops: [0.35, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable content ────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // Top bar
                SliverToBoxAdapter(child: _TopBar()),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SET Halletsin
                        Text(
                          'SET Halletsin',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFFB8860B),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Title
                        Text(
                          project.title,
                          style: AppTextStyles.displayXL.copyWith(
                            color: Colors.black87,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Status row
                        Row(
                          children: [
                            Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE8B84B),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE8B84B)
                                        .withValues(alpha: 0.45),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ekip Kuruluyor',
                              style: AppTextStyles.heading3.copyWith(
                                color: const Color(0xFFB8860B),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Projeniz SET ekibi tarafından yönetiliyor.',
                          style: AppTextStyles.body2
                              .copyWith(color: Colors.black45),
                        ),
                        const SizedBox(height: 20),

                        // ── Steps card ───────────────────────────────────────
                        _Card(
                          child: _StepProgress(currentStep: currentStep),
                        ),
                        const SizedBox(height: 12),

                        // ── Son Güncelleme card ──────────────────────────────
                        _Card(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0E8DC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.insert_drive_file_outlined,
                                  color: Color(0xFF8D6E63),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Son Güncelleme',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.black45,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Videographer shortlist tamamlandı. Bugün saat 18:00\'e kadar ekip kesinleşecek.',
                                      style: AppTextStyles.body2.copyWith(
                                        color: Colors.black87,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '2 saat önce',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.black38,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 10,
                                    color: Colors.black38,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Project Manager card ─────────────────────────────
                        _Card(
                          child: Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFE8D5C0),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Color(0xFF8D6E63),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF4CAF50),
                                        border: Border.all(
                                            color: Colors.white, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selin A.',
                                      style: AppTextStyles.heading3.copyWith(
                                        color: Colors.black87,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'SET Project Manager',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.black45,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Online',
                                      style: AppTextStyles.caption.copyWith(
                                        color: const Color(0xFF4CAF50),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.toNamed(
                                  '/client/chat-detail',
                                  arguments: {'name': 'Selin A.'},
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Mesaj Gönder',
                                        style: AppTextStyles.button.copyWith(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Ekip Durumu card ─────────────────────────────────
                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ekip Durumu',
                                    style: AppTextStyles.heading3.copyWith(
                                      color: Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    'Tümünü Gör  →',
                                    style: AppTextStyles.caption.copyWith(
                                      color: const Color(0xFFB8860B),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _teamStatus
                                      .map((t) => Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16),
                                            child: _TeamStatusItem(
                                              role: t.$1,
                                              found: t.$2,
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Stats row card ────────────────────────────────────
                        _Card(
                          child: Row(
                            children: [
                              _StatItem(
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'Bütçe',
                                value: '120.000 TL',
                              ),
                              _Divider(),
                              _StatItem(
                                icon: Icons.calendar_today_outlined,
                                label: 'Teslim',
                                value: '7 Gün',
                              ),
                              _Divider(),
                              _StatItem(
                                icon: Icons.location_on_outlined,
                                label: 'Lokasyon',
                                value: 'Beşiktaş',
                              ),
                              _Divider(),
                              _StatItem(
                                icon: Icons.shield_outlined,
                                label: 'Escrow',
                                value: 'Aktif',
                                valueColor: const Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Proje Dosyaları card ──────────────────────────────
                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Proje Dosyaları',
                                    style: AppTextStyles.heading3.copyWith(
                                      color: Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    'Tümünü Gör  →',
                                    style: AppTextStyles.caption.copyWith(
                                      color: const Color(0xFFB8860B),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _files
                                      .map((f) => Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: _FileThumb(
                                              icon: f.$1,
                                              name: f.$2,
                                              meta: f.$3,
                                              color: f.$4,
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom sticky card ────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1200),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.movie_creation_outlined,
                          color: Color(0xFFE8B84B),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yaklaşan Adım',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Çekim Planlaması',
                              style: AppTextStyles.heading3.copyWith(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '29 Mayıs 2024',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8B84B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.black,
                          size: 20,
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
// Top Bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: Get.back,
          ),
          const Spacer(),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'SE',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 1,
                  ),
                ),
                TextSpan(
                  text: 'T',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE8B84B),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _IconCircleBtn(icon: Icons.ios_share_outlined, onTap: () {}),
          const SizedBox(width: 8),
          _IconCircleBtn(
              icon: Icons.notifications_none_rounded,
              onTap: () {},
              dot: true),
        ],
      ),
    );
  }
}

class _IconCircleBtn extends StatelessWidget {
  const _IconCircleBtn(
      {required this.icon, required this.onTap, this.dot = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.75),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 18, color: Colors.black54),
          ),
          if (dot)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8B84B),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card wrapper
// ---------------------------------------------------------------------------

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Step Progress
// ---------------------------------------------------------------------------

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_steps.length, (i) {
          final isDone = i < currentStep;
          final isCurrent = i == currentStep;

          Widget circle;
          if (isDone) {
            circle = Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF0E8DC),
                border: Border.all(color: Colors.black12),
              ),
              child: const Icon(Icons.check_rounded,
                  size: 18, color: Colors.black54),
            );
          } else if (isCurrent) {
            circle = Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8B84B),
              ),
              child: Icon(_steps[i].$1, size: 18, color: Colors.white),
            );
          } else {
            circle = Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF5F0EC),
                border: Border.all(color: Colors.black12),
              ),
              child:
                  Icon(_steps[i].$1, size: 18, color: Colors.black26),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                child: Column(
                  children: [
                    circle,
                    const SizedBox(height: 6),
                    Text(
                      _steps[i].$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isCurrent
                            ? const Color(0xFFB8860B)
                            : Colors.black45,
                        fontSize: 10,
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _steps[i].$3,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isCurrent
                            ? const Color(0xFFB8860B)
                            : Colors.black26,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < _steps.length - 1)
                Padding(
                  padding: const EdgeInsets.only(top: 17),
                  child: Container(
                    width: 16,
                    height: 2,
                    color: i < currentStep
                        ? const Color(0xFFE8B84B)
                        : Colors.black12,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Team Status Item
// ---------------------------------------------------------------------------

class _TeamStatusItem extends StatelessWidget {
  const _TeamStatusItem({required this.role, required this.found});
  final String role;
  final bool found;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8D5C0),
              ),
              child: const Icon(Icons.person, size: 28, color: Color(0xFF8D6E63)),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: found ? const Color(0xFF4CAF50) : const Color(0xFFE8B84B),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Icon(
                  found ? Icons.check_rounded : Icons.search_rounded,
                  size: 9,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          role,
          style: AppTextStyles.caption.copyWith(
            color: Colors.black54,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          found ? 'Bulundu' : 'Aranıyor',
          style: AppTextStyles.caption.copyWith(
            color: found ? const Color(0xFF4CAF50) : const Color(0xFFB8860B),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stat item
// ---------------------------------------------------------------------------

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF8D6E63)),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.black38,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.black.withValues(alpha: 0.07),
    );
  }
}

// ---------------------------------------------------------------------------
// File Thumbnail
// ---------------------------------------------------------------------------

class _FileThumb extends StatelessWidget {
  const _FileThumb({
    required this.icon,
    required this.name,
    required this.meta,
    required this.color,
  });
  final IconData icon;
  final String name;
  final String meta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 72,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: color.withValues(alpha: 0.25), width: 1),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: Text(
            name,
            style: AppTextStyles.caption.copyWith(
              color: Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          meta,
          style: AppTextStyles.caption.copyWith(
            color: Colors.black38,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
