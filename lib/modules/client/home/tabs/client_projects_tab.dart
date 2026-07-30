import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_fonts.dart';

import '../../../../data/models/brief_model.dart';
import '../../../../data/models/project_model.dart';
import '../../../../routes/app_routes.dart';
import '../client_projects_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB); // arka plan (Keşfet ile aynı)
const _kGold = Color(0xFFD9A84E); // kritik / vurgu altın tonu
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kDivider = Color(0x12000000);
const _kCardBorder = Color(0x0F000000);

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
}) =>
    AppFonts.ui(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: spacing,
    );

// ─────────────────────────────────────────────────────────────────
// TAB
// ─────────────────────────────────────────────────────────────────
class ClientProjectsTab extends StatefulWidget {
  const ClientProjectsTab({super.key});

  @override
  State<ClientProjectsTab> createState() => _ClientProjectsTabState();
}

class _ClientProjectsTabState extends State<ClientProjectsTab> {
  int _filterIndex = 0;

  static const _filterLabels = ['TÜMÜ', 'TEKLİF AŞAMASINDA', 'ANLAŞMA BEKLİYOR'];
  static const _filterStatus = <String?>[null, 'offer_sent', 'submitted'];

  List<BriefModel> _apply(List<BriefModel> all) {
    final st = _filterStatus[_filterIndex];
    if (st == null) return all;
    return all.where((b) => b.status == st).toList();
  }

  // Aktif projeler yalnızca "TÜMÜ" filtresinde, brieflerin üstünde gösterilir.
  List<ProjectModel> _activeProjects(ClientProjectsController controller) {
    if (_filterIndex != 0) return [];
    return controller.projects
        .where((p) => p.status == ProjectStatus.active)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientProjectsController>();
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();
    // Kayan nav bar (68 yükseklik + 16 alt boşluk) üstünde kalması için pay.
    final double navClear = MediaQuery.paddingOf(context).bottom + 68 + 16 + 14;

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopStrip(s),
                  SizedBox(height: 18 * s),
                  _buildHeader(s, controller),
                  SizedBox(height: 20 * s),
                  _buildFilterBar(s),
                  SizedBox(height: 8 * s),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: _kGold),
                        );
                      }
                      if (controller.errorMsg.isNotEmpty) {
                        return _ErrorView(
                            scale: s, onRetry: controller.loadBriefs);
                      }
                      final briefs = _apply(controller.briefs);
                      final activeProjects = _activeProjects(controller);
                      if (briefs.isEmpty && activeProjects.isEmpty) {
                        return _EmptyState(scale: s);
                      }
                      return RefreshIndicator(
                        color: _kGold,
                        onRefresh: controller.loadBriefs,
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(0, 6 * s, 0, 130 * s),
                          children: [
                            if (activeProjects.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                                child: _SectionLabel(scale: s, text: 'AKTİF PROJELER'),
                              ),
                              SizedBox(height: 12 * s),
                              for (final p in activeProjects) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24 * s),
                                  child: _ProjectCard(scale: s, project: p),
                                ),
                                SizedBox(height: 18 * s),
                              ],
                              SizedBox(height: 4 * s),
                            ],
                            if (briefs.isNotEmpty) ...[
                              if (activeProjects.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24 * s),
                                  child: _SectionLabel(scale: s, text: 'BRIEFLER'),
                                ),
                                SizedBox(height: 12 * s),
                              ],
                              for (var i = 0; i < briefs.length; i++) ...[
                                _BriefCard(scale: s, brief: briefs[i]),
                                if (i < briefs.length - 1)
                                  SizedBox(height: 18 * s),
                              ],
                            ],
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
              _buildSetFab(s, navClear),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sayfa tepesi — SET · PROJELERİM + tam genişlik ayraç ──────────
  Widget _buildTopStrip(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(26 * s, 6 * s, 26 * s, 12 * s),
          child: Text(
            'SET · PROJELERİM',
            style: _ui(size: 8 * s, color: _kBlack, spacing: 2),
          ),
        ),
        Container(height: 1, color: _kDivider),
      ],
    );
  }

  // ── Header ──────────────────────────────────────────────────────
  Widget _buildHeader(double s, ClientProjectsController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(26 * s, 0, 18 * s, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Projelerim',
                  style: _display(
                      size: 40 * s, weight: FontWeight.w600, color: _kInk),
                ),
                SizedBox(height: 6 * s),
                Obx(() {
                  final count = _apply(controller.briefs).length +
                      _activeProjects(controller).length;
                  return Text(
                    '$count proje görüntüleniyor',
                    style: _ui(size: 8 * s, color: _kBlack, spacing: 0.5),
                  );
                }),
              ],
            ),
          ),
          SizedBox(width: 10 * s),
          _IconBtn(scale: s, icon: Icons.search_rounded, onTap: () {}),
          SizedBox(width: 8 * s),
          _IconBtn(
              scale: s,
              icon: Icons.notifications_none_rounded,
              badge: true,
              onTap: () {}),
        ],
      ),
    );
  }

  // ── Filtre sekmeleri (Keşfet ekranındaki widget ile aynı tasarım) ─
  Widget _buildFilterBar(double s) {
    return SizedBox(
      height: 40 * s,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24 * s),
        children: List.generate(_filterLabels.length, (i) {
          final selected = i == _filterIndex;
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(right: 26 * s),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Container(
                      width: 4 * s,
                      height: 4 * s,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6 * s),
                  ],
                  Text(
                    _filterLabels[i],
                    style: _ui(
                      size: 9 * s,
                      weight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: _kBlack,
                      spacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Kayan SET butonu (sağ alt) ──────────────────────────────────
  // SET Halletsin ile ilerleyen projelerin takip ekranına götürür.
  Widget _buildSetFab(double s, double bottom) {
    return Positioned(
      right: 24 * s,
      bottom: bottom - 46 * s,
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.setProjects),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 56 * s,
          height: 56 * s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 16 * s,
                offset: Offset(0, 6 * s),
              ),
            ],
          ),
          child: Text(
            'SET',
            style: AppFonts.display(
              fontSize: 13 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bölüm etiketi ────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.scale, required this.text});
  final double scale;
  final String text;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: [
        Container(width: 18 * s, height: 2, color: _kGold),
        SizedBox(width: 10 * s),
        Text(
          text,
          style: _ui(size: 8 * s, weight: FontWeight.w700, color: _kBlack, spacing: 1.8),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ACTIVE PROJECT CARD — anlaşılan ve devam eden projeler (ProjectRepository).
// ─────────────────────────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.scale, required this.project});

  final double scale;
  final ProjectModel project;

  IconData get _categoryIcon {
    final cat = (project.category ?? '').toLowerCase();
    if (cat.contains('video') || cat.contains('film')) {
      return Icons.videocam_rounded;
    } else if (cat.contains('fotoğraf') || cat.contains('photo')) {
      return Icons.camera_alt_rounded;
    } else if (cat.contains('ses') || cat.contains('müzik')) {
      return Icons.music_note_rounded;
    } else if (cat.contains('cgi') || cat.contains('vfx')) {
      return Icons.auto_awesome_rounded;
    } else if (cat.contains('kurgu')) {
      return Icons.content_cut_rounded;
    } else if (cat.contains('grafik')) {
      return Icons.brush_rounded;
    }
    return Icons.work_history_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kGold.withValues(alpha: 0.4)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 16 * s),
      child: Row(
        children: [
          Container(
            width: 44 * s,
            height: 44 * s,
            color: _kGold.withValues(alpha: 0.15),
            alignment: Alignment.center,
            child: Icon(_categoryIcon, size: 22 * s, color: _kGold),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title.isNotEmpty ? project.title : 'Proje',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _display(size: 16 * s, weight: FontWeight.w600, color: _kInk),
                ),
                SizedBox(height: 3 * s),
                Text(
                  '${project.budget.toStringAsFixed(0)} ₺ · AKTİF',
                  style: _ui(
                      size: 9 * s, weight: FontWeight.w700, color: _kGold, spacing: 0.4),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18 * s, color: _kMuted),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BRIEF CARD
// ─────────────────────────────────────────────────────────────────
class _BriefCard extends StatelessWidget {
  const _BriefCard({required this.scale, required this.brief});

  final double scale;
  final BriefModel brief;

  String get _statusLabel {
    switch (brief.status) {
      case 'offer_sent':
        return 'TEKLİF AŞAMASINDA';
      case 'submitted':
        return 'ANLAŞMA BEKLİYOR';
      default:
        return 'TASLAK';
    }
  }

  Color get _statusColor {
    switch (brief.status) {
      case 'offer_sent':
      case 'submitted':
        return _kGold;
      default:
        return _kMuted;
    }
  }

  String get _bigTitle =>
      brief.category.isNotEmpty ? brief.category : brief.title;

  String get _subtitle => brief.answers.shootingType ?? '';

  String get _categoryAsset {
    final cat = brief.category.toLowerCase();
    if (cat.contains('video') || cat.contains('film')) {
      return 'assets/images/main_service_icons/video.png';
    } else if (cat.contains('fotoğraf') || cat.contains('photo')) {
      return 'assets/images/main_service_icons/foto.png';
    } else if (cat.contains('ses') || cat.contains('müzik')) {
      return 'assets/images/main_service_icons/ses.png';
    } else if (cat.contains('cgi') || cat.contains('vfx')) {
      return 'assets/images/main_service_icons/cgi.png';
    } else if (cat.contains('kurgu') || cat.contains('montaj')) {
      return 'assets/images/main_service_icons/kurgu.png';
    } else if (cat.contains('sosyal')) {
      return 'assets/images/main_service_icons/sosyal medya.png';
    }
    return 'assets/images/main_service_icons/grafiktasarim.png';
  }

  IconData get _categoryIcon {
    final cat = brief.category.toLowerCase();
    if (cat.contains('video') || cat.contains('film')) {
      return Icons.videocam_rounded;
    } else if (cat.contains('fotoğraf') || cat.contains('photo')) {
      return Icons.camera_alt_rounded;
    } else if (cat.contains('ses') || cat.contains('müzik')) {
      return Icons.music_note_rounded;
    } else if (cat.contains('cgi') || cat.contains('vfx')) {
      return Icons.auto_awesome_rounded;
    }
    return Icons.work_rounded;
  }

  // "50.000₺ - 120.000₺" -> "50K-120K", "300.000₺+" -> "300K+"
  String _compactBudget(String raw) {
    final matches =
        RegExp(r'\d[\d.]*').allMatches(raw).map((m) => m.group(0)!).toList();
    if (matches.isEmpty) return raw;
    final parts = matches.map((numStr) {
      final n = int.tryParse(numStr.replaceAll('.', '')) ?? 0;
      if (n >= 1000) {
        final k = n / 1000;
        final kStr =
            k == k.roundToDouble() ? k.toStringAsFixed(0) : k.toStringAsFixed(1);
        return '${kStr}K';
      }
      return numStr;
    }).toList();
    return parts.join('-') + (raw.contains('+') ? '+' : '');
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.briefDetail, arguments: {'brief': brief}),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: _kCardBorder),
            bottom: BorderSide(color: _kCardBorder),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Durum satırı
            Padding(
              padding: EdgeInsets.fromLTRB(42 * s, 16 * s, 38 * s, 0),
              child: Row(
                children: [
                  Container(
                    width: 8 * s,
                    height: 8 * s,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  Text(
                    _statusLabel,
                    style: _ui(
                        size: 8 * s,
                        weight: FontWeight.w700,
                        color: _kBlack,
                        spacing: 1.4),
                  ),
                ],
              ),
            ),

            // Kimlik satırı
            Padding(
              padding: EdgeInsets.fromLTRB(42 * s, 16 * s, 42 * s, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48 * s,
                    height: 48 * s,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      _categoryAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                          _categoryIcon,
                          size: 22 * s,
                          color: _kGold),
                    ),
                  ),
                  SizedBox(width: 14 * s),
                  Expanded(
                    child: SizedBox(
                      height: 48 * s,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _bigTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _display(
                                size: 20 * s,
                                weight: FontWeight.w600,
                                color: _kInk),
                          ),
                          if (_subtitle.isNotEmpty) ...[
                            SizedBox(height: 3 * s),
                            Text(
                              _subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _ui(
                                  size: 8 * s, color: _kBlack, spacing: 1),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (brief.sentToIds.isNotEmpty) ...[
                    SizedBox(width: 10 * s),
                    Text(
                      '${brief.sentToIds.length}',
                      style: _display(
                          size: 25 * s,
                          weight: FontWeight.w700,
                          color: _kGold),
                    ),
                  ],
                ],
              ),
            ),

            // Meta satırı (teslim / bütçe / çekim)
            if (brief.answers.deliveryTime != null ||
                brief.answers.budget != null ||
                brief.answers.dateRange != null) ...[
              SizedBox(height: 18 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 42 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _MetaCell(
                        scale: s,
                        icon: Icons.schedule_rounded,
                        label: 'TESLİM',
                        value: brief.answers.deliveryTime ?? '—',
                      ),
                    ),
                    Expanded(
                      child: _MetaCell(
                        scale: s,
                        icon: Icons.payments_outlined,
                        label: 'BÜTÇE',
                        value: brief.answers.budget != null
                            ? _compactBudget(brief.answers.budget!)
                            : '—',
                      ),
                    ),
                    Expanded(
                      child: _MetaCell(
                        scale: s,
                        icon: Icons.calendar_today_rounded,
                        label: 'ÇEKİM',
                        value: brief.answers.dateRange ?? '—',
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Konum
            if (brief.answers.location != null &&
                brief.answers.location!.isNotEmpty) ...[
              SizedBox(height: 24 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 42 * s),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13 * s, color: _kTaupe),
                    SizedBox(width: 5 * s),
                    Expanded(
                      child: Text(
                        brief.answers.location!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _ui(size: 9 * s, color: _kBlack, spacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Açıklama + Revize Et
            if (brief.answers.notes != null &&
                brief.answers.notes!.isNotEmpty) ...[
              SizedBox(height: 14 * s),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.sendOffer, arguments: {
                  'category': brief.category,
                  'brief': brief,
                }),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(42 * s, 0, 38 * s, 16 * s),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 13 * s, color: _kTaupe),
                      SizedBox(width: 5 * s),
                      Expanded(
                        child: Text(
                          brief.answers.notes!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _ui(
                              size: 9 * s,
                              weight: FontWeight.w700,
                              color: _kInk,
                              spacing: 0.2),
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Text(
                        'REVİZE ET',
                        style: _ui(
                            size: 8 * s,
                            weight: FontWeight.w700,
                            color: _kGold,
                            spacing: 1.2),
                      ),
                      SizedBox(width: 4 * s),
                      Icon(Icons.chevron_right,
                          size: 16 * s, color: _kGold),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Alt bilgi
              SizedBox(height: 18 * s),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.sendOffer, arguments: {
                  'category': brief.category,
                  'brief': brief,
                }),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(42 * s, 12 * s, 38 * s, 14 * s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'REVİZE ET',
                        style: _ui(
                            size: 8 * s,
                            weight: FontWeight.w700,
                            color: _kGold,
                            spacing: 1.2),
                      ),
                      SizedBox(width: 4 * s),
                      Icon(Icons.chevron_right,
                          size: 16 * s, color: _kGold),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Meta hücresi ─────────────────────────────────────────────────
class _MetaCell extends StatelessWidget {
  const _MetaCell({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 11 * s, color: _kTaupe),
            SizedBox(width: 4 * s),
            Text(
              label,
              style: _ui(size: 7 * s, color: _kBlack, spacing: 1),
            ),
          ],
        ),
        SizedBox(height: 5 * s),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _ui(
              size: 10 * s, weight: FontWeight.w400, color: _kBlack, spacing: 0.3),
        ),
      ],
    );
  }
}

// ─── İkon butonu ──────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.scale,
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  final double scale;
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44 * s,
        height: 44 * s,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20 * s, color: _kInk),
            if (badge)
              Positioned(
                top: 11 * s,
                right: 12 * s,
                child: Container(
                  width: 6 * s,
                  height: 6 * s,
                  decoration: const BoxDecoration(
                    color: _kGold,
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Boş durum ────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68 * s,
            height: 68 * s,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
            ),
            child: Icon(Icons.folder_open_rounded,
                size: 30 * s, color: _kMuted),
          ),
          SizedBox(height: 18 * s),
          Text(
            'Henüz proje yok',
            style: _display(size: 22 * s, weight: FontWeight.w600, color: _kInk),
          ),
          SizedBox(height: 6 * s),
          Text(
            'Brief gönderdikten sonra buraya düşer.',
            style: _ui(size: 9 * s, color: _kBlack, spacing: 0.3),
          ),
        ],
      ),
    );
  }
}

// ─── Hata durumu ──────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.scale, required this.onRetry});
  final double scale;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Projeler yüklenemedi',
            style: _display(size: 22 * s, weight: FontWeight.w600, color: _kInk),
          ),
          SizedBox(height: 12 * s),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 10 * s),
              decoration: BoxDecoration(
                color: _kInk,
                borderRadius: BorderRadius.zero,
              ),
              child: Text(
                'TEKRAR DENE',
                style: _ui(
                    size: 9 * s,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    spacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
