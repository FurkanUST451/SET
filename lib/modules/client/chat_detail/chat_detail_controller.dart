import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/brief_model.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/repositories/brief_repository.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/offer_repository.dart';
import '../../../modules/app/user_controller.dart';
import '../../../routes/app_routes.dart';

class ChatDetailController extends GetxController {
  final ChatRepository _chatRepo = Get.find<ChatRepository>();
  final OfferRepository _offerRepo = Get.find<OfferRepository>();
  final BriefRepository _briefRepo = Get.find<BriefRepository>();
  final UserController _userController = Get.find<UserController>();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController offerAmountController = TextEditingController();
  final TextEditingController offerNoteController = TextEditingController();

  late final String chatId;
  late final String chatName;
  late final String briefTitle;
  String _returnRoute = AppRoutes.clientHome;

  ChatModel? _chat;
  final Rxn<BriefModel> brief = Rxn<BriefModel>();

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isSending = false.obs;
  final RxBool isSendingOffer = false.obs;
  final RxMap<String, OfferModel> offers = <String, OfferModel>{}.obs;
  final Map<String, StreamSubscription<OfferModel?>> _offerSubs = {};
  StreamSubscription<List<MessageModel>>? _sub;

  String get myId => _userController.currentUser?.id ?? '';

  bool get hasAcceptedOffer =>
      offers.values.any((o) => o.status == OfferStatus.accepted);

  String? get _otherUserId {
    final chat = _chat;
    if (chat == null) return null;
    return myId == chat.clientId ? chat.freelancerId : chat.clientId;
  }

  void _subscribeMessages() {
    _sub?.cancel();
    _sub = _chatRepo.messagesStream(chatId).listen(
      (msgs) {
        messages.assignAll(msgs);
        for (final msg in msgs) {
          if (msg.type == 'offer' && msg.offerId != null) {
            _subscribeOffer(msg.offerId!);
          }
        }
      },
      onError: (Object e) {
        debugPrint('ChatDetail stream error: $e — retrying in 3s');
        Future.delayed(const Duration(seconds: 3), _subscribeMessages);
      },
      cancelOnError: true,
    );
  }

  void _subscribeOffer(String offerId) {
    if (_offerSubs.containsKey(offerId)) return;
    _offerSubs[offerId] = _offerRepo.offerStream(offerId).listen((offer) {
      if (offer != null) offers[offerId] = offer;
    });
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
      _chatRepo.fetchChat(chatId).then((chat) async {
        _chat = chat;
        if (chat != null && chat.briefId.isNotEmpty) {
          brief.value = await _briefRepo.fetchBrief(chat.briefId);
        }
      });
    }
  }

  void goBack() {
    // Normal durumda (ör. proje detayı, freelancer profili üzerinden açılmışsa)
    // geldiği ekrana dön. Sadece bildirim/derin bağlantı gibi yığında önceki
    // ekran yoksa ana sekmeye düş.
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back<void>();
      return;
    }
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

  Future<void> sendOffer() async {
    final amountText = offerAmountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0 || chatId.isEmpty) return;
    final receiverId = _otherUserId;
    if (receiverId == null) {
      Get.snackbar('Hata', 'Sohbet bilgisi yüklenemedi, tekrar deneyin.',
          backgroundColor: const Color(0xFFD32F2F), colorText: Colors.white);
      return;
    }

    isSendingOffer.value = true;
    try {
      await _offerRepo.sendOffer(
        chatId: chatId,
        briefId: _chat?.briefId ?? '',
        briefTitle: briefTitle,
        senderId: myId,
        receiverId: receiverId,
        amount: amount,
        message: offerNoteController.text.trim(),
      );
      offerAmountController.clear();
      offerNoteController.clear();
      Get.back(); // close bottom sheet
    } catch (_) {
      Get.snackbar('Hata', 'Teklif gönderilemedi.',
          backgroundColor: const Color(0xFFD32F2F), colorText: Colors.white);
    } finally {
      isSendingOffer.value = false;
    }
  }

  Future<void> respondToOffer(OfferModel offer, bool accept) async {
    final chat = _chat;
    if (chat == null) return;

    try {
      await _offerRepo.respondToOffer(
        offerId: offer.id,
        accept: accept,
        clientId: chat.clientId,
        freelancerId: chat.freelancerId,
      );
      if (accept) {
        Get.snackbar('Anlaştınız!', 'Proje aktif projelerinize eklendi.',
            backgroundColor: const Color(0xFF2E7D32), colorText: Colors.white);
      }
    } catch (_) {
      Get.snackbar('Hata', 'Teklif güncellenemedi.',
          backgroundColor: const Color(0xFFD32F2F), colorText: Colors.white);
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
    for (final sub in _offerSubs.values) {
      sub.cancel();
    }
    messageController.dispose();
    offerAmountController.dispose();
    offerNoteController.dispose();
    super.onClose();
  }
}
