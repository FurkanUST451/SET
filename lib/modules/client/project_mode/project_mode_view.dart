import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/constants/app_assets.dart';
import '../../../routes/app_routes.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF1A1A1F);
const _kTextInk = Color(0xFF1F1D26);
const _kTaupe = Color(0xFF8E8778);
const _kLabelBrown = Color(0xFF8A7C68);
const _kStepGrey = Color(0xFF5F5B54);
const _kHairLight = Color(0x0F000000);
const _kHairDark = Color(0x1AFFFFFF);

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
    final pad = EdgeInsets.symmetric(horizontal: 20 * s);

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Column(
            children: [
              // ── Üst bar: geri + adım göstergesi ──────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20 * s, 8 * s, 20 * s, 12 * s),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back<void>(),
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        Icons.arrow_back,
                        size: 21 * s,
                        color: _kTextInk,
                      ),
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

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12 * s),

                      // ── Başlık ─────────────────────────────────────────
                      Padding(
                        padding: pad,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                  text: 'İki yol var',
                                  style: _display(
                                    size: 32 * s,
                                    weight: FontWeight.w700,
                                    color: _kTextInk,
                                  ),
                                ),
                                TextSpan(
                                  text: '.',
                                  style: _display(
                                    size: 32 * s,
                                    weight: FontWeight.w700,
                                    color: _kGold,
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(height: 6 * s),
                            Text(
                              'Aynı brief, iki farklı yürütme biçimi.',
                              style: _ui(size: 13.5 * s, color: _kTaupe),
                            ),
                            SizedBox(height: 13 * s),
                            _VideoPreviewBar(scale: s),
                          ],
                        ),
                      ),

                      SizedBox(height: 20 * s),

                      // ── 01 · Freelancer ile ─────────────────────────────
                      Padding(
                        padding: pad,
                        child: _PathSection(
                          scale: s,
                          dark: false,
                          onTap: () => _choose('freelancer'),
                          stepLabel: '01 · KENDİN SEÇ',
                          title: 'Freelancer ile',
                          subtitle: 'Pazaryerinden kendi ekibini kurarsın.',
                          image: AppAssets.projectModeFreelancerBox,
                          imageWidth: 108 * s,
                          imageHeight: 86 * s,
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

                      SizedBox(height: 30 * s),

                      // ── 02 · SET ekibi ile (tam genişlik koyu blok) ─────
                      Container(
                        width: double.infinity,
                        color: _kInk,
                        padding: EdgeInsets.fromLTRB(
                          20 * s,
                          16 * s,
                          20 * s,
                          14 * s,
                        ),
                        child: _PathSection(
                          scale: s,
                          dark: true,
                          onTap: () => _choose('set'),
                          stepLabel: '02 · SET HALLETSİN',
                          badge: 'PREMIUM',
                          title: 'SET ekibi ile',
                          subtitle:
                              'Tek muhatap, kurulmuş ekip, yönetilen süreç.',
                          image: AppAssets.projectModeSetRing,
                          imageWidth: 100 * s,
                          imageHeight: 80 * s,
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

                      SizedBox(height: 13 * s),
                      Center(
                        child: Text(
                          'Kararını sonra da değiştirebilirsin.',
                          style: _ui(
                            size: 11.5 * s,
                            weight: FontWeight.w500,
                            color: _kStepGrey,
                          ).copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: _kStepGrey,
                          ),
                        ),
                      ),
                      SizedBox(height: 11 * s),
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

// ─── "Farkı 40 saniyede izle" video önizleme çubuğu ────────────────────────────
class _VideoPreviewBar extends StatelessWidget {
  const _VideoPreviewBar({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
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
    );
  }
}

// ─── Yol bölümü (01 Freelancer / 02 SET) ──────────────────────────────────────
class _PathSection extends StatelessWidget {
  const _PathSection({
    required this.scale,
    required this.dark,
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
  final bool dark;
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
    final Color titleColor = dark ? Colors.white : _kTextInk;
    final Color bodyColor = dark
        ? Colors.white.withValues(alpha: 0.92)
        : _kTextInk;
    final Color subColor = dark
        ? Colors.white.withValues(alpha: 0.55)
        : _kTaupe;
    final Color hair = dark ? _kHairDark : _kHairLight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiket bloğu + sağda illüstrasyon
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(right: imageWidth + 8 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 26 * s, height: 3 * s, color: _kGold),
                    SizedBox(height: 11 * s),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            stepLabel,
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                            style: _ui(
                              size: 10.5 * s,
                              weight: FontWeight.w700,
                              color: dark ? _kGold : _kLabelBrown,
                              spacing: 0.9,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          SizedBox(width: 9 * s),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7 * s,
                              vertical: 3 * s,
                            ),
                            color: _kGold,
                            child: Text(
                              badge!,
                              style: _ui(
                                size: 8.5 * s,
                                weight: FontWeight.w700,
                                color: _kInk,
                                spacing: 0.6,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 5 * s),
                    Text(
                      title,
                      style: _display(
                        size: 25 * s,
                        weight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: -8 * s,
                child: Image.asset(
                  image,
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          SizedBox(height: 5 * s),
          Text(
            subtitle,
            style: _ui(size: 13.5 * s, color: subColor, height: 1.3),
          ),
          SizedBox(height: 12 * s),

          // Maddeler — her satırın altında ince ayraç
          for (final bullet in bullets) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 3 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 5 * s),
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
                      style: _ui(
                        size: 11.5 * s,
                        color: bodyColor,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: hair),
            SizedBox(height: 3 * s),
          ],

          SizedBox(height: 3 * s),
          _StatsRow(
            scale: s,
            stats: stats,
            valueColor: titleColor,
            labelColor: dark ? Colors.white.withValues(alpha: 0.45) : _kTaupe,
            dividerColor: hair,
          ),
          SizedBox(height: 10 * s),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'DEVAM ET  →',
              style: _ui(
                size: 11.5 * s,
                weight: FontWeight.w700,
                color: _kGold,
                spacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── İstatistik satırı (3 sütun, aralarında dikey ayraç) ──────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.scale,
    required this.stats,
    required this.valueColor,
    required this.labelColor,
    required this.dividerColor,
  });

  final double scale;
  final List<(String, String)> stats;
  final Color valueColor;
  final Color labelColor;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            if (i != 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14 * s),
                child: Container(width: 1, color: dividerColor),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stats[i].$1,
                    style: _display(
                      size: 17 * s,
                      weight: FontWeight.w700,
                      color: valueColor,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    stats[i].$2,
                    style: _ui(
                      size: 9 * s,
                      weight: FontWeight.w600,
                      color: labelColor,
                      spacing: 0.7,
                    ),
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
