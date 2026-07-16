import 'package:get/get.dart';

import '../../data/models/user_model.dart';
import '../../data/services/storage_service.dart';

class UserController extends GetxController {
  final Rxn<UserModel> _currentUser = Rxn<UserModel>();

  UserModel? get currentUser => _currentUser.value;
  bool get hasUser => _currentUser.value != null;
  Rxn<UserModel> get userObs => _currentUser;

  void setUser(UserModel user) {
    _currentUser.value = user;
    StorageService.write(StorageService.userId, user.id);
    StorageService.write(StorageService.userRole, user.role.name);
  }

  void clearUser() {
    _currentUser.value = null;
    StorageService.remove(StorageService.userId);
    StorageService.remove(StorageService.userRole);
  }

  void updateRole(UserRole role) {
    final u = _currentUser.value;
    if (u == null) return;
    _currentUser.value = u.copyWith(role: role);
    StorageService.write(StorageService.userRole, role.name);
  }
}
