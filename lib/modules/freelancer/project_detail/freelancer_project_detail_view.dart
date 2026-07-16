import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home/tabs/freelancer_projects_tab.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kDivider = Color(0x12000000);
const _kCardBorder = Color(0x14000000);

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
  double height = 1.4,
}) => GoogleFonts.spaceMono(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
  height: height,
);

// ─── İlerleme (milestone) modeli — UI-only ────────────────────────────────────
class _Milestone {
  _Milestone({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
  });

  String title;
  String subtitle;
  String timeLabel;
}

class FreelancerProjectDetailView extends StatefulWidget {
  const FreelancerProjectDetailView({super.key});

  @override
  State<FreelancerProjectDetailView> createState() =>
      _FreelancerProjectDetailViewState();
}

class _FreelancerProjectDetailViewState
    extends State<FreelancerProjectDetailView> {
  FreelancerProjectModel? _project;
  List<_Milestone> _milestones = [];

  static const _months = [
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

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _project = args?['project'] as FreelancerProjectModel?;
    if (_project != null) {
      _milestones = [
        _Milestone(
          title: 'Brief Onayı',
          subtitle: _project!.title,
          timeLabel: 'Bugün',
        ),
        _Milestone(
          title: 'Ekip Kesinleşir',
          subtitle: _project!.title,
          timeLabel: '18:00',
        ),
        _Milestone(
          title: 'Çekim Planlama',
          subtitle: _project!.title,
          timeLabel: _project!.dateRange,
        ),
      ];
    }
  }

  String _fmtFull(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month]} ${d.year} - $h:$m';
  }

  IconData _categoryIcon(String category) {
    final cat = category.toLowerCase();
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
    final project = _project;
    final double s = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.85, 1.15)
        .toDouble();

    if (project == null) {
      return Scaffold(
        backgroundColor: _kCream,
        body: const Center(child: Text('Proje bulunamadı')),
      );
    }

    final active = project.status == 'Aktif';
    final statusColor = active ? _kGold : _kMuted;
    final projectId = '#PRJ-${project.createdAt.year}-${project.id}';

    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: _kCream,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Üst bar
              Padding(
                padding: EdgeInsets.fromLTRB(8 * s, 8 * s, 8 * s, 8 * s),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back<void>(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8 * s),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 22 * s,
                          color: _kInk,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Proje Detayı',
                        textAlign: TextAlign.center,
                        style: _serif(
                          size: 22 * s,
                          weight: FontWeight.w600,
                          color: _kInk,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8 * s),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          size: 22 * s,
                          color: _kTaupe,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20 * s, 6 * s, 20 * s, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık kartı
                      Container(
                        padding: EdgeInsets.all(16 * s),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border.fromBorderSide(
                            BorderSide(color: _kCardBorder),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56 * s,
                              height: 56 * s,
                              color: _kGold,
                              alignment: Alignment.center,
                              child: Icon(
                                _categoryIcon(project.category),
                                size: 28 * s,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 14 * s),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.status.toUpperCase(),
                                    style: _mono(
                                      size: 8 * s,
                                      weight: FontWeight.w700,
                                      color: statusColor,
                                      spacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 5 * s),
                                  Text(
                                    project.category,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: _serif(
                                      size: 24 * s,
                                      weight: FontWeight.w600,
                                      color: _kInk,
                                    ),
                                  ),
                                  SizedBox(height: 2 * s),
                                  Text(
                                    '${project.shootingType} · «${project.title}»',
                                    style: _mono(
                                      size: 8 * s,
                                      color: _kMuted,
                                      spacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14 * s),

                      // Brief bilgileri
                      _Section(
                        scale: s,
                        icon: Icons.assignment_outlined,
                        label: 'BRIEF BİLGİLERİ',
                        child: _buildBriefGrid(project, s),
                      ),
                      SizedBox(height: 14 * s),

                      // İş tarifi
                      if (project.notes.isNotEmpty) ...[
                        _Section(
                          scale: s,
                          icon: Icons.description_outlined,
                          label: 'İŞ TARİFİ',
                          child: Padding(
                            padding: EdgeInsets.only(top: 12 * s),
                            child: Text(
                              project.notes,
                              style: _mono(
                                size: 10 * s,
                                color: _kInk,
                                spacing: 0.2,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 14 * s),
                      ],

                      // İlerleme
                      _Section(
                        scale: s,
                        icon: Icons.timeline_outlined,
                        label: 'İLERLEME',
                        onAdd: () => _openMilestoneSheet(),
                        child: Padding(
                          padding: EdgeInsets.only(top: 6 * s),
                          child: Column(
                            children: [
                              for (var i = 0; i < _milestones.length; i++) ...[
                                _buildMilestoneRow(_milestones[i], s),
                                if (i < _milestones.length - 1)
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: _kDivider,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14 * s),

                      // Proje bilgileri
                      _Section(
                        scale: s,
                        icon: Icons.info_outline,
                        label: 'PROJE BİLGİLERİ',
                        child: Padding(
                          padding: EdgeInsets.only(top: 14 * s),
                          child: Column(
                            children: [
                              _InfoRow(
                                scale: s,
                                label: 'Oluşturulma Tarihi',
                                value: _fmtFull(project.createdAt),
                              ),
                              SizedBox(height: 12 * s),
                              _InfoRow(
                                scale: s,
                                label: 'Son Güncelleme',
                                value: _fmtFull(project.updatedAt),
                              ),
                              SizedBox(height: 12 * s),
                              _InfoRow(
                                scale: s,
                                label: 'Proje ID',
                                value: projectId,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 120 * s),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBriefGrid(FreelancerProjectModel p, double s) {
    final items = <_GridItem>[
      _GridItem(
        icon: Icons.movie_creation_outlined,
        label: 'Çekim Türü',
        value: p.shootingType,
      ),
      _GridItem(
        icon: Icons.access_time_outlined,
        label: 'Teslim Süresi',
        value: p.deliveryTime,
      ),
      _GridItem(icon: Icons.payments_outlined, label: 'Bütçe', value: p.budget),
      _GridItem(
        icon: Icons.calendar_today_outlined,
        label: 'Çekim Tarihi',
        value: p.dateRange,
      ),
      _GridItem(
        icon: Icons.location_on_outlined,
        label: 'Lokasyon',
        value: p.location,
      ),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 3) {
      final rowItems = items.sublist(
        i,
        i + 3 > items.length ? items.length : i + 3,
      );
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(3, (j) {
            if (j >= rowItems.length) return const Expanded(child: SizedBox());
            return Expanded(
              child: _GridCell(scale: s, item: rowItems[j]),
            );
          }),
        ),
      );
      if (i + 3 < items.length) rows.add(SizedBox(height: 14 * s));
    }

    return Padding(
      padding: EdgeInsets.only(top: 16 * s),
      child: Column(children: rows),
    );
  }

  // ── İlerleme satırı ──────────────────────────────────────────────────────────
  Widget _buildMilestoneRow(_Milestone m, double s) {
    return _SwipeToDeleteRow(
      key: ValueKey(m),
      scale: s,
      onDelete: () => setState(() => _milestones.remove(m)),
      onTap: () => _openMilestoneSheet(existing: m),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12 * s),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _MilestoneDot(scale: s),
            SizedBox(width: 14 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${m.title} · ${m.timeLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _mono(
                      size: 11 * s,
                      weight: FontWeight.w700,
                      color: _kInk,
                      spacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 3 * s),
                  Text(
                    m.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _mono(
                      size: 9 * s,
                      weight: FontWeight.w600,
                      color: _kGold,
                      spacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16 * s, color: _kMuted),
          ],
        ),
      ),
    );
  }

  // ── İlerleme ekle / düzenle bottomsheet ────────────────────────────────────
  Future<void> _openMilestoneSheet({_Milestone? existing}) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.subtitle ?? '');

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _kCream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        final s = (MediaQuery.sizeOf(ctx).width / 390)
            .clamp(0.85, 1.15)
            .toDouble();
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20 * s,
            20 * s,
            20 * s,
            MediaQuery.of(ctx).viewInsets.bottom + 20 * s,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36 * s,
                  height: 3 * s,
                  color: _kDivider,
                  margin: EdgeInsets.only(bottom: 18 * s),
                ),
              ),
              Text(
                existing == null ? 'İlerleme Ekle' : 'İlerlemeyi Düzenle',
                style: _serif(
                  size: 22 * s,
                  weight: FontWeight.w600,
                  color: _kInk,
                ),
              ),
              SizedBox(height: 20 * s),
              Text(
                'BAŞLIK',
                style: _mono(
                  size: 8 * s,
                  weight: FontWeight.w700,
                  color: _kMuted,
                  spacing: 1.2,
                ),
              ),
              SizedBox(height: 8 * s),
              _SheetField(
                controller: titleCtrl,
                scale: s,
                hint: 'Örn. Çekim başladı',
              ),
              SizedBox(height: 18 * s),
              Text(
                'AÇIKLAMA',
                style: _mono(
                  size: 8 * s,
                  weight: FontWeight.w700,
                  color: _kMuted,
                  spacing: 1.2,
                ),
              ),
              SizedBox(height: 8 * s),
              _SheetField(
                controller: descCtrl,
                scale: s,
                hint: 'Kısa bir not',
                maxLines: 1,
              ),
              SizedBox(height: 24 * s),
              GestureDetector(
                onTap: () {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  final desc = descCtrl.text.trim();
                  setState(() {
                    if (existing != null) {
                      existing.title = title;
                      existing.subtitle = desc;
                    } else {
                      final now = DateTime.now();
                      _milestones.add(
                        _Milestone(
                          title: title,
                          subtitle: desc,
                          timeLabel:
                              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                        ),
                      );
                    }
                  });
                  Navigator.of(ctx).pop();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  height: 52 * s,
                  color: _kGold,
                  alignment: Alignment.center,
                  child: Text(
                    'KAYDET',
                    style: _mono(
                      size: 11 * s,
                      weight: FontWeight.w700,
                      color: Colors.white,
                      spacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Sağa kaydırınca solda silme ikonu açan satır ──────────────────────────────
// Kaydırma tek başına silmez; açılan sarı çöp ikonuna dokunmak gerekir.
class _SwipeToDeleteRow extends StatefulWidget {
  const _SwipeToDeleteRow({
    super.key,
    required this.scale,
    required this.onDelete,
    required this.onTap,
    required this.child,
  });

  final double scale;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_SwipeToDeleteRow> createState() => _SwipeToDeleteRowState();
}

class _SwipeToDeleteRowState extends State<_SwipeToDeleteRow> {
  double _offset = 0;
  double get _revealWidth => 56 * widget.scale;

  void _close() => setState(() => _offset = 0);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  widget.onDelete();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: _revealWidth,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: _kCardBorder)),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 20 * widget.scale,
                    color: _kGold,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _offset = (_offset + details.delta.dx).clamp(0.0, _revealWidth);
              });
            },
            onHorizontalDragEnd: (details) {
              setState(() {
                _offset = _offset > _revealWidth / 2 ? _revealWidth : 0;
              });
            },
            onTap: () {
              if (_offset > 0) {
                _close();
              } else {
                widget.onTap();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              transform: Matrix4.translationValues(_offset, 0, 0),
              color: _kCream,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

// ── İlerleme noktası — eklenen her madde tikli görünür ────────────────────────
class _MilestoneDot extends StatelessWidget {
  const _MilestoneDot({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final size = 26 * s;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: _kInk, width: 1.4),
      ),
      child: Icon(Icons.check_rounded, size: 14 * s, color: _kInk),
    );
  }
}

// ── Bottomsheet metin alanı ────────────────────────────────────────────────────
class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.scale,
    this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final double scale;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: c),
    );
    return TextField(
      controller: controller,
      maxLines: maxLines,
      cursorColor: _kGold,
      style: _mono(size: 11 * s, color: _kInk, spacing: 0.2),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: _mono(size: 11 * s, color: _kMuted, spacing: 0.2),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14 * s,
          vertical: 12 * s,
        ),
        border: border(Colors.black.withValues(alpha: 0.12)),
        enabledBorder: border(Colors.black.withValues(alpha: 0.12)),
        focusedBorder: border(_kGold),
      ),
    );
  }
}

// ── Bölüm sarmalayıcı ────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  const _Section({
    required this.scale,
    required this.icon,
    required this.label,
    required this.child,
    this.onAdd,
  });

  final double scale;
  final IconData icon;
  final String label;
  final Widget child;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16 * s, 14 * s, 16 * s, 16 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14 * s, color: _kGold),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  label,
                  style: _mono(
                    size: 8 * s,
                    weight: FontWeight.w700,
                    color: _kInk,
                    spacing: 1.4,
                  ),
                ),
              ),
              if (onAdd != null)
                GestureDetector(
                  onTap: onAdd,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 22 * s,
                    height: 22 * s,
                    color: _kGold,
                    child: Icon(
                      Icons.add_rounded,
                      size: 16 * s,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

// ── Grid hücresi ─────────────────────────────────────────────────────────────
class _GridItem {
  const _GridItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.scale, required this.item});
  final double scale;
  final _GridItem item;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    if (item.value.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(item.icon, size: 11 * s, color: _kTaupe),
            SizedBox(width: 4 * s),
            Expanded(
              child: Text(
                item.label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _mono(size: 7 * s, color: _kMuted, spacing: 0.8),
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * s),
        Text(
          item.value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _mono(
            size: 10 * s,
            weight: FontWeight.w700,
            color: _kInk,
            spacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ── Bilgi satırı ─────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.scale,
    required this.label,
    required this.value,
  });
  final double scale;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.3),
          ),
        ),
        SizedBox(width: 10 * s),
        Text(
          value,
          style: _mono(
            size: 9 * s,
            weight: FontWeight.w700,
            color: _kInk,
            spacing: 0.3,
          ),
        ),
      ],
    );
  }
}
