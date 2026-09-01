import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../data/models/work_model.dart';
import 'freelancer_upload_work_controller.dart';
import '../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kDivider = Color(0x12000000);

TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
}) =>
    AppFonts.display(
        fontSize: size, fontWeight: weight, color: color, height: height);

TextStyle _ui({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
}) =>
    AppFonts.ui(
        fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing);

class FreelancerUploadWorkView extends GetView<FreelancerUploadWorkController> {
  const FreelancerUploadWorkView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();

    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: _kCream,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(s),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(26 * s, 20 * s, 26 * s, 24 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel(s, 'KATEGORİ'),
                      SizedBox(height: 12 * s),
                      _CategoryChips(scale: s),
                      SizedBox(height: 26 * s),
                      _sectionLabel(s, 'GÖRSEL / VİDEO'),
                      SizedBox(height: 12 * s),
                      _MediaPicker(scale: s),
                      SizedBox(height: 26 * s),
                      _sectionLabel(s, 'PROJE İSMİ'),
                      SizedBox(height: 10 * s),
                      _TextInput(
                        scale: s,
                        controller: controller.titleController,
                        hint: 'ör. "Mercedes-Benz The Chase"',
                      ),
                      SizedBox(height: 20 * s),
                      _sectionLabel(s, 'AÇIKLAMA'),
                      SizedBox(height: 10 * s),
                      _TextInput(
                        scale: s,
                        controller: controller.descriptionController,
                        hint: 'İş hakkında kısa bir açıklama (opsiyonel)',
                        maxLines: 4,
                      ),
                      SizedBox(height: 30 * s),
                      _SubmitButton(scale: s),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(double s, String text) => Text(
        text,
        style: _ui(size: 10 * s, weight: FontWeight.w700, color: _kMuted, spacing: 1.6),
      );

  Widget _buildTopBar(double s) {
    return Container(
      decoration: const BoxDecoration(
        color: _kCream,
        border: Border(bottom: BorderSide(color: _kDivider)),
      ),
      child: SizedBox(
        height: 56 * s,
        child: Row(
          children: [
            SizedBox(width: 6 * s),
            GestureDetector(
              onTap: Get.back,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(10 * s),
                child: Icon(Icons.arrow_back_rounded, size: 20 * s, color: _kInk),
              ),
            ),
            SizedBox(width: 4 * s),
            Text('Proje Yükle',
                style: _display(size: 24 * s, weight: FontWeight.w600, color: _kInk)),
          ],
        ),
      ),
    );
  }
}

// ─── Kategori seçim çipleri ────────────────────────────────────────────────
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final controller = Get.find<FreelancerUploadWorkController>();
    return Obx(() => Wrap(
          spacing: 10 * s,
          runSpacing: 10 * s,
          children: WorkType.values.map((t) {
            final selected = controller.selectedType.value == t;
            return GestureDetector(
              onTap: () => controller.selectType(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
                decoration: BoxDecoration(
                  color: selected ? _kInk : Colors.white,
                  border: Border.all(color: selected ? _kInk : Colors.black.withValues(alpha: 0.12)),
                ),
                child: Text(
                  t.label.toUpperCaseTr(),
                  style: _ui(
                    size: 11 * s,
                    weight: FontWeight.w700,
                    color: selected ? _kGold : _kTaupe,
                    spacing: 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }
}

// ─── Görsel / video seçici ─────────────────────────────────────────────────
class _MediaPicker extends StatelessWidget {
  const _MediaPicker({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final controller = Get.find<FreelancerUploadWorkController>();
    return Obx(() {
      final file = controller.pickedFile.value;
      final isVideo = controller.pickedIsVideo.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10 * s),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141219),
                  border: Border.all(color: _kGold.withValues(alpha: 0.3)),
                ),
                child: file == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 30 * s, color: Colors.white.withValues(alpha: 0.3)),
                            SizedBox(height: 8 * s),
                            Text('HENÜZ MEDYA SEÇİLMEDİ',
                                style: _ui(
                                    size: 10 * s,
                                    color: Colors.white.withValues(alpha: 0.3),
                                    spacing: 1.5)),
                          ],
                        ),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          if (!isVideo)
                            Image.file(file, fit: BoxFit.cover)
                          else
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.videocam_rounded,
                                      size: 30 * s, color: Colors.white.withValues(alpha: 0.85)),
                                  SizedBox(height: 8 * s),
                                  Text('VİDEO SEÇİLDİ',
                                      style: _ui(
                                          size: 10 * s,
                                          color: Colors.white.withValues(alpha: 0.85),
                                          spacing: 1.5)),
                                ],
                              ),
                            ),
                          Positioned(
                            top: 8 * s,
                            right: 8 * s,
                            child: GestureDetector(
                              onTap: controller.clearMedia,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 28 * s,
                                height: 28 * s,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close_rounded, size: 16 * s, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: 10 * s),
          Row(
            children: [
              Expanded(
                child: _MediaPickButton(
                  scale: s,
                  icon: Icons.image_outlined,
                  label: 'Görsel Seç',
                  onTap: controller.pickImage,
                ),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: _MediaPickButton(
                  scale: s,
                  icon: Icons.videocam_outlined,
                  label: 'Video Seç',
                  onTap: controller.pickVideo,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _MediaPickButton extends StatelessWidget {
  const _MediaPickButton({
    required this.scale,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final double scale;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 42 * s,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16 * s, color: _kInk),
            SizedBox(width: 8 * s),
            Text(label, style: _ui(size: 10 * s, weight: FontWeight.w700, color: _kInk, spacing: 0.4)),
          ],
        ),
      ),
    );
  }
}

// ─── Metin girişi ────────────────────────────────────────────────────────────
class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.scale,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });
  final double scale;
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: maxLines > 1 ? 12 * s : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      height: maxLines > 1 ? null : 46 * s,
      alignment: maxLines > 1 ? null : Alignment.centerLeft,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        cursorColor: _kGold,
        style: _ui(size: 10 * s, color: _kInk, spacing: 0.2),
        decoration: InputDecoration(
          isCollapsed: true,
          filled: false,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: _ui(size: 10 * s, color: _kMuted, spacing: 0.2),
        ),
      ),
    );
  }
}

// ─── Gönder butonu ─────────────────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final controller = Get.find<FreelancerUploadWorkController>();
    return Obx(() => GestureDetector(
          onTap: controller.isSubmitting.value
              ? null
              : () async {
                  final ok = await controller.submit();
                  if (ok) Get.back();
                },
          child: Container(
            height: 52 * s,
            width: double.infinity,
            color: _kGold,
            alignment: Alignment.center,
            child: controller.isSubmitting.value
                ? SizedBox(
                    width: 18 * s,
                    height: 18 * s,
                    child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Projeyi Yükle',
                    style: _ui(size: 10 * s, weight: FontWeight.w700, color: Colors.white, spacing: 0.8)),
          ),
        ));
  }
}
