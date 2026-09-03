import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/brief_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/freelancer_repository.dart';
import '../../data/repositories/offer_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/work_repository.dart';
import '../../data/services/notification_service.dart';
import '../client/home/client_chats_controller.dart';
import '../freelancer/home/freelancer_chats_controller.dart';
import 'auth_controller.dart';
import 'theme_controller.dart';
import 'user_controller.dart';
import 'works_controller.dart';

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
    Get.put<ProjectRepository>(
      ProjectRepository(briefRepository: Get.find<BriefRepository>()),
      permanent: true,
    );
    Get.put<OfferRepository>(
      OfferRepository(
        chatRepository: Get.find<ChatRepository>(),
        projectRepository: Get.find<ProjectRepository>(),
        briefRepository: Get.find<BriefRepository>(),
      ),
      permanent: true,
    );
    Get.put<WorkRepository>(WorkRepository(), permanent: true);
    Get.put<ProgressRepository>(ProgressRepository(), permanent: true);
    // Genel bildirme (report) sistemi — Keşfet gönderileri ve ileride
    // sohbet mesajları gibi farklı içerik türleri aynı repo'yu paylaşır.
    Get.put<ReportRepository>(ReportRepository(), permanent: true);

    // Services
    Get.put<NotificationService>(NotificationService(), permanent: true);

    // Controllers
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<UserController>(UserController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);

    // Chat controllers — permanent so Get.offAllNamed never disposes them
    Get.put<ClientChatsController>(ClientChatsController(), permanent: true);
    Get.put<FreelancerChatsController>(FreelancerChatsController(), permanent: true);

    // Keşfet akışı — hem client hem freelancer aynı controller'ı paylaşır
    Get.put<WorksController>(WorksController(), permanent: true);
  }
}
