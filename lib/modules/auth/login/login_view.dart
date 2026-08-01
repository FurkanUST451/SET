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
}) => AppFonts.display(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
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
  // Toplam süre 4.59sn — logo/etiket yerleşince e-posta/şifre/şifremi
  // unuttum/buton/diğer giriş seçenekleri art arda hızlıca belirir (bekleme yok).
  // 0-900ms        "HOŞ GELDİN" alttan girer
  // 900-1650ms     bekler / okunur                          (750ms)
  // 1650-2550ms    "HOŞ GELDİN" yukarı çıkıp kaybolur / logo
  //                + "Tüm kreatif süreçler. Tek yerde." alttan girer
  // 2550-2830ms    e-posta alanı hızlıca belirir
  // 2970-3250ms    şifre alanı hızlıca belirir
  // 3390-3590ms    "Şifremi unuttum?" hızlıca belirir
  // 3690-3970ms    giriş yap butonu hızlıca belirir
  // 4110-4390ms    Kayıt Ol + Google/Apple/E-posta seçenekleri hızlıca belirir
  static const int _totalMs = 4590;
  static const double _enterEnd = 900 / _totalMs;
  static const double _holdEnd = 1650 / _totalMs;
  static const double _transitionEnd = 2550 / _totalMs;
  static const double _emailStart = _transitionEnd;
  static const double _emailEnd = 2830 / _totalMs;
  static const double _passwordStart = 2970 / _totalMs;
  static const double _passwordEnd = 3250 / _totalMs;
  static const double _forgotStart = 3390 / _totalMs;
  static const double _forgotEnd = 3590 / _totalMs;
  static const double _buttonStart = 3690 / _totalMs;
  static const double _buttonEnd = 3970 / _totalMs;
  static const double _authStart = 4110 / _totalMs;
  static const double _authEnd = 4390 / _totalMs;

  final FocusNode _emailFocusNode = FocusNode();

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _totalMs),
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  double _lineOneDy(double t) {
    if (t < _enterEnd) {
      return 1 - Curves.easeOutCubic.transform(t / _enterEnd);
    }
    if (t < _holdEnd) return 0;
    if (t < _transitionEnd) {
      return -Curves.easeInCubic.transform(
        (t - _holdEnd) / (_transitionEnd - _holdEnd),
      );
    }
    return -1;
  }

  double _lineTwoDy(double t) {
    if (t < _holdEnd) return 1;
    if (t < _transitionEnd) {
      return 1 -
          Curves.easeOutCubic.transform(
            (t - _holdEnd) / (_transitionEnd - _holdEnd),
          );
    }
    return 0;
  }

  double _reveal(double t, double start, double end) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return Curves.easeOutCubic.transform((t - start) / (end - start));
  }

  Widget _revealed(double t, double start, double end, double s, Widget child) {
    final r = _reveal(t, start, end);
    return Transform.translate(
      offset: Offset(0, (1 - r) * 26 * s),
      child: Opacity(opacity: r, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double s = (size.width / 390).clamp(0.85, 1.15).toDouble();
    final double screenHeight = size.height;

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
                  padding: EdgeInsets.fromLTRB(0, 32 * s, 0, 24 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 26 * s),
                        child: SizedBox(
                          height: 155 * s,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Transform.translate(
                                offset: Offset(0, _lineOneDy(t) * screenHeight),
                                child: Text(
                                  'HOŞ GELDİN',
                                  style: _display(
                                    size: 27 * s,
                                    weight: FontWeight.w600,
                                    color: _kInk,
                                    height: 1.15,
                                  ),
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0, _lineTwoDy(t) * screenHeight),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      AppAssets.loginLogo,
                                      height: 60 * s,
                                    ),
                                    SizedBox(height: 16 * s),
                                    Text(
                                      'Tüm kreatif süreçler.\nTek yerde.',
                                      style: _display(
                                        size: 28 * s,
                                        weight: FontWeight.w700,
                                        color: _kInk,
                                        height: 1.15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 60 * s),
                      Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _revealed(
                              t,
                              _emailStart,
                              _emailEnd,
                              s,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 26 * s,
                                    ),
                                    child: Text(
                                      'E-POSTA',
                                      style: _ui(
                                        size: 8 * s,
                                        weight: FontWeight.w700,
                                        color: _kBlack,
                                        spacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8 * s),
                                  TextFormField(
                                    controller: controller.emailController,
                                    focusNode: _emailFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
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
                                      fillColor: Colors.white,
                                      hintText: 'ornek@set.app',
                                      hintStyle: _ui(
                                        size: 11 * s,
                                        color: _kTaupe,
                                        spacing: 0.2,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 14 * s,
                                        vertical: 14 * s,
                                      ),
                                      border: border(
                                        Colors.black.withValues(alpha: 0.12),
                                      ),
                                      enabledBorder: border(
                                        Colors.black.withValues(alpha: 0.12),
                                      ),
                                      focusedBorder: border(_kGold),
                                      errorBorder: border(_kDanger),
                                      focusedErrorBorder: border(_kDanger),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20 * s),
                            _revealed(
                              t,
                              _passwordStart,
                              _passwordEnd,
                              s,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 26 * s,
                                    ),
                                    child: Text(
                                      'ŞİFRE',
                                      style: _ui(
                                        size: 8 * s,
                                        weight: FontWeight.w700,
                                        color: _kBlack,
                                        spacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8 * s),
                                  Obx(
                                    () => TextFormField(
                                      controller: controller.passwordController,
                                      obscureText:
                                          controller.obscurePassword.value,
                                      textInputAction: TextInputAction.done,
                                      validator: Validators.password,
                                      cursorColor: _kGold,
                                      style: _ui(
                                        size: 11 * s,
                                        color: _kBlack,
                                        spacing: 0.2,
                                      ),
                                      onFieldSubmitted: (_) =>
                                          controller.submit(),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: '••••••',
                                        hintStyle: _ui(
                                          size: 11 * s,
                                          color: _kTaupe,
                                          spacing: 0.2,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 14 * s,
                                          vertical: 14 * s,
                                        ),
                                        border: border(
                                          Colors.black.withValues(alpha: 0.12),
                                        ),
                                        enabledBorder: border(
                                          Colors.black.withValues(alpha: 0.12),
                                        ),
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
                                    if (err == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        26 * s,
                                        10 * s,
                                        26 * s,
                                        0,
                                      ),
                                      child: Text(
                                        err,
                                        style: _ui(
                                          size: 9 * s,
                                          color: _kDanger,
                                          spacing: 0.2,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            SizedBox(height: 12 * s),
                            _revealed(
                              t,
                              _forgotStart,
                              _forgotEnd,
                              s,
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 26 * s,
                                ),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => _showForgotPasswordSheet(
                                      context,
                                      controller,
                                      s,
                                    ),
                                    behavior: HitTestBehavior.opaque,
                                    child: Text(
                                      'Şifremi unuttum?',
                                      style: _ui(
                                        size: 12 * s,
                                        weight: FontWeight.w700,
                                        color: _kGold,
                                        spacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 14 * s),
                            _revealed(
                              t,
                              _buttonStart,
                              _buttonEnd,
                              s,
                              Obx(
                                () => GestureDetector(
                                  onTap: controller.isLoading.value
                                      ? null
                                      : controller.submit,
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: double.infinity,
                                    height: 52 * s,
                                    color: _kGold,
                                    alignment: Alignment.center,
                                    child: controller.isLoading.value
                                        ? SizedBox(
                                            height: 18 * s,
                                            width: 18 * s,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2.2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                        Colors.white,
                                                      ),
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 22 * s),
                      _revealed(
                        t,
                        _authStart,
                        _authEnd,
                        s,
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 26 * s,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.dontHaveAccount,
                                    style: _ui(
                                      size: 12 * s,
                                      color: _kBlack,
                                      spacing: 0.3,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: controller.goToRegister,
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6 * s,
                                      ),
                                      child: Text(
                                        AppStrings.register,
                                        style: _ui(
                                          size: 12 * s,
                                          weight: FontWeight.w700,
                                          color: _kGold,
                                          spacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20 * s),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 26 * s,
                              ),
                              child: _AuthOptionsFrame(
                                scale: s,
                                onGoogle: () {},
                                onApple: () {},
                                onEmail: () => _emailFocusNode.requestFocus(),
                              ),
                            ),
                          ],
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

// ─── Google/Apple/E-posta seçenekleri (kare çerçeve) ────────────────────────
class _AuthOptionsFrame extends StatelessWidget {
  const _AuthOptionsFrame({
    required this.scale,
    required this.onGoogle,
    required this.onApple,
    required this.onEmail,
  });

  final double scale;
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onEmail;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      children: [
        Text(
          'VEYA',
          style: _ui(
            size: 9 * s,
            weight: FontWeight.w700,
            color: _kTaupe,
            spacing: 1.5,
          ),
        ),
        SizedBox(height: 14 * s),
        Row(
          children: [
            Expanded(
              child: _AuthIconButton(
                scale: s,
                icon: AppAssets.loginGoogle,
                onTap: onGoogle,
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: _AuthIconButton(
                scale: s,
                icon: AppAssets.loginApple,
                onTap: onApple,
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: _AuthIconButton(
                scale: s,
                icon: AppAssets.loginEmail,
                onTap: onEmail,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthIconButton extends StatelessWidget {
  const _AuthIconButton({
    required this.scale,
    required this.icon,
    required this.onTap,
  });

  final double scale;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52 * s,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
        ),
        alignment: Alignment.center,
        child: Image.asset(icon, height: 22 * s, fit: BoxFit.contain),
      ),
    );
  }
}

// ─── Şifremi unuttum alt sayfası ────────────────────────────────────────────
void _showForgotPasswordSheet(
  BuildContext context,
  LoginController controller,
  double s,
) {
  controller.resetEmailController.text = controller.emailController.text;
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
              style: _display(size: 20 * s, weight: FontWeight.w600, color: _kInk),
            ),
            SizedBox(height: 6 * s),
            Text(
              'E-postana bir sıfırlama bağlantısı gönderelim.',
              style: _ui(size: 9 * s, color: _kBlack, spacing: 0.2),
            ),
            SizedBox(height: 16 * s),
            TextField(
              controller: controller.resetEmailController,
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
                          controller.resetEmailController.text,
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
