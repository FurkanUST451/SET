import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/utils/avatar_image.dart';
import '../../../data/models/freelancer_model.dart';
import '../../../widgets/video_viewer_page.dart';
import 'freelancer_detail_controller.dart';
import '../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kDivider = Color(0x12000000);
const _kCardBorder = Color(0x14000000);
const _kThumbTop = Color(0xFF3A342E);
const _kThumbBot = Color(0xFF211E1A);

double _scaleOf(BuildContext c) =>
    (MediaQuery.sizeOf(c).width / 390).clamp(0.85, 1.15).toDouble();

TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
}) =>
    AppFonts.display(
        fontSize: size, fontWeight: weight, color: color, height: height);

TextStyle _ui({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
  double height = 1.4,
}) =>
    AppFonts.ui(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height);


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
    final primaryCategory =
        (f?.categories.isNotEmpty == true ? f!.categories.first : '')
            .toUpperCaseTr();

    PortfolioProject? showreel;
    for (final p in f?.projects ?? const <PortfolioProject>[]) {
      if (p.videoUrl != null) {
        showreel = p;
        break;
      }
    }
    final showreelThumb =
        showreel != null ? _youtubeThumbnail(showreel.videoUrl!) : null;
    final showreelFallback = AppAssets.portfolioMercedesGallery.first;
    final showreelMinutes = 1 + (f?.experience ?? 3) % 4;
    final showreelSeconds = (14 + ((f?.experience ?? 3) * 7) % 46);
    final showreelDuration =
        '$showreelMinutes:${showreelSeconds.toString().padLeft(2, '0')}';

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
                      Expanded(
                        child: Center(
                          child: Text(
                            'SET · PROFİL',
                            style: _ui(
                                size: 10 * s,
                                weight: FontWeight.w700,
                                color: _kInk,
                                spacing: 2),
                          ),
                        ),
                      ),
                      _barIcon(s, Icons.more_horiz_rounded, () {}),
                    ],
                  ),
                ),
                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, _) => [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 14 * s, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kimlik: sol avatar + sağda ad/rol/konum
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 24 * s),
                                child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Avatar (dairesel + online göstergesi)
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ClipOval(
                                        child: SizedBox(
                                          width: 72 * s,
                                          height: 72 * s,
                                          child: buildAvatarImage(
                                            f?.profileImageUrl ??
                                                placeholderAvatarFor(u?.gender,
                                                    f?.userId ?? name),
                                            size: 72 * s,
                                            placeholder: _avatarPlaceholder(s),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 2 * s,
                                        right: 2 * s,
                                        child: Container(
                                          width: 14 * s,
                                          height: 14 * s,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF6B8E5A),
                                            border: Border.all(
                                                color: _kCream, width: 2.5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 18 * s),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: _display(
                                                size: 30 * s,
                                                weight: FontWeight.w600,
                                                color: _kInk)),
                                        SizedBox(height: 6 * s),
                                        Text(
                                          'DİREKTÖR${primaryCategory.isNotEmpty ? ' · $primaryCategory' : ''}',
                                          style: _ui(
                                              size: 8 * s,
                                              weight: FontWeight.w700,
                                              color: _kGold,
                                              spacing: 1),
                                        ),
                                        SizedBox(height: 6 * s),
                                        Text(
                                          '${(f?.location ?? 'İstanbul').toUpperCaseTr()}, TÜRKİYE',
                                          style: _ui(
                                              size: 8 * s,
                                              color: _kTaupe,
                                              spacing: 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              ),
                              SizedBox(height: 18 * s),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: _kDivider),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 14 * s),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _StatColumn(
                                        scale: s,
                                        label: 'PUAN',
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.star_rounded,
                                                size: 13 * s, color: _kGold),
                                            SizedBox(width: 3 * s),
                                            Text(
                                              '${f?.rating.toStringAsFixed(1) ?? '4.9'} ($reviewCount)',
                                              style: _ui(
                                                  size: 10 * s,
                                                  weight: FontWeight.w700,
                                                  color: _kInk,
                                                  spacing: 0.3),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: 1,
                                        height: 26 * s,
                                        color: _kDivider),
                                    Expanded(
                                      child: _StatColumn(
                                        scale: s,
                                        label: 'TAMAMLANAN İŞ',
                                        child: Text('$jobCount',
                                            style: _ui(
                                                size: 10 * s,
                                                weight: FontWeight.w700,
                                                color: _kInk,
                                                spacing: 0.3)),
                                      ),
                                    ),
                                    Container(
                                        width: 1,
                                        height: 26 * s,
                                        color: _kDivider),
                                    Expanded(
                                      child: _StatColumn(
                                        scale: s,
                                        label: 'DENEYİM',
                                        child: Text(
                                            '${f?.experience ?? 3} YIL',
                                            style: _ui(
                                                size: 10 * s,
                                                weight: FontWeight.w700,
                                                color: _kInk,
                                                spacing: 0.3)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 18 * s),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: controller.openChat,
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        height: 50 * s,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: _kInk, width: 1.2),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text('MESAJ',
                                            style: _ui(
                                                size: 9 * s,
                                                weight: FontWeight.w700,
                                                color: _kInk,
                                                spacing: 1)),
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
                                        decoration: const BoxDecoration(
                                          color: _kGold,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text('TEKLİF GÖNDER',
                                            style: _ui(
                                                size: 9 * s,
                                                weight: FontWeight.w700,
                                                color: Colors.white,
                                                spacing: 1)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ...[
                                SizedBox(height: 20 * s),
                                GestureDetector(
                                  onTap: showreel != null
                                      ? () => _openVideo(
                                          showreel!.videoUrl!, showreel.title)
                                      : null,
                                  child: Container(
                                    width: double.infinity,
                                    height: 170 * s,
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
                                        if (showreelThumb != null)
                                          CachedNetworkImage(
                                            imageUrl: showreelThumb,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, _, _) => Image.asset(
                                                showreelFallback,
                                                fit: BoxFit.cover),
                                          )
                                        else
                                          Image.asset(showreelFallback,
                                              fit: BoxFit.cover),
                                        Positioned(
                                          top: 10 * s,
                                          left: 10 * s,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 6 * s,
                                                height: 6 * s,
                                                decoration:
                                                    const BoxDecoration(
                                                        shape:
                                                            BoxShape.circle,
                                                        color: _kGold),
                                              ),
                                              SizedBox(width: 5 * s),
                                              Text('SHOWREEL',
                                                  style: _ui(
                                                      size: 8 * s,
                                                      weight:
                                                          FontWeight.w700,
                                                      color: Colors.white,
                                                      spacing: 1.2)),
                                            ],
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: 48 * s,
                                            height: 48 * s,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white
                                                  .withValues(alpha: 0.9),
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                                Icons.play_arrow_rounded,
                                                color: _kInk,
                                                size: 26 * s),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 10 * s,
                                          right: 10 * s,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6 * s,
                                                vertical: 3 * s),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                            ),
                                            child: Text(showreelDuration,
                                                style: _ui(
                                                    size: 8 * s,
                                                    weight: FontWeight.w700,
                                                    color: Colors.white,
                                                    spacing: 0.5)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
                            labelStyle: _ui(
                                size: 10 * s,
                                weight: FontWeight.w700,
                                color: _kBlack,
                                spacing: 1),
                            unselectedLabelStyle:
                                _ui(size: 10 * s, color: _kBlack, spacing: 1),
                            labelColor: _kBlack,
                            unselectedLabelColor: _kBlack,
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

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.scale,
    required this.label,
    required this.child,
  });

  final double scale;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      children: [
        Text(label,
            style: _ui(size: 7 * s, color: _kTaupe, spacing: 0.8)),
        SizedBox(height: 5 * s),
        child,
      ],
    );
  }
}

Widget _avatarPlaceholder(double s) => Container(
      width: 92 * s,
      height: 92 * s,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEADCBB),
      ),
      alignment: Alignment.center,
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

  static const _placeholderProjects = [
    ('REKLAM', 'Yolun Ötesi'),
    ('KLİP', 'Bir Nefes Uzakta'),
    ('BELGESEL', 'Şehrin İzleri'),
    ('MODA', 'Form & Işık'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    final projects = freelancer?.projects ?? [];
    final hasRealProjects = projects.isNotEmpty;
    final gallery = AppAssets.portfolioMercedesGallery;
    final itemCount =
        hasRealProjects ? projects.length : _placeholderProjects.length;

    return ListView(
      padding: EdgeInsets.fromLTRB(0, 20 * s, 0, 32 * s),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Projeler',
                  style: _display(
                      size: 22 * s, weight: FontWeight.w600, color: _kInk)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('TÜMÜNÜ GÖR',
                      style: _ui(
                          size: 8 * s,
                          weight: FontWeight.w700,
                          color: _kGold,
                          spacing: 1)),
                  SizedBox(width: 4 * s),
                  Icon(Icons.arrow_forward_rounded,
                      size: 12 * s, color: _kGold),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 14 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16 * s,
            crossAxisSpacing: 12 * s,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, i) {
            final p = hasRealProjects ? projects[i] : null;
            final videoUrl = p?.videoUrl;
            final category =
                p != null ? p.jobType.toUpperCaseTr() : _placeholderProjects[i].$1;
            final title = p != null ? p.title : _placeholderProjects[i].$2;
            final networkThumb = p?.thumbnailUrl ??
                (videoUrl != null ? _youtubeThumbnail(videoUrl) : null);
            final assetThumb = gallery[i % gallery.length];
            return GestureDetector(
              onTap: videoUrl != null
                  ? () => _openVideo(videoUrl, title)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
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
                          if (networkThumb != null)
                            CachedNetworkImage(
                              imageUrl: networkThumb,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) =>
                                  Image.asset(assetThumb, fit: BoxFit.cover),
                            )
                          else
                            Image.asset(assetThumb, fit: BoxFit.cover),
                          if (videoUrl != null)
                            Positioned(
                              top: 8 * s,
                              left: 8 * s,
                              child: Container(
                                width: 26 * s,
                                height: 26 * s,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.45),
                                ),
                                child: Icon(Icons.play_arrow_rounded,
                                    color: Colors.white, size: 16 * s),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  if (category.isNotEmpty)
                    Text(category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _ui(
                            size: 7 * s,
                            weight: FontWeight.w700,
                            color: _kGold,
                            spacing: 0.8)),
                  SizedBox(height: 2 * s),
                  if (title.isNotEmpty)
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _display(
                            size: 15 * s,
                            weight: FontWeight.w600,
                            color: _kInk)),
                ],
              ),
            );
          },
        ),
        ),
        SizedBox(height: 28 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Yorumlar ($reviewCount)',
                  style: _display(
                      size: 22 * s, weight: FontWeight.w600, color: _kInk)),
              Text('TÜMÜNÜ GÖR',
                  style: _ui(
                      size: 8 * s,
                      weight: FontWeight.w700,
                      color: _kGold,
                      spacing: 1)),
            ],
          ),
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
            decoration: BoxDecoration(
              border: Border.all(color: _kGold),
            ),
            child: Text('TRUST $trustScore%',
                style: _ui(
                    size: 9 * s,
                    weight: FontWeight.w700,
                    color: _kGold,
                    spacing: 1)),
          ),
        ),
        SizedBox(height: 20 * s),
        Text('BİYOGRAFİ', style: _ui(size: 8 * s, color: _kBlack, spacing: 1.5)),
        SizedBox(height: 8 * s),
        Text(bio.isNotEmpty ? bio : 'Henüz biyografi eklenmemiş.',
            style: _ui(size: 10 * s, color: _kBlack, spacing: 0.2, height: 1.7)),
        SizedBox(height: 24 * s),
        Text('UZMANLIK', style: _ui(size: 8 * s, color: _kBlack, spacing: 1.5)),
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
                        style: _ui(size: 9 * s, color: _kBlack, spacing: 0.2)),
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
      padding: EdgeInsets.fromLTRB(0, 16 * s, 0, 32 * s),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Text('Yorumlar ($reviewCount)',
              style:
                  _display(size: 22 * s, weight: FontWeight.w600, color: _kInk)),
        ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38 * s,
            height: 38 * s,
            decoration: const BoxDecoration(
              color: Color(0xFFEADCBB),
            ),
            alignment: Alignment.center,
            child: Text(initials,
                style: _ui(
                    size: 12 * s,
                    weight: FontWeight.w700,
                    color: _kBlack,
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
                          style: _ui(
                              size: 8 * s, color: _kBlack, spacing: 0.3)),
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
                        style: _ui(
                            size: 8 * s,
                            weight: FontWeight.w700,
                            color: _kBlack,
                            spacing: 0.3)),
                  ],
                ),
                SizedBox(height: 5 * s),
                Text(comment,
                    style: _display(
                        size: 15 * s, weight: FontWeight.w500, color: _kInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
