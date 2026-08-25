import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_text_styles.dart';
import 'onboarding_brand_page.dart';
import 'onboarding_controller.dart';
import 'onboarding_welcome_page.dart';

// Uygulamanın geri kalanında (ana hizmetler, login, vb.) kullanılan altın
// tonuyla aynı — bkz. diğer ekranlardaki `_kGold`.
const Color _kGold = Color(0xFFD9A84E);

/// Kullanıcının ilk açılışta gördüğü iki adımlı hoşgeldin akışı: marka
/// (typewriter) ve görsel kompozisyon sayfaları, her birinin giriş
/// animasyonu bitince soldan kayarak beliren "Devam Et" / "Başla" butonuyla
/// ilerlenir.
class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              child: controller.currentPage.value == 0
                  ? OnboardingBrandPage(
                      key: const ValueKey('brand'),
                      onReady: controller.onPageReady,
                    )
                  : OnboardingWelcomePage(
                      key: const ValueKey('welcome'),
                      onReady: controller.onPageReady,
                    ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() {
              final visible = controller.canContinue.value;
              return IgnorePointer(
                ignoring: !visible,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOut,
                  offset: visible ? Offset.zero : const Offset(-1.3, 0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOut,
                    opacity: visible ? 1 : 0,
                    child: _GoldContinueButton(
                      text: controller.isLastPage ? 'Başla' : 'Devam Et',
                      active: visible,
                      onPressed: controller.next,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Sarı/altın "Devam Et" butonu. Buton sahneye yerleşince (slide-in
/// tamamlanınca) üzerinden bir ışık yansıması geçer.
class _GoldContinueButton extends StatefulWidget {
  const _GoldContinueButton({
    required this.text,
    required this.onPressed,
    required this.active,
  });

  final String text;
  final VoidCallback onPressed;
  final bool active;

  @override
  State<_GoldContinueButton> createState() => _GoldContinueButtonState();
}

class _GoldContinueButtonState extends State<_GoldContinueButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didUpdateWidget(covariant _GoldContinueButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) {
      // Buton yerine oturduktan (slide-in ~420ms) hemen sonra ışık geçsin.
      Future.delayed(const Duration(milliseconds: 430), () {
        if (mounted) _shineController.forward(from: 0);
      });
    } else if (!widget.active) {
      _shineController.value = 0;
    }
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: Material(
        color: _kGold,
        child: InkWell(
          onTap: widget.onPressed,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomSafe),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.text.toUpperCase(),
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                      AnimatedBuilder(
                        animation: _shineController,
                        builder: (context, child) {
                          final w = constraints.maxWidth;
                          final dx = _shineController.value * (w + 120) - 60;
                          return IgnorePointer(
                            child: Transform.translate(
                              offset: Offset(dx, 0),
                              child: Transform.rotate(
                                angle: -0.35,
                                child: Container(
                                  width: 36,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0),
                                        Colors.white.withValues(alpha: 0.5),
                                        Colors.white.withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
