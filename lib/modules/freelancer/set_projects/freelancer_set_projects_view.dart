import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/utils/avatar_image.dart';
import '../../../routes/app_routes.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kCardBorder = Color(0x14000000);
const _kOnline = Color(0xFF4CAF50);

// ─── Tipografi yardımcıları ───────────────────────────────────────────────────
TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
  bool italic = false,
}) => AppFonts.display(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
);

TextStyle _ui({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
  double height = 1.4,
}) => AppFonts.ui(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
  height: height,
);

// ─── Süreç aşaması modeli — UI-only, freelancer bu ekrandan yönetir ───────────
class _ProcessStep {
  _ProcessStep({
    required this.title,
    required this.tag,
    required this.icon,
    required this.description,
    this.isDone = false,
  });

  String title;
  String tag;
  IconData icon;
  String description;
  bool isDone;
}

class FreelancerSetProjectsView extends StatefulWidget {
  const FreelancerSetProjectsView({super.key});

  @override
  State<FreelancerSetProjectsView> createState() =>
      _FreelancerSetProjectsViewState();
}

class _FreelancerSetProjectsViewState
    extends State<FreelancerSetProjectsView> {
  final List<_ProcessStep> _steps = [
    _ProcessStep(
      title: 'BRİF',
      tag: '24 MAY',
      icon: Icons.assignment_outlined,
      description: 'Proje kapsamı, hedefler ve gereksinimler netleştirildi.',
      isDone: true,
    ),
    _ProcessStep(
      title: 'PLANLAMA',
      tag: '25 MAY',
      icon: Icons.event_note_rounded,
      description: 'Ekip planı ve süreç takvimi oluşturuldu.',
      isDone: true,
    ),
    _ProcessStep(
      title: 'EKİP OLUŞUMU',
      tag: '',
      icon: Icons.groups_rounded,
      description:
          'Görüntü yönetmeni, editör ve diğer ekip üyeleri bir araya getiriliyor.',
    ),
    _ProcessStep(
      title: 'ÇEKİM',
      tag: '',
      icon: Icons.videocam_rounded,
      description: 'Belirlenen lokasyonda çekim gerçekleştirilecek.',
    ),
    _ProcessStep(
      title: 'KURGU',
      tag: '',
      icon: Icons.content_cut_rounded,
      description: 'Ham görüntüler kurgulanıp son haline getirilecek.',
    ),
    _ProcessStep(
      title: 'TESLİM',
      tag: '',
      icon: Icons.flag_rounded,
      description: 'Tamamlanan proje teslim edilecek.',
    ),
  ];

  // "Şu an" olan aşama — sırayla ilk tamamlanmamış adım.
  int get _currentStep {
    final i = _steps.indexWhere((s) => !s.isDone);
    return i == -1 ? _steps.length - 1 : i;
  }

  // Sayfanın çoğu bölümü 24*s yatay boşlukla ortalanır; en alttaki proje
  // detayı kartları ise ekranın sağına/soluna dayanmalı, o yüzden dışarıda
  // bırakılıp yalnızca bu yardımcıyla saracağımız bölümlere uygulanır.
  static Widget _pad(double s, Widget child) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 24 * s),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final double s = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.85, 1.15)
        .toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Geri oku — kendi satırında.
                _pad(
                  s,
                  GestureDetector(
                    onTap: () => Get.back<void>(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4 * s),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 22 * s,
                        color: _kInk,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8 * s),
                // Proje indeksi + dosya no — okun hemen altında, sayfa
                // bu çizgiyle başlar.
                _pad(
                  s,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'PROJE / 01',
                        style: _ui(
                          size: 10 * s,
                          weight: FontWeight.w700,
                          color: _kGold,
                          spacing: 1.4,
                        ),
                      ),
                      SizedBox(width: 10 * s),
                      Expanded(
                        child: Container(height: 1, color: _kCardBorder),
                      ),
                      SizedBox(width: 10 * s),
                      Text(
                        'DOSYA NO · SH-2405-118',
                        style: _ui(size: 10 * s, color: _kTaupe, spacing: 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16 * s),

                // Başlık
                _pad(
                  s,
                  Text(
                    'Cafe Tanıtım\nFilmi',
                    style: _display(
                      size: 32 * s,
                      weight: FontWeight.w600,
                      color: _kInk,
                    ),
                  ),
                ),
                SizedBox(height: 16 * s),

                // Durum rozeti
                _pad(
                  s,
                  Row(
                    children: [
                      Container(
                        width: 8 * s,
                        height: 8 * s,
                        decoration: const BoxDecoration(color: _kGold),
                      ),
                      SizedBox(width: 8 * s),
                      Text(
                        'EKİP KURULUYOR',
                        style: _ui(
                          size: 10 * s,
                          weight: FontWeight.w700,
                          color: _kBlack,
                          spacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20 * s),

                // Proje sorumlusu kartı (köşe işaretli çerçeve)
                _pad(
                  s,
                  _CornerFramed(
                    scale: s,
                    child: _ManagerCard(scale: s),
                  ),
                ),
                SizedBox(height: 28 * s),
                _pad(s, Container(height: 1, color: _kCardBorder)),
                SizedBox(height: 18 * s),

                // Süreç adımları başlığı + yönetim butonu — yalnızca
                // hizmet veren (freelancer) bu ekrandan süreci düzenleyebilir.
                _pad(
                  s,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'SÜREÇ ADIMLARI',
                          style: _ui(
                            size: 10 * s,
                            weight: FontWeight.w700,
                            color: _kBlack,
                            spacing: 1.5,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _openManageStepsSheet,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 24 * s,
                          height: 24 * s,
                          color: _kGold,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.add_rounded,
                            size: 16 * s,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14 * s),

                // Süreç adımları — dikey zaman çizelgesi
                _pad(
                  s,
                  _StepProgress(scale: s, steps: _steps, currentStep: _currentStep),
                ),
                SizedBox(height: 24 * s),
                _pad(s, Container(height: 1, color: _kCardBorder)),
                SizedBox(height: 18 * s),

                // Güncelleme
                _pad(
                  s,
                  Text(
                    'GÜNCELLEME',
                    style: _ui(size: 10 * s, color: _kBlack, spacing: 1.5),
                  ),
                ),
                SizedBox(height: 14 * s),
                _pad(s, _UpdateItem(scale: s)),
                SizedBox(height: 28 * s),

                // Ekip Durumu
                _pad(s, _SectionHeader(scale: s, title: 'Ekip Durumu')),
                SizedBox(height: 14 * s),
                _pad(s, _TeamRow(scale: s)),
                SizedBox(height: 32 * s),

                // ── Proje detayı ──────────────────────────────────
                _ProjectDetailsHeaderCard(scale: s),
                SizedBox(height: 14 * s),
                _InfoSection(
                  scale: s,
                  icon: Icons.assignment_outlined,
                  label: 'BRIEF BİLGİLERİ',
                  child: _BriefGrid(scale: s),
                ),
                SizedBox(height: 14 * s),
                _InfoSection(
                  scale: s,
                  icon: Icons.description_outlined,
                  label: 'İŞ TARİFİ',
                  child: Padding(
                    padding: EdgeInsets.only(top: 12 * s),
                    child: Text(
                      'Cafe için 60 saniyelik tanıtım filmi. Sıcak ve samimi '
                      'bir atmosfer hedefleniyor; mekan çekimleri ve müşteri '
                      'anları öne çıkarılacak.',
                      style: _ui(
                        size: 15 * s,
                        color: _kBlack,
                        spacing: 0.2,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14 * s),
                _InfoSection(
                  scale: s,
                  icon: Icons.info_outline,
                  label: 'PROJE BİLGİLERİ',
                  child: Padding(
                    padding: EdgeInsets.only(top: 14 * s),
                    child: Column(
                      children: [
                        _InfoRow(
                          scale: s,
                          label: 'Oluşturulma Tarihi',
                          value: '20 May 2026 - 10:15',
                        ),
                        SizedBox(height: 12 * s),
                        _InfoRow(
                          scale: s,
                          label: 'Son Güncelleme',
                          value: '26 Ağu 2026 - 14:32',
                        ),
                        SizedBox(height: 12 * s),
                        _InfoRow(
                          scale: s,
                          label: 'Proje ID',
                          value: '#PRJ-2026-SH2405118',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Süreç adımlarını yönetme bottomsheet'i — sırala, düzenle, sil, ekle ──
  void _openManageStepsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _kCream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        final s = (MediaQuery.sizeOf(ctx).width / 390)
            .clamp(0.85, 1.15)
            .toDouble();
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            void refresh() => setState(() {});
            return DraggableScrollableSheet(
              initialChildSize: 0.82,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (ctx, scrollController) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(20 * s, 20 * s, 20 * s, 20 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36 * s,
                          height: 3 * s,
                          color: _kCardBorder,
                          margin: EdgeInsets.only(bottom: 18 * s),
                        ),
                      ),
                      Text(
                        'Süreç Adımlarını Yönet',
                        style: _display(
                          size: 24 * s,
                          weight: FontWeight.w600,
                          color: _kInk,
                        ),
                      ),
                      SizedBox(height: 4 * s),
                      Text(
                        'Sürükleyerek sırala, dokunarak düzenle.',
                        style: _ui(size: 9 * s, color: _kTaupe, spacing: 0.2),
                      ),
                      SizedBox(height: 16 * s),
                      Expanded(
                        child: ReorderableListView.builder(
                          scrollController: scrollController,
                          buildDefaultDragHandles: false,
                          itemCount: _steps.length,
                          onReorder: (oldIndex, newIndex) {
                            setSheetState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final item = _steps.removeAt(oldIndex);
                              _steps.insert(newIndex, item);
                            });
                            refresh();
                          },
                          itemBuilder: (ctx, i) {
                            final step = _steps[i];
                            return Container(
                              key: ValueKey('step-$i-${step.title}'),
                              margin: EdgeInsets.only(bottom: 10 * s),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: _kCardBorder),
                              ),
                              child: ListTile(
                                onTap: () => _openStepEditSheet(
                                  existingIndex: i,
                                  onSaved: () {
                                    setSheetState(() {});
                                    refresh();
                                  },
                                ),
                                leading: ReorderableDragStartListener(
                                  index: i,
                                  child: Icon(
                                    Icons.drag_indicator_rounded,
                                    color: _kTaupe,
                                    size: 18 * s,
                                  ),
                                ),
                                title: Text(
                                  step.title.isEmpty
                                      ? 'Başlıksız Aşama'
                                      : step.title,
                                  style: _ui(
                                    size: 10 * s,
                                    weight: FontWeight.w700,
                                    color: _kBlack,
                                    spacing: 0.3,
                                  ),
                                ),
                                subtitle: step.description.isNotEmpty
                                    ? Text(
                                        step.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: _ui(
                                          size: 9 * s,
                                          color: _kTaupe,
                                          spacing: 0.2,
                                        ),
                                      )
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      step.isDone
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked,
                                      size: 16 * s,
                                      color: step.isDone
                                          ? _kOnline
                                          : _kMuted,
                                    ),
                                    SizedBox(width: 8 * s),
                                    GestureDetector(
                                      onTap: () {
                                        setSheetState(() {
                                          _steps.removeAt(i);
                                        });
                                        refresh();
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18 * s,
                                        color: _kGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 14 * s),
                      GestureDetector(
                        onTap: () => _openStepEditSheet(
                          onSaved: () {
                            setSheetState(() {});
                            refresh();
                          },
                        ),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          height: 48 * s,
                          color: _kInk,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 16 * s,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6 * s),
                              Text(
                                'YENİ AŞAMA EKLE',
                                style: _ui(
                                  size: 10 * s,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                  spacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10 * s),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          height: 48 * s,
                          color: _kGold,
                          alignment: Alignment.center,
                          child: Text(
                            'TAMAM',
                            style: _ui(
                              size: 10 * s,
                              weight: FontWeight.w700,
                              color: Colors.white,
                              spacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ── Tek bir aşamayı ekle / düzenle bottomsheet'i ────────────────────────
  void _openStepEditSheet({int? existingIndex, required VoidCallback onSaved}) {
    final existing = existingIndex != null ? _steps[existingIndex] : null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final tagCtrl = TextEditingController(text: existing?.tag ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    bool isDone = existing?.isDone ?? false;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _kCream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        final s = (MediaQuery.sizeOf(ctx).width / 390)
            .clamp(0.85, 1.15)
            .toDouble();
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20 * s,
                20 * s,
                20 * s,
                MediaQuery.of(ctx).viewInsets.bottom + 20 * s,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36 * s,
                      height: 3 * s,
                      color: _kCardBorder,
                      margin: EdgeInsets.only(bottom: 18 * s),
                    ),
                  ),
                  Text(
                    existing == null ? 'Yeni Aşama' : 'Aşamayı Düzenle',
                    style: _display(
                      size: 24 * s,
                      weight: FontWeight.w600,
                      color: _kInk,
                    ),
                  ),
                  SizedBox(height: 20 * s),
                  Text(
                    'BAŞLIK',
                    style: _ui(
                      size: 10 * s,
                      weight: FontWeight.w700,
                      color: _kBlack,
                      spacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  _SheetField(
                    controller: titleCtrl,
                    scale: s,
                    hint: 'Örn. Renk Düzeltme',
                  ),
                  SizedBox(height: 18 * s),
                  Text(
                    'TARİH / ETİKET (opsiyonel)',
                    style: _ui(
                      size: 10 * s,
                      weight: FontWeight.w700,
                      color: _kBlack,
                      spacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  _SheetField(
                    controller: tagCtrl,
                    scale: s,
                    hint: 'Örn. 28 MAY',
                  ),
                  SizedBox(height: 18 * s),
                  Text(
                    'İÇERİK',
                    style: _ui(
                      size: 10 * s,
                      weight: FontWeight.w700,
                      color: _kBlack,
                      spacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  _SheetField(
                    controller: descCtrl,
                    scale: s,
                    hint: 'Bu aşamada ne yapılacak?',
                    maxLines: 3,
                  ),
                  SizedBox(height: 16 * s),
                  GestureDetector(
                    onTap: () =>
                        setLocalState(() => isDone = !isDone),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Icon(
                          isDone
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 18 * s,
                          color: isDone ? _kGold : _kMuted,
                        ),
                        SizedBox(width: 8 * s),
                        Text(
                          'Bu aşama tamamlandı',
                          style: _ui(
                            size: 10 * s,
                            weight: FontWeight.w600,
                            color: _kBlack,
                            spacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * s),
                  GestureDetector(
                    onTap: () {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) return;
                      final tag = tagCtrl.text.trim();
                      final desc = descCtrl.text.trim();
                      if (existing != null && existingIndex != null) {
                        existing.title = title;
                        existing.tag = tag;
                        existing.description = desc;
                        existing.isDone = isDone;
                      } else {
                        _steps.add(
                          _ProcessStep(
                            title: title,
                            tag: tag,
                            icon: Icons.flag_outlined,
                            description: desc,
                            isDone: isDone,
                          ),
                        );
                      }
                      onSaved();
                      Navigator.of(ctx).pop();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      height: 52 * s,
                      color: _kGold,
                      alignment: Alignment.center,
                      child: Text(
                        'KAYDET',
                        style: _ui(
                          size: 11 * s,
                          weight: FontWeight.w700,
                          color: Colors.white,
                          spacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Bottomsheet metin alanı ────────────────────────────────────────────────────
class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.scale,
    this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final double scale;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: c),
    );
    return TextField(
      controller: controller,
      maxLines: maxLines,
      cursorColor: _kGold,
      style: _ui(size: 11 * s, color: _kBlack, spacing: 0.2),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: _ui(size: 11 * s, color: _kBlack, spacing: 0.2),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14 * s,
          vertical: 12 * s,
        ),
        border: border(Colors.black.withValues(alpha: 0.12)),
        enabledBorder: border(Colors.black.withValues(alpha: 0.12)),
        focusedBorder: border(_kGold),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Köşe işaretli çerçeve (kart etrafında dekoratif L köşeler)
// ---------------------------------------------------------------------------

class _CornerFramed extends StatelessWidget {
  const _CornerFramed({required this.scale, required this.child});
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Stack(
      children: [
        child,
        Positioned(top: 0, left: 0, child: _corner(s, 0)),
        Positioned(top: 0, right: 0, child: _corner(s, 1)),
        Positioned(bottom: 0, left: 0, child: _corner(s, 2)),
        Positioned(bottom: 0, right: 0, child: _corner(s, 3)),
      ],
    );
  }

  // quadrant: 0 = top-left, 1 = top-right, 2 = bottom-left, 3 = bottom-right
  Widget _corner(double s, int quadrant) {
    final len = 12 * s;
    final isLeft = quadrant == 0 || quadrant == 2;
    final isTop = quadrant == 0 || quadrant == 1;
    return SizedBox(
      width: len,
      height: len,
      child: Stack(
        children: [
          Positioned(
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            child: Container(width: len, height: 1.4, color: _kGold),
          ),
          Positioned(
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            child: Container(width: 1.4, height: len, color: _kGold),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Proje sorumlusu kartı
// ---------------------------------------------------------------------------

class _ManagerCard extends StatelessWidget {
  const _ManagerCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipOval(
                    child: buildAvatarImage(
                      placeholderAvatarFor('kadin', 'selin-a-pm'),
                      size: 60 * s,
                      placeholder: Container(
                        width: 60 * s,
                        height: 60 * s,
                        color: const Color(0xFFE8D5C0),
                        child: Icon(Icons.person, size: 32 * s, color: _kTaupe),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 1 * s,
                    right: 1 * s,
                    child: Container(
                      width: 12 * s,
                      height: 12 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kOnline,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 14 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selin A.',
                      style: _display(
                        size: 24 * s,
                        weight: FontWeight.w600,
                        color: _kInk,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      'PROJE SORUMLUSU',
                      style: _ui(
                        size: 10 * s,
                        weight: FontWeight.w700,
                        color: _kGold,
                        spacing: 1,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Row(
                      children: [
                        Container(
                          width: 6 * s,
                          height: 6 * s,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kOnline,
                          ),
                        ),
                        SizedBox(width: 5 * s),
                        Text(
                          'ŞU AN ONLINE',
                          style: _ui(size: 10 * s, color: _kTaupe, spacing: 0.8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18 * s),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: _kCardBorder)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * s),
                child: Container(
                  width: 5 * s,
                  height: 5 * s,
                  decoration: const BoxDecoration(color: _kGold),
                ),
              ),
              Expanded(child: Container(height: 1, color: _kCardBorder)),
            ],
          ),
          SizedBox(height: 16 * s),
          Text(
            'Süreç boyunca tek muhatabın.',
            style: _display(
              size: 15 * s,
              weight: FontWeight.w500,
              color: _kInk,
              italic: true,
            ),
          ),
          SizedBox(height: 16 * s),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.chatDetail,
                    arguments: {'name': 'Selin A.', 'mode': 'set'},
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48 * s,
                    color: _kGold,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 15 * s,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8 * s),
                        Text(
                          'MESAJ GÖNDER',
                          style: _ui(
                            size: 10 * s,
                            weight: FontWeight.w700,
                            color: Colors.white,
                            spacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10 * s),
              GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 48 * s,
                  height: 48 * s,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _kInk, width: 1.2),
                  ),
                  child: Icon(Icons.call_outlined, size: 18 * s, color: _kInk),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Süreç adımları — dikey zaman çizelgesi (freelancer tarafından düzenlenebilir)
// ---------------------------------------------------------------------------

class _StepProgress extends StatelessWidget {
  const _StepProgress({
    required this.scale,
    required this.steps,
    required this.currentStep,
  });
  final double scale;
  final List<_ProcessStep> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          _StepRow(
            scale: s,
            step: steps[i],
            isCurrent: i == currentStep,
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class _StepRow extends StatefulWidget {
  const _StepRow({
    required this.scale,
    required this.step,
    required this.isCurrent,
    required this.isLast,
  });
  final double scale;
  final _ProcessStep step;
  final bool isCurrent;
  final bool isLast;

  @override
  State<_StepRow> createState() => _StepRowState();
}

class _StepRowState extends State<_StepRow>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrent) {
      _pulse = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _StepRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent && _pulse == null) {
      _pulse = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true);
    } else if (!widget.isCurrent && _pulse != null) {
      _pulse!.dispose();
      _pulse = null;
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final circleSize = 40.0 * s;
    final step = widget.step;
    final isCurrent = widget.isCurrent;

    Widget circle;
    if (isCurrent && _pulse != null) {
      // Yalnızca şu an yapılan iş aktif görünür — dolgun altın daire.
      circle = AnimatedBuilder(
        animation: _pulse!,
        builder: (context, child) {
          final t = _pulse!.value;
          return Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kGold,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15 + 0.75 * t),
                width: 2.5 * s,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withValues(alpha: 0.45 * t),
                  blurRadius: 10 * s,
                  spreadRadius: 2 * s,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Icon(step.icon, size: 18 * s, color: Colors.white),
      );
    } else {
      // Tamamlanmış ya da sıradaki işler — ikisi de deaktif görünür.
      circle = Container(
        width: circleSize,
        height: circleSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
        ),
        child: Icon(
          step.icon,
          size: 16 * s,
          color: _kMuted,
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              circle,
              if (!widget.isLast)
                Expanded(
                  child: Container(
                    width: 1.4,
                    margin: EdgeInsets.symmetric(vertical: 4 * s),
                    color: step.isDone
                        ? _kGold.withValues(alpha: 0.35)
                        : _kCardBorder,
                  ),
                ),
            ],
          ),
          SizedBox(width: 14 * s),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 6 * s,
                bottom: widget.isLast ? 0 : 22 * s,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        step.title.isEmpty ? 'BAŞLIKSIZ' : step.title,
                        style: _ui(
                          size: 10 * s,
                          weight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                          color: isCurrent ? _kGold : _kMuted,
                          spacing: 0.8,
                        ),
                      ),
                      if (step.tag.isNotEmpty) ...[
                        SizedBox(width: 8 * s),
                        Text(
                          step.tag,
                          style: _ui(
                            size: 7.5 * s,
                            weight: FontWeight.w700,
                            color: isCurrent ? _kGold : _kMuted,
                            spacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (step.description.isNotEmpty) ...[
                    SizedBox(height: 8 * s),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10 * s),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? _kGold.withValues(alpha: 0.08)
                            : Colors.white,
                        border: Border.all(
                          color: isCurrent
                              ? _kGold.withValues(alpha: 0.35)
                              : _kCardBorder,
                        ),
                      ),
                      child: Text(
                        step.description,
                        style: _ui(
                          size: 9 * s,
                          color: isCurrent ? _kInk : _kMuted,
                          spacing: 0.2,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Son güncelleme
// ---------------------------------------------------------------------------

class _UpdateItem extends StatelessWidget {
  const _UpdateItem({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6 * s,
          height: 6 * s,
          margin: EdgeInsets.only(top: 6 * s),
          decoration: const BoxDecoration(color: _kGold),
        ),
        SizedBox(width: 12 * s),
        ClipOval(
          child: buildAvatarImage(
            placeholderAvatarFor('kadin', 'set-update-selin'),
            size: 36 * s,
            placeholder: Container(
              width: 36 * s,
              height: 36 * s,
              color: const Color(0xFFEADCBB),
              child: Icon(Icons.person, size: 20 * s, color: _kTaupe),
            ),
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selin A.',
                    style: _ui(
                      size: 10 * s,
                      weight: FontWeight.w700,
                      color: _kInk,
                      spacing: 0.2,
                    ),
                  ),
                  Text(
                    'BUGÜN · 14:32',
                    style: _ui(size: 8 * s, color: _kTaupe, spacing: 0.3),
                  ),
                ],
              ),
              SizedBox(height: 6 * s),
              Text(
                'Yönetmen ve görüntü yönetmeniyle toplantı gerçekleştirildi. Mekan keşfi 26 Mayıs\'ta.',
                style: _ui(
                  size: 9.5 * s,
                  color: _kBlack,
                  spacing: 0.2,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ortak bölüm başlığı
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.scale, required this.title});
  final double scale;
  final String title;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: [
        Text(
          title,
          style: _display(size: 24 * s, weight: FontWeight.w600, color: _kInk),
        ),
        const Spacer(),
        Text(
          'TÜMÜNÜ GÖR',
          style: _ui(
            size: 10 * s,
            weight: FontWeight.w700,
            color: _kGold,
            spacing: 1,
          ),
        ),
        SizedBox(width: 4 * s),
        Icon(Icons.arrow_forward_rounded, size: 12 * s, color: _kGold),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ekip durumu
// ---------------------------------------------------------------------------

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.scale});
  final double scale;

  static const _members = [
    ('Videographer', 'Bulundu', true),
    ('Editor', 'Bulundu', true),
    ('Colorist', 'Aranıyor', false),
    ('Drone Op.', 'Aranıyor', false),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: _members.map((m) {
        final found = m.$3;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 10 * s),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipOval(
                      child: buildAvatarImage(
                        placeholderAvatarFor(null, m.$1),
                        size: 52 * s,
                        placeholder: Container(
                          width: 52 * s,
                          height: 52 * s,
                          color: const Color(0xFFE8D5C0),
                          child: Icon(
                            Icons.person,
                            size: 26 * s,
                            color: _kTaupe,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14 * s,
                        height: 14 * s,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: found ? _kOnline : _kGold,
                          border: Border.all(color: Colors.white, width: 1.4),
                        ),
                        child: Icon(
                          found ? Icons.check_rounded : Icons.search_rounded,
                          size: 8 * s,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * s),
                Text(
                  m.$1,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _ui(
                    size: 7.5 * s,
                    weight: FontWeight.w700,
                    color: _kBlack,
                    spacing: 0.2,
                  ),
                ),
                SizedBox(height: 3 * s),
                Text(
                  m.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _ui(
                    size: 7 * s,
                    color: found ? _kOnline : _kGold,
                    spacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Proje detayı
// ---------------------------------------------------------------------------

class _ProjectDetailsHeaderCard extends StatelessWidget {
  const _ProjectDetailsHeaderCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(36 * s, 16 * s, 36 * s, 16 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _kCardBorder),
          bottom: BorderSide(color: _kCardBorder),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56 * s,
            height: 56 * s,
            decoration: const BoxDecoration(color: Colors.white),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/main_service_icons/video.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.videocam_rounded, size: 28 * s, color: _kGold),
            ),
          ),
          SizedBox(width: 14 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EKİP KURULUYOR',
                  style: _ui(
                    size: 10 * s,
                    weight: FontWeight.w700,
                    color: _kGold,
                    spacing: 1.2,
                  ),
                ),
                SizedBox(height: 5 * s),
                Text(
                  'Cafe Tanıtım Filmi',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _display(
                    size: 24 * s,
                    weight: FontWeight.w600,
                    color: _kInk,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  'Video Prodüksiyon',
                  style: _ui(size: 13 * s, color: _kBlack, spacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.scale,
    required this.icon,
    required this.label,
    required this.child,
  });

  final double scale;
  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(36 * s, 14 * s, 36 * s, 16 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _kCardBorder),
          bottom: BorderSide(color: _kCardBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14 * s, color: _kGold),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  label,
                  style: _ui(
                    size: 10 * s,
                    weight: FontWeight.w700,
                    color: _kBlack,
                    spacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _BriefGrid extends StatelessWidget {
  const _BriefGrid({required this.scale});
  final double scale;

  static const _items = [
    (Icons.movie_creation_outlined, 'Çekim Türü', 'Reklam Filmi'),
    (Icons.calendar_today_outlined, 'Çekim Tarihi', '26 May 2026'),
    (Icons.access_time_outlined, 'Teslim Süresi', '7 Gün'),
    (Icons.payments_outlined, 'Bütçe', '120K'),
    (Icons.location_on_outlined, 'Lokasyon', 'Beşiktaş'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final rows = <Widget>[];
    for (var i = 0; i < _items.length; i += 3) {
      final rowItems = _items.sublist(
        i,
        i + 3 > _items.length ? _items.length : i + 3,
      );
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(3, (j) {
            if (j >= rowItems.length) return const Expanded(child: SizedBox());
            final item = rowItems[j];
            return Expanded(
              child: _GridCell(
                scale: s,
                icon: item.$1,
                label: item.$2,
                value: item.$3,
              ),
            );
          }),
        ),
      );
      if (i + 3 < _items.length) rows.add(SizedBox(height: 14 * s));
    }

    return Padding(
      padding: EdgeInsets.only(top: 16 * s),
      child: Column(children: rows),
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.scale,
    required this.icon,
    required this.label,
    required this.value,
  });
  final double scale;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 11 * s, color: _kTaupe),
            SizedBox(width: 4 * s),
            Expanded(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _ui(size: 10 * s, color: _kBlack, spacing: 0.8),
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * s),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _ui(
            size: 10 * s,
            weight: FontWeight.w400,
            color: _kBlack,
            spacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.scale,
    required this.label,
    required this.value,
  });
  final double scale;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: _ui(size: 9 * s, color: _kBlack, spacing: 0.3),
          ),
        ),
        SizedBox(width: 10 * s),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: _ui(
              size: 9 * s,
              weight: FontWeight.w700,
              color: _kBlack,
              spacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}
