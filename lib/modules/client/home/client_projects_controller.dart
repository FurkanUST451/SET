import 'package:get/get.dart';

import '../../../data/models/brief_model.dart';
import '../../../data/repositories/brief_repository.dart';
import '../../app/user_controller.dart';

class ClientProjectsController extends GetxController {
  final BriefRepository _briefRepo = Get.find<BriefRepository>();
  final UserController _userController = Get.find<UserController>();

  final RxList<BriefModel> briefs = <BriefModel>[].obs;
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
        return;
      }
      briefs.assignAll(await _briefRepo.fetchByOwner(ownerId));
    } catch (e) {
      errorMsg.value = e.toString();
      briefs.clear();
      Get.snackbar(
        'Hata',
        'Projeler yüklenemedi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
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
