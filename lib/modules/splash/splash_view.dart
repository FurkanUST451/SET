import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: _SplashImageCarousel(),
      ),
    );
  }
}

// Uygulama hazır olana kadar page_images görsellerini sırayla
// çapraz geçişle (crossfade) döngüye alır.
class _SplashImageCarousel extends StatefulWidget {
  const _SplashImageCarousel();

  @override
  State<_SplashImageCarousel> createState() => _SplashImageCarouselState();
}

class _SplashImageCarouselState extends State<_SplashImageCarousel> {
  // 1.7 kat hızlandırıldı (350ms → ~206ms).
  static const _interval = Duration(milliseconds: 206);

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_interval, (_) {
      setState(() {
        _index = (_index + 1) % AppAssets.splashPageImages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 147,
      height: 147,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 88),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: Image.asset(
          AppAssets.splashPageImages[_index],
          key: ValueKey(_index),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
