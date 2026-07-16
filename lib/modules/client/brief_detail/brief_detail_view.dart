import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/freelancer_model.dart';
import 'brief_detail_controller.dart';

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

class BriefDetailView extends GetView<BriefDetailController> {
  const BriefDetailView({super.key});

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

  String _fmtFull(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month]} ${d.year} - $h:$m';
  }

  String get _projectId {
    final b = controller.brief;
    return '#PRJ-${b.createdAt.year}-${b.id.substring(0, 8).toUpperCase()}';
  }

  String get _statusLabel {
    switch (controller.brief.status) {
      case 'offer_sent':
        return 'TEKLİF AŞAMASINDA';
      case 'submitted':
        return 'ANLAŞMA BEKLİYOR';
      default:
        return 'TASLAK';
    }
  }

  Color get _statusColor {
    switch (controller.brief.status) {
      case 'offer_sent':
      case 'submitted':
        return _kGold;
      default:
        return _kMuted;
    }
  }

  IconData get _categoryIcon {
    final cat = controller.brief.category.toLowerCase();
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

  // İlerleme — freelancer'ın eklediği aşamaların salt-okunur görünümü.
  List<_Milestone> get _milestones {
    final brief = controller.brief;
    final title = brief.title.isNotEmpty ? brief.title : brief.category;
    return [
      _Milestone(title: 'Brief Onayı', subtitle: title, timeLabel: 'Bugün'),
      _Milestone(title: 'Ekip Kesinleşir', subtitle: title, timeLabel: '18:00'),
      _Milestone(
        title: 'Çekim Planlama',
        subtitle: title,
        timeLabel: brief.answers.dateRange ?? '—',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final brief = controller.brief;
    final a = brief.answers;
    final double s = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.85, 1.15)
        .toDouble();

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
                      _buildHeaderCard(s),
                      SizedBox(height: 14 * s),

                      if (a.shootingType != null ||
                          a.vibes != null ||
                          a.dateRange != null ||
                          a.deliveryTime != null ||
                          a.budget != null ||
                          a.location != null) ...[
                        _Section(
                          scale: s,
                          icon: Icons.assignment_outlined,
                          label: 'BRIEF BİLGİLERİ',
                          child: _buildBriefGrid(a, s),
                        ),
                        SizedBox(height: 14 * s),
                      ],

                      if (a.notes != null && a.notes!.isNotEmpty) ...[
                        _Section(
                          scale: s,
                          icon: Icons.description_outlined,
                          label: 'İŞ TARİFİ',
                          child: Padding(
                            padding: EdgeInsets.only(top: 12 * s),
                            child: Text(
                              a.notes!,
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

                      if (brief.sentToIds.isNotEmpty) ...[
                        Obx(() => _buildFreelancerSection(s)),
                        SizedBox(height: 14 * s),
                      ],

                      // İlerleme — sadece görüntüleme; düzenleme freelancer'da.
                      _Section(
                        scale: s,
                        icon: Icons.timeline_outlined,
                        label: 'İLERLEME',
                        child: Padding(
                          padding: EdgeInsets.only(top: 6 * s),
                          child: Column(
                            children: [
                              for (var i = 0; i < _milestones.length; i++) ...[
                                _MilestoneRow(
                                  scale: s,
                                  milestone: _milestones[i],
                                ),
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
                                value: _fmtFull(brief.createdAt),
                              ),
                              SizedBox(height: 12 * s),
                              _InfoRow(
                                scale: s,
                                label: 'Son Güncelleme',
                                value: _fmtFull(brief.updatedAt),
                              ),
                              SizedBox(height: 12 * s),
                              _InfoRow(
                                scale: s,
                                label: 'Proje ID',
                                value: _projectId,
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
        bottomNavigationBar: _buildBottomBar(s),
      ),
    );
  }

  // ── Header kartı ────────────────────────────────────────────────────────────
  Widget _buildHeaderCard(double s) {
    final brief = controller.brief;
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56 * s,
            height: 56 * s,
            color: _kGold,
            alignment: Alignment.center,
            child: Icon(_categoryIcon, size: 28 * s, color: Colors.white),
          ),
          SizedBox(width: 14 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusLabel,
                  style: _mono(
                    size: 8 * s,
                    weight: FontWeight.w700,
                    color: _statusColor,
                    spacing: 1.2,
                  ),
                ),
                SizedBox(height: 5 * s),
                Text(
                  brief.title.isNotEmpty ? brief.title : brief.category,
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
                  brief.category,
                  style: _mono(size: 8 * s, color: _kMuted, spacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Brief bilgi grid ─────────────────────────────────────────────────────────
  Widget _buildBriefGrid(dynamic a, double s) {
    final items = <_GridItem>[];

    void add(bool cond, IconData icon, String label, String value) {
      if (cond && value.isNotEmpty) {
        items.add(_GridItem(icon: icon, label: label, value: value));
      }
    }

    add(
      a.shootingType != null,
      Icons.movie_creation_outlined,
      'Çekim Türü',
      (a.shootingType as String?) ?? '',
    );
    add(
      a.vibes != null && (a.vibes as List).isNotEmpty,
      Icons.show_chart_rounded,
      'Duygu',
      a.vibes != null ? (a.vibes as List<String>).join(', ') : '',
    );
    add(
      a.dateRange != null,
      Icons.calendar_today_outlined,
      'Çekim Tarihi',
      (a.dateRange as String?) ?? '',
    );
    add(
      a.deliveryTime != null,
      Icons.access_time_outlined,
      'Teslim Süresi',
      (a.deliveryTime as String?) ?? '',
    );
    add(
      a.budget != null,
      Icons.payments_outlined,
      'Bütçe',
      (a.budget as String?) ?? '',
    );
    add(
      a.location != null,
      Icons.location_on_outlined,
      'Lokasyon',
      (a.location as String?) ?? '',
    );

    if (items.isEmpty) return const SizedBox.shrink();

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

  // ── Freelancer bölümü ─────────────────────────────────────────────────────────
  Widget _buildFreelancerSection(double s) {
    final brief = controller.brief;
    if (brief.sentToIds.isEmpty) return const SizedBox.shrink();

    final freelancers = controller.freelancers;
    final loading = controller.loadingFreelancers.value;
    final count = brief.sentToIds.length;
    final show = freelancers.take(3).toList();

    return _Section(
      scale: s,
      icon: Icons.send_outlined,
      label: 'TEKLİF GÖNDERİLEN FREELANCERLAR ($count)',
      child: Padding(
        padding: EdgeInsets.only(top: 10 * s),
        child: loading
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 16 * s),
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _kGold,
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  ...show.map((f) => _FreelancerRow(scale: s, freelancer: f)),
                  if (show.length < count) ...[
                    SizedBox(height: 4 * s),
                    GestureDetector(
                      onTap: controller.sendToNewFreelancer,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10 * s),
                        child: Row(
                          children: [
                            Text(
                              'TÜMÜNÜ GÖR',
                              style: _mono(
                                size: 8 * s,
                                weight: FontWeight.w700,
                                color: _kGold,
                                spacing: 1.2,
                              ),
                            ),
                            SizedBox(width: 4 * s),
                            Icon(
                              Icons.chevron_right,
                              size: 16 * s,
                              color: _kGold,
                            ),
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

  // ── Alt bar ────────────────────────────────────────────────────────────────
  Widget _buildBottomBar(double s) {
    return Container(
      padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 28 * s),
      decoration: const BoxDecoration(
        color: _kCream,
        border: Border(top: BorderSide(color: _kDivider)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: controller.openEdit,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 52 * s,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, size: 16 * s, color: _kInk),
                    SizedBox(width: 7 * s),
                    Text(
                      'DÜZENLE',
                      style: _mono(
                        size: 10 * s,
                        weight: FontWeight.w700,
                        color: _kInk,
                        spacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: controller.sendToNewFreelancer,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 52 * s,
                color: _kGold,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, size: 15 * s, color: Colors.white),
                    SizedBox(width: 8 * s),
                    Text(
                      "YENİ FREELANCER'A GÖNDER",
                      style: _mono(
                        size: 9 * s,
                        weight: FontWeight.w700,
                        color: Colors.white,
                        spacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
  });

  final double scale;
  final IconData icon;
  final String label;
  final Widget child;

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

// ── Freelancer satırı ────────────────────────────────────────────────────────
class _FreelancerRow extends StatelessWidget {
  const _FreelancerRow({required this.scale, required this.freelancer});
  final double scale;
  final FreelancerModel freelancer;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * s),
      child: Row(
        children: [
          Container(
            width: 40 * s,
            height: 40 * s,
            decoration: BoxDecoration(
              color: const Color(0xFFEADCBB),
              image: freelancer.profileImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(freelancer.profileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: freelancer.profileImageUrl == null
                ? Text(
                    freelancer.name.isNotEmpty
                        ? freelancer.name[0].toUpperCase()
                        : '?',
                    style: _mono(
                      size: 12 * s,
                      weight: FontWeight.w700,
                      color: _kInk,
                      spacing: 0.5,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  freelancer.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _serif(
                    size: 15 * s,
                    weight: FontWeight.w600,
                    color: _kInk,
                  ),
                ),
                if (freelancer.categories.isNotEmpty)
                  Text(
                    freelancer.categories.first.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _mono(size: 7 * s, color: _kMuted, spacing: 1),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8 * s),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
            color: _kGold.withValues(alpha: 0.12),
            child: Text(
              'TEKLİF BEKLENİYOR',
              style: _mono(
                size: 7 * s,
                weight: FontWeight.w700,
                color: _kGold,
                spacing: 0.8,
              ),
            ),
          ),
          SizedBox(width: 6 * s),
          Icon(Icons.chevron_right, size: 16 * s, color: _kMuted),
        ],
      ),
    );
  }
}

// ── İlerleme (salt-okunur) ────────────────────────────────────────────────────
class _Milestone {
  const _Milestone({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.scale, required this.milestone});
  final double scale;
  final _Milestone milestone;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: () => _showMilestoneDetail(context, milestone, s),
      behavior: HitTestBehavior.opaque,
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
                    '${milestone.title} · ${milestone.timeLabel}',
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
                    milestone.subtitle,
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
}

// ── İlerleme detayı — salt-okunur bottomsheet ─────────────────────────────────
void _showMilestoneDetail(BuildContext context, _Milestone m, double s) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: _kCream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20 * s,
          20 * s,
          20 * s,
          MediaQuery.of(ctx).viewInsets.bottom + 28 * s,
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
            Row(
              children: [
                _MilestoneDot(scale: s),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Text(
                    m.title,
                    style: _serif(
                      size: 22 * s,
                      weight: FontWeight.w600,
                      color: _kInk,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14 * s),
            Text(
              m.timeLabel.toUpperCase(),
              style: _mono(
                size: 8 * s,
                weight: FontWeight.w700,
                color: _kGold,
                spacing: 1.2,
              ),
            ),
            SizedBox(height: 16 * s),
            Text(
              m.subtitle,
              style: _mono(
                size: 11 * s,
                color: _kInk,
                spacing: 0.2,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
    },
  );
}

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
