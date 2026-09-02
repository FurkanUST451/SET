class AppAssets {
  AppAssets._();

  static const String _images = 'assets/images';
  static const String _roleSelection = '$_images/role_selection';
  static const String _loginPages = '$_images/login_pages';
  static const String _profilePhotos = '$_images/profile_photos';
  static const String _placeholder = '$_images/placeholder';
  static const String _briefImages = '$_images/brief_images';
  static const String _pageImages = '$_images/page_images';
  static const String _freelancerSet = '$_images/freelancer_set';

  // Login / choose-auth screens
  static const String loginLogo = '$_loginPages/logo.png';
  static const String loginGoogle = '$_loginPages/google.png';
  static const String loginApple = '$_loginPages/apple.png';
  static const String loginEmail = '$_loginPages/mail.png';
  static const String choosePageBg = '$_loginPages/choose_page_bg.jpeg';

  // Profil sayfası ve ayarlar menüsü ikonları
  static const String settingsProfile = '$_loginPages/profile.png';
  static const String settingsMail = '$_loginPages/mail.png';
  static const String settingsPassword = '$_loginPages/pasword.png';
  static const String settingsNotification = '$_loginPages/notification.png';
  static const String settingsLanguage = '$_loginPages/language_nation.png';
  static const String settingsHelp = '$_loginPages/help.png';
  static const String settingsContact = '$_loginPages/contact.png';
  static const String settingsTerms = '$_loginPages/terms.png';
  static const String settingsRole = '$_loginPages/role.png';
  static const String settingsExit = '$_loginPages/exit.png';
  static const String settingsDelete = '$_loginPages/delete.png';
  static const String settingsPortfolio = '$_loginPages/portfolio.png';
  static const String settingsInteraction = '$_loginPages/interaction.png';

  // Role selection screen
  static const String roleTelephone = '$_roleSelection/telephone_hizmet_alan.png';
  static const String roleCamera = '$_roleSelection/video_camera_hizmet_veren.png';

  // Yer tutucu profil fotoğrafları — cinsiyete göre dummy kullanıcılara dağıtılır
  static const List<String> profilePhotosFemale = [
    '$_profilePhotos/female1.png',
    '$_profilePhotos/female2.png',
    '$_profilePhotos/female3.png',
    '$_profilePhotos/female4.png',
  ];
  static const List<String> profilePhotosMale = [
    '$_profilePhotos/male1.png',
    '$_profilePhotos/male2.png',
    '$_profilePhotos/male3.png',
    '$_profilePhotos/male4.png',
    '$_profilePhotos/male5.png',
  ];

  // Proje modu seçimi — "Freelancer Bul" / "SET Halletsin" kart illüstrasyonları
  static const String briefFreelancerIllustration =
      '$_briefImages/mercek_freelancerbul.png';
  static const String briefFreelancerIllustrationShadow =
      '$_briefImages/mercek_shadow.png';
  static const String briefSetIllustration = '$_briefImages/cep_saati.png';
  static const String briefSetIllustrationShadow =
      '$_briefImages/cep_saati_shadow.png';

  // "İki yol var" karşılaştırma ekranı — freelancer / SET ekibi görselleri
  static const String projectModeFreelancerBox =
      '$_freelancerSet/box_freelancer.png';
  static const String projectModeSetRing =
      '$_freelancerSet/ring_role_selection.png';

  // Splash — marka/karşılama ekranlarının ana görseli
  static const String splashHeroAtlas = '$_pageImages/atlas.png';

  // Ana sayfa karşılama (ilk kullanım) hero görseli
  static const String homeClapperboard = '$_pageImages/klaket.png';

  // Splash ekranı — sırayla değişen tanıtım görselleri
  static const List<String> splashPageImages = [
    '$_pageImages/apple.png',
    '$_pageImages/atlas.png',
    '$_pageImages/bird.png',
    '$_pageImages/feather.png',
    '$_pageImages/key.png',
    '$_pageImages/pot.png',
  ];

  // Proje detayı — Mercedes Campaign yer tutucu görselleri
  static const String portfolioMercedesBg = '$_placeholder/mercedes_bg.png';
  static const List<String> portfolioMercedesGallery = [
    '$_placeholder/mercedes_project_image.png',
    '$_placeholder/mercedes_project_image2.png',
    '$_placeholder/mercedes_project_image3.png',
    '$_placeholder/mercedes_project_image4.png',
  ];
}
