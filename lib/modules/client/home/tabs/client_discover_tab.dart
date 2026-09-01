import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../../core/utils/avatar_image.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/turkish_case.dart';
import '../../../../data/models/work_model.dart';
import '../../../app/works_controller.dart';
import 'work_comments_sheet.dart';
import 'work_video_player_view.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB); // arka plan
const _kGold = Color(0xFFD9A84E); // kritik / vurgu altın tonu
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kDivider = Color(0x12000000);
const _kDanger = Color(
  0xFFB3402A,
); // yıkıcı aksiyonlar (sil vb.) — paletle uyumlu toprak kırmızısı
const _kThumbTop = Color(0xFF262430);
const _kThumbBot = Color(0xFF141219);

// Paylaşım linki için markalı izleme sayfası — ham Storage linki yerine bu
// paylaşılır (bkz. functions/index.js watchPage). Kısa, tokensız ve
// paylaşıldığında link önizleme kartı (başlık + kapak görseli) gösterir.
const _kWatchBaseUrl = 'https://sett-451.web.app/w';

// ─── Tipografi yardımcıları ───────────────────────────────────────────────────
TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
  bool italic = false,
  double? spacing,
}) => AppFonts.display(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: spacing,
  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
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

class ClientDiscoverTab extends StatefulWidget {
  const ClientDiscoverTab({super.key});

  @override
  State<ClientDiscoverTab> createState() => _ClientDiscoverTabState();
}

class _ClientDiscoverTabState extends State<ClientDiscoverTab> {
  // null = "TÜMÜ" filtresi aktif
  WorkType? _filter;

  final WorksController _worksController = Get.find<WorksController>();

  List<WorkModel> _filtered(List<WorkModel> all) {
    if (_filter == null) return all;
    return all.where((w) => w.type == _filter).toList();
  }

  String _timeAgoFor(WorkModel work) {
    final createdAt = work.createdAt;
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt);
    if (diff.inHours < 1)
      return '${diff.inMinutes < 1 ? 1 : diff.inMinutes}DK ÖNCE';
    if (diff.inDays < 1) return '${diff.inHours}S ÖNCE';
    if (diff.inDays < 7) return '${diff.inDays}G ÖNCE';
    return '${(diff.inDays / 7).floor()}H ÖNCE';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();

    return ColoredBox(
      color: _kCream,
      child: MediaQuery.withNoTextScaling(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopStrip(s),
              Expanded(
                child: Obx(() {
                  final works = _filtered(_worksController.works);
                  return RefreshIndicator(
                    color: _kGold,
                    backgroundColor: _kCream,
                    onRefresh: _worksController.reload,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: _Header(scale: s)),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _FilterBarHeaderDelegate(
                            scale: s,
                            selected: _filter,
                            onSelect: (t) => setState(() => _filter = t),
                          ),
                        ),
                        if (works.isEmpty)
                          SliverToBoxAdapter(child: _EmptyState(scale: s))
                        else
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              26 * s,
                              10 * s,
                              26 * s,
                              130 * s,
                            ),
                            sliver: SliverList.separated(
                              itemCount: works.length,
                              separatorBuilder: (_, _) => const Divider(
                                height: 1,
                                thickness: 1,
                                color: _kDivider,
                              ),
                              itemBuilder: (_, i) {
                                final work = works[i];
                                return _WorkCard(
                                  scale: s,
                                  work: work,
                                  timeAgo: _timeAgoFor(work),
                                  controller: _worksController,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sayfa tepesi — SET · KEŞFET + tam genişlik ayraç ──────────────
  Widget _buildTopStrip(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(26 * s, 6 * s, 26 * s, 12 * s),
          child: Text(
            'SET · KEŞFET',
            style: _ui(size: 10 * s, color: _kBlack, spacing: 2),
          ),
        ),
        Container(height: 1, color: _kDivider),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HEADER — promo + "neler YAPTIK?" editoryal başlık
// ─────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.fromLTRB(26 * s, 22 * s, 18 * s, 28 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "neler" — display italic, muted
          Text(
            'neler',
            style: _display(
              size: 27 * s,
              weight: FontWeight.w500,
              color: _kMuted,
              italic: true,
            ),
          ),
          // "YAPTIK?" — büyük display, ? altın
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'YAPTIK',
                  style: _display(
                    size: 52 * s,
                    weight: FontWeight.w600,
                    color: _kInk,
                    height: 0.95,
                    spacing: 1,
                  ),
                ),
                TextSpan(
                  text: '?',
                  style: _display(
                    size: 52 * s,
                    weight: FontWeight.w600,
                    color: _kGold,
                    height: 0.95,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * s),
          Text(
            'SETTEKİLERİN SON İŞLERİ',
            style: _ui(size: 10 * s, color: _kBlack, spacing: 2),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BOŞ DURUM — henüz yüklenmiş gerçek iş yokken gösterilir
// ─────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.fromLTRB(26 * s, 40 * s, 26 * s, 80 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HENÜZ PAYLAŞIM YOK',
            style: _ui(size: 10 * s, color: _kBlack, spacing: 1.5),
          ),
          SizedBox(height: 10 * s),
          Text(
            'Setteki ekipler ilk işlerini yüklediğinde burada görünecek.',
            style: _ui(size: 9 * s, color: _kTaupe, spacing: 0.2),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// FILTER BAR — sabit üst şeridin hemen altına sabitlenen (pinned) sliver başlık
// ─────────────────────────────────────────────────────────────────
class _FilterBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _FilterBarHeaderDelegate({
    required this.scale,
    required this.selected,
    required this.onSelect,
  });

  final double scale;
  final WorkType? selected;
  final ValueChanged<WorkType?> onSelect;

  double get _height => 46 * scale;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _kCream,
        border: Border(bottom: BorderSide(color: _kDivider)),
      ),
      child: _FilterBar(scale: scale, selected: selected, onSelect: onSelect),
    );
  }

  @override
  bool shouldRebuild(covariant _FilterBarHeaderDelegate oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.selected != selected ||
        oldDelegate.onSelect != onSelect;
  }
}

// ─────────────────────────────────────────────────────────────────
// FILTER BAR — metin sekmeleri, aktif olanda altın nokta
// ─────────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.scale,
    required this.selected,
    required this.onSelect,
  });

  final double scale;
  final WorkType? selected;
  final ValueChanged<WorkType?> onSelect;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 46 * s,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 26 * s),
        children: [
          _FilterTab(
            scale: s,
            label: 'TÜMÜ',
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          ...WorkType.values.map(
            (t) => _FilterTab(
              scale: s,
              label: t.label.toUpperCaseTr(),
              selected: selected == t,
              onTap: () => onSelect(t),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
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
              label,
              style: _ui(
                size: 11 * s,
                weight: selected ? FontWeight.w700 : FontWeight.w400,
                color: _kBlack,
                spacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// WORK CARD — kimlik satırı + kapak + alt bilgi + aksiyonlar
// ─────────────────────────────────────────────────────────────────
class _WorkCard extends StatelessWidget {
  const _WorkCard({
    required this.scale,
    required this.work,
    required this.timeAgo,
    required this.controller,
  });

  final double scale;
  final WorkModel work;
  final String timeAgo;
  final WorksController controller;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kimlik satırı
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  placeholderAvatarFor(null, work.studio),
                  width: 38 * s,
                  height: 38 * s,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 14 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      work.studio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _display(
                        size: 19 * s,
                        weight: FontWeight.w600,
                        color: _kInk,
                      ),
                    ),
                    SizedBox(height: 3 * s),
                    Text(
                      work.type.label.toUpperCaseTr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _ui(
                        size: 10 * s,
                        weight: FontWeight.w700,
                        color: _kGold,
                        spacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12 * s),
              Text(
                timeAgo,
                style: _ui(size: 8 * s, color: _kBlack, spacing: 1),
              ),
              SizedBox(width: 4 * s),
              _WorkMenuButton(scale: s, work: work, controller: controller),
            ],
          ),
          SizedBox(height: 16 * s),
          // Başlık
          Text(
            work.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _display(
              size: 13 * s,
              weight: FontWeight.w500,
              color: _kInk,
              italic: true,
            ),
          ),
          if (work.description != null && work.description!.isNotEmpty) ...[
            SizedBox(height: 8 * s),
            _ExpandableDescription(
              scale: s,
              text: work.description!,
              style: _ui(size: 9 * s, color: _kTaupe, spacing: 0.2),
            ),
          ],
          SizedBox(height: 16 * s),
          // Kapak
          GestureDetector(
            onTap: work.isVideo && (work.mediaUrl?.isNotEmpty ?? false)
                ? () => Get.to(
                    () => WorkVideoPlayerView(
                      videoUrl: work.mediaUrl!,
                      title: work.title,
                      thumbnailUrl: work.thumbnailUrl,
                    ),
                  )
                : null,
            child: _CoverPlaceholder(
              scale: s,
              type: work.type,
              coverImage: work.coverImage,
              mediaUrl: work.mediaUrl,
              thumbnailUrl: work.thumbnailUrl,
              isVideo: work.isVideo,
            ),
          ),
          SizedBox(height: 18 * s),
          // Aksiyonlar
          Row(
            children: [
              _LikeAction(scale: s, work: work, controller: controller),
              SizedBox(width: 28 * s),
              _CommentAction(scale: s, work: work),
              SizedBox(width: 28 * s),
              _ShareAction(scale: s, work: work),
              const Spacer(),
              Icon(Icons.bookmark_border_rounded, size: 16 * s, color: _kTaupe),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// AÇIKLAMA — belirli bir satır sayısını aşan metinler kısaltılır ve
// altına "Devamını oku" eklenir; dokunulunca tüm metin açılır.
// ─────────────────────────────────────────────────────────────────
class _ExpandableDescription extends StatefulWidget {
  const _ExpandableDescription({
    required this.scale,
    required this.text,
    required this.style,
  });

  final double scale;
  final String text;
  final TextStyle style;

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  static const _kCollapsedMaxLines = 2;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    if (_expanded) {
      return Text(widget.text, style: widget.style);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: _kCollapsedMaxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        if (!painter.didExceedMaxLines) {
          return Text(widget.text, style: widget.style);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: _kCollapsedMaxLines,
              overflow: TextOverflow.ellipsis,
              style: widget.style,
            ),
            SizedBox(height: 4 * s),
            GestureDetector(
              onTap: () => setState(() => _expanded = true),
              behavior: HitTestBehavior.opaque,
              child: Text(
                'DEVAMINI OKU',
                style: _ui(
                  size: 10 * s,
                  weight: FontWeight.w700,
                  color: _kGold,
                  spacing: 1,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// GÖNDERİ MENÜSÜ — dikey 3 nokta: herkes bildirebilir, sahibi silebilir.
// ─────────────────────────────────────────────────────────────────
enum _WorkMenuAction { report, delete }

class _WorkMenuButton extends StatelessWidget {
  const _WorkMenuButton({
    required this.scale,
    required this.work,
    required this.controller,
  });

  final double scale;
  final WorkModel work;
  final WorksController controller;

  bool get _isOwner =>
      work.freelancerId != null &&
      work.freelancerId == controller.currentUserId;

  Future<void> _handleReport(BuildContext context) async {
    final reason = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => const _ReportReasonDialog(),
    );

    final trimmed = reason?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    final ok = await controller.reportWork(work, reason: trimmed);
    if (ok && context.mounted) {
      Get.snackbar(
        'Teşekkürler',
        'Gönderi bildirildi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => _EditorialDialog(
        title: 'GÖNDERİYİ SİL',
        content: Text(
          'Bu gönderiyi kalıcı olarak silmek istediğine emin misin? '
          'Bu işlem geri alınamaz.',
          style: _ui(
            size: 9,
            color: _kTaupe,
            spacing: 0.2,
          ).copyWith(height: 1.5),
        ),
        actions: [
          _EditorialDialogAction(
            label: 'VAZGEÇ',
            color: _kTaupe,
            onTap: () => Navigator.of(ctx).pop(false),
          ),
          _EditorialDialogAction(
            label: 'SİL',
            color: _kDanger,
            onTap: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await controller.deleteWork(work.id);
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return PopupMenuButton<_WorkMenuAction>(
      padding: EdgeInsets.zero,
      color: _kCream,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        side: BorderSide(color: _kDivider),
      ),
      icon: Icon(Icons.more_vert_rounded, size: 18 * s, color: _kTaupe),
      onSelected: (action) {
        switch (action) {
          case _WorkMenuAction.report:
            _handleReport(context);
          case _WorkMenuAction.delete:
            _handleDelete(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _WorkMenuAction.report,
          height: 40,
          child: Text(
            'GÖNDERİYİ BİLDİR',
            style: _ui(
              size: 10,
              weight: FontWeight.w600,
              color: _kInk,
              spacing: 1,
            ),
          ),
        ),
        if (_isOwner)
          PopupMenuItem(
            value: _WorkMenuAction.delete,
            height: 40,
            child: Text(
              'SİL',
              style: _ui(
                size: 10,
                weight: FontWeight.w600,
                color: _kDanger,
                spacing: 1,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BİLDİRİM SEBEBİ DİYALOĞU — TextEditingController'ı State içinde tutup
// dispose'unu widget gerçekten unmount olurken (dialog kapanış animasyonu
// bittiğinde) yapar. showDialog'un future'ı pop() çağrılır çağrılmaz
// tamamlandığından, controller'ı doğrudan orada manuel dispose etmek
// TextField hâlâ ekrandan çıkış animasyonundayken kullanılmasına ve
// "_dependents.isEmpty" assertion'ına yol açıyordu.
// ─────────────────────────────────────────────────────────────────
class _ReportReasonDialog extends StatefulWidget {
  const _ReportReasonDialog();

  @override
  State<_ReportReasonDialog> createState() => _ReportReasonDialogState();
}

class _ReportReasonDialogState extends State<_ReportReasonDialog> {
  static const _kDefaultReportReason = 'Bu gönderiyi uygunsuz buluyorum';

  late final TextEditingController _textController = TextEditingController(
    text: _kDefaultReportReason,
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditorialDialog(
      title: 'GÖNDERİYİ BİLDİR',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bu içeriği neden bildiriyorsun? Mesajı dilediğin gibi düzenleyebilirsin.',
            style: _ui(
              size: 9,
              color: _kTaupe,
              spacing: 0.2,
            ).copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: _kDivider)),
            child: TextField(
              controller: _textController,
              autofocus: true,
              textAlignVertical: TextAlignVertical.top,
              minLines: 3,
              maxLines: 5,
              maxLength: 500,
              cursorColor: _kGold,
              style: _ui(
                size: 10,
                color: _kBlack,
                spacing: 0.2,
              ).copyWith(height: 1.5),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
                counterText: '',
                hintText: 'Bildirme sebebini yaz...',
                hintStyle: _ui(size: 10, color: _kTaupe, spacing: 0.2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        _EditorialDialogAction(
          label: 'VAZGEÇ',
          color: _kTaupe,
          onTap: () => Navigator.of(context).pop(),
        ),
        _EditorialDialogAction(
          label: 'GÖNDER',
          color: _kGold,
          onTap: () => Navigator.of(context).pop(_textController.text),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EDİTORYAL DİYALOG KABI — uygulamanın kendi paleti/tipografisiyle
// (bkz. dosya başındaki _kCream/_kGold/... ve _display/_ui) çizilen,
// Material'ın varsayılan AlertDialog'u yerine geçen ortak kabuk.
// Font yalnızca _ui/_display üzerinden geldiği için ileride uygulama
// genelinde font değişirse buradaki diyaloglar da otomatik güncellenir.
// ─────────────────────────────────────────────────────────────────
class _EditorialDialogAction {
  const _EditorialDialogAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _EditorialDialog extends StatelessWidget {
  const _EditorialDialog({
    required this.title,
    required this.content,
    required this.actions,
  });

  final String title;
  final Widget content;
  final List<_EditorialDialogAction> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _kCream,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: _ui(
                size: 10,
                weight: FontWeight.w700,
                color: _kBlack,
                spacing: 1.5,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 18),
              height: 1,
              color: _kDivider,
            ),
            content,
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final action in actions)
                  GestureDetector(
                    onTap: action.onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Text(
                        action.label,
                        style: _ui(
                          size: 10,
                          weight: FontWeight.w700,
                          color: action.color,
                          spacing: 1.2,
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

const _kThumbGradient = DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_kThumbTop, _kThumbBot],
    ),
  ),
);

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({
    required this.scale,
    required this.type,
    required this.coverImage,
    this.mediaUrl,
    this.thumbnailUrl,
    this.isVideo = false,
  });

  final double scale;
  final WorkType type;
  final String? coverImage;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final isMotion =
        isVideo || type == WorkType.video || type == WorkType.cgiVfx;
    // Video için üretilen JPEG önizleme (thumbnailUrl), foto işler için ise
    // mediaUrl'in kendisi kapak görseli olarak kullanılır.
    final networkImageUrl = isVideo ? thumbnailUrl : mediaUrl;
    final hasNetworkImage = networkImageUrl?.isNotEmpty ?? false;
    final hasAsset = coverImage != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14 * s),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasNetworkImage)
              CachedNetworkImage(
                imageUrl: networkImageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => _kThumbGradient,
                errorWidget: (_, _, _) => _kThumbGradient,
              )
            else if (hasAsset)
              Image.asset(coverImage!, fit: BoxFit.cover)
            else
              _kThumbGradient,
            if (!hasNetworkImage && !hasAsset)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.crop_original_rounded,
                      size: 28 * s,
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                    SizedBox(height: 6 * s),
                    Text(
                      'ÖNİZLEME YOK',
                      style: _ui(
                        size: 10 * s,
                        color: Colors.white.withValues(alpha: 0.22),
                        spacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            if (isMotion) Center(child: _PlayButton(scale: s)),
          ],
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 52 * s,
      height: 52 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1.2,
        ),
      ),
      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28 * s),
    );
  }
}

class _IconCount extends StatelessWidget {
  const _IconCount({
    required this.scale,
    required this.icon,
    required this.count,
  });

  final double scale;
  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16 * s, color: _kTaupe),
        SizedBox(width: 7 * s),
        Text(
          Formatters.compactCount(count),
          style: _ui(size: 9 * s, color: _kBlack, spacing: 0.5),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BEĞENİ — isLiked durumu Firestore'dan (works/{id}/likes/{uid} doküman varlığı)
// canlı akar; sayaç ise works.likes alanından gelir ve Cloud Function
// tetikleyicisi FieldValue.increment ile güncelleyene kadar küçük bir
// gecikme olabileceğinden, kendi dokunuşumuzun etkisini o an gösterebilmek
// için tek adımlık bir optimistic delta tutulur (sunucudan gerçek sayaç
// gelince otomatik bırakılır).
// ─────────────────────────────────────────────────────────────────
class _LikeAction extends StatefulWidget {
  const _LikeAction({
    required this.scale,
    required this.work,
    required this.controller,
  });

  final double scale;
  final WorkModel work;
  final WorksController controller;

  @override
  State<_LikeAction> createState() => _LikeActionState();
}

class _LikeActionState extends State<_LikeAction> {
  bool _isToggling = false;
  int _optimisticDelta = 0;

  // StreamBuilder yeni bir Stream instance'ı her build'de yeniden abone
  // olur. Bu ekrandaki herhangi bir işin beğeni/yorum sayacı değiştiğinde
  // tüm liste (Obx) yeniden build edildiğinden, stream'i work.id sabit
  // kaldığı sürece burada önbelleğe almazsak her karttaki dinleyici
  // gereksiz yere kapanıp yeniden açılır.
  Stream<bool>? _likedStream;

  @override
  void initState() {
    super.initState();
    _syncLikedStream();
  }

  @override
  void didUpdateWidget(covariant _LikeAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.work.likes != oldWidget.work.likes) {
      _optimisticDelta = 0;
    }
    if (widget.work.id != oldWidget.work.id) {
      _syncLikedStream();
    }
  }

  void _syncLikedStream() {
    _likedStream = widget.work.isLive
        ? widget.controller.isLikedStream(widget.work.id)
        : null;
  }

  Future<void> _handleTap(bool isLiked) async {
    if (_isToggling) return;
    setState(() {
      _isToggling = true;
      _optimisticDelta = isLiked ? -1 : 1;
    });
    await widget.controller.toggleLike(widget.work.id, isLiked);
    if (mounted) setState(() => _isToggling = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final likedStream = _likedStream;
    if (likedStream == null) {
      return _IconCount(
        scale: s,
        icon: Icons.favorite_border_rounded,
        count: widget.work.likes,
      );
    }
    return StreamBuilder<bool>(
      stream: likedStream,
      builder: (context, snapshot) {
        final isLiked = snapshot.data ?? false;
        final count = widget.work.likes + _optimisticDelta;
        return GestureDetector(
          onTap: () => _handleTap(isLiked),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: _isToggling ? 0.82 : 1.0,
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                child: Icon(
                  isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 16 * s,
                  color: isLiked ? _kGold : _kTaupe,
                ),
              ),
              SizedBox(width: 7 * s),
              Text(
                Formatters.compactCount(count < 0 ? 0 : count),
                style: _ui(size: 9 * s, color: _kBlack, spacing: 0.5),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// YORUM — dokunulduğunda yorum sayfasını açar.
// ─────────────────────────────────────────────────────────────────
class _CommentAction extends StatelessWidget {
  const _CommentAction({required this.scale, required this.work});

  final double scale;
  final WorkModel work;

  @override
  Widget build(BuildContext context) {
    final icon = _IconCount(
      scale: scale,
      icon: Icons.mode_comment_outlined,
      count: work.comments,
    );
    if (!work.isLive) return icon;
    return GestureDetector(
      onTap: () => showWorkCommentsSheet(context, work),
      behavior: HitTestBehavior.opaque,
      child: icon,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// GÖNDER — işletim sisteminin native paylaşım sayfasını açar (WhatsApp, SMS, vb.) ve
// markalı izleme sayfasının linkini paylaşır — ham Storage linki değil.
// ─────────────────────────────────────────────────────────────────
class _ShareAction extends StatelessWidget {
  const _ShareAction({required this.scale, required this.work});

  final double scale;
  final WorkModel work;

  bool get _canShare => work.isLive && (work.mediaUrl?.isNotEmpty ?? false);

  Future<void> _share(BuildContext context) async {
    if (!_canShare) return;
    final url = '$_kWatchBaseUrl/${work.id}';

    // iPad/macOS'ta paylaşım sayfası bir popover olarak açılır ve nereden
    // açılacağını bilmesi için tıklanan öğenin ekran konumu gerekir.
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? (box.localToGlobal(Offset.zero) & box.size)
        : null;

    await SharePlus.instance.share(
      ShareParams(
        text: '${work.studio} — «${work.title}»\n$url',
        sharePositionOrigin: origin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final icon = Icon(Icons.share_outlined, size: 16 * s, color: _kTaupe);
    if (!_canShare) return icon;
    return GestureDetector(
      onTap: () => _share(context),
      behavior: HitTestBehavior.opaque,
      child: icon,
    );
  }
}
