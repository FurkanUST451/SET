import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../data/models/chat_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../app/user_controller.dart';

class ClientChatsController extends GetxController {
  final ChatRepository _chatRepo = Get.find<ChatRepository>();
  final UserController _userController = Get.find<UserController>();

  final RxList<ChatModel> chats = <ChatModel>[].obs;
  StreamSubscription<List<ChatModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    ever(_userController.userObs, (_) => _subscribe());
    _subscribe();
  }

  void _subscribe() {
    _sub?.cancel();
    final user = _userController.currentUser;
    if (user == null || user.role != UserRole.client) {
      chats.clear();
      return;
    }
    final userId = user.id;

    _sub = _chatRepo.chatsForClient(userId).listen(
      (list) => chats.assignAll(list),
      onError: (Object e) {
        debugPrint('ClientChatsController stream error: $e — retrying in 3s');
        Future.delayed(const Duration(seconds: 3), _subscribe);
      },
      cancelOnError: true,
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
