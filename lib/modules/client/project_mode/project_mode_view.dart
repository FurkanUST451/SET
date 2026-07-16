import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../routes/app_routes.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF23212B);
const _kTextInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kCardBorder = Color(0x14000000);

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

Widget _wordmark(double s) => RichText(
      text: TextSpan(children: [
        TextSpan(
          text: 'SE',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 18 * s,
              fontWeight: FontWeight.w700,
              color: _kTextInk,
              letterSpacing: 2.5),
        ),
        TextSpan(
          text: 'T',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 18 * s,
              fontWeight: FontWeight.w800,
              color: _kGold,
              letterSpacing: 2.5),
        ),
      ]),
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
      Get.toNamed(AppRoutes.chatDetail,
          arguments: {'name': 'SET · Operasyon Ekibi', 'mode': 'set'});
    } else {
      Get.toNamed(AppRoutes.freelancersByCategory,
          arguments: {'category': category, 'briefId': briefId});
    }
  }

  @override
  Widget build(BuildContext context) {
    final double s =
        (MediaQuery.sizeOf(context).width / 390).clamp(0.85, 1.15).toDouble();

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
                          child: Icon(Icons.arrow_back_rounded,
                              size: 22 * s, color: _kTextInk),
                        ),
                      ),
                    ),
                    _wordmark(s),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24 * s, 12 * s, 24 * s, 32 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Projene en uygun üretim sürecini seç.',
                          style:
                              _mono(size: 9 * s, color: _kTaupe, spacing: 0.3)),
                      SizedBox(height: 8 * s),
                      Text('Nasıl\nilerleyelim?',
                          style: _serif(
                              size: 44 * s,
                              weight: FontWeight.w600,
                              color: _kTextInk,
                              height: 1.0)),
                      SizedBox(height: 24 * s),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _ModeCard(
                                scale: s,
                                selected: _selected == 'freelancer',
                                dark: false,
                                onTap: () =>
                                    setState(() => _selected = 'freelancer'),
                                child: _FreelancerCard(scale: s),
                              ),
                            ),
                            SizedBox(width: 12 * s),
                            Expanded(
                              child: _ModeCard(
                                scale: s,
                                selected: _selected == 'set',
                                dark: true,
                                onTap: () => setState(() => _selected = 'set'),
                                child: _SetCard(scale: s),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 28 * s),
                      GestureDetector(
                        onTap: _proceed,
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedOpacity(
                          opacity: _selected != null ? 1.0 : 0.45,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: double.infinity,
                            height: 54 * s,
                            color: _kGold,
                            alignment: Alignment.center,
                            child: Text('DEVAM ET  →',
                                style: _mono(
                                    size: 11 * s,
                                    weight: FontWeight.w700,
                                    color: Colors.white,
                                    spacing: 1.5)),
                          ),
                        ),
                      ),
                      SizedBox(height: 12 * s),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 11 * s, color: _kMuted),
                          SizedBox(width: 5 * s),
                          Text('Seçimin daha sonra değiştirilebilir.',
                              style: _mono(
                                  size: 8 * s, color: _kMuted, spacing: 0.3)),
                        ],
                      ),
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
            width: selected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ─── Sol kart ─────────────────────────────────────────────────────────────────
class _FreelancerCard extends StatelessWidget {
  const _FreelancerCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    const freelancers = [
      ('Video Editor', '4.9'),
      ('Cinematographer', '4.8'),
      ('Colorist', '4.9'),
    ];
    return Padding(
      padding: EdgeInsets.all(16 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38 * s,
            height: 38 * s,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withValues(alpha: 0.12))),
            child: Icon(Icons.search_rounded, color: _kTaupe, size: 20 * s),
          ),
          SizedBox(height: 12 * s),
          Text('Freelancer\nBul',
              style: _serif(
                  size: 22 * s,
                  weight: FontWeight.w600,
                  color: _kTextInk,
                  height: 1.05)),
          SizedBox(height: 6 * s),
          Text("Kendi freelancer'ını bul, projeni sen yönet.",
              style: _mono(size: 8 * s, color: _kTaupe, spacing: 0.2)),
          SizedBox(height: 14 * s),
          ...freelancers.map((f) => Padding(
                padding: EdgeInsets.only(bottom: 6 * s),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8 * s, vertical: 7 * s),
                  color: const Color(0xFFF3EEE2),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 13 * s, color: _kTaupe),
                      SizedBox(width: 5 * s),
                      Expanded(
                        child: Text(f.$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _mono(
                                size: 8 * s,
                                weight: FontWeight.w700,
                                color: _kTextInk,
                                spacing: 0.2)),
                      ),
                      Icon(Icons.star_rounded, size: 10 * s, color: _kGold),
                      Text(' ${f.$2}',
                          style: _mono(
                              size: 8 * s, color: _kTaupe, spacing: 0.2)),
                    ],
                  ),
                ),
              )),
          SizedBox(height: 12 * s),
          ...[
            'Binlerce freelancer profili',
            'Kendini seç, kendin yönet',
            'Esnek ve hızlı başlangıç',
          ].map((b) => Padding(
                padding: EdgeInsets.only(bottom: 4 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: _mono(size: 9 * s, color: _kGold)),
                    Expanded(
                        child: Text(b,
                            style: _mono(
                                size: 8 * s, color: _kTaupe, spacing: 0.2))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Sağ kart (koyu) ──────────────────────────────────────────────────────────
class _SetCard extends StatelessWidget {
  const _SetCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final checklist = [
      ('Ekibi Oluşturuyoruz', true),
      ('Planlıyoruz', true),
      ('Üretiyoruz', true),
      ('Teslim Ediyoruz', false),
    ];
    return Padding(
      padding: EdgeInsets.all(16 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
            color: Colors.black,
            child: Text('SET',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5)),
          ),
          SizedBox(height: 12 * s),
          Text('SET\nHalletsin',
              style: _serif(
                  size: 22 * s,
                  weight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.05)),
          SizedBox(height: 6 * s),
          Text('Tüm prodüksiyon sürecini biz yönetelim, seninle sonuca odaklanalım.',
              style: _mono(
                  size: 8 * s,
                  color: Colors.white.withValues(alpha: 0.55),
                  spacing: 0.2)),
          SizedBox(height: 14 * s),
          Container(
            padding: EdgeInsets.all(10 * s),
            color: Colors.white.withValues(alpha: 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SÜREÇ YÖNETİMİ',
                    style: _mono(
                        size: 7 * s,
                        color: Colors.white.withValues(alpha: 0.4),
                        spacing: 1.2)),
                SizedBox(height: 8 * s),
                ...checklist.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 6 * s),
                      child: Row(
                        children: [
                          Icon(
                            item.$2
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 13 * s,
                            color: item.$2
                                ? _kGold
                                : Colors.white.withValues(alpha: 0.25),
                          ),
                          SizedBox(width: 6 * s),
                          Expanded(
                            child: Text(item.$1,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _mono(
                                    size: 8 * s,
                                    color: item.$2
                                        ? Colors.white.withValues(alpha: 0.75)
                                        : Colors.white.withValues(alpha: 0.3),
                                    spacing: 0.2)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(height: 12 * s),
          ...[
            'Uzman ekibi biz kurarız',
            'Tüm süreci biz yönetiriz',
            'Zaman kazandırır, stressiz ilerler',
          ].map((b) => Padding(
                padding: EdgeInsets.only(bottom: 4 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: _mono(size: 9 * s, color: _kGold)),
                    Expanded(
                        child: Text(b,
                            style: _mono(
                                size: 8 * s,
                                color: Colors.white.withValues(alpha: 0.4),
                                spacing: 0.2))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
