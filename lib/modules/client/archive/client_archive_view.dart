import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/dummy/dummy_data.dart';
import '../../../data/models/portfolio_project_model.dart';
import '../../../routes/app_routes.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kBlack = Color(0xFF000000);
const _kTaupe = Color(0xFF9B8E7B);
const _kDivider = Color(0x12000000);

TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
}) => AppFonts.display(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
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

// Kapak görseli girilmemiş dummy projeler için sırayla kullanılan
// yer tutucu görseller (elimizdeki tek gerçek prodüksiyon fotoğraf seti).
const _kFallbackCovers = [
  AppAssets.portfolioMercedesBg,
  ...AppAssets.portfolioMercedesGallery,
];

// Proje etiketinden basit bir arşiv filtresi kovası çıkarır.
String _bucketFor(PortfolioProjectModel p) {
  final tag = p.tagLabel.toUpperCase();
  if (tag.contains('REKLAM')) return 'REKLAM';
  if (tag.contains('BELGESEL')) return 'BELGESEL';
  if (tag.contains('KLİP') || tag.contains('MÜZİK')) return 'KLİP';
  if (tag.contains('KURUMSAL')) return 'KURUMSAL';
  return 'TANITIM';
}

class ClientArchiveView extends StatefulWidget {
  const ClientArchiveView({super.key});

  @override
  State<ClientArchiveView> createState() => _ClientArchiveViewState();
}

class _ClientArchiveViewState extends State<ClientArchiveView> {
  static const _filters = [
    'TÜMÜ',
    'REKLAM',
    'TANITIM',
    'KLİP',
    'KURUMSAL',
    'BELGESEL',
  ];
  int _filterIndex = 0;

  List<PortfolioProjectModel> get _filtered {
    final all = DummyData.portfolioProjects;
    if (_filterIndex == 0) return all;
    final label = _filters[_filterIndex];
    return all.where((p) => _bucketFor(p) == label).toList();
  }

  String _coverFor(PortfolioProjectModel p, int i) =>
      p.coverImageUrl ?? _kFallbackCovers[i % _kFallbackCovers.length];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();
    final projects = _filtered;

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopStrip(s),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 40 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 22 * s),
                      _buildHeader(s),
                      SizedBox(height: 22 * s),
                      _buildFilterBar(s),
                      SizedBox(height: 4 * s),
                      Container(height: 1, color: _kDivider),
                      SizedBox(height: 20 * s),
                      for (var i = 0; i < projects.length; i++) ...[
                        _ArchiveListCard(
                          scale: s,
                          project: projects[i],
                          cover: _coverFor(projects[i], i),
                          index: i + 1,
                        ),
                        SizedBox(height: 22 * s),
                      ],
                      if (projects.isEmpty) _buildEmpty(s),
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

  Widget _buildTopStrip(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(26 * s, 6 * s, 26 * s, 12 * s),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                behavior: HitTestBehavior.opaque,
                child: Icon(Icons.arrow_back_rounded, size: 20 * s, color: _kInk),
              ),
              const Spacer(),
              Text(
                'SET · ARŞİV',
                style: _ui(size: 10 * s, color: _kBlack, spacing: 2),
              ),
            ],
          ),
        ),
        Container(height: 1, color: _kDivider),
      ],
    );
  }

  Widget _buildHeader(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'SET\nİMZALI',
                  style: _display(size: 40 * s, weight: FontWeight.w700, color: _kBlack, height: 1),
                ),
                TextSpan(
                  text: '.',
                  style: _display(size: 40 * s, weight: FontWeight.w700, color: _kGold, height: 1),
                ),
              ],
            ),
          ),
          SizedBox(height: 12 * s),
          Text(
            'Bünyemizde tamamlanan ${DummyData.portfolioProjects.length} proje.',
            style: _ui(size: 11 * s, color: _kTaupe, spacing: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(double s) {
    return SizedBox(
      height: 26 * s,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 26 * s),
        children: List.generate(_filters.length, (i) {
          final selected = i == _filterIndex;
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(right: 24 * s),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Container(
                      width: 4 * s,
                      height: 4 * s,
                      decoration: const BoxDecoration(
                        color: _kGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6 * s),
                  ],
                  Text(
                    _filters[i],
                    style: _ui(
                      size: 10 * s,
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

  Widget _buildEmpty(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26 * s, vertical: 40 * s),
      child: Text(
        'Bu kategoride henüz proje yok.',
        style: _ui(size: 10 * s, color: _kTaupe, spacing: 0.3),
      ),
    );
  }
}

// ── Arşiv kartı + altındaki "0X ── İNCELE" satırı ─────────────────
class _ArchiveListCard extends StatelessWidget {
  const _ArchiveListCard({
    required this.scale,
    required this.project,
    required this.cover,
    required this.index,
  });

  final double scale;
  final PortfolioProjectModel project;
  final String cover;
  final int index;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    void openDetail() => Get.toNamed(
          AppRoutes.portfolioProjectDetail,
          arguments: {'project': project},
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: openDetail,
          behavior: HitTestBehavior.opaque,
          child: AspectRatio(
            aspectRatio: 2.1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(cover, fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.4, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 22 * s,
                  right: 22 * s,
                  bottom: 18 * s,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.title.replaceAll('\n', ' '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _display(
                                size: 22 * s,
                                weight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4 * s),
                            Text(
                              '${_bucketFor(project)} · ${project.year}',
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
                      Text(
                        '${project.team.length} KİŞİ · ${project.durationLabel}',
                        style: _ui(
                          size: 9 * s,
                          weight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85),
                          spacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12 * s),
        GestureDetector(
          onTap: openDetail,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 26 * s),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  index.toString().padLeft(2, '0'),
                  style: _ui(
                    size: 10 * s,
                    weight: FontWeight.w700,
                    color: _kGold,
                    spacing: 0.5,
                  ),
                ),
                SizedBox(width: 14 * s),
                Expanded(child: Container(height: 1, color: _kDivider)),
                SizedBox(width: 14 * s),
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
    );
  }
}
