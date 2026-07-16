import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/brief_model.dart';

class BriefRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _briefs =>
      _db.collection('briefs');

  Future<void> saveBrief(BriefModel brief) async {
    await _briefs.doc(brief.id).set(brief.toJson());
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

  Future<void> updateSentToIds(String briefId, List<String> ids) async {
    await _briefs.doc(briefId).update({
      'sentToIds': ids,
      'status': 'offer_sent',
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeSentToId(
      String briefId, String freelancerId, List<String> updatedIds) async {
    await _briefs.doc(briefId).update({
      'sentToIds': updatedIds,
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
