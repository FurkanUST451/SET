class AppAssets {
  AppAssets._();

  static const String _images = 'assets/images';
  static const String _roleSelection = '$_images/role_selection';
  static const String _splashScreens = '$_images/splash_screens';
  static const String _welcomePages = '$_images/welcome_pages';
  static const String _loginPages = '$_images/login_pages';

  // Login / choose-auth screens
  static const String loginLogo = '$_loginPages/logo.png';
  static const String loginGoogle = '$_loginPages/login_google.png';
  static const String loginApple = '$_loginPages/login_apple.png';
  static const String loginEmail = '$_loginPages/login_email.png';
  static const String choosePageBg = '$_loginPages/choose_page_bg.jpeg';

  // Role selection screen
  static const String roleProjectClient = '$_roleSelection/project_client.jpg';
  static const String roleProjectClient2 = '$_roleSelection/project_client2.jpeg';
  static const String roleFreelancer = '$_roleSelection/freelancer.jpg';

  // Onboarding / splash screens
  static const String splashScreen1 = '$_splashScreens/splashsayfa1.png';
  static const String splashScreen2 = '$_splashScreens/splash_screen2.png';
  static const String splashScreen3 = '$_splashScreens/splash_screen3.png';

  // Welcome page backgrounds (JPEG - %99 küçüldü)
  static const String welcomeBg1 = '$_welcomePages/welcom_page_bg_1.jpg';
  static const String welcomeBg2 = '$_welcomePages/welcome_page_bg_2.jpg';
  static const String welcomeBg3 = '$_welcomePages/welcome_page_bg_3.jpg';

  // Welcome page mascots (PNG - resize ile %80-94 küçüldü)
  static const String welcomeMascot1 = '$_welcomePages/welcome_page_mascot_1.png';
  static const String welcomeMascot2 = '$_welcomePages/welcome_page_mascot_2.png';
  static const String welcomeMascot3 = '$_welcomePages/welcome_page_mascot_3.png';
}
