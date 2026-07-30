import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/constants/app_assets.dart';
import '../../../routes/app_routes.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF23212B);
const _kTextInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kCardBorder = Color(0x14000000);

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

Widget _wordmark(double s) => RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: 'SE',
        style: AppFonts.display(
          fontSize: 18 * s,
          fontWeight: FontWeight.w700,
          color: _kTextInk,
          letterSpacing: 2.5,
        ),
      ),
      TextSpan(
        text: 'T',
        style: AppFonts.display(
          fontSize: 18 * s,
          fontWeight: FontWeight.w800,
          color: _kGold,
          letterSpacing: 2.5,
        ),
      ),
    ],
  ),
);

class ProjectModeView extends StatefulWidget {
  const ProjectModeView({super.key});

  @override
  State<ProjectModeView> createState() => _ProjectModeViewState();
}

class _ProjectModeViewState extends State<ProjectModeView> {
  String? _selected; // 'freelancer' | 'set'

  void _proceed() {
    if (_selected == null) return;
    final args = Get.arguments as Map<String, dynamic>?;
    final category = (args?['category'] as String?) ?? '';
    final briefId = (args?['briefId'] as String?) ?? '';
    if (_selected == 'set') {
      // Atanmış operasyon ekibiyle doğrudan sohbet ekranına git.
      Get.toNamed(
        AppRoutes.chatDetail,
        arguments: {'name': 'SET · Operasyon Ekibi', 'mode': 'set'},
      );
    } else {
      Get.toNamed(
        AppRoutes.freelancersByCategory,
        arguments: {'category': category, 'briefId': briefId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double s = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.85, 1.15)
        .toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 48 * s,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Get.back<void>(),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.all(12 * s),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 22 * s,
                            color: _kTextInk,
                          ),
                        ),
                      ),
                    ),
                    _wordmark(s),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24 * s, 8 * s, 24 * s, 12 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Projene en uygun üretim sürecini seç.',
                        style: _ui(size: 9 * s, color: _kBlack, spacing: 0.3),
                      ),
                      SizedBox(height: 6 * s),
                      Text(
                        'Nasıl\nilerleyelim?',
                        style: _display(
                          size: 36 * s,
                          weight: FontWeight.w600,
                          color: _kTextInk,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 28 * s),
                      _ModeCard(
                        scale: s,
                        selected: _selected == 'freelancer',
                        dark: false,
                        onTap: () => setState(() => _selected = 'freelancer'),
                        child: _FreelancerCard(scale: s),
                      ),
                      SizedBox(height: 16 * s),
                      _ModeCard(
                        scale: s,
                        selected: _selected == 'set',
                        dark: true,
                        onTap: () => setState(() => _selected = 'set'),
                        child: _SetCard(scale: s),
                      ),
                    ],
                  ),
                ),
              ),
              // Alt sabit bölüm
              Padding(
                padding: EdgeInsets.fromLTRB(0, 8 * s, 0, 6 * s),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _proceed,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedOpacity(
                        opacity: _selected != null ? 1.0 : 0.45,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: double.infinity,
                          height: 50 * s,
                          color: _kGold,
                          alignment: Alignment.center,
                          child: Text(
                            'DEVAM ET  →',
                            style: _ui(
                              size: 11 * s,
                              weight: FontWeight.w700,
                              color: Colors.white,
                              spacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24 * s),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 11 * s,
                            color: _kMuted,
                          ),
                          SizedBox(width: 5 * s),
                          Text(
                            'Seçimin daha sonra değiştirilebilir.',
                            style: _ui(
                              size: 8 * s,
                              color: _kBlack,
                              spacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8 * s),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Kart sarmalayıcı ─────────────────────────────────────────────────────────
class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.scale,
    required this.selected,
    required this.dark,
    required this.onTap,
    required this.child,
  });

  final double scale;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: dark ? _kInk : Colors.white,
          border: Border.all(
            color: selected
                ? _kGold
                : (dark ? Colors.transparent : _kCardBorder),
            width: 1.5,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ─── Ana görsel + gölgesi (aynı kadrajda üst üste bindirilir) ─────────────────
class _CardIllustration extends StatelessWidget {
  const _CardIllustration({
    required this.image,
    required this.shadow,
    required this.height,
    this.width,
    this.shadowOpacity = 0.35,
  });

  final String image;
  final String shadow;
  final double height;
  final double? width;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gölge, ana görselle birebir aynı kadrajda konumlandığı için
          // ikisini de aynı alana yerleştirmek gölgeyi doğru yere oturtur.
          Opacity(
            opacity: shadowOpacity,
            child: Image.asset(shadow, fit: BoxFit.contain),
          ),
          Image.asset(image, fit: BoxFit.contain),
        ],
      ),
    );
  }
}

// ─── Üst üste binen avatar dizisi ─────────────────────────────────────────────
class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.scale, required this.dark});
  final double scale;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final photos = [
      ...AppAssets.profilePhotosMale,
      ...AppAssets.profilePhotosFemale,
    ];
    const highlightIndex = 3;
    const count = 8;
    final baseSize = 28.0 * s;
    final step = baseSize * 0.62;

    // Merkezdeki (sarı çizgili) fotoğraf en büyük; kenara gittikçe küçülür.
    double scaleFor(int i) =>
        (1.3 - 0.1 * (i - highlightIndex).abs()).clamp(0.85, 1.3);

    final maxSize = baseSize * scaleFor(highlightIndex);
    final rowHeight = maxSize + 8 * s;
    final totalWidth = step * (count - 1) + baseSize + 22 * s;

    Widget avatar(int i) {
      final isHighlight = i == highlightIndex;
      final size = baseSize * scaleFor(i);
      return Positioned(
        left: step * i,
        top: (rowHeight - size) / 2,
        child: Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(isHighlight ? 2 * s : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dark ? _kInk : Colors.white,
            border: isHighlight
                ? Border.all(color: _kGold, width: 1.6 * s)
                : null,
          ),
          child: ClipOval(
            child: Image.asset(photos[i % photos.length], fit: BoxFit.cover),
          ),
        ),
      );
    }

    return SizedBox(
      height: rowHeight,
      width: totalWidth,
      child: Stack(
        children: [
          // Merkezdeki fotoğraf önplana çıkması için en son (en üstte) çizilir.
          for (int i = 0; i < count; i++)
            if (i != highlightIndex) avatar(i),
          avatar(highlightIndex),
          Positioned(
            left: step * (count - 1) + baseSize + 4 * s,
            top: (rowHeight - 16 * s) / 2,
            child: Icon(Icons.star_rounded, size: 16 * s, color: _kGold),
          ),
        ],
      ),
    );
  }
}

// ─── Alt ikon satırı (ayraç üstü) ─────────────────────────────────────────────
class _BottomIconsRow extends StatelessWidget {
  const _BottomIconsRow({required this.scale, required this.icons});
  final double scale;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < icons.length; i++) ...[
          if (i != 0) SizedBox(width: 22 * s),
          Icon(icons[i], size: 17 * s, color: _kTaupe),
        ],
      ],
    );
  }
}

// ─── Üst kart ─────────────────────────────────────────────────────────────────
class _FreelancerCard extends StatelessWidget {
  const _FreelancerCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.all(18 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KENDİ EKİBİNİ SEÇ',
                      style: _ui(
                        size: 9 * s,
                        weight: FontWeight.w700,
                        color: _kGold,
                        spacing: 1.3,
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Text(
                      'Freelancer Bul',
                      style: _display(
                        size: 24 * s,
                        weight: FontWeight.w600,
                        color: _kTextInk,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: 5 * s),
                    Text(
                      'Binlerce yetenek arasından seç.',
                      style: _ui(size: 8.5 * s, color: _kBlack, spacing: 0.2),
                    ),
                  ],
                ),
              ),
              // Görsel, metinden bağımsız kendi alanında durur (üst üste binmez).
              _CardIllustration(
                image: AppAssets.briefFreelancerIllustration,
                shadow: AppAssets.briefFreelancerIllustrationShadow,
                height: 108 * s,
                width: 132 * s,
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          Center(child: _AvatarStack(scale: s, dark: false)),
          SizedBox(height: 16 * s),
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.1)),
          SizedBox(height: 12 * s),
          _BottomIconsRow(
            scale: s,
            icons: const [
              Icons.search_rounded,
              Icons.pan_tool_outlined,
              Icons.bolt_rounded,
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Süreç adımları (Ekip → Plan → Üretim → Teslim) ───────────────────────────
class _ProcessSteps extends StatelessWidget {
  const _ProcessSteps({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    const steps = [
      ('Ekip', Icons.people_alt_outlined, true),
      ('Plan', Icons.calendar_today_outlined, true),
      ('Üretim', Icons.movie_creation_outlined, true),
      ('Teslim', Icons.local_shipping_outlined, false),
    ];
    final circleSize = 30.0 * s;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          if (i != 0)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: circleSize / 2,
                  left: 2 * s,
                  right: 2 * s,
                ),
                child: Container(
                  height: 1,
                  color: steps[i - 1].$3
                      ? _kGold.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
          Column(
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: steps[i].$3
                      ? _kGold.withValues(alpha: 0.12)
                      : Colors.transparent,
                  border: Border.all(
                    color: steps[i].$3
                        ? _kGold
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  steps[i].$2,
                  size: 13 * s,
                  color: steps[i].$3
                      ? _kGold
                      : Colors.white.withValues(alpha: 0.35),
                ),
              ),
              SizedBox(height: 5 * s),
              Text(
                steps[i].$1,
                style: _ui(
                  size: 7 * s,
                  color: steps[i].$3
                      ? Colors.white.withValues(alpha: 0.75)
                      : Colors.white.withValues(alpha: 0.35),
                  spacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Alt kart (koyu) ──────────────────────────────────────────────────────────
class _SetCard extends StatelessWidget {
  const _SetCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.all(18 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BİZ YÖNETELİM',
                      style: _ui(
                        size: 9 * s,
                        weight: FontWeight.w700,
                        color: _kGold,
                        spacing: 1.3,
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Text(
                      'SET Halletsin',
                      style: _display(
                        size: 24 * s,
                        weight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: 5 * s),
                    Text(
                      'Sen sonuca odaklan.',
                      style: _ui(
                        size: 8.5 * s,
                        color: Colors.white.withValues(alpha: 0.55),
                        spacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Görsel, metinden bağımsız kendi alanında durur (üst üste binmez).
              _CardIllustration(
                image: AppAssets.briefSetIllustration,
                shadow: AppAssets.briefSetIllustrationShadow,
                height: 108 * s,
                width: 132 * s,
                shadowOpacity: 0.5,
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          _ProcessSteps(scale: s),
          SizedBox(height: 16 * s),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
          SizedBox(height: 12 * s),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14 * s, color: _kGold),
              SizedBox(width: 6 * s),
              Expanded(
                child: Text(
                  'Zaman kazandırır, stressiz ilerlersin.',
                  style: _ui(
                    size: 9 * s,
                    color: Colors.white.withValues(alpha: 0.5),
                    spacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
