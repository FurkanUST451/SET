import 'package:get/get.dart';

import '../../../data/models/brief_model.dart';
import '../../../data/models/freelancer_model.dart';
import '../../../data/repositories/freelancer_repository.dart';
import '../../../routes/app_routes.dart';
import '../home/client_projects_controller.dart';

class BriefDetailController extends GetxController {
  late final BriefModel brief;

  final RxList<FreelancerModel> freelancers = <FreelancerModel>[].obs;
  final RxBool loadingFreelancers = false.obs;

  final _freelancerRepo = Get.find<FreelancerRepository>();

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
}
