import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'onboarding_controller.dart';

const Color _cinematicGold = Color(0xFFD9B36A);
const Color _cinematicCream = Color(0xFFE8D8B8);
const Color _cinematicInk = Color(0xFF1A1410);

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final pages = OnboardingController.pages;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Sadece aktif sayfa ve komşusu render edilir; bellek baskısını azaltır.
              for (int i = 0; i < pages.length; i++)
                AnimatedBuilder(
                  animation: controller.pageController,
                  builder: (_, child) {
                    final p = controller.pageController.hasClients
                        ? (controller.pageController.page ?? 0.0)
                        : 0.0;
                    if ((i - p).abs() > 1.5) return const SizedBox.shrink();
                    return Transform.translate(
                      offset: Offset((i - p) * w, 0),
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: w,
                    height: h,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (pages[i].backgroundImage != null)
                          Image.asset(
                            pages[i].backgroundImage!,
                            fit: BoxFit.cover,
                            cacheWidth: w.toInt().clamp(1, 1080),
                          ),
                        if (pages[i].mascotImage != null)
                          Center(
                            child: Image.asset(
                              pages[i].mascotImage!,
                              cacheWidth: (w * 0.8).toInt().clamp(1, 800),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // Saydam PageView — sadece swipe gesture için
              Positioned.fill(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: pages.length,
                  itemBuilder: (_, __) => const SizedBox.expand(),
                ),
              ),

              // Devam butonu
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.xl + bottomPadding,
                child: Obx(() => _ContinueButton(
                      text: controller.isLastPage
                          ? 'Başla'
                          : AppStrings.continueLabel,
                      onPressed: controller.next,
                    )),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.full);
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _cinematicCream,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: _cinematicCream.withValues(alpha: 0.3),
              blurRadius: 28,
              offset: const Offset(0, 10),
              spreadRadius: -6,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            splashColor: _cinematicGold.withValues(alpha: 0.3),
            highlightColor: _cinematicGold.withValues(alpha: 0.15),
            child: Center(
              child: Text(
                text,
                style: AppTextStyles.button.copyWith(
                  color: _cinematicInk,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
