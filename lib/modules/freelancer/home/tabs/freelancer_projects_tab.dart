import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../routes/app_routes.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kDivider = Color(0x12000000);
const _kCardBorder = Color(0x0F000000);

// ─── Tipografi yardımcıları ───────────────────────────────────────────────────
TextStyle _serif({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
}) => GoogleFonts.cormorantGaramond(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

TextStyle _mono({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
}) => GoogleFonts.spaceMono(
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

// ─── Dummy proje verisi (UI-only) ─────────────────────────────────────────────
class FreelancerProjectModel {
  const FreelancerProjectModel({
    required this.id,
    required this.category,
    required this.title,
    required this.status,
    required this.shootingType,
    required this.deliveryTime,
    required this.budget,
    required this.dateRange,
    required this.location,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String category;
  final String title;
  final String status; // 'Aktif' | 'Tamamlandı'
  final String shootingType;
  final String deliveryTime;
  final String budget;
  final String dateRange;
  final String location;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final _allProjects = [
  FreelancerProjectModel(
    id: 'ER48WVEE',
    category: 'Video Prodüksiyon',
    title: 'Ürün Reklamı - Erkan',
    status: 'Aktif',
    shootingType: 'Reklam Filmi',
    deliveryTime: '7 Gün',
    budget: '₺18.000',
    dateRange: '12-14 Mayıs',
    location: 'İstanbul / Beşiktaş',
    notes: 'Ürün lansmanı için enerjik, hızlı kesimli bir reklam filmi.',
    createdAt: DateTime(2026, 4, 28),
    updatedAt: DateTime(2026, 5, 9),
  ),
  FreelancerProjectModel(
    id: 'AR12MXQZ',
    category: 'Ses Tasarımı',
    title: 'Müzik Videosu - Aria',
    status: 'Tamamlandı',
    shootingType: 'Müzik Videosu',
    deliveryTime: 'Teslim edildi',
    budget: '₺40.000',
    dateRange: '04 Mart',
    location: 'Stüdyo',
    notes: 'Final teslim yapıldı, tüm dosyalar paylaşıldı.',
    createdAt: DateTime(2026, 2, 18),
    updatedAt: DateTime(2026, 3, 4),
  ),
];

// ─────────────────────────────────────────────────────────────────
// TAB
// ─────────────────────────────────────────────────────────────────
class FreelancerProjectsTab extends StatefulWidget {
  const FreelancerProjectsTab({super.key});

  @override
  State<FreelancerProjectsTab> createState() => _FreelancerProjectsTabState();
}

class _FreelancerProjectsTabState extends State<FreelancerProjectsTab> {
  int _filterIndex = 0;

  static const _filterLabels = ['TÜMÜ', 'AKTİF', 'TAMAMLANDI'];
  static const _filterStatus = <String?>[null, 'Aktif', 'Tamamlandı'];

  List<FreelancerProjectModel> get _filtered {
    final st = _filterStatus[_filterIndex];
    if (st == null) return _allProjects;
    return _allProjects.where((p) => p.status == st).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();
    final list = _filtered;

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(s, list.length),
              SizedBox(height: 20 * s),
              _buildFilterBar(s),
              SizedBox(height: 8 * s),
              Expanded(
                child: list.isEmpty
                    ? _EmptyState(scale: s)
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          24 * s,
                          6 * s,
                          24 * s,
                          130 * s,
                        ),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => SizedBox(height: 18 * s),
                        itemBuilder: (_, i) =>
                            _ProjectCard(scale: s, project: list[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────
  Widget _buildHeader(double s, int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(26 * s, 22 * s, 18 * s, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SET · ÜRETİM',
                  style: _mono(size: 8 * s, color: _kMuted, spacing: 2),
                ),
                SizedBox(height: 8 * s),
                Text(
                  'Projelerim',
                  style: _serif(
                    size: 40 * s,
                    weight: FontWeight.w600,
                    color: _kInk,
                  ),
                ),
                SizedBox(height: 6 * s),
                Text(
                  '$count proje görüntüleniyor',
                  style: _mono(size: 8 * s, color: _kTaupe, spacing: 0.5),
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

  // ── Filtre pilleri ──────────────────────────────────────────────
  Widget _buildFilterBar(double s) {
    return SizedBox(
      height: 40 * s,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24 * s),
        itemCount: _filterLabels.length,
        separatorBuilder: (_, _) => SizedBox(width: 10 * s),
        itemBuilder: (_, i) {
          final active = i == _filterIndex;
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16 * s),
              decoration: BoxDecoration(
                color: active ? _kInk : Colors.transparent,
                border: Border.all(
                  color: active ? _kInk : Colors.black.withValues(alpha: 0.14),
                ),
              ),
              child: Text(
                _filterLabels[i],
                style: _mono(
                  size: 9 * s,
                  weight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? Colors.white : _kTaupe,
                  spacing: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PROJECT CARD — hizmet alan "Projelerim" kartıyla birebir aynı tasarım;
// düzenleme butonu ve teklif sayacı yok (hizmet veren sadece görüntüler).
// ─────────────────────────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.scale, required this.project});

  final double scale;
  final FreelancerProjectModel project;

  Color get _statusColor => project.status == 'Aktif' ? _kGold : _kMuted;

  IconData get _categoryIcon {
    final cat = project.category.toLowerCase();
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
                    project.status.toUpperCase(),
                    style: _mono(
                      size: 8 * s,
                      weight: FontWeight.w700,
                      color: _kInk,
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
                          project.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _serif(
                            size: 20 * s,
                            weight: FontWeight.w600,
                            color: _kInk,
                          ),
                        ),
                        SizedBox(height: 3 * s),
                        Text(
                          '${project.shootingType} · «${project.title}»',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _mono(size: 8 * s, color: _kMuted, spacing: 1),
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
                      value: project.deliveryTime,
                    ),
                  ),
                  Expanded(
                    child: _MetaCell(
                      scale: s,
                      icon: Icons.payments_outlined,
                      label: 'BÜTÇE',
                      value: project.budget,
                    ),
                  ),
                  Expanded(
                    child: _MetaCell(
                      scale: s,
                      icon: Icons.calendar_today_rounded,
                      label: 'ÇEKİM',
                      value: project.dateRange,
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
                      project.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.5),
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
                project.notes,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _mono(size: 9 * s, color: _kInk, spacing: 0.2),
              ),
            ),

            // Alt bilgi
            SizedBox(height: 18 * s),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _kDivider)),
              ),
              padding: EdgeInsets.fromLTRB(18 * s, 12 * s, 14 * s, 14 * s),
              child: Row(
                children: [
                  Text(
                    'SON GÜNCELLEME · ${_formatDate(project.updatedAt).toUpperCase()}',
                    style: _mono(size: 8 * s, color: _kMuted, spacing: 0.8),
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
              style: _mono(size: 7 * s, color: _kMuted, spacing: 1),
            ),
          ],
        ),
        SizedBox(height: 5 * s),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _mono(
            size: 10 * s,
            weight: FontWeight.w700,
            color: _kInk,
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
            style: _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk),
          ),
          SizedBox(height: 6 * s),
          Text(
            'Kabul ettiğin işler burada görünecek.',
            style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.3),
          ),
        ],
      ),
    );
  }
}
