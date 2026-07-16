import 'package:get/get.dart';

import '../../../data/models/freelancer_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/brief_repository.dart';
import '../../../data/repositories/freelancer_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

class FreelancersByCategoryController extends GetxController {
  final FreelancerRepository _freelancerRepo;
  final UserRepository _userRepo;
  final BriefRepository _briefRepo = Get.find<BriefRepository>();

  FreelancersByCategoryController(this._freelancerRepo, this._userRepo);

  late final String category;
  late final String briefId;

  final RxList<FreelancerModel> freelancers = <FreelancerModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMsg = ''.obs;
  final RxList<String> selectedIds = <String>[].obs;
  final RxBool isSending = false.obs;
  static const int maxSelections = 5;

  final Map<String, UserModel> _userCache = {};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    category = (args?['category'] as String?) ?? '';
    briefId = (args?['briefId'] as String?) ?? '';
    _load();
  }

  Future<void> _load() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      final list = await _freelancerRepo.filterByCategory(category);
      for (final f in list) {
        try {
          final user = await _userRepo.fetchUser(f.userId);
          if (user != null) _userCache[f.userId] = user;
        } catch (_) {}
      }
      freelancers.assignAll(list);
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  UserModel userFor(FreelancerModel f) =>
      _userCache[f.userId] ??
      UserModel(
        id: f.userId,
        name: 'Bilinmiyor',
        email: '',
        role: UserRole.freelancer,
        createdAt: DateTime.now(),
      );

  bool isSelected(FreelancerModel f) => selectedIds.contains(f.userId);

  void toggleSelect(FreelancerModel f) {
    if (isSelected(f)) {
      selectedIds.remove(f.userId);
    } else if (selectedIds.length < maxSelections) {
      selectedIds.add(f.userId);
    }
  }

  void openDetail(FreelancerModel f) {
    Get.toNamed(
      AppRoutes.freelancerDetail,
      arguments: {'freelancer': f, 'user': userFor(f)},
    );
  }

  Future<void> sendOffers() async {
    if (selectedIds.isEmpty || isSending.value) return;
    isSending.value = true;
    try {
      if (briefId.isNotEmpty) {
        await _briefRepo.updateSentToIds(briefId, selectedIds.toList());
      }
    } catch (_) {
      // proceed even if Firestore update fails
    } finally {
      isSending.value = false;
    }
    Get.offAllNamed(AppRoutes.clientHome, arguments: {'tab': 3});
  }
}
