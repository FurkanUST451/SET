import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_fonts.dart';

import '../../../../data/models/project_model.dart';
import '../../../../routes/app_routes.dart';
import '../freelancer_projects_controller.dart';
import '../../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
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
}) => AppFonts.display(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

TextStyle _ui({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
}) => AppFonts.ui(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
);

const _months = [
  '',
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];

String _formatDate(DateTime d) => '${d.day} ${_months[d.month]} ${d.year}';

// ─────────────────────────────────────────────────────────────────
// TAB
// ─────────────────────────────────────────────────────────────────
class FreelancerProjectsTab extends StatefulWidget {
  const FreelancerProjectsTab({super.key});

  @override
  State<FreelancerProjectsTab> createState() => _FreelancerProjectsTabState();
}

class _FreelancerProjectsTabState extends State<FreelancerProjectsTab> {
  final FreelancerProjectsController controller =
      Get.find<FreelancerProjectsController>();

  int _filterIndex = 0;

  static const _filterLabels = ['TÜMÜ', 'AKTİF', 'TAMAMLANDI'];
  static const _filterStatus = <ProjectStatus?>[
    null,
    ProjectStatus.active,
    ProjectStatus.completed,
  ];

  List<ProjectModel> _filtered(List<ProjectModel> all) {
    final st = _filterStatus[_filterIndex];
    if (st == null) return all;
    return all.where((p) => p.status == st).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          bottom: false,
          child: Obx(() {
            if (controller.isLoading.value && controller.projects.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: _kGold),
              );
            }
            final list = _filtered(controller.projects);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopStrip(s),
                SizedBox(height: 18 * s),
                _buildHeader(s, list.length),
                SizedBox(height: 20 * s),
                _buildFilterBar(s),
                SizedBox(height: 8 * s),
                Expanded(
                  child: RefreshIndicator(
                    color: _kGold,
                    onRefresh: controller.loadProjects,
                    child: list.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [_EmptyState(scale: s)],
                          )
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              24 * s,
                              6 * s,
                              24 * s,
                              130 * s,
                            ),
                            itemCount: list.length,
                            separatorBuilder: (_, _) => SizedBox(height: 18 * s),
                            itemBuilder: (_, i) => _ProjectCard(
                              scale: s,
                              project: list[i],
                              clientName: controller.clientNames[list[i].clientId],
                            ),
                          ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Sayfa tepesi — SET · ÜRETİM + tam genişlik ayraç ──────────────
  Widget _buildTopStrip(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(26 * s, 6 * s, 26 * s, 12 * s),
          child: Text(
            'SET · ÜRETİM',
            style: _ui(size: 8 * s, color: _kBlack, spacing: 2),
          ),
        ),
        Container(height: 1, color: _kDivider),
      ],
    );
  }

  // ── Header ──────────────────────────────────────────────────────
  Widget _buildHeader(double s, int count) {
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
                    size: 40 * s,
                    weight: FontWeight.w600,
                    color: _kInk,
                  ),
                ),
                SizedBox(height: 6 * s),
                Text(
                  '$count proje görüntüleniyor',
                  style: _ui(size: 8 * s, color: _kBlack, spacing: 0.5),
                ),
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
            onTap: () {},
          ),
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
}

// ─────────────────────────────────────────────────────────────────
// PROJECT CARD — sektasarım tasarımı, ProjectRepository'den gelen gerçek
// verilerle (durum, bütçe, hizmet alan adı) beslenir.
// ─────────────────────────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.scale,
    required this.project,
    this.clientName,
  });

  final double scale;
  final ProjectModel project;
  final String? clientName;

  String get _category => project.category ?? '';

  String get _statusLabel {
    switch (project.status) {
      case ProjectStatus.active:
        return 'AKTİF';
      case ProjectStatus.completed:
        return 'TAMAMLANDI';
      case ProjectStatus.cancelled:
        return 'İPTAL EDİLDİ';
      case ProjectStatus.pending:
        return 'BEKLİYOR';
    }
  }

  Color get _statusColor {
    switch (project.status) {
      case ProjectStatus.active:
        return _kGold;
      case ProjectStatus.completed:
        return const Color(0xFF6B8F71);
      case ProjectStatus.cancelled:
        return const Color(0xFFBE6A5A);
      case ProjectStatus.pending:
        return _kMuted;
    }
  }

  IconData get _categoryIcon {
    final cat = _category.toLowerCase();
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

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.freelancerProjectDetail,
        arguments: {'project': project},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _kCardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Durum satırı
            Padding(
              padding: EdgeInsets.fromLTRB(18 * s, 16 * s, 14 * s, 0),
              child: Row(
                children: [
                  Container(width: 8 * s, height: 8 * s, color: _statusColor),
                  SizedBox(width: 8 * s),
                  Text(
                    _statusLabel,
                    style: _ui(
                      size: 8 * s,
                      weight: FontWeight.w700,
                      color: _kBlack,
                      spacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Kimlik satırı
            Padding(
              padding: EdgeInsets.fromLTRB(18 * s, 16 * s, 18 * s, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48 * s,
                    height: 48 * s,
                    color: _kGold,
                    child: Icon(
                      _categoryIcon,
                      size: 24 * s,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 14 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _display(
                            size: 20 * s,
                            weight: FontWeight.w600,
                            color: _kInk,
                          ),
                        ),
                        SizedBox(height: 3 * s),
                        Text(
                          '${project.shootingType ?? ''} · «${project.title}»',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _ui(size: 8 * s, color: _kBlack, spacing: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Meta satırı (teslim / bütçe / çekim)
            SizedBox(height: 18 * s),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _MetaCell(
                      scale: s,
                      icon: Icons.schedule_rounded,
                      label: 'TESLİM',
                      value: (project.deliveryTime?.isNotEmpty ?? false)
                          ? project.deliveryTime!
                          : '—',
                    ),
                  ),
                  Expanded(
                    child: _MetaCell(
                      scale: s,
                      icon: Icons.payments_outlined,
                      label: 'BÜTÇE',
                      value: '${project.budget.toStringAsFixed(0)} ₺',
                    ),
                  ),
                  Expanded(
                    child: _MetaCell(
                      scale: s,
                      icon: Icons.calendar_today_rounded,
                      label: 'ÇEKİM',
                      value: (project.dateRange?.isNotEmpty ?? false)
                          ? project.dateRange!
                          : '—',
                    ),
                  ),
                ],
              ),
            ),

            // Konum
            SizedBox(height: 16 * s),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18 * s),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 13 * s,
                    color: _kTaupe,
                  ),
                  SizedBox(width: 5 * s),
                  Expanded(
                    child: Text(
                      (project.location?.isNotEmpty ?? false)
                          ? project.location!
                          : '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _ui(size: 9 * s, color: _kBlack, spacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Açıklama
            SizedBox(height: 14 * s),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18 * s),
              child: Text(
                (project.notes ?? project.description),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _ui(size: 9 * s, color: _kBlack, spacing: 0.2),
              ),
            ),

            // Alt bilgi — hizmet alan (varsa) ya da oluşturulma tarihi
            SizedBox(height: 18 * s),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _kDivider)),
              ),
              padding: EdgeInsets.fromLTRB(18 * s, 12 * s, 14 * s, 14 * s),
              child: Row(
                children: [
                  Text(
                    clientName != null
                        ? 'HİZMET ALAN · ${clientName!.toUpperCaseTr()}'
                        : 'OLUŞTURULMA · ${_formatDate(project.createdAt).toUpperCaseTr()}',
                    style: _ui(size: 8 * s, color: _kBlack, spacing: 0.8),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, size: 16 * s, color: _kGold),
                ],
              ),
            ),
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
            size: 10 * s,
            weight: FontWeight.w700,
            color: _kBlack,
            spacing: 0.3,
          ),
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
                child: Container(width: 6 * s, height: 6 * s, color: _kGold),
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
            child: Icon(
              Icons.folder_open_rounded,
              size: 30 * s,
              color: _kMuted,
            ),
          ),
          SizedBox(height: 18 * s),
          Text(
            'Henüz proje yok',
            style: _display(size: 22 * s, weight: FontWeight.w600, color: _kInk),
          ),
          SizedBox(height: 6 * s),
          Text(
            'Kabul ettiğin işler burada görünecek.',
            style: _ui(size: 9 * s, color: _kBlack, spacing: 0.3),
          ),
        ],
      ),
    );
  }
}
