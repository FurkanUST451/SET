class AppRoutes {
  AppRoutes._();

  // Boot
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  // Auth
  static const String chooseAuth = '/choose-auth';
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
  static const String projectDetail = '/client/project-detail';
  static const String briefDetail = '/client/brief-detail';
  static const String setProjects = '/client/set-projects';

  // Freelancer (Hizmet Ver) flow — implementation pending
  static const String freelancerOnboarding = '/freelancer/onboarding';
  static const String freelancerHome = '/freelancer/home';
  static const String freelancerOfferDetail = '/freelancer/offer-detail';
  static const String freelancerProjectDetail = '/freelancer/project-detail';
}
