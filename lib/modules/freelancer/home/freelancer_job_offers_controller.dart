import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../data/models/brief_model.dart';
import '../../../data/models/project_model.dart';
import '../../../data/repositories/brief_repository.dart';
import '../../../data/repositories/project_repository.dart';
import '../../app/user_controller.dart';

class FreelancerJobOffersController extends GetxController {
  final BriefRepository _briefRepo = Get.find<BriefRepository>();
  final ProjectRepository _projectRepo = Get.find<ProjectRepository>();
  final UserController _userController = Get.find<UserController>();

  String get freelancerId => _userController.currentUser?.id ?? '';

  final RxList<BriefModel> offers = <BriefModel>[].obs;
  // Bu freelancer için zaten aktif projeye dönüşmüş brief'ler (briefId -> proje) —
  // kart bu map'teyse sade "Kabul Edildi" kartı, anlaşılan ücretiyle gösterilir.
  final RxMap<String, ProjectModel> acceptedProjectsByBriefId =
      <String, ProjectModel>{}.obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<List<BriefModel>>? _offersSub;
  StreamSubscription<List<ProjectModel>>? _projectsSub;
  bool _offersLoaded = false;
  bool _projectsLoaded = false;

  @override
  void onInit() {
    super.onInit();
    _subscribe();
  }

  @override
  void onClose() {
    _offersSub?.cancel();
    _projectsSub?.cancel();
    super.onClose();
  }

  // Teklifler ve kabul edilmiş projeler canlı Firestore stream'i ile
  // akıyor — yeni bir teklif geldiğinde çıkış/giriş yapmaya gerek kalmadan
  // anında listede görünür.
  void _subscribe() {
    final freelancerId = _userController.currentUser?.id ?? '';
    if (freelancerId.isEmpty) {
      offers.clear();
      acceptedProjectsByBriefId.clear();
      isLoading.value = false;
      return;
    }

    _offersLoaded = false;
    _projectsLoaded = false;
    isLoading.value = true;

    _offersSub = _briefRepo.watchByFreelancer(freelancerId).listen((list) {
      offers.assignAll(list);
      _offersLoaded = true;
      _maybeStopLoading();
    });

    _projectsSub =
        _projectRepo.watchByFreelancer(freelancerId).listen((list) {
      acceptedProjectsByBriefId.assignAll({
        for (final p in list)
          if (p.briefId != null) p.briefId!: p,
      });
      _projectsLoaded = true;
      _maybeStopLoading();
    });
  }

  void _maybeStopLoading() {
    if (_offersLoaded && _projectsLoaded) {
      isLoading.value = false;
    }
  }

  // Pull-to-refresh: veri zaten canlı stream ile akıyor, bu yüzden yeni bir
  // şey "çekmiyoruz" — ama bağlantı bir şekilde takılıp kaldıysa stream'leri
  // yeniden abone ederek kurtarma imkânı sağlıyor.
  // (GetxController'ın kendi refresh() metoduyla çakışmasın diye reload
  // adını kullanıyoruz.)
  Future<void> reload() async {
    await _offersSub?.cancel();
    await _projectsSub?.cancel();
    _subscribe();
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  // Freelancer teklifi kendi listesinden kaldırır — sadece daha önce
  // değerlendirilmiş (reddedilmiş veya müşteri tarafından iptal edilmiş)
  // teklifler için çağrılır; view tarafında zaten bu şarta göre gösterilir.
  Future<void> deleteOffer(BriefModel brief) async {
    final id = freelancerId;
    if (id.isEmpty) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFFFEFDFB),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0x14000000)),
        ),
        title: Text(
          'Teklifi Sil',
          style: AppFonts.display(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF35333F),
          ),
        ),
        content: Text(
          'Bu teklifi listenden kaldırmak istediğine emin misin?',
          style: AppFonts.ui(
            fontSize: 12,
            color: const Color(0xFF000000),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'VAZGEÇ',
              style: AppFonts.ui(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF000000),
                letterSpacing: 1,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'SİL',
              style: AppFonts.ui(
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
      await _briefRepo.removeFreelancerFromBrief(brief.id, id);
    } catch (_) {
      Get.snackbar(
        'Hata',
        'Teklif silinemedi. Lütfen tekrar deneyin.',
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
    }
  }
}
