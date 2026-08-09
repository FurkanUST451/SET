import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../app/auth_controller.dart';
import '../../app/user_controller.dart';

class RegisterController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();
  final UserController _user = Get.find<UserController>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxnString selectedGender = RxnString();

  RxBool get isLoading => _auth.isLoading;
  RxnString get errorMessage => _auth.errorMessage;

  void toggleObscure() => obscurePassword.toggle();
  void setGender(String value) => selectedGender.value = value;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final ageText = ageController.text.trim();
    final ok = await _auth.register(
      name: nameController.text.trim(),
      surname: surnameController.text.trim().isEmpty
          ? null
          : surnameController.text.trim(),
      age: ageText.isEmpty ? null : int.tryParse(ageText),
      gender: selectedGender.value,
      email: emailController.text.trim(),
      password: passwordController.text,
    );
    if (ok) Get.offAllNamed(AppRoutes.roleSelection);
  }

  Future<void> loginWithGoogle() async {
    final result = await _auth.loginWithGoogle();
    if (!result.ok) return;
    if (result.isNewUser) {
      Get.offAllNamed(AppRoutes.roleSelection);
      return;
    }
    // Google hesabı zaten kayıtlıysa (login ekranındaki akışla aynı),
    // rolüne göre doğrudan ana sayfaya yönlendir.
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

  @override
  void onClose() {
    nameController.dispose();
    surnameController.dispose();
    ageController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
