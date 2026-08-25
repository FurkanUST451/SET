import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Onboarding 1. sayfa — logo + daktilo (typewriter) efektiyle yazılan
/// marka sloganı. Yazım bitince [onReady] çağrılır; ekrana dokunmak
/// yazımı anında tamamlayıp [onReady]'i erken tetikler.
class OnboardingBrandPage extends StatefulWidget {
  const OnboardingBrandPage({super.key, required this.onReady});

  final VoidCallback onReady;

  @override
  State<OnboardingBrandPage> createState() => _OnboardingBrandPageState();
}

class _OnboardingBrandPageState extends State<OnboardingBrandPage>
    with SingleTickerProviderStateMixin {
  static const String _text = 'Fikrini,\nyeteneğe bağla.';
  static const Duration _charDelay = Duration(milliseconds: 65);
  static const Duration _holdAfterTyped = Duration(milliseconds: 1300);

  late final AnimationController _cursorController;
  Timer? _typeTimer;
  Timer? _holdTimer;
  int _charCount = 0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    // 2. sayfadaki atlas.png'yi bu ekran açıkken önbelleğe al ki geçişte
    // takılma olmasın.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(const AssetImage(AppAssets.splashWelcomeImage), context);
    });

    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _typeTimer = Timer.periodic(_charDelay, (timer) {
      if (_charCount >= _text.length) {
        timer.cancel();
        _holdTimer = Timer(_holdAfterTyped, _markReady);
        return;
      }
      setState(() => _charCount++);
    });
  }

  void _skipTyping() {
    if (_ready) return;
    _typeTimer?.cancel();
    _holdTimer?.cancel();
    setState(() => _charCount = _text.length);
    _markReady();
  }

  void _markReady() {
    if (_ready) return;
    _ready = true;
    widget.onReady();
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _holdTimer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typed = _text.substring(0, _charCount);

    final textStyle = AppTextStyles.heading2.copyWith(
      color: AppColors.textPrimaryLight,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _skipTyping,
      child: Container(
        color: AppColors.backgroundLight,
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(AppAssets.loginLogo, height: 44),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: textStyle,
                  children: [
                    TextSpan(text: typed),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: AnimatedBuilder(
                        animation: _cursorController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _cursorController.value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 2,
                          height: (textStyle.fontSize ?? 26) * 0.85,
                          margin: const EdgeInsets.only(left: 3),
                          color: AppColors.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
