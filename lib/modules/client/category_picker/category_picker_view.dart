import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'category_picker_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kMuted = Color(0xFFB6AD9A);
const _kCardBorder = Color(0x14000000);

const Map<String, String> _kCategoryIcons = {
  'Video Çekim': 'assets/images/main_service_icons/video.png',
  'Kurgu': 'assets/images/main_service_icons/kurgu.png',
  'Ses Tasarımı': 'assets/images/main_service_icons/ses.png',
  'CGI & VFX': 'assets/images/main_service_icons/cgi.png',
  'Fotoğraf': 'assets/images/main_service_icons/foto.png',
  'Grafik Tasarım': 'assets/images/main_service_icons/grafiktasarim.png',
  'Sosyal Medya Yönetimi': 'assets/images/main_service_icons/sosyal medya.png',
};

const Map<String, String> _kCategoryTags = {
  'Video Çekim': 'REKLAM FİLMİ · MOTION · SET ÇEKİM',
  'Kurgu': 'REKLAM · DİZİ · SOSYAL MEDYA KURGUSU',
  'Ses Tasarımı': 'MİKS · SESLENDİRME · SOUND DESIGN',
  'CGI & VFX': '3D MODELLEME · VFX · CGI ÜRÜN',
  'Fotoğraf': 'ÜRÜN · PORTRE · REKLAM FOTOĞRAFI',
  'Grafik Tasarım': 'LOGO · KATALOG · SOSYAL GÖRSEL',
  'Sosyal Medya Yönetimi': 'İÇERİK · STRATEJİ · YÖNETİM',
};

TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
  bool italic = false,
}) =>
    AppFonts.display(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      decoration: TextDecoration.none,
    );

TextStyle _ui({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
}) =>
    AppFonts.ui(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: spacing,
      decoration: TextDecoration.none,
    );

Widget _wordmark(double s) => RichText(
      text: TextSpan(children: [
        TextSpan(
          text: 'SE',
          style: AppFonts.display(
              fontSize: 18 * s,
              fontWeight: FontWeight.w700,
              color: _kInk,
              letterSpacing: 2.5),
        ),
        TextSpan(
          text: 'T',
          style: AppFonts.display(
              fontSize: 18 * s,
              fontWeight: FontWeight.w800,
              color: _kGold,
              letterSpacing: 2.5),
        ),
      ]),
    );

class CategoryPickerView extends GetView<CategoryPickerController> {
  const CategoryPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double s = (screenWidth / 390).clamp(0.85, 1.15).toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Üst bar
              SizedBox(
                height: 48 * s,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Get.back<void>(),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.all(12 * s),
                          child: Icon(Icons.arrow_back_rounded,
                              size: 22 * s, color: _kInk),
                        ),
                      ),
                    ),
                    _wordmark(s),
                  ],
                ),
              ),
              SizedBox(height: 22 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dilediğin hizmeti seç',
                      style: _display(
                          size: 17 * s,
                          weight: FontWeight.w500,
                          color: _kInk,
                          italic: true),
                    ),
                    SizedBox(height: 4 * s),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: 'Biz ',
                          style: _display(
                              size: 40 * s,
                              weight: FontWeight.w700,
                              color: _kInk),
                        ),
                        TextSpan(
                          text: 'üretelim!',
                          style: _display(
                              size: 40 * s,
                              weight: FontWeight.w700,
                              color: _kGold),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22 * s),
              Expanded(
                child: _CategoryCarousel(
                  scale: s,
                  categories: controller.categories,
                  onContinue: controller.selectCategory,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCarousel extends StatefulWidget {
  const _CategoryCarousel({
    required this.scale,
    required this.categories,
    required this.onContinue,
  });

  final double scale;
  final List<String> categories;
  final ValueChanged<String> onContinue;

  @override
  State<_CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<_CategoryCarousel> {
  late final PageController _pageController =
      PageController(viewportFraction: 0.64);
  int _activeIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.categories.length,
            onPageChanged: (i) => setState(() => _activeIndex = i),
            itemBuilder: (_, i) {
              final cat = widget.categories[i];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double page = _activeIndex.toDouble();
                  if (_pageController.hasClients &&
                      _pageController.page != null) {
                    page = _pageController.page!;
                  }
                  final delta = (page - i).abs().clamp(0.0, 1.0);
                  final scale = 1 - delta * 0.14;
                  final opacity = 1 - delta * 0.55;
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(opacity: opacity, child: child),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * s),
                  child: _CategoryCard(
                    scale: s,
                    index: i,
                    label: cat,
                    active: i == _activeIndex,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 18 * s),
        SmoothPageIndicator(
          controller: _pageController,
          count: widget.categories.length,
          effect: WormEffect(
            dotWidth: 7 * s,
            dotHeight: 7 * s,
            activeDotColor: _kGold,
            dotColor: _kMuted.withValues(alpha: 0.4),
            spacing: 8 * s,
          ),
        ),
        SizedBox(height: 20 * s),
        GestureDetector(
          onTap: () => widget.onContinue(widget.categories[_activeIndex]),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: double.infinity,
            height: 54 * s,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _kGold,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'DEVAM ET',
                  style: _ui(
                      size: 11 * s,
                      weight: FontWeight.w700,
                      color: Colors.white,
                      spacing: 1.8),
                ),
                SizedBox(width: 10 * s),
                Icon(Icons.arrow_forward_rounded,
                    size: 16 * s, color: Colors.white),
              ],
            ),
          ),
        ),
        SizedBox(height: 10 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 11 * s, color: _kMuted),
            SizedBox(width: 5 * s),
            Text(
              'Seçimin gizli tutulur ve güvenle saklanır.',
              style: _ui(size: 8 * s, color: _kMuted, spacing: 0.2),
            ),
          ],
        ),
        SizedBox(height: 18 * s),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.scale,
    required this.index,
    required this.label,
    required this.active,
  });

  final double scale;
  final int index;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final firstSpaceIndex = label.indexOf(' ');
    final firstWord =
        firstSpaceIndex == -1 ? label : label.substring(0, firstSpaceIndex);
    final restWord =
        firstSpaceIndex == -1 ? '' : label.substring(firstSpaceIndex);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(20 * s, 22 * s, 20 * s, 22 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(
          color: active ? _kInk : _kCardBorder,
          width: active ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HİZMET · ${(index + 1).toString().padLeft(2, '0')}',
            style: _ui(
                size: 9 * s,
                weight: FontWeight.w700,
                color: _kMuted,
                spacing: 1.6),
          ),
          SizedBox(height: 30 * s),
          Expanded(
            flex: 3,
            child: Center(
              child: Image.asset(
                _kCategoryIcons[label] ?? '',
                width: 192 * s,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 10 * s),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: firstWord,
                style: _display(size: 32 * s, weight: FontWeight.w600, color: _kInk),
              ),
              TextSpan(
                text: restWord,
                style:
                    _display(size: 32 * s, weight: FontWeight.w600, color: _kGold),
              ),
            ]),
          ),
          SizedBox(height: 36 * s),
          Text(
            _kCategoryTags[label] ?? '',
            style: _ui(
                size: 10.5 * s,
                weight: FontWeight.w700,
                color: _kInk,
                spacing: 0.8),
          ),
          SizedBox(height: 4 * s),
          Text(
            've daha fazlası...',
            style: _display(
                size: 15 * s,
                weight: FontWeight.w500,
                color: _kInk,
                italic: true),
          ),
          const Expanded(flex: 1, child: SizedBox()),
        ],
      ),
    );
  }
}
