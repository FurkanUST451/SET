import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/constants/app_assets.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import 'login_controller.dart';
import '../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kDanger = Color(0xFFBE6A5A);
const _kCardBorder = Color(0x1F000000);

TextStyle _ui({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
}) => AppFonts.ui(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
);

TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
  bool italic = false,
}) => AppFonts.display(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
);

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final LoginController controller = Get.find<LoginController>();

  // ── Açılış zamanlaması (tek bir controller üzerinden yönetilir) ───────
  // Toplam süre 3.09sn — sayfa boş açılır, sonra parçalar sırayla yerine
  // oturur. Varsayılan giriş yönü alttan yukarı; sadece breadcrumb sağdan girer.
  // Marka bloğu (SET + "Kreativitenin merkezi") kendi başına soft+hızlı bir
  // eğriyle girer; ondan sonraki tüm parçalar eski zamanlamaya göre 1.3 kat
  // hızlandırılmıştır.
  // 0-420ms        SET logosu + "Kreativitenin merkezi" alttan soft+hızlı girer
  // 420-805ms      bekler / okunur                          (385ms)
  // 805-1150ms     "GİRİŞ / 01" breadcrumb'ı sağdan girer
  // 1150-1495ms    "tekrar hoş geldin." başlığı hemen ardından alttan girer
  // 1610-1825ms    e-posta alanı (kart + köşe süslemesiyle birlikte) belirir
  // 1935-2150ms    şifre alanı + "Şifremi unuttum?" belirir
  // 2260-2475ms    giriş yap butonu + "Hesabın yok mu?" satırı belirir
  // 2585-2770ms    "VEYA" ayracı belirir
  // 2880-3090ms    Google/Apple seçenekleri + güvenlik notu belirir
  static const int _totalMs = 3090;
  static const double _brandStart = 0 / _totalMs;
  static const double _brandEnd = 420 / _totalMs;
  static const double _breadcrumbStart = 805 / _totalMs;
  static const double _breadcrumbEnd = 1150 / _totalMs;
  static const double _headlineStart = _breadcrumbEnd;
  static const double _headlineEnd = 1495 / _totalMs;
  static const double _emailStart = 1610 / _totalMs;
  static const double _emailEnd = 1825 / _totalMs;
  static const double _passwordStart = 1935 / _totalMs;
  static const double _passwordEnd = 2150 / _totalMs;
  static const double _buttonStart = 2260 / _totalMs;
  static const double _buttonEnd = 2475 / _totalMs;
  static const double _veyaStart = 2585 / _totalMs;
  static const double _veyaEnd = 2770 / _totalMs;
  static const double _authStart = 2880 / _totalMs;
  static const double _authEnd = 3090 / _totalMs;

  final FocusNode _emailFocusNode = FocusNode();

  // Bu alanlar View'ın kendi State'ine ait: GetX, LoginController'ı sayfa
  // geçiş animasyonu bitmeden (henüz ekranda görünürken) dispose edebiliyor.
  // Controller'lar GetxController'a bağlı olsaydı, çıkış animasyonu sırasında
  // "used after being disposed" hatası oluşuyordu.
  final TextEditingController _emailController = TextEditingController(
    text: 'ornek@set.app',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '123456',
  );
  final TextEditingController _resetEmailController = TextEditingController();

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _totalMs),
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    _emailFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _submit() => controller.submit(
    email: _emailController.text,
    password: _passwordController.text,
  );

  double _reveal(
    double t,
    double start,
    double end, {
    Curve curve = Curves.easeOutCubic,
  }) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return curve.transform((t - start) / (end - start));
  }

  Widget _revealed(
    double t,
    double start,
    double end,
    double s,
    Widget child, {
    Curve curve = Curves.easeOutCubic,
  }) {
    final r = _reveal(t, start, end, curve: curve);
    return Transform.translate(
      offset: Offset(0, (1 - r) * 26 * s),
      child: Opacity(opacity: r, child: child),
    );
  }

  // Breadcrumb sağdan gelir — diğer tüm parçalar alttan gelir.
  Widget _revealedFromRight(
    double t,
    double start,
    double end,
    double s,
    Widget child,
  ) {
    final r = _reveal(t, start, end);
    return Transform.translate(
      offset: Offset((1 - r) * 60 * s, 0),
      child: Opacity(opacity: r, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double s = (size.width / 390).clamp(0.85, 1.15).toDouble();

    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: c),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _kCream,
        body: AnimatedBuilder(
          animation: _intro,
          builder: (context, _) {
            final t = _intro.value;
            return MediaQuery.withNoTextScaling(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(0, 24 * s, 0, 24 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Kalıcı marka bloğu — alttan girer ───────────────
                      _revealed(
                        t,
                        _brandStart,
                        _brandEnd,
                        s,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 26 * s),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(AppAssets.loginLogo, height: 34 * s),
                              SizedBox(height: 8 * s),
                              Text(
                                'KREATİVİTENİN MERKEZİ',
                                style: _ui(
                                  size: 10 * s,
                                  weight: FontWeight.w700,
                                  color: _kInk,
                                  spacing: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        curve: Curves.easeOutQuart,
                      ),
                      SizedBox(height: 28 * s),
                      // ─── Breadcrumb — sağdan girer ────────────────────────
                      _revealedFromRight(
                        t,
                        _breadcrumbStart,
                        _breadcrumbEnd,
                        s,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 26 * s),
                          child: Row(
                            children: [
                              Text(
                                'GİRİŞ / 01',
                                style: _ui(
                                  size: 10 * s,
                                  weight: FontWeight.w700,
                                  color: _kGold,
                                  spacing: 1.5,
                                ),
                              ),
                              SizedBox(width: 10 * s),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: _kCardBorder,
                                ),
                              ),
                              SizedBox(width: 10 * s),
                              Text(
                                'SET · v1.0',
                                style: _ui(
                                  size: 9 * s,
                                  color: _kTaupe,
                                  spacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12 * s),
                      // ─── "tekrar hoş geldin." başlığı — alttan girer ─────
                      _revealed(
                        t,
                        _headlineStart,
                        _headlineEnd,
                        s,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 26 * s),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'tekrar\n',
                                  style: _display(
                                    size: 22 * s,
                                    weight: FontWeight.w500,
                                    color: _kInk,
                                    height: 1.1,
                                    italic: true,
                                  ),
                                ),
                                TextSpan(
                                  text: 'hoş ',
                                  style: _display(
                                    size: 32 * s,
                                    weight: FontWeight.w700,
                                    color: _kInk,
                                    height: 1.1,
                                  ),
                                ),
                                TextSpan(
                                  text: 'geldin.',
                                  style: _display(
                                    size: 32 * s,
                                    weight: FontWeight.w700,
                                    color: _kGold,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 22 * s),
                      // ─── Kart (köşe süslemeli) — e-posta ile birlikte girer ─
                      _revealed(
                        t,
                        _emailStart,
                        _emailEnd,
                        s,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 26 * s),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(18 * s),
                                color: Colors.white,
                                child: Form(
                                  key: controller.formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'E-POSTA',
                                            style: _ui(
                                              size: 10 * s,
                                              weight: FontWeight.w700,
                                              color: _kBlack,
                                              spacing: 1.1,
                                            ),
                                          ),
                                          SizedBox(height: 6 * s),
                                          TextFormField(
                                            controller: _emailController,
                                            focusNode: _emailFocusNode,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: Validators.email,
                                            cursorColor: _kGold,
                                            style: _ui(
                                              size: 11 * s,
                                              color: _kBlack,
                                              spacing: 0.2,
                                            ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              filled: true,
                                              fillColor: _kCream,
                                              hintText: 'ornek@set.app',
                                              hintStyle: _ui(
                                                size: 11 * s,
                                                color: _kTaupe,
                                                spacing: 0.2,
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 12 * s,
                                                vertical: 12 * s,
                                              ),
                                              border: border(_kCardBorder),
                                              enabledBorder:
                                                  border(_kCardBorder),
                                              focusedBorder: border(_kGold),
                                              errorBorder: border(_kDanger),
                                              focusedErrorBorder:
                                                  border(_kDanger),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 14 * s),
                                      _revealed(
                                        t,
                                        _passwordStart,
                                        _passwordEnd,
                                        s,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _PasswordField(
                                              scale: s,
                                              controller: controller,
                                              textController:
                                                  _passwordController,
                                              border: border,
                                              onSubmitted: _submit,
                                            ),
                                            SizedBox(height: 10 * s),
                                            Align(
                                              alignment:
                                                  Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _showForgotPasswordSheet(
                                                  context,
                                                  controller,
                                                  _emailController,
                                                  _resetEmailController,
                                                  s,
                                                ),
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                child: Text(
                                                  'ŞİFREMİ UNUTTUM',
                                                  style: _ui(
                                                    size: 10 * s,
                                                    weight: FontWeight.w700,
                                                    color: _kTaupe,
                                                    spacing: 0.8,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 14 * s),
                                      _revealed(
                                        t,
                                        _buttonStart,
                                        _buttonEnd,
                                        s,
                                        Column(
                                          children: [
                                            _LoginButton(
                                              scale: s,
                                              controller: controller,
                                              onSubmit: _submit,
                                            ),
                                            SizedBox(height: 18 * s),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  AppStrings.dontHaveAccount
                                                      .toUpperCaseTr(),
                                                  style: _ui(
                                                    size: 10 * s,
                                                    color: _kTaupe,
                                                    spacing: 0.3,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: controller
                                                      .goToRegister,
                                                  behavior: HitTestBehavior
                                                      .opaque,
                                                  child: Padding(
                                                    padding: EdgeInsets
                                                        .symmetric(
                                                      horizontal: 6 * s,
                                                    ),
                                                    child: Text(
                                                      AppStrings.register
                                                          .toUpperCaseTr(),
                                                      style: _ui(
                                                        size: 10 * s,
                                                        weight:
                                                            FontWeight.w700,
                                                        color: _kGold,
                                                        spacing: 0.3,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20 * s),
                                      _revealed(
                                        t,
                                        _veyaStart,
                                        _veyaEnd,
                                        s,
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                color: _kCardBorder,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10 * s,
                                              ),
                                              child: Text(
                                                'VEYA',
                                                style: _ui(
                                                  size: 10 * s,
                                                  weight: FontWeight.w700,
                                                  color: _kTaupe,
                                                  spacing: 1.5,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                color: _kCardBorder,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 16 * s),
                                      _revealed(
                                        t,
                                        _authStart,
                                        _authEnd,
                                        s,
                                        _AuthOptionsRow(
                                          scale: s,
                                          controller: controller,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -8 * s,
                                left: -8 * s,
                                child: _CornerBracket(
                                  scale: s,
                                  top: true,
                                  left: true,
                                ),
                              ),
                              Positioned(
                                bottom: -8 * s,
                                right: -8 * s,
                                child: _CornerBracket(
                                  scale: s,
                                  top: false,
                                  left: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 22 * s),
                      _revealed(
                        t,
                        _authStart,
                        _authEnd,
                        s,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 26 * s),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 11 * s,
                                color: _kTaupe,
                              ),
                              SizedBox(width: 6 * s),
                              Flexible(
                                child: Text(
                                  'Verilerin güvende. SET, KVKK kapsamında korunur.',
                                  style: _ui(
                                    size: 8 * s,
                                    color: _kTaupe,
                                    spacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Şifre alanı ──────────────────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.scale,
    required this.controller,
    required this.textController,
    required this.border,
    required this.onSubmitted,
  });

  final double scale;
  final LoginController controller;
  final TextEditingController textController;
  final OutlineInputBorder Function(Color) border;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ŞİFRE',
          style: _ui(
            size: 10 * s,
            weight: FontWeight.w700,
            color: _kBlack,
            spacing: 1.1,
          ),
        ),
        SizedBox(height: 6 * s),
        Obx(
          () => TextFormField(
            controller: textController,
            obscureText: controller.obscurePassword.value,
            textInputAction: TextInputAction.done,
            validator: Validators.password,
            cursorColor: _kGold,
            style: _ui(size: 11 * s, color: _kBlack, spacing: 0.2),
            onFieldSubmitted: (_) => onSubmitted(),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: _kCream,
              hintText: '••••••',
              hintStyle: _ui(size: 11 * s, color: _kTaupe, spacing: 0.2),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12 * s,
                vertical: 12 * s,
              ),
              border: border(_kCardBorder),
              enabledBorder: border(_kCardBorder),
              focusedBorder: border(_kGold),
              errorBorder: border(_kDanger),
              focusedErrorBorder: border(_kDanger),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18 * s,
                  color: _kTaupe,
                ),
                onPressed: controller.toggleObscure,
              ),
            ),
          ),
        ),
        Obx(() {
          final err = controller.errorMessage.value;
          if (err == null) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(top: 10 * s),
            child: Text(
              err,
              style: _ui(size: 9 * s, color: _kDanger, spacing: 0.2),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Giriş yap butonu ─────────────────────────────────────────────────────
class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.scale,
    required this.controller,
    required this.onSubmit,
  });

  final double scale;
  final LoginController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Obx(
      () => GestureDetector(
        onTap: controller.isLoading.value ? null : onSubmit,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: 54 * s,
          color: _kGold,
          alignment: Alignment.center,
          child: controller.isLoading.value
              ? SizedBox(
                  height: 20 * s,
                  width: 20 * s,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  AppStrings.login.toUpperCaseTr(),
                  style: _ui(
                    size: 11 * s,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    spacing: 1.2,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Google/Apple seçenekleri (ortalanmış, kare çerçeve) ────────────────────
class _AuthOptionsRow extends StatelessWidget {
  const _AuthOptionsRow({required this.scale, required this.controller});

  final double scale;
  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 140 * s,
          child: Obx(
            () => _AuthIconButton(
              scale: s,
              icon: AppAssets.loginGoogle,
              label: 'GOOGLE',
              onTap: controller.isLoading.value
                  ? null
                  : controller.loginWithGoogle,
            ),
          ),
        ),
        SizedBox(width: 12 * s),
        SizedBox(
          width: 140 * s,
          child: _AuthIconButton(
            scale: s,
            icon: AppAssets.loginApple,
            label: 'APPLE',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _AuthIconButton extends StatelessWidget {
  const _AuthIconButton({
    required this.scale,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final double scale;
  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 62 * s,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _kCardBorder),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(icon, height: 18 * s, fit: BoxFit.contain),
            SizedBox(height: 6 * s),
            Text(
              label,
              style: _ui(
                size: 10 * s,
                weight: FontWeight.w700,
                color: _kInk,
                spacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Kart köşe süslemesi ──────────────────────────────────────────────────
class _CornerBracket extends StatelessWidget {
  const _CornerBracket({
    required this.scale,
    required this.top,
    required this.left,
  });

  final double scale;
  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    final double len = 22 * scale;
    const double thickness = 2;
    return SizedBox(
      width: len,
      height: len,
      child: Stack(
        children: [
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: left ? 0 : null,
            right: left ? null : 0,
            child: Container(width: len, height: thickness, color: _kGold),
          ),
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: left ? 0 : null,
            right: left ? null : 0,
            child: Container(width: thickness, height: len, color: _kGold),
          ),
        ],
      ),
    );
  }
}

// ─── Şifremi unuttum alt sayfası ────────────────────────────────────────────
void _showForgotPasswordSheet(
  BuildContext context,
  LoginController controller,
  TextEditingController emailController,
  TextEditingController resetEmailController,
  double s,
) {
  resetEmailController.text = emailController.text;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: _kCream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (ctx) {
      OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: c),
      );
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20 * s,
          20 * s,
          20 * s,
          MediaQuery.of(ctx).viewInsets.bottom + 20 * s,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Şifreni sıfırla',
              style: _display(size: 24 * s, weight: FontWeight.w600, color: _kInk),
            ),
            SizedBox(height: 6 * s),
            Text(
              'E-postana bir sıfırlama bağlantısı gönderelim.',
              style: _ui(size: 9 * s, color: _kBlack, spacing: 0.2),
            ),
            SizedBox(height: 16 * s),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              cursorColor: _kGold,
              style: _ui(size: 11 * s, color: _kBlack, spacing: 0.2),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'ornek@set.app',
                hintStyle: _ui(size: 11 * s, color: _kTaupe, spacing: 0.2),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14 * s,
                  vertical: 14 * s,
                ),
                border: border(Colors.black.withValues(alpha: 0.12)),
                enabledBorder: border(Colors.black.withValues(alpha: 0.12)),
                focusedBorder: border(_kGold),
              ),
            ),
            SizedBox(height: 18 * s),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => GestureDetector(
                  onTap: controller.isSendingReset.value
                      ? null
                      : () => controller.sendPasswordReset(
                          resetEmailController.text,
                        ),
                  child: Container(
                    height: 50 * s,
                    color: _kGold,
                    alignment: Alignment.center,
                    child: controller.isSendingReset.value
                        ? SizedBox(
                            width: 18 * s,
                            height: 18 * s,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Bağlantı Gönder',
                            style: _ui(
                              size: 10 * s,
                              weight: FontWeight.w700,
                              color: Colors.white,
                              spacing: 0.6,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
