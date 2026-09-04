import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../data/models/freelancer_model.dart';
import '../../../data/models/portfolio_project_model.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import 'portfolio_project_detail_controller.dart';
import '../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000);
const _kDivider = Color(0x12000000);
const _kDark = Color(0xFF141219);
const _kThumbTop = Color(0xFF262430);
const _kThumbBot = Color(0xFF141219);

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
  double height = 1.4,
}) => AppFonts.ui(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
  height: height,
  decoration: TextDecoration.none,
);

const _kThumbGradient = DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_kThumbTop, _kThumbBot],
    ),
  ),
);

// Aşama başlığı → gün sayısı. Model'de süreç aşamalarının süresi
// tutulmadığı için (bkz. PortfolioProcessStage) gösterimlik sabit bir
// süre tablosu kullanılıyor — bilinmeyen bir etiket 3 gün varsayar.
const _kStageDurations = <String, int>{
  'Brief & Analiz': 4,
  'Pre-Prodüksiyon': 5,
  'Prodüksiyon': 7,
  'Post-Prodüksiyon': 8,
  'Teslim': 4,
};

int _stageDuration(String label) => _kStageDurations[label] ?? 3;

String _stageCaption(String label) {
  switch (label) {
    case 'Brief & Analiz':
      return 'Hedefler, referanslar ve görsel dil netleştirildi.';
    case 'Pre-Prodüksiyon':
      return 'Storyboard, lokasyon ve çekim takvimi hazırlandı.';
    case 'Prodüksiyon':
      return 'İstanbul\'da üç lokasyonda çekimler yapıldı.';
    case 'Post-Prodüksiyon':
      return 'Renk, ses ve kurgu tek anlatıda birleştirildi.';
    case 'Teslim':
      return 'Tüm formatlar hazırlanıp teslim edildi.';
    default:
      return 'Bu aşama özenle yürütüldü.';
  }
}

// "SONUÇ" bölümü — gerçek kampanya sonuçları henüz backend'de bir alan
// olarak tutulmadığı için yalnızca elimizde gerçek vaka metni olan
// projeler (şu an sadece Mercedes) için gösterilir.
class _CaseResult {
  const _CaseResult({
    required this.viewsLabel,
    required this.targetLabel,
    required this.earlyLabel,
    required this.quote,
    required this.clientLabel,
  });
  final String viewsLabel;
  final String targetLabel;
  final String earlyLabel;
  final String quote;
  final String clientLabel;
}

const _kCaseResults = <String, _CaseResult>{
  'w1': _CaseResult(
    viewsLabel: '4.2M',
    targetLabel: '%180',
    earlyLabel: '12 GÜN',
    quote: 'Ekip, ilk kurguyu planlanandan on iki gün önce teslim etti.',
    clientLabel: 'MERCEDES-BENZ TÜRK · PAZARLAMA DİREKTÖRÜ',
  ),
};

class PortfolioProjectDetailView extends StatelessWidget {
  const PortfolioProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioProjectDetailController>();
    final project = controller.project;
    final double s = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.85, 1.15)
        .toDouble();
    final result = _kCaseResults[project.id];

    return MediaQuery.withNoTextScaling(
      key: ValueKey('portfolio-detail-${project.id}'),
      child: Scaffold(
        backgroundColor: _kCream,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 40 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Hero(scale: s, project: project),
              SizedBox(height: 20 * s),
              _StatsRow(scale: s, project: project),
              SizedBox(height: 20 * s),
              Container(height: 1, color: _kDivider),
              SizedBox(height: 22 * s),
              _SectionLabel(scale: s, label: 'BRIEF'),
              SizedBox(height: 12 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22 * s),
                child: Text(
                  project.description,
                  style: _ui(size: 14 * s, color: _kBlack, spacing: 0.2, height: 1.6),
                ),
              ),
              SizedBox(height: 28 * s),
              if (result != null) ...[
                _ResultSection(scale: s, result: result),
                SizedBox(height: 28 * s),
              ],
              _SectionLabel(scale: s, label: 'EKİP'),
              SizedBox(height: 8 * s),
              _TeamList(scale: s, project: project),
              SizedBox(height: 28 * s),
              _SectionLabel(scale: s, label: 'SÜREÇ'),
              SizedBox(height: 8 * s),
              _ProcessSection(scale: s, project: project),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HERO — kapak fotoğrafı + video'dan oluşan carousel. Video asset'i
// henüz tanımlanmadığı için ikinci sayfa şimdilik yer tutucu gösterir;
// asset eklendiğinde sadece _heroVideoAsset doldurulması yeterli.
// ─────────────────────────────────────────────────────────────────
class _Hero extends StatefulWidget {
  const _Hero({required this.scale, required this.project});
  final double scale;
  final PortfolioProjectModel project;

  @override
  State<_Hero> createState() => _HeroState();
}

// Proje id'sine göre hero videosu — henüz yalnızca Mercedes Campaign
// için gerçek bir video dosyası var; diğer projelerde ikinci sayfa
// yer tutucu olarak kalır.
const _kHeroVideos = <String, String>{
  'w1': 'assets/videos/mercedescampaign.mp4',
};

class _HeroState extends State<_Hero> {
  String? get _heroVideoAsset => _kHeroVideos[widget.project.id];

  // Video sayfasının altına serilen sabit kare. Doku (texture) kaydırma
  // sırasında siyah basarsa bu görsel gizler; galeri sayfasıyla aynı
  // kadraj olmasın diye ikinci galeri görseli tercih edilir.
  String? get _videoPosterAsset {
    final gallery = widget.project.galleryImageUrls;
    if (gallery.length > 1) return gallery[1];
    if (gallery.isNotEmpty) return gallery.first;
    return widget.project.coverImageUrl;
  }

  bool _didPrecache = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sayfalar arası geçişte görselin anında görünmesi için hero'daki üç
    // kareyi de önceden decode edip önbelleğe alıyoruz.
    if (_didPrecache) return;
    _didPrecache = true;
    final width = MediaQuery.sizeOf(context).width;
    final cacheWidth = (width * MediaQuery.devicePixelRatioOf(context)).round();
    for (final asset in <String?>{
      widget.project.coverImageUrl,
      if (widget.project.galleryImageUrls.isNotEmpty)
        widget.project.galleryImageUrls.first,
      _videoPosterAsset,
    }) {
      if (asset == null) continue;
      precacheImage(ResizeImage(AssetImage(asset), width: cacheWidth), context);
    }
  }

  late final PageController _pageController = PageController();

  // Sayfa değişimi kaydırma sürerken tetiklendiği için setState yerine
  // ValueNotifier kullanılıyor: yalnızca sayaç rozeti ve video sayfası
  // yeniden çiziliyor, hero'nun tamamı değil.
  final ValueNotifier<int> _activeIndex = ValueNotifier<int>(0);
  bool _muted = true;

  static const int _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    _activeIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final project = widget.project;
    return RepaintBoundary(
      key: ValueKey('hero-${project.id}'),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (i) => _activeIndex.value = i,
              children: [
                _HeroImagePage(project: project),
                ValueListenableBuilder<int>(
                  valueListenable: _activeIndex,
                  builder: (_, index, _) => _HeroVideoPage(
                    scale: s,
                    videoAsset: _heroVideoAsset,
                    posterAsset: _videoPosterAsset,
                    isActive: index == 1,
                    muted: _muted,
                  ),
                ),
                _HeroGalleryPage(project: project),
              ],
            ),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.45, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10 * s,
              left: 6 * s,
              child: SafeArea(
                bottom: false,
                child: GestureDetector(
                  onTap: () => Get.back<void>(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(10 * s),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 22 * s,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            // Instagram tarzı transparan "1/2" sayfa göstergesi
            Positioned(
              top: 10 * s,
              right: 12 * s,
              child: SafeArea(
                bottom: false,
                child: ValueListenableBuilder<int>(
                  valueListenable: _activeIndex,
                  builder: (_, index, _) => _PagePill(
                    scale: s,
                    text: '${index + 1}/$_pageCount',
                  ),
                ),
              ),
            ),
            // Instagram tarzı transparan ses aç/kapa — tüm sayfalarda görünür
            Positioned(
              right: 14 * s,
              bottom: 14 * s,
              child: GestureDetector(
                onTap: () => setState(() => _muted = !_muted),
                behavior: HitTestBehavior.opaque,
                child: _PagePill(
                  scale: s,
                  icon: _muted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  square: true,
                ),
              ),
            ),
            Positioned(
              left: 22 * s,
              right: 22 * s,
              bottom: 22 * s,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${project.status.label} · ${project.year}',
                    style: _ui(
                      size: 11 * s,
                      weight: FontWeight.w700,
                      color: _kGold,
                      spacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 6 * s),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: project.title,
                          style: _display(
                            size: 34 * s,
                            weight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.02,
                          ),
                        ),
                        TextSpan(
                          text: '.',
                          style: _display(
                            size: 34 * s,
                            weight: FontWeight.w700,
                            color: _kGold,
                            height: 1.02,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 14 * s),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pageCount,
                    effect: WormEffect(
                      dotWidth: 6 * s,
                      dotHeight: 6 * s,
                      activeDotColor: _kGold,
                      dotColor: Colors.white.withValues(alpha: 0.4),
                      spacing: 7 * s,
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

// Hero'daki tüm sabit kareler bu widget'tan geçer: asset'ler ~1750px
// genişliğinde, ekran ise en fazla ~1200px basıyor — [cacheWidth] ile
// ekran boyutunda decode edilip kaydırma sırasındaki takılma önlenir.
class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round(),
    );
  }
}

class _HeroImagePage extends StatelessWidget {
  const _HeroImagePage({required this.project});
  final PortfolioProjectModel project;

  @override
  Widget build(BuildContext context) {
    return project.coverImageUrl != null
        ? _HeroPhoto(asset: project.coverImageUrl!)
        : const Stack(fit: StackFit.expand, children: [_kThumbGradient]);
  }
}

// Üçüncü sayfa — proje galerisinden bir kare (kapaktan farklı bir kadraj
// göstermek için ilk galeri görseli kullanılır).
class _HeroGalleryPage extends StatelessWidget {
  const _HeroGalleryPage({required this.project});
  final PortfolioProjectModel project;

  @override
  Widget build(BuildContext context) {
    final images = project.galleryImageUrls;
    return images.isNotEmpty
        ? _HeroPhoto(asset: images.first)
        : const Stack(fit: StackFit.expand, children: [_kThumbGradient]);
  }
}

// Video sayfası — sessiz döngüde oynar. Asset henüz sağlanmadıysa
// kapak fotoğrafını soluk bir zeminle gösterip oynatıcıyı hiç kurmaz.
class _HeroVideoPage extends StatefulWidget {
  const _HeroVideoPage({
    required this.scale,
    required this.videoAsset,
    required this.posterAsset,
    required this.isActive,
    required this.muted,
  });

  final double scale;
  final String? videoAsset;
  final String? posterAsset;
  final bool isActive;
  final bool muted;

  @override
  State<_HeroVideoPage> createState() => _HeroVideoPageState();
}

class _HeroVideoPageState extends State<_HeroVideoPage> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _setUpController();
  }

  void _setUpController() {
    final asset = widget.videoAsset;
    if (asset == null) return;
    _hasError = false;
    _controller = VideoPlayerController.asset(asset)
      ..setLooping(true)
      ..setVolume(widget.muted ? 0 : 1)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        if (widget.isActive) _controller?.play();
      }).catchError((Object e) {
        if (!mounted) return;
        setState(() => _hasError = true);
      });
  }

  @override
  void didUpdateWidget(covariant _HeroVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoAsset != oldWidget.videoAsset) {
      _controller?.dispose();
      _controller = null;
      _setUpController();
      return;
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (widget.isActive != oldWidget.isActive) {
      widget.isActive ? controller.play() : controller.pause();
    }
    if (widget.muted != oldWidget.muted) {
      controller.setVolume(widget.muted ? 0 : 1);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final isReady = controller != null && controller.value.isInitialized;
    final poster = widget.posterAsset;

    // Android'de video bir doku (texture) olarak basılıyor. Sayfa duraklatılıp
    // PageView tarafından ötelenince bu doku — özellikle emülatörde — siyah
    // kare veriyor. Çözüm iki parçalı:
    //  1. Poster HER ZAMAN ağaçta ve videonun altında duruyor; böylece
    //     decode edilmiş, boyanmaya hazır bir kare hep mevcut oluyor.
    //  2. Sayfa aktif değilken VideoPlayer ağaçtan çıkarılıyor; ortada
    //     kompozit edilecek bir doku kalmadığı için siyahlık da olmuyor,
    //     kaydırma sırasındaki GPU yükü de düşüyor.
    // Oynatıcının kendisi (controller) yaşamaya devam ettiği için geri
    // dönüldüğünde doku anında yeniden bağlanıyor.
    return Stack(
      fit: StackFit.expand,
      children: [
        poster != null
            ? _HeroPhoto(asset: poster)
            : const Stack(fit: StackFit.expand, children: [_kThumbGradient]),
        if (isReady && widget.isActive)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        if (!isReady)
          Center(
            child: Icon(
              _hasError
                  ? Icons.error_outline_rounded
                  : Icons.play_circle_outline_rounded,
              size: (_hasError ? 36 : 40) * widget.scale,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
      ],
    );
  }
}

// Instagram tarzı transparan pill/rozet — sayfa sayacı ve ses düğmesi
// için ortak görünüm.
class _PagePill extends StatelessWidget {
  const _PagePill({
    required this.scale,
    this.text,
    this.icon,
    this.square = false,
  });

  final double scale;
  final String? text;
  final IconData? icon;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: square ? 30 * s : null,
      height: square ? 30 * s : null,
      padding: square
          ? null
          : EdgeInsets.symmetric(horizontal: 9 * s, vertical: 5 * s),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(square ? 15 * s : 20 * s),
      ),
      child: icon != null
          ? Icon(icon, size: 15 * s, color: Colors.white)
          : Text(
              text ?? '',
              style: _ui(
                size: 9 * s,
                weight: FontWeight.w700,
                color: Colors.white,
                spacing: 0.4,
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STAT ROW — KİŞİ / SÜRE / BÜTÇE / TESLİM
// ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.scale, required this.project});
  final double scale;
  final PortfolioProjectModel project;

  static const _kUnitAbbr = {
    'HAFTA': 'HFT',
    'GÜN': 'GÜN',
    'AY': 'AY',
    'SAAT': 'SAAT',
  };

  // "4 HAFTA" -> "4 HFT" — dar sütuna sığması için kısaltılır.
  String get _compactDuration {
    final raw = project.durationLabel.trim();
    final parts = raw.split(RegExp(r'\s+'));
    if (parts.length < 2) return raw;
    final unitRaw = parts.sublist(1).join(' ').toUpperCaseTr();
    final abbr = _kUnitAbbr[unitRaw] ??
        (unitRaw.length > 3 ? unitRaw.substring(0, 3) : unitRaw);
    return '${parts[0]} $abbr';
  }

  // "250K - 500K ₺" -> "500B" — tek değer, ₺ işareti olmadan.
  String get _compactBudget {
    final raw = project.budgetRangeLabel;
    final matches = RegExp(r'\d[\d.]*[KM]?')
        .allMatches(raw)
        .map((m) => m.group(0)!)
        .toList();
    if (matches.isEmpty) return raw;
    final last = matches.last;
    return last.endsWith('K')
        ? '${last.substring(0, last.length - 1)}B'
        : last;
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final stats = [
      (project.team.length.toString(), 'KİŞİ'),
      (_compactDuration, 'SÜRE'),
      (_compactBudget, 'BÜTÇE'),
      (project.galleryImageUrls.length.toString(), 'TESLİM'),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * s),
                child: Container(width: 1, height: 34 * s, color: _kDivider),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stats[i].$1,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _display(
                      size: 19 * s,
                      weight: FontWeight.w700,
                      color: _kBlack,
                      height: 1.05,
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
      padding: EdgeInsets.symmetric(horizontal: 22 * s),
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
// SONUÇ — koyu vaka çalışması bölümü (yalnızca gerçek metni olan
// projelerde gösterilir)
// ─────────────────────────────────────────────────────────────────
class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.scale, required this.result});
  final double scale;
  final _CaseResult result;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final stats = [
      (result.viewsLabel, 'İZLENME'),
      (result.targetLabel, 'HEDEF ÜSTÜ'),
      (result.earlyLabel, 'ERKEN TESLİM'),
    ];
    return Container(
      width: double.infinity,
      color: _kDark,
      padding: EdgeInsets.fromLTRB(22 * s, 22 * s, 22 * s, 22 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SONUÇ',
            style: _ui(
              size: 9 * s,
              weight: FontWeight.w700,
              color: _kGold,
              spacing: 1.6,
            ),
          ),
          SizedBox(height: 14 * s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14 * s),
                    child: Container(
                      width: 1,
                      height: 34 * s,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stats[i].$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _display(
                          size: 22 * s,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 3 * s),
                      Text(
                        stats[i].$2,
                        style: _ui(
                          size: 8 * s,
                          color: Colors.white.withValues(alpha: 0.5),
                          spacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 18 * s),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.14)),
          SizedBox(height: 16 * s),
          Text(
            result.quote,
            style: _ui(
              size: 12.5 * s,
              color: Colors.white.withValues(alpha: 0.85),
              spacing: 0.2,
              height: 1.5,
            ),
          ),
          SizedBox(height: 10 * s),
          Text(
            result.clientLabel,
            style: _ui(
              size: 9 * s,
              weight: FontWeight.w700,
              color: _kGold,
              spacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EKİP — numaralı satır listesi
// ─────────────────────────────────────────────────────────────────
class _TeamList extends StatelessWidget {
  const _TeamList({required this.scale, required this.project});
  final double scale;
  final PortfolioProjectModel project;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    if (project.team.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 14 * s),
        child: Text(
          'Ekip bilgisi henüz eklenmedi.',
          style: _ui(size: 12 * s, color: _kTaupe, spacing: 0.2),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < project.team.length; i++) ...[
          _TeamListRow(scale: s, index: i + 1, member: project.team[i]),
          Divider(height: 1, color: _kDivider),
        ],
      ],
    );
  }
}

class _TeamListRow extends StatelessWidget {
  const _TeamListRow({
    required this.scale,
    required this.index,
    required this.member,
  });
  final double scale;
  final int index;
  final PortfolioTeamMember member;

  String get _initials {
    final parts = member.name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCaseTr();
    }
    return member.name.isNotEmpty ? member.name[0].toUpperCaseTr() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: () {
        final parts = member.name.trim().split(RegExp(r'\s+'));
        final firstName = parts.isNotEmpty ? parts.first : member.name;
        final surname = parts.length > 1 ? parts.sublist(1).join(' ') : null;
        final user = UserModel(
          id: 'team-${member.name}',
          name: firstName,
          surname: surname,
          email: '',
          role: UserRole.freelancer,
          avatarUrl: member.avatarUrl,
          createdAt: DateTime.now(),
        );
        final freelancer = FreelancerModel(
          userId: user.id,
          name: firstName,
          surname: surname,
          categories: const [],
          bio: '',
          experience: 3,
          location: '',
          rating: 0,
          profileImageUrl: member.avatarUrl,
        );
        Get.toNamed(
          AppRoutes.freelancerDetail,
          arguments: {'freelancer': freelancer, 'user': user},
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 12 * s),
        child: Row(
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
            Container(
              width: 44 * s,
              height: 56 * s,
              decoration: BoxDecoration(
                color: _kGold.withValues(alpha: 0.10),
                image: member.avatarUrl != null
                    ? DecorationImage(
                        image: AssetImage(member.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: member.avatarUrl == null
                  ? Text(
                      _initials,
                      style: _ui(
                        size: 12 * s,
                        weight: FontWeight.w700,
                        color: _kBlack,
                        spacing: 0.3,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 14 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    member.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _display(
                      size: 18 * s,
                      weight: FontWeight.w600,
                      color: _kInk,
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    member.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ui(size: 11 * s, color: _kTaupe, spacing: 0.3),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8 * s),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PROFİL',
                  style: _ui(
                    size: 8 * s,
                    weight: FontWeight.w700,
                    color: _kGold,
                    spacing: 1,
                  ),
                ),
                SizedBox(width: 3 * s),
                Icon(Icons.arrow_forward_rounded, size: 12 * s, color: _kGold),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SÜREÇ — gün aralıklı zaman çizelgesi
// ─────────────────────────────────────────────────────────────────
class _ProcessSection extends StatelessWidget {
  const _ProcessSection({required this.scale, required this.project});
  final double scale;
  final PortfolioProjectModel project;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final stages = project.processStages;
    if (stages.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 14 * s),
        child: Text(
          'Süreç bilgisi henüz eklenmedi.',
          style: _ui(size: 12 * s, color: _kTaupe, spacing: 0.2),
        ),
      );
    }
    final durations = stages.map((st) => _stageDuration(st.label)).toList();
    final totalDays = durations.fold<int>(0, (a, b) => a + b);
    var dayCursor = 1;
    final ranges = <String>[];
    for (final d in durations) {
      final end = dayCursor + d - 1;
      ranges.add(
        '${dayCursor.toString().padLeft(2, '0')}–${end.toString().padLeft(2, '0')}',
      );
      dayCursor = end + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22 * s),
          child: Text(
            '$totalDays günde teslim.',
            style: _display(size: 24 * s, weight: FontWeight.w700, color: _kInk),
          ),
        ),
        SizedBox(height: 16 * s),
        for (var i = 0; i < stages.length; i++) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 12 * s),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 62 * s,
                  child: Text(
                    ranges[i],
                    style: _display(
                      size: 18 * s,
                      weight: FontWeight.w700,
                      color: _kBlack,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stages[i].label,
                        style: _ui(
                          size: 14 * s,
                          weight: FontWeight.w700,
                          color: _kInk,
                          spacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 3 * s),
                      Text(
                        _stageCaption(stages[i].label),
                        style: _ui(
                          size: 11 * s,
                          color: _kTaupe,
                          spacing: 0.2,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8 * s),
                Text(
                  '${durations[i]} GÜN',
                  style: _ui(
                    size: 9 * s,
                    weight: FontWeight.w700,
                    color: _kMuted,
                    spacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          if (i < stages.length - 1) Divider(height: 1, color: _kDivider),
        ],
      ],
    );
  }
}
