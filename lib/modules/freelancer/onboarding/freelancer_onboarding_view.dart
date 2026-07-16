import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/freelancer_model.dart';
import 'freelancer_onboarding_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kDivider = Color(0x12000000);
const _kCardBorder = Color(0x14000000);

double _scaleOf(BuildContext c) =>
    (MediaQuery.sizeOf(c).width / 390).clamp(0.85, 1.15).toDouble();

TextStyle _serif({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
}) =>
    GoogleFonts.cormorantGaramond(
        fontSize: size, fontWeight: weight, color: color, height: height);

TextStyle _mono({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
  double height = 1.4,
}) =>
    GoogleFonts.spaceMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height);

Widget _bottomSheetHandle(double s) => Container(
      margin: EdgeInsets.only(top: 10 * s, bottom: 4 * s),
      width: 40 * s,
      height: 4 * s,
      decoration: BoxDecoration(
        color: _kCardBorder,
        borderRadius: BorderRadius.circular(4),
      ),
    );

class FreelancerOnboardingView extends GetView<FreelancerOnboardingController> {
  const FreelancerOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return Scaffold(
      backgroundColor: _kCream,
      resizeToAvoidBottomInset: true,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12 * s, 8 * s, 20 * s, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back<void>(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8 * s),
                        child: Icon(Icons.arrow_back_rounded, size: 22 * s, color: _kInk),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Text(
                      'Freelancer Profili',
                      style: _serif(size: 20 * s, weight: FontWeight.w600, color: _kInk),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24 * s, 16 * s, 24 * s, 0),
                child: Obx(() => _StepIndicator(
                      total: FreelancerOnboardingController.totalSteps,
                      current: controller.currentStep.value,
                      scale: s,
                    )),
              ),
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    _PersonalInfoStep(),
                    _CategoryStep(),
                    _BioStep(),
                    _PortfolioStep(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24 * s, 8 * s, 24 * s, 20 * s),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator(color: _kGold));
                  }
                  return Row(
                    children: [
                      if (controller.currentStep.value > 0) ...[
                        Expanded(
                          child: _OutlineButton(label: 'Geri', onTap: controller.previous),
                        ),
                        SizedBox(width: 12 * s),
                      ],
                      Expanded(
                        child: _PrimaryButton(
                          label: controller.isLastStep ? 'Bitir' : 'Devam Et',
                          onTap: controller.next,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Butonlar ─────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 52 * s,
        color: _kGold,
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: _mono(size: 11 * s, weight: FontWeight.w700, color: Colors.white, spacing: 1.5),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 52 * s,
        decoration: BoxDecoration(border: Border.all(color: _kGold)),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: _mono(size: 11 * s, weight: FontWeight.w700, color: _kGold, spacing: 1.5),
        ),
      ),
    );
  }
}

// ─── Etiketli metin alanı ───────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: c, width: w),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label.toUpperCase(),
            style: _mono(size: 8 * s, weight: FontWeight.w700, color: _kMuted, spacing: 1.2),
          ),
          SizedBox(height: 7 * s),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          textInputAction: textInputAction,
          cursorColor: _kGold,
          style: _mono(size: 11 * s, color: _kInk, spacing: 0.2, height: 1.3),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: _mono(size: 11 * s, color: _kMuted, spacing: 0.2),
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
            border: border(Colors.black.withValues(alpha: 0.12)),
            enabledBorder: border(Colors.black.withValues(alpha: 0.12)),
            focusedBorder: border(_kGold, 1.4),
          ),
        ),
      ],
    );
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.total, required this.current, required this.scale});
  final int total;
  final int current;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: List.generate(total, (i) {
        final active = i <= current;
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 3 * s),
            height: 3 * s,
            color: active ? _kGold : _kCardBorder,
          ),
        );
      }),
    );
  }
}

// ─── Step 0: Personal Info ───────────────────────────────────────────────────

class _PersonalInfoStep extends StatelessWidget {
  const _PersonalInfoStep();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FreelancerOnboardingController>();
    final s = _scaleOf(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(24 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kişisel Bilgiler',
              style: _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk)),
          SizedBox(height: 20 * s),

          // Profil Fotoğrafı
          Center(
            child: Obx(() {
              final file = c.profileImageFile.value;
              return GestureDetector(
                onTap: c.pickProfileImage,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 96 * s,
                      height: 96 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.45),
                        border: Border.all(color: _kGold, width: 1.8),
                        image: file != null
                            ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: file == null
                          ? Icon(Icons.person_outline, size: 40 * s, color: _kTaupe)
                          : null,
                    ),
                    Positioned(
                      right: -2 * s,
                      bottom: -2 * s,
                      child: Container(
                        width: 30 * s,
                        height: 30 * s,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kGold,
                          border: Border.all(color: _kCream, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.edit, size: 14 * s, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 24 * s),

          // Ad + Soyad
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Ad',
                  controller: c.nameController,
                  hint: 'Adın',
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: _LabeledField(
                  label: 'Soyad',
                  controller: c.surnameController,
                  hint: 'Soyadın',
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * s),

          // Doğum Tarihi
          Obx(() => _LabeledField(
                label: 'Doğum Tarihi',
                controller: TextEditingController(text: c.formattedBirthDate),
                hint: 'GG.AA.YYYY',
                readOnly: true,
                suffixIcon: Icon(Icons.calendar_today_outlined, size: 16 * s, color: _kTaupe),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: c.birthDate.value ?? DateTime(1995, 1, 1),
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
                  );
                  if (picked != null) c.setBirthDate(picked);
                },
              )),
          SizedBox(height: 16 * s),

          // Şehir
          Obx(() => _LabeledField(
                label: 'Yaşadığı Şehir',
                controller: TextEditingController(text: c.selectedCity.value ?? ''),
                hint: 'Şehir seçin',
                readOnly: true,
                suffixIcon: Icon(Icons.keyboard_arrow_down, size: 18 * s, color: _kTaupe),
                onTap: () => _showCityPicker(context, c),
              )),
          SizedBox(height: 16 * s),

          // Deneyim Yılı
          Obx(() => _LabeledField(
                label: 'Deneyim Yılı',
                controller: TextEditingController(
                  text: c.selectedExperience.value == 0
                      ? '0 yıl'
                      : '${c.selectedExperience.value} yıl',
                ),
                hint: '0 yıl',
                readOnly: true,
                suffixIcon: Icon(Icons.keyboard_arrow_down, size: 18 * s, color: _kTaupe),
                onTap: () => _showExperiencePicker(context, c),
              )),
        ],
      ),
    );
  }

  void _showCityPicker(BuildContext context, FreelancerOnboardingController c) {
    final searchCtrl = TextEditingController();
    final filtered =
        ValueNotifier<List<String>>(FreelancerOnboardingController.turkishCities);
    final s = _scaleOf(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(color: _kCream),
        child: Column(
          children: [
            _bottomSheetHandle(s),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 8 * s),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Şehir Seçin',
                    style: _serif(size: 18 * s, weight: FontWeight.w600, color: _kInk)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * s),
              child: TextField(
                controller: searchCtrl,
                autofocus: true,
                cursorColor: _kGold,
                style: _mono(size: 11 * s, color: _kInk),
                decoration: InputDecoration(
                  hintText: 'Şehir ara...',
                  hintStyle: _mono(size: 11 * s, color: _kMuted),
                  prefixIcon: Icon(Icons.search, size: 18 * s, color: _kTaupe),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: const BorderSide(color: _kGold, width: 1.4),
                  ),
                ),
                onChanged: (val) {
                  filtered.value = FreelancerOnboardingController.turkishCities
                      .where((city) => city.toLowerCase().contains(val.toLowerCase()))
                      .toList();
                },
              ),
            ),
            SizedBox(height: 8 * s),
            Expanded(
              child: ValueListenableBuilder<List<String>>(
                valueListenable: filtered,
                builder: (_, cities, _) => ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20 * s),
                  itemCount: cities.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, thickness: 1, color: _kDivider),
                  itemBuilder: (_, i) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(cities[i],
                        style: _serif(size: 15 * s, weight: FontWeight.w500, color: _kInk)),
                    onTap: () {
                      c.selectedCity.value = cities[i];
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExperiencePicker(BuildContext context, FreelancerOnboardingController c) {
    int tempValue = c.selectedExperience.value;
    final s = _scaleOf(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: 300 * s,
        decoration: const BoxDecoration(color: _kCream),
        child: Column(
          children: [
            _bottomSheetHandle(s),
            SizedBox(height: 6 * s),
            Text('Deneyim Yılı',
                style: _serif(size: 18 * s, weight: FontWeight.w600, color: _kInk)),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 42 * s,
                scrollController:
                    FixedExtentScrollController(initialItem: c.selectedExperience.value),
                onSelectedItemChanged: (i) => tempValue = i,
                children: List.generate(
                  21,
                  (i) => Center(
                    child: Text(
                      i == 0 ? '0 yıl' : '$i yıl',
                      style: _mono(size: 13 * s, color: _kInk, spacing: 0.2),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16 * s),
              child: _PrimaryButton(
                label: 'Seç',
                onTap: () {
                  c.selectedExperience.value = tempValue;
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 1: Categories ───────────────────────────────────────────────────────

class _CategoryStep extends StatelessWidget {
  const _CategoryStep();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FreelancerOnboardingController>();
    final s = _scaleOf(context);
    return Padding(
      padding: EdgeInsets.all(24 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kategoriler', style: _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk)),
          SizedBox(height: 4 * s),
          Text('Birden fazla seçebilirsin',
              style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.2)),
          SizedBox(height: 20 * s),
          Expanded(
            child: SingleChildScrollView(
              child: Obx(() => Wrap(
                    spacing: 8 * s,
                    runSpacing: 8 * s,
                    children: c.categories.map((cat) {
                      final selected = c.selectedCategories.contains(cat);
                      return InkWell(
                        onTap: () => c.toggleCategory(cat),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 9 * s),
                          decoration: BoxDecoration(
                            color: selected ? _kGold.withValues(alpha: 0.14) : Colors.white,
                            border: Border.all(
                              color: selected ? _kGold : _kCardBorder,
                              width: selected ? 1.2 : 1,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: _mono(
                              size: 10 * s,
                              weight: selected ? FontWeight.w700 : FontWeight.w400,
                              color: selected ? _kGold : _kInk,
                              spacing: 0.3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Bio ─────────────────────────────────────────────────────────────

class _BioStep extends StatelessWidget {
  const _BioStep();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FreelancerOnboardingController>();
    final s = _scaleOf(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24 * s,
          right: 24 * s,
          top: 24 * s,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24 * s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kendini kısaca tanıt:',
                style: _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk)),
            SizedBox(height: 20 * s),
            _LabeledField(
              label: '',
              controller: c.bioController,
              hint: 'Neler yapıyorsun, hangi işlere odaklanıyorsun?',
              maxLines: 8,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 3: Portfolio ────────────────────────────────────────────────────────

class _PortfolioStep extends StatelessWidget {
  const _PortfolioStep();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FreelancerOnboardingController>();
    final s = _scaleOf(context);
    return Obx(() {
      final projects = c.addedProjects;
      return ListView(
        padding: EdgeInsets.all(24 * s),
        children: [
          Text('Bize projelerinden bahset',
              style: _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk)),
          SizedBox(height: 4 * s),
          Text(
            'Bize daha önce yaptığın projelerden bahseder misin?',
            style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.2),
          ),
          SizedBox(height: 4 * s),
          Text(
            '(Profil kısmından projelerini eklemeye devam edebilirsin)',
            style: _mono(size: 8 * s, color: _kMuted, spacing: 0.2),
          ),
          SizedBox(height: 20 * s),

          // Eklenen proje kartları
          ...projects.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 10 * s),
              child: _ProjectCard(
                project: p,
                scale: s,
                onDelete: () => c.removeProject(i),
              ),
            );
          }),

          // + Buton
          InkWell(
            onTap: () => _showAddProjectSheet(context, c),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16 * s),
              decoration: BoxDecoration(border: Border.all(color: _kCardBorder)),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 18 * s, color: _kGold),
                  SizedBox(width: 8 * s),
                  Text('Proje Ekle',
                      style: _mono(
                          size: 10 * s, weight: FontWeight.w600, color: _kGold, spacing: 0.4)),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  void _showAddProjectSheet(BuildContext context, FreelancerOnboardingController c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddProjectSheet(onAdd: c.addProject),
    );
  }
}

// ─── Proje Kartı ─────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.scale, required this.onDelete});
  final PortfolioProject project;
  final double scale;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (project.title.isNotEmpty)
                  Text(project.title,
                      style: _serif(size: 15 * s, weight: FontWeight.w600, color: _kInk)),
                if (project.jobType.isNotEmpty) ...[
                  SizedBox(height: 2 * s),
                  Text(project.jobType,
                      style: _mono(size: 8.5 * s, color: _kTaupe, spacing: 0.2)),
                ],
                if (project.description.isNotEmpty) ...[
                  SizedBox(height: 6 * s),
                  Text(
                    project.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _mono(size: 8.5 * s, color: _kMuted, spacing: 0.2),
                  ),
                ],
                if (project.videoUrl != null && project.videoUrl!.isNotEmpty) ...[
                  SizedBox(height: 6 * s),
                  Row(
                    children: [
                      Icon(Icons.play_circle_outline, size: 13 * s, color: _kGold),
                      SizedBox(width: 4 * s),
                      Expanded(
                        child: Text(
                          project.videoUrl!,
                          style: _mono(size: 8 * s, color: _kGold, spacing: 0.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.close, size: 16 * s, color: _kTaupe),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─── Proje Ekleme Modal ───────────────────────────────────────────────────────

class _AddProjectSheet extends StatefulWidget {
  const _AddProjectSheet({required this.onAdd});
  final void Function(PortfolioProject) onAdd;

  @override
  State<_AddProjectSheet> createState() => _AddProjectSheetState();
}

class _AddProjectSheetState extends State<_AddProjectSheet> {
  final _titleCtrl = TextEditingController();
  final _jobTypeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _videoUrlCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _jobTypeCtrl.dispose();
    _descCtrl.dispose();
    _videoUrlCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty && _jobTypeCtrl.text.trim().isEmpty) {
      return;
    }
    widget.onAdd(PortfolioProject(
      title: _titleCtrl.text.trim(),
      jobType: _jobTypeCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      videoUrl: _videoUrlCtrl.text.trim().isEmpty ? null : _videoUrlCtrl.text.trim(),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(color: _kCream),
      padding: EdgeInsets.fromLTRB(20 * s, 14 * s, 20 * s, bottom + 20 * s),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: _bottomSheetHandle(s)),
            SizedBox(height: 14 * s),
            Text('Proje Ekle', style: _serif(size: 20 * s, weight: FontWeight.w600, color: _kInk)),
            SizedBox(height: 16 * s),
            _LabeledField(label: 'Proje Başlığı', controller: _titleCtrl, hint: 'Migros'),
            SizedBox(height: 14 * s),
            _LabeledField(label: 'İş Tanımı', controller: _jobTypeCtrl, hint: 'Reklam filmi'),
            SizedBox(height: 14 * s),
            _LabeledField(
              label: 'Kısa Açıklama',
              controller: _descCtrl,
              hint: 'Projeni kısaca anlat...',
              maxLines: 4,
            ),
            SizedBox(height: 14 * s),
            _LabeledField(
              label: 'Video Linki',
              controller: _videoUrlCtrl,
              hint: 'YouTube, Vimeo veya doğrudan video URL\'i',
              suffixIcon: Icon(Icons.play_circle_outline, size: 18 * s, color: _kTaupe),
            ),
            SizedBox(height: 20 * s),
            _PrimaryButton(label: 'Ekle', onTap: _submit),
          ],
        ),
      ),
    );
  }
}
