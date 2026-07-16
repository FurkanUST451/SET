import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/brief_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/freelancer_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../client/home/client_chats_controller.dart';
import '../freelancer/home/freelancer_chats_controller.dart';
import 'auth_controller.dart';
import 'theme_controller.dart';
import 'user_controller.dart';

/// Uygulama başlarken global olarak ayağa kaldırılan controller'lar
/// ve repository'ler. `permanent: true` ile bellekte kalırlar.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.put<UserRepository>(UserRepository(), permanent: true);
    Get.put<FreelancerRepository>(FreelancerRepository(), permanent: true);
    Get.put<BriefRepository>(BriefRepository(), permanent: true);
    Get.put<ChatRepository>(ChatRepository(), permanent: true);

    // Controllers
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<UserController>(UserController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);

    // Chat controllers — permanent so Get.offAllNamed never disposes them
    Get.put<ClientChatsController>(ClientChatsController(), permanent: true);
    Get.put<FreelancerChatsController>(FreelancerChatsController(), permanent: true);
  }
}
