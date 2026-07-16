import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/message_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../modules/app/user_controller.dart';
import '../../../routes/app_routes.dart';

class ChatDetailController extends GetxController {
  final ChatRepository _chatRepo = Get.find<ChatRepository>();
  final UserController _userController = Get.find<UserController>();
  final TextEditingController messageController = TextEditingController();

  late final String chatId;
  late final String chatName;
  late final String briefTitle;
  String _returnRoute = AppRoutes.clientHome;

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isSending = false.obs;
  StreamSubscription<List<MessageModel>>? _sub;

  String get myId => _userController.currentUser?.id ?? '';

  void _subscribeMessages() {
    _sub?.cancel();
    _sub = _chatRepo.messagesStream(chatId).listen(
      (msgs) => messages.assignAll(msgs),
      onError: (Object e) {
        debugPrint('ChatDetail stream error: $e — retrying in 3s');
        Future.delayed(const Duration(seconds: 3), _subscribeMessages);
      },
      cancelOnError: true,
    );
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    chatId = args['chatId'] as String? ?? '';
    chatName = args['otherUserName'] as String? ?? 'Sohbet';
    briefTitle = args['briefTitle'] as String? ?? '';
    _returnRoute = args['returnRoute'] as String? ?? AppRoutes.clientHome;

    if (chatId.isNotEmpty) {
      _subscribeMessages();
    }
  }

  void goBack() {
    if (_returnRoute == AppRoutes.freelancerHome) {
      Get.offAllNamed(AppRoutes.freelancerHome, arguments: {'tab': 1});
    } else {
      Get.offAllNamed(AppRoutes.clientHome, arguments: {'tab': 1});
    }
  }

  Future<void> send() async {
    final text = messageController.text.trim();
    if (text.isEmpty || chatId.isEmpty) return;
    messageController.clear();
    isSending.value = true;
    try {
      await _chatRepo.sendMessage(
        chatId: chatId,
        senderId: myId,
        content: text,
      );
    } catch (_) {
      Get.snackbar('Hata', 'Mesaj gönderilemedi.',
          backgroundColor: const Color(0xFFD32F2F),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isSending.value = false;
    }
  }

  String formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$hour:$m $period';
  }

  @override
  void onClose() {
    _sub?.cancel();
    messageController.dispose();
    super.onClose();
  }
}
