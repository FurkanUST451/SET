import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/freelancer_model.dart';
import '../../../data/models/user_model.dart';
import '../../../widgets/video_viewer_page.dart';
import 'freelancers_by_category_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kCardBorder = Color(0x14000000);
const _kThumbTop = Color(0xFF3A342E);
const _kThumbBot = Color(0xFF211E1A);

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

class FreelancersByCategoryView
    extends GetView<FreelancersByCategoryController> {
  const FreelancersByCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final double s =
        (MediaQuery.sizeOf(context).width / 390).clamp(0.85, 1.15).toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back<void>(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(12 * s),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 22 * s, color: _kInk),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24 * s, 4 * s, 24 * s, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                              'uygun ${controller.freelancers.isEmpty ? 0 : controller.freelancers.length * 10} kreatif.',
                              style: _serif(
                                  size: 38 * s,
                                  weight: FontWeight.w600,
                                  color: _kInk),
                            )),
                        SizedBox(height: 8 * s),
                        Text(
                          '5 kişiye ücretsiz teklif gönder. Fazlası için kredi gerekir.',
                          style: _mono(
                              size: 9 * s,
                              color: _kTaupe,
                              spacing: 0.2,
                              height: 1.5),
                        ),
                        SizedBox(height: 14 * s),
                        Obx(() => Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16 * s, vertical: 12 * s),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                    left: BorderSide(color: _kGold, width: 3),
                                    top: BorderSide(color: _kCardBorder),
                                    right: BorderSide(color: _kCardBorder),
                                    bottom: BorderSide(color: _kCardBorder)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${controller.selectedIds.length}/5 seçildi',
                                    style: _serif(
                                        size: 17 * s,
                                        weight: FontWeight.w600,
                                        color: _kInk),
                                  ),
                                  SizedBox(height: 2 * s),
                                  Text(
                                    'Öne çıkan işlere bak, doğru ekibi seç',
                                    style: _mono(
                                        size: 8 * s,
                                        color: _kTaupe,
                                        spacing: 0.2),
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(height: 14 * s),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: _kGold),
                        );
                      }
                      if (controller.errorMsg.isNotEmpty) {
                        return Center(
                          child: Text(controller.errorMsg.value,
                              style: _mono(
                                  size: 10 * s, color: _kTaupe, spacing: 0.2)),
                        );
                      }
                      if (controller.freelancers.isEmpty) {
                        return _EmptyState(scale: s, category: controller.category);
                      }
                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(24 * s, 0, 24 * s, 100 * s),
                        itemCount: controller.freelancers.length,
                        separatorBuilder: (_, _) => SizedBox(height: 14 * s),
                        itemBuilder: (_, i) {
                          final f = controller.freelancers[i];
                          return Obx(() => _FreelancerCard(
                                scale: s,
                                freelancer: f,
                                user: controller.userFor(f),
                                selected: controller.isSelected(f),
                                onProfile: () => controller.openDetail(f),
                                onInvite: () => controller.toggleSelect(f),
                              ));
                        },
                      );
                    }),
                  ),
                ],
              ),
              // Alt CTA
              Positioned(
                left: 24 * s,
                right: 24 * s,
                bottom: 24 * s,
                child: Obx(() {
                  final count = controller.selectedIds.length;
                  final sending = controller.isSending.value;
                  return GestureDetector(
                    onTap: sending ? null : controller.sendOffers,
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedOpacity(
                      opacity: count > 0 ? 1.0 : 0.45,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        height: 54 * s,
                        color: _kGold,
                        alignment: Alignment.center,
                        child: sending
                            ? SizedBox(
                                width: 22 * s,
                                height: 22 * s,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white),
                              )
                            : Text('SEÇİLENLERE TEKLİF GÖNDER  →',
                                style: _mono(
                                    size: 10 * s,
                                    weight: FontWeight.w700,
                                    color: Colors.white,
                                    spacing: 1.2)),
                      ),
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
}

class _FreelancerCard extends StatelessWidget {
  const _FreelancerCard({
    required this.scale,
    required this.freelancer,
    required this.user,
    required this.selected,
    required this.onProfile,
    required this.onInvite,
  });

  final double scale;
  final FreelancerModel freelancer;
  final UserModel user;
  final bool selected;
  final VoidCallback onProfile;
  final VoidCallback onInvite;

  int get _jobCount => freelancer.experience * 12 + 15;
  int get _trustScore => (freelancer.rating * 19.5).round();

  String _buildDisplayName(FreelancerModel f, UserModel u) {
    final name = f.name.isNotEmpty ? f.name : u.name;
    final surname =
        (f.surname?.isNotEmpty == true) ? f.surname! : (u.surname ?? '');
    return surname.isNotEmpty ? '$name $surname' : name;
  }

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
    if (id == null) return null;
    return 'https://img.youtube.com/vi/$id/mqdefault.jpg';
  }

  void _openVideo(String url) {
    Navigator.of(Get.context!).push(
      MaterialPageRoute(builder: (_) => VideoViewerPage(videoUrl: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64 * s,
                height: 64 * s,
                child: freelancer.profileImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: freelancer.profileImageUrl!,
                        width: 64 * s,
                        height: 64 * s,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _AvatarPlaceholder(size: 64 * s),
                        errorWidget: (_, _, _) =>
                            _AvatarPlaceholder(size: 64 * s),
                      )
                    : _AvatarPlaceholder(size: 64 * s),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _buildDisplayName(freelancer, user),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _serif(
                          size: 18 * s,
                          weight: FontWeight.w600,
                          color: _kInk),
                    ),
                    SizedBox(height: 3 * s),
                    Text(
                      'Direktör · ${freelancer.categories.join(', ')}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _mono(size: 8 * s, color: _kTaupe, spacing: 0.2),
                    ),
                    SizedBox(height: 3 * s),
                    Text(
                      '${freelancer.location}, Türkiye · ${freelancer.experience} Yıl',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _mono(size: 8 * s, color: _kMuted, spacing: 0.2),
                    ),
                    SizedBox(height: 8 * s),
                    Wrap(
                      spacing: 6 * s,
                      runSpacing: 6 * s,
                      children: [
                        _Chip(scale: s, label: freelancer.rating.toStringAsFixed(1)),
                        _Chip(scale: s, label: '$_jobCount iş'),
                        _Chip(scale: s, label: 'Trust $_trustScore'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          Row(
            children: List.generate(3, (i) {
              final videoUrl = i < freelancer.projects.length
                  ? freelancer.projects[i].videoUrl
                  : null;
              final thumbnail =
                  videoUrl != null ? _youtubeThumbnail(videoUrl) : null;
              return Expanded(
                child: GestureDetector(
                  onTap: videoUrl != null ? () => _openVideo(videoUrl) : null,
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 6 * s : 0),
                    height: 68 * s,
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
                            color: Colors.black.withValues(alpha: 0.35),
                            alignment: Alignment.center,
                            child: Icon(Icons.videocam_outlined,
                                color: Colors.white70, size: 22 * s),
                          ),
                        if (videoUrl != null)
                          Positioned(
                            bottom: 4 * s,
                            right: 4 * s,
                            child: Container(
                              padding: EdgeInsets.all(3 * s),
                              color: Colors.black54,
                              child: Icon(Icons.play_arrow,
                                  color: Colors.white, size: 13 * s),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 12 * s),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onProfile,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 44 * s,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black12)),
                    alignment: Alignment.center,
                    child: Text('PROFİLİ GÖR',
                        style: _mono(
                            size: 9 * s,
                            weight: FontWeight.w700,
                            color: _kInk,
                            spacing: 1)),
                  ),
                ),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: GestureDetector(
                  onTap: onInvite,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 44 * s,
                    color: selected ? _kGold : _kInk,
                    alignment: Alignment.center,
                    child: Text(selected ? 'SEÇİLDİ ✓' : 'DAVET ET',
                        style: _mono(
                            size: 9 * s,
                            weight: FontWeight.w700,
                            color: Colors.white,
                            spacing: 1)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFEADCBB),
      child: Icon(Icons.person, size: size * 0.56, color: _kTaupe),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.scale, required this.label});
  final double scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 4 * s),
      color: _kGold.withValues(alpha: 0.12),
      child: Text(
        label,
        style: _mono(
            size: 8 * s, weight: FontWeight.w700, color: _kInk, spacing: 0.3),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scale, required this.category});
  final double scale;
  final String category;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 52 * s, color: _kMuted),
          SizedBox(height: 16 * s),
          Text(
            '"$category" alanında\nhenüz kreatif yok',
            textAlign: TextAlign.center,
            style: _serif(size: 20 * s, weight: FontWeight.w600, color: _kInk),
          ),
        ],
      ),
    );
  }
}
