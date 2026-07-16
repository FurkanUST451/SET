import 'package:get/get.dart';

import '../../../data/repositories/chat_repository.dart';
import 'freelancer_offer_detail_controller.dart';

class FreelancerOfferDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FreelancerOfferDetailController>(
      () => FreelancerOfferDetailController(),
    );
    if (!Get.isRegistered<ChatRepository>()) {
      Get.put<ChatRepository>(ChatRepository(), permanent: true);
    }
  }
}
