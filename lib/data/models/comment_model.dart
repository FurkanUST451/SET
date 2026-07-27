class CommentModel {
  const CommentModel({
    required this.id,
    required this.workId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String workId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String text;
  final DateTime createdAt;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      workId: json['workId'] as String? ?? '',
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String? ?? 'SET Kullanıcısı',
      authorAvatar: json['authorAvatar'] as String?,
      text: json['text'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workId': workId,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };
}
