import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/utils/avatar_image.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/progress_entry_model.dart';
import '../../../data/models/project_model.dart';
import '../../../routes/app_routes.dart';
import 'project_detail_controller.dart';
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
const _kCompleted = Color(0xFF6B8F71);
const _kCancelled = Color(0xFFBE6A5A);

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
  final FreelancerProjectDetailController controller =
      Get.find<FreelancerProjectDetailController>();

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

  // Zaman çizelgesinin ilk kalemi — brief bir fiyatta anlaşılıp proje aktif
  // olduğu an (project.createdAt) otomatik oluşur, hiçbir yerde saklanmaz.
  _Milestone get _briefApprovalMilestone {
    final project = controller.project;
    return _Milestone(
      title: 'Brief Onayı',
      subtitle: project.title,
      timeLabel: _fmtFull(project.createdAt),
    );
  }

  String _fmtFull(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month]} ${d.year} - $h:$m';
  }

  String get _projectCode {
    final p = controller.project;
    return '#PRJ-${p.createdAt.year}-${p.id.substring(0, p.id.length >= 8 ? 8 : p.id.length).toUpperCaseTr()}';
  }

  String get _statusLabel {
    switch (controller.project.status) {
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
    switch (controller.project.status) {
      case ProjectStatus.active:
        return _kGold;
      case ProjectStatus.completed:
        return _kCompleted;
      case ProjectStatus.cancelled:
        return _kCancelled;
      case ProjectStatus.pending:
        return _kMuted;
    }
  }

  String _categoryAsset(String category) {
    final cat = category.toLowerCase();
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
    final project = controller.project;
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
                    GestureDetector(
                      onTap: () =>
                          Get.toNamed(AppRoutes.freelancerSetProjects),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8 * s),
                        child: Icon(
                          Icons.timeline_outlined,
                          size: 22 * s,
                          color: _kInk,
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
                              decoration: const BoxDecoration(color: Colors.white),
                              alignment: Alignment.center,
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                _categoryAsset(project.category ?? ''),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  _categoryIcon(project.category ?? ''),
                                  size: 28 * s,
                                  color: _kGold,
                                ),
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
                                      size: 8 * s,
                                      weight: FontWeight.w700,
                                      color: _statusColor,
                                      spacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 5 * s),
                                  Text(
                                    project.title.isNotEmpty
                                        ? project.title
                                        : (project.category ?? ''),
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
                                    '${project.shootingType ?? ''} · «${project.category ?? ''}»',
                                    style: _ui(
                                      size: 8 * s,
                                      color: _kBlack,
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
                      if (project.shootingType != null ||
                          (project.vibes?.isNotEmpty ?? false) ||
                          project.dateRange != null ||
                          project.deliveryTime != null ||
                          project.budget > 0 ||
                          project.location != null) ...[
                        _Section(
                          scale: s,
                          icon: Icons.assignment_outlined,
                          label: 'BRIEF BİLGİLERİ',
                          child: _buildBriefGrid(project, s),
                        ),
                        SizedBox(height: 14 * s),
                      ],

                      // İş tarifi
                      if ((project.notes ?? project.description).isNotEmpty) ...[
                        _Section(
                          scale: s,
                          icon: Icons.description_outlined,
                          label: 'İŞ TARİFİ',
                          child: Padding(
                            padding: EdgeInsets.only(top: 12 * s),
                            child: Text(
                              project.notes ?? project.description,
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

                      // İşi Veren (client) — gerçek kullanıcı verisi
                      Obx(() => _buildClientSection(s)),
                      SizedBox(height: 14 * s),

                      // İlerleme
                      _Section(
                        scale: s,
                        icon: Icons.timeline_outlined,
                        label: 'İLERLEME',
                        onAdd: () => _openMilestoneSheet(),
                        child: Padding(
                          padding: EdgeInsets.only(top: 6 * s),
                          child: Obx(() {
                            final entries = controller.progressEntries;
                            return Column(
                              children: [
                                _buildSyntheticRow(_briefApprovalMilestone, s),
                                for (final entry in entries) ...[
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: _kDivider,
                                  ),
                                  _buildEntryRow(entry, s),
                                ],
                              ],
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 14 * s),

                      // Proje kaydı
                      _Section(
                        scale: s,
                        icon: Icons.info_outline,
                        label: 'PROJE KAYDI',
                        child: Padding(
                          padding: EdgeInsets.only(top: 14 * s),
                          child: Column(
                            children: [
                              _InfoRow(
                                scale: s,
                                label: 'Oluşturulma Tarihi',
                                value: _fmtFull(project.createdAt),
                              ),
                              if (project.deadline != null) ...[
                                SizedBox(height: 12 * s),
                                _InfoRow(
                                  scale: s,
                                  label: 'Teslim Tarihi',
                                  value: _fmtFull(project.deadline!),
                                ),
                              ],
                              SizedBox(height: 12 * s),
                              _InfoRow(
                                scale: s,
                                label: 'Proje ID',
                                value: _projectCode,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14 * s),

                      // Anlaşılan ücret — sadece rakam, açıklama yok.
                      _buildAgreedPriceBox(project, s),

                      SizedBox(height: 120 * s),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Alt eylem çubuğu ────────────────────────────────────────────────
        bottomNavigationBar: _buildBottomBar(s),
      ),
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
              size: 15 * s,
              weight: FontWeight.w700,
              color: _kInk,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBriefGrid(ProjectModel p, double s) {
    final items = <_GridItem>[];
    if (p.shootingType != null && p.shootingType!.isNotEmpty) {
      items.add(_GridItem(
        icon: Icons.movie_creation_outlined,
        label: 'Çekim Türü',
        value: p.shootingType!,
      ));
    }
    if (p.vibes != null && p.vibes!.isNotEmpty) {
      items.add(_GridItem(
        icon: Icons.show_chart_rounded,
        label: 'Duygu',
        value: p.vibes!.join(', '),
      ));
    }
    if (p.dateRange != null && p.dateRange!.isNotEmpty) {
      items.add(_GridItem(
        icon: Icons.calendar_today_outlined,
        label: 'Çekim Tarihi',
        value: p.dateRange!,
      ));
    }
    if (p.deliveryTime != null && p.deliveryTime!.isNotEmpty) {
      items.add(_GridItem(
        icon: Icons.access_time_outlined,
        label: 'Teslim Süresi',
        value: p.deliveryTime!,
      ));
    }
    if (p.budget > 0) {
      items.add(_GridItem(
        icon: Icons.payments_outlined,
        label: 'Bütçe',
        value: '${p.budget.toStringAsFixed(0)} ₺',
      ));
    }
    if (p.location != null && p.location!.isNotEmpty) {
      items.add(_GridItem(
        icon: Icons.location_on_outlined,
        label: 'Lokasyon',
        value: p.location!,
      ));
    }

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
            return Expanded(child: _GridCell(scale: s, item: rowItems[j]));
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

  Widget _buildClientSection(double s) {
    final loading = controller.loadingClient.value;
    final client = controller.client.value;

    return _Section(
      scale: s,
      icon: Icons.person_outline,
      label: 'İŞİ VEREN',
      child: Padding(
        padding: EdgeInsets.only(top: 10 * s),
        child: loading
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16 * s),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _kGold,
                  ),
                ),
              )
            : Row(
                children: [
                  Container(
                    width: 42 * s,
                    height: 42 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kMuted.withValues(alpha: 0.3),
                      image: DecorationImage(
                        image: avatarImageProvider(
                          client?.avatarUrl ??
                              placeholderAvatarFor(
                                  client?.gender, client?.id ?? 'client'),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: Text(
                      client?.fullName ?? 'Müşteri',
                      style: _ui(
                        size: 11 * s,
                        weight: FontWeight.w600,
                        color: _kBlack,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.openChat,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * s,
                        vertical: 8 * s,
                      ),
                      color: _kGold.withValues(alpha: 0.15),
                      child: Text(
                        'Mesaj',
                        style: _ui(
                          size: 9 * s,
                          weight: FontWeight.w700,
                          color: _kBlack,
                          spacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBottomBar(double s) {
    return Container(
      padding: EdgeInsets.fromLTRB(16 * s, 12 * s, 16 * s, 28 * s),
      decoration: BoxDecoration(
        color: _kCream,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
      ),
      child: Obx(() => GestureDetector(
            onTap: controller.isOpeningChat.value ? null : controller.openChat,
            child: Container(
              height: 52 * s,
              color: _kGold,
              alignment: Alignment.center,
              child: controller.isOpeningChat.value
                  ? SizedBox(
                      width: 18 * s,
                      height: 18 * s,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 17 * s, color: Colors.white),
                        SizedBox(width: 6 * s),
                        Text(
                          'Müşteriyle Mesajlaş',
                          style: _ui(
                            size: 11 * s,
                            weight: FontWeight.w700,
                            color: Colors.white,
                            spacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          )),
    );
  }

  // ── İlerleme satırı (görsel gövde, hem sabit hem gerçek kayıt için) ─────────
  Widget _milestoneRowBody(String title, String timeLabel, String subtitle, double s) {
    return Padding(
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
                  '$title · $timeLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _ui(
                    size: 11 * s,
                    weight: FontWeight.w700,
                    color: _kBlack,
                    spacing: 0.2,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 3 * s),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ui(
                      size: 9 * s,
                      weight: FontWeight.w600,
                      color: _kGold,
                      spacing: 0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Brief Onayı — otomatik oluşan, silinemeyen/düzenlenemeyen ilk kalem.
  Widget _buildSyntheticRow(_Milestone m, double s) {
    return _milestoneRowBody(m.title, m.timeLabel, m.subtitle, s);
  }

  // Freelancer'ın Firestore'a yazdığı gerçek ilerleme kaydı — kaydırarak sil,
  // dokununca düzenle.
  Widget _buildEntryRow(ProgressEntryModel entry, double s) {
    return _SwipeToDeleteRow(
      key: ValueKey(entry.id),
      scale: s,
      onDelete: () => controller.deleteProgress(entry),
      onTap: () => _openMilestoneSheet(existing: entry),
      child: _milestoneRowBody(
        entry.title,
        _fmtFull(entry.createdAt),
        entry.description,
        s,
      ),
    );
  }

  // ── İlerleme ekle / düzenle bottomsheet ────────────────────────────────────
  Future<void> _openMilestoneSheet({ProgressEntryModel? existing}) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

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
                style: _display(
                  size: 22 * s,
                  weight: FontWeight.w600,
                  color: _kInk,
                ),
              ),
              SizedBox(height: 20 * s),
              Text(
                'BAŞLIK',
                style: _ui(
                  size: 8 * s,
                  weight: FontWeight.w700,
                  color: _kBlack,
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
                style: _ui(
                  size: 8 * s,
                  weight: FontWeight.w700,
                  color: _kBlack,
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
                onTap: () async {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  final desc = descCtrl.text.trim();
                  if (existing != null) {
                    await controller.updateProgress(existing, title, desc);
                  } else {
                    await controller.addProgress(title, desc);
                  }
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  height: 52 * s,
                  color: _kGold,
                  alignment: Alignment.center,
                  child: Text(
                    'KAYDET',
                    style: _ui(
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

// ── İlerleme noktası ──────────────────────────────────────────────────────────
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
      style: _ui(size: 11 * s, color: _kBlack, spacing: 0.2),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: _ui(size: 11 * s, color: _kBlack, spacing: 0.2),
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
                  style: _ui(
                    size: 8 * s,
                    weight: FontWeight.w700,
                    color: _kBlack,
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
                item.label.toUpperCaseTr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _ui(size: 7 * s, color: _kBlack, spacing: 0.8),
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * s),
        Text(
          item.value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _ui(
            size: 10 * s,
            weight: FontWeight.w700,
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
