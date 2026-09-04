import 'package:get/get.dart';

import '../modules/auth/login/login_binding.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/auth/register/register_binding.dart';
import '../modules/auth/register/register_view.dart';
import '../modules/client/archive/client_archive_view.dart';
import '../modules/client/brief_share/brief_share_binding.dart';
import '../modules/client/brief_share/brief_share_view.dart';
import '../modules/client/category_picker/category_picker_binding.dart';
import '../modules/client/category_picker/category_picker_view.dart';
import '../modules/client/chat_detail/chat_detail_binding.dart';
import '../modules/client/chat_detail/chat_detail_view.dart';
import '../modules/client/brief_detail/brief_detail_binding.dart';
import '../modules/client/brief_detail/brief_detail_view.dart';
import '../modules/client/project_detail/project_detail_view.dart';
import '../modules/client/portfolio_project_detail/portfolio_project_detail_binding.dart';
import '../modules/client/portfolio_project_detail/portfolio_project_detail_view.dart';
import '../modules/client/portfolio_project_detail/portfolio_team_profile_view.dart';
import '../modules/client/freelancer_detail/freelancer_detail_binding.dart';
import '../modules/client/freelancer_detail/freelancer_detail_view.dart';
import '../modules/client/freelancers_by_category/freelancers_by_category_binding.dart';
import '../modules/client/freelancers_by_category/freelancers_by_category_view.dart';
import '../modules/client/home/client_home_binding.dart';
import '../modules/client/home/client_home_view.dart';
import '../modules/client/offer_review/offer_review_binding.dart';
import '../modules/client/offer_review/offer_review_view.dart';
import '../modules/client/project_mode/project_mode_view.dart';
import '../modules/client/send_offer/send_offer_binding.dart';
import '../modules/client/send_offer/send_offer_view.dart';
import '../modules/client/set_projects/set_projects_view.dart';
import '../modules/freelancer/home/freelancer_home_binding.dart';
import '../modules/freelancer/home/freelancer_home_view.dart';
import '../modules/freelancer/offer_detail/freelancer_offer_detail_binding.dart';
import '../modules/freelancer/offer_detail/freelancer_offer_detail_view.dart';
import '../modules/freelancer/project_detail/project_detail_binding.dart';
import '../modules/freelancer/onboarding/freelancer_onboarding_binding.dart';
import '../modules/freelancer/onboarding/freelancer_onboarding_view.dart';
import '../modules/freelancer/project_detail/freelancer_project_detail_view.dart';
import '../modules/freelancer/set_projects/freelancer_set_projects_view.dart';
import '../modules/freelancer/upload_work/freelancer_upload_work_binding.dart';
import '../modules/freelancer/upload_work/freelancer_upload_work_view.dart';
import '../modules/role_selection/role_selection_binding.dart';
import '../modules/role_selection/role_selection_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_brand_view.dart';
import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_welcome_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splashBrand,
      page: () => const SplashBrandScreen(),
    ),
    GetPage(
      name: AppRoutes.splashWelcome,
      page: () => const SplashWelcomeScreen(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionView(),
      binding: RoleSelectionBinding(),
    ),

    // Client (Hizmet Al)
    GetPage(
      name: AppRoutes.clientHome,
      page: () => const ClientHomeView(),
      binding: ClientHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.categoryPicker,
      page: () => const CategoryPickerView(),
      binding: CategoryPickerBinding(),
    ),
    GetPage(
      name: AppRoutes.freelancersByCategory,
      page: () => const FreelancersByCategoryView(),
      binding: FreelancersByCategoryBinding(),
    ),
    GetPage(
      name: AppRoutes.freelancerDetail,
      page: () => const FreelancerDetailView(),
      binding: FreelancerDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.sendOffer,
      page: () => const SendOfferView(),
      binding: SendOfferBinding(),
    ),
    GetPage(
      name: AppRoutes.briefShare,
      page: () => const BriefShareView(),
      binding: BriefShareBinding(),
    ),
    GetPage(
      name: AppRoutes.projectMode,
      page: () => const ProjectModeView(),
    ),
    GetPage(
      name: AppRoutes.chatDetail,
      page: () => const ChatDetailView(),
      binding: ChatDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.offerReview,
      page: () => const OfferReviewView(),
      binding: OfferReviewBinding(),
    ),
    GetPage(
      name: AppRoutes.projectDetail,
      page: () => const ProjectDetailView(),
    ),
    GetPage(
      name: AppRoutes.briefDetail,
      page: () => const BriefDetailView(),
      binding: BriefDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.setProjects,
      page: () => const SetProjectsView(),
    ),
    GetPage(
      name: AppRoutes.portfolioProjectDetail,
      page: () => const PortfolioProjectDetailView(),
      binding: PortfolioProjectDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.portfolioTeamProfile,
      page: () => const PortfolioTeamProfileView(),
    ),
    GetPage(
      name: AppRoutes.clientArchive,
      page: () => const ClientArchiveView(),
    ),

    // Freelancer (Hizmet Ver) — implementation pending
    GetPage(
      name: AppRoutes.freelancerOnboarding,
      page: () => const FreelancerOnboardingView(),
      binding: FreelancerOnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.freelancerHome,
      page: () => const FreelancerHomeView(),
      binding: FreelancerHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.freelancerOfferDetail,
      page: () => const FreelancerOfferDetailView(),
      binding: FreelancerOfferDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.freelancerProjectDetail,
      page: () => const FreelancerProjectDetailView(),
      binding: FreelancerProjectDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.freelancerUploadWork,
      page: () => const FreelancerUploadWorkView(),
      binding: FreelancerUploadWorkBinding(),
    ),
    GetPage(
      name: AppRoutes.freelancerSetProjects,
      page: () => const FreelancerSetProjectsView(),
    ),
  ];
}
