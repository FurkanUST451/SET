import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/brief_model.dart';
import '../../../data/repositories/brief_repository.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';
import '../../app/user_controller.dart';

class FreelancerOfferDetailController extends GetxController {
  final BriefRepository _briefRepo = Get.find<BriefRepository>();
  final ChatRepository _chatRepo = Get.find<ChatRepository>();
  final UserRepository _userRepo = Get.find<UserRepository>();
  final UserController _userController = Get.find<UserController>();

  late final BriefModel brief;
  final RxBool isRejecting = false.obs;
  final RxBool isOpeningChat = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    brief = args['brief'] as BriefModel;
  }

  Future<void> openChat() async {
    if (isOpeningChat.value) return;
    isOpeningChat.value = true;
    try {
      final me = _userController.currentUser;
      if (me == null) return;

      // fetch client info
      final client = await _userRepo.fetchUser(brief.ownerId);
      final clientName = client?.fullName ?? 'Müşteri';
      final briefTitle =
          brief.title.isNotEmpty ? brief.title : brief.category;

      final chat = await _chatRepo.getOrCreateChat(
        clientId: brief.ownerId,
        clientName: clientName,
        freelancerId: me.id,
        freelancerName: me.fullName,
        briefId: brief.id,
        briefTitle: briefTitle,
      );

      Get.toNamed(
        AppRoutes.chatDetail,
        arguments: {
          'chatId': chat.id,
          'otherUserName': clientName,
          'briefTitle': briefTitle,
          'returnRoute': AppRoutes.freelancerHome,
        },
      );
    } catch (e, st) {
      debugPrint('openChat error: $e\n$st');
      Get.snackbar(
        'Hata',
        'Sohbet başlatılamadı: $e',
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
    } finally {
      isOpeningChat.value = false;
    }
  }

  Future<void> rejectOffer() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFFFEFDFB),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0x14000000)),
        ),
        title: Text(
          'Teklifi Reddet',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF35333F),
          ),
        ),
        content: Text(
          'Bu teklifi reddetmek istediğinize emin misiniz?',
          style: GoogleFonts.spaceMono(
            fontSize: 12,
            color: const Color(0xFF9B8E7B),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'VAZGEÇ',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF9B8E7B),
                letterSpacing: 1,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'REDDET',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFBE6A5A),
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isRejecting.value = true;
      final userId = _userController.currentUser?.id ?? '';
      if (userId.isEmpty) return;

      final updatedIds =
          brief.sentToIds.where((id) => id != userId).toList();
      await _briefRepo.removeSentToId(brief.id, userId, updatedIds);
      Get.back(result: 'rejected');
    } catch (_) {
      Get.snackbar(
        'Hata',
        'Teklif reddedilemedi. Lütfen tekrar deneyin.',
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
    } finally {
      isRejecting.value = false;
    }
  }
}
