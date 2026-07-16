import 'package:get/get.dart';

import '../../../data/models/brief_model.dart';
import '../../../data/repositories/brief_repository.dart';
import '../../app/user_controller.dart';

class FreelancerJobOffersController extends GetxController {
  final BriefRepository _briefRepo = Get.find<BriefRepository>();
  final UserController _userController = Get.find<UserController>();

  final RxList<BriefModel> offers = <BriefModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadOffers();
  }

  Future<void> loadOffers() async {
    try {
      isLoading.value = true;
      final freelancerId = _userController.currentUser?.id ?? '';
      if (freelancerId.isEmpty) {
        offers.clear();
        return;
      }
      offers.assignAll(await _briefRepo.fetchByFreelancer(freelancerId));
    } catch (_) {
      offers.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
