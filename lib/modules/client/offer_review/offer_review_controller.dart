import 'package:get/get.dart';

import '../../../data/models/brief_model.dart';
import '../../../data/models/offer_model.dart';

class OfferReviewController extends GetxController {
  late final OfferModel offer;
  late final BriefModel? brief;
  late final Future<void> Function() _onAccept;
  late final Future<void> Function() _onReject;

  final RxBool isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    offer = args['offer'] as OfferModel;
    brief = args['brief'] as BriefModel?;
    _onAccept = args['onAccept'] as Future<void> Function();
    _onReject = args['onReject'] as Future<void> Function();
  }

  Future<void> accept() async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      await _onAccept();
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> reject() async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      await _onReject();
    } finally {
      isProcessing.value = false;
    }
  }
}
