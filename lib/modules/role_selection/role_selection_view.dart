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
const Color _kInk = Color(0xFF1A1A1A);
const Color _kMuted = Color(0xFF8B8377);
const Color _kDivider = Color(0x1F1A1A1A);

class RoleSelectionView extends GetView<RoleSelectionController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.roleSelectionEyebrow,
                    style: AppTextStyles.microLabel.copyWith(color: _kMuted),
                  ),
                  const SizedBox(height: 18),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.editorialDisplay.copyWith(
                        fontSize: 34,
                        color: _kInk,
                      ),
                      children: const [
                        TextSpan(text: 'Sen '),
                        TextSpan(
                          text: 'ne yapmak',
                          style: TextStyle(color: _kGold),
                        ),
                        TextSpan(text: ' için buradasın?'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(
                () => Column(
                  children: [
                    const SizedBox(height: 8),
                    Expanded(
                      child: _RoleRow(
                        number: '01',
                        category: AppStrings.roleClientCategory,
                        title: AppStrings.roleClient,
                        description: AppStrings.roleClientDesc,
                        archiveLabel: AppStrings.roleClientArchive,
                        image: AppAssets.roleTelephone,
                        selected: controller.selectedRole.value == UserRole.client,
                        onTap: () => controller.selectRole(UserRole.client),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: _kDivider, height: 1),
                    ),
                    Expanded(
                      child: _RoleRow(
                        number: '02',
                        category: AppStrings.roleFreelancerCategory,
                        title: AppStrings.roleFreelancer,
                        description: AppStrings.roleFreelancerDesc,
                        archiveLabel: AppStrings.roleFreelancerArchive,
                        image: AppAssets.roleCamera,
                        selected:
                            controller.selectedRole.value == UserRole.freelancer,
                        onTap: () => controller.selectRole(UserRole.freelancer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(
              () => AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: controller.selectedRole.value == null ? 0.4 : 1,
                child: GestureDetector(
                  onTap: controller.selectedRole.value == null
                      ? null
                      : controller.confirm,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    color: _kGold,
                    alignment: Alignment.center,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.roleContinue,
                                style: AppTextStyles.eyebrow.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleRow extends StatelessWidget {
  const _RoleRow({
    required this.number,
    required this.category,
    required this.title,
    required this.description,
    required this.archiveLabel,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final String number;
  final String category;
  final String title;
  final String description;
  final String archiveLabel;
  final String image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$number · $category',
                    style: AppTextStyles.eyebrow.copyWith(color: _kGold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: AppTextStyles.heading1.copyWith(color: _kInk),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTextStyles.body2.copyWith(color: _kMuted),
                  ),
                  const SizedBox(height: 14),
                  Container(width: 48, height: 2, color: _kGold),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        archiveLabel,
                        style: AppTextStyles.microLabel.copyWith(color: _kMuted),
                      ),
                      if (selected) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, size: 14, color: _kGold),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              height: 120,
              child: Image.asset(image, fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }
}
