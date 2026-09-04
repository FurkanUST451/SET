import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../data/models/portfolio_project_model.dart';
import '../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kBlack = Color(0xFF000000);
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

/// Kimler Çalıştı listesindeki bir ekip üyesinin yer tutucu profil ekranı.
/// Şimdilik gerçek bir freelancer/kullanıcı kaydına bağlı değil — yalnızca
/// proje kartında geçen ad/rol/foto bilgisini gösterir.
class PortfolioTeamProfileView extends StatelessWidget {
  const PortfolioTeamProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final member = args is Map<String, dynamic>
        ? args['member'] as PortfolioTeamMember?
        : null;
    final double s = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.85, 1.15)
        .toDouble();

    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: _kCream,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8 * s, 8 * s, 8 * s, 8 * s),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back<void>(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8 * s),
                        child: Icon(Icons.arrow_back_rounded,
                            size: 22 * s, color: _kInk),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'PROFİL',
                        textAlign: TextAlign.center,
                        style: _ui(
                          size: 10 * s,
                          weight: FontWeight.w700,
                          color: _kBlack,
                          spacing: 1.6,
                        ),
                      ),
                    ),
                    SizedBox(width: 38 * s),
                  ],
                ),
              ),
              if (member == null)
                Expanded(
                  child: Center(
                    child: Text(
                      'Profil bulunamadı.',
                      style: _ui(size: 13 * s, color: _kTaupe),
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24 * s, 20 * s, 24 * s, 40 * s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 96 * s,
                                height: 96 * s,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _kGold.withValues(alpha: 0.10),
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.12),
                                  ),
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
                                        member.name.isNotEmpty
                                            ? member.name[0].toUpperCaseTr()
                                            : '?',
                                        style: _ui(
                                          size: 24 * s,
                                          weight: FontWeight.w700,
                                          color: _kBlack,
                                        ),
                                      )
                                    : null,
                              ),
                              SizedBox(height: 16 * s),
                              Text(
                                member.name,
                                style: _display(
                                  size: 24 * s,
                                  weight: FontWeight.w600,
                                  color: _kInk,
                                ),
                              ),
                              SizedBox(height: 4 * s),
                              Text(
                                member.role,
                                style: _ui(
                                  size: 10 * s,
                                  weight: FontWeight.w700,
                                  color: _kGold,
                                  spacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 28 * s),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16 * s),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _kCardBorder),
                            borderRadius: BorderRadius.circular(10 * s),
                          ),
                          child: Text(
                            'Bu ekip üyesi için detaylı profil bilgisi '
                            'henüz eklenmedi. Deneyim, geçmiş projeler ve '
                            'iletişim bilgileri yakında burada yer alacak.',
                            style: _ui(
                              size: 15 * s,
                              color: _kBlack,
                              spacing: 0.2,
                              height: 1.6,
                            ),
                          ),
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
