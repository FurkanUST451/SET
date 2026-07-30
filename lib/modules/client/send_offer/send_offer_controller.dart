import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/brief_model.dart';
import '../../../routes/app_routes.dart';

class SendOfferController extends GetxController {
  late final String category;
  String? _briefId;
  String? _existingNotes;

  bool get isEditMode => _briefId != null;

  // ─── Çekim türü ───────────────────────────────────────────────────────────
  final RxString selectedShootingType = ''.obs;
  final RxBool isShootingTypeExpanded = false.obs;

  // ─── Çekim tarihi ─────────────────────────────────────────────────────────
  final RxBool isDateExpanded = false.obs;
  // null = henüz seçilmedi, true = "Tarih belli", false = "Esnek"
  final Rx<bool?> isDateFixed = Rx<bool?>(null);
  final RxString dateRangeLabel = ''.obs;
  final Rx<DateTime?> rangeStart = Rx<DateTime?>(null);
  final Rx<DateTime?> rangeEnd = Rx<DateTime?>(null);

  // ─── Teslim süresi ────────────────────────────────────────────────────────
  final RxBool isDeliveryExpanded = false.obs;
  final RxString selectedDelivery = ''.obs;
  final RxBool isCustomDelivery = false.obs;
  final TextEditingController customDeliveryController =
      TextEditingController();

  // ─── Lokasyon ─────────────────────────────────────────────────────────────
  final RxBool isLocationExpanded = false.obs;
  final RxString selectedLocation = ''.obs;

  final RxBool isSubmitting = false.obs;

  static const shootingTypes = [
    'Reklam Filmi Yatay',
    'Reklam Filmi Dikey',
    'Marka Filmi',
    'Kurumsal Video',
    'Tanıtım Filmi',
    'Sosyal Medya İçeriği',
  ];

  static const deliveryOptions = [
    '7 Gün',
    '14 Gün',
    '21 Gün',
    '30 Gün',
  ];

  static const locationOptions = [
    'İstanbul / Beşiktaş',
    'İstanbul / Kadıköy',
    'İstanbul / Şişli',
    'Ankara / Çankaya',
    'İzmir / Alsancak',
    'Uzaktan',
  ];

  // Bu kategorilerde çekim mahal bağımsız olduğu için lokasyon sorulmaz.
  static const _noLocationCategories = {
    'CGI & VFX',
    'Ses Tasarımı',
    'Kurgu',
    'Sosyal Medya Yönetimi',
  };

  bool get showLocation => !_noLocationCategories.contains(category);

  int get totalSteps => showLocation ? 4 : 3;

  int get completedSteps {
    var n = 0;
    if (selectedShootingType.value.isNotEmpty) n++;
    if (isDateFixed.value != null && dateRangeLabel.value.isNotEmpty) n++;
    if (selectedDelivery.value.isNotEmpty) n++;
    if (showLocation && selectedLocation.value.isNotEmpty) n++;
    return n;
  }

  static const _monthNames = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    category = (args?['category'] as String?) ?? '';

    final existing = args?['brief'] as BriefModel?;
    if (existing != null) {
      // Edit mode — pre-populate from existing brief
      _briefId = existing.id;
      _existingNotes = existing.answers.notes;
      selectedShootingType.value = existing.answers.shootingType ?? '';

      final existingDateRange = existing.answers.dateRange;
      if (existingDateRange != null &&
          existingDateRange.isNotEmpty &&
          existingDateRange != 'Tarih Belirsiz') {
        isDateFixed.value = true;
        dateRangeLabel.value = existingDateRange;
      } else if (existingDateRange == 'Tarih Belirsiz') {
        isDateFixed.value = false;
        dateRangeLabel.value = 'Esnek';
      }

      selectedDelivery.value = existing.answers.deliveryTime ?? '';
      selectedLocation.value = existing.answers.location ?? '';
    }
  }

  @override
  void onClose() {
    customDeliveryController.dispose();
    super.onClose();
  }

  void toggleShootingTypeExpanded() {
    isShootingTypeExpanded.value = !isShootingTypeExpanded.value;
    if (isShootingTypeExpanded.value) _collapseOthers(_Section.shootingType);
  }

  void toggleDateExpanded() {
    isDateExpanded.value = !isDateExpanded.value;
    if (isDateExpanded.value) _collapseOthers(_Section.date);
  }

  void toggleDeliveryExpanded() {
    isDeliveryExpanded.value = !isDeliveryExpanded.value;
    if (isDeliveryExpanded.value) _collapseOthers(_Section.delivery);
  }

  void toggleLocationExpanded() {
    isLocationExpanded.value = !isLocationExpanded.value;
    if (isLocationExpanded.value) _collapseOthers(_Section.location);
  }

  void _collapseOthers(_Section keep) {
    if (keep != _Section.shootingType) isShootingTypeExpanded.value = false;
    if (keep != _Section.date) isDateExpanded.value = false;
    if (keep != _Section.delivery) isDeliveryExpanded.value = false;
    if (keep != _Section.location) isLocationExpanded.value = false;
  }

  void _advanceTo(_Section? next) {
    isShootingTypeExpanded.value = false;
    isDateExpanded.value = false;
    isDeliveryExpanded.value = false;
    isLocationExpanded.value = false;
    switch (next) {
      case _Section.shootingType:
        isShootingTypeExpanded.value = true;
      case _Section.date:
        isDateExpanded.value = true;
      case _Section.delivery:
        isDeliveryExpanded.value = true;
      case _Section.location:
        isLocationExpanded.value = true;
      case null:
        break;
    }
  }

  void selectShootingType(String type) {
    selectedShootingType.value = type;
    _advanceTo(_Section.date);
  }

  void setDateMode(bool fixed) {
    isDateFixed.value = fixed;
    if (!fixed) {
      dateRangeLabel.value = 'Esnek';
      rangeStart.value = null;
      rangeEnd.value = null;
      _advanceTo(_Section.delivery);
    } else if (dateRangeLabel.value == 'Esnek') {
      dateRangeLabel.value = '';
    }
  }

  void pickStripDay(DateTime day) {
    if (rangeStart.value == null || rangeEnd.value != null) {
      rangeStart.value = day;
      rangeEnd.value = null;
    } else if (day.isBefore(rangeStart.value!)) {
      rangeStart.value = day;
    } else {
      rangeEnd.value = day;
    }
    _syncDateLabel();
    // İlk (başlangıç) seçiminde kart açık kalır; ikinci (bitiş) seçiminde kapanıp
    // bir sonraki karta geçilir.
    if (rangeEnd.value != null) _advanceTo(_Section.delivery);
  }

  void _syncDateLabel() {
    final start = rangeStart.value;
    final end = rangeEnd.value;
    if (start == null) {
      dateRangeLabel.value = '';
    } else if (end == null) {
      dateRangeLabel.value = '${start.day} ${_monthNames[start.month - 1]}';
    } else {
      dateRangeLabel.value = start.month == end.month
          ? '${start.day} - ${end.day} ${_monthNames[start.month - 1]}'
          : '${start.day} ${_monthNames[start.month - 1]} - ${end.day} ${_monthNames[end.month - 1]}';
    }
  }

  void selectDelivery(String value) {
    isCustomDelivery.value = false;
    selectedDelivery.value = value;
    _advanceTo(showLocation ? _Section.location : null);
  }

  void selectCustomDelivery() {
    isCustomDelivery.value = true;
    final days = customDeliveryController.text.trim();
    selectedDelivery.value = days.isEmpty ? '' : '$days Gün';
  }

  void setCustomDeliveryDays(String days) {
    final trimmed = days.trim();
    if (trimmed.isNotEmpty) selectedDelivery.value = '$trimmed Gün';
  }

  void submitCustomDelivery() {
    final trimmed = customDeliveryController.text.trim();
    if (trimmed.isEmpty) return;
    selectedDelivery.value = '$trimmed Gün';
    _advanceTo(showLocation ? _Section.location : null);
  }

  void selectLocation(String value) {
    selectedLocation.value = value;
    _advanceTo(null);
  }

  Future<void> submit() async {
    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isSubmitting.value = false;
    Get.toNamed(
      AppRoutes.briefShare,
      arguments: {
        'category': category,
        'briefId': _briefId,
        'existingNotes': _existingNotes,
        'shootingType': selectedShootingType.value,
        'dateRange': isDateFixed.value == false
            ? 'Tarih Belirsiz'
            : (dateRangeLabel.value.isEmpty
                ? 'Tarih Belirsiz'
                : dateRangeLabel.value),
        'deliveryTime': selectedDelivery.value,
        'budget': null,
        'location': showLocation ? selectedLocation.value : null,
      },
    );
  }
}

enum _Section { shootingType, date, delivery, location }
