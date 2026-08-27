import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/constants/app_assets.dart';

import '../../../../data/models/brief_model.dart';
import '../../../../data/models/project_model.dart';
import '../../../../routes/app_routes.dart';
import '../client_projects_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB); // arka plan (Keşfet ile aynı)
const _kGold = Color(0xFFD9A84E); // kritik / vurgu altın tonu
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kDivider = Color(0x12000000);
const _kCardBorder = Color(0x0F000000);
const _kGreen = Color(0xFF6B8F71); // onaylı proje durumu

// ─── Tipografi yardımcıları ───────────────────────────────────────────────────
TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
  bool italic = false,
}) =>
    AppFonts.display(
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
}) =>
    AppFonts.ui(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: spacing,
    );

// ─────────────────────────────────────────────────────────────────
// TAB
// ─────────────────────────────────────────────────────────────────
class ClientProjectsTab extends StatefulWidget {
  const ClientProjectsTab({super.key});

  @override
  State<ClientProjectsTab> createState() => _ClientProjectsTabState();
}

class _ClientProjectsTabState extends State<ClientProjectsTab> {
  int _filterIndex = 0;

  static const _filterLabels = [
    'TÜMÜ',
    'AKTİF PROJELER',
    'TEKLİF AŞAMASINDA',
    'ANLAŞMA BEKLİYOR',
    'SET HALLETSİN',
  ];
  static const _filterStatus = <String?>[
    null,
    null,
    'offer_sent',
    'submitted',
    null,
  ];
  static const _activeFilterIndex = 1;
  static const _setFilterIndex = 4;

  List<BriefModel> _apply(List<BriefModel> all) {
    if (_filterIndex == _activeFilterIndex || _filterIndex == _setFilterIndex) {
      return [];
    }
    // Kabul edilip projeye dönüşen brief'ler artık ONAYLI PROJE kartı
    // olarak gösteriliyor; iptal edilenler ise kapanmış sayılır — ikisi de
    // burada tekrar gösterilmesin.
    final base = all
        .where((b) => b.status != 'accepted' && b.status != 'cancelled')
        .toList();
    final st = _filterStatus[_filterIndex];
    if (st == null) return base;
    return base.where((b) => b.status == st).toList();
  }

  // Aktif projeler "TÜMÜ", "AKTİF PROJELER" ve "SET HALLETSİN"
  // filtrelerinde gösterilir — SET Halletsin, aynı aktif projelerin
  // SET tarafından yürütülen takip ekranına önizlemesidir.
  List<ProjectModel> _activeProjects(ClientProjectsController controller) {
    if (_filterIndex != 0 &&
        _filterIndex != _activeFilterIndex &&
        _filterIndex != _setFilterIndex) {
      return [];
    }
    return controller.projects
        .where((p) => p.status == ProjectStatus.active)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientProjectsController>();
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopStrip(s),
              SizedBox(height: 18 * s),
              _buildHeader(s, controller),
              SizedBox(height: 20 * s),
              _buildFilterBar(s),
              SizedBox(height: 8 * s),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: _kGold),
                    );
                  }
                  if (controller.errorMsg.isNotEmpty) {
                    return _ErrorView(
                        scale: s, onRetry: controller.loadBriefs);
                  }
                  final briefs = _apply(controller.briefs);
                  final activeProjects = _activeProjects(controller);
                  if (briefs.isEmpty && activeProjects.isEmpty) {
                    return _EmptyState(scale: s);
                  }
                  // SET Halletsin kartı, kendi sekmesinde olduğu gibi
                  // "TÜMÜ" sekmesinde de gösterilir.
                  final isSetTab =
                      _filterIndex == _setFilterIndex || _filterIndex == 0;
                  return RefreshIndicator(
                    color: _kGold,
                    onRefresh: controller.loadBriefs,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(0, 6 * s, 0, 30 * s),
                      children: [
                        for (var i = 0; i < activeProjects.length; i++) ...[
                          isSetTab
                              ? _SetProjectCard(
                                  scale: s, project: activeProjects[i])
                              : _ProjectCard(
                                  scale: s, project: activeProjects[i]),
                          if (i < activeProjects.length - 1 ||
                              briefs.isNotEmpty)
                            SizedBox(height: 18 * s),
                        ],
                        for (var i = 0; i < briefs.length; i++) ...[
                          _BriefCard(scale: s, brief: briefs[i]),
                          if (i < briefs.length - 1)
                            SizedBox(height: 18 * s),
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sayfa tepesi — SET · PROJELERİM + tam genişlik ayraç ──────────
  Widget _buildTopStrip(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(26 * s, 6 * s, 26 * s, 12 * s),
          child: Text(
            'SET · PROJELERİM',
            style: _ui(size: 8 * s, color: _kBlack, spacing: 2),
          ),
        ),
        Container(height: 1, color: _kDivider),
      ],
    );
  }

  // ── Header ──────────────────────────────────────────────────────
  Widget _buildHeader(double s, ClientProjectsController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(26 * s, 0, 18 * s, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Projelerim',
                  style: _display(
                      size: 40 * s, weight: FontWeight.w600, color: _kInk),
                ),
                SizedBox(height: 6 * s),
                Obx(() {
                  final count = _apply(controller.briefs).length +
                      _activeProjects(controller).length;
                  return Text(
                    '$count proje görüntüleniyor',
                    style: _ui(size: 8 * s, color: _kBlack, spacing: 0.5),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Filtre sekmeleri (Keşfet ekranındaki widget ile aynı tasarım) ─
  Widget _buildFilterBar(double s) {
    return SizedBox(
      height: 40 * s,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24 * s),
        children: List.generate(_filterLabels.length, (i) {
          final selected = i == _filterIndex;
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(right: 26 * s),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Container(
                      width: 4 * s,
                      height: 4 * s,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6 * s),
                  ],
                  Text(
                    _filterLabels[i],
                    style: _ui(
                      size: 9 * s,
                      weight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: _kBlack,
                      spacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

}

// ─── Sinyal gibi yanıp sönen durum noktası ─────────────────────────
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, this.size = 8});
  final Color color;
  final double size;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(begin: 0.25, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ACTIVE PROJECT CARD — anlaşılan ve devam eden projeler (ProjectRepository).
// Görünüm olarak BRIEF CARD ile birebir aynıdır; yalnızca durum
// etiketi/rengi ve "REVİZE ET" yerine proje detayına yönlendirme değişir.
// ─────────────────────────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.scale, required this.project});

  final double scale;
  final ProjectModel project;

  String get _bigTitle {
    final cat = project.category ?? '';
    return cat.isNotEmpty ? cat : project.title;
  }

  String get _subtitle => project.shootingType ?? '';

  String get _categoryAsset {
    final cat = (project.category ?? '').toLowerCase();
    if (cat.contains('video') || cat.contains('film')) {
      return 'assets/images/main_service_icons/video.png';
    } else if (cat.contains('fotoğraf') || cat.contains('photo')) {
      return 'assets/images/main_service_icons/foto.png';
    } else if (cat.contains('ses') || cat.contains('müzik')) {
      return 'assets/images/main_service_icons/ses.png';
    } else if (cat.contains('cgi') || cat.contains('vfx')) {
      return 'assets/images/main_service_icons/cgi.png';
    } else if (cat.contains('kurgu') || cat.contains('montaj')) {
      return 'assets/images/main_service_icons/kurgu.png';
    } else if (cat.contains('sosyal')) {
      return 'assets/images/main_service_icons/sosyal medya.png';
    }
    return 'assets/images/main_service_icons/grafiktasarim.png';
  }

  IconData get _categoryIcon {
    final cat = (project.category ?? '').toLowerCase();
    if (cat.contains('video') || cat.contains('film')) {
      return Icons.videocam_rounded;
    } else if (cat.contains('fotoğraf') || cat.contains('photo')) {
      return Icons.camera_alt_rounded;
    } else if (cat.contains('ses') || cat.contains('müzik')) {
      return Icons.music_note_rounded;
    } else if (cat.contains('cgi') || cat.contains('vfx')) {
      return Icons.auto_awesome_rounded;
    }
    return Icons.work_rounded;
  }

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
    final s = scale;
    return GestureDetector(
      onTap: () =>
          Get.find<ClientProjectsController>().openProjectDetail(project),
      child: Container(
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
            // Durum satırı
            Padding(
              padding: EdgeInsets.fromLTRB(42 * s, 16 * s, 38 * s, 0),
              child: Row(
                children: [
                  _PulsingDot(color: _kGreen, size: 8 * s),
                  SizedBox(width: 8 * s),
                  Text(
                    'ONAYLI PROJE',
                    style: _ui(
                        size: 8 * s,
                        weight: FontWeight.w700,
                        color: _kBlack,
                        spacing: 1.4),
                  ),
                ],
              ),
            ),

            // Kimlik satırı
            Padding(
              padding: EdgeInsets.fromLTRB(42 * s, 16 * s, 42 * s, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48 * s,
                    height: 48 * s,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      _categoryAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                          _categoryIcon,
                          size: 22 * s,
                          color: _kGold),
                    ),
                  ),
                  SizedBox(width: 14 * s),
                  Expanded(
                    child: SizedBox(
                      height: 48 * s,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _bigTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _display(
                                size: 20 * s,
                                weight: FontWeight.w600,
                                color: _kInk),
                          ),
                          if (_subtitle.isNotEmpty) ...[
                            SizedBox(height: 3 * s),
                            Text(
                              _subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _ui(
                                  size: 8 * s, color: _kBlack, spacing: 1),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Meta satırı (teslim / bütçe / çekim)
            if (project.deliveryTime != null || project.dateRange != null) ...[
              SizedBox(height: 18 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 42 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _MetaCell(
                        scale: s,
                        icon: Icons.schedule_rounded,
                        label: 'TESLİM',
                        value: project.deliveryTime ?? '—',
                      ),
                    ),
                    Expanded(
                      child: _MetaCell(
                        scale: s,
                        icon: Icons.payments_outlined,
                        label: 'BÜTÇE',
                        value: _compactBudget,
                      ),
                    ),
                    Expanded(
                      child: _MetaCell(
                        scale: s,
                        icon: Icons.calendar_today_rounded,
                        label: 'ÇEKİM',
                        value: project.dateRange ?? '—',
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Konum
            if (project.location != null && project.location!.isNotEmpty) ...[
              SizedBox(height: 24 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 42 * s),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13 * s, color: _kTaupe),
                    SizedBox(width: 5 * s),
                    Expanded(
                      child: Text(
                        project.location!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _ui(size: 9 * s, color: _kBlack, spacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Açıklama + Detay
            SizedBox(height: 14 * s),
            Padding(
              padding: EdgeInsets.fromLTRB(42 * s, 0, 38 * s, 16 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (project.notes != null && project.notes!.isNotEmpty) ...[
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 13 * s, color: _kTaupe),
                    SizedBox(width: 5 * s),
                    Expanded(
                      child: Text(
                        project.notes!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _ui(
                            size: 9 * s,
                            weight: FontWeight.w700,
                            color: _kInk,
                            spacing: 0.2),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                  ] else
                    const Spacer(),
                  Text(
                    'DETAY',
                    style: _ui(
                        size: 8 * s,
                        weight: FontWeight.w700,
                        color: _kGold,
                        spacing: 1.2),
                  ),
                  SizedBox(width: 4 * s),
                  Icon(Icons.chevron_right, size: 16 * s, color: _kGold),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SET HALLETSİN CARD — "SET Halletsin" sekmesinde aktif projelerin SET
// tarafından yürütülen takip ekranına önizlemesi. ACTIVE PROJECT CARD ile
// aynı düzeni kullanır; yalnızca durum etiketi/rengi, sağ üst SET rozeti
// ve dokunma hedefi (proje detayı yerine SET takip sayfası) değişir.
// ─────────────────────────────────────────────────────────────────
class _SetProjectCard extends StatelessWidget {
  const _SetProjectCard({required this.scale, required this.project});

  final double scale;
  final ProjectModel project;

  String get _bigTitle {
    final cat = project.category ?? '';
    return cat.isNotEmpty ? cat : project.title;
  }

  String get _subtitle => project.shootingType ?? '';

  String get _categoryAsset {
    final cat = (project.category ?? '').toLowerCase();
    if (cat.contains('video') || cat.contains('film')) {
      return 'assets/images/main_service_icons/video.png';
    } else if (cat.contains('fotoğraf') || cat.contains('photo')) {
      return 'assets/images/main_service_icons/foto.png';
    } else if (cat.contains('ses') || cat.contains('müzik')) {
      return 'assets/images/main_service_icons/ses.png';
    } else if (cat.contains('cgi') || cat.contains('vfx')) {
      return 'assets/images/main_service_icons/cgi.png';
    } else if (cat.contains('kurgu') || cat.contains('montaj')) {
      return 'assets/images/main_service_icons/kurgu.png';
    } else if (cat.contains('sosyal')) {
      return 'assets/images/main_service_icons/sosyal medya.png';
    }
    return 'assets/images/main_service_icons/grafiktasarim.png';
  }

  IconData get _categoryIcon {
    final cat = (project.category ?? '').toLowerCase();
    if (cat.contains('video') || cat.contains('film')) {
      return Icons.videocam_rounded;
    } else if (cat.contains('fotoğraf') || cat.contains('photo')) {
      return Icons.camera_alt_rounded;
    } else if (cat.contains('ses') || cat.contains('müzik')) {
      return Icons.music_note_rounded;
    } else if (cat.contains('cgi') || cat.contains('vfx')) {
      return Icons.auto_awesome_rounded;
    }
    return Icons.work_rounded;
  }

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
    final s = scale;
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.setProjects),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: _kCardBorder),
            bottom: BorderSide(color: _kCardBorder),
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Durum satırı
                Padding(
                  padding: EdgeInsets.fromLTRB(42 * s, 16 * s, 38 * s, 0),
                  child: Row(
                    children: [
                      _PulsingDot(color: _kGold, size: 8 * s),
                      SizedBox(width: 8 * s),
                      Text(
                        'SET HALLEDİYOR',
                        style: _ui(
                            size: 8 * s,
                            weight: FontWeight.w700,
                            color: _kBlack,
                            spacing: 1.4),
                      ),
                    ],
                  ),
                ),

                // Kimlik satırı
                Padding(
                  padding: EdgeInsets.fromLTRB(42 * s, 16 * s, 42 * s, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48 * s,
                        height: 48 * s,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          _categoryAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              _categoryIcon,
                              size: 22 * s,
                              color: _kGold),
                        ),
                      ),
                      SizedBox(width: 14 * s),
                      Expanded(
                        child: SizedBox(
                          height: 48 * s,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _bigTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _display(
                                    size: 20 * s,
                                    weight: FontWeight.w600,
                                    color: _kInk),
                              ),
                              if (_subtitle.isNotEmpty) ...[
                                SizedBox(height: 3 * s),
                                Text(
                                  _subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _ui(
                                      size: 8 * s, color: _kBlack, spacing: 1),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Meta satırı (teslim / bütçe / çekim)
                if (project.deliveryTime != null ||
                    project.dateRange != null) ...[
                  SizedBox(height: 18 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 42 * s),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _MetaCell(
                            scale: s,
                            icon: Icons.schedule_rounded,
                            label: 'TESLİM',
                            value: project.deliveryTime ?? '—',
                          ),
                        ),
                        Expanded(
                          child: _MetaCell(
                            scale: s,
                            icon: Icons.payments_outlined,
                            label: 'BÜTÇE',
                            value: _compactBudget,
                          ),
                        ),
                        Expanded(
                          child: _MetaCell(
                            scale: s,
                            icon: Icons.calendar_today_rounded,
                            label: 'ÇEKİM',
                            value: project.dateRange ?? '—',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Konum
                if (project.location != null &&
                    project.location!.isNotEmpty) ...[
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 42 * s),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 13 * s, color: _kTaupe),
                        SizedBox(width: 5 * s),
                        Expanded(
                          child: Text(
                            project.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                _ui(size: 9 * s, color: _kBlack, spacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Açıklama + Detay
                SizedBox(height: 14 * s),
                Padding(
                  padding: EdgeInsets.fromLTRB(42 * s, 0, 38 * s, 16 * s),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (project.notes != null &&
                          project.notes!.isNotEmpty) ...[
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 13 * s, color: _kTaupe),
                        SizedBox(width: 5 * s),
                        Expanded(
                          child: Text(
                            project.notes!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _ui(
                                size: 9 * s,
                                weight: FontWeight.w700,
                                color: _kInk,
                                spacing: 0.2),
                          ),
                        ),
                        SizedBox(width: 8 * s),
                      ] else
                        const Spacer(),
                      Text(
                        'DETAY',
                        style: _ui(
                            size: 8 * s,
                            weight: FontWeight.w700,
                            color: _kGold,
                            spacing: 1.2),
                      ),
                      SizedBox(width: 4 * s),
                      Icon(Icons.chevron_right, size: 16 * s, color: _kGold),
                    ],
                  ),
                ),
              ],
            ),
            // Sağ üst SET rozeti
            Positioned(
              top: 12 * s,
              right: 12 * s,
              child: SizedBox(
                width: 36 * s,
                height: 36 * s,
                child: Image.asset(AppAssets.loginLogo, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BRIEF CARD
// ─────────────────────────────────────────────────────────────────
class _BriefCard extends StatelessWidget {
  const _BriefCard({required this.scale, required this.brief});

  final double scale;
  final BriefModel brief;

  String get _statusLabel {
    switch (brief.status) {
      case 'offer_sent':
        return 'TEKLİF AŞAMASINDA';
      case 'submitted':
        return 'ANLAŞMA BEKLİYOR';
      default:
        return 'TASLAK';
    }
  }

  Color get _statusColor {
    switch (brief.status) {
      case 'offer_sent':
        return _kBlack;
      case 'submitted':
        return _kGold;
      default:
        return _kMuted;
    }
  }

  String get _bigTitle =>
      brief.category.isNotEmpty ? brief.category : brief.title;

  String get _subtitle => brief.answers.shootingType ?? '';

  String get _categoryAsset {
    final cat = brief.category.toLowerCase();
    if (cat.contains('video') || cat.contains('film')) {
      return 'assets/images/main_service_icons/video.png';
    } else if (cat.contains('fotoğraf') || cat.contains('photo')) {
      return 'assets/images/main_service_icons/foto.png';
    } else if (cat.contains('ses') || cat.contains('müzik')) {
      return 'assets/images/main_service_icons/ses.png';
    } else if (cat.contains('cgi') || cat.contains('vfx')) {
      return 'assets/images/main_service_icons/cgi.png';
    } else if (cat.contains('kurgu') || cat.contains('montaj')) {
      return 'assets/images/main_service_icons/kurgu.png';
    } else if (cat.contains('sosyal')) {
      return 'assets/images/main_service_icons/sosyal medya.png';
    }
    return 'assets/images/main_service_icons/grafiktasarim.png';
  }

  IconData get _categoryIcon {
    final cat = brief.category.toLowerCase();
    if (cat.contains('video') || cat.contains('film')) {
      return Icons.videocam_rounded;
    } else if (cat.contains('fotoğraf') || cat.contains('photo')) {
      return Icons.camera_alt_rounded;
    } else if (cat.contains('ses') || cat.contains('müzik')) {
      return Icons.music_note_rounded;
    } else if (cat.contains('cgi') || cat.contains('vfx')) {
      return Icons.auto_awesome_rounded;
    }
    return Icons.work_rounded;
  }

  // "50.000₺ - 120.000₺" -> "50K-120K", "300.000₺+" -> "300K+"
  String _compactBudget(String raw) {
    final matches =
        RegExp(r'\d[\d.]*').allMatches(raw).map((m) => m.group(0)!).toList();
    if (matches.isEmpty) return raw;
    final parts = matches.map((numStr) {
      final n = int.tryParse(numStr.replaceAll('.', '')) ?? 0;
      if (n >= 1000) {
        final k = n / 1000;
        final kStr =
            k == k.roundToDouble() ? k.toStringAsFixed(0) : k.toStringAsFixed(1);
        return '${kStr}K';
      }
      return numStr;
    }).toList();
    return parts.join('-') + (raw.contains('+') ? '+' : '');
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.briefDetail, arguments: {'brief': brief}),
      child: Container(
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
            // Durum satırı
            Padding(
              padding: EdgeInsets.fromLTRB(42 * s, 16 * s, 38 * s, 0),
              child: Row(
                children: [
                  _PulsingDot(color: _statusColor, size: 8 * s),
                  SizedBox(width: 8 * s),
                  Text(
                    _statusLabel,
                    style: _ui(
                        size: 8 * s,
                        weight: FontWeight.w700,
                        color: _kBlack,
                        spacing: 1.4),
                  ),
                ],
              ),
            ),

            // Kimlik satırı
            Padding(
              padding: EdgeInsets.fromLTRB(42 * s, 16 * s, 42 * s, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48 * s,
                    height: 48 * s,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      _categoryAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                          _categoryIcon,
                          size: 22 * s,
                          color: _kGold),
                    ),
                  ),
                  SizedBox(width: 14 * s),
                  Expanded(
                    child: SizedBox(
                      height: 48 * s,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _bigTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _display(
                                size: 20 * s,
                                weight: FontWeight.w600,
                                color: _kInk),
                          ),
                          if (_subtitle.isNotEmpty) ...[
                            SizedBox(height: 3 * s),
                            Text(
                              _subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _ui(
                                  size: 8 * s, color: _kBlack, spacing: 1),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (brief.sentToIds.isNotEmpty) ...[
                    SizedBox(width: 10 * s),
                    Text(
                      '${brief.sentToIds.length}',
                      style: _display(
                          size: 25 * s,
                          weight: FontWeight.w700,
                          color: _kGold),
                    ),
                  ],
                ],
              ),
            ),

            // Meta satırı (teslim / bütçe / çekim)
            if (brief.answers.deliveryTime != null ||
                brief.answers.budget != null ||
                brief.answers.dateRange != null) ...[
              SizedBox(height: 18 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 42 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _MetaCell(
                        scale: s,
                        icon: Icons.schedule_rounded,
                        label: 'TESLİM',
                        value: brief.answers.deliveryTime ?? '—',
                      ),
                    ),
                    Expanded(
                      child: _MetaCell(
                        scale: s,
                        icon: Icons.payments_outlined,
                        label: 'BÜTÇE',
                        value: brief.answers.budget != null
                            ? _compactBudget(brief.answers.budget!)
                            : '—',
                      ),
                    ),
                    Expanded(
                      child: _MetaCell(
                        scale: s,
                        icon: Icons.calendar_today_rounded,
                        label: 'ÇEKİM',
                        value: brief.answers.dateRange ?? '—',
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Konum
            if (brief.answers.location != null &&
                brief.answers.location!.isNotEmpty) ...[
              SizedBox(height: 24 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 42 * s),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13 * s, color: _kTaupe),
                    SizedBox(width: 5 * s),
                    Expanded(
                      child: Text(
                        brief.answers.location!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _ui(size: 9 * s, color: _kBlack, spacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Açıklama + Revize Et
            if (brief.answers.notes != null &&
                brief.answers.notes!.isNotEmpty) ...[
              SizedBox(height: 14 * s),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.briefDetail,
                    arguments: {'brief': brief}),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(42 * s, 0, 38 * s, 16 * s),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 13 * s, color: _kTaupe),
                      SizedBox(width: 5 * s),
                      Expanded(
                        child: Text(
                          brief.answers.notes!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _ui(
                              size: 9 * s,
                              weight: FontWeight.w700,
                              color: _kInk,
                              spacing: 0.2),
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Text(
                        'REVİZE ET',
                        style: _ui(
                            size: 8 * s,
                            weight: FontWeight.w700,
                            color: _kGold,
                            spacing: 1.2),
                      ),
                      SizedBox(width: 4 * s),
                      Icon(Icons.chevron_right,
                          size: 16 * s, color: _kGold),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Alt bilgi
              SizedBox(height: 18 * s),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.briefDetail,
                    arguments: {'brief': brief}),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(42 * s, 12 * s, 38 * s, 14 * s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'REVİZE ET',
                        style: _ui(
                            size: 8 * s,
                            weight: FontWeight.w700,
                            color: _kGold,
                            spacing: 1.2),
                      ),
                      SizedBox(width: 4 * s),
                      Icon(Icons.chevron_right,
                          size: 16 * s, color: _kGold),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Meta hücresi ─────────────────────────────────────────────────
class _MetaCell extends StatelessWidget {
  const _MetaCell({
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
            Text(
              label,
              style: _ui(size: 7 * s, color: _kBlack, spacing: 1),
            ),
          ],
        ),
        SizedBox(height: 5 * s),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _ui(
              size: 10 * s, weight: FontWeight.w400, color: _kBlack, spacing: 0.3),
        ),
      ],
    );
  }
}

// ─── Boş durum ────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68 * s,
            height: 68 * s,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
            ),
            child: Icon(Icons.folder_open_rounded,
                size: 30 * s, color: _kMuted),
          ),
          SizedBox(height: 18 * s),
          Text(
            'Henüz proje yok',
            style: _display(size: 22 * s, weight: FontWeight.w600, color: _kInk),
          ),
          SizedBox(height: 6 * s),
          Text(
            'Brief gönderdikten sonra buraya düşer.',
            style: _ui(size: 9 * s, color: _kBlack, spacing: 0.3),
          ),
        ],
      ),
    );
  }
}

// ─── Hata durumu ──────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.scale, required this.onRetry});
  final double scale;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Projeler yüklenemedi',
            style: _display(size: 22 * s, weight: FontWeight.w600, color: _kInk),
          ),
          SizedBox(height: 12 * s),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 10 * s),
              decoration: BoxDecoration(
                color: _kInk,
                borderRadius: BorderRadius.zero,
              ),
              child: Text(
                'TEKRAR DENE',
                style: _ui(
                    size: 9 * s,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    spacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
