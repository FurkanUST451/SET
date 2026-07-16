import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart' hide RadialGradient, LinearGradient;

import '../../../../routes/app_routes.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);

TextStyle _serif({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
}) => GoogleFonts.cormorantGaramond(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

TextStyle _mono({
  required double size,
  FontWeight weight = FontWeight.w400,
  required Color color,
  double spacing = 0.5,
}) => GoogleFonts.spaceMono(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
);

class ClientHomeTab extends StatefulWidget {
  const ClientHomeTab({super.key});

  @override
  State<ClientHomeTab> createState() => _ClientHomeTabState();
}

class _ClientHomeTabState extends State<ClientHomeTab> {
  OneShotAnimation? _pulseCtrl;
  bool _tapped = false;

  void _onRiveInit(Artboard artboard) {
    final ctrl = OneShotAnimation('Timeline 19', autoplay: false);
    artboard.addController(ctrl);
    _pulseCtrl = ctrl;
  }

  Future<void> _onButtonTap() async {
    if (_tapped) return;
    _tapped = true;
    _pulseCtrl?.isActive = true;
    await Future.delayed(const Duration(milliseconds: 550));
    if (mounted) {
      Get.toNamed(AppRoutes.categoryPicker);
      _tapped = false;
    }
  }

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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20 * s),
                // Marka eyebrow
                Text(
                  'SET · ÜRETİM',
                  textAlign: TextAlign.center,
                  style: _mono(size: 8 * s, color: _kMuted, spacing: 2),
                ),
                const Spacer(),
                // Başlık
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32 * s),
                  child: Text(
                    'Projeni başlat,\nduygusallıkla,\nyaratıcılıkla',
                    textAlign: TextAlign.center,
                    style: _serif(
                      size: 40 * s,
                      weight: FontWeight.w600,
                      color: _kInk,
                      height: 1.15,
                    ),
                  ),
                ),
                SizedBox(height: 52 * s),
                // Kare buton + Rive pulse
                GestureDetector(
                  onTap: _onButtonTap,
                  child: SizedBox(
                    width: 190 * s,
                    height: 190 * s,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        RiveAnimation.asset(
                          'assets/animations/pulse.riv',
                          onInit: _onRiveInit,
                          fit: BoxFit.contain,
                        ),
                        Container(
                          width: 128 * s,
                          height: 128 * s,
                          color: _kGold,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.rocket_launch_outlined,
                                color: Colors.white,
                                size: 26 * s,
                              ),
                              SizedBox(height: 8 * s),
                              Text(
                                'PROJE\nBAŞLAT',
                                textAlign: TextAlign.center,
                                style: _mono(
                                  size: 10 * s,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                  spacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 44 * s),
                // Açıklama
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48 * s),
                  child: Text(
                    'Danışmanlarınla iletişim kur,\nhız, güven ve yaratıcılıkla\nprojeni hayata geçir.',
                    textAlign: TextAlign.center,
                    style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.3),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
