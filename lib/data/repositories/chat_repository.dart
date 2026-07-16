import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');

  CollectionReference<Map<String, dynamic>> _msgs(String chatId) =>
      _db.collection('chats').doc(chatId).collection('messages');

  // chatId is deterministic: briefId_freelancerId
  String chatId(String briefId, String freelancerId) =>
      '${briefId}_$freelancerId';

  Future<ChatModel> getOrCreateChat({
    required String clientId,
    required String clientName,
    required String freelancerId,
    required String freelancerName,
    required String briefId,
    required String briefTitle,
  }) async {
    final id = chatId(briefId, freelancerId);
    final chat = ChatModel(
      id: id,
      clientId: clientId,
      clientName: clientName,
      freelancerId: freelancerId,
      freelancerName: freelancerName,
      briefId: briefId,
      briefTitle: briefTitle,
      createdAt: DateTime.now(),
    );
    // merge: true → mevcut dokümanın lastMessage/lastMessageAt alanlarına dokunmaz
    await _chats.doc(id).set(
      {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
        'freelancerId': freelancerId,
        'freelancerName': freelancerName,
        'briefId': briefId,
        'briefTitle': briefTitle,
        'createdAt': chat.createdAt.toIso8601String(),
      },
      SetOptions(merge: true),
    );
    return chat;
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    final msgRef = _msgs(chatId).doc();
    final msg = MessageModel(
      id: msgRef.id,
      chatId: chatId,
      senderId: senderId,
      content: content,
      createdAt: DateTime.now(),
    );
    await Future.wait([
      msgRef.set(msg.toJson()),
      _chats.doc(chatId).update({
        'lastMessage': content,
        'lastMessageAt': msg.createdAt.toIso8601String(),
      }),
    ]);
  }

  Stream<List<MessageModel>> messagesStream(String chatId) {
    return _msgs(chatId).snapshots().map((s) {
      final list =
          s.docs.map((d) => MessageModel.fromJson(d.data())).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  Stream<List<ChatModel>> chatsForClient(String clientId) {
    return _chats
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((s) {
      final list =
          s.docs.map((d) => ChatModel.fromJson(d.data())).toList();
      list.sort((a, b) {
        final at = a.lastMessageAt;
        final bt = b.lastMessageAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
      return list;
    });
  }

  Stream<List<ChatModel>> chatsForFreelancer(String freelancerId) {
    return _chats
        .where('freelancerId', isEqualTo: freelancerId)
        .snapshots()
        .map((s) {
      final list =
          s.docs.map((d) => ChatModel.fromJson(d.data())).toList();
      list.sort((a, b) {
        final at = a.lastMessageAt;
        final bt = b.lastMessageAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
      return list;
    });
  }
}
