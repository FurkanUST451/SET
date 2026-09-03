import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/turkish_case.dart';

class SetSectionHeader extends StatelessWidget {
  const SetSectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.description,
    this.action,
    this.onActionTap,
    this.large = false,
  });

  final String title;
  final String? eyebrow;
  final String? description;
  final String? action;
  final VoidCallback? onActionTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final titleStyle = large ? AppTextStyles.displayXL : AppTextStyles.heading1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCaseTr(),
            style: AppTextStyles.eyebrow.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Text(title, style: titleStyle)),
            if (action != null)
              TextButton(
                onPressed: onActionTap,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  action!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            description!,
            style: AppTextStyles.body2.copyWith(color: secondaryColor),
          ),
        ],
      ],
    );
  }
}
