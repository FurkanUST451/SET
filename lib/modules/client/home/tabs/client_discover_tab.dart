import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/dummy/dummy_data.dart';
import '../../../../data/models/work_model.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB); // arka plan
const _kGold = Color(0xFFD9A84E); // kritik / vurgu altın tonu
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
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
    case WorkType.vfx:
      return 'PRORES';
    case WorkType.photo:
      return 'RAW';
    case WorkType.cgi:
      return 'EXR';
    case WorkType.ai:
      return 'MP4';
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
  bool _promoVisible = true;

  List<WorkModel> get _works {
    if (_filter == null) return DummyData.works;
    return DummyData.works.where((w) => w.type == _filter).toList();
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
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  scale: s,
                  promoVisible: _promoVisible,
                  onDismissPromo: () =>
                      setState(() => _promoVisible = false),
                ),
              ),
              SliverToBoxAdapter(
                child: _FilterBar(
                  scale: s,
                  selected: _filter,
                  onSelect: (t) => setState(() => _filter = t),
                ),
              ),
              SliverToBoxAdapter(
                child: Divider(
                    height: 1, thickness: 1, color: _kDivider),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(26 * s, 10 * s, 26 * s, 130 * s),
                sliver: SliverList.separated(
                  itemCount: _works.length,
                  separatorBuilder: (_, _) => const Divider(
                      height: 1, thickness: 1, color: _kDivider),
                  itemBuilder: (_, i) {
                    final work = _works[i];
                    // Orijinal listedeki index'e göre sabit meta türet.
                    final baseIndex = DummyData.works.indexOf(work);
                    return _WorkCard(
                      scale: s,
                      work: work,
                      timeAgo: _kTimeAgo[baseIndex % _kTimeAgo.length],
                      duration: _kDurations[baseIndex % _kDurations.length],
                      format: _formatFor(work.type),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HEADER — promo + "neler YAPTIK?" editoryal başlık
// ─────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({
    required this.scale,
    required this.promoVisible,
    required this.onDismissPromo,
  });

  final double scale;
  final bool promoVisible;
  final VoidCallback onDismissPromo;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.fromLTRB(26 * s, 22 * s, 18 * s, 28 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (promoVisible) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yeni bir işi mi bitirdin?',
                        style: _mono(
                            size: 8 * s, color: _kTaupe, spacing: 0.3),
                      ),
                      SizedBox(height: 4 * s),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: 'Kadraja al, ',
                            style: _mono(
                                size: 8 * s, color: _kTaupe, spacing: 0.3),
                          ),
                          TextSpan(
                            text: 'buraya bırak.',
                            style: _mono(
                                size: 8 * s,
                                weight: FontWeight.w700,
                                color: _kGold,
                                spacing: 0.3),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onDismissPromo,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(6 * s),
                    child: Icon(Icons.close_rounded,
                        size: 18 * s, color: _kInk),
                  ),
                ),
              ],
            ),
            SizedBox(height: 48 * s),
          ],
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
            style: _mono(size: 8 * s, color: _kMuted, spacing: 2),
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
          children: [
            if (selected) ...[
              Container(
                width: 5 * s,
                height: 5 * s,
                decoration:
                    const BoxDecoration(color: _kGold, shape: BoxShape.circle),
              ),
              SizedBox(width: 6 * s),
            ],
            Text(
              label,
              style: _mono(
                size: 9 * s,
                weight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? _kInk : _kMuted,
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

  String get _initials {
    final parts = work.studio.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    final t = work.studio.trim();
    return t.substring(0, math.min(2, t.length)).toUpperCase();
  }

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
              Container(
                width: 38 * s,
                height: 38 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kGold.withValues(alpha: 0.10),
                  border: Border.all(
                      color: Colors.black.withValues(alpha: 0.12)),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: _mono(
                      size: 9 * s,
                      weight: FontWeight.w700,
                      color: _kInk,
                      spacing: 0.5),
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
                              size: 8 * s, color: _kMuted, spacing: 1),
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
                style: _mono(size: 8 * s, color: _kMuted, spacing: 1),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          // Kapak
          _CoverPlaceholder(scale: s, type: work.type, coverImage: work.coverImage),
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
                '$duration · $format',
                style: _mono(size: 8 * s, color: _kMuted, spacing: 1),
              ),
            ],
          ),
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

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({
    required this.scale,
    required this.type,
    required this.coverImage,
  });

  final double scale;
  final WorkType type;
  final String? coverImage;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final isMotion = type == WorkType.video ||
        type == WorkType.vfx ||
        type == WorkType.cgi;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14 * s),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (coverImage != null)
              Image.asset(coverImage!, fit: BoxFit.cover)
            else
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_kThumbTop, _kThumbBot],
                  ),
                ),
              ),
            if (coverImage == null)
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
          style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.5),
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
