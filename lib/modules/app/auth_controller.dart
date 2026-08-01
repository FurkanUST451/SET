import 'dart:async';

import 'package:get/get.dart';

import '../../core/utils/avatar_image.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/storage_service.dart';
import 'user_controller.dart';

class AuthController extends GetxController {
  final AuthRepository _repo = Get.find<AuthRepository>();
  final UserRepository _userRepo = Get.find<UserRepository>();
  final UserController _user = Get.find<UserController>();
  final NotificationService _notifications = Get.find<NotificationService>();

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  bool get isLoggedIn =>
      _user.hasUser || StorageService.has(StorageService.userId);

  Future<bool> login({required String email, required String password}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final authUser = await _repo.login(email: email, password: password);
      // Firestore'dan tam profili çek
      final stored = await _userRepo.fetchUser(authUser.id);
      _user.setUser(stored ?? authUser);
      // Bildirim izni diyaloğu + FCM token alımı saniyeler sürebilir; login'i
      // bloklamasın diye arka planda çalıştırıyoruz.
      unawaited(_notifications.registerDevice(authUser.id));
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String name,
    String? surname,
    int? age,
    String? gender,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final authUser = await _repo.register(
        name: name,
        email: email,
        password: password,
      );
      final fullUser = authUser.copyWith(
        surname: surname,
        age: age,
        gender: gender,
        avatarUrl: placeholderAvatarFor(gender, authUser.id),
      );
      // Firestore'a kullanıcı profilini kaydet
      await _userRepo.upsertUser(fullUser);
      _user.setUser(fullUser);
      unawaited(_notifications.registerDevice(fullUser.id));
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _notifications.unregisterDevice();
      await _repo.logout();
      _user.clearUser();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) =>
      _repo.sendPasswordResetEmail(email);
}
