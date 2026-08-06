import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/brief_model.dart';
import '../../../data/models/freelancer_model.dart';
import '../../../data/repositories/brief_repository.dart';
import '../../../data/repositories/freelancer_repository.dart';
import '../../../routes/app_routes.dart';
import '../home/client_projects_controller.dart';

class BriefDetailController extends GetxController {
  late final BriefModel brief;

  final RxList<FreelancerModel> freelancers = <FreelancerModel>[].obs;
  final RxBool loadingFreelancers = false.obs;
  final RxBool isCancelling = false.obs;

  final _freelancerRepo = Get.find<FreelancerRepository>();
  final _briefRepo = Get.find<BriefRepository>();

  // Onaylı projeye dönüşmüş bir brief burada iptal edilemez — o farklı bir
  // senaryo (proje iptali), henüz kabul edilmemiş teklifler için geçerli.
  bool get canCancel => brief.status != 'accepted' && brief.status != 'cancelled';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    brief = args!['brief'] as BriefModel;
    _loadFreelancers();
  }

  Future<void> _loadFreelancers() async {
    if (brief.sentToIds.isEmpty) return;
    loadingFreelancers.value = true;
    try {
      final results = await Future.wait(
        brief.sentToIds.map((id) => _freelancerRepo.fetchByUserId(id)),
      );
      freelancers.assignAll(results.whereType<FreelancerModel>());
    } finally {
      loadingFreelancers.value = false;
    }
  }

  void openEdit() {
    Get.toNamed(
      AppRoutes.sendOffer,
      arguments: {'category': brief.category, 'brief': brief},
    );
  }

  void sendToNewFreelancer() {
    Get.toNamed(
      AppRoutes.freelancersByCategory,
      arguments: {'category': brief.category, 'briefId': brief.id},
    );
  }

  void refreshBriefs() {
    try {
      Get.find<ClientProjectsController>().loadBriefs();
    } catch (_) {}
  }

  Future<void> cancelBrief(String reason) async {
    if (isCancelling.value) return;
    isCancelling.value = true;
    try {
      await _briefRepo.cancelBrief(brief.id, reason);
      refreshBriefs();
      isCancelling.value = false;
      Get.back<void>(); // dialog'u kapat
      Get.back<void>(); // brief detay sayfasından çık — artık iptal edildi
    } catch (_) {
      isCancelling.value = false;
      Get.snackbar(
        'Hata',
        'Brief iptal edilemedi. Lütfen tekrar deneyin.',
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }
}
