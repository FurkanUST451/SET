import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import 'login_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kDanger = Color(0xFFBE6A5A);

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

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();

    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: c),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _kCream,
        body: MediaQuery.withNoTextScaling(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(26 * s, 32 * s, 26 * s, 24 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'SE',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20 * s,
                            fontWeight: FontWeight.w700,
                            color: _kInk,
                            letterSpacing: 2.5,
                          ),
                        ),
                        TextSpan(
                          text: 'T',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20 * s,
                            fontWeight: FontWeight.w800,
                            color: _kGold,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 44 * s),
                  Text(
                    'WELCOME BACK',
                    style: _mono(size: 8 * s, color: _kMuted, spacing: 2),
                  ),
                  SizedBox(height: 8 * s),
                  Text(
                    'Tekrar hoş geldin',
                    style: _serif(
                      size: 38 * s,
                      weight: FontWeight.w600,
                      color: _kInk,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  Text(
                    'Hesabına giriş yap, üretmeye devam et.',
                    style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.3),
                  ),
                  SizedBox(height: 36 * s),
                  Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'E-POSTA',
                          style: _mono(
                            size: 8 * s,
                            weight: FontWeight.w700,
                            color: _kMuted,
                            spacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8 * s),
                        TextFormField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.email,
                          cursorColor: _kGold,
                          style: _mono(
                            size: 11 * s,
                            color: _kInk,
                            spacing: 0.2,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'ornek@set.app',
                            hintStyle: _mono(
                              size: 11 * s,
                              color: _kMuted,
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
                        SizedBox(height: 20 * s),
                        Text(
                          'ŞİFRE',
                          style: _mono(
                            size: 8 * s,
                            weight: FontWeight.w700,
                            color: _kMuted,
                            spacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8 * s),
                        Obx(
                          () => TextFormField(
                            controller: controller.passwordController,
                            obscureText: controller.obscurePassword.value,
                            textInputAction: TextInputAction.done,
                            validator: Validators.password,
                            cursorColor: _kGold,
                            style: _mono(
                              size: 11 * s,
                              color: _kInk,
                              spacing: 0.2,
                            ),
                            onFieldSubmitted: (_) => controller.submit(),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              hintText: '••••••',
                              hintStyle: _mono(
                                size: 11 * s,
                                color: _kMuted,
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
                          if (err == null) return const SizedBox.shrink();
                          return Padding(
                            padding: EdgeInsets.only(top: 10 * s),
                            child: Text(
                              err,
                              style: _mono(
                                size: 9 * s,
                                color: _kDanger,
                                spacing: 0.2,
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 26 * s),
                        Obx(
                          () => GestureDetector(
                            onTap: controller.isLoading.value
                                ? null
                                : controller.submit,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: double.infinity,
                              height: 52 * s,
                              color: _kInk,
                              alignment: Alignment.center,
                              child: controller.isLoading.value
                                  ? SizedBox(
                                      height: 18 * s,
                                      width: 18 * s,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      AppStrings.login.toUpperCase(),
                                      style: _mono(
                                        size: 11 * s,
                                        weight: FontWeight.w700,
                                        color: Colors.white,
                                        spacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22 * s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.dontHaveAccount,
                        style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.3),
                      ),
                      GestureDetector(
                        onTap: controller.goToRegister,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6 * s),
                          child: Text(
                            AppStrings.register,
                            style: _mono(
                              size: 9 * s,
                              weight: FontWeight.w700,
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
          ),
        ),
      ),
    );
  }
}
