import 'package:get/get.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../routes/app_routes.dart';
import '../app/user_controller.dart';

class RoleSelectionController extends GetxController {
  final UserController _user = Get.find<UserController>();
  final UserRepository _userRepo = Get.find<UserRepository>();

  final RxBool isLoading = false.obs;
  final Rx<UserRole?> selectedRole = Rx<UserRole?>(null);

  void selectRole(UserRole role) {
    selectedRole.value = role;
  }

  /// Kart tek dokunuşla seçilir ve akış devam eder — ayrı "DEVAM ET" butonu yok.
  Future<void> selectAndContinue(UserRole role) async {
    if (isLoading.value) return;
    selectRole(role);
    await confirm();
  }

  Future<void> confirm() async {
    final role = selectedRole.value;
    if (role == null || isLoading.value) return;

    isLoading.value = true;
    try {
      _user.updateRole(role);
      final userId = _user.currentUser?.id;
      if (userId != null) {
        await _userRepo.updateRole(userId, role);
      }
    } finally {
      isLoading.value = false;
    }

    switch (role) {
      case UserRole.client:
        Get.offAllNamed(AppRoutes.clientHome);
      case UserRole.freelancer:
        Get.offAllNamed(AppRoutes.freelancerOnboarding);
    }
  }
}
