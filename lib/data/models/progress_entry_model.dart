class ProgressEntryModel {
  const ProgressEntryModel({
    required this.id,
    required this.projectId,
    required this.freelancerId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String projectId;
  final String freelancerId;
  final String title;
  final String description;
  final DateTime createdAt;

  factory ProgressEntryModel.fromJson(Map<String, dynamic> json) {
    return ProgressEntryModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      freelancerId: json['freelancerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'freelancerId': freelancerId,
        'title': title,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
      };

  ProgressEntryModel copyWith({String? title, String? description}) {
    return ProgressEntryModel(
      id: id,
      projectId: projectId,
      freelancerId: freelancerId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }
}
