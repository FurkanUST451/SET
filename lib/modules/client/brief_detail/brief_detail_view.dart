import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/utils/avatar_image.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/freelancer_model.dart';
import '../../../data/models/project_model.dart';
import '../home/tabs/profile_screens.dart' show ContactUsScreen;
import 'brief_detail_controller.dart';
import '../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kDivider = Color(0x12000000);
const _kCardBorder = Color(0x14000000);
const _kDanger = Color(0xFFBE6A5A);

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
  double height = 1.4,
}) => AppFonts.ui(
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
    return '#PRJ-${b.createdAt.year}-${b.id.substring(0, 8).toUpperCaseTr()}';
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

  String get _categoryAsset {
    final cat = controller.brief.category.toLowerCase();
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

  // İlerleme — freelancer'ın eklediği aşamaların salt-okunur görünümü.
  // İlk kalem her zaman brief'in bir fiyatta anlaşılıp proje aktif olduğu
  // an (project.createdAt); sonrası freelancer'ın girdiği gerçek kayıtlar.
  _Milestone get _briefApprovalMilestone {
    final brief = controller.brief;
    final title = brief.title.isNotEmpty ? brief.title : brief.category;
    final project = controller.project!;
    return _Milestone(
      title: 'Brief Onayı',
      subtitle: title,
      timeLabel: _fmtFull(project.createdAt),
    );
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
                        style: _display(
                          size: 22 * s,
                          weight: FontWeight.w600,
                          color: _kInk,
                        ),
                      ),
                    ),
                    controller.brief.status == 'accepted'
                        ? PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            color: _kCream,
                            surfaceTintColor: Colors.transparent,
                            elevation: 3,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(color: _kDivider),
                            ),
                            icon: Container(
                              width: 36 * s,
                              height: 36 * s,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.16)),
                              ),
                              child: Icon(
                                Icons.more_horiz_rounded,
                                size: 20 * s,
                                color: _kInk,
                              ),
                            ),
                            onSelected: (value) {
                              if (value == 'cancel') {
                                _showCancelProjectDialog(context, s, controller);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'cancel',
                                height: 40,
                                child: Text(
                                  'İptal Et',
                                  style: _ui(
                                    size: 9 * s,
                                    weight: FontWeight.w600,
                                    color: _kDanger,
                                    spacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : controller.canCancel
                            ? PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                color: _kCream,
                                surfaceTintColor: Colors.transparent,
                                elevation: 3,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                  side: BorderSide(color: _kDivider),
                                ),
                                icon: Icon(
                                  Icons.more_horiz_rounded,
                                  size: 22 * s,
                                  color: _kTaupe,
                                ),
                                onSelected: (value) {
                                  if (value == 'cancel') {
                                    _showCancelBriefDialog(
                                        context, s, controller);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'cancel',
                                    height: 40,
                                    child: Text(
                                      "Brief'i Sil",
                                      style: _ui(
                                        size: 9 * s,
                                        weight: FontWeight.w600,
                                        color: _kDanger,
                                        spacing: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: EdgeInsets.all(8 * s),
                                child: Icon(
                                  Icons.more_horiz_rounded,
                                  size: 22 * s,
                                  color: _kTaupe.withValues(alpha: 0.3),
                                ),
                              ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(0, 6 * s, 0, 0),
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
                              style: _ui(
                                size: 10 * s,
                                color: _kBlack,
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
                      // Brief henüz onaylanıp projeye dönüşmediyse gösterecek
                      // bir şey yok, bölüm hiç render edilmez.
                      if (controller.project != null) ...[
                        _Section(
                          scale: s,
                          icon: Icons.timeline_outlined,
                          label: 'İLERLEME',
                          child: Padding(
                            padding: EdgeInsets.only(top: 6 * s),
                            child: Obx(() {
                              final entries = controller.progressEntries;
                              return Column(
                                children: [
                                  _MilestoneRow(
                                    scale: s,
                                    milestone: _briefApprovalMilestone,
                                  ),
                                  for (final entry in entries) ...[
                                    const Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: _kDivider,
                                    ),
                                    _MilestoneRow(
                                      scale: s,
                                      milestone: _Milestone(
                                        title: entry.title,
                                        subtitle: entry.description,
                                        timeLabel: _fmtFull(entry.createdAt),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }),
                          ),
                        ),
                        SizedBox(height: 14 * s),
                      ],

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

                      if (controller.project != null) ...[
                        SizedBox(height: 14 * s),
                        // Anlaşılan ücret — sadece rakam, açıklama yok.
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 36 * s),
                          child: _buildAgreedPriceBox(controller.project!, s),
                        ),
                      ],

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
      padding: EdgeInsets.fromLTRB(36 * s, 16 * s, 36 * s, 16 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _kCardBorder),
          bottom: BorderSide(color: _kCardBorder),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56 * s,
            height: 56 * s,
            decoration: const BoxDecoration(color: Colors.white),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              _categoryAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(_categoryIcon, size: 28 * s, color: _kGold),
            ),
          ),
          SizedBox(width: 14 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusLabel,
                  style: _ui(
                    size: 10 * s,
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
                  style: _display(
                    size: 24 * s,
                    weight: FontWeight.w600,
                    color: _kInk,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  brief.category,
                  style: _ui(size: 10 * s, color: _kBlack, spacing: 0.5),
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

    void add(bool cond, IconData icon, String label, String value,
        {bool singleLine = false}) {
      if (cond && value.isNotEmpty) {
        items.add(_GridItem(
            icon: icon, label: label, value: value, singleLine: singleLine));
      }
    }

    add(
      a.shootingType != null,
      Icons.movie_creation_outlined,
      'Çekim Türü',
      (a.shootingType as String?) ?? '',
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
      a.budget != null ? _compactBudget(a.budget as String) : '',
    );
    add(
      a.location != null,
      Icons.location_on_outlined,
      'Lokasyon',
      (a.location as String?) ?? '',
      singleLine: true,
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

  // ── Anlaşılan ücret kutusu ───────────────────────────────────────────────
  Widget _buildAgreedPriceBox(ProjectModel p, double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kGold, width: 1.4),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ANLAŞILAN ÜCRET',
            style: _ui(
              size: 13 * s,
              weight: FontWeight.w700,
              color: _kBlack,
              spacing: 1.4,
            ),
          ),
          SizedBox(height: 6 * s),
          Text(
            '${Formatters.groupThousands(p.budget)} ₺',
            style: _display(
              size: 22 * s,
              weight: FontWeight.w700,
              color: _kInk,
            ),
          ),
        ],
      ),
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
                  ...show.map((f) => _FreelancerRow(
                        scale: s,
                        freelancer: f,
                        isRejected: brief.rejectedByIds.contains(f.userId),
                      )),
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
                              style: _ui(
                                size: 10 * s,
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
    if (controller.brief.status == 'accepted') {
      return Container(
        padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 28 * s),
        decoration: const BoxDecoration(
          color: _kCream,
          border: Border(top: BorderSide(color: _kDivider)),
        ),
        child: GestureDetector(
          onTap: () => Get.to<void>(() => const ContactUsScreen()),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            height: 52 * s,
            color: _kGold,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.support_agent_rounded, size: 17 * s, color: Colors.white),
                SizedBox(width: 8 * s),
                Text(
                  'SET DESTEK',
                  style: _ui(
                    size: 10 * s,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    spacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                      style: _ui(
                        size: 10 * s,
                        weight: FontWeight.w700,
                        color: _kBlack,
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
                      style: _ui(
                        size: 10 * s,
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
      padding: EdgeInsets.fromLTRB(36 * s, 14 * s, 36 * s, 16 * s),
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
          Row(
            children: [
              Icon(icon, size: 14 * s, color: _kGold),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  label,
                  style: _ui(
                    size: 10 * s,
                    weight: FontWeight.w700,
                    color: _kBlack,
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
    this.singleLine = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool singleLine;
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
                item.label.toUpperCaseTr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _ui(size: 10 * s, color: _kBlack, spacing: 0.8),
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * s),
        if (item.singleLine)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              item.value,
              maxLines: 1,
              style: _ui(
                size: 10 * s,
                weight: FontWeight.w400,
                color: _kBlack,
                spacing: 0.2,
              ),
            ),
          )
        else
          Text(
            item.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _ui(
              size: 10 * s,
              weight: FontWeight.w400,
              color: _kBlack,
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
            style: _ui(size: 9 * s, color: _kBlack, spacing: 0.3),
          ),
        ),
        SizedBox(width: 10 * s),
        Text(
          value,
          style: _ui(
            size: 9 * s,
            weight: FontWeight.w700,
            color: _kBlack,
            spacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ── Freelancer satırı ────────────────────────────────────────────────────────
class _FreelancerRow extends StatelessWidget {
  const _FreelancerRow({
    required this.scale,
    required this.freelancer,
    this.isRejected = false,
  });
  final double scale;
  final FreelancerModel freelancer;
  final bool isRejected;

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
              shape: BoxShape.circle,
              color: const Color(0xFFEADCBB),
              image: DecorationImage(
                image: avatarImageProvider(
                  freelancer.profileImageUrl ??
                      placeholderAvatarFor(null, freelancer.userId),
                ),
                fit: BoxFit.cover,
              ),
            ),
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
                  style: _display(
                    size: 19 * s,
                    weight: FontWeight.w600,
                    color: _kInk,
                  ),
                ),
                if (freelancer.categories.isNotEmpty)
                  Text(
                    freelancer.categories.first.toUpperCaseTr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ui(size: 10 * s, color: _kBlack, spacing: 1),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8 * s),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
            color: isRejected
                ? _kDanger.withValues(alpha: 0.12)
                : _kGold.withValues(alpha: 0.12),
            child: Text(
              isRejected ? 'REDDEDİLDİ' : 'TEKLİF BEKLENİYOR',
              style: _ui(
                size: 10 * s,
                weight: FontWeight.w700,
                color: isRejected ? _kDanger : _kGold,
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
                    style: _ui(
                      size: 11 * s,
                      weight: FontWeight.w400,
                      color: _kBlack,
                      spacing: 0.2,
                    ),
                  ),
                  if (milestone.subtitle.isNotEmpty) ...[
                    SizedBox(height: 3 * s),
                    Text(
                      milestone.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _ui(
                        size: 9 * s,
                        weight: FontWeight.w400,
                        color: _kGold,
                        spacing: 0.3,
                      ),
                    ),
                  ],
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
                    style: _display(
                      size: 24 * s,
                      weight: FontWeight.w600,
                      color: _kInk,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14 * s),
            Text(
              m.timeLabel.toUpperCaseTr(),
              style: _ui(
                size: 10 * s,
                weight: FontWeight.w700,
                color: _kGold,
                spacing: 1.2,
              ),
            ),
            SizedBox(height: 16 * s),
            Text(
              m.subtitle,
              style: _ui(
                size: 11 * s,
                color: _kBlack,
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
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final offset in const [
            Offset(-0.4, 0),
            Offset(0.4, 0),
            Offset(0, -0.4),
            Offset(0, 0.4),
          ])
            Transform.translate(
              offset: offset,
              child: Icon(Icons.check_rounded, size: 22 * s, color: _kInk),
            ),
          Icon(Icons.check_rounded, size: 22 * s, color: _kInk),
        ],
      ),
    );
  }
}

// ── Brief iptal onayı — sebep seçimi + Sil/İptal ────────────────────────────
void _showCancelBriefDialog(
    BuildContext context, double s, BriefDetailController controller) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) => _CancelBriefDialog(scale: s, controller: controller),
  );
}

class _CancelBriefDialog extends StatefulWidget {
  const _CancelBriefDialog({required this.scale, required this.controller});

  final double scale;
  final BriefDetailController controller;

  @override
  State<_CancelBriefDialog> createState() => _CancelBriefDialogState();
}

class _CancelBriefDialogState extends State<_CancelBriefDialog> {
  static const _reasons = <String>[
    'Yanlış brief gönderdim.',
    'Projeden vazgeçtim.',
    'Başka bir freelancer ile anlaştım.',
    'Belirtmek istemiyorum.',
  ];

  String _selected = _reasons.first;

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return Dialog(
      backgroundColor: _kCream,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 24 * s),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: _kCardBorder),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(22 * s, 22 * s, 22 * s, 18 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emin misin?',
              style: _display(size: 24 * s, weight: FontWeight.w600, color: _kInk),
            ),
            SizedBox(height: 6 * s),
            Text(
              'Bu brief iptal edilecek ve gönderdiğin freelancerlara '
              '"İptal Edildi" olarak görünecek.',
              style: _ui(size: 9 * s, color: _kTaupe, spacing: 0.2, height: 1.5),
            ),
            SizedBox(height: 18 * s),
            Text(
              'İPTALİN SEBEBİ NEDİR?',
              style: _ui(
                size: 10 * s,
                weight: FontWeight.w700,
                color: _kBlack,
                spacing: 1.2,
              ),
            ),
            SizedBox(height: 10 * s),
            Wrap(
              spacing: 8 * s,
              runSpacing: 8 * s,
              children: [
                for (final r in _reasons)
                  _ReasonChip(
                    scale: s,
                    label: r,
                    selected: _selected == r,
                    onTap: () => setState(() => _selected = r),
                  ),
              ],
            ),
            SizedBox(height: 22 * s),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 46 * s,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black.withValues(alpha: 0.14)),
                      ),
                      child: Text(
                        'İPTAL',
                        style: _ui(
                          size: 10 * s,
                          weight: FontWeight.w700,
                          color: _kInk,
                          spacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: Obx(() => GestureDetector(
                        onTap: widget.controller.isCancelling.value
                            ? null
                            : () => widget.controller.cancelBrief(_selected),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 46 * s,
                          alignment: Alignment.center,
                          color: _kDanger,
                          child: widget.controller.isCancelling.value
                              ? SizedBox(
                                  width: 18 * s,
                                  height: 18 * s,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'SİL',
                                  style: _ui(
                                    size: 10 * s,
                                    weight: FontWeight.w700,
                                    color: Colors.white,
                                    spacing: 1,
                                  ),
                                ),
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    required this.scale,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final double scale;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
        decoration: BoxDecoration(
          color: selected ? _kGold : Colors.white,
          border: Border.all(color: selected ? _kGold : _kCardBorder),
        ),
        child: Text(
          label,
          style: _ui(
            size: 11 * s,
            weight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : _kInk,
            spacing: 0.2,
          ),
        ),
      ),
    );
  }
}

// ── Onaylı proje iptali — serbest metin sebep + Gönder/Vazgeç ──────────────
void _showCancelProjectDialog(
    BuildContext context, double s, BriefDetailController controller) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) => _CancelProjectDialog(scale: s),
  );
}

class _CancelProjectDialog extends StatefulWidget {
  const _CancelProjectDialog({required this.scale});

  final double scale;

  @override
  State<_CancelProjectDialog> createState() => _CancelProjectDialogState();
}

class _CancelProjectDialogState extends State<_CancelProjectDialog> {
  final _reasonController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(() {
      final hasText = _reasonController.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) return;
    Navigator.of(context).pop();
    Get.snackbar(
      'Talebiniz alındı',
      'İptal talebini aldık, destek ekibimiz en kısa sürede seninle iletişime geçecek.',
      backgroundColor: const Color(0xFF2E7D32),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return Dialog(
      backgroundColor: _kCream,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 24 * s),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: _kCardBorder),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(22 * s, 22 * s, 22 * s, 18 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Projeyi İptal Et',
              style: _display(size: 24 * s, weight: FontWeight.w600, color: _kInk),
            ),
            SizedBox(height: 6 * s),
            Text(
              'Bu proje iptal edilecek ve destek ekibimiz senin ve freelancer\'ın '
              'sürecini kapatmak için iletişime geçecek.',
              style: _ui(size: 9 * s, color: _kTaupe, spacing: 0.2, height: 1.5),
            ),
            SizedBox(height: 18 * s),
            Text(
              'İPTAL ETME NEDENİNİZİ BELİRTİN',
              style: _ui(
                size: 10 * s,
                weight: FontWeight.w700,
                color: _kBlack,
                spacing: 1.2,
              ),
            ),
            SizedBox(height: 10 * s),
            Container(
              color: Colors.white,
              child: TextField(
                controller: _reasonController,
                maxLines: 4,
                maxLength: 500,
                cursorColor: _kGold,
                style: _ui(size: 10 * s, color: _kBlack, spacing: 0.2, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'Nedeninizi buraya yazın...',
                  hintStyle: _ui(size: 10 * s, color: _kTaupe, spacing: 0.2),
                  filled: true,
                  fillColor: Colors.white,
                  counterText: '',
                  isDense: true,
                  contentPadding: EdgeInsets.all(12 * s),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.14)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.14)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: _kGold),
                  ),
                ),
              ),
            ),
            SizedBox(height: 22 * s),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 46 * s,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black.withValues(alpha: 0.14)),
                      ),
                      child: Text(
                        'VAZGEÇ',
                        style: _ui(
                          size: 10 * s,
                          weight: FontWeight.w700,
                          color: _kInk,
                          spacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: GestureDetector(
                    onTap: _hasText ? _submit : null,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 46 * s,
                      alignment: Alignment.center,
                      color: _hasText ? _kDanger : _kDanger.withValues(alpha: 0.35),
                      child: Text(
                        'GÖNDER',
                        style: _ui(
                          size: 10 * s,
                          weight: FontWeight.w700,
                          color: Colors.white,
                          spacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
