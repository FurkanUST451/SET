import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/progress_entry_model.dart';

class ProgressRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _progress(String projectId) =>
      _db.collection('projects').doc(projectId).collection('progress');

  // Müşteri ve freelancer tarafı aynı akışı dinler; freelancer yeni bir
  // ilerleme girdiği anda müşterinin ekranı otomatik güncellensin diye.
  Stream<List<ProgressEntryModel>> watchByProject(String projectId) {
    return _progress(projectId).orderBy('createdAt').snapshots().map(
          (snapshot) => snapshot.docs
              .map((d) => ProgressEntryModel.fromJson(d.data()))
              .toList(),
        );
  }

  Future<ProgressEntryModel> addEntry({
    required String projectId,
    required String freelancerId,
    required String title,
    required String description,
  }) async {
    final ref = _progress(projectId).doc();
    final entry = ProgressEntryModel(
      id: ref.id,
      projectId: projectId,
      freelancerId: freelancerId,
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    await ref.set(entry.toJson());
    return entry;
  }

  Future<void> updateEntry(ProgressEntryModel entry) async {
    await _progress(entry.projectId).doc(entry.id).update({
      'title': entry.title,
      'description': entry.description,
    });
  }

  Future<void> deleteEntry(String projectId, String entryId) async {
    await _progress(projectId).doc(entryId).delete();
  }
}
