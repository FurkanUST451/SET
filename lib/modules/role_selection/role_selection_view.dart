import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import 'role_selection_controller.dart';

class RoleSelectionView extends GetView<RoleSelectionController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.choosePageBg, fit: BoxFit.cover, cacheWidth: 1080),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                children: [
                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.wordmark.copyWith(
                      color: Colors.black87,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nasıl devam etmek istersin?',
                    style: AppTextStyles.body2.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _RoleCard(
                      label: 'Hizmet Al',
                      dark: false,
                      onTap: () => controller.select(UserRole.client),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _RoleCard(
                      label: 'Hizmet Ver',
                      dark: true,
                      onTap: () => controller.select(UserRole.freelancer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.dark,
    required this.onTap,
  });

  final String label;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF1A1A1A) : Colors.white.withValues(alpha: 0.88);
    final labelColor = dark ? const Color(0xFFE8B84B) : Colors.black87;
    final arrowBg = dark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);
    final arrowColor = dark ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.35 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.displayXL.copyWith(
                color: labelColor,
                fontSize: 42,
                height: 1.1,
              ),
            ),
            const Spacer(),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: arrowBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward, color: arrowColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
