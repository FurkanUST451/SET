import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'category_picker_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kMuted = Color(0xFFB6AD9A);
const _kCardBorder = Color(0x14000000);

TextStyle _serif({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
  bool italic = false,
}) =>
    GoogleFonts.cormorantGaramond(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal);

Widget _wordmark(double s) => RichText(
      text: TextSpan(children: [
        TextSpan(
          text: 'SE',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 18 * s,
              fontWeight: FontWeight.w700,
              color: _kInk,
              letterSpacing: 2.5),
        ),
        TextSpan(
          text: 'T',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 18 * s,
              fontWeight: FontWeight.w800,
              color: _kGold,
              letterSpacing: 2.5),
        ),
      ]),
    );

class CategoryPickerView extends GetView<CategoryPickerController> {
  const CategoryPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    final double s =
        (MediaQuery.sizeOf(context).width / 390).clamp(0.85, 1.15).toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              SizedBox(height: 20 * s),
              Text('Hizmetini seç,',
                  style:
                      _serif(size: 30 * s, weight: FontWeight.w600, color: _kInk)),
              Text('fikrini hayata geçirelim.',
                  style: _serif(
                      size: 22 * s,
                      weight: FontWeight.w500,
                      color: _kMuted,
                      italic: true)),
              SizedBox(height: 12 * s),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: _kMuted, size: 26 * s),
              SizedBox(height: 12 * s),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(24 * s, 4 * s, 24 * s, 24 * s),
                  itemCount: controller.categories.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12 * s),
                  itemBuilder: (_, i) {
                    final cat = controller.categories[i];
                    return _CategoryCard(
                      scale: s,
                      label: cat,
                      onTap: () => controller.selectCategory(cat),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.scale,
    required this.label,
    required this.onTap,
  });

  final double scale;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 68 * s,
        padding: EdgeInsets.symmetric(horizontal: 20 * s),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(color: _kGold, width: 3),
            top: BorderSide(color: _kCardBorder),
            right: BorderSide(color: _kCardBorder),
            bottom: BorderSide(color: _kCardBorder),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk),
              ),
            ),
            Icon(Icons.arrow_forward_rounded, size: 18 * s, color: _kGold),
          ],
        ),
      ),
    );
  }
}
