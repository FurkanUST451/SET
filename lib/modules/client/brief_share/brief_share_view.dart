import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import 'brief_share_controller.dart';
import '../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kCardBorder = Color(0x14000000);

TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
}) =>
    AppFonts.display(
        fontSize: size, fontWeight: weight, color: color, height: height);

TextStyle _ui({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
  double height = 1.4,
}) =>
    AppFonts.ui(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height);

Widget _wordmark(double s) => RichText(
      text: TextSpan(children: [
        TextSpan(
          text: 'SE',
          style: AppFonts.display(
              fontSize: 18 * s,
              fontWeight: FontWeight.w700,
              color: _kInk,
              letterSpacing: 2.5),
        ),
        TextSpan(
          text: 'T',
          style: AppFonts.display(
              fontSize: 18 * s,
              fontWeight: FontWeight.w800,
              color: _kGold,
              letterSpacing: 2.5),
        ),
      ]),
    );

class BriefShareView extends GetView<BriefShareController> {
  const BriefShareView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final double s =
        (MediaQuery.sizeOf(context).width / 390).clamp(0.85, 1.15).toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      resizeToAvoidBottomInset: true,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Column(
            children: [
              // Üst bar
              SizedBox(
                height: 48 * s,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Get.back<void>(),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.all(12 * s),
                          child: Icon(Icons.arrow_back_rounded,
                              size: 22 * s, color: _kInk),
                        ),
                      ),
                    ),
                    _wordmark(s),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(0, 12 * s, 0, bottomInset + 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * s),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (controller.category.isNotEmpty
                                      ? controller.category
                                      : 'Video Çekim')
                                  .toUpperCaseTr(),
                              style: _ui(
                                  size: 8 * s, color: _kBlack, spacing: 1.5),
                            ),
                            SizedBox(height: 8 * s),
                            Text(
                              controller.isEditMode
                                  ? "Brief'ini güncelle."
                                  : "Brief'ini paylaş.",
                              style: _display(
                                  size: 40 * s,
                                  weight: FontWeight.w600,
                                  color: _kInk),
                            ),
                            SizedBox(height: 8 * s),
                            Text(
                              controller.isEditMode
                                  ? 'Projenin güncel detaylarını düzenleyebilirsin.'
                                  : 'Fikrini, referanslarını ve tüm detayları bizimle paylaş ki en doğru ekibi bulalım.',
                              style: _ui(
                                  size: 9 * s,
                                  color: _kBlack,
                                  spacing: 0.2,
                                  height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * s),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: _SectionCard(
                            scale: s,
                            icon: Icons.edit_outlined,
                            title: "Kendi Brief'ini Yaz",
                            subtitle:
                                'Projenin detaylarını, hedefini, istediğin tarzı ve özel notlarını yaz.',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(height: 12 * s),
                                Container(
                                  color: _kCream,
                                  child: TextField(
                                    controller: controller.briefText,
                                    maxLines: 7,
                                    maxLength: 2000,
                                    cursorColor: _kGold,
                                    style: _ui(
                                        size: 10 * s,
                                        color: _kBlack,
                                        spacing: 0.2,
                                        height: 1.5),
                                    decoration: InputDecoration(
                                      hintText: "Brief'ini buraya yaz...",
                                      hintStyle: _ui(
                                          size: 10 * s,
                                          color: _kBlack,
                                          spacing: 0.2),
                                      filled: true,
                                      fillColor: _kCream,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      counterText: '',
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(12 * s),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6 * s),
                                Obx(() => Text(
                                    '${controller.charCount.value} / 2000',
                                    style: _ui(
                                        size: 8 * s,
                                        color: _kBlack,
                                        spacing: 0.5))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Alt sabit bölüm
              Padding(
                padding: EdgeInsets.fromLTRB(0, 12 * s, 0, 8 * s),
                child: Column(
                  children: [
                    Obx(() => GestureDetector(
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
                                    width: 22 * s,
                                    height: 22 * s,
                                    child: const CircularProgressIndicator(
                                        strokeWidth: 2.5, color: Colors.white),
                                  )
                                : Text(
                                    controller.isEditMode
                                        ? "BRIEF'İ GÜNCELLE  →"
                                        : "BRIEF'İ GÖNDER  →",
                                    style: _ui(
                                        size: 11 * s,
                                        weight: FontWeight.w700,
                                        color: Colors.white,
                                        spacing: 1.5)),
                          ),
                        )),
                    SizedBox(height: 10 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24 * s),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 11 * s, color: _kMuted),
                          SizedBox(width: 5 * s),
                          Flexible(
                            child: Text(
                              'Tüm dosyalar gizlidir ve sadece seçilen ekiplerle paylaşılır.',
                              style: _ui(
                                  size: 8 * s, color: _kBlack, spacing: 0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8 * s),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bölüm kartı ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.scale,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final double scale;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38 * s,
                height: 38 * s,
                color: _kGold,
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 18 * s),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: _display(
                            size: 17 * s,
                            weight: FontWeight.w600,
                            color: _kInk)),
                    SizedBox(height: 3 * s),
                    Text(subtitle,
                        style: _ui(
                            size: 8 * s,
                            color: _kBlack,
                            spacing: 0.2,
                            height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}
