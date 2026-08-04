import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../data/models/project_model.dart';
import '../../../../routes/app_routes.dart';
import '../client_projects_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kDivider = Color(0x12000000);
// Devam eden proje kartı — sayfanın kendi arka plan rengi (sarıya çalan
// krem beyaz), koyu değil.
const _kCardBg = _kCream;

// "Yakındaki kreatifler" satırı için karışık cinsiyette yer tutucu fotoğraflar
final _kNearbyCreatives = [
  AppAssets.profilePhotosFemale[0],
  AppAssets.profilePhotosMale[1],
  AppAssets.profilePhotosFemale[2],
  AppAssets.profilePhotosMale[3],
];

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
  decoration: TextDecoration.none,
);

TextStyle _ui({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
}) => AppFonts.ui(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
  decoration: TextDecoration.none,
);

class _FeaturedProject {
  const _FeaturedProject({
    required this.id,
    required this.index,
    required this.tag,
    required this.title,
    required this.people,
    required this.city,
  });

  final String id;
  final String index;
  final String tag;
  final String title;
  final String people;
  final String city;
}

class ClientHomeTab extends StatelessWidget {
  const ClientHomeTab({super.key});

  static const _projects = [
    _FeaturedProject(
      id: 'w1',
      index: '01',
      tag: 'REKLAM',
      title: 'Mercedes Campaign',
      people: '12 KİŞİ',
      city: 'İSTANBUL',
    ),
    _FeaturedProject(
      id: 'w4',
      index: '02',
      tag: 'VİDEO',
      title: 'Nike Motion Project',
      people: '8 KİŞİ',
      city: 'İSTANBUL',
    ),
    _FeaturedProject(
      id: 'w5',
      index: '03',
      tag: 'BELGESEL',
      title: 'Netflix Documentary',
      people: '6 KİŞİ',
      city: 'İSTANBUL',
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
                        _buildHero(s),
                        SizedBox(height: 46 * s),
                        _buildStartButton(s),
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
                          if (active == null) return SizedBox(height: 36 * s);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 18 * s),
                              _ActiveProjectCard(scale: s, project: active),
                              SizedBox(height: 36 * s),
                            ],
                          );
                        }),
                        _buildFeaturedSection(s),
                        SizedBox(height: 36 * s),
                        _buildInspirationSection(context, s),
                        SizedBox(height: 36 * s),
                        _buildCreativesSection(s),
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

  // ── Sayfa tepesi — SET · ANA SAYFA + bildirim + tam genişlik ayraç ─
  Widget _buildTopStrip(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(26 * s, 6 * s, 26 * s, 12 * s),
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                Text(
                  'SET · ANA SAYFA',
                  style: _ui(size: 8 * s, color: _kBlack, spacing: 2),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 18 * s,
                            color: _kInk,
                          ),
                          Positioned(
                            top: -1 * s,
                            right: -1 * s,
                            child: Container(
                              width: 5 * s,
                              height: 5 * s,
                              decoration: const BoxDecoration(
                                color: _kGold,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(height: 1, color: _kDivider),
      ],
    );
  }

  // ── Başlık + günün objesi + görsel (görsel, metin bloğuyla aynı yüksekliği kaplar) ─
  Widget _buildHero(double s) {
    // Metin sütunu sabit genişlikte; görsel bunun üstüne mutlak konumlanır.
    // Böylece ikisinin boyutu birbirine bağımlı değildir — biri büyürken
    // diğeri küçülmez.
    return Padding(
      padding: EdgeInsets.fromLTRB(26 * s, 26 * s, 0, 0),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: 205 * s,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Doğru ekip,\ndoğru ',
                          style: _display(
                            size: 27 * s,
                            weight: FontWeight.w600,
                            color: _kInk,
                            height: 1.15,
                          ),
                        ),
                        TextSpan(
                          text: 'fikirle',
                          style: _display(
                            size: 27 * s,
                            weight: FontWeight.w600,
                            color: _kGold,
                            height: 1.15,
                          ),
                        ),
                        TextSpan(
                          text: '\ngerçek olur.',
                          style: _display(
                            size: 27 * s,
                            weight: FontWeight.w600,
                            color: _kInk,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22 * s),
                  Container(width: 24 * s, height: 1, color: _kDivider),
                  SizedBox(height: 16 * s),
                  Text(
                    'GÜNÜN OBJESİ',
                    style: _ui(size: 8 * s, color: _kTaupe, spacing: 1.8),
                  ),
                  SizedBox(height: 6 * s),
                  Text(
                    'ANAHTAR',
                    style: _ui(
                      size: 13 * s,
                      weight: FontWeight.w700,
                      color: _kInk,
                      spacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 5 * s),
                  Text(
                    'Doğru insan her kapıyı açar.',
                    style: _ui(size: 9 * s, color: _kBlack, spacing: 0.3),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 4 * s,
              // Alt kenar sabit kalsın diye "bottom" ile konumlandırıyoruz;
              // görsel büyüdükçe sadece üst kenar yukarı doğru uzar.
              bottom: -44 * s,
              child: Image.asset(
                'assets/images/page_images/key.png',
                width: 177 * s,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Proje başlat bandı ───────────────────────────────────────
  Widget _buildStartButton(double s) {
    final double barHeight = 56 * s;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26 * s),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.categoryPicker),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: barHeight,
          color: _kGold,
          padding: EdgeInsets.symmetric(horizontal: 20 * s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 19 * s,
                height: 19 * s,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: _kBlack, width: 0.8),
                ),
                child: Icon(Icons.add_rounded, size: 11 * s, color: _kBlack),
              ),
              SizedBox(width: 12 * s),
              Text(
                'Projeni Başlat',
                style: _display(
                  size: 19 * s,
                  weight: FontWeight.w600,
                  color: _kBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Ortak bölüm başlığı: label + (opsiyonel) "TÜMÜNÜ GÖR" ────
  Widget _sectionHeaderRow(double s, String label, {bool showAll = true}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: _ui(
              size: 8 * s,
              weight: FontWeight.w700,
              color: _kBlack,
              spacing: 1.6,
            ),
          ),
        ),
        if (showAll)
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(
                  'TÜMÜNÜ GÖR',
                  style: _ui(
                    size: 8 * s,
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
    );
  }

  // ── Öne çıkan projeler ─────────────────────────────────────────
  Widget _buildFeaturedSection(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeaderRow(s, 'ÖNE ÇIKAN PROJELER', showAll: false),
          SizedBox(height: 6 * s),
          for (var i = 0; i < _projects.length; i++) ...[
            _FeaturedProjectRow(scale: s, project: _projects[i]),
            if (i < _projects.length - 1)
              Divider(height: 1, thickness: 1, color: _kDivider),
          ],
        ],
      ),
    );
  }

  // ── İlham kartı ───────────────────────────────────────────────
  Widget _buildInspirationSection(BuildContext context, double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 26 * s),
          child: Text(
            'İLHAM',
            style: _ui(
              size: 8 * s,
              weight: FontWeight.w700,
              color: _kBlack,
              spacing: 1.6,
            ),
          ),
        ),
        SizedBox(height: 14 * s),
        GestureDetector(
          onTap: () => _openInspirationModal(context, s),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: _kDivider),
                bottom: BorderSide(color: _kDivider),
              ),
            ),
            padding: EdgeInsets.fromLTRB(26 * s, 14 * s, 26 * s, 14 * s),
            child: Row(
              children: [
                SizedBox(
                  width: 56 * s,
                  height: 56 * s,
                  child: Image.asset(
                    'assets/images/page_images/apple.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 14 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apple',
                        style: _display(
                          size: 20 * s,
                          weight: FontWeight.w600,
                          color: _kInk,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        'Think Different.',
                        style: _display(
                          size: 13 * s,
                          weight: FontWeight.w600,
                          color: _kGold,
                          italic: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '”',
                  style: _display(
                    size: 44 * s,
                    weight: FontWeight.w600,
                    color: _kMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Yakındaki kreatifler ─────────────────────────────────────
  Widget _buildCreativesSection(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeaderRow(s, 'YAKINDAKİ KREATİFLER'),
          SizedBox(height: 16 * s),
          Text(
            'Doğru kişiyi bul,\nprojen büyüsün.',
            style: _display(
              size: 19 * s,
              weight: FontWeight.w500,
              color: _kInk,
              height: 1.2,
            ),
          ),
          SizedBox(height: 18 * s),
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                ClipOval(
                  child: Image.asset(
                    _kNearbyCreatives[i],
                    width: 46 * s,
                    height: 46 * s,
                    fit: BoxFit.cover,
                  ),
                ),
                if (i < 3) SizedBox(width: 10 * s),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── İlham kartı → tam ekran modal (şeffaf overlay, bulanıklık yok) ──
  void _openInspirationModal(BuildContext context, double s) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'İlham',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (_, animation, _, _) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: Center(
              // "İlk attığım görseli %15 daha küçük kullan" — modal, ekran
              // ölçeğinin %85'i ile çiziliyor.
              child: _InspirationModal(scale: s * 0.85),
            ),
          ),
        );
      },
    );
  }
}

// ── Öne çıkan proje satırı ───────────────────────────────────────
class _FeaturedProjectRow extends StatelessWidget {
  const _FeaturedProjectRow({required this.scale, required this.project});
  final double scale;
  final _FeaturedProject project;

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
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14 * s),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              project.index,
              style: _ui(size: 10 * s, color: _kTaupe, spacing: 0.5),
            ),
            SizedBox(width: 16 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.tag,
                    style: _ui(
                      size: 7 * s,
                      weight: FontWeight.w700,
                      color: _kGold,
                      spacing: 1,
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _display(
                      size: 16 * s,
                      weight: FontWeight.w600,
                      color: _kInk,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8 * s),
            Text(
              '${project.people} · ${project.city}',
              style: _ui(size: 8 * s, color: _kTaupe, spacing: 0.3),
            ),
            SizedBox(width: 6 * s),
            Icon(Icons.chevron_right, size: 16 * s, color: _kMuted),
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

// ── Devam eden proje kartı — Projelerim'deki onaylı projenin önizlemesi ─
class _ActiveProjectCard extends StatelessWidget {
  const _ActiveProjectCard({required this.scale, required this.project});

  final double scale;
  final ProjectModel project;

  String get _title =>
      (project.category != null && project.category!.isNotEmpty)
      ? project.category!
      : project.title;

  String get _subtitle => project.shootingType ?? '';

  String get _nextStep => (project.notes != null && project.notes!.isNotEmpty)
      ? project.notes!
      : 'Ekiple iletişimde kal';

  String get _compactBudget {
    final b = project.budget;
    if (b >= 1000) {
      final k = b / 1000;
      final kStr = k == k.roundToDouble()
          ? k.toStringAsFixed(0)
          : k.toStringAsFixed(1);
      return '${kStr}K';
    }
    return b.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    // Kart içeriği "Projeni Başlat" bandına göre biraz büyütülür. Kartın dış
    // kenar boşluğu ise bandınkinden (26*scale) belirgin şekilde daha dar
    // tutulur — kart neredeyse ekran kenarına kadar genişler.
    final s = scale * 1.12;
    final marginH = 6.0 * scale;
    final radius = 0.0;
    final chamfer = 22.0 * s;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: marginH),
      child: GestureDetector(
        // Projelerim sekmesindeki onaylı proje kartıyla aynı detay akışı.
        onTap: () =>
            Get.find<ClientProjectsController>().openProjectDetail(project),
        behavior: HitTestBehavior.opaque,
        child: ClipPath(
          clipper: _CornerChamferClipper(
            radius: radius,
            chamfer: chamfer,
            topRight: true,
            bottomLeft: true,
          ),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                color: _kCardBg,
                padding: EdgeInsets.fromLTRB(24 * s, 20 * s, 24 * s, 6 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'DEVAM EDEN PROJE',
                            style: _ui(
                              size: 8 * s,
                              weight: FontWeight.w700,
                              color: _kGold,
                              spacing: 1.6,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.check_box_outlined,
                          size: 13 * s,
                          color: _kBlack.withValues(alpha: 0.55),
                        ),
                        SizedBox(width: 5 * s),
                        Text(
                          'AKTİF',
                          style: _ui(
                            size: 8 * s,
                            weight: FontWeight.w700,
                            color: _kBlack.withValues(alpha: 0.55),
                            spacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10 * s),
                    Text(
                      _title,
                      style: _display(
                        size: 23 * s,
                        weight: FontWeight.w600,
                        color: _kBlack,
                      ),
                    ),
                    if (_subtitle.isNotEmpty) ...[
                      SizedBox(height: 4 * s),
                      Text(
                        _subtitle,
                        style: _ui(
                          size: 10 * s,
                          color: _kBlack.withValues(alpha: 0.6),
                          spacing: 0.3,
                        ),
                      ),
                    ],
                    SizedBox(height: 18 * s),
                    Row(
                      children: [
                        Expanded(
                          child: _DarkMetaCell(
                            scale: s,
                            label: 'TESLİM',
                            value: project.deliveryTime ?? '—',
                          ),
                        ),
                        Expanded(
                          child: _DarkMetaCell(
                            scale: s,
                            label: 'BÜTÇE',
                            value: _compactBudget,
                          ),
                        ),
                        Expanded(
                          child: _DarkMetaCell(
                            scale: s,
                            label: 'ÇEKİM',
                            value: project.dateRange ?? '—',
                          ),
                        ),
                      ],
                    ),
                    if (project.location != null &&
                        project.location!.isNotEmpty) ...[
                      SizedBox(height: 14 * s),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12 * s,
                            color: _kBlack.withValues(alpha: 0.45),
                          ),
                          SizedBox(width: 5 * s),
                          Text(
                            project.location!,
                            style: _ui(
                              size: 9 * s,
                              color: _kBlack.withValues(alpha: 0.6),
                              spacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 18 * s),
                    Row(
                      children: [
                        Text(
                          'İLERLEME',
                          style: _ui(
                            size: 7 * s,
                            weight: FontWeight.w700,
                            color: _kBlack.withValues(alpha: 0.45),
                            spacing: 1.4,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_kActiveProjectStageIndex/${_kActiveProjectStages.length} AŞAMA',
                          style: _ui(
                            size: 7 * s,
                            weight: FontWeight.w700,
                            color: _kGold,
                            spacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * s),
                    _ProgressStages(
                      scale: s,
                      stages: _kActiveProjectStages,
                      stageIndex: _kActiveProjectStageIndex,
                    ),
                    SizedBox(height: 16 * s),
                    Divider(height: 1, color: _kBlack.withValues(alpha: 0.12)),
                    SizedBox(height: 6 * s),
                    Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'SONRAKİ ADIM · ',
                                  style: _ui(
                                    size: 8 * s,
                                    weight: FontWeight.w700,
                                    color: _kBlack.withValues(alpha: 0.45),
                                    spacing: 0.8,
                                  ),
                                ),
                                TextSpan(
                                  text: _nextStep,
                                  style: _ui(
                                    size: 8 * s,
                                    weight: FontWeight.w700,
                                    color: _kBlack.withValues(alpha: 0.85),
                                    spacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          'DETAY',
                          style: _ui(
                            size: 8 * s,
                            weight: FontWeight.w700,
                            color: _kGold,
                            spacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 4 * s),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 13 * s,
                          color: _kGold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Üst ve alt kenar çizgileri — düz, sağdan soldan eşit mesafeyle ortalı.
              Positioned(
                top: 0,
                left: 24 * s,
                right: 24 * s,
                child: Container(height: 1, color: _kDivider),
              ),
              Positioned(
                bottom: 0,
                left: 24 * s,
                right: 24 * s,
                child: Container(height: 1, color: _kDivider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Kart içi meta hücresi (TESLİM / BÜTÇE / ÇEKİM) ──────────────────────
class _DarkMetaCell extends StatelessWidget {
  const _DarkMetaCell({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _ui(
            size: 7 * s,
            weight: FontWeight.w700,
            color: _kBlack.withValues(alpha: 0.45),
            spacing: 1,
          ),
        ),
        SizedBox(height: 5 * s),
        Text(
          value,
          style: _ui(size: 12 * s, weight: FontWeight.w600, color: _kBlack),
        ),
      ],
    );
  }
}

// ── Aşama ilerleme çubuğu — 5 segment + altında etiketler ──────────────
class _ProgressStages extends StatelessWidget {
  const _ProgressStages({
    required this.scale,
    required this.stages,
    required this.stageIndex,
  });
  final double scale;
  final List<String> stages;
  final int stageIndex;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final count = stages.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < count; i++) ...[
              Expanded(
                child: Container(
                  height: 3 * s,
                  decoration: BoxDecoration(
                    color: i < stageIndex
                        ? _kGold
                        : (i == stageIndex
                              ? _kGold.withValues(alpha: 0.5)
                              : _kBlack.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(2 * s),
                  ),
                ),
              ),
              if (i < count - 1) SizedBox(width: 4 * s),
            ],
          ],
        ),
        SizedBox(height: 6 * s),
        Row(
          children: [
            for (var i = 0; i < count; i++)
              Expanded(
                child: Text(
                  stages[i].toUpperCase(),
                  textAlign: i == 0
                      ? TextAlign.left
                      : (i == count - 1 ? TextAlign.right : TextAlign.center),
                  style: _ui(
                    size: 6 * s,
                    weight: FontWeight.w600,
                    color: i <= stageIndex
                        ? _kBlack.withValues(alpha: 0.75)
                        : _kBlack.withValues(alpha: 0.35),
                    spacing: 0.4,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Köşeleri kısmen kesilmiş ("bilet") dikdörtgen için clipper ─────────
class _CornerChamferClipper extends CustomClipper<Path> {
  const _CornerChamferClipper({
    required this.radius,
    required this.chamfer,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  final double radius;
  final double chamfer;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    if (topLeft) {
      path.moveTo(chamfer, 0);
    } else {
      path.moveTo(radius, 0);
    }

    if (topRight) {
      path.lineTo(w - chamfer, 0);
      path.lineTo(w, chamfer);
    } else {
      path.lineTo(w - radius, 0);
      path.quadraticBezierTo(w, 0, w, radius);
    }

    if (bottomRight) {
      path.lineTo(w, h - chamfer);
      path.lineTo(w - chamfer, h);
    } else {
      path.lineTo(w, h - radius);
      path.quadraticBezierTo(w, h, w - radius, h);
    }

    if (bottomLeft) {
      path.lineTo(chamfer, h);
      path.lineTo(0, h - chamfer);
    } else {
      path.lineTo(radius, h);
      path.quadraticBezierTo(0, h, 0, h - radius);
    }

    if (topLeft) {
      path.lineTo(0, chamfer);
      path.lineTo(chamfer, 0);
    } else {
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _CornerChamferClipper oldClipper) {
    return radius != oldClipper.radius ||
        chamfer != oldClipper.chamfer ||
        topLeft != oldClipper.topLeft ||
        topRight != oldClipper.topRight ||
        bottomLeft != oldClipper.bottomLeft ||
        bottomRight != oldClipper.bottomRight;
  }
}

// ── İlham modalı — "İLHAM" kartına tıklanınca açılan tam kart ────────────
class _InspirationModal extends StatelessWidget {
  const _InspirationModal({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22 * s),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(26 * s, 24 * s, 26 * s, 20 * s),
        decoration: BoxDecoration(
          color: _kCream,
          borderRadius: BorderRadius.circular(22 * s),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '“',
                  style: _display(
                    size: 46 * s,
                    weight: FontWeight.w600,
                    color: _kMuted,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(4 * s),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20 * s,
                      color: _kGold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4 * s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Fark yaratmak,\nfarklı ',
                          style: _display(
                            size: 26 * s,
                            weight: FontWeight.w600,
                            color: _kInk,
                            height: 1.18,
                          ),
                        ),
                        TextSpan(
                          text: 'düşünmekle',
                          style: _display(
                            size: 26 * s,
                            weight: FontWeight.w600,
                            color: _kGold,
                            height: 1.18,
                          ),
                        ),
                        TextSpan(
                          text: '\nbaşlar.',
                          style: _display(
                            size: 26 * s,
                            weight: FontWeight.w600,
                            color: _kInk,
                            height: 1.18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8 * s),
                Transform.translate(
                  offset: Offset(-14 * s, 0),
                  child: Image.asset(
                    'assets/images/page_images/apple.png',
                    width: 128 * s,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            SizedBox(height: 22 * s),
            Text(
              'Vizyondan gerçeğe uzanan her projede, fikirler değişir; dünya dönüşür.',
              style: _ui(size: 12 * s, color: _kBlack, spacing: 0.2),
            ),
            SizedBox(height: 20 * s),
            Divider(height: 1, thickness: 1, color: _kDivider),
            SizedBox(height: 16 * s),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 34 * s,
                  height: 34 * s,
                  child: Image.asset(
                    'assets/images/page_images/apple.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 12 * s),
                Container(width: 1, height: 28 * s, color: _kDivider),
                SizedBox(width: 12 * s),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Apple',
                      style: _display(
                        size: 19 * s,
                        weight: FontWeight.w600,
                        color: _kInk,
                      ),
                    ),
                    Text(
                      'Think Different.',
                      style: _display(
                        size: 13 * s,
                        weight: FontWeight.w600,
                        color: _kGold,
                        italic: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
