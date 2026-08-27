import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../routes/app_routes.dart';
import 'widgets/splash_continue_button.dart';

// ─── Palet — uygulamanın kalan ekranlarıyla aynı (login/category_picker) ────
const _kInk = Color(0xFF35333F);
const _kGold = Color(0xFFD9A84E);

/// 1. splash ekranı — logo + daktilo efektiyle marka sloganı.
/// İkinci ekrana yalnızca "devam et" ile geçilir, otomatik geçiş yok.
class SplashBrandScreen extends StatefulWidget {
  const SplashBrandScreen({super.key});

  @override
  State<SplashBrandScreen> createState() => _SplashBrandScreenState();
}

class _SplashBrandScreenState extends State<SplashBrandScreen>
    with SingleTickerProviderStateMixin {
  static const String _slogan = 'Fikrini,\nyeteneğe bağla.';
  static const Duration _charDelay = Duration(milliseconds: 65);

  late final AnimationController _cursorController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  Timer? _typeTimer;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _typeTimer = Timer.periodic(_charDelay, (timer) {
      if (_charCount >= _slogan.length) {
        timer.cancel();
        return;
      }
      setState(() => _charCount++);
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  void _goNext() {
    Get.offNamed(AppRoutes.splashWelcome);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final s = (size.width / 390).clamp(0.85, 1.15).toDouble();
    final topInset = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final shown = _slogan.substring(0, _charCount);

    // Ekran dikeyde ikiye bölünür; logo + slogan alt yarının tavanına
    // (üst sınırına) yapıştırılır. Bu yalnızca bir konumlandırma — daktilo
    // animasyonunun kendisi değişmiyor.
    final topGap = (size.height / 2 - topInset).clamp(0.0, size.height);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: topGap),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 26 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo — uygulamanın diğer ekranlarındaki (login) boyutunun
                  // yaklaşık 2 katı büyüklükte gösteriliyor (%10 küçültüldü:
                  // 68 -> 61.2).
                  Image.asset(AppAssets.loginLogo, height: 61.2 * s),
                  SizedBox(height: 28 * s),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: shown,
                          style: AppFonts.display(
                            fontSize: 22 * s,
                            fontWeight: FontWeight.w700,
                            color: _kInk,
                            height: 1.2,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: FadeTransition(
                            opacity: _cursorController,
                            child: Container(
                              width: 2,
                              height: 20 * s,
                              margin: EdgeInsets.only(left: 2 * s),
                              color: _kGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SplashContinueButton(scale: s, onTap: _goNext),
            SizedBox(height: 12 * s + bottomPadding),
          ],
        ),
      ),
    );
  }
}
