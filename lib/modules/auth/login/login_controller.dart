import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../app/auth_controller.dart';
import '../../app/user_controller.dart';

class LoginController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();
  final UserController _user = Get.find<UserController>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: 'ornek@set.app');
  final passwordController = TextEditingController(text: '123456');
  final RxBool obscurePassword = true.obs;

  RxBool get isLoading => _auth.isLoading;
  RxnString get errorMessage => _auth.errorMessage;

  void toggleObscure() => obscurePassword.toggle();

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final ok = await _auth.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
    if (!ok) return;

    final role = _user.currentUser?.role;
    switch (role) {
      case UserRole.freelancer:
        Get.offAllNamed(AppRoutes.freelancerHome);
      case UserRole.client:
        Get.offAllNamed(AppRoutes.clientHome);
      case null:
        Get.offAllNamed(AppRoutes.roleSelection);
    }
  }

  void goToRegister() => Get.toNamed(AppRoutes.register);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
