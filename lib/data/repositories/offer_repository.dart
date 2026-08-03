import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/offer_model.dart';
import 'brief_repository.dart';
import 'chat_repository.dart';
import 'project_repository.dart';

class OfferRepository {
  OfferRepository({
    required ChatRepository chatRepository,
    required ProjectRepository projectRepository,
    required BriefRepository briefRepository,
  })  : _chatRepo = chatRepository,
        _projectRepo = projectRepository,
        _briefRepo = briefRepository;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ChatRepository _chatRepo;
  final ProjectRepository _projectRepo;
  final BriefRepository _briefRepo;

  CollectionReference<Map<String, dynamic>> get _offers =>
      _db.collection('offers');

  Future<OfferModel> sendOffer({
    required String chatId,
    required String briefId,
    required String briefTitle,
    required String senderId,
    required String receiverId,
    required double amount,
    String message = '',
  }) async {
    final ref = _offers.doc();
    final offer = OfferModel(
      id: ref.id,
      chatId: chatId,
      briefId: briefId,
      briefTitle: briefTitle,
      senderId: senderId,
      receiverId: receiverId,
      amount: amount,
      message: message,
      status: OfferStatus.pending,
      createdAt: DateTime.now(),
    );
    await ref.set(offer.toJson());
    await _chatRepo.sendMessage(
      chatId: chatId,
      senderId: senderId,
      content: 'Fiyat teklifi',
      type: 'offer',
      offerId: offer.id,
    );
    return offer;
  }

  Future<OfferModel?> fetchOffer(String offerId) async {
    final doc = await _offers.doc(offerId).get();
    final data = doc.data();
    if (data == null) return null;
    return OfferModel.fromJson(data);
  }

  Stream<OfferModel?> offerStream(String offerId) {
    return _offers.doc(offerId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return OfferModel.fromJson(data);
    });
  }

  Future<void> respondToOffer({
    required String offerId,
    required bool accept,
    required String clientId,
    required String freelancerId,
  }) async {
    final offer = await fetchOffer(offerId);
    if (offer == null || offer.status != OfferStatus.pending) return;

    await _offers.doc(offerId).update({
      'status': accept ? 'accepted' : 'rejected',
    });

    if (accept) {
      await _projectRepo.createFromOffer(
        offer.copyWith(status: OfferStatus.accepted),
        clientId: clientId,
        freelancerId: freelancerId,
      );
      if (offer.briefId.isNotEmpty) {
        await _briefRepo.updateStatus(offer.briefId, 'accepted');
      }
    }
  }
}
