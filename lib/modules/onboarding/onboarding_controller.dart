import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../../data/services/storage_service.dart';
import '../../routes/app_routes.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    this.icon,
    this.backgroundImage,
    this.mascotImage,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final String? backgroundImage;
  final String? mascotImage;
}

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  static const List<OnboardingPageData> pages = [
    OnboardingPageData(
      title: '',
      subtitle: '',
      backgroundImage: AppAssets.welcomeBg1,
      mascotImage: AppAssets.welcomeMascot1,
    ),
    OnboardingPageData(
      title: '',
      subtitle: '',
      backgroundImage: AppAssets.welcomeBg2,
      mascotImage: AppAssets.welcomeMascot2,
    ),
    OnboardingPageData(
      title: '',
      subtitle: '',
      backgroundImage: AppAssets.welcomeBg3,
      mascotImage: AppAssets.welcomeMascot3,
    ),
  ];

  bool get isLastPage => currentPage.value == pages.length - 1;

  void onPageChanged(int index) => currentPage.value = index;

  void next() {
    if (isLastPage) {
      finish();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void skip() => finish();

  Future<void> finish() async {
    await StorageService.write(StorageService.onboardingComplete, true);
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
