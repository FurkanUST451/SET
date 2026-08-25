import 'package:get/get.dart';

import '../../data/services/storage_service.dart';
import '../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  static const int pageCount = 2;

  final RxInt currentPage = 0.obs;
  final RxBool canContinue = false.obs;

  bool get isLastPage => currentPage.value == pageCount - 1;

  /// İlgili sayfanın giriş animasyonu bittiğinde (veya kullanıcı atladığında)
  /// çağrılır; "Devam Et" / "Başla" butonunu ortaya çıkarır.
  void onPageReady() => canContinue.value = true;

  void next() {
    if (isLastPage) {
      finish();
      return;
    }
    canContinue.value = false;
    currentPage.value++;
  }

  Future<void> finish() async {
    await StorageService.write(StorageService.onboardingComplete, true);
    Get.offAllNamed(AppRoutes.login);
  }
}
