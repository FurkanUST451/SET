import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import 'offer_review_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kCardBorder = Color(0x14000000);
const _kDanger = Color(0xFFBE6A5A);

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

class OfferReviewView extends GetView<OfferReviewController> {
  const OfferReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final double s =
        (MediaQuery.sizeOf(context).width / 390).clamp(0.85, 1.15).toDouble();
    final offer = controller.offer;
    final brief = controller.brief;
    final a = brief?.answers;

    final rows = <_ReviewRowData>[
      _ReviewRowData(
        label: 'Hizmet',
        value: brief?.category.isNotEmpty == true
            ? brief!.category
            : offer.briefTitle,
      ),
      if (a?.shootingType != null && a!.shootingType!.isNotEmpty)
        _ReviewRowData(label: 'Çekim Türü', value: a.shootingType!),
      if (a?.dateRange != null && a!.dateRange!.isNotEmpty)
        _ReviewRowData(label: 'Çekim Tarihi', value: a.dateRange!),
      if (a?.deliveryTime != null && a!.deliveryTime!.isNotEmpty)
        _ReviewRowData(label: 'Teslim Süresi', value: a.deliveryTime!),
      if (a?.location != null && a!.location!.isNotEmpty)
        _ReviewRowData(label: 'Lokasyon', value: a.location!),
      if (a?.notes != null && a!.notes!.isNotEmpty)
        _ReviewRowData(label: 'Brief Açıklaması', value: a.notes!),
      _ReviewRowData(
        label: 'Anlaşılan Ücret',
        value: '${offer.amount.toStringAsFixed(0)} ₺',
      ),
    ];

    return Scaffold(
      backgroundColor: _kCream,
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
                  padding: EdgeInsets.fromLTRB(24 * s, 12 * s, 24 * s, 24 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('ONAY',
                              style: _ui(
                                  size: 8 * s,
                                  weight: FontWeight.w700,
                                  color: _kBlack,
                                  spacing: 1.5)),
                          SizedBox(width: 10 * s),
                          Expanded(
                            child: Container(height: 1, color: _kCardBorder),
                          ),
                        ],
                      ),
                      SizedBox(height: 18 * s),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: 'Gözden ',
                            style: _display(
                                size: 34 * s,
                                weight: FontWeight.w600,
                                color: _kInk),
                          ),
                          TextSpan(
                            text: 'geçirelim.',
                            style: _display(
                                size: 34 * s,
                                weight: FontWeight.w600,
                                color: _kGold),
                          ),
                        ]),
                      ),
                      SizedBox(height: 28 * s),
                      for (var i = 0; i < rows.length; i++)
                        _ReviewRow(
                          scale: s,
                          index: i + 1,
                          label: rows[i].label,
                          value: rows[i].value,
                        ),
                    ],
                  ),
                ),
              ),
              // Alt sabit bölüm
              Padding(
                padding: EdgeInsets.fromLTRB(24 * s, 12 * s, 24 * s, 8 * s),
                child: Column(
                  children: [
                    Obx(() => Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: controller.isProcessing.value
                                    ? null
                                    : () async {
                                        try {
                                          await controller.reject();
                                        } finally {
                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        }
                                      },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  height: 54 * s,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color:
                                            _kDanger.withValues(alpha: 0.4)),
                                  ),
                                  child: Text('REDDET',
                                      style: _ui(
                                          size: 10 * s,
                                          weight: FontWeight.w700,
                                          color: _kDanger,
                                          spacing: 1.2)),
                                ),
                              ),
                            ),
                            SizedBox(width: 10 * s),
                            Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: controller.isProcessing.value
                                    ? null
                                    : () async {
                                        try {
                                          await controller.accept();
                                        } finally {
                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        }
                                      },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  height: 54 * s,
                                  color: _kGold,
                                  alignment: Alignment.center,
                                  child: controller.isProcessing.value
                                      ? SizedBox(
                                          width: 22 * s,
                                          height: 22 * s,
                                          child:
                                              const CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Colors.white),
                                        )
                                      : Text('KABUL ET',
                                          style: _ui(
                                              size: 10 * s,
                                              weight: FontWeight.w700,
                                              color: Colors.white,
                                              spacing: 1.2)),
                                ),
                              ),
                            ),
                          ],
                        )),
                    SizedBox(height: 10 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 11 * s, color: _kMuted),
                        SizedBox(width: 5 * s),
                        Flexible(
                          child: Text(
                            'Tüm bilgilerin güvenliği SET güvencesiyle korunur.',
                            style: _ui(size: 8 * s, color: _kBlack, spacing: 0.2),
                          ),
                        ),
                      ],
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

class _ReviewRowData {
  const _ReviewRowData({required this.label, required this.value});
  final String label;
  final String value;
}

// ─── Bilgi satırı (numaralı) ───────────────────────────────────────────────
class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.scale,
    required this.index,
    required this.label,
    required this.value,
  });

  final double scale;
  final int index;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.only(bottom: 16 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20 * s,
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: _ui(
                      size: 8.5 * s,
                      weight: FontWeight.w700,
                      color: _kGold,
                      spacing: 0.5),
                ),
              ),
              SizedBox(
                width: 96 * s,
                child: Text(
                  label,
                  style: _ui(
                      size: 8.5 * s,
                      weight: FontWeight.w700,
                      color: _kBlack,
                      spacing: 1),
                ),
              ),
              SizedBox(width: 10 * s),
              Container(width: 1, height: 14 * s, color: _kCardBorder),
              SizedBox(width: 12 * s),
              Expanded(
                child: Text(
                  value,
                  style: _display(
                      size: 15 * s, weight: FontWeight.w600, color: _kInk),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * s),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: _kCardBorder)),
              SizedBox(width: 32 * s, child: Container(height: 1, color: _kGold)),
            ],
          ),
        ],
      ),
    );
  }
}
