import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FreelancerHomeController extends GetxController {
  static const int homeTabIndex = 0;

  final RxInt currentIndex = 0.obs;
  DateTime? _lastBackPressAt;

  void changeTab(int index) => currentIndex.value = index;

  // Geri tuşu: önce ana sekmeye dön, orada da isek çift basışla çıkışa izin ver.
  bool handleBackPress() {
    if (currentIndex.value != homeTabIndex) {
      currentIndex.value = homeTabIndex;
      return false;
    }
    final now = DateTime.now();
    if (_lastBackPressAt != null &&
        now.difference(_lastBackPressAt!) < const Duration(seconds: 2)) {
      return true;
    }
    _lastBackPressAt = now;
    Get.snackbar(
      '',
      'Çıkmak için tekrar basın',
      titleText: const SizedBox.shrink(),
      messageText: const Text(
        'Çıkmak için tekrar basın',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.black87,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
    return false;
  }
}
