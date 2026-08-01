import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/report_model.dart';

/// Genel amaçlı bildirme (report) repository'si. Herhangi bir içerik türü
/// (Keşfet gönderisi, ileride sohbet mesajı vb.) bu tek koleksiyon üzerinden
/// bildirilir — admin panel tarafı da tek bir `reports` koleksiyonunu izler.
class ReportRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _db.collection('reports');

  Future<void> submitReport({
    required String type,
    required String targetId,
    required String reason,
    required Map<String, dynamic> reporter,
    required Map<String, dynamic> target,
  }) {
    final ref = _reports.doc();
    final report = ReportModel(
      id: ref.id,
      type: type,
      targetId: targetId,
      reason: reason,
      reporter: reporter,
      target: target,
      createdAt: DateTime.now(),
    );
    return ref.set(report.toJson());
  }
}
