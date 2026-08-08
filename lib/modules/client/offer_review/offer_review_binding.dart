import 'package:get/get.dart';

import 'offer_review_controller.dart';

class OfferReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OfferReviewController());
  }
}
