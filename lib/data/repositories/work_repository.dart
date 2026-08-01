import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment_model.dart';
import '../models/work_model.dart';

class WorkRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _works =>
      _db.collection('works');

  CollectionReference<Map<String, dynamic>> _likes(String workId) =>
      _works.doc(workId).collection('likes');

  CollectionReference<Map<String, dynamic>> _comments(String workId) =>
      _works.doc(workId).collection('comments');

  Future<void> createWork(WorkModel work) => _works.doc(work.id).set(work.toJson());

  Future<void> deleteWork(String workId) => _works.doc(workId).delete();

  Stream<List<WorkModel>> watchAll() {
    return _works.snapshots().map((snapshot) {
      final list =
          snapshot.docs.map((d) => WorkModel.fromJson(d.data())).toList();
      list.sort((a, b) {
        final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  // ---- Beğeniler ----
  // Doküman id'si = kullanıcının uid'i, böylece "bir kullanıcı bir postu
  // yalnızca bir kez beğenebilir" kısıtı doküman varlığıyla garanti edilir
  // (bkz. firestore.rules). Sayaç (works.likes) client'tan değil, bu alt
  // koleksiyondaki create/delete'i dinleyen Cloud Function tarafından
  // güncellenir (bkz. functions/index.js).

  Stream<bool> watchIsLiked(String workId, String uid) {
    if (uid.isEmpty) return Stream.value(false);
    return _likes(workId).doc(uid).snapshots().map((doc) => doc.exists);
  }

  Future<void> like(String workId, String uid) => _likes(workId).doc(uid).set({
        'userId': uid,
        'createdAt': DateTime.now().toIso8601String(),
      });

  Future<void> unlike(String workId, String uid) =>
      _likes(workId).doc(uid).delete();

  // ---- Yorumlar ----

  Future<void> addComment({
    required String workId,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required String text,
  }) {
    final ref = _comments(workId).doc();
    final comment = CommentModel(
      id: ref.id,
      workId: workId,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      text: text,
      createdAt: DateTime.now(),
    );
    return ref.set(comment.toJson());
  }

  Stream<List<CommentModel>> watchComments(String workId) {
    return _comments(workId).snapshots().map((snapshot) {
      final list =
          snapshot.docs.map((d) => CommentModel.fromJson(d.data())).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  Future<void> deleteComment(String workId, String commentId) =>
      _comments(workId).doc(commentId).delete();
}
