import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/brief_model.dart';
import '../../../data/repositories/brief_repository.dart';
import '../../../modules/app/user_controller.dart';
import '../../../modules/client/home/client_projects_controller.dart';
import '../../../routes/app_routes.dart';

class BriefShareController extends GetxController {
  late final String category;
  late final String _shootingType;
  late final List<String> _vibes;
  late final String _dateRange;
  late final String _deliveryTime;
  late final String _budget;
  late final String _location;
  String? _briefId;

  bool get isEditMode => _briefId != null;

  final briefText = TextEditingController();
  final RxInt charCount = 0.obs;
  final RxBool isLoading = false.obs;

  final _repo = Get.find<BriefRepository>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    category = (args?['category'] as String?) ?? '';
    _briefId = args?['briefId'] as String?;
    _shootingType = (args?['shootingType'] as String?) ?? '';
    _vibes = (args?['vibes'] as List?)?.cast<String>() ?? [];
    _dateRange = (args?['dateRange'] as String?) ?? '';
    _deliveryTime = (args?['deliveryTime'] as String?) ?? '';
    _budget = (args?['budget'] as String?) ?? '';
    _location = (args?['location'] as String?) ?? '';

    final existingNotes = args?['existingNotes'] as String?;
    if (existingNotes != null && existingNotes.isNotEmpty) {
      briefText.text = existingNotes;
      charCount.value = existingNotes.length;
    }

    briefText.addListener(() => charCount.value = briefText.text.length);
  }

  Future<void> submit() async {
    final text = briefText.text.trim();
    if (text.isEmpty) {
      Get.snackbar('Hata', "Brief boş bırakılamaz.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final answers = BriefAnswers(
        shootingType: _shootingType.isNotEmpty ? _shootingType : null,
        vibes: _vibes.isNotEmpty ? _vibes : null,
        dateRange: _dateRange.isNotEmpty ? _dateRange : null,
        deliveryTime: _deliveryTime.isNotEmpty ? _deliveryTime : null,
        budget: _budget.isNotEmpty ? _budget : null,
        location: _location.isNotEmpty ? _location : null,
        notes: text,
      );

      if (isEditMode) {
        // Update existing brief — only answers + updatedAt change
        final userController = Get.find<UserController>();
        final placeholder = BriefModel(
          id: _briefId!,
          ownerId: userController.currentUser?.id ?? '',
          title: category.isNotEmpty ? category : 'Brief',
          category: category,
          status: 'submitted',
          answers: answers,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _repo.updateBrief(placeholder);
        try {
          Get.find<ClientProjectsController>().loadBriefs();
        } catch (_) {}
        Get.until((route) => route.settings.name == AppRoutes.clientHome);
      } else {
        final userController = Get.find<UserController>();
        final ownerId = userController.currentUser?.id ?? '';
        final now = DateTime.now();
        final docId = FirebaseFirestore.instance.collection('briefs').doc().id;

        final brief = BriefModel(
          id: docId,
          ownerId: ownerId,
          title: category.isNotEmpty ? category : 'Brief',
          category: category,
          status: 'submitted',
          answers: answers,
          createdAt: now,
          updatedAt: now,
        );

        await _repo.saveBrief(brief);
        Get.toNamed(
          AppRoutes.projectMode,
          arguments: {'category': category, 'briefId': docId},
        );
      }
    } catch (e) {
      Get.snackbar('Hata', 'Brief kaydedilemedi: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    briefText.dispose();
    super.onClose();
  }
}
