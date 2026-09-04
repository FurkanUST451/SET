import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import 'role_selection_controller.dart';

// Uygulama genelinde "DEVAM ET" butonunun kullandığı renk — bkz.
// splash_continue_button.dart, category_picker_view.dart.
const Color _kGold = Color(0xFFD9A84E);
const Color _kCream = Color(0xFFF4EFE4);
const Color _kCard = Color(0xFFFBF8F1);
const Color _kInk = Color(0xFF1A1A1A);
const Color _kMuted = Color(0xFF8B8377);
const Color _kDivider = Color(0x1F1A1A1A);

/// Kartın esnemediği durumdaki doğal yüksekliği.
const double _kCardBaseHeight = 190;

/// Kartların esneyip ekranı doldurabilmesi için gereken en az ekran boyu;
/// altında kalan cihazlarda doğal boyutlu + kaydırmalı düzene düşülür.
const double _kFlexibleLayoutMinHeight = 640;

class RoleSelectionView extends GetView<RoleSelectionController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final clientCard = Obx(
              () => _RoleCard(
                number: '01',
                category: AppStrings.roleClientCategory,
                title: AppStrings.roleClient,
                description: AppStrings.roleClientDesc,
                ctaLabel: AppStrings.roleClientCta,
                image: AppAssets.roleTelephone,
                busy: controller.isLoading.value &&
                    controller.selectedRole.value == UserRole.client,
                onTap: () => controller.selectAndContinue(UserRole.client),
              ),
            );
            final freelancerCard = Obx(
              () => _RoleCard(
                number: '02',
                category: AppStrings.roleFreelancerCategory,
                title: AppStrings.roleFreelancer,
                description: AppStrings.roleFreelancerDesc,
                ctaLabel: AppStrings.roleFreelancerCta,
                image: AppAssets.roleCamera,
                busy: controller.isLoading.value &&
                    controller.selectedRole.value == UserRole.freelancer,
                onTap: () => controller.selectAndContinue(UserRole.freelancer),
              ),
            );

            // Kısa ekran: eski davranış — doğal yükseklik + kaydırma.
            if (constraints.maxHeight < _kFlexibleLayoutMinHeight) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Header(),
                    const SizedBox(height: 14),
                    SizedBox(height: _kCardBaseHeight, child: clientCard),
                    const SizedBox(height: 14),
                    SizedBox(height: _kCardBaseHeight, child: freelancerCard),
                    const SizedBox(height: 32),
                    const _Footnote(),
                  ],
                ),
              );
            }

            // Normal ekran: kartlar kalan dikey alanı paylaşır.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                const SizedBox(height: 14),
                Expanded(child: clientCard),
                const SizedBox(height: 14),
                Expanded(child: freelancerCard),
                const SizedBox(height: 28),
                const _Footnote(),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Footnote extends StatelessWidget {
  const _Footnote();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppStrings.roleSelectionFootnote,
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          color: _kMuted,
          decoration: TextDecoration.underline,
          decorationColor: _kMuted,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.roleSelectionEyebrow,
            style: AppTextStyles.microLabel.copyWith(color: _kMuted),
          ),
          const SizedBox(height: 14),
          const Divider(color: _kDivider, height: 1),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              style: AppTextStyles.editorialDisplay.copyWith(
                fontSize: 38,
                color: _kInk,
              ),
              children: const [
                TextSpan(text: 'Sen '),
                TextSpan(text: 'ne yapmak', style: TextStyle(color: _kGold)),
                TextSpan(text: ' için buradasın?'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.roleSelectionSubtitle,
            style: AppTextStyles.body2.copyWith(color: _kMuted),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.number,
    required this.category,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.image,
    required this.busy,
    required this.onTap,
  });

  final String number;
  final String category;
  final String title;
  final String description;
  final String ctaLabel;
  final String image;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: _kCard,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Tipografi sabit kalır; kart uzadıkça yalnızca görsel büyür.
            // Üst sınır 144: metin sütunu CTA satırını tek satırda taşıyacak
            // kadar geniş kalsın diye.
            final imageSize = constraints.hasBoundedHeight
                ? (constraints.maxHeight * 0.6).clamp(108.0, 144.0)
                : 108.0;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 12, 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$number · $category',
                          style: AppTextStyles.eyebrow.copyWith(color: _kGold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: AppTextStyles.heading2.copyWith(color: _kInk),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: AppTextStyles.body2.copyWith(color: _kMuted),
                        ),
                        const SizedBox(height: 18),
                        Container(width: 120, height: 1, color: _kGold),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                ctaLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.eyebrow
                                    .copyWith(color: _kGold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: _kGold,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: Image.asset(image, fit: BoxFit.contain),
                  ),
                  SizedBox(
                    width: 36,
                    child: Center(
                      child: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _kGold,
                              ),
                            )
                          : const Icon(
                              Icons.chevron_right_rounded,
                              size: 28,
                              color: _kGold,
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
