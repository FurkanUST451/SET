import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/notification_service.dart';
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

  // Açılıştaki fotoğraf animasyonu en az bu kadar görünür kalır. Süre
  // "started" anından itibaren ölçülür; uygulama arka planda zaten açılmış
  // ve veriler önceden çekilmişse (_resolveRoute hızlı biterse) sadece
  // kalan fark kadar beklenir — bu pay toplam süreye asla üstüne eklenmez.
  static const _minSplashDuration = Duration(milliseconds: 500);

  Future<void> _decideInitialRoute() async {
    final started = DateTime.now();
    final route = await _resolveRoute();
    final elapsed = DateTime.now().difference(started);
    if (elapsed < _minSplashDuration) {
      await Future.delayed(_minSplashDuration - elapsed);
    }
    Get.offAllNamed(route);
  }

  Future<String> _resolveRoute() async {
    final hasOnboarded =
        StorageService.read<bool>(StorageService.onboardingComplete) ?? false;

    // Onboarding hiç gösterilmemişse oraya gönder
    if (!hasOnboarded) {
      return AppRoutes.onboarding;
    }

    // Firebase Auth oturumu yoksa her zaman giriş ekranına
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      StorageService.remove(StorageService.userId);
      StorageService.remove(StorageService.userRole);
      return AppRoutes.login;
    }

    // Önceki oturumdan gelen kullanıcıyı UserController'a yükle
    if (!_userController.hasUser) {
      try {
        final stored = await _userRepo.fetchUser(firebaseUser.uid);
        if (stored != null) _userController.setUser(stored);
      } catch (_) {}
    }

    // Oturum devam ediyorsa cihaz token'ını güncelle (bildirimler için)
    Get.find<NotificationService>().registerDevice(firebaseUser.uid);

    final roleName = StorageService.read<String>(StorageService.userRole);

    // Rol seçilmemişse role selection'a
    if (roleName == null) {
      return AppRoutes.roleSelection;
    }

    // Rol belirli → doğrudan home'a
    switch (UserRole.fromName(roleName)) {
      case UserRole.client:
        return AppRoutes.clientHome;
      case UserRole.freelancer:
        return AppRoutes.freelancerHome;
    }
  }
}
