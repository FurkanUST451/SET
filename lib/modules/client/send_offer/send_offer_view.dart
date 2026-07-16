import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'send_offer_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kCardBorder = Color(0x14000000);
const _kDivider = Color(0x0F000000);

TextStyle _serif({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
}) =>
    GoogleFonts.cormorantGaramond(
        fontSize: size, fontWeight: weight, color: color, height: height);

TextStyle _mono({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
  double height = 1.4,
}) =>
    GoogleFonts.spaceMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height);

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

class SendOfferView extends GetView<SendOfferController> {
  const SendOfferView({super.key});

  @override
  Widget build(BuildContext context) {
    final double s =
        (MediaQuery.sizeOf(context).width / 390).clamp(0.85, 1.15).toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Column(
            children: [
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
                  padding: EdgeInsets.fromLTRB(24 * s, 12 * s, 24 * s, 32 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (controller.category.isNotEmpty
                                ? controller.category
                                : 'Video Çekim')
                            .toUpperCase(),
                        style: _mono(size: 8 * s, color: _kMuted, spacing: 1.5),
                      ),
                      SizedBox(height: 8 * s),
                      Text(
                        controller.isEditMode
                            ? "Brief'ini\ngüncelle."
                            : "Doğru brief'i\noluşturalım.",
                        style: _serif(
                            size: 40 * s,
                            weight: FontWeight.w600,
                            color: _kInk,
                            height: 1.05),
                      ),
                      SizedBox(height: 8 * s),
                      Text('Projene en uygun kreatif ekibi eşleştirelim.',
                          style:
                              _mono(size: 9 * s, color: _kTaupe, spacing: 0.2)),
                      SizedBox(height: 24 * s),

                      _ShootingTypeRow(scale: s, controller: controller),
                      SizedBox(height: 10 * s),

                      _DateRow(scale: s, controller: controller),
                      SizedBox(height: 10 * s),

                      Obx(() => _BriefRow(
                            scale: s,
                            icon: Icons.hourglass_empty_rounded,
                            label: 'Teslim Süresi',
                            value: controller.selectedDelivery.value,
                            onTap: () => _showPicker(
                              context,
                              title: 'Teslim Süresi',
                              options: SendOfferController.deliveryOptions,
                              selected: controller.selectedDelivery.value,
                              onSelect: (v) =>
                                  controller.selectedDelivery.value = v,
                            ),
                          )),
                      SizedBox(height: 10 * s),

                      Obx(() => _BriefRow(
                            scale: s,
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Bütçe Aralığı',
                            value: controller.selectedBudget.value,
                            onTap: () => _showPicker(
                              context,
                              title: 'Bütçe Aralığı',
                              options: SendOfferController.budgetOptions,
                              selected: controller.selectedBudget.value,
                              onSelect: (v) =>
                                  controller.selectedBudget.value = v,
                            ),
                          )),

                      if (controller.showLocation) ...[
                        SizedBox(height: 10 * s),
                        Obx(() => _BriefRow(
                              scale: s,
                              icon: Icons.location_on_outlined,
                              label: 'Lokasyon',
                              value: controller.selectedLocation.value,
                              onTap: () => _showPicker(
                                context,
                                title: 'Lokasyon',
                                options: SendOfferController.locationOptions,
                                selected: controller.selectedLocation.value,
                                onSelect: (v) =>
                                    controller.selectedLocation.value = v,
                              ),
                            )),
                      ],

                      SizedBox(height: 28 * s),

                      Obx(() => GestureDetector(
                            onTap: controller.isSubmitting.value
                                ? null
                                : controller.submit,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: double.infinity,
                              height: 54 * s,
                              color: _kGold,
                              alignment: Alignment.center,
                              child: controller.isSubmitting.value
                                  ? SizedBox(
                                      width: 22 * s,
                                      height: 22 * s,
                                      child: const CircularProgressIndicator(
                                          strokeWidth: 2.4, color: Colors.white),
                                    )
                                  : Text('DEVAM ET  →',
                                      style: _mono(
                                          size: 11 * s,
                                          weight: FontWeight.w700,
                                          color: Colors.white,
                                          spacing: 1.5)),
                            ),
                          )),

                      SizedBox(height: 14 * s),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 11 * s, color: _kMuted),
                          SizedBox(width: 5 * s),
                          Flexible(
                            child: Text(
                              'Tüm bilgilerin güvenliği SET güvencesiyle korunur.',
                              style: _mono(
                                  size: 8 * s, color: _kMuted, spacing: 0.2),
                            ),
                          ),
                        ],
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
  }

  static void _showPicker(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String selected,
    required void Function(String) onSelect,
  }) {
    final s =
        (MediaQuery.sizeOf(context).width / 390).clamp(0.85, 1.15).toDouble();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _kCream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (_) => MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12 * s),
              Container(width: 36 * s, height: 3, color: Colors.black12),
              Padding(
                padding: EdgeInsets.fromLTRB(24 * s, 16 * s, 24 * s, 8 * s),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(title,
                      style: _serif(
                          size: 22 * s,
                          weight: FontWeight.w600,
                          color: _kInk)),
                ),
              ),
              ...options.map((o) => InkWell(
                    onTap: () {
                      onSelect(o);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 24 * s, vertical: 14 * s),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: _kDivider)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(o,
                                style: _serif(
                                    size: 16 * s,
                                    weight: o == selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: _kInk)),
                          ),
                          if (o == selected)
                            Icon(Icons.check_rounded,
                                color: _kGold, size: 20 * s),
                        ],
                      ),
                    ),
                  )),
              SizedBox(height: 16 * s),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Çekim Türü — aynı kart içinde aşağı doğru açılır liste ───────────────────
class _ShootingTypeRow extends StatelessWidget {
  const _ShootingTypeRow({required this.scale, required this.controller});

  final double scale;
  final SendOfferController controller;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Obx(() {
      final expanded = controller.isShootingTypeExpanded.value;
      final selected = controller.selectedShootingType.value;
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: controller.toggleShootingTypeExpanded,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.movie_creation_outlined, size: 18 * s, color: _kTaupe),
                        SizedBox(width: 12 * s),
                        Text('ÇEKİM TÜRÜ',
                            style: _mono(size: 8 * s, color: _kMuted, spacing: 1.2)),
                        const Spacer(),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: _kMuted,
                          size: 20 * s,
                        ),
                      ],
                    ),
                    if (selected.isNotEmpty) ...[
                      SizedBox(height: 4 * s),
                      Padding(
                        padding: EdgeInsets.only(left: 30 * s),
                        child: Text(selected,
                            style: _serif(
                                size: 18 * s, weight: FontWeight.w600, color: _kInk)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: !expanded
                  ? const SizedBox.shrink()
                  : Column(
                      children: SendOfferController.shootingTypes.map((o) {
                        final active = o == selected;
                        return InkWell(
                          onTap: () => controller.selectShootingType(o),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(
                                16 * s, 12 * s, 16 * s, 12 * s),
                            decoration:
                                const BoxDecoration(border: Border(top: BorderSide(color: _kDivider))),
                            child: Row(
                              children: [
                                SizedBox(width: 30 * s),
                                Expanded(
                                  child: Text(o,
                                      style: _serif(
                                          size: 15 * s,
                                          weight: active ? FontWeight.w700 : FontWeight.w500,
                                          color: _kInk)),
                                ),
                                if (active)
                                  Icon(Icons.check_rounded, color: _kGold, size: 18 * s),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Çekim tarihi belirli mi? — toggle + takvim ────────────────────────────────
class _DateRow extends StatelessWidget {
  const _DateRow({required this.scale, required this.controller});

  final double scale;
  final SendOfferController controller;

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: _kGold,
                onPrimary: Colors.white,
                onSurface: _kInk,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) controller.setPickedDateRange(picked);
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Obx(() {
      final hasFixedDate = controller.hasFixedDate.value;
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 18 * s, color: _kTaupe),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: Text('Çekim tarihi belirli mi?',
                        style: _serif(size: 15 * s, weight: FontWeight.w600, color: _kInk)),
                  ),
                  Transform.scale(
                    scale: 0.8 * s,
                    child: Switch(
                      value: hasFixedDate,
                      onChanged: controller.setHasFixedDate,
                      activeThumbColor: Colors.white,
                      activeTrackColor: _kGold,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.black12,
                    ),
                  ),
                ],
              ),
            ),
            if (hasFixedDate)
              InkWell(
                onTap: () => _pickRange(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(16 * s, 0, 16 * s, 14 * s),
                  child: Row(
                    children: [
                      SizedBox(width: 30 * s),
                      Expanded(
                        child: Text(
                          controller.dateRangeLabel.value.isEmpty
                              ? 'Tarih aralığı seç'
                              : controller.dateRangeLabel.value,
                          style: _serif(
                            size: 16 * s,
                            weight: FontWeight.w600,
                            color: controller.dateRangeLabel.value.isEmpty ? _kMuted : _kInk,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: _kMuted, size: 18 * s),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ─── Brief satırı (keskin kart) ───────────────────────────────────────────────
class _BriefRow extends StatelessWidget {
  const _BriefRow({
    required this.scale,
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final double scale;
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18 * s, color: _kTaupe),
                SizedBox(width: 12 * s),
                Text(label.toUpperCase(),
                    style: _mono(size: 8 * s, color: _kMuted, spacing: 1.2)),
                const Spacer(),
                Icon(Icons.chevron_right, color: _kMuted, size: 18 * s),
              ],
            ),
            if (value != null && value!.isNotEmpty) ...[
              SizedBox(height: 4 * s),
              Padding(
                padding: EdgeInsets.only(left: 30 * s),
                child: Text(value!,
                    style: _serif(
                        size: 18 * s,
                        weight: FontWeight.w600,
                        color: _kInk)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
