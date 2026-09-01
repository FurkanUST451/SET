import 'package:get/get.dart';

import '../../../data/models/freelancer_model.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../freelancers_by_category/freelancers_by_category_controller.dart';

class FreelancerDetailController extends GetxController {
  late final FreelancerModel? freelancer;
  late final UserModel? user;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    freelancer = args?['freelancer'] as FreelancerModel?;
    user = args?['user'] as UserModel?;
  }

  void sendOffer() {
    Get.toNamed(AppRoutes.chatDetail, arguments: {
      'name': user?.name ?? 'Freelancer',
    });
  }

  void openChat() {
    Get.toNamed(AppRoutes.chatDetail, arguments: {'name': user?.name});
  }

  // Bu profil, "Ekibini sen kur" (freelancers_by_category) listesinden
  // açıldıysa alttaki "Seçime ekle" çubuğu o ekranın seçim durumunu
  // doğrudan günceller. Listesi hâlâ bellekte değilse (ör. başka bir
  // akıştan gelindiyse) sessizce yok sayılır.
  FreelancersByCategoryController? get listController =>
      Get.isRegistered<FreelancersByCategoryController>()
          ? Get.find<FreelancersByCategoryController>()
          : null;

  void toggleSelectionInList() {
    final f = freelancer;
    final list = listController;
    if (f == null || list == null) return;
    list.toggleSelect(f);
  }
}
