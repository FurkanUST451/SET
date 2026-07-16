import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_assets.dart';
import '../../../routes/app_routes.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);

TextStyle _serif({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
}) => GoogleFonts.cormorantGaramond(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

TextStyle _mono({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
}) => GoogleFonts.spaceMono(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
);

class ChooseAuthView extends StatelessWidget {
  const ChooseAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32 * s),
            child: Column(
              children: [
                const Spacer(),
                Image.asset(AppAssets.loginLogo, height: 72 * s),
                SizedBox(height: 28 * s),
                Text(
                  'Tüm kreatif süreçler.\nTek yerde.',
                  textAlign: TextAlign.center,
                  style: _serif(
                    size: 26 * s,
                    weight: FontWeight.w600,
                    color: _kInk,
                  ),
                ),
                const Spacer(),
                _AuthButton(
                  scale: s,
                  label: 'Google ile devam et',
                  icon: AppAssets.loginGoogle,
                  onTap: () {},
                  dark: false,
                ),
                SizedBox(height: 10 * s),
                _AuthButton(
                  scale: s,
                  label: 'Apple ile devam et',
                  icon: AppAssets.loginApple,
                  onTap: () {},
                  dark: true,
                ),
                SizedBox(height: 10 * s),
                _AuthButton(
                  scale: s,
                  label: 'E-posta ile devam et',
                  icon: AppAssets.loginEmail,
                  onTap: () => Get.toNamed(AppRoutes.login),
                  dark: false,
                ),
                SizedBox(height: 26 * s),
                GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'MİSAFİR OLARAK DEVAM ET',
                    style: _mono(
                      size: 9 * s,
                      weight: FontWeight.w600,
                      color: _kTaupe,
                      spacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 20 * s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.scale,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.dark,
  });

  final double scale;
  final String label;
  final String icon;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52 * s,
        decoration: BoxDecoration(
          color: dark ? _kInk : Colors.white,
          border: dark
              ? null
              : Border.all(color: Colors.black.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, height: 20 * s, width: 20 * s),
            SizedBox(width: 12 * s),
            Text(
              label,
              style: _mono(
                size: 10.5 * s,
                weight: FontWeight.w700,
                color: dark ? Colors.white : _kInk,
                spacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
