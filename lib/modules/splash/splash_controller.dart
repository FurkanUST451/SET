import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/storage_service.dart';
import '../../routes/app_routes.dart';
import '../app/user_controller.dart';

class SplashController extends GetxController {
  final UserController _userController = Get.find<UserController>();
  final UserRepository _userRepo = Get.find<UserRepository>();

  @override
  void onReady() {
    super.onReady();
    _decideInitialRoute();
  }

  Future<void> _decideInitialRoute() async {
    await Future.delayed(const Duration(seconds: 2));

    final hasOnboarded =
        StorageService.read<bool>(StorageService.onboardingComplete) ?? false;

    // Onboarding hiç gösterilmemişse oraya gönder
    if (!hasOnboarded) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    // Firebase Auth oturumu yoksa her zaman giriş ekranına
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      StorageService.remove(StorageService.userId);
      StorageService.remove(StorageService.userRole);
      Get.offAllNamed(AppRoutes.chooseAuth);
      return;
    }

    // Önceki oturumdan gelen kullanıcıyı UserController'a yükle
    if (!_userController.hasUser) {
      try {
        final stored = await _userRepo.fetchUser(firebaseUser.uid);
        if (stored != null) _userController.setUser(stored);
      } catch (_) {}
    }

    final roleName = StorageService.read<String>(StorageService.userRole);

    // Rol seçilmemişse role selection'a
    if (roleName == null) {
      Get.offAllNamed(AppRoutes.roleSelection);
      return;
    }

    // Rol belirli → doğrudan home'a
    switch (UserRole.fromName(roleName)) {
      case UserRole.client:
        Get.offAllNamed(AppRoutes.clientHome);
      case UserRole.freelancer:
        Get.offAllNamed(AppRoutes.freelancerHome);
    }
  }
}
