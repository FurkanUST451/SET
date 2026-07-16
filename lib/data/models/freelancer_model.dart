class PortfolioProject {
  const PortfolioProject({
    required this.title,
    required this.jobType,
    required this.description,
    this.videoUrl,
    this.thumbnailUrl,
  });

  final String title;
  final String jobType;
  final String description;
  final String? videoUrl;
  final String? thumbnailUrl;

  factory PortfolioProject.fromJson(Map<String, dynamic> json) =>
      PortfolioProject(
        title: json['title'] as String? ?? '',
        jobType: json['jobType'] as String? ?? '',
        description: json['description'] as String? ?? '',
        videoUrl: json['videoUrl'] as String?,
        thumbnailUrl: json['thumbnailUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'jobType': jobType,
        'description': description,
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
      };
}

class FreelancerModel {
  const FreelancerModel({
    required this.userId,
    this.name = '',
    this.surname,
    required this.categories,
    required this.bio,
    required this.experience,
    required this.location,
    required this.rating,
    this.birthDate,
    this.projects = const [],
    this.portfolio = const [],
    this.profileImageUrl,
  });

  final String userId;
  final String name;
  final String? surname;
  final List<String> categories;
  final String bio;
  final int experience;
  final String location;
  final double rating;
  final DateTime? birthDate;
  final List<PortfolioProject> projects;
  final List<String> portfolio;
  final String? profileImageUrl;

  String get fullName => (surname != null && surname!.isNotEmpty)
      ? '$name $surname'
      : name;

  factory FreelancerModel.fromJson(Map<String, dynamic> json) {
    return FreelancerModel(
      userId: json['userId'] as String,
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String?,
      categories: (json['categories'] as List?)?.cast<String>() ?? const [],
      bio: json['bio'] as String? ?? '',
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      location: json['location'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
      projects: (json['projects'] as List?)
              ?.map((e) =>
                  PortfolioProject.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      portfolio: (json['portfolio'] as List?)?.cast<String>() ?? const [],
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'surname': surname,
        'categories': categories,
        'bio': bio,
        'experience': experience,
        'location': location,
        'rating': rating,
        'birthDate': birthDate?.toIso8601String(),
        'projects': projects.map((p) => p.toJson()).toList(),
        'portfolio': portfolio,
        'profileImageUrl': profileImageUrl,
      };

  FreelancerModel copyWith({
    String? userId,
    String? name,
    String? surname,
    List<String>? categories,
    String? bio,
    int? experience,
    String? location,
    double? rating,
    DateTime? birthDate,
    List<PortfolioProject>? projects,
    List<String>? portfolio,
    String? profileImageUrl,
  }) {
    return FreelancerModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      categories: categories ?? this.categories,
      bio: bio ?? this.bio,
      experience: experience ?? this.experience,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      birthDate: birthDate ?? this.birthDate,
      projects: projects ?? this.projects,
      portfolio: portfolio ?? this.portfolio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
