import 'package:get/get.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../routes/app_routes.dart';
import '../app/user_controller.dart';

class RoleSelectionController extends GetxController {
  final UserController _user = Get.find<UserController>();
  final UserRepository _userRepo = Get.find<UserRepository>();

  final RxBool isLoading = false.obs;

  Future<void> select(UserRole role) async {
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
