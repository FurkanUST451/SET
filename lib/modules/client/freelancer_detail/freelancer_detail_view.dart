import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/freelancer_model.dart';
import '../../../widgets/video_viewer_page.dart';
import 'freelancer_detail_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kDivider = Color(0x12000000);
const _kCardBorder = Color(0x14000000);
const _kThumbTop = Color(0xFF3A342E);
const _kThumbBot = Color(0xFF211E1A);

double _scaleOf(BuildContext c) =>
    (MediaQuery.sizeOf(c).width / 390).clamp(0.85, 1.15).toDouble();

TextStyle _serif({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
}) =>
    GoogleFonts.cormorantGaramond(
        fontSize: size, fontWeight: weight, color: color, height: height);

TextStyle _mono({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
  double height = 1.4,
}) =>
    GoogleFonts.spaceMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height);

Widget _wordmark(double s) => RichText(
      text: TextSpan(children: [
        TextSpan(
          text: 'SE',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 18 * s,
              fontWeight: FontWeight.w700,
              color: _kInk,
              letterSpacing: 2.5),
        ),
        TextSpan(
          text: 'T',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 18 * s,
              fontWeight: FontWeight.w800,
              color: _kGold,
              letterSpacing: 2.5),
        ),
      ]),
    );

class FreelancerDetailView extends GetView<FreelancerDetailController> {
  const FreelancerDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    final f = controller.freelancer;
    final u = controller.user;
    final fName = f?.name.isNotEmpty == true ? f!.name : (u?.name ?? '');
    final fSurname =
        (f?.surname?.isNotEmpty == true) ? f!.surname! : (u?.surname ?? '');
    final name = fSurname.isNotEmpty
        ? '$fName $fSurname'
        : (fName.isNotEmpty ? fName : 'Freelancer');

    final reviewCount = (f?.experience ?? 3) * 18;
    final jobCount = (f?.experience ?? 3) * 12 + 15;
    final trustScore = ((f?.rating ?? 4.9) * 19.5).round();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _kCream,
        body: MediaQuery.withNoTextScaling(
          child: SafeArea(
            child: Column(
              children: [
                // Üst bar
                Padding(
                  padding: EdgeInsets.fromLTRB(8 * s, 6 * s, 8 * s, 6 * s),
                  child: Row(
                    children: [
                      _barIcon(s, Icons.chevron_left_rounded, () => Get.back<void>()),
                      const Spacer(),
                      _wordmark(s),
                      const Spacer(),
                      _barIcon(s, Icons.ios_share_outlined, () {}),
                      _barIcon(s, Icons.more_horiz_rounded, () {}),
                    ],
                  ),
                ),
                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, _) => [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(24 * s, 14 * s, 24 * s, 0),
                          child: Column(
                            children: [
                              // Avatar (keskin kare + online göstergesi)
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  SizedBox(
                                    width: 92 * s,
                                    height: 92 * s,
                                    child: f?.profileImageUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl: f!.profileImageUrl!,
                                            width: 92 * s,
                                            height: 92 * s,
                                            fit: BoxFit.cover,
                                            placeholder: (_, _) =>
                                                _avatarPlaceholder(s),
                                            errorWidget: (_, _, _) =>
                                                _avatarPlaceholder(s),
                                          )
                                        : _avatarPlaceholder(s),
                                  ),
                                  Positioned(
                                    bottom: 4 * s,
                                    right: 4 * s,
                                    child: Container(
                                      width: 12 * s,
                                      height: 12 * s,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6B8E5A),
                                        border: Border.all(
                                            color: _kCream, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14 * s),
                              Text(name,
                                  textAlign: TextAlign.center,
                                  style: _serif(
                                      size: 30 * s,
                                      weight: FontWeight.w600,
                                      color: _kInk)),
                              SizedBox(height: 5 * s),
                              Text(
                                'DİREKTÖR · ${(f?.categories.join(', ') ?? '').toUpperCase()}',
                                textAlign: TextAlign.center,
                                style: _mono(
                                    size: 8 * s, color: _kTaupe, spacing: 1),
                              ),
                              SizedBox(height: 12 * s),
                              Text(
                                '★ ${f?.rating.toStringAsFixed(1) ?? '4.9'} ($reviewCount)  ·  ${(f?.experience ?? 3) * 8 + 20} yaş',
                                style: _mono(
                                    size: 9 * s, color: _kInk, spacing: 0.3),
                              ),
                              SizedBox(height: 4 * s),
                              Text(
                                '${f?.location ?? 'İstanbul'}, Türkiye  ·  $jobCount İş',
                                style: _mono(
                                    size: 9 * s, color: _kTaupe, spacing: 0.3),
                              ),
                              SizedBox(height: 2 * s),
                              Text('${f?.experience ?? 3} Yıl Deneyim',
                                  style: _mono(
                                      size: 9 * s, color: _kTaupe, spacing: 0.3)),
                              SizedBox(height: 20 * s),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: controller.openChat,
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        height: 50 * s,
                                        color: _kInk,
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.circle_outlined,
                                                color: Colors.white,
                                                size: 14 * s),
                                            SizedBox(width: 8 * s),
                                            Text('MESAJ GÖNDER',
                                                style: _mono(
                                                    size: 9 * s,
                                                    weight: FontWeight.w700,
                                                    color: Colors.white,
                                                    spacing: 1)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12 * s),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: controller.sendOffer,
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        height: 50 * s,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border:
                                              Border.all(color: _kGold, width: 1.4),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text('TEKLİF GÖNDER',
                                            style: _mono(
                                                size: 9 * s,
                                                weight: FontWeight.w700,
                                                color: _kGold,
                                                spacing: 1)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20 * s),
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _TabHeaderDelegate(
                          TabBar(
                            tabs: const [
                              Tab(text: 'İşler'),
                              Tab(text: 'Hakkında'),
                              Tab(text: 'Yorumlar'),
                            ],
                            labelStyle: _mono(
                                size: 10 * s,
                                weight: FontWeight.w700,
                                color: _kInk,
                                spacing: 1),
                            unselectedLabelStyle:
                                _mono(size: 10 * s, color: _kMuted, spacing: 1),
                            labelColor: _kInk,
                            unselectedLabelColor: _kMuted,
                            indicatorColor: _kGold,
                            indicatorWeight: 2,
                            dividerColor: _kDivider,
                          ),
                        ),
                      ),
                    ],
                    body: TabBarView(
                      children: [
                        _IslerTab(
                            freelancer: f, reviewCount: reviewCount),
                        _HakkindaTab(bio: f?.bio ?? '', trustScore: trustScore, freelancer: f),
                        _YorumlarTab(reviewCount: reviewCount),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _barIcon(double s, IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.all(8 * s),
          child: Icon(icon, size: 22 * s, color: _kInk),
        ),
      );
}

Widget _avatarPlaceholder(double s) => Container(
      width: 92 * s,
      height: 92 * s,
      color: const Color(0xFFEADCBB),
      child: Icon(Icons.person, size: 48 * s, color: _kTaupe),
    );

// ─── Tab delegate ────────────────────────────────────────────────────────────
class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabHeaderDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: _kCream, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabHeaderDelegate old) => false;
}

// ─── YouTube yardımcıları ──────────────────────────────────────────────────────
String? _youtubeId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  if (uri.host.contains('youtu.be')) return uri.pathSegments.firstOrNull;
  if (uri.host.contains('youtube.com')) {
    if (uri.pathSegments.contains('shorts') && uri.pathSegments.length > 1) {
      return uri.pathSegments[uri.pathSegments.indexOf('shorts') + 1];
    }
    return uri.queryParameters['v'];
  }
  return null;
}

String? _youtubeThumbnail(String url) {
  final id = _youtubeId(url);
  return id != null ? 'https://img.youtube.com/vi/$id/mqdefault.jpg' : null;
}

void _openVideo(String url, String title) {
  Navigator.of(Get.context!).push(
    MaterialPageRoute(
      builder: (_) => VideoViewerPage(videoUrl: url, title: title),
    ),
  );
}

// ─── İşler Tab ────────────────────────────────────────────────────────────────
class _IslerTab extends StatelessWidget {
  const _IslerTab({required this.freelancer, required this.reviewCount});

  final FreelancerModel? freelancer;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    final projects = freelancer?.projects ?? [];

    return ListView(
      padding: EdgeInsets.fromLTRB(24 * s, 20 * s, 24 * s, 32 * s),
      children: [
        Text('Projeler',
            style: _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk)),
        SizedBox(height: 14 * s),
        if (projects.isEmpty)
          Container(
            height: 120 * s,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(border: Border.fromBorderSide(BorderSide(color: _kCardBorder))),
            child: Text('Henüz proje eklenmemiş',
                style: _mono(size: 9 * s, color: _kMuted, spacing: 0.2)),
          )
        else
          SizedBox(
            height: 180 * s,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: projects.length,
              separatorBuilder: (_, _) => SizedBox(width: 10 * s),
              itemBuilder: (context, i) {
                final p = projects[i];
                final videoUrl = p.videoUrl;
                final thumbnail =
                    videoUrl != null ? _youtubeThumbnail(videoUrl) : null;
                return GestureDetector(
                  onTap: videoUrl != null
                      ? () => _openVideo(videoUrl, p.title)
                      : null,
                  child: Container(
                    width: 150 * s,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_kThumbTop, _kThumbBot],
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (thumbnail != null)
                          CachedNetworkImage(
                            imageUrl: thumbnail,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => const SizedBox.shrink(),
                          )
                        else if (videoUrl != null)
                          Container(
                            color: Colors.black.withValues(alpha: 0.2),
                            alignment: Alignment.center,
                            child: Icon(Icons.videocam_outlined,
                                color: Colors.white54, size: 34 * s),
                          ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                            padding:
                                EdgeInsets.fromLTRB(10 * s, 20 * s, 10 * s, 10 * s),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (p.title.isNotEmpty)
                                  Text(p.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _serif(
                                          size: 15 * s,
                                          weight: FontWeight.w600,
                                          color: Colors.white)),
                                if (p.jobType.isNotEmpty)
                                  Text(p.jobType.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _mono(
                                          size: 7 * s,
                                          color: Colors.white60,
                                          spacing: 0.8)),
                              ],
                            ),
                          ),
                        ),
                        if (videoUrl != null)
                          Positioned(
                            top: 10 * s,
                            left: 10 * s,
                            child: Container(
                              width: 32 * s,
                              height: 32 * s,
                              color: Colors.black.withValues(alpha: 0.45),
                              child: Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 20 * s),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        SizedBox(height: 28 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Yorumlar ($reviewCount)',
                style:
                    _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk)),
            Text('TÜMÜNÜ GÖR',
                style: _mono(
                    size: 8 * s,
                    weight: FontWeight.w700,
                    color: _kGold,
                    spacing: 1)),
          ],
        ),
        SizedBox(height: 12 * s),
        _ReviewItem(
            scale: s,
            brand: 'Migros',
            projectType: 'Marka Filmi',
            rating: 5.0,
            comment: 'Harika bir iş çıkardı.',
            initials: 'M'),
        SizedBox(height: 10 * s),
        _ReviewItem(
            scale: s,
            brand: 'Beko',
            projectType: 'Reklam Filmi',
            rating: 4.9,
            comment: 'Çok profesyonel çalışma.',
            initials: 'B'),
      ],
    );
  }
}

// ─── Hakkında Tab ─────────────────────────────────────────────────────────────
class _HakkindaTab extends StatelessWidget {
  const _HakkindaTab(
      {required this.bio, required this.trustScore, required this.freelancer});

  final String bio;
  final int trustScore;
  final FreelancerModel? freelancer;

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(24 * s, 20 * s, 24 * s, 32 * s),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
            decoration: BoxDecoration(border: Border.all(color: _kGold)),
            child: Text('TRUST $trustScore%',
                style: _mono(
                    size: 9 * s,
                    weight: FontWeight.w700,
                    color: _kGold,
                    spacing: 1)),
          ),
        ),
        SizedBox(height: 20 * s),
        Text('BİYOGRAFİ', style: _mono(size: 8 * s, color: _kMuted, spacing: 1.5)),
        SizedBox(height: 8 * s),
        Text(bio.isNotEmpty ? bio : 'Henüz biyografi eklenmemiş.',
            style: _mono(size: 10 * s, color: _kInk, spacing: 0.2, height: 1.7)),
        SizedBox(height: 24 * s),
        Text('UZMANLIK', style: _mono(size: 8 * s, color: _kMuted, spacing: 1.5)),
        SizedBox(height: 10 * s),
        Wrap(
          spacing: 8 * s,
          runSpacing: 8 * s,
          children: [
            ...(freelancer?.categories ?? []),
            'Color Grading',
          ]
              .where((x) => x.isNotEmpty)
              .map((x) => Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12 * s, vertical: 7 * s),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black12)),
                    child: Text(x,
                        style: _mono(size: 9 * s, color: _kInk, spacing: 0.2)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ─── Yorumlar Tab ─────────────────────────────────────────────────────────────
class _YorumlarTab extends StatelessWidget {
  const _YorumlarTab({required this.reviewCount});
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    final dummyReviews = [
      ('M', 'Migros', 'Marka Filmi', 5.0, 'Harika bir iş çıkardı.'),
      ('B', 'Beko', 'Reklam Filmi', 4.9, 'Çok profesyonel çalışma.'),
      ('A', 'Ajet', 'Tanıtım Filmi', 5.0, 'Kesinlikle tavsiye ederim.'),
      ('T', 'Türk Telekom', 'Kurumsal', 4.8, 'Zamanında ve kaliteli teslimat.'),
    ];
    return ListView(
      padding: EdgeInsets.fromLTRB(24 * s, 16 * s, 24 * s, 32 * s),
      children: [
        Text('Yorumlar ($reviewCount)',
            style: _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk)),
        SizedBox(height: 14 * s),
        ...dummyReviews.map((r) => Padding(
              padding: EdgeInsets.only(bottom: 10 * s),
              child: _ReviewItem(
                  scale: s,
                  initials: r.$1,
                  brand: r.$2,
                  projectType: r.$3,
                  rating: r.$4,
                  comment: r.$5),
            )),
      ],
    );
  }
}

// ─── Review Item ──────────────────────────────────────────────────────────────
class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.scale,
    required this.initials,
    required this.brand,
    required this.projectType,
    required this.rating,
    required this.comment,
  });

  final double scale;
  final String initials;
  final String brand;
  final String projectType;
  final double rating;
  final String comment;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.all(14 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38 * s,
            height: 38 * s,
            color: const Color(0xFFEADCBB),
            alignment: Alignment.center,
            child: Text(initials,
                style: _mono(
                    size: 12 * s,
                    weight: FontWeight.w700,
                    color: _kInk,
                    spacing: 0.5)),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text('$brand · $projectType',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _mono(
                              size: 8 * s, color: _kTaupe, spacing: 0.3)),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(Icons.star_rounded,
                            size: 12 * s,
                            color: i < rating.round()
                                ? _kGold
                                : Colors.black12),
                      ),
                    ),
                    SizedBox(width: 4 * s),
                    Text(rating.toStringAsFixed(1),
                        style: _mono(
                            size: 8 * s,
                            weight: FontWeight.w700,
                            color: _kInk,
                            spacing: 0.3)),
                  ],
                ),
                SizedBox(height: 5 * s),
                Text(comment,
                    style: _serif(
                        size: 15 * s, weight: FontWeight.w500, color: _kInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
