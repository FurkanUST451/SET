import 'package:get/get.dart';

import '../../../data/models/brief_model.dart';
import '../../../data/models/project_model.dart';
import '../../../data/repositories/brief_repository.dart';
import '../../../data/repositories/project_repository.dart';
import '../../../routes/app_routes.dart';
import '../../app/user_controller.dart';

class ClientProjectsController extends GetxController {
  final BriefRepository _briefRepo = Get.find<BriefRepository>();
  final ProjectRepository _projectRepo = Get.find<ProjectRepository>();
  final UserController _userController = Get.find<UserController>();

  final RxList<BriefModel> briefs = <BriefModel>[].obs;
  final RxList<ProjectModel> projects = <ProjectModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMsg = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadBriefs();
  }

  Future<void> loadBriefs() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      final ownerId = _userController.currentUser?.id ?? '';
      if (ownerId.isEmpty) {
        briefs.clear();
        projects.clear();
        return;
      }
      final results = await Future.wait([
        _briefRepo.fetchByOwner(ownerId),
        _projectRepo.fetchByClient(ownerId),
      ]);
      briefs.assignAll(results[0] as List<BriefModel>);
      projects.assignAll(results[1] as List<ProjectModel>);
    } catch (e) {
      errorMsg.value = e.toString();
      briefs.clear();
      projects.clear();
      Get.snackbar(
        'Hata',
        'Projeler yüklenemedi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Onaylı proje kartına dokununca ilişkili brief'in detay sayfasını aç.
  Future<void> openProjectDetail(ProjectModel project) async {
    final briefId = project.briefId;
    if (briefId == null || briefId.isEmpty) {
      Get.snackbar(
        'Hata',
        'Proje detayları bulunamadı',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final brief = await _briefRepo.fetchBrief(briefId);
    if (brief == null) {
      Get.snackbar(
        'Hata',
        'Proje detayları bulunamadı',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(
      AppRoutes.briefDetail,
      arguments: {'brief': brief, 'project': project},
    );
  }

  Future<void> updateBriefNotes(String briefId, String notes) async {
    try {
      await _briefRepo.updateNotes(briefId, notes);
      await loadBriefs();
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Brief güncellenemedi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
