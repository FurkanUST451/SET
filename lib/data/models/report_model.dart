/// Bildirilebilen içerik türleri. Yeni bir yer (ör. sohbet mesajları)
/// bildirme sistemine eklendiğinde buraya yeni bir sabit eklemek yeterli —
/// Firestore şeması (`reports` koleksiyonu) ve admin panel tarafı değişmez.
class ReportedContentType {
  ReportedContentType._();

  static const work = 'work';
  static const chatMessage = 'chat_message';
}

/// Tek bir bildirimi temsil eder. `reporter` ve `target`, bildirim anındaki
/// kullanıcı/içerik bilgilerinin anlık görüntüsüdür (denormalize) — böylece
/// içerik veya kullanıcı sonradan silinse/değişse bile admin panelinde
/// bildirim anındaki hâliyle görüntülenebilir.
class ReportModel {
  const ReportModel({
    required this.id,
    required this.type,
    required this.targetId,
    required this.reason,
    required this.reporter,
    required this.target,
    this.status = 'pending',
    required this.createdAt,
  });

  final String id;
  final String type; // bkz. ReportedContentType
  final String targetId;
  final String reason;
  final Map<String, dynamic> reporter;
  final Map<String, dynamic> target;
  final String status; // 'pending' | 'reviewed' | 'dismissed' — admin panel yönetir
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'targetId': targetId,
        'reason': reason,
        'status': status,
        'reporter': reporter,
        'target': target,
        'createdAt': createdAt.toIso8601String(),
      };
}
