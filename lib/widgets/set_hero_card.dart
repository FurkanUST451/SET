import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'set_chip.dart';
import '../core/utils/turkish_case.dart';

class SetHeroCard extends StatelessWidget {
  const SetHeroCard({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.tag,
    this.decorativeIcon,
    this.onTap,
    this.aspectRatio = 16 / 10,
    this.featured = false,
    this.height,
    this.titleStyle,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final String? tag;
  final IconData? decorativeIcon;
  final VoidCallback? onTap;
  final double aspectRatio;
  final bool featured;
  final double? height;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppRadius.hero);

    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B232C),
              Color(0xFF0B0F14),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6ECF5),
              Color(0xFFF5F7FA),
            ],
          );

    final scrim = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? const [Colors.transparent, Color(0xCC0B0F14)]
          : [
              Colors.transparent,
              const Color(0xFF0B0F14).withValues(alpha: 0.55),
            ],
      stops: const [0.35, 1.0],
    );

    final shadows = <BoxShadow>[
      BoxShadow(
        color: isDark
            ? const Color(0xAA000000)
            : const Color(0x1A0E1419),
        blurRadius: 32,
        offset: const Offset(0, 18),
        spreadRadius: -6,
      ),
      if (featured)
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.25),
          blurRadius: 60,
          spreadRadius: -10,
        ),
    ];

    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(gradient: bgGradient),
          child: Stack(
            children: [
              // Decorative blue glow (top-right radial)
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Large faded decorative icon (bottom-right)
              if (decorativeIcon != null)
                Positioned(
                  bottom: -20,
                  right: -20,
                  child: Icon(
                    decorativeIcon,
                    size: 180,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                ),
              // Scrim
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: scrim),
                ),
              ),
              // Top-left tag chip
              if (tag != null)
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  child: SetChip(label: tag!),
                ),
              // Bottom-left content
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (eyebrow != null) ...[
                      Text(
                        eyebrow!.toUpperCaseTr(),
                        style: AppTextStyles.eyebrow.copyWith(
                          color: AppColors.accentCyan,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Text(
                      title,
                      style: (titleStyle ?? AppTextStyles.heading1).copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        subtitle!,
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final sized = height != null
        ? SizedBox(height: height, child: card)
        : AspectRatio(aspectRatio: aspectRatio, child: card);

    if (onTap == null) return sized;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: sized,
      ),
    );
  }
}
