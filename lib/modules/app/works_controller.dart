import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/models/comment_model.dart';
import '../../data/models/report_model.dart';
import '../../data/models/work_model.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/repositories/work_repository.dart';
import 'user_controller.dart';

/// Keşfet akışını besleyen paylaşılan controller.
/// Firestore'a yüklenen gerçek işleri gösterir (en yeni yüklenen en
/// üstte görünür). Beğeni ve yorum aksiyonları da buradan yönetilir —
/// hem client hem freelancer tarafı aynı Keşfet ekranını paylaştığı
/// için tek bir yerden akar.
class WorksController extends GetxController {
  WorksController({WorkRepository? repository, ReportRepository? reportRepository})
      : _repo = repository ?? Get.find<WorkRepository>(),
        _reportRepo = reportRepository ?? Get.find<ReportRepository>();

  final WorkRepository _repo;
  final ReportRepository _reportRepo;
  final RxList<WorkModel> uploadedWorks = <WorkModel>[].obs;
  StreamSubscription<List<WorkModel>>? _sub;
  StreamSubscription<User?>? _authSub;

  List<WorkModel> get works => uploadedWorks;

  String get _uid => Get.find<UserController>().currentUser?.id ?? '';
  String get currentUserId => _uid;

  @override
  void onInit() {
    super.onInit();
    // Bu controller uygulama açılışında (InitialBinding) kuruluyor, yani
    // henüz kullanıcı giriş yapmamış olabilir. "works" okuması Firestore
    // kurallarında isSignedIn() şartına bağlı olduğu için giriş
    // tamamlanmadan kurulan abonelik permission-denied ile sessizce ölür
    // ve bir daha kendini yenilemez (Keşfet ilk açılışta boş görünür).
    // Auth durumunu dinleyip kullanıcı giriş yaptığında aboneliği
    // yeniden kuruyoruz.
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _sub?.cancel();
      if (user == null) {
        uploadedWorks.clear();
        return;
      }
      _sub = _repo.watchAll().listen((list) => uploadedWorks.assignAll(list));
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }

  // Pull-to-refresh: veri zaten canlı stream ile akıyor, bu yüzden yeni bir
  // şey "çekmiyoruz" — ama bağlantı bir şekilde takılıp kaldıysa stream'i
  // yeniden abone ederek kurtarma imkânı sağlıyor.
  // (GetxController'ın kendi refresh() metoduyla çakışmasın diye reload
  // adını kullanıyoruz.)
  Future<void> reload() async {
    await _sub?.cancel();
    _sub = _repo.watchAll().listen((list) => uploadedWorks.assignAll(list));
    await Future<void>.delayed(const Duration(milliseconds: 400));
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

  // ---- Gönderi sahibi aksiyonları / şikayet ----

  Future<bool> deleteWork(String workId) async {
    try {
      await _repo.deleteWork(workId);
      return true;
    } catch (_) {
      Get.snackbar('Hata', 'Gönderi silinemedi, tekrar dene.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> reportWork(WorkModel work, {required String reason}) async {
    final trimmed = reason.trim();
    if (trimmed.isEmpty) return false;
    final user = Get.find<UserController>().currentUser;
    if (user == null) return false;

    try {
      await _reportRepo.submitReport(
        type: ReportedContentType.work,
        targetId: work.id,
        reason: trimmed,
        reporter: user.toReporterSnapshot(),
        target: work.toReportSnapshot(),
      );
      return true;
    } catch (_) {
      Get.snackbar('Hata', 'Bildirim gönderilemedi, tekrar dene.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
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
