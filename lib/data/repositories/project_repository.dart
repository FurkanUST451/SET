import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/offer_model.dart';
import '../models/project_model.dart';
import 'brief_repository.dart';

class ProjectRepository {
  ProjectRepository({BriefRepository? briefRepository})
      : _briefRepo = briefRepository ?? BriefRepository();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final BriefRepository _briefRepo;

  CollectionReference<Map<String, dynamic>> get _projects =>
      _db.collection('projects');

  Future<ProjectModel> createFromOffer(
    OfferModel offer, {
    required String clientId,
    required String freelancerId,
  }) async {
    final brief = offer.briefId.isNotEmpty
        ? await _briefRepo.fetchBrief(offer.briefId)
        : null;
    final ref = _projects.doc();
    final project = ProjectModel(
      id: ref.id,
      clientId: clientId,
      freelancerId: freelancerId,
      status: ProjectStatus.active,
      title: offer.briefTitle,
      description: offer.message,
      budget: offer.amount,
      createdAt: DateTime.now(),
      offerId: offer.id,
      briefId: offer.briefId,
      chatId: offer.chatId,
      category: brief?.category,
      shootingType: brief?.answers.shootingType,
      vibes: brief?.answers.vibes,
      dateRange: brief?.answers.dateRange,
      deliveryTime: brief?.answers.deliveryTime,
      location: brief?.answers.location,
      notes: brief?.answers.notes,
    );
    await ref.set(project.toJson());
    return project;
  }

  Future<List<ProjectModel>> fetchByClient(String clientId) async {
    final snapshot =
        await _projects.where('clientId', isEqualTo: clientId).get();
    final list =
        snapshot.docs.map((d) => ProjectModel.fromJson(d.data())).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<ProjectModel>> fetchByFreelancer(String freelancerId) async {
    final snapshot =
        await _projects.where('freelancerId', isEqualTo: freelancerId).get();
    final list =
        snapshot.docs.map((d) => ProjectModel.fromJson(d.data())).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // Freelancer'ın kabul edilmiş projelerini canlı akıtır (bkz.
  // freelancer_job_offers_controller.dart — teklif kabul edilir edilmez
  // "Kabul Edildi" kartına anında dönüşsün diye).
  Stream<List<ProjectModel>> watchByFreelancer(String freelancerId) {
    return _projects
        .where('freelancerId', isEqualTo: freelancerId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => ProjectModel.fromJson(d.data())).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }
}
