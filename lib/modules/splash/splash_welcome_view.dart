import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../routes/app_routes.dart';
import 'widgets/splash_continue_button.dart';

// ─── Palet — uygulamanın kalan ekranlarıyla aynı (login/category_picker) ────
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);

/// 2. splash ekranı — yamuk kompozisyonlu görsel + marka vaadi.
class SplashWelcomeScreen extends StatefulWidget {
  const SplashWelcomeScreen({super.key});

  @override
  State<SplashWelcomeScreen> createState() => _SplashWelcomeScreenState();
}

class _SplashWelcomeScreenState extends State<SplashWelcomeScreen>
    with SingleTickerProviderStateMixin {
  // ── Staggered giriş animasyonu zamanlaması (ms) ──────────────────────────
  // Başlık: sayfa açılışından 180ms sonra başlar, 750ms sürer (930ms'de
  // biter).
  static const int _titleDelayMs = 180;
  static const int _titleDurationMs = 750;
  // Alt yazı: başlık tamamen bittikten sonra, 150ms'lik ek bir boşlukla
  // başlar (930+150=1080ms) — böylece iki cümle üst üste binmeden, art
  // arda gelir.
  static const int _subtitleDelayMs = _titleDelayMs + _titleDurationMs + 150;
  static const int _subtitleDurationMs = 650;
  // Buton: alt yazının başlangıcından 350ms sonra başlar, aniden değil
  // kendi de fade-in ile belirir.
  static const int _buttonDelayMs = _subtitleDelayMs + 350;
  static const int _buttonDurationMs = 350;
  // Kontrolcünün toplam süresi — en geç biten öğeyi (buton) küçük bir
  // payla kapsayacak şekilde.
  static const int _totalMs = _buttonDelayMs + _buttonDurationMs + 100;

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _totalMs),
  );

  // Başlık: soldan hızla kayarak gelir + fade-in, hızlı başlayıp yavaşça
  // yerine oturur (easeOutExpo).
  late final Animation<double> _titleAnim = CurvedAnimation(
    parent: _intro,
    curve: Interval(
      _titleDelayMs / _totalMs,
      (_titleDelayMs + _titleDurationMs) / _totalMs,
      curve: Curves.easeOutExpo,
    ),
  );

  // Alt yazı: başlıkla aynı soldan kayma efekti, kendi gecikmesiyle art
  // arda gelir.
  late final Animation<double> _subtitleAnim = CurvedAnimation(
    parent: _intro,
    curve: Interval(
      _subtitleDelayMs / _totalMs,
      (_subtitleDelayMs + _subtitleDurationMs) / _totalMs,
      curve: Curves.easeOutExpo,
    ),
  );

  // Buton: yalnızca fade-in, ease-out.
  late final Animation<double> _buttonAnim = CurvedAnimation(
    parent: _intro,
    curve: Interval(
      _buttonDelayMs / _totalMs,
      (_buttonDelayMs + _buttonDurationMs) / _totalMs,
      curve: Curves.easeOut,
    ),
  );

  bool _precached = false;

  @override
  void initState() {
    super.initState();
    // Görsel zaten statik — beklemeden, sayfa açılır açılmaz başlar.
    _intro.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ana görsel artık statik olsa da geç yüklenme takılmasını önlemek için
    // splash başlamadan önce yükleniyor.
    if (!_precached) {
      _precached = true;
      precacheImage(const AssetImage(AppAssets.splashHeroAtlas), context);
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _goNext() {
    Get.offAllNamed(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final s = (size.width / 390).clamp(0.85, 1.15).toDouble();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Logo — login ekranındaki ile aynı konum (sol üst) ve boyutta.
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(26 * s, 12 * s, 26 * s, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset(AppAssets.loginLogo, height: 34 * s),
              ),
            ),
          ),
          // Logo ile görsel arasındaki esnek boşluk — kalan boş alanı burada
          // toplar, böylece görsel her zaman sabit boyutta kalır ve metnin
          // hemen üstüne yapışık durur.
          const Expanded(child: SizedBox()),

          // Ana görsel — sabit boyutlu bir alana yerleşir, kasıtlı eğik,
          // sol kenardan taşıyor. Metin bloğunun hemen üstünde yer alır.
          SizedBox(
            height: size.height * 0.5,
            child: OverflowBox(
              alignment: Alignment.centerRight,
              maxWidth: size.width * 1.5,
              minWidth: 0,
              child: Transform.translate(
                offset: Offset(-size.width * 0.14, 0),
                child: Transform.rotate(
                  angle: -11 * math.pi / 180,
                  child: Image.asset(
                    AppAssets.splashHeroAtlas,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16 * s),

          // Başlık + alt yazı — devam et butonunun hemen üstünde. Her biri
          // kendi gecikme/süresiyle ayrı ayrı belirir (staggered).
          Padding(
            padding: EdgeInsets.only(left: 16 * s, right: 26 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _titleAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset((1 - _titleAnim.value) * -70 * s, 0),
                      child: Opacity(opacity: _titleAnim.value, child: child),
                    );
                  },
                  child: Text(
                    'Fikrin burada şekil buluyor.',
                    style: AppFonts.display(
                      fontSize: 26 * s,
                      fontWeight: FontWeight.w700,
                      color: _kInk,
                      height: 1.1,
                    ),
                  ),
                ),
                SizedBox(height: 10 * s),
                AnimatedBuilder(
                  animation: _subtitleAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset((1 - _subtitleAnim.value) * -70 * s, 0),
                      child: Opacity(
                        opacity: _subtitleAnim.value,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    'SET — yaratıcı işler platformu',
                    style: AppFonts.ui(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w700,
                      color: _kTaupe,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * s),

          // Devam et butonu — ekranın sağına/soluna tam yaslı, dipten
          // güvenli alan payıyla ayrık. Kendisi de fade-in ile belirir.
          FadeTransition(
            opacity: _buttonAnim,
            child: SplashContinueButton(scale: s, onTap: _goNext),
          ),
          SizedBox(height: bottomPadding + 20 * s),
        ],
      ),
    );
  }
}
