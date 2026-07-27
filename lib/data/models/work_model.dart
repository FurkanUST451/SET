enum WorkType {
  video,
  photo,
  cgiVfx,
  graphic,
  sound;

  String get label {
    switch (this) {
      case WorkType.video:
        return 'Video';
      case WorkType.photo:
        return 'Foto';
      case WorkType.cgiVfx:
        return 'CGI&VFX';
      case WorkType.graphic:
        return 'Grafik';
      case WorkType.sound:
        return 'Ses';
    }
  }

  static WorkType fromName(String? value) {
    return WorkType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => WorkType.video,
    );
  }
}

class WorkModel {
  const WorkModel({
    required this.id,
    required this.title,
    required this.studio,
    required this.type,
    this.likes = 0,
    this.comments = 0,
    this.coverImage,
    this.freelancerId,
    this.description,
    this.mediaUrl,
    this.thumbnailUrl,
    this.isVideo = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String studio;
  final WorkType type;
  final int likes;
  final int comments;
  final String? coverImage;

  // Gerçek (Firestore'a yüklenmiş) işler için ek alanlar
  final String? freelancerId;
  final String? description;
  final String? mediaUrl;

  // Video işleri için upload sırasında üretilen JPEG önizleme (bkz.
  // freelancer_upload_work_controller.dart _uploadThumbnail).
  final String? thumbnailUrl;
  final bool isVideo;
  final DateTime? createdAt;

  // Firestore'a yüklenmiş gerçek işler için true; DummyData.works içindeki
  // tanıtım amaçlı statik kartlar için false (bkz. dummy_data.dart —
  // createdAt hiç set edilmez). Like/yorum gibi backend'e yazan aksiyonlar,
  // arkasında gerçek bir Firestore dokümanı olmayan dummy kartlarda açılmaz.
  bool get isLive => createdAt != null;

  factory WorkModel.fromJson(Map<String, dynamic> json) {
    return WorkModel(
      id: json['id'] as String,
      title: json['title'] as String,
      studio: json['studio'] as String,
      type: WorkType.fromName(json['type'] as String?),
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      coverImage: json['coverImage'] as String?,
      freelancerId: json['freelancerId'] as String?,
      description: json['description'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isVideo: json['isVideo'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'studio': studio,
        'type': type.name,
        'likes': likes,
        'comments': comments,
        'coverImage': coverImage,
        'freelancerId': freelancerId,
        'description': description,
        'mediaUrl': mediaUrl,
        'thumbnailUrl': thumbnailUrl,
        'isVideo': isVideo,
        'createdAt': createdAt?.toIso8601String(),
      };
}
