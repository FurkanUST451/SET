import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../data/models/brief_model.dart';
import '../../../../data/models/project_model.dart';
import '../../../../routes/app_routes.dart';
import '../client_home_controller.dart';
import '../client_projects_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kDivider = Color(0x12000000);
const _kGreen = Color(0xFF6B8F71);
// "Açık brief" kartının koyu zemini
const _kCardDark = Color(0xFF1C1B20);

// Yer tutucu profil fotoğrafları — brief'e yanıt veren freelancer'ların
// avatar dizisi henüz backend'de karşılığı olmadığı için karışık
// cinsiyette sabit görsellerle gösterilir.
final _kResponderAvatars = [
  AppAssets.profilePhotosMale[0],
  AppAssets.profilePhotosFemale[1],
  AppAssets.profilePhotosMale[2],
  AppAssets.profilePhotosFemale[3],
];

const _kWeekdayNames = [
  'PAZARTESİ',
  'SALI',
  'ÇARŞAMBA',
  'PERŞEMBE',
  'CUMA',
  'CUMARTESİ',
  'PAZAR',
];
const _kMonthNames = [
  'OCAK',
  'ŞUBAT',
  'MART',
  'NİSAN',
  'MAYIS',
  'HAZİRAN',
  'TEMMUZ',
  'AĞUSTOS',
  'EYLÜL',
  'EKİM',
  'KASIM',
  'ARALIK',
];

// "Gelen fiyatlar" ve "Son yanıt" alanları henüz backend'de bir teklif
// modeline bağlı olmadığı için gösterimlik sabit veriyle doldurulur.
class _MockQuote {
  const _MockQuote({required this.price, required this.name});
  final String price;
  final String name;
}

const _kMockQuotes = [
  _MockQuote(price: '44.000 ₺', name: 'EMRE K.'),
  _MockQuote(price: '48.000 ₺', name: 'SELİN D.'),
  _MockQuote(price: '61.000 ₺', name: 'KAAN A.'),
];

TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
  bool italic = false,
  double? letterSpacing,
}) => AppFonts.display(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
  decoration: TextDecoration.none,
);

TextStyle _ui({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
  double? height,
}) => AppFonts.ui(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
  height: height,
  decoration: TextDecoration.none,
);

class _ArchiveProject {
  const _ArchiveProject({
    required this.id,
    required this.image,
    required this.tag,
    required this.title,
    required this.people,
    required this.year,
  });

  final String id;
  final String image;
  final String tag;
  final String title;
  final String people;
  final String year;
}

class ClientHomeTab extends StatelessWidget {
  const ClientHomeTab({super.key});

  static final _archive = [
    _ArchiveProject(
      id: 'w1',
      image: AppAssets.portfolioMercedesBg,
      tag: 'REKLAM',
      title: 'Mercedes Campaign',
      people: '12 KİŞİ',
      year: '2023',
    ),
    _ArchiveProject(
      id: 'w1',
      image: AppAssets.portfolioMercedesGallery[1],
      tag: 'REKLAM',
      title: 'Mercedes Campaign',
      people: '12 KİŞİ',
      year: '2023',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();

    return SizedBox.expand(
      child: ColoredBox(
        color: _kCream,
        child: MediaQuery.withNoTextScaling(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopStrip(s),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 130 * s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 34 * s),
                        Obx(() {
                          final controller =
                              Get.find<ClientProjectsController>();
                          BriefModel? openBrief;
                          for (final b in controller.briefs) {
                            if (b.status == 'offer_sent') {
                              openBrief = b;
                              break;
                            }
                          }
                          return _buildResponseSection(s, openBrief);
                        }),
                        SizedBox(height: 34 * s),
                        Obx(() {
                          final controller =
                              Get.find<ClientProjectsController>();
                          ProjectModel? active;
                          for (final p in controller.projects) {
                            if (p.status == ProjectStatus.active) {
                              active = p;
                              break;
                            }
                          }
                          if (active == null) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOngoingSection(s, active),
                              SizedBox(height: 30 * s),
                            ],
                          );
                        }),
                        _buildNewBriefBanner(s),
                        SizedBox(height: 34 * s),
                        _buildArchiveSection(s),
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

  // ── Sayfa tepesi — GÜN · TARİH + SET · ANA SAYFA ────────────────
  Widget _buildTopStrip(double s) {
    final now = DateTime.now();
    final weekday = _kWeekdayNames[now.weekday - 1];
    final dateLabel = '$weekday · ${now.day} ${_kMonthNames[now.month - 1]}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(26 * s, 6 * s, 26 * s, 12 * s),
          child: Row(
            children: [
              Text(
                'SET · ANA SAYFA',
                style: _ui(size: 10 * s, color: _kBlack, spacing: 2),
              ),
              const Spacer(),
              Text(
                dateLabel,
                style: _ui(size: 10 * s, color: _kBlack, spacing: 1.6),
              ),
            ],
          ),
        ),
        Container(height: 1, color: _kDivider),
      ],
    );
  }

  // ── Brief'e gelen yanıt özeti + açık brief kartı ─────────────────
  Widget _buildResponseSection(double s, BriefModel? openBrief) {
    final hasReal = openBrief != null;
    final title = hasReal
        ? (openBrief.category.isNotEmpty ? openBrief.category : openBrief.title)
        : 'Cafe Tanıtım Filmi';
    final subtitleParts = <String>[
      hasReal
          ? (openBrief.answers.shootingType ?? openBrief.category)
          : 'Tanıtım Filmi',
      if (hasReal && (openBrief.answers.location ?? '').isNotEmpty)
        openBrief.answers.location!
      else if (!hasReal)
        'İstanbul',
      if (hasReal && (openBrief.answers.budget ?? '').isNotEmpty)
        openBrief.answers.budget!
      else if (!hasReal)
        '40–60.000 ₺',
    ];
    final sentCount = hasReal && openBrief.sentToIds.isNotEmpty
        ? openBrief.sentToIds.length
        : 7;
    // Gerçek "yanıtlayan" sayısı henüz brief modelinde tutulmadığı için
    // gösterimlik bir oran kullanılır.
    final respondedCount = hasReal
        ? (sentCount * 0.6).round().clamp(1, sentCount).toInt()
        : 3;

    void openBriefDetail() {
      if (hasReal) {
        Get.toNamed(AppRoutes.briefDetail, arguments: {'brief': openBrief});
      } else {
        Get.find<ClientHomeController>().changeTab(3);
      }
    }

    void openBriefEdit() {
      if (hasReal) {
        Get.toNamed(
          AppRoutes.sendOffer,
          arguments: {'category': openBrief.category, 'brief': openBrief},
        );
      } else {
        Get.find<ClientHomeController>().changeTab(3);
      }
    }

    final numberText = '$respondedCount'.padLeft(2, '0');
    final numberFontSize = 116 * s;
    final digitStyle = _display(
      size: numberFontSize,
      weight: FontWeight.w700,
      color: _kInk,
      height: 1.0,
      letterSpacing: numberFontSize * -0.03,
    );
    final digitStrut = StrutStyle(
      fontSize: numberFontSize,
      height: 1.0,
      forceStrutHeight: true,
    );

    final labelFontSize = 11.0 * s;
    final labelStyle = _ui(
      size: labelFontSize,
      weight: FontWeight.w700,
      color: _kBlack,
      spacing: 0.9 * s,
      height: 1.3,
    );
    final labelStrut = StrutStyle(
      fontSize: labelFontSize,
      height: 1.3,
      forceStrutHeight: true,
    );
    const labelText = 'BRIEF\'İNE GELEN\nYANIT';

    // Nokta ile etiketin konumu birbirinden bağımsız olarak, rakamın ve
    // etiketin GERÇEK ölçülmüş baseline'larından hesaplanır — biri
    // değişince diğerini etkilemez (Stack + Positioned, Row/Column yok).
    final digitPainter = TextPainter(
      text: TextSpan(text: numberText, style: digitStyle),
      strutStyle: digitStrut,
      textDirection: TextDirection.ltr,
    )..layout();
    final labelPainter = TextPainter(
      text: TextSpan(text: labelText, style: labelStyle),
      strutStyle: labelStrut,
      textDirection: TextDirection.ltr,
    )..layout();

    final digitBaseline = digitPainter.computeLineMetrics().first.baseline;
    final labelLastBaseline = labelPainter.computeLineMetrics().last.baseline;

    const capRatio = 0.72; // TEK ayarlanabilir sabit — rakamın görünen yüksekliği
    final capTop = digitBaseline - numberFontSize * capRatio;
    final dotSize = 10 * s;
    final columnGap = 12 * s;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 26 * s),
          child: SizedBox(
            width: digitPainter.width + columnGap + labelPainter.width,
            height: digitPainter.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Text(numberText, style: digitStyle, strutStyle: digitStrut),
                ),
                // Nokta: ÜST kenarı rakamın üst kenarıyla aynı hizada.
                Positioned(
                  left: digitPainter.width + columnGap,
                  top: capTop,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kGold,
                    ),
                  ),
                ),
                // Etiket: son satırın baseline'ı rakamın baseline'ıyla çakışır.
                Positioned(
                  left: digitPainter.width + columnGap,
                  top: digitBaseline - labelLastBaseline,
                  child: Text(labelText, style: labelStyle, strutStyle: labelStrut),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 26 * s),
          child: Text(
            '$respondedCount freelancer fiyat verdi, ${sentCount - respondedCount}\'ü inceliyor.',
            style: _ui(
              size: 15 * s,
              weight: FontWeight.w400,
              color: _kTaupe,
              spacing: 0,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: 48 * s),
        GestureDetector(
          onTap: openBriefDetail,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            color: _kCardDark,
            padding: EdgeInsets.fromLTRB(24 * s, 20 * s, 24 * s, 20 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AÇIK BRIEF',
                      style: _ui(
                        size: 10 * s,
                        weight: FontWeight.w700,
                        color: _kGold,
                        spacing: 1.6,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '2 GÜN KALDI',
                      style: _ui(
                        size: 10 * s,
                        weight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.5),
                        spacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * s),
                Text(
                  title,
                  style: _display(
                    size: 24 * s,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  subtitleParts.join(' · '),
                  style: _ui(
                    size: 13 * s,
                    color: Colors.white.withValues(alpha: 0.55),
                    spacing: 0.3,
                  ),
                ),
                SizedBox(height: 18 * s),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
                SizedBox(height: 16 * s),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '0$respondedCount/0$sentCount',
                      style: _display(
                        size: 22 * s,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Text(
                      'YANITLADI',
                      style: _ui(
                        size: 10 * s,
                        weight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.5),
                        spacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < _kResponderAvatars.length; i++)
                          _ResponderAvatarChip(
                            scale: s,
                            image: _kResponderAvatars[i],
                            active: i < respondedCount,
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 18 * s),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
                SizedBox(height: 16 * s),
                Text(
                  'GELEN FİYATLAR',
                  style: _ui(
                    size: 10 * s,
                    weight: FontWeight.w700,
                    color: _kGold,
                    spacing: 1.4,
                  ),
                ),
                SizedBox(height: 10 * s),
                Row(
                  children: [
                    for (var i = 0; i < _kMockQuotes.length; i++) ...[
                      if (i > 0)
                        Container(
                          width: 1,
                          height: 30 * s,
                          color: Colors.white.withValues(alpha: 0.12),
                          margin: EdgeInsets.symmetric(horizontal: 12 * s),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _kMockQuotes[i].price,
                              style: _display(
                                size: 15 * s,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2 * s),
                            Text(
                              _kMockQuotes[i].name,
                              style: _ui(
                                size: 10 * s,
                                weight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.45),
                                spacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 20 * s),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            Get.find<ClientHomeController>().changeTab(1),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 42 * s,
                          color: _kGold,
                          alignment: Alignment.center,
                          child: Text(
                            'YANITLARI GÖR',
                            style: _ui(
                              size: 10 * s,
                              weight: FontWeight.w700,
                              color: _kBlack,
                              spacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10 * s),
                    Expanded(
                      child: GestureDetector(
                        onTap: openBriefEdit,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 42 * s,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            'BRIEF\'İ DÜZENLE',
                            style: _ui(
                              size: 10 * s,
                              weight: FontWeight.w700,
                              color: Colors.white,
                              spacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 38 * s),
        _buildLastResponsePreview(s),
      ],
    );
  }

  // ── Son yanıt önizlemesi — freelancer'ın son mesajı ve ilgili teklifi ─
  Widget _buildLastResponsePreview(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 24 * s, height: 1.5, color: _kGold),
          SizedBox(height: 12 * s),
          Text(
            'SON YANIT',
            style: _ui(
              size: 10 * s,
              weight: FontWeight.w700,
              color: _kBlack,
              spacing: 1.6,
            ),
          ),
          SizedBox(height: 14 * s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Image.asset(
                  _kResponderAvatars[0],
                  width: 44 * s,
                  height: 44 * s,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emre K.',
                      style: _display(
                        size: 19 * s,
                        weight: FontWeight.w600,
                        color: _kInk,
                      ),
                    ),
                    SizedBox(height: 3 * s),
                    Text(
                      'Merhaba, proje detaylarını inceledim.',
                      style: _ui(size: 13 * s, color: _kTaupe, spacing: 0.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          GestureDetector(
            onTap: () => Get.find<ClientHomeController>().changeTab(3),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: _kDivider),
                  bottom: BorderSide(color: _kDivider),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 14 * s),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Görüntü yönetmeni · 6 gün · 48.000 ₺',
                      style: _ui(size: 9 * s, color: _kBlack, spacing: 0.3),
                    ),
                  ),
                  Text(
                    'İNCELE',
                    style: _ui(
                      size: 10 * s,
                      weight: FontWeight.w700,
                      color: _kGold,
                      spacing: 1,
                    ),
                  ),
                  SizedBox(width: 4 * s),
                  Icon(Icons.arrow_forward_rounded, size: 13 * s, color: _kGold),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Süren iş — Projelerim'deki onaylı/aktif projenin önizlemesi ─────
  Widget _buildOngoingSection(double s, ProjectModel project) {
    final title = (project.category != null && project.category!.isNotEmpty)
        ? project.category!
        : project.title;
    final currentStage = _kActiveProjectStages[_kActiveProjectStageIndex];
    return GestureDetector(
      onTap: () => Get.find<ClientProjectsController>().openProjectDetail(project),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26 * s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 24 * s, height: 1.5, color: _kGold),
            SizedBox(height: 12 * s),
            Text(
              'SÜREN İŞ',
              style: _ui(
                size: 10 * s,
                weight: FontWeight.w700,
                color: _kGold,
                spacing: 1.8,
              ),
            ),
            SizedBox(height: 14 * s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '0$_kActiveProjectStageIndex/0${_kActiveProjectStages.length}',
                  style: _display(
                    size: 34 * s,
                    weight: FontWeight.w600,
                    color: _kInk,
                  ),
                ),
                SizedBox(width: 20 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _display(
                          size: 19 * s,
                          weight: FontWeight.w600,
                          color: _kInk,
                        ),
                      ),
                      SizedBox(height: 4 * s),
                      Row(
                        children: [
                          Container(
                            width: 6 * s,
                            height: 6 * s,
                            decoration: const BoxDecoration(
                              color: _kGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6 * s),
                          Text(
                            'Selin A. · şu an online',
                            style: _ui(
                              size: 9 * s,
                              color: _kTaupe,
                              spacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 20 * s, color: _kMuted),
              ],
            ),
            SizedBox(height: 12 * s),
            Text(
              currentStage.toUpperCase(),
              style: _ui(
                size: 10 * s,
                weight: FontWeight.w700,
                color: _kBlack.withValues(alpha: 0.45),
                spacing: 1.4,
              ),
            ),
            SizedBox(height: 20 * s),
            Container(height: 1, color: _kDivider),
          ],
        ),
      ),
    );
  }

  // ── Yeni brief oluştur bandı ───────────────────────────────────────
  Widget _buildNewBriefBanner(double s) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.categoryPicker),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        color: _kGold,
        padding: EdgeInsets.symmetric(horizontal: 26 * s, vertical: 22 * s),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yeni brief oluştur',
                    style: _display(
                      size: 24 * s,
                      weight: FontWeight.w600,
                      color: _kBlack,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    'Ne istediğini anlat, teklifler sana gelsin.',
                    style: _ui(size: 9 * s, color: _kBlack, spacing: 0.2),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, size: 22 * s, color: _kBlack),
          ],
        ),
      ),
    );
  }

  // ── Arşivden — tamamlanmış işlerin görsel arşivi ─────────────────
  Widget _buildArchiveSection(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 26 * s),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'ARŞİVDEN',
                  style: _ui(
                    size: 10 * s,
                    weight: FontWeight.w700,
                    color: _kBlack,
                    spacing: 1.6,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.clientArchive),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      'TÜMÜ',
                      style: _ui(
                        size: 10 * s,
                        weight: FontWeight.w700,
                        color: _kGold,
                        spacing: 1,
                      ),
                    ),
                    SizedBox(width: 4 * s),
                    Icon(Icons.arrow_forward_rounded, size: 13 * s, color: _kGold),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16 * s),
        for (final project in _archive) ...[
          _ArchiveCard(scale: s, project: project),
          SizedBox(height: 4 * s),
        ],
      ],
    );
  }
}

// ── Arşiv görsel kartı ────────────────────────────────────────────
// ── Yanıtlayan avatar çipi — yan yana, bitişik, dikdörtgen. Henüz
// yanıtlamayanlar soluk/gri gösterilir. ─────────────────────────────
class _ResponderAvatarChip extends StatelessWidget {
  const _ResponderAvatarChip({
    required this.scale,
    required this.image,
    required this.active,
  });

  final double scale;
  final String image;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final photo = Image.asset(image, width: 30 * s, height: 38 * s, fit: BoxFit.cover);
    return Container(
      width: 30 * s,
      height: 38 * s,
      decoration: BoxDecoration(
        border: Border.all(color: _kCardDark, width: 1 * s),
      ),
      child: active
          ? photo
          : Opacity(
              opacity: 0.35,
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
                child: photo,
              ),
            ),
    );
  }
}

class _ArchiveCard extends StatelessWidget {
  const _ArchiveCard({required this.scale, required this.project});
  final double scale;
  final _ArchiveProject project;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.portfolioProjectDetail,
        arguments: {
          'workId': project.id,
          'title': project.title,
          'category': project.tag,
        },
      ),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        height: 220 * s,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(project.image, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  stops: const [0.4, 1],
                ),
              ),
            ),
            Positioned(
              left: 26 * s,
              right: 26 * s,
              bottom: 20 * s,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: _display(
                      size: 24 * s,
                      weight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    '${project.tag} · ${project.people} · ${project.year}',
                    style: _ui(
                      size: 10 * s,
                      weight: FontWeight.w700,
                      color: _kGold,
                      spacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Kart, ilerleme "aşama"larını backend'de henüz karşılığı olmayan
// bir alan olduğu için sabit/gösterimlik tutar.
const _kActiveProjectStages = [
  'Brief Onayı',
  'Ekip',
  'Planlama',
  'Çekim',
  'Teslim',
];
const _kActiveProjectStageIndex = 3;
