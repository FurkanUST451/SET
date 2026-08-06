import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/brief_model.dart';

class BriefRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _briefs =>
      _db.collection('briefs');

  Future<void> saveBrief(BriefModel brief) async {
    await _briefs.doc(brief.id).set(brief.toJson());
  }

  Future<BriefModel?> fetchBrief(String briefId) async {
    final doc = await _briefs.doc(briefId).get();
    final data = doc.data();
    if (data == null) return null;
    return BriefModel.fromJson(data);
  }

  Future<List<BriefModel>> fetchByOwner(String ownerId) async {
    final snapshot = await _briefs
        .where('ownerId', isEqualTo: ownerId)
        .get();
    final list = snapshot.docs
        .map((d) => BriefModel.fromJson(d.data()))
        .toList();
    // Sort in Dart to avoid requiring a Firestore composite index
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<BriefModel>> fetchByFreelancer(String freelancerId) async {
    final snapshot = await _briefs
        .where('sentToIds', arrayContains: freelancerId)
        .get();
    final list = snapshot.docs
        .map((d) => BriefModel.fromJson(d.data()))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // Freelancer'a gönderilen teklifleri canlı akıtır — yeni bir teklif
  // geldiğinde ekranın yeniden giriş yapmaya gerek kalmadan güncellenmesi
  // için kullanılır (bkz. freelancer_job_offers_controller.dart).
  Stream<List<BriefModel>> watchByFreelancer(String freelancerId) {
    return _briefs
        .where('sentToIds', arrayContains: freelancerId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((d) => BriefModel.fromJson(d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> updateSentToIds(String briefId, List<String> ids) async {
    await _briefs.doc(briefId).update({
      'sentToIds': ids,
      'status': 'offer_sent',
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Freelancer teklifi reddeder — sentToIds'e dokunulmaz, sadece
  // rejectedByIds'e eklenir. Böylece brief o freelancer'ın kendi
  // listesinden kaybolmaz, "Reddedildi" kartı olarak görünmeye devam eder.
  Future<void> rejectByFreelancer(String briefId, String freelancerId) async {
    await _briefs.doc(briefId).update({
      'rejectedByIds': FieldValue.arrayUnion([freelancerId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Freelancer daha önce reddettiği bir teklifi "yeniden değerlendirip"
  // mesajlaşmayı seçerse reddedilmiş işaretini geri alır.
  Future<void> unrejectByFreelancer(
      String briefId, String freelancerId) async {
    await _briefs.doc(briefId).update({
      'rejectedByIds': FieldValue.arrayRemove([freelancerId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Freelancer teklifi kendi listesinden tamamen siler — sentToIds'den
  // çıkarılır, bir daha o freelancer'ın listesinde görünmez.
  Future<void> removeFreelancerFromBrief(
      String briefId, String freelancerId) async {
    await _briefs.doc(briefId).update({
      'sentToIds': FieldValue.arrayRemove([freelancerId]),
      'rejectedByIds': FieldValue.arrayRemove([freelancerId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateStatus(String briefId, String status) async {
    await _briefs.doc(briefId).update({
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> cancelBrief(String briefId, String reason) async {
    await _briefs.doc(briefId).update({
      'status': 'cancelled',
      'cancelReason': reason,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateNotes(String briefId, String notes) async {
    await _briefs.doc(briefId).update({
      'answers.notes': notes,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateBrief(BriefModel brief) async {
    await _briefs.doc(brief.id).update({
      'answers': brief.answers.toJson(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
