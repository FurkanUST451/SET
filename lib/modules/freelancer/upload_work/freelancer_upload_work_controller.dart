import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

import '../../../data/models/work_model.dart';
import '../../../data/repositories/work_repository.dart';
import '../../app/user_controller.dart';

class FreelancerUploadWorkController extends GetxController {
  FreelancerUploadWorkController({WorkRepository? repository})
      : _repo = repository ?? Get.find<WorkRepository>();

  final WorkRepository _repo;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final Rx<WorkType> selectedType = WorkType.video.obs;
  final Rxn<File> pickedFile = Rxn<File>();
  final RxBool pickedIsVideo = false.obs;
  final RxBool isSubmitting = false.obs;

  void selectType(WorkType type) => selectedType.value = type;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 88,
    );
    if (picked == null) return;
    pickedFile.value = File(picked.path);
    pickedIsVideo.value = false;
  }

  Future<void> pickVideo() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    pickedFile.value = File(picked.path);
    pickedIsVideo.value = true;
  }

  void clearMedia() {
    pickedFile.value = null;
    pickedIsVideo.value = false;
  }

  Future<bool> submit() async {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      Get.snackbar('Eksik bilgi', 'Proje ismini doldur',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    final file = pickedFile.value;
    if (file == null) {
      Get.snackbar('Eksik medya', 'Bir görsel ya da video seç',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    final user = Get.find<UserController>().currentUser;
    if (user == null) return false;
    final studio = user.fullName;

    isSubmitting.value = true;
    try {
      try {
        await FirebaseFunctions.instanceFor(region: 'europe-west1')
            .httpsCallable('checkVideoUploadLimit')
            .call();
      } on FirebaseFunctionsException catch (e) {
        Get.snackbar(
          'Yavaşla',
          e.message ?? 'Çok fazla yükleme yaptınız, biraz sonra tekrar dene.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final uploadFile = pickedIsVideo.value
          ? await _compressVideo(file)
          : file;

      final workId = FirebaseFirestore.instance.collection('works').doc().id;
      final ext = pickedIsVideo.value ? 'mp4' : 'jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('work_uploads')
          .child('${user.id}_$workId.$ext');
      await ref.putFile(uploadFile);
      final mediaUrl = await ref.getDownloadURL();

      final thumbnailUrl = pickedIsVideo.value
          ? await _uploadThumbnail(uploadFile, user.id, workId)
          : null;

      final work = WorkModel(
        id: workId,
        title: title,
        studio: studio,
        type: selectedType.value,
        freelancerId: user.id,
        description:
            descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
        isVideo: pickedIsVideo.value,
        createdAt: DateTime.now(),
      );
      await _repo.createWork(work);
      return true;
    } catch (_) {
      Get.snackbar('Hata', 'Yükleme başarısız oldu, tekrar dene',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      if (pickedIsVideo.value) {
        await VideoCompress.deleteAllCache();
      }
      isSubmitting.value = false;
    }
  }

  // Storage'a göndermeden önce videoyu 720p / makul bitrate'e sıkıştırır.
  // Sıkıştırma başarısız olursa (desteklenmeyen platform/codec vb.)
  // orijinal dosyayla devam edilir, yükleme akışı kesilmez.
  Future<File> _compressVideo(File file) async {
    try {
      final info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.Res1280x720Quality,
        deleteOrigin: false,
        includeAudio: true,
      );
      return info?.file ?? file;
    } catch (_) {
      return file;
    }
  }

  // Videodan bir kare çıkarıp Storage'a yükler; keşfet kartında video
  // oynatılmadan önceki önizleme olarak kullanılır. Başarısız olursa null
  // döner — video yüklemesi yine de tamamlanır, sadece önizleme "yok" görünür.
  Future<String?> _uploadThumbnail(
    File videoFile,
    String uid,
    String workId,
  ) async {
    try {
      final thumbFile = await VideoCompress.getFileThumbnail(
        videoFile.path,
        quality: 60,
      );
      final thumbRef = FirebaseStorage.instance
          .ref()
          .child('work_uploads')
          .child('${uid}_${workId}_thumb.jpg');
      await thumbRef.putFile(thumbFile);
      return await thumbRef.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
