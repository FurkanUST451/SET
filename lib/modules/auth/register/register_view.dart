import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/turkish_case.dart';
import '../../../core/utils/validators.dart';
import 'register_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kBlack = Color(0xFF000000);
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

OutlineInputBorder _fieldBorder(Color c) => OutlineInputBorder(
  borderRadius: BorderRadius.zero,
  borderSide: BorderSide(color: c),
);

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final double s =
        (MediaQuery.sizeOf(context).width / 390).clamp(0.85, 1.15).toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, 12 * s, 0, 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * s),
                  child: GestureDetector(
                    onTap: () => Get.back<void>(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 * s),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 22 * s,
                        color: _kInk,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26 * s),
                  child: Row(
                    children: [
                      Text(
                        'KAYIT / 02',
                        style: _ui(
                          size: 10 * s,
                          weight: FontWeight.w700,
                          color: _kTaupe,
                          spacing: 1.5,
                        ),
                      ),
                      SizedBox(width: 10 * s),
                      Expanded(
                        child: Container(height: 1, color: _kCardBorder),
                      ),
                      SizedBox(width: 10 * s),
                      Text(
                        'SET · v1.0',
                        style: _ui(
                          size: 10 * s,
                          color: _kTaupe,
                          spacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 22 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26 * s),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'hesap\n',
                          style: _display(
                            size: 34 * s,
                            weight: FontWeight.w500,
                            color: _kInk,
                            height: 1.05,
                            italic: true,
                          ),
                        ),
                        TextSpan(
                          text: 'oluştur.',
                          style: _display(
                            size: 44 * s,
                            weight: FontWeight.w700,
                            color: _kGold,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26 * s),
                  child: Text(
                    "Birkaç saniyede SET'e katıl.",
                    style: _ui(size: 10 * s, color: _kBlack, spacing: 0.2),
                  ),
                ),
                SizedBox(height: 28 * s),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _LabeledField(
                                      scale: s,
                                      label: 'AD',
                                      hint: 'Adın',
                                      controller: controller.nameController,
                                      textInputAction: TextInputAction.next,
                                      validator: (v) =>
                                          Validators.minLength(v, 2),
                                    ),
                                  ),
                                  SizedBox(width: 10 * s),
                                  Expanded(
                                    child: _LabeledField(
                                      scale: s,
                                      label: 'SOYAD',
                                      hint: 'Soyadın',
                                      controller:
                                          controller.surnameController,
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14 * s),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 78 * s,
                                    child: _LabeledField(
                                      scale: s,
                                      label: 'YAŞ',
                                      hint: '25',
                                      controller: controller.ageController,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return null;
                                        }
                                        final n = int.tryParse(v);
                                        if (n == null || n < 13 || n > 100) {
                                          return 'Geçersiz';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10 * s),
                                  Expanded(
                                    child: _GenderSelector(
                                      scale: s,
                                      selected: controller.selectedGender,
                                      onSelect: controller.setGender,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14 * s),
                              _LabeledField(
                                scale: s,
                                label: 'E-POSTA',
                                hint: 'ornek@set.app',
                                controller: controller.emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: Validators.email,
                              ),
                              SizedBox(height: 14 * s),
                              Obx(
                                () => _LabeledField(
                                  scale: s,
                                  label: 'ŞİFRE',
                                  hint: 'En az 6 karakter',
                                  controller: controller.passwordController,
                                  obscureText:
                                      controller.obscurePassword.value,
                                  textInputAction: TextInputAction.done,
                                  validator: Validators.password,
                                  onSubmitted: (_) => controller.submit(),
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
                              Obx(() {
                                final err = controller.errorMessage.value;
                                if (err == null) return const SizedBox.shrink();
                                return Padding(
                                  padding: EdgeInsets.only(top: 10 * s),
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
                              SizedBox(height: 20 * s),
                              Obx(
                                () => GestureDetector(
                                  onTap: controller.isLoading.value
                                      ? null
                                      : controller.submit,
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: double.infinity,
                                    height: 54 * s,
                                    color: _kGold,
                                    alignment: Alignment.center,
                                    child: controller.isLoading.value
                                        ? SizedBox(
                                            width: 20 * s,
                                            height: 20 * s,
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
                                            '${AppStrings.register.toUpperCaseTr()}  →',
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
                              SizedBox(height: 18 * s),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ZATEN HESABIN VAR MI?',
                                    style: _ui(
                                      size: 10 * s,
                                      color: _kTaupe,
                                      spacing: 0.3,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Get.back<void>(),
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6 * s,
                                      ),
                                      child: Text(
                                        AppStrings.login.toUpperCaseTr(),
                                        style: _ui(
                                          size: 10 * s,
                                          weight: FontWeight.w700,
                                          color: _kGold,
                                          spacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 22 * s),
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
                              SizedBox(height: 16 * s),
                              Row(
                                children: [
                                  Expanded(
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
                                  Expanded(
                                    child: _AuthIconButton(
                                      scale: s,
                                      icon: AppAssets.loginApple,
                                      label: 'APPLE',
                                      onTap: () {},
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: -8 * s,
                        left: -8 * s,
                        child: _CornerBracket(scale: s, top: true, left: true),
                      ),
                      Positioned(
                        bottom: -8 * s,
                        right: -8 * s,
                        child:
                            _CornerBracket(scale: s, top: false, left: false),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 22 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26 * s),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, size: 11 * s, color: _kTaupe),
                      SizedBox(width: 6 * s),
                      Flexible(
                        child: Text(
                          'Kayıt olarak kullanım koşulları ve KVKK metnini kabul edersin.',
                          style: _ui(size: 8 * s, color: _kTaupe, spacing: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Etiketli metin alanı ─────────────────────────────────────────────────
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.scale,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
  });

  final double scale;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _ui(
            size: 10 * s,
            weight: FontWeight.w700,
            color: _kBlack,
            spacing: 1.1,
          ),
        ),
        SizedBox(height: 6 * s),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          obscureText: obscureText,
          cursorColor: _kGold,
          onFieldSubmitted: onSubmitted,
          style: _ui(size: 11 * s, color: _kBlack, spacing: 0.2),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: _kCream,
            hintText: hint,
            hintStyle: _ui(size: 11 * s, color: _kTaupe, spacing: 0.2),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12 * s,
              vertical: 12 * s,
            ),
            border: _fieldBorder(_kCardBorder),
            enabledBorder: _fieldBorder(_kCardBorder),
            focusedBorder: _fieldBorder(_kGold),
            errorBorder: _fieldBorder(_kDanger),
            focusedErrorBorder: _fieldBorder(_kDanger),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

// ─── Cinsiyet seçici ──────────────────────────────────────────────────────
class _GenderSelector extends StatelessWidget {
  const _GenderSelector({
    required this.scale,
    required this.selected,
    required this.onSelect,
  });

  final double scale;
  final RxnString selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CİNSİYET',
          style: _ui(
            size: 10 * s,
            weight: FontWeight.w700,
            color: _kBlack,
            spacing: 1.1,
          ),
        ),
        SizedBox(height: 6 * s),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _GenderChip(
                  scale: s,
                  label: 'ERKEK',
                  selected: selected.value == 'erkek',
                  onTap: () => onSelect('erkek'),
                ),
              ),
              SizedBox(width: 6 * s),
              Expanded(
                child: _GenderChip(
                  scale: s,
                  label: 'KADIN',
                  selected: selected.value == 'kadin',
                  onTap: () => onSelect('kadin'),
                ),
              ),
              SizedBox(width: 6 * s),
              Expanded(
                child: _GenderChip(
                  scale: s,
                  label: 'DİĞER',
                  selected: selected.value == 'diger',
                  onTap: () => onSelect('diger'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.scale,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final double scale;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 42 * s,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _kGold : _kCream,
          border: Border.all(color: selected ? _kGold : _kCardBorder),
        ),
        child: Text(
          label,
          style: _ui(
            size: 10 * s,
            weight: FontWeight.w700,
            color: selected ? Colors.white : _kInk,
            spacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ─── Google/Apple butonları ───────────────────────────────────────────────
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
