import 'package:get/get.dart';

import 'client_home_controller.dart';
import 'client_projects_controller.dart';

class ClientHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClientHomeController());
    Get.lazyPut(() => ClientProjectsController());
  }
}
