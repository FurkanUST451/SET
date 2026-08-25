import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_text_styles.dart';

/// Onboarding 2. sayfa — atlas.png üzerine kurulu yamuk/çapraz kompozisyon.
///
/// Görsel → dekoratif çerçeve → başlık → alt metin sırasıyla sahneye
/// girer; giriş animasyonu bitince [onReady] çağrılır. Ekrana dokunmak
/// animasyonu anında tamamlayıp [onReady]'i erken tetikler.
class OnboardingWelcomePage extends StatefulWidget {
  const OnboardingWelcomePage({super.key, required this.onReady});

  final VoidCallback onReady;

  @override
  State<OnboardingWelcomePage> createState() => _OnboardingWelcomePageState();
}

class _OnboardingWelcomePageState extends State<OnboardingWelcomePage>
    with SingleTickerProviderStateMixin {
  static const Duration _stageDuration = Duration(milliseconds: 750);
  static const Duration _stageGap = Duration(milliseconds: 350);

  // 3 sahne: görsel, başlık, alt metin. Her biri kendi aralığında (interval)
  // ease-out ile sahneye girer, aralarında _stageGap kadar boşluk bırakılır.
  static const int _stageCount = 3;
  late final AnimationController _controller;
  late final List<Animation<double>> _stageAnimations;
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    final totalMs = _stageCount * _stageDuration.inMilliseconds +
        (_stageCount - 1) * _stageGap.inMilliseconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );

    _stageAnimations = List.generate(_stageCount, (index) {
      final startMs =
          index * (_stageDuration.inMilliseconds + _stageGap.inMilliseconds);
      final start = startMs / totalMs;
      final end = (startMs + _stageDuration.inMilliseconds) / totalMs;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });

    _controller.forward().whenComplete(_markReady);
  }

  void _skipAnimation() {
    if (_ready) return;
    _controller.value = 1.0;
    _markReady();
  }

  void _markReady() {
    if (_ready) return;
    _ready = true;
    widget.onReady();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 1.25;
    final s = (screenWidth / 390).clamp(0.85, 1.15);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _skipAnimation,
      child: Container(
        color: AppColors.backgroundLight,
        child: SafeArea(
          child: Stack(
            children: [
              // Marka bloğu — giriş ekranındaki ile aynı boyut/konum (sol üst).
              Positioned(
                top: 24 * s,
                left: 26 * s,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(AppAssets.loginLogo, height: 34 * s),
                    SizedBox(height: 8 * s),
                    Text(
                      'KREATİVİTENİN MERKEZİ',
                      style: AppFonts.ui(
                        fontSize: 9 * s,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              // Ana görsel — hafif eğik, sol kenardan taşan çapraz kompozisyon.
              Positioned(
                left: -imageSize * 0.28,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: const Alignment(0, -0.4),
                  child: FadeTransition(
                    opacity: _stageAnimations[0],
                    child: Transform.rotate(
                      angle: -11 * math.pi / 180,
                      child: ClipPath(
                        clipper: _TrapezoidClipper(),
                        child: SizedBox(
                          width: imageSize,
                          height: imageSize,
                          child: Image.asset(
                            AppAssets.splashWelcomeImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Alt metin bloğu — görselle ve alttaki "Devam Et" butonuyla
              // çakışmayan alan.
              Positioned(
                left: 0,
                right: 0,
                bottom: 130,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _stageAnimations[1],
                        child: SlideTransition(
                          position: Tween(
                            begin: const Offset(0, 0.15),
                            end: Offset.zero,
                          ).animate(_stageAnimations[1]),
                          child: Text(
                            'Fikrin burada şekil buluyor.',
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeTransition(
                        opacity: _stageAnimations[2],
                        child: SlideTransition(
                          position: Tween(
                            begin: const Offset(0, 0.15),
                            end: Offset.zero,
                          ).animate(_stageAnimations[2]),
                          child: Text(
                            'SET — yaratıcı işler platformu',
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Görselin köşelerini kırpıp yamuk/düzensiz bir kenar veren clipper.
class _TrapezoidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.08, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width * 0.92, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
