import 'package:get/get.dart';

import 'brief_detail_controller.dart';

class BriefDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BriefDetailController());
  }
}
