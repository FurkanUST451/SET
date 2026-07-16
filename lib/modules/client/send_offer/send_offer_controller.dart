import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/brief_model.dart';
import '../../../routes/app_routes.dart';

class SendOfferController extends GetxController {
  late final String category;
  String? _briefId;
  String? _existingNotes;

  bool get isEditMode => _briefId != null;

  final RxString selectedShootingType = ''.obs;
  final RxBool isShootingTypeExpanded = false.obs;

  final RxBool hasFixedDate = false.obs;
  final RxString dateRangeLabel = ''.obs;

  final RxString selectedDelivery = ''.obs;
  final RxString selectedBudget = ''.obs;
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
    '3 Gün',
    '7 Gün',
    '14 Gün',
    '1 Ay',
    '2+ Ay',
  ];

  static const budgetOptions = [
    '10.000₺ - 30.000₺',
    '30.000₺ - 50.000₺',
    '50.000₺ - 120.000₺',
    '120.000₺ - 300.000₺',
    '300.000₺+',
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
      selectedShootingType.value =
          existing.answers.shootingType ?? 'Reklam Filmi Yatay';

      final existingDateRange = existing.answers.dateRange;
      if (existingDateRange != null &&
          existingDateRange.isNotEmpty &&
          existingDateRange != 'Tarih Belirsiz') {
        hasFixedDate.value = true;
        dateRangeLabel.value = existingDateRange;
      }

      selectedDelivery.value = existing.answers.deliveryTime ?? '7 Gün';
      selectedBudget.value = existing.answers.budget ?? '50.000₺ - 120.000₺';
      selectedLocation.value =
          existing.answers.location ?? 'İstanbul / Beşiktaş';
    } else {
      // New brief — defaults
      selectedShootingType.value = 'Reklam Filmi Yatay';
      selectedDelivery.value = '7 Gün';
      selectedBudget.value = '50.000₺ - 120.000₺';
      selectedLocation.value = 'İstanbul / Beşiktaş';
    }
  }

  void toggleShootingTypeExpanded() =>
      isShootingTypeExpanded.value = !isShootingTypeExpanded.value;

  void selectShootingType(String type) {
    selectedShootingType.value = type;
    isShootingTypeExpanded.value = false;
  }

  void setHasFixedDate(bool value) {
    hasFixedDate.value = value;
    if (!value) dateRangeLabel.value = '';
  }

  void setPickedDateRange(DateTimeRange range) {
    final start = range.start;
    final end = range.end;
    dateRangeLabel.value = start.month == end.month
        ? '${start.day} - ${end.day} ${_monthNames[start.month - 1]}'
        : '${start.day} ${_monthNames[start.month - 1]} - ${end.day} ${_monthNames[end.month - 1]}';
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
        'dateRange': hasFixedDate.value && dateRangeLabel.value.isNotEmpty
            ? dateRangeLabel.value
            : 'Tarih Belirsiz',
        'deliveryTime': selectedDelivery.value,
        'budget': selectedBudget.value,
        'location': showLocation ? selectedLocation.value : null,
      },
    );
  }
}
