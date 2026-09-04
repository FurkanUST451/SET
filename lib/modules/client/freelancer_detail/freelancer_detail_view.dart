import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/constants/app_assets.dart';
import '../../../data/models/freelancer_model.dart';
import '../../../widgets/video_viewer_page.dart';
import '../freelancers_by_category/freelancers_by_category_controller.dart';
import 'freelancer_detail_controller.dart';
import '../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kBlack = Color(0xFF000000);
const _kDivider = Color(0x12000000);
const _kDark = Color(0xFF141219);
const _kGreen = Color(0xFF6B8F71);

const Map<String, String> _kCategoryRoleLabel = {
  'Video Çekim': 'GÖRÜNTÜ YÖNETMENİ',
  'Kurgu': 'KURGU YÖNETMENİ',
  'Ses Tasarımı': 'SES TASARIMCISI',
  'CGI & VFX': 'CGI SANATÇISI',
  'Fotoğraf': 'FOTOĞRAFÇI',
  'Sosyal Medya Yönetimi': 'İÇERİK YÖNETMENİ',
  'Grafik Tasarım': 'GRAFİK TASARIMCI',
};

double _scaleOf(BuildContext c) =>
    (MediaQuery.sizeOf(c).width / 390).clamp(0.85, 1.15).toDouble();

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
  double height = 1.4,
}) => AppFonts.ui(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
  height: height,
  decoration: TextDecoration.none,
);

// Deneyime göre gösterimlik ücret aralığı — freelancer listesindeki
// hesaplamayla aynı (bkz. freelancers_by_category_view.dart).
(int, int) _feeRangeBoundsFor(FreelancerModel? f) {
  final exp = f?.experience ?? 3;
  if (exp >= 15) return (25, 500);
  if (exp >= 8) return (15, 250);
  if (exp >= 3) return (8, 120);
  return (2, 50);
}

String? _youtubeId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  if (uri.host.contains('youtu.be')) return uri.pathSegments.firstOrNull;
  if (uri.host.contains('youtube.com')) {
    if (uri.pathSegments.contains('shorts') && uri.pathSegments.length > 1) {
      return uri.pathSegments[uri.pathSegments.indexOf('shorts') + 1];
    }
    return uri.queryParameters['v'];
  }
  return null;
}

String? _youtubeThumbnail(String url) {
  final id = _youtubeId(url);
  return id != null ? 'https://img.youtube.com/vi/$id/mqdefault.jpg' : null;
}

void _openVideo(String url, String title) {
  Navigator.of(Get.context!).push(
    MaterialPageRoute(
      builder: (_) => VideoViewerPage(videoUrl: url, title: title),
    ),
  );
}

class FreelancerDetailView extends GetView<FreelancerDetailController> {
  const FreelancerDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = _scaleOf(context);
    final f = controller.freelancer;
    final u = controller.user;
    final fName = f?.name.isNotEmpty == true ? f!.name : (u?.name ?? '');
    final fSurname =
        (f?.surname?.isNotEmpty == true) ? f!.surname! : (u?.surname ?? '');
    final name = fSurname.isNotEmpty
        ? '$fName $fSurname'
        : (fName.isNotEmpty ? fName : 'Freelancer');

    final jobCount = (f?.experience ?? 3) * 12 + 15;
    final reviewCount = (f?.experience ?? 3) * 18;
    final primaryCategory =
        f?.categories.isNotEmpty == true ? f!.categories.first : '';
    final role = _kCategoryRoleLabel[primaryCategory] ?? 'KREATİF';
    final (feeLo, feeHi) = _feeRangeBoundsFor(f);

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(scale: s),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 130 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 34 * s),
                      _IdentityRow(
                        scale: s,
                        freelancer: f,
                        user: u,
                        name: name,
                        role: role,
                      ),
                      SizedBox(height: 34 * s),
                      _StatsRow(
                        scale: s,
                        rating: f?.rating ?? 4.9,
                        jobCount: jobCount,
                      ),
                      SizedBox(height: 22 * s),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * s),
                        child: Container(height: 1, color: _kDivider),
                      ),
                      SizedBox(height: 22 * s),
                      _SectionLabel(scale: s, label: 'KENDİ SÖZLERİYLE'),
                      SizedBox(height: 10 * s),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * s),
                        child: Text(
                          (f?.bio.isNotEmpty == true)
                              ? f!.bio
                              : 'Bu kreatif henüz kendi sözlerini eklemedi.',
                          style: _ui(
                            size: 14 * s,
                            color: _kBlack,
                            spacing: 0.2,
                            height: 1.6,
                          ),
                        ),
                      ),
                      SizedBox(height: 26 * s),
                      _FitSection(scale: s, feeLo: feeLo, feeHi: feeHi, name: name),
                      SizedBox(height: 26 * s),
                      _SectionLabel(scale: s, label: 'UZMANLIK'),
                      SizedBox(height: 12 * s),
                      _ExpertiseGrid(scale: s, freelancer: f, role: role),
                      SizedBox(height: 30 * s),
                      _WorksSection(
                        scale: s,
                        freelancer: f,
                        jobCount: jobCount,
                      ),
                      SizedBox(height: 30 * s),
                      _CollaboratorsSection(
                        scale: s,
                        freelancer: f,
                        jobCount: jobCount,
                      ),
                      SizedBox(height: 30 * s),
                      _ReviewsSection(scale: s, reviewCount: reviewCount),
                      SizedBox(height: 30 * s),
                      _WorkStyleSection(scale: s),
                      SizedBox(height: 30 * s),
                      _AvailabilitySection(scale: s),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _SelectionBar(
        scale: s,
        name: name,
        role: role,
        feeLo: feeLo,
        feeHi: feeHi,
        avatarUrl: f?.profileImageUrl ?? AppAssets.profilePhotosMale[4],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10 * s, 6 * s, 24 * s, 12 * s),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back<void>(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(8 * s),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20 * s,
                    color: _kInk,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'SET · PROFİL',
                style: _ui(size: 10 * s, color: _kBlack, spacing: 2),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Container(height: 1, color: _kDivider),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// KİMLİK — köşe bantlı fotoğraf + müsaitlik/ad/rol/konum
// ─────────────────────────────────────────────────────────────────
class _IdentityRow extends StatelessWidget {
  const _IdentityRow({
    required this.scale,
    required this.freelancer,
    required this.user,
    required this.name,
    required this.role,
  });

  final double scale;
  final FreelancerModel? freelancer;
  final dynamic user;
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final photo = freelancer?.profileImageUrl ?? AppAssets.profilePhotosMale[4];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100 * s,
            height: 130 * s,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Image.asset(photo, fit: BoxFit.cover),
                ),
                Positioned(
                  top: -8 * s,
                  left: -8 * s,
                  child: _CornerMark(scale: s, top: true, left: true),
                ),
                Positioned(
                  top: -8 * s,
                  right: -8 * s,
                  child: _CornerMark(scale: s, top: true, left: false),
                ),
                Positioned(
                  bottom: -8 * s,
                  left: -8 * s,
                  child: _CornerMark(scale: s, top: false, left: true),
                ),
                Positioned(
                  bottom: -8 * s,
                  right: -8 * s,
                  child: _CornerMark(scale: s, top: false, left: false),
                ),
              ],
            ),
          ),
          SizedBox(width: 18 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7 * s,
                      height: 7 * s,
                      decoration: const BoxDecoration(
                        color: _kGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6 * s),
                    // Gerçek müsaitlik takvimi henüz tutulmuyor —
                    // gösterimlik sabit bir tarih kullanılıyor.
                    Expanded(
                      child: Text(
                        'MÜSAİT · 12 HAZİRAN\'DAN İTİBAREN',
                        maxLines: 2,
                        style: _ui(
                          size: 9 * s,
                          weight: FontWeight.w700,
                          color: _kGold,
                          spacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * s),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _display(
                    size: 28 * s,
                    weight: FontWeight.w700,
                    color: _kBlack,
                  ),
                ),
                SizedBox(height: 6 * s),
                Text(
                  role,
                  style: _ui(
                    size: 12 * s,
                    weight: FontWeight.w700,
                    color: _kGold,
                    spacing: 0.8,
                  ),
                ),
                SizedBox(height: 8 * s),
                Text(
                  '${freelancer?.location.isNotEmpty == true ? freelancer!.location : 'İstanbul'} · ${freelancer?.experience ?? 3} yıl deneyim',
                  style: _ui(size: 11 * s, color: _kTaupe, spacing: 0.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerMark extends StatelessWidget {
  const _CornerMark({
    required this.scale,
    required this.top,
    required this.left,
  });
  final double scale;
  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    final len = 18 * scale;
    const thickness = 2.0;
    return SizedBox(
      width: len,
      height: len,
      child: Stack(
        children: [
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: left ? 0 : null,
            right: left ? null : 0,
            child: Container(width: len, height: thickness, color: _kGold),
          ),
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: left ? 0 : null,
            right: left ? null : 0,
            child: Container(width: thickness, height: len, color: _kGold),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STAT SATIRI — PUAN / PROJE / ZAMANINDA / YANIT
// ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.scale,
    required this.rating,
    required this.jobCount,
  });

  final double scale;
  final double rating;
  final int jobCount;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    // "Zamanında teslim" ve "ortalama yanıt süresi" gerçek verisi henüz
    // tutulmuyor — puana bağlı, gösterimlik ama makul değerler üretilir.
    final onTimePct = (85 + (rating * 3)).clamp(80, 99).round();
    final responseHours = (2 + ((10 - rating) * 3)).clamp(1, 24).round();
    final stats = [
      (rating.toStringAsFixed(1), 'PUAN'),
      ('$jobCount', 'PROJE'),
      ('%$onTimePct', 'ZAMANINDA'),
      ('$responseHours SA', 'YANIT'),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * s),
                child: Container(width: 1, height: 40 * s, color: _kDivider),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stats[i].$1,
                    textAlign: TextAlign.center,
                    style: _display(
                      size: 22 * s,
                      weight: FontWeight.w700,
                      color: _kBlack,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    stats[i].$2,
                    textAlign: TextAlign.center,
                    style: _ui(size: 8 * s, color: _kTaupe, spacing: 0.8),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SECTION LABEL — küçük altın çizgi + başlık
// ─────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.scale, required this.label});
  final double scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 24 * s, height: 1.5, color: _kGold),
          SizedBox(height: 10 * s),
          Text(
            label,
            style: _ui(
              size: 9 * s,
              weight: FontWeight.w700,
              color: _kGold,
              spacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BRIEF'İNE UYGUNLUK — koyu blok
// ─────────────────────────────────────────────────────────────────
class _FitSection extends StatelessWidget {
  const _FitSection({
    required this.scale,
    required this.feeLo,
    required this.feeHi,
    required this.name,
  });

  final double scale;
  final int feeLo;
  final int feeHi;
  final String name;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    // Eşleşme yüzdesi ve müsait süre gerçek brief karşılaştırmasına henüz
    // bağlı değil — gösterimlik sabit değerler kullanılıyor.
    const matchPct = 92;
    const availableDays = 6;
    return Container(
      width: double.infinity,
      color: _kDark,
      padding: EdgeInsets.fromLTRB(24 * s, 20 * s, 24 * s, 20 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "BRIEF'İNE UYGUNLUK",
            style: _ui(
              size: 9 * s,
              weight: FontWeight.w700,
              color: _kGold,
              spacing: 1.4,
            ),
          ),
          SizedBox(height: 14 * s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FitStat(
                  scale: s,
                  value: '$feeLo-${feeHi}B ₺',
                  label: 'BÜTÇE ARALIĞI',
                ),
              ),
              Container(
                width: 1,
                height: 34 * s,
                color: Colors.white.withValues(alpha: 0.14),
              ),
              Expanded(
                child: _FitStat(
                  scale: s,
                  value: '%$matchPct',
                  label: 'EŞLEŞME',
                ),
              ),
              Container(
                width: 1,
                height: 34 * s,
                color: Colors.white.withValues(alpha: 0.14),
              ),
              Expanded(
                child: _FitStat(
                  scale: s,
                  value: '$availableDays GÜN',
                  label: 'MÜSAİT SÜRE',
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.14)),
          SizedBox(height: 14 * s),
          Text(
            'Brief bütçenle uyumlu bir aralıkta çalışıyor.\n$name bu tür projelerde deneyimli.',
            style: _ui(
              size: 12 * s,
              color: Colors.white.withValues(alpha: 0.75),
              spacing: 0.2,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _FitStat extends StatelessWidget {
  const _FitStat({required this.scale, required this.value, required this.label});
  final double scale;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: _display(size: 18 * s, weight: FontWeight.w700, color: Colors.white),
        ),
        SizedBox(height: 3 * s),
        Text(
          label,
          style: _ui(size: 7.5 * s, color: Colors.white.withValues(alpha: 0.5), spacing: 0.6),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// UZMANLIK — 3 sütunlu etiket ızgarası
// ─────────────────────────────────────────────────────────────────
class _ExpertiseGrid extends StatelessWidget {
  const _ExpertiseGrid({
    required this.scale,
    required this.freelancer,
    required this.role,
  });

  final double scale;
  final FreelancerModel? freelancer;
  final String role;

  // Kategori dışındaki ek uzmanlık etiketleri henüz backend'de tutulmuyor;
  // gerçek kategorilerin yanına gösterimlik tamamlayıcı etiketler eklenir.
  static const _kFillerTags = [
    'REKLAM',
    'MÜZİK VİDEOSU',
    'GECE ÇEKİMİ',
    'RENK DÜZENLEME',
    'KAMERA HAREKETİ',
    'SİNEMATİK IŞIK',
    'KURUMSAL',
    'BELGESEL',
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final tags = <String>{
      for (final c in freelancer?.categories ?? const <String>[])
        c.toUpperCaseTr(),
      ..._kFillerTags,
    }.toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Wrap(
        children: [
          for (var i = 0; i < tags.length; i++)
            Container(
              width: (MediaQuery.sizeOf(context).width - 48 * s - 32 * s) / 3,
              padding: EdgeInsets.symmetric(vertical: 12 * s),
              margin: EdgeInsets.only(
                right: (i % 3 != 2) ? 16 * s : 0,
                bottom: 4 * s,
              ),
              decoration: BoxDecoration(
                border: Border(
                  right: (i % 3 != 2)
                      ? const BorderSide(color: _kDivider)
                      : BorderSide.none,
                  bottom: const BorderSide(color: _kDivider),
                ),
              ),
              child: Text(
                tags[i],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _ui(
                  size: 9 * s,
                  weight: FontWeight.w700,
                  color: _kBlack,
                  spacing: 0.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// İŞLERİ — yatay galeri + son iş bilgisi
// ─────────────────────────────────────────────────────────────────
class _WorksSection extends StatelessWidget {
  const _WorksSection({
    required this.scale,
    required this.freelancer,
    required this.jobCount,
  });

  final double scale;
  final FreelancerModel? freelancer;
  final int jobCount;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final projects = freelancer?.projects ?? const [];
    final gallery = AppAssets.portfolioWorksStrip;
    final hasReal = projects.isNotEmpty;
    final featured = hasReal ? projects.first : null;
    final featuredImage = featured?.thumbnailUrl ??
        (featured?.videoUrl != null
            ? _youtubeThumbnail(featured!.videoUrl!)
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'İŞLERİ',
                  style: _ui(
                    size: 9 * s,
                    weight: FontWeight.w700,
                    color: _kGold,
                    spacing: 1.6,
                  ),
                ),
              ),
              Text(
                '$jobCount PROJE',
                style: _ui(
                  size: 9 * s,
                  weight: FontWeight.w700,
                  color: _kGold,
                  spacing: 0.6,
                ),
              ),
              SizedBox(width: 4 * s),
              Icon(Icons.arrow_forward_rounded, size: 12 * s, color: _kGold),
            ],
          ),
        ),
        SizedBox(height: 14 * s),
        _AutoScrollWorksStrip(
          images: gallery,
          itemSize: 130 * s,
          gap: 10 * s,
          leadingPadding: 24 * s,
        ),
        SizedBox(height: 12 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: GestureDetector(
            onTap: featured?.videoUrl != null
                ? () => _openVideo(featured!.videoUrl!, featured.title)
                : null,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasReal
                        ? '${featured!.title.toUpperCaseTr()} · ${featured.jobType.toUpperCaseTr()}'
                        : 'MERCEDES CAMPAIGN · REKLAM · 2023',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ui(
                      size: 9 * s,
                      weight: FontWeight.w700,
                      color: _kTaupe,
                      spacing: 0.6,
                    ),
                  ),
                ),
                if (featuredImage != null || hasReal) ...[
                  Text(
                    'İZLE',
                    style: _ui(
                      size: 9 * s,
                      weight: FontWeight.w700,
                      color: _kGold,
                      spacing: 1,
                    ),
                  ),
                  SizedBox(width: 4 * s),
                  Icon(Icons.arrow_forward_rounded, size: 12 * s, color: _kGold),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// İŞLERİ ŞERİDİ — ekran açılınca sola doğru kendiliğinden akan galeri
//
// Şerit `images` listesini tekrarlar; bir tur tamamlandığında kaydırma
// bir tur geriye alınır — içerik aynı olduğu için sıçrama görünmez.
// Kullanıcı şeride dokunduğunda akış durur, bıraktıktan kısa süre sonra
// kaldığı yerden devam eder.
// ─────────────────────────────────────────────────────────────────
class _AutoScrollWorksStrip extends StatefulWidget {
  const _AutoScrollWorksStrip({
    required this.images,
    required this.itemSize,
    required this.gap,
    required this.leadingPadding,
  });

  final List<String> images;
  final double itemSize;
  final double gap;
  final double leadingPadding;

  @override
  State<_AutoScrollWorksStrip> createState() => _AutoScrollWorksStripState();
}

class _AutoScrollWorksStripState extends State<_AutoScrollWorksStrip>
    with SingleTickerProviderStateMixin {
  /// Saniyede kaç piksel — göz takip edebilsin diye bilinçli olarak yavaş.
  static const double _speed = 20;

  /// Kullanıcı elini çektikten sonra akışın yeniden başlama gecikmesi.
  static const Duration _resumeDelay = Duration(milliseconds: 1800);

  final ScrollController _scrollController = ScrollController();
  late final Ticker _ticker;
  Timer? _resumeTimer;
  Duration _lastElapsed = Duration.zero;
  double _offset = 0;
  bool _pausedByUser = false;
  bool _reducedMotion = false;

  double get _cycleLength =>
      widget.images.length * (widget.itemSize + widget.gap);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  @override
  void dispose() {
    _resumeTimer?.cancel();
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    if (_pausedByUser || _reducedMotion) return;
    if (!_scrollController.hasClients) return;
    // İlk kare veya uzun donmalarda büyük sıçrama olmasın.
    final dt = delta.inMicroseconds / Duration.microsecondsPerSecond;
    if (dt <= 0 || dt > 0.1) return;

    _offset += _speed * dt;
    if (_offset >= _cycleLength) _offset -= _cycleLength;
    _scrollController.jumpTo(_offset);
  }

  void _pause() {
    _resumeTimer?.cancel();
    _pausedByUser = true;
  }

  void _scheduleResume() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(_resumeDelay, () {
      if (!mounted || !_scrollController.hasClients) return;
      // Kullanıcının bıraktığı yerden devam et; tur uzunluğunun katları
      // görsel olarak aynı noktaya denk geldiği için normalize etmek güvenli.
      var offset = _scrollController.offset;
      while (offset >= _cycleLength) {
        offset -= _cycleLength;
      }
      if (offset < 0) offset = 0;
      _offset = offset;
      _scrollController.jumpTo(_offset);
      _pausedByUser = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Bir tur akarken hem mevcut hem sonraki tur ekranda olabildiği için
    // en az üç tur besleniyor.
    final itemCount = widget.images.length * 3;

    return SizedBox(
      height: widget.itemSize,
      child: Listener(
        onPointerDown: (_) => _pause(),
        onPointerUp: (_) => _scheduleResume(),
        onPointerCancel: (_) => _scheduleResume(),
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.only(left: widget.leadingPadding),
          scrollDirection: Axis.horizontal,
          itemCount: itemCount,
          itemBuilder: (_, i) => Padding(
            padding: EdgeInsets.only(right: widget.gap),
            child: ClipRect(
              child: SizedBox(
                width: widget.itemSize,
                height: widget.itemSize,
                child: Image.asset(
                  widget.images[i % widget.images.length],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BİRLİKTE ÇALIŞTIKLARI — dekoratif avatar şeridi
// ─────────────────────────────────────────────────────────────────
class _CollaboratorsSection extends StatelessWidget {
  const _CollaboratorsSection({
    required this.scale,
    required this.freelancer,
    required this.jobCount,
  });

  final double scale;
  final FreelancerModel? freelancer;
  final int jobCount;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final avatars = [
      ...AppAssets.profilePhotosMale,
      ...AppAssets.profilePhotosFemale,
    ];
    const shown = 6;
    final more = (jobCount - shown).clamp(0, 999);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(scale: s, label: 'BİRLİKTE ÇALIŞTIKLARI'),
        SizedBox(height: 14 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Row(
            children: [
              for (var i = 0; i < shown; i++) ...[
                if (i > 0) SizedBox(width: 8 * s),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(
                      avatars[i % avatars.length],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              SizedBox(width: 8 * s),
              Text(
                '+$more',
                style: _ui(
                  size: 12 * s,
                  weight: FontWeight.w700,
                  color: _kTaupe,
                  spacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Text(
            'SET üzerinde $jobCount projede yer aldı.',
            style: _ui(size: 11 * s, color: _kTaupe, spacing: 0.2),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// MÜŞTERİ YORUMLARI
// ─────────────────────────────────────────────────────────────────
class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.scale, required this.reviewCount});
  final double scale;
  final int reviewCount;

  // Gerçek müşteri yorumları henüz backend'de tutulmuyor — gösterimlik.
  static const _kReviews = [
    ('Ayça B.', 5.0, 'Gece çekiminde tek bir plan sapması olmadı. İkinci projede de onunla çalıştık.', 'MERCEDES CAMPAIGN · 2023'),
    ('Tolga M.', 4.9, "Storyboard'a birebir sadık kaldı, kurgu aşamasında da destek verdi.", 'ARÇELİK LANSMAN · 2024'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'MÜŞTERİ YORUMLARI',
                  style: _ui(
                    size: 9 * s,
                    weight: FontWeight.w700,
                    color: _kGold,
                    spacing: 1.6,
                  ),
                ),
              ),
              Text(
                'TÜMÜ ($reviewCount)',
                style: _ui(
                  size: 9 * s,
                  weight: FontWeight.w700,
                  color: _kGold,
                  spacing: 0.6,
                ),
              ),
              SizedBox(width: 4 * s),
              Icon(Icons.arrow_forward_rounded, size: 12 * s, color: _kGold),
            ],
          ),
        ),
        SizedBox(height: 16 * s),
        for (var i = 0; i < _kReviews.length; i++) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRect(
                      child: SizedBox(
                        width: 34 * s,
                        height: 34 * s,
                        child: Image.asset(
                          AppAssets.profilePhotosFemale[i % 4],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: Text(
                        _kReviews[i].$1,
                        style: _display(
                          size: 16 * s,
                          weight: FontWeight.w600,
                          color: _kInk,
                        ),
                      ),
                    ),
                    Text(
                      _kReviews[i].$2.toStringAsFixed(1),
                      style: _display(
                        size: 16 * s,
                        weight: FontWeight.w700,
                        color: _kBlack,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * s),
                Text(
                  _kReviews[i].$3,
                  style: _ui(
                    size: 12 * s,
                    color: _kBlack,
                    spacing: 0.2,
                    height: 1.5,
                  ).copyWith(fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 8 * s),
                Text(
                  _kReviews[i].$4,
                  style: _ui(size: 9 * s, color: _kTaupe, spacing: 0.8),
                ),
              ],
            ),
          ),
          if (i < _kReviews.length - 1) ...[
            SizedBox(height: 16 * s),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * s),
              child: Container(height: 1, color: _kDivider),
            ),
            SizedBox(height: 16 * s),
          ],
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ÇALIŞMA ŞEKLİ — gösterimlik satırlar
// ─────────────────────────────────────────────────────────────────
class _WorkStyleSection extends StatelessWidget {
  const _WorkStyleSection({required this.scale});
  final double scale;

  // Ekipman/çalışma günü/seyahat/ödeme tercihleri henüz backend'de bir
  // profil alanı olmadığı için gösterimlik sabit değerlerle doldurulur.
  static const _kRows = [
    ('Ekipman', 'KENDİ KAMERASI · ARRI'),
    ('Çalışma günü', '10 SAAT · HAFTA İÇİ'),
    ('Seyahat', 'TÜRKİYE GENELİ'),
    ('Ödeme', 'SET ÜZERİNDEN · %50 PEŞİN'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(scale: s, label: 'ÇALIŞMA ŞEKLİ'),
        SizedBox(height: 6 * s),
        for (var i = 0; i < _kRows.length; i++) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 12 * s),
            child: Row(
              children: [
                Text(
                  _kRows[i].$1,
                  style: _display(
                    size: 14 * s,
                    weight: FontWeight.w600,
                    color: _kInk,
                  ),
                ),
                const Spacer(),
                Text(
                  _kRows[i].$2,
                  style: _ui(
                    size: 9 * s,
                    weight: FontWeight.w700,
                    color: _kTaupe,
                    spacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          if (i < _kRows.length - 1)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * s),
              child: Container(height: 1, color: _kDivider),
            ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// MÜSAİTLİK
// ─────────────────────────────────────────────────────────────────
class _AvailabilitySection extends StatelessWidget {
  const _AvailabilitySection({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(scale: s, label: 'MÜSAİTLİK'),
        SizedBox(height: 10 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gerçek takvim entegrasyonu henüz yok — gösterimlik metin.
              Text(
                "Haziran'da 12 gün müsait.",
                style: _display(
                  size: 19 * s,
                  weight: FontWeight.w700,
                  color: _kInk,
                ),
              ),
              SizedBox(height: 6 * s),
              Text(
                'İlk boş tarih 12 Haziran, en yakın dolu blok 20-24 Haziran.',
                style: _ui(size: 11 * s, color: _kTaupe, spacing: 0.2, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ALT ÇUBUK — seçime ekle / mesaj at
// ─────────────────────────────────────────────────────────────────
class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.scale,
    required this.name,
    required this.role,
    required this.feeLo,
    required this.feeHi,
    required this.avatarUrl,
  });

  final double scale;
  final String name;
  final String role;
  final int feeLo;
  final int feeHi;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final controller = Get.find<FreelancerDetailController>();
    final listController = controller.listController;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        color: _kDark,
        padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 16 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'SEÇİMİNE EKLE',
                  style: _ui(
                    size: 9 * s,
                    weight: FontWeight.w700,
                    color: _kGold,
                    spacing: 1.4,
                  ),
                ),
                const Spacer(),
                if (listController != null)
                  Obx(
                    () => Text(
                      '${listController.selectedIds.length}/${FreelancersByCategoryController.maxSelections} DOLU',
                      style: _ui(
                        size: 10 * s,
                        weight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.6),
                        spacing: 0.4,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12 * s),
            Row(
              children: [
                ClipRect(
                  child: SizedBox(
                    width: 40 * s,
                    height: 40 * s,
                    child: Image.asset(avatarUrl, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _display(
                          size: 17 * s,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        '${role[0]}${role.substring(1).toLowerCaseTr()} · $feeLo-${feeHi}B ₺',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _ui(
                          size: 10 * s,
                          color: Colors.white.withValues(alpha: 0.6),
                          spacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * s),
            Row(
              children: [
                Expanded(
                  child: listController == null
                      ? _SolidButton(
                          scale: s,
                          label: 'TEKLİF GÖNDER',
                          onTap: controller.sendOffer,
                        )
                      : Obx(() {
                          final selected = controller.freelancer != null &&
                              listController.isSelected(controller.freelancer!);
                          return _SolidButton(
                            scale: s,
                            label: selected ? 'SEÇİMDEN ÇIKAR' : 'SEÇİME EKLE',
                            onTap: controller.toggleSelectionInList,
                          );
                        }),
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: GestureDetector(
                    onTap: controller.openChat,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 46 * s,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'MESAJ AT',
                        style: _ui(
                          size: 10 * s,
                          weight: FontWeight.w700,
                          color: Colors.white,
                          spacing: 0.6,
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
    );
  }
}

class _SolidButton extends StatelessWidget {
  const _SolidButton({
    required this.scale,
    required this.label,
    required this.onTap,
  });
  final double scale;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46 * s,
        color: _kGold,
        alignment: Alignment.center,
        child: Text(
          label,
          style: _ui(
            size: 10 * s,
            weight: FontWeight.w700,
            color: Colors.white,
            spacing: 0.6,
          ),
        ),
      ),
    );
  }
}
