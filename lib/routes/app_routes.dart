class AppRoutes {
  AppRoutes._();

  // Boot
  static const String splashBrand = '/splash-brand';
  static const String splashWelcome = '/splash-welcome';
  static const String splash = '/splash';

  // Auth
  static const String login = '/login';
  static const String register = '/register';

  // Role
  static const String roleSelection = '/role-selection';

  // Client (Hizmet Al) flow
  static const String clientHome = '/client/home';
  static const String categoryPicker = '/client/category-picker';
  static const String freelancersByCategory = '/client/freelancers-by-category';
  static const String freelancerDetail = '/client/freelancer-detail';
  static const String sendOffer = '/client/send-offer';
  static const String briefShare = '/client/brief-share';
  static const String projectMode = '/client/project-mode';
  static const String chatDetail = '/client/chat-detail';
  static const String offerReview = '/client/offer-review';
  static const String projectDetail = '/client/project-detail';
  static const String briefDetail = '/client/brief-detail';
  static const String setProjects = '/client/set-projects';
  static const String portfolioProjectDetail = '/client/portfolio-project-detail';
  static const String portfolioTeamProfile = '/client/portfolio-team-profile';
  static const String clientArchive = '/client/archive';

  // Freelancer (Hizmet Ver) flow — implementation pending
  static const String freelancerOnboarding = '/freelancer/onboarding';
  static const String freelancerHome = '/freelancer/home';
  static const String freelancerOfferDetail = '/freelancer/offer-detail';
  static const String freelancerProjectDetail = '/freelancer/project-detail';
  static const String freelancerUploadWork = '/freelancer/upload-work';
  static const String freelancerSetProjects = '/freelancer/set-projects';
}
