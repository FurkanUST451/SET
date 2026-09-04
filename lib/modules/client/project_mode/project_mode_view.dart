import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/constants/app_assets.dart';
import '../../../routes/app_routes.dart';
import '../home/tabs/how_it_works_modal.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kPage = Color(0xFFF1EFE9); // bölümler arasındaki krem zemin
const _kPanel = Color(0xFFFAF9F6); // üst blok ve kartlar
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF1A1A1F);
const _kTextInk = Color(0xFF1F1D26);
const _kTaupe = Color(0xFF8E8778);
const _kLabelBrown = Color(0xFF8A7C68);
const _kStepGrey = Color(0xFF5F5B54);
const _kHairLight = Color(0x0F000000);

// Kartın sağ kenarında chevron için ayrılan sütun; görsel bu sınırın solunda
// kalır (chevron ikonu 26, kalanı nefes payı).
const double _kChevronLane = 32;

TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w600,
  required Color color,
  double height = 1.02,
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
  double spacing = 0.2,
  double height = 1.35,
}) => AppFonts.ui(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
  height: height,
);

class ProjectModeView extends StatelessWidget {
  const ProjectModeView({super.key});

  void _choose(String mode) {
    final args = Get.arguments as Map<String, dynamic>?;
    final category = (args?['category'] as String?) ?? '';
    final briefId = (args?['briefId'] as String?) ?? '';
    if (mode == 'set') {
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
    // Üst blok panel rengini durum çubuğunun arkasına kadar taşır; alt güvenli
    // alan ise sayfa rengiyle kapanır.
    final double topInset = MediaQuery.paddingOf(context).top;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _kPanel,
      body: MediaQuery.withNoTextScaling(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _IntroPanel(scale: s, topInset: topInset),

                    _Gap(scale: s),

                    // ── 01 · Kendin seç ──────────────────────────────────
                    Expanded(
                      child: _PathCard(
                        scale: s,
                        onTap: () => _choose('freelancer'),
                        stepLabel: '01 · KENDİN SEÇ',
                        title: 'Freelancer ile',
                        subtitle: 'Sen seçersin, sen yönetirsin.',
                        image: AppAssets.projectModeFreelancerBox,
                        imageWidth: 120 * s,
                        imageHeight: 104 * s,
                        bullets: const [
                          '5 kişiye kadar brief gönderirsin',
                          'Fiyat ve takvimi doğrudan konuşursun',
                          'Süreci sen yönetirsin',
                          'Ödeme SET güvencesinde tutulur',
                        ],
                        stats: const [
                          ('24 SA', 'İLK YANIT'),
                          ('128', 'SETTEKİ'),
                          ('%5', 'KOMİSYON'),
                        ],
                      ),
                    ),

                    _Gap(scale: s),

                    // ── 02 · SET halletsin ───────────────────────────────
                    Expanded(
                      child: _PathCard(
                        scale: s,
                        onTap: () => _choose('set'),
                        stepLabel: '02 · SET HALLETSİN',
                        badge: 'PREMIUM',
                        title: 'SET ekibi ile',
                        subtitle: 'Bir kez anlat, gerisini biz kuralım.',
                        image: AppAssets.projectModeSetRing,
                        imageWidth: 112 * s,
                        imageHeight: 112 * s,
                        bullets: const [
                          'Operasyon sorumlusuyla tek görüşme',
                          'İşin ölçeğine göre ekip biz kurarız',
                          'Süreci baştan sona biz yönetiriz',
                          'Teslim ve revizyon SET güvencesinde',
                        ],
                        stats: const [
                          ('2 SA', 'İLK YANIT'),
                          ('TEK', 'MUHATAP'),
                          ('%100', 'TESLİM'),
                        ],
                      ),
                    ),

                    // Artan boşluk kartlara dağıtılır; alt bant doğal boyunda kalır.
                    Container(
                      color: _kPage,
                      padding: EdgeInsets.only(bottom: bottomInset),
                      constraints: BoxConstraints(minHeight: 70 * s),
                      alignment: Alignment.center,
                      child: Text(
                        'İkisi arasında kararsız mısın?',
                        style:
                            _ui(
                              size: 12 * s,
                              weight: FontWeight.w500,
                              color: _kStepGrey,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: _kStepGrey,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bölümler arasındaki ince krem şerit ──────────────────────────────────────
class _Gap extends StatelessWidget {
  const _Gap({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) =>
      Container(height: 8 * scale, color: _kPage);
}

// ─── Üst blok: adım göstergesi, başlık, video çubuğu ──────────────────────────
class _IntroPanel extends StatelessWidget {
  const _IntroPanel({required this.scale, required this.topInset});
  final double scale;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final pad = EdgeInsets.symmetric(horizontal: 20 * s);

    return Container(
      width: double.infinity,
      color: _kPanel,
      padding: EdgeInsets.only(top: topInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20 * s, 10 * s, 20 * s, 12 * s),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back<void>(),
                  behavior: HitTestBehavior.opaque,
                  child: Icon(Icons.arrow_back, size: 21 * s, color: _kTextInk),
                ),
                const Spacer(),
                Text(
                  'ADIM 3 / 3',
                  style: _ui(
                    size: 11 * s,
                    weight: FontWeight.w600,
                    color: _kStepGrey,
                    spacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: pad,
            child: Container(height: 1, color: _kHairLight),
          ),
          SizedBox(height: 22 * s),
          Padding(
            padding: pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Bundan sonrasını\n',
                        style: _display(
                          size: 30 * s,
                          weight: FontWeight.w700,
                          color: _kTextInk,
                          height: 1.15,
                        ),
                      ),
                      TextSpan(
                        text: 'kim yürütsün?',
                        style: _display(
                          size: 30 * s,
                          weight: FontWeight.w700,
                          color: _kGold,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * s),
                Text(
                  'Brief\'in hazır. Tek bir karar kaldı.',
                  style: _ui(size: 13.5 * s, color: _kTaupe),
                ),
                SizedBox(height: 20 * s),
                _VideoPreviewBar(scale: s),
              ],
            ),
          ),
          SizedBox(height: 18 * s),
        ],
      ),
    );
  }
}

// ─── "Farkı 40 saniyede izle" video önizleme çubuğu ────────────────────────────
class _VideoPreviewBar extends StatelessWidget {
  const _VideoPreviewBar({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      // Ana sayfadaki "İZLE" düğmesiyle aynı tanıtım penceresi; brief zaten
      // oluşturulmuş olduğu için alttaki "brief oluştur" düğmesi gizlenir.
      onTap: () => showHowItWorksModal(ctaLabel: null, closeLabel: 'Kapat'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 41 * s,
        padding: EdgeInsets.symmetric(horizontal: 11 * s),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x1A000000)),
        ),
        child: Row(
          children: [
            Container(
              width: 25 * s,
              height: 25 * s,
              decoration: BoxDecoration(
                color: _kGold,
                borderRadius: BorderRadius.circular(3 * s),
              ),
              child: Icon(Icons.play_arrow_rounded, size: 16 * s, color: _kInk),
            ),
            SizedBox(width: 11 * s),
            Expanded(
              child: Text(
                'Farkı 40 saniyede izle',
                style: _ui(size: 13 * s, color: _kTextInk),
              ),
            ),
            Text('0:40', style: _ui(size: 12 * s, color: _kTaupe)),
          ],
        ),
      ),
    );
  }
}

// ─── Yol kartı (01 Freelancer / 02 SET) ───────────────────────────────────────
class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.scale,
    required this.onTap,
    required this.stepLabel,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.imageWidth,
    required this.imageHeight,
    required this.bullets,
    required this.stats,
    this.badge,
  });

  final double scale;
  final VoidCallback onTap;
  final String stepLabel;
  final String? badge;
  final String title;
  final String subtitle;
  final String image;
  final double imageWidth;
  final double imageHeight;

  final List<String> bullets;
  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        color: _kPanel,
        padding: EdgeInsets.fromLTRB(20 * s, 20 * s, 18 * s, 16 * s),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              // Kart kalan dikey alanla birlikte uzayabildiği için içerik
              // dikeyde ortalanır.
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst blok: metin solda, illüstrasyon sağda - ayrı sütunlar,
                // yani görsel hiçbir koşulda metnin üstüne binmez.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stepLabel,
                            style: _ui(
                              size: 10.5 * s,
                              weight: FontWeight.w700,
                              color: _kLabelBrown,
                              spacing: 0.9,
                            ),
                          ),
                          SizedBox(height: 9 * s),
                          Text(
                            title,
                            style: _display(
                              size: 25 * s,
                              weight: FontWeight.w700,
                              color: _kTextInk,
                            ),
                          ),
                          SizedBox(height: 8 * s),
                          Text(
                            subtitle,
                            style: _ui(
                              size: 13 * s,
                              color: _kTaupe,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10 * s),
                    Image.asset(
                      image,
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.contain,
                    ),
                    // Sağdaki chevron şeridi — görsel bu sınırın solunda kalır.
                    SizedBox(width: _kChevronLane * s),
                  ],
                ),
                SizedBox(height: 18 * s),
                Container(width: 108 * s, height: 1, color: _kGold),
                SizedBox(height: 14 * s),
                _HowItWorksLink(scale: s, onTap: () => _openHowItWorks(s)),
              ],
            ),

            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(Icons.chevron_right, size: 26 * s, color: _kGold),
              ),
            ),

            if (badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6 * s,
                    vertical: 4 * s,
                  ),
                  color: _kGold,
                  child: Text(
                    badge!,
                    style: _ui(
                      size: 8 * s,
                      weight: FontWeight.w700,
                      color: _kInk,
                      spacing: 0.6,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openHowItWorks(double s) {
    Get.bottomSheet<void>(
      _HowItWorksSheet(
        scale: s,
        title: title,
        stepLabel: stepLabel,
        bullets: bullets,
        stats: stats,
      ),
      backgroundColor: _kPanel,
      isScrollControlled: true,
    );
  }
}

// ─── "[i] NASIL İŞLER?" bağlantısı ────────────────────────────────────────────
class _HowItWorksLink extends StatelessWidget {
  const _HowItWorksLink({required this.scale, required this.onTap});
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18 * s,
            height: 18 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border.all(color: _kGold)),
            child: Text(
              'i',
              style: _ui(
                size: 10 * s,
                weight: FontWeight.w600,
                color: _kGold,
                spacing: 0,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: 9 * s),
          Text(
            'NASIL İŞLER?',
            style: _ui(
              size: 10.5 * s,
              weight: FontWeight.w700,
              color: _kGold,
              spacing: 0.9,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── "Nasıl işler?" alt sayfası — yolun maddeleri ve sayaçları ────────────────
class _HowItWorksSheet extends StatelessWidget {
  const _HowItWorksSheet({
    required this.scale,
    required this.stepLabel,
    required this.title,
    required this.bullets,
    required this.stats,
  });

  final double scale;
  final String stepLabel;
  final String title;
  final List<String> bullets;
  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20 * s, 18 * s, 20 * s, 22 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 38 * s, height: 3 * s, color: _kGold),
            ),
            SizedBox(height: 18 * s),
            Text(
              stepLabel,
              style: _ui(
                size: 10.5 * s,
                weight: FontWeight.w700,
                color: _kLabelBrown,
                spacing: 0.9,
              ),
            ),
            SizedBox(height: 7 * s),
            Text(
              title,
              style: _display(
                size: 25 * s,
                weight: FontWeight.w700,
                color: _kTextInk,
              ),
            ),
            SizedBox(height: 16 * s),
            for (final bullet in bullets) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 4 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 6 * s),
                      child: Container(
                        width: 5 * s,
                        height: 5 * s,
                        color: _kGold,
                      ),
                    ),
                    SizedBox(width: 11 * s),
                    Expanded(
                      child: Text(
                        bullet,
                        style: _ui(size: 12 * s, color: _kTextInk, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: _kHairLight),
              SizedBox(height: 4 * s),
            ],
            SizedBox(height: 10 * s),
            _StatsRow(scale: s, stats: stats),
          ],
        ),
      ),
    );
  }
}

// ─── İstatistik satırı (3 sütun, aralarında dikey ayraç) ──────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.scale, required this.stats});

  final double scale;
  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          if (i != 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14 * s),
              child: Container(width: 1, height: 32 * s, color: _kHairLight),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stats[i].$1,
                  style: _display(
                    size: 17 * s,
                    weight: FontWeight.w700,
                    color: _kTextInk,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 3 * s),
                Text(
                  stats[i].$2,
                  style: _ui(
                    size: 9 * s,
                    weight: FontWeight.w600,
                    color: _kTaupe,
                    spacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
