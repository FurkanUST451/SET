import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/constants/app_assets.dart';
import 'send_offer_controller.dart';
import '../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kCardBorder = Color(0x14000000);
const _kDivider = Color(0x0F000000);

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

// Hizmet seçimi ekranıyla aynı marka logosu, aynı ölçekte.
Widget _wordmark(double s) => Image.asset(AppAssets.loginLogo, height: 28 * s);

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
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 20 * s),
                        child: Obx(() => Text(
                              '${controller.completedSteps}/${controller.totalSteps}',
                              style: _ui(
                                  size: 9 * s, color: _kMuted, spacing: 0.5),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(0, 12 * s, 0, 24 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * s),
                        child: Text(
                          (controller.category.isNotEmpty
                                  ? controller.category
                                  : 'Video Çekim')
                              .toUpperCaseTr(),
                          style:
                              _ui(size: 10 * s, color: _kBlack, spacing: 1.5),
                        ),
                      ),
                      SizedBox(height: 8 * s),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * s),
                        child: Text.rich(
                          TextSpan(children: controller.isEditMode
                              ? [
                                  TextSpan(
                                    text: "Brief'ini\n",
                                    style: _display(
                                        size: 32 * s,
                                        weight: FontWeight.w600,
                                        color: _kInk,
                                        height: 1.05),
                                  ),
                                  TextSpan(
                                    text: 'güncelle.',
                                    style: _display(
                                        size: 32 * s,
                                        weight: FontWeight.w600,
                                        color: _kGold,
                                        height: 1.05),
                                  ),
                                ]
                              : [
                                  TextSpan(
                                    text: "Doğru brief'i\n",
                                    style: _display(
                                        size: 32 * s,
                                        weight: FontWeight.w600,
                                        color: _kInk,
                                        height: 1.05),
                                  ),
                                  TextSpan(
                                    text: 'oluşturalım.',
                                    style: _display(
                                        size: 32 * s,
                                        weight: FontWeight.w600,
                                        color: _kGold,
                                        height: 1.05),
                                  ),
                                ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8 * s),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * s),
                        child: Text(
                            'Projene en uygun kreatif ekibi eşleştirelim.',
                            style: _ui(
                                size: 13 * s, color: _kBlack, spacing: 0.2)),
                      ),
                      SizedBox(height: 24 * s),

                      _ShootingTypeCard(scale: s, controller: controller),
                      Obx(() => _SlideInReveal(
                            visible:
                                controller.selectedShootingType.value.isNotEmpty,
                            child: _DateCard(scale: s, controller: controller),
                          )),
                      Obx(() => _SlideInReveal(
                            visible: controller.isDateFixed.value == false ||
                                (controller.isDateFixed.value == true &&
                                    controller.rangeEnd.value != null),
                            child:
                                _DeliveryCard(scale: s, controller: controller),
                          )),
                      if (controller.showLocation)
                        Obx(() => _SlideInReveal(
                              visible: controller.selectedDelivery.value.isNotEmpty,
                              child: _LocationCard(
                                  scale: s, controller: controller),
                            )),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10 * s, 0, 14 * s),
                child: Column(
                  children: [
                    Obx(() {
                      final isComplete =
                          controller.completedSteps == controller.totalSteps;
                      final enabled = isComplete && !controller.isSubmitting.value;
                      return GestureDetector(
                        onTap: enabled ? controller.submit : null,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          height: 54 * s,
                          color: isComplete
                              ? _kGold
                              : _kGold.withValues(alpha: 0.35),
                          alignment: Alignment.center,
                          child: controller.isSubmitting.value
                              ? SizedBox(
                                  width: 22 * s,
                                  height: 22 * s,
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2.4, color: Colors.white),
                                )
                              : Text('DEVAM ET  →',
                                  style: _ui(
                                      size: 11 * s,
                                      weight: FontWeight.w700,
                                      color: Colors.white,
                                      spacing: 1.5)),
                        ),
                      );
                    }),
                    SizedBox(height: 14 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24 * s),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 11 * s, color: _kMuted),
                          SizedBox(width: 5 * s),
                          Flexible(
                            child: Text(
                              'Tüm bilgilerin güvenliği SET güvencesiyle korunur.',
                              style: _ui(
                                  size: 8 * s, color: _kBlack, spacing: 0.2),
                            ),
                          ),
                        ],
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
  }
}

// ─── Sıradaki kart — bir önceki seçilince soldan sağa kayarak yerine oturur ───
class _SlideInReveal extends StatelessWidget {
  const _SlideInReveal({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: !visible
          ? const SizedBox(width: double.infinity)
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              builder: (context, value, animatedChild) => Transform.translate(
                offset: Offset((1 - value) * -40, 0),
                child: Opacity(opacity: value, child: animatedChild),
              ),
              child: child,
            ),
    );
  }
}

// ─── Kart içi alt bölüm — bir önceki seçim yapılınca yukarıdan yumuşakça belirir ───
class _SlideDownReveal extends StatelessWidget {
  const _SlideDownReveal({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: !visible
          ? const SizedBox(width: double.infinity)
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              builder: (context, value, animatedChild) => Transform.translate(
                offset: Offset(0, (1 - value) * -18),
                child: Opacity(opacity: value, child: animatedChild),
              ),
              child: child,
            ),
    );
  }
}

// ─── Ortak açılır kart kabuğu ─────────────────────────────────────────────────
class _ExpandableCard extends StatelessWidget {
  const _ExpandableCard({
    required this.scale,
    required this.icon,
    required this.label,
    required this.valueText,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final double scale;
  final IconData icon;
  final String label;
  final String? valueText;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 18 * s, color: _kTaupe),
                      SizedBox(width: 12 * s),
                      Text(label.toUpperCaseTr(),
                          style:
                              _ui(size: 10 * s, color: _kBlack, spacing: 1.2)),
                      const Spacer(),
                      Icon(
                        expanded ? Icons.remove_rounded : Icons.add_rounded,
                        color: expanded ? _kInk : _kMuted,
                        size: 20 * s,
                      ),
                    ],
                  ),
                  SizedBox(height: 4 * s),
                  Padding(
                    padding: EdgeInsets.only(left: 30 * s),
                    child: Text(
                      valueText == null || valueText!.isEmpty
                          ? 'Seç'
                          : valueText!,
                      style: _display(
                          size: 19 * s,
                          weight: FontWeight.w600,
                          color: valueText == null || valueText!.isEmpty
                              ? _kMuted
                              : _kInk),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: !expanded
                ? const SizedBox(width: double.infinity)
                : Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16 * s, 0, 16 * s, 16 * s),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: _kDivider)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 14 * s),
                      child: child,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Seçim çipi ───────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  const _Chip({
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
        padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _kGold : Colors.transparent,
          border: Border.all(color: selected ? _kGold : _kCardBorder),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: _display(
                size: 13.5 * s,
                weight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : _kInk)),
      ),
    );
  }
}

// ─── Çekim Türü ───────────────────────────────────────────────────────────────
class _ShootingTypeCard extends StatelessWidget {
  const _ShootingTypeCard({required this.scale, required this.controller});
  final double scale;
  final SendOfferController controller;

  static const _labels = [
    'Reklam filmi · dikey',
    'Reklam filmi · yatay',
    'Ürün videosu',
    'Röportaj',
    'Etkinlik',
    'Sosyal medya seti',
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Obx(() => _ExpandableCard(
          scale: s,
          icon: Icons.movie_creation_outlined,
          label: 'Çekim Türü',
          valueText: controller.selectedShootingType.value.isEmpty
              ? null
              : _labels[SendOfferController.shootingTypes
                  .indexOf(controller.selectedShootingType.value)],
          expanded: controller.isShootingTypeExpanded.value,
          onToggle: controller.toggleShootingTypeExpanded,
          child: Column(
            children: [
              _chipRow(s, controller, [0, 1]),
              SizedBox(height: 8 * s),
              _chipRow(s, controller, [2, 3, 4]),
              SizedBox(height: 8 * s),
              _chipRow(s, controller, [5]),
            ],
          ),
        ));
  }

  static Widget _chipRow(
      double s, SendOfferController controller, List<int> indices) {
    return Row(
      children: [
        for (var i = 0; i < indices.length; i++) ...[
          if (i > 0) SizedBox(width: 8 * s),
          Expanded(
            child: _Chip(
              scale: s,
              label: _labels[indices[i]],
              selected: controller.selectedShootingType.value ==
                  SendOfferController.shootingTypes[indices[i]],
              onTap: () => controller.selectShootingType(
                  SendOfferController.shootingTypes[indices[i]]),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Çekim Tarihi ───────────────────────────────────────────────────────────
class _DateCard extends StatelessWidget {
  const _DateCard({required this.scale, required this.controller});
  final double scale;
  final SendOfferController controller;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Obx(() => _ExpandableCard(
          scale: s,
          icon: Icons.calendar_month_outlined,
          label: 'Çekim Tarihi',
          valueText: controller.dateRangeLabel.value,
          expanded: controller.isDateExpanded.value,
          onToggle: controller.toggleDateExpanded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ModeTab(
                      scale: s,
                      label: 'Tarih belli',
                      selected: controller.isDateFixed.value == true,
                      onTap: () => controller.setDateMode(true),
                    ),
                  ),
                  SizedBox(width: 10 * s),
                  Expanded(
                    child: _ModeTab(
                      scale: s,
                      label: 'Esnek',
                      selected: controller.isDateFixed.value == false,
                      onTap: () => controller.setDateMode(false),
                    ),
                  ),
                ],
              ),
              _SlideDownReveal(
                visible: controller.isDateFixed.value == true,
                child: Padding(
                  padding: EdgeInsets.only(top: 14 * s),
                  child: _MonthStrip(scale: s, controller: controller),
                ),
              ),
              _SlideDownReveal(
                visible: controller.isDateFixed.value == true &&
                    controller.selectedMonth.value != null,
                child: Padding(
                  padding: EdgeInsets.only(top: 14 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DateStrip(scale: s, controller: controller),
                      SizedBox(height: 8 * s),
                      Text(
                        'Başlangıç ve bitiş gününe dokun. Tek gün için aynı güne iki kez dokun.',
                        style: _ui(size: 7.5 * s, color: _kMuted, spacing: 0.2),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.isDateFixed.value == false) ...[
                SizedBox(height: 12 * s),
                Text(
                  'Ekip, senin takvimine göre esnek planlanacak.',
                  style: _ui(size: 13 * s, color: _kMuted, spacing: 0.2),
                ),
              ],
            ],
          ),
        ));
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
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
        height: 38 * s,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _kGold : _kCream,
          border: Border.all(color: selected ? _kGold : _kCardBorder),
        ),
        child: Text(label,
            style: _ui(
                size: 11 * s,
                weight: FontWeight.w700,
                color: selected ? Colors.white : _kInk,
                spacing: 0.6)),
      ),
    );
  }
}

const List<String> _kWeekdayShort = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];

// Ay seçimi için yatay kaydırılabilen şerit — gün şeridinden önce görüntülenir.
class _MonthStrip extends StatelessWidget {
  const _MonthStrip({required this.scale, required this.controller});
  final double scale;
  final SendOfferController controller;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final months = controller.availableMonths;

    return SizedBox(
      height: 44 * s,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: months.length,
        itemBuilder: (context, i) {
          final month = months[i];
          final selectedMonth = controller.selectedMonth.value;
          final selected = selectedMonth != null &&
              selectedMonth.year == month.year &&
              selectedMonth.month == month.month;

          return GestureDetector(
            onTap: () => controller.selectMonth(month),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: EdgeInsets.only(right: 8 * s),
              padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _kGold : Colors.transparent,
                border: Border.all(color: selected ? _kGold : _kCardBorder),
              ),
              child: Text(
                controller.monthLabel(month),
                style: _ui(
                  size: 9 * s,
                  weight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? Colors.white : _kInk,
                  spacing: 0.3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Seçilen ayın günlerini gösteren, sağa sola serbestçe kaydırılabilen şerit.
class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.scale, required this.controller});
  final double scale;
  final SendOfferController controller;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final month = controller.selectedMonth.value!;
    final today = DateTime.now();
    final isCurrentMonth =
        month.year == today.year && month.month == today.month;
    final startDay = isCurrentMonth ? today.day : 1;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final dayCount = daysInMonth - startDay + 1;

    return SizedBox(
      height: 62 * s,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dayCount,
        itemBuilder: (context, i) {
          final day = DateTime(month.year, month.month, startDay + i);
          final rangeStart = controller.rangeStart.value;
          final rangeEnd = controller.rangeEnd.value;
          final isStart = rangeStart != null && _isSameDay(day, rangeStart);
          final isEnd = rangeEnd != null && _isSameDay(day, rangeEnd);
          final inRange = rangeStart != null &&
              rangeEnd != null &&
              day.isAfter(rangeStart) &&
              day.isBefore(rangeEnd);

          return GestureDetector(
            onTap: () => controller.pickStripDay(day),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44 * s,
              margin: EdgeInsets.only(right: 6 * s),
              color: inRange ? _kGold.withValues(alpha: 0.15) : Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_kWeekdayShort[day.weekday - 1],
                      style: _ui(size: 8 * s, color: _kMuted, spacing: 0.3)),
                  SizedBox(height: 6 * s),
                  Container(
                    width: 32 * s,
                    height: 32 * s,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isStart || isEnd) ? _kGold : Colors.transparent,
                    ),
                    child: Text('${day.day}',
                        style: _ui(
                          size: 11 * s,
                          weight: (isStart || isEnd)
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: (isStart || isEnd) ? Colors.white : _kInk,
                        )),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// ─── Teslim Süresi ─────────────────────────────────────────────────────────
class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.scale, required this.controller});
  final double scale;
  final SendOfferController controller;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Obx(() => _ExpandableCard(
          scale: s,
          icon: Icons.hourglass_empty_rounded,
          label: 'Teslim Süresi',
          valueText: controller.selectedDelivery.value,
          expanded: controller.isDeliveryExpanded.value,
          onToggle: controller.toggleDeliveryExpanded,
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: controller.isCustomDelivery.value
                  ? _CustomDeliveryInput(
                      key: const ValueKey('custom'),
                      scale: s,
                      controller: controller,
                    )
                  : _DeliveryOptionsList(
                      key: const ValueKey('options'),
                      scale: s,
                      controller: controller,
                    ),
            ),
          ),
        ));
  }
}

class _DeliveryOptionsList extends StatelessWidget {
  const _DeliveryOptionsList({super.key, required this.scale, required this.controller});
  final double scale;
  final SendOfferController controller;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final o in SendOfferController.deliveryOptions)
          _DeliveryOptionButton(
            scale: s,
            label: o,
            selected: !controller.isCustomDelivery.value &&
                controller.selectedDelivery.value == o,
            onTap: () => controller.selectDelivery(o),
          ),
        _DeliveryOptionButton(
          scale: s,
          label: 'Özel',
          selected: controller.isCustomDelivery.value,
          onTap: controller.selectCustomDelivery,
        ),
      ],
    );
  }
}

class _DeliveryOptionButton extends StatelessWidget {
  const _DeliveryOptionButton({
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
        width: double.infinity,
        height: 48 * s,
        margin: EdgeInsets.only(bottom: 8 * s),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _kGold : Colors.transparent,
          border: Border.all(color: selected ? _kGold : _kCardBorder),
        ),
        child: Text(
          label,
          style: _display(
            size: 17 * s,
            weight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : _kInk,
          ),
        ),
      ),
    );
  }
}

class _CustomDeliveryInput extends StatelessWidget {
  const _CustomDeliveryInput({super.key, required this.scale, required this.controller});
  final double scale;
  final SendOfferController controller;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      height: 48 * s,
      padding: EdgeInsets.symmetric(horizontal: 12 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kCardBorder),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.cancelCustomDelivery,
            behavior: HitTestBehavior.opaque,
            child: Icon(Icons.arrow_back_rounded, size: 18 * s, color: _kMuted),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: TextField(
              controller: controller.customDeliveryController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: _display(size: 15 * s, color: _kInk),
              onChanged: controller.setCustomDeliveryDays,
              onSubmitted: (_) => controller.submitCustomDelivery(),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                hintText: 'Gün sayısı',
                hintStyle: _ui(size: 9 * s, color: _kMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Lokasyon ─────────────────────────────────────────────────────────────
class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.scale, required this.controller});
  final double scale;
  final SendOfferController controller;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Obx(() => _ExpandableCard(
          scale: s,
          icon: Icons.location_on_outlined,
          label: 'Lokasyon',
          valueText: controller.selectedLocation.value,
          expanded: controller.isLocationExpanded.value,
          onToggle: controller.toggleLocationExpanded,
          child: _LocationList(scale: s, controller: controller),
        ));
  }
}

// 81 il + İstanbul'un iki yakası, büyükşehirler listenin başında olacak
// şekilde seçilebilir dikey liste.
class _LocationList extends StatelessWidget {
  const _LocationList({required this.scale, required this.controller});
  final double scale;
  final SendOfferController controller;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 260 * s,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: SendOfferController.locationOptions.length,
        separatorBuilder: (_, _) => Divider(height: 1, color: _kDivider),
        itemBuilder: (context, i) {
          final name = SendOfferController.locationOptions[i];
          final selected = controller.selectedLocation.value == name;
          return GestureDetector(
            onTap: () => controller.selectLocation(name),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12 * s),
              color: selected ? _kGold.withValues(alpha: 0.1) : Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: _display(
                        size: 19 * s,
                        weight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? _kGold : _kInk,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_rounded, size: 18 * s, color: _kGold),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
