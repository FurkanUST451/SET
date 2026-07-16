class AppStrings {
  AppStrings._();

  static const String appName = 'SET';
  static const String appTagline = 'Video prodüksiyonun buluşma noktası';

  // Auth
  static const String login = 'Giriş Yap';
  static const String register = 'Kayıt Ol';
  static const String logout = 'Çıkış Yap';
  static const String email = 'E-posta';
  static const String password = 'Şifre';
  static const String fullName = 'Ad Soyad';
  static const String forgotPassword = 'Şifremi unuttum';
  static const String dontHaveAccount = 'Hesabın yok mu?';
  static const String alreadyHaveAccount = 'Zaten hesabın var mı?';

  // Roles
  static const String roleSelectionTitle = 'Nasıl başlamak istersin?';
  static const String roleClient = 'Hizmet Al';
  static const String roleClientDesc =
      'Projen için doğru freelancer\'ı keşfet ve teklif gönder.';
  static const String roleFreelancer = 'Hizmet Ver';
  static const String roleFreelancerDesc =
      'Yeteneklerini sergile, projeler al.';

  // Tabs
  static const String tabDiscover = 'Keşfet';
  static const String tabChat = 'Sohbet';
  static const String tabHome = 'Ana Sayfa';
  static const String tabMyProjects = 'Projelerim';
  static const String tabProfile = 'Profil';
  static const String tabJobOffers = 'Teklifler';

  // Common
  static const String continueLabel = 'Devam';
  static const String back = 'Geri';
  static const String next = 'İleri';
  static const String finish = 'Bitir';
  static const String save = 'Kaydet';
  static const String cancel = 'İptal';
  static const String send = 'Gönder';
  static const String search = 'Ara';

  // Errors / validation
  static const String requiredField = 'Bu alan boş bırakılamaz';
  static const String invalidEmail = 'Geçerli bir e-posta gir';
  static const String passwordTooShort = 'Şifre en az 6 karakter olmalı';
}
