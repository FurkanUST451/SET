import '../../core/constants/app_assets.dart';
import '../models/freelancer_model.dart';
import '../models/portfolio_project_model.dart';
import '../models/user_model.dart';

class DummyData {
  DummyData._();

  static const List<String> categories = [
    'Video Çekim',
    'Fotoğraf',
    'Sosyal Medya Yönetimi',
    'Grafik Tasarım',
    'Kurgu',
    'CGI & VFX',
    'Ses Tasarımı',
  ];

  static final List<PortfolioProjectModel> portfolioProjects = [
    PortfolioProjectModel(
      id: 'w1',
      title: 'Mercedes\nCampaign',
      subtitle: 'Lüks. Performans.\nSinema...',
      tagLabel: 'TİCARİ REKLAM',
      isFeatured: true,
      year: '2023',
      durationLabel: '4 HAFTA',
      status: PortfolioStatus.completed,
      description:
          "Mercedes'in yeni model lansmanı için sinematik bir tanıtım filmi "
          'hazırlandı. Güç, zarafet ve ileri teknolojiyi vurgulayan görsel bir '
          'anlatı oluşturuldu.',
      category: 'Video Çekim',
      budgetRangeLabel: '250K - 500K ₺',
      location: 'İstanbul',
      coverImageUrl: AppAssets.portfolioMercedesBg,
      galleryImageUrls: AppAssets.portfolioMercedesGallery,
      team: [
        PortfolioTeamMember(
          name: 'Eren A.',
          role: 'YÖNETMEN',
          avatarUrl: AppAssets.profilePhotosMale[0],
        ),
        PortfolioTeamMember(
          name: 'Murat K.',
          role: 'GÖRÜNTÜ YÖN.',
          avatarUrl: AppAssets.profilePhotosMale[1],
        ),
        PortfolioTeamMember(
          name: 'Selin D.',
          role: 'KURGU',
          avatarUrl: AppAssets.profilePhotosFemale[0],
        ),
        PortfolioTeamMember(
          name: 'Deniz Y.',
          role: 'VFX ARTIST',
          avatarUrl: AppAssets.profilePhotosFemale[1],
        ),
        PortfolioTeamMember(
          name: 'Kaan T.',
          role: 'SES TASARIM',
          avatarUrl: AppAssets.profilePhotosMale[2],
        ),
        PortfolioTeamMember(
          name: 'İlker P.',
          role: 'COLORIST',
          avatarUrl: AppAssets.profilePhotosMale[3],
        ),
      ],
      processStages: const [
        PortfolioProcessStage(label: 'Brief & Analiz', done: true),
        PortfolioProcessStage(label: 'Pre-Prodüksiyon', done: true),
        PortfolioProcessStage(label: 'Prodüksiyon', done: true),
        PortfolioProcessStage(label: 'Post-Prodüksiyon', done: true),
        PortfolioProcessStage(label: 'Teslim', done: true),
      ],
    ),
    PortfolioProjectModel(
      id: 'w4',
      title: 'Nike Motion Project',
      subtitle: 'Hareket. Enerji. Marka.',
      tagLabel: 'VİDEO',
      year: '2023',
      durationLabel: '3 HAFTA',
      status: PortfolioStatus.completed,
      description:
          "Nike'ın yeni koleksiyonu için dinamik bir motion graphics serisi "
          'üretildi. Sosyal medya formatlarına özel kurgular hazırlandı.',
      category: 'Kurgu',
      budgetRangeLabel: '100K - 250K ₺',
      location: 'İstanbul',
      galleryImageUrls: const [],
      team: [
        PortfolioTeamMember(
          name: 'Ayşe Y.',
          role: 'YÖNETMEN',
          avatarUrl: AppAssets.profilePhotosFemale[2],
        ),
        PortfolioTeamMember(
          name: 'Ozan B.',
          role: 'MOTION DESIGNER',
          avatarUrl: AppAssets.profilePhotosMale[0],
        ),
        PortfolioTeamMember(
          name: 'Nil K.',
          role: 'KURGU',
          avatarUrl: AppAssets.profilePhotosFemale[3],
        ),
      ],
      processStages: const [
        PortfolioProcessStage(label: 'Brief & Analiz', done: true),
        PortfolioProcessStage(label: 'Pre-Prodüksiyon', done: true),
        PortfolioProcessStage(label: 'Prodüksiyon', done: true),
        PortfolioProcessStage(label: 'Post-Prodüksiyon', done: true),
        PortfolioProcessStage(label: 'Teslim', done: true),
      ],
    ),
    PortfolioProjectModel(
      id: 'w5',
      title: 'Netflix Documentary',
      subtitle: 'Gerçek hikayeler, sinematik anlatım.',
      tagLabel: 'BELGESEL',
      year: '2024',
      durationLabel: '8 HAFTA',
      status: PortfolioStatus.ongoing,
      description:
          'Netflix için hazırlanan belgesel projesinde çekim yönetiminden '
          'renk düzeltmeye kadar tüm prodüksiyon süreci yürütüldü.',
      category: 'Video Çekim',
      budgetRangeLabel: '500K - 1M ₺',
      location: 'İstanbul',
      galleryImageUrls: const [],
      team: [
        PortfolioTeamMember(
          name: 'Barış S.',
          role: 'YÖNETMEN',
          avatarUrl: AppAssets.profilePhotosMale[1],
        ),
        PortfolioTeamMember(
          name: 'Ece T.',
          role: 'GÖRÜNTÜ YÖN.',
          avatarUrl: AppAssets.profilePhotosFemale[0],
        ),
        PortfolioTeamMember(
          name: 'Mert A.',
          role: 'KURGU',
          avatarUrl: AppAssets.profilePhotosMale[2],
        ),
        PortfolioTeamMember(
          name: 'Pınar C.',
          role: 'SES TASARIM',
          avatarUrl: AppAssets.profilePhotosFemale[1],
        ),
      ],
      processStages: const [
        PortfolioProcessStage(label: 'Brief & Analiz', done: true),
        PortfolioProcessStage(label: 'Pre-Prodüksiyon', done: true),
        PortfolioProcessStage(label: 'Prodüksiyon', done: true),
        PortfolioProcessStage(label: 'Post-Prodüksiyon'),
        PortfolioProcessStage(label: 'Teslim'),
      ],
    ),
  ];

  static final List<UserModel> users = [
    UserModel(
      id: 'u1',
      name: 'Aylin Demir',
      email: 'aylin@set.app',
      role: UserRole.freelancer,
      gender: 'kadin',
      avatarUrl: AppAssets.profilePhotosFemale[0],
      createdAt: DateTime(2025, 6, 12),
    ),
    UserModel(
      id: 'u2',
      name: 'Mert Kaya',
      email: 'mert@set.app',
      role: UserRole.freelancer,
      gender: 'erkek',
      avatarUrl: AppAssets.profilePhotosMale[0],
      createdAt: DateTime(2025, 7, 1),
    ),
    UserModel(
      id: 'u3',
      name: 'Selin Acar',
      email: 'selin@set.app',
      role: UserRole.freelancer,
      gender: 'kadin',
      avatarUrl: AppAssets.profilePhotosFemale[1],
      createdAt: DateTime(2025, 8, 4),
    ),
    UserModel(
      id: 'u4',
      name: 'Burak Yılmaz',
      email: 'burak@set.app',
      role: UserRole.freelancer,
      gender: 'erkek',
      avatarUrl: AppAssets.profilePhotosMale[1],
      createdAt: DateTime(2025, 9, 18),
    ),
    UserModel(
      id: 'u5',
      name: 'Eda Şen',
      email: 'eda@set.app',
      role: UserRole.freelancer,
      gender: 'kadin',
      avatarUrl: AppAssets.profilePhotosFemale[2],
      createdAt: DateTime(2025, 10, 22),
    ),
    UserModel(
      id: 'u6',
      name: 'Can Aksoy',
      email: 'can@set.app',
      role: UserRole.freelancer,
      gender: 'erkek',
      avatarUrl: AppAssets.profilePhotosMale[2],
      createdAt: DateTime(2025, 11, 5),
    ),
    UserModel(
      id: 'u7',
      name: 'Kaan Özdemir',
      email: 'kaan@set.app',
      role: UserRole.freelancer,
      gender: 'erkek',
      avatarUrl: AppAssets.profilePhotosMale[3],
      createdAt: DateTime(2025, 11, 10),
    ),
    UserModel(
      id: 'u8',
      name: 'Zeynep Arslan',
      email: 'zeynep@set.app',
      role: UserRole.freelancer,
      gender: 'kadin',
      avatarUrl: AppAssets.profilePhotosFemale[3],
      createdAt: DateTime(2025, 11, 15),
    ),
    UserModel(
      id: 'u9',
      name: 'Emre Koç',
      email: 'emre@set.app',
      role: UserRole.freelancer,
      gender: 'erkek',
      avatarUrl: AppAssets.profilePhotosMale[0],
      createdAt: DateTime(2025, 11, 20),
    ),
    UserModel(
      id: 'u10',
      name: 'Deniz Şahin',
      email: 'deniz@set.app',
      role: UserRole.freelancer,
      gender: 'kadin',
      avatarUrl: AppAssets.profilePhotosFemale[0],
      createdAt: DateTime(2025, 12, 1),
    ),
  ];

  static final List<FreelancerModel> freelancers = [
    FreelancerModel(
      userId: 'u1',
      categories: const ['Video Çekim'],
      bio: 'Reklam ve müzik videosu odaklı, set'
          ' deneyimi yüksek videograf.',
      experience: 7,
      location: 'İstanbul',
      rating: 4.9,
      portfolio: const [],
      profileImageUrl: AppAssets.profilePhotosFemale[0],
    ),
    FreelancerModel(
      userId: 'u2',
      categories: const ['Ses Tasarımı'],
      bio: 'Reklam, dizi ve kısa film için ses tasarımı ve mix.',
      experience: 5,
      location: 'Ankara',
      rating: 4.7,
      portfolio: const [],
      profileImageUrl: AppAssets.profilePhotosMale[0],
    ),
    FreelancerModel(
      userId: 'u3',
      categories: const ['Kurgu'],
      bio: 'Sosyal medya ve reklam kurguları, hızlı teslim.',
      experience: 4,
      location: 'İzmir',
      rating: 4.8,
      portfolio: const [],
      profileImageUrl: AppAssets.profilePhotosFemale[1],
    ),
    FreelancerModel(
      userId: 'u4',
      categories: const ['CGI & VFX'],
      bio: 'CGI ürün görselleri ve AI tabanlı VFX iş akışları.',
      experience: 6,
      location: 'İstanbul',
      rating: 4.6,
      portfolio: const [],
      profileImageUrl: AppAssets.profilePhotosMale[1],
    ),
    FreelancerModel(
      userId: 'u5',
      categories: const ['Video Çekim'],
      bio: 'Lisanslı drone pilotu — sinematik hava çekimleri.',
      experience: 3,
      location: 'Antalya',
      rating: 4.85,
      portfolio: const [],
      profileImageUrl: AppAssets.profilePhotosFemale[2],
    ),
    FreelancerModel(
      userId: 'u6',
      categories: const ['Fotoğraf'],
      bio: 'Marka kampanyaları ve editorial fotoğraf.',
      experience: 8,
      location: 'İstanbul',
      rating: 4.95,
      portfolio: const [],
      profileImageUrl: AppAssets.profilePhotosMale[2],
    ),
    FreelancerModel(
      userId: 'u7',
      categories: const ['Video Çekim'],
      bio: 'Kurumsal ve ürün videolarında uzman, 4K cinema kamera deneyimi.',
      experience: 5,
      location: 'İstanbul',
      rating: 4.8,
      portfolio: const [],
      profileImageUrl: AppAssets.profilePhotosMale[3],
    ),
    FreelancerModel(
      userId: 'u8',
      categories: const ['Video Çekim'],
      bio: 'Belgesel ve marka hikayeciliği odaklı yönetmen ve kameraman.',
      experience: 9,
      location: 'İstanbul',
      rating: 4.95,
      portfolio: const [],
      profileImageUrl: AppAssets.profilePhotosFemale[3],
    ),
    FreelancerModel(
      userId: 'u9',
      categories: const ['Video Çekim'],
      bio: 'Sosyal medya içerikleri ve kısa format video üretimi.',
      experience: 3,
      location: 'İzmir',
      rating: 4.7,
      portfolio: const [],
      profileImageUrl: AppAssets.profilePhotosMale[0],
    ),
    FreelancerModel(
      userId: 'u10',
      categories: const ['Kurgu'],
      bio: 'Film ve reklam kurguları, renk düzeltme ve motion grafik.',
      experience: 6,
      location: 'İstanbul',
      rating: 4.85,
      portfolio: const [],
      profileImageUrl: AppAssets.profilePhotosFemale[0],
    ),
  ];

  // ── Gösterimlik kreatifler ───────────────────────────────────────────
  // "Ekibini sen kur" listesi tek tük kayıtla boş görünmesin diye eklenen
  // demo kartlar. Firestore'da karşılıkları yok; hangi kategoriye
  // bakılıyorsa o kategoriyle üretilirler.
  static const List<({String id, String name, String surname, String gender,
      int experience, double rating, String location, String bio})>
      _demoProfiles = [
    (
      id: 'demo-f1',
      name: 'Zeynep',
      surname: 'Aksoy',
      gender: 'kadin',
      experience: 11,
      rating: 4.9,
      location: 'İstanbul',
      bio: 'Marka filmleri ve kampanya işlerinde 10+ yıl saha deneyimi.',
    ),
    (
      id: 'demo-f2',
      name: 'Barış',
      surname: 'Demir',
      gender: 'erkek',
      experience: 6,
      rating: 4.7,
      location: 'İzmir',
      bio: 'Kısa format içerik ve sosyal medya kampanyalarında hızlı teslim.',
    ),
    (
      id: 'demo-f3',
      name: 'Elif',
      surname: 'Yurdakul',
      gender: 'kadin',
      experience: 8,
      rating: 4.8,
      location: 'Ankara',
      bio: 'Kurumsal işler ve belgesel anlatımı odaklı, ekip kurmayı sever.',
    ),
  ];

  static List<FreelancerModel> demoFreelancersFor(String category) => [
        for (final p in _demoProfiles)
          FreelancerModel(
            userId: p.id,
            name: p.name,
            surname: p.surname,
            categories: [category],
            bio: p.bio,
            experience: p.experience,
            location: p.location,
            rating: p.rating,
            portfolio: const [],
          ),
      ];

  static List<UserModel> get demoUsers => [
        for (final p in _demoProfiles)
          UserModel(
            id: p.id,
            name: p.name,
            surname: p.surname,
            email: '${p.id}@set.app',
            role: UserRole.freelancer,
            gender: p.gender,
            createdAt: DateTime(2026, 1, 1),
          ),
      ];
}
