class ChatModel {
  const ChatModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.freelancerId,
    required this.freelancerName,
    required this.briefId,
    required this.briefTitle,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String freelancerId;
  final String freelancerName;
  final String briefId;
  final String briefTitle;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
        'freelancerId': freelancerId,
        'freelancerName': freelancerName,
        'briefId': briefId,
        'briefTitle': briefTitle,
        'createdAt': createdAt.toIso8601String(),
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt?.toIso8601String(),
      };

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        id: json['id'] as String,
        clientId: json['clientId'] as String,
        clientName: json['clientName'] as String? ?? '',
        freelancerId: json['freelancerId'] as String,
        freelancerName: json['freelancerName'] as String? ?? '',
        briefId: json['briefId'] as String,
        briefTitle: json['briefTitle'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastMessage: json['lastMessage'] as String?,
        lastMessageAt: json['lastMessageAt'] != null
            ? DateTime.parse(json['lastMessageAt'] as String)
            : null,
      );

  String otherUserName(String myId) =>
      myId == clientId ? freelancerName : clientName;
}
