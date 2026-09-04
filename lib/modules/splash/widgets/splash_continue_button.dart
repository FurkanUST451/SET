import 'package:flutter/material.dart';

import '../../../core/theme/app_fonts.dart';

// Uygulamanın "ana hizmetler" (kategori seçim) ekranındaki "DEVAM ET"
// butonuyla birebir aynı stil — bkz. category_picker_view.dart,
// project_mode_view.dart, send_offer_view.dart. Yeni bir stil tanımlamak
// yerine iki splash ekranı da bunu paylaşır.
const Color kSplashContinueGold = Color(0xFFD9A84E);

class SplashContinueButton extends StatelessWidget {
  const SplashContinueButton({
    super.key,
    required this.onTap,
    required this.scale,
  });

  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 54 * s,
        color: kSplashContinueGold,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DEVAM ET',
              style: AppFonts.ui(
                fontSize: 11 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.8,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(width: 10 * s),
            Icon(Icons.arrow_forward_rounded, size: 16 * s, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
