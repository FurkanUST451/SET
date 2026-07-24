import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/avatar_image.dart';
import '../../../../data/dummy/dummy_data.dart';
import '../../../../data/models/work_model.dart';
import '../../../app/works_controller.dart';
import 'work_video_player_view.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB); // arka plan
const _kGold = Color(0xFFD9A84E); // kritik / vurgu altın tonu
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // mono etiket fontu - tam siyah
const _kDivider = Color(0x12000000);
const _kThumbTop = Color(0xFF262430);
const _kThumbBot = Color(0xFF141219);

// ─── Tipografi yardımcıları ───────────────────────────────────────────────────
TextStyle _serif({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
  bool italic = false,
  double spacing = 0,
}) =>
    GoogleFonts.cormorantGaramond(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );

TextStyle _mono({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
}) =>
    GoogleFonts.spaceMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: spacing,
    );

// ─── UI-only türetilmiş etiketler (dummy veriye ek meta, modele dokunmadan) ────
const _kTimeAgo = ['2S ÖNCE', '5S ÖNCE', '1G ÖNCE', '3G ÖNCE', '1H ÖNCE', '2H ÖNCE'];
const _kDurations = ['01:42', '00:58', '02:15', '01:10', '03:04', '01:33'];

String _formatFor(WorkType t) {
  switch (t) {
    case WorkType.video:
      return 'PRORES';
    case WorkType.photo:
      return 'RAW';
    case WorkType.cgiVfx:
      return 'EXR';
    case WorkType.graphic:
      return 'PSD';
    case WorkType.sound:
      return 'WAV';
  }
}

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
    if (createdAt != null) {
      final diff = DateTime.now().difference(createdAt);
      if (diff.inHours < 1) return '${diff.inMinutes < 1 ? 1 : diff.inMinutes}DK ÖNCE';
      if (diff.inDays < 1) return '${diff.inHours}S ÖNCE';
      if (diff.inDays < 7) return '${diff.inDays}G ÖNCE';
      return '${(diff.inDays / 7).floor()}H ÖNCE';
    }
    final idx = DummyData.works.indexWhere((w) => w.id == work.id);
    return _kTimeAgo[(idx < 0 ? 0 : idx) % _kTimeAgo.length];
  }

  String _durationFor(WorkModel work) {
    if (work.createdAt != null) return '';
    final idx = DummyData.works.indexWhere((w) => w.id == work.id);
    return _kDurations[(idx < 0 ? 0 : idx) % _kDurations.length];
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
          child: Obx(() {
            final works = _filtered(_worksController.works);
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildTopStrip(s),
                ),
                SliverToBoxAdapter(
                  child: _Header(scale: s),
                ),
                SliverToBoxAdapter(
                  child: _FilterBar(
                    scale: s,
                    selected: _filter,
                    onSelect: (t) => setState(() => _filter = t),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(26 * s, 10 * s, 26 * s, 130 * s),
                  sliver: SliverList.separated(
                    itemCount: works.length,
                    separatorBuilder: (_, _) => const Divider(
                        height: 1, thickness: 1, color: _kDivider),
                    itemBuilder: (_, i) {
                      final work = works[i];
                      return _WorkCard(
                        scale: s,
                        work: work,
                        timeAgo: _timeAgoFor(work),
                        duration: _durationFor(work),
                        format: _formatFor(work.type),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
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
            style: _mono(size: 8 * s, color: _kBlack, spacing: 2),
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
          // "neler" — serif italic, muted
          Text(
            'neler',
            style: _serif(
                size: 27 * s,
                weight: FontWeight.w500,
                color: _kMuted,
                italic: true),
          ),
          // "YAPTIK?" — büyük serif, ? altın
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: 'YAPTIK',
                style: _serif(
                    size: 52 * s,
                    weight: FontWeight.w600,
                    color: _kInk,
                    height: 0.95,
                    spacing: 1),
              ),
              TextSpan(
                text: '?',
                style: _serif(
                    size: 52 * s,
                    weight: FontWeight.w600,
                    color: _kGold,
                    height: 0.95),
              ),
            ]),
          ),
          SizedBox(height: 20 * s),
          Text(
            'SETTEKİLERİN SON İŞLERİ',
            style: _mono(size: 8 * s, color: _kBlack, spacing: 2),
          ),
        ],
      ),
    );
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
          ...WorkType.values.map((t) => _FilterTab(
                scale: s,
                label: t.label.toUpperCase(),
                selected: selected == t,
                onTap: () => onSelect(t),
              )),
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
              style: _mono(
                size: 9 * s,
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
    required this.duration,
    required this.format,
  });

  final double scale;
  final WorkModel work;
  final String timeAgo;
  final String duration;
  final String format;


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
                      style: _serif(
                          size: 14 * s,
                          weight: FontWeight.w600,
                          color: _kInk),
                    ),
                    SizedBox(height: 3 * s),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: work.type.label.toUpperCase(),
                          style: _mono(
                              size: 8 * s,
                              weight: FontWeight.w700,
                              color: _kGold,
                              spacing: 1),
                        ),
                        TextSpan(
                          text: '  ·  «${work.title.toUpperCase()}»',
                          style: _mono(
                              size: 8 * s, color: _kBlack, spacing: 1),
                        ),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12 * s),
              Text(
                timeAgo,
                style: _mono(size: 8 * s, color: _kBlack, spacing: 1),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          // Kapak
          GestureDetector(
            onTap: work.isVideo && (work.mediaUrl?.isNotEmpty ?? false)
                ? () => Get.to(() => WorkVideoPlayerView(
                      videoUrl: work.mediaUrl!,
                      title: work.title,
                      thumbnailUrl: work.thumbnailUrl,
                    ))
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
          // Alt bilgi: başlık + süre·format
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  work.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _serif(
                      size: 13 * s,
                      weight: FontWeight.w500,
                      color: _kInk,
                      italic: true),
                ),
              ),
              SizedBox(width: 12 * s),
              Text(
                duration.isEmpty ? format : '$duration · $format',
                style: _mono(size: 8 * s, color: _kBlack, spacing: 1),
              ),
            ],
          ),
          if (work.description != null && work.description!.isNotEmpty) ...[
            SizedBox(height: 8 * s),
            Text(
              work.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.2),
            ),
          ],
          SizedBox(height: 18 * s),
          // Aksiyonlar
          Row(
            children: [
              _IconCount(
                scale: s,
                icon: Icons.favorite_border_rounded,
                count: work.likes,
              ),
              SizedBox(width: 28 * s),
              _IconCount(
                scale: s,
                icon: Icons.mode_comment_outlined,
                count: work.comments,
              ),
              const Spacer(),
              Icon(Icons.bookmark_border_rounded,
                  size: 16 * s, color: _kTaupe),
            ],
          ),
        ],
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
    final isMotion = isVideo ||
        type == WorkType.video ||
        type == WorkType.cgiVfx;
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
                    Icon(Icons.crop_original_rounded,
                        size: 28 * s,
                        color: Colors.white.withValues(alpha: 0.16)),
                    SizedBox(height: 6 * s),
                    Text(
                      'ÖNİZLEME YOK',
                      style: _mono(
                          size: 7 * s,
                          color: Colors.white.withValues(alpha: 0.22),
                          spacing: 2),
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
      child: Icon(Icons.play_arrow_rounded,
          color: Colors.white, size: 28 * s),
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
          _format(count),
          style: _mono(size: 9 * s, color: _kBlack, spacing: 0.5),
        ),
      ],
    );
  }

  String _format(int n) {
    if (n >= 1000) {
      final k = n / 1000;
      return k % 1 == 0 ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    }
    return n.toString();
  }
}
