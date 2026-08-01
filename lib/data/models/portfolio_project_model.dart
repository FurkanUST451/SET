import '../../core/utils/turkish_case.dart';

enum PortfolioStatus {
  completed,
  ongoing,
  planned;

  String get label {
    switch (this) {
      case PortfolioStatus.completed:
        return 'TAMAMLANDI';
      case PortfolioStatus.ongoing:
        return 'DEVAM EDİYOR';
      case PortfolioStatus.planned:
        return 'PLANLANDI';
    }
  }
}

class PortfolioTeamMember {
  const PortfolioTeamMember({
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  final String name;
  final String role;
  final String? avatarUrl;
}

class PortfolioProcessStage {
  const PortfolioProcessStage({
    required this.label,
    this.done = false,
  });

  final String label;
  final bool done;
}

class PortfolioProjectModel {
  const PortfolioProjectModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tagLabel,
    required this.year,
    required this.durationLabel,
    required this.status,
    required this.description,
    required this.category,
    required this.budgetRangeLabel,
    required this.location,
    this.isFeatured = false,
    this.coverImageUrl,
    this.galleryImageUrls = const [],
    this.team = const [],
    this.processStages = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final String tagLabel;
  final String year;
  final String durationLabel;
  final PortfolioStatus status;
  final String description;
  final String category;
  final String budgetRangeLabel;
  final String location;
  final bool isFeatured;
  final String? coverImageUrl;
  final List<String> galleryImageUrls;
  final List<PortfolioTeamMember> team;
  final List<PortfolioProcessStage> processStages;

  factory PortfolioProjectModel.placeholderFor({
    required String id,
    required String title,
    required String category,
  }) {
    return PortfolioProjectModel(
      id: id,
      title: title,
      subtitle: 'Detaylar yakında eklenecek.',
      tagLabel: category.toUpperCaseTr(),
      year: DateTime.now().year.toString(),
      durationLabel: '—',
      status: PortfolioStatus.completed,
      description: 'Bu proje için henüz detaylı bilgi girilmedi.',
      category: category,
      budgetRangeLabel: '—',
      location: '—',
      galleryImageUrls: const [],
      team: const [],
      processStages: const [
        PortfolioProcessStage(label: 'Brief & Analiz', done: true),
        PortfolioProcessStage(label: 'Pre-Prodüksiyon'),
        PortfolioProcessStage(label: 'Prodüksiyon'),
        PortfolioProcessStage(label: 'Post-Prodüksiyon'),
        PortfolioProcessStage(label: 'Teslim'),
      ],
    );
  }
}
