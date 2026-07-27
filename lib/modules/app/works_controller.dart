import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';

import '../../data/dummy/dummy_data.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/work_model.dart';
import '../../data/repositories/work_repository.dart';
import 'user_controller.dart';

/// Keşfet akışını besleyen paylaşılan controller.
/// Firestore'a yüklenen gerçek işleri, tanıtım amaçlı dummy işlerin
/// üzerine ekler (en yeni yüklenen en üstte görünür). Beğeni ve yorum
/// aksiyonları da buradan yönetilir — hem client hem freelancer tarafı
/// aynı Keşfet ekranını paylaştığı için tek bir yerden akar.
class WorksController extends GetxController {
  WorksController({WorkRepository? repository})
      : _repo = repository ?? Get.find<WorkRepository>();

  final WorkRepository _repo;
  final RxList<WorkModel> uploadedWorks = <WorkModel>[].obs;
  StreamSubscription<List<WorkModel>>? _sub;

  List<WorkModel> get works => [...uploadedWorks, ...DummyData.works];

  String get _uid => Get.find<UserController>().currentUser?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    _sub = _repo.watchAll().listen((list) => uploadedWorks.assignAll(list));
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // ---- Beğeniler ----

  Stream<bool> isLikedStream(String workId) => _repo.watchIsLiked(workId, _uid);

  Future<void> toggleLike(String workId, bool isCurrentlyLiked) async {
    final uid = _uid;
    if (uid.isEmpty) return;

    if (!await _passesEngagementLimit()) return;

    try {
      if (isCurrentlyLiked) {
        await _repo.unlike(workId, uid);
      } else {
        await _repo.like(workId, uid);
      }
    } catch (_) {
      Get.snackbar('Hata', 'İşlem tamamlanamadı, tekrar dene.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ---- Yorumlar ----

  Stream<List<CommentModel>> commentsStream(String workId) =>
      _repo.watchComments(workId);

  Future<bool> postComment(String workId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final user = Get.find<UserController>().currentUser;
    if (user == null) return false;

    if (!await _passesEngagementLimit()) return false;

    try {
      await _repo.addComment(
        workId: workId,
        authorId: user.id,
        authorName: user.fullName,
        authorAvatar: user.avatarUrl,
        text: trimmed,
      );
      return true;
    } catch (_) {
      Get.snackbar('Hata', 'Yorum gönderilemedi, tekrar dene.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<void> deleteComment(String workId, String commentId) async {
    try {
      await _repo.deleteComment(workId, commentId);
    } catch (_) {
      Get.snackbar('Hata', 'Yorum silinemedi, tekrar dene.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Like/yorum atmadan hemen önce çağrılır — spam/bot korumalı ortak kota
  // (bkz. functions/index.js checkEngagementLimit). Reddedilirse ilgili
  // Firestore yazması hiç denenmez.
  Future<bool> _passesEngagementLimit() async {
    try {
      await FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('checkEngagementLimit')
          .call();
      return true;
    } on FirebaseFunctionsException catch (e) {
      Get.snackbar(
        'Yavaşla',
        e.message ?? 'Çok fazla istek gönderdiniz, biraz sonra tekrar dene.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar('Hata', 'Bağlantı sorunu, tekrar dene.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
