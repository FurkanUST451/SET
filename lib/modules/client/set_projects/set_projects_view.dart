import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../routes/app_routes.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kDark = Color(0xFF23212B);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kCardBorder = Color(0x14000000);
const _kDivider = Color(0x12000000);
const _kTile = Color(0xFFF3EEE2);
const _kGreen = Color(0xFF5B8C6E);
const _kGoldSoft = Color(0xFFF1E4C6);

// ─── Tipografi yardımcıları ───────────────────────────────────────────────────
TextStyle _serif({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
  bool italic = false,
}) =>
    GoogleFonts.cormorantGaramond(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );

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
      height: height,
    );

Widget _wordmark(double s) => RichText(
      text: TextSpan(children: [
        TextSpan(
          text: 'SE',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 18 * s,
              fontWeight: FontWeight.w700,
              color: _kInk,
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

class SetProjectsView extends StatelessWidget {
  const SetProjectsView({super.key});

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
              _TopBar(scale: s),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24 * s, 8 * s, 24 * s, 40 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Başlık bloğu ──
                      Text('SET HALLETSİN',
                          style: _mono(size: 9 * s, color: _kGold, spacing: 2)),
                      SizedBox(height: 10 * s),
                      Text('Cafe Tanıtım\nFilmi',
                          style: _serif(
                              size: 42 * s,
                              weight: FontWeight.w600,
                              color: _kInk,
                              height: 1.0)),
                      SizedBox(height: 16 * s),
                      Row(
                        children: [
                          Container(
                              width: 8 * s, height: 8 * s, color: _kGold),
                          SizedBox(width: 8 * s),
                          Text('EKİP KURULUYOR',
                              style: _mono(
                                  size: 9 * s,
                                  weight: FontWeight.w700,
                                  color: _kInk,
                                  spacing: 1.4)),
                        ],
                      ),
                      SizedBox(height: 6 * s),
                      Text('Projen SET ekibi tarafından yönetiliyor.',
                          style:
                              _mono(size: 9 * s, color: _kTaupe, spacing: 0.3)),

                      SizedBox(height: 32 * s),
                      _StepperCard(scale: s),

                      SizedBox(height: 20 * s),
                      _UpdateCard(scale: s),

                      SizedBox(height: 20 * s),
                      _ManagerCard(scale: s),

                      SizedBox(height: 32 * s),
                      _SectionHeader(scale: s, title: 'Ekip Durumu'),
                      SizedBox(height: 14 * s),
                      _TeamRow(scale: s),

                      SizedBox(height: 32 * s),
                      _MetaCard(scale: s),

                      SizedBox(height: 32 * s),
                      _SectionHeader(scale: s, title: 'Proje Dosyaları'),
                      SizedBox(height: 14 * s),
                      _FilesRow(scale: s),

                      SizedBox(height: 32 * s),
                      _NextStepCard(scale: s),
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

// ─── Üst bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.fromLTRB(20 * s, 6 * s, 20 * s, 6 * s),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back<void>(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40 * s,
              height: 40 * s,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
              ),
              child: Icon(Icons.arrow_back_rounded, size: 20 * s, color: _kInk),
            ),
          ),
          Expanded(child: Center(child: _wordmark(s))),
          _SquareIcon(scale: s, icon: Icons.chat_bubble_outline, badge: true),
          SizedBox(width: 8 * s),
          _SquareIcon(scale: s, icon: Icons.notifications_none_rounded),
        ],
      ),
    );
  }
}

class _SquareIcon extends StatelessWidget {
  const _SquareIcon(
      {required this.scale, required this.icon, this.badge = false});
  final double scale;
  final IconData icon;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 40 * s,
      height: 40 * s,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: 19 * s, color: _kInk),
          if (badge)
            Positioned(
              top: 9 * s,
              right: 10 * s,
              child: Container(width: 6 * s, height: 6 * s, color: _kGold),
            ),
        ],
      ),
    );
  }
}

// ─── Süreç adımları ─────────────────────────────────────────────────────────
enum _StepState { done, active, pending }

class _StepData {
  const _StepData(this.label, this.sub, this.icon, this.state);
  final String label;
  final String sub;
  final IconData icon;
  final _StepState state;
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({required this.scale});
  final double scale;

  static const _steps = [
    _StepData('Brief', '23 May', Icons.check_rounded, _StepState.done),
    _StepData('Planlama', '24 May', Icons.check_rounded, _StepState.done),
    _StepData('Ekip Kuruluyor', 'Şu An', Icons.groups_rounded,
        _StepState.active),
    _StepData('Çekim', '—', Icons.videocam_outlined, _StepState.pending),
    _StepData('Kurgu', '—', Icons.content_cut_rounded, _StepState.pending),
    _StepData('Teslim', '—', Icons.flag_outlined, _StepState.pending),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final double box = 34 * s;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 18 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final double cell = constraints.maxWidth / _steps.length;
        return Column(
          children: [
            SizedBox(
              height: box,
              child: Stack(
                children: [
                  // bağlantı çizgisi
                  Positioned(
                    left: cell / 2,
                    right: cell / 2,
                    top: box / 2,
                    child: Container(height: 1, color: _kDivider),
                  ),
                  Row(
                    children: _steps
                        .map((st) => Expanded(
                              child: Center(child: _stepMark(st, box, s)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * s),
            Row(
              children: _steps
                  .map((st) => Expanded(
                        child: Column(
                          children: [
                            Text(st.label,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: _mono(
                                    size: 7 * s,
                                    weight: st.state == _StepState.active
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: st.state == _StepState.pending
                                        ? _kMuted
                                        : _kInk,
                                    spacing: 0.2,
                                    height: 1.25)),
                            SizedBox(height: 3 * s),
                            Text(st.sub,
                                textAlign: TextAlign.center,
                                style: _mono(
                                    size: 7 * s,
                                    color: st.state == _StepState.active
                                        ? _kGold
                                        : _kMuted,
                                    spacing: 0.2)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _stepMark(_StepData st, double box, double s) {
    switch (st.state) {
      case _StepState.done:
        return Container(
          width: box,
          height: box,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border.fromBorderSide(BorderSide(color: _kGold)),
          ),
          child: Icon(Icons.check_rounded, size: 16 * s, color: _kGold),
        );
      case _StepState.active:
        return Container(
          width: box,
          height: box,
          color: _kGold,
          child: Icon(st.icon, size: 16 * s, color: Colors.white),
        );
      case _StepState.pending:
        return Container(
          width: box,
          height: box,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
          ),
          child: Icon(st.icon, size: 15 * s, color: _kMuted),
        );
    }
  }
}

// ─── Son güncelleme ─────────────────────────────────────────────────────────
class _UpdateCard extends StatelessWidget {
  const _UpdateCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38 * s,
            height: 38 * s,
            color: _kTile,
            child: Icon(Icons.description_outlined,
                size: 18 * s, color: _kTaupe),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Son Güncelleme',
                        style: _serif(
                            size: 16 * s,
                            weight: FontWeight.w600,
                            color: _kInk)),
                    const Spacer(),
                    Text('2 saat önce',
                        style: _mono(size: 7 * s, color: _kMuted, spacing: 0.3)),
                  ],
                ),
                SizedBox(height: 6 * s),
                Text(
                    "Videographer shortlist tamamlandı. Bugün saat 18.00'e kadar ekip kesinleşecek.",
                    style: _mono(
                        size: 9 * s,
                        color: _kTaupe,
                        spacing: 0.2,
                        height: 1.55)),
              ],
            ),
          ),
          SizedBox(width: 8 * s),
          Icon(Icons.chevron_right, size: 18 * s, color: _kGold),
        ],
      ),
    );
  }
}

// ─── Proje yöneticisi ───────────────────────────────────────────────────────
class _ManagerCard extends StatelessWidget {
  const _ManagerCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.all(14 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Row(
        children: [
          _InitialSquare(scale: s, text: 'SA', size: 46, dark: false),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selin A.',
                    style: _serif(
                        size: 18 * s, weight: FontWeight.w600, color: _kInk)),
                SizedBox(height: 2 * s),
                Text('SET Project Manager',
                    style: _mono(size: 8 * s, color: _kTaupe, spacing: 0.3)),
                SizedBox(height: 5 * s),
                Row(
                  children: [
                    Container(width: 6 * s, height: 6 * s, color: _kGreen),
                    SizedBox(width: 5 * s),
                    Text('Online',
                        style: _mono(
                            size: 8 * s, color: _kGreen, spacing: 0.3)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * s),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.chatDetail,
                arguments: {'name': 'Selin A.', 'mode': 'set'}),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14 * s, vertical: 11 * s),
              color: _kDark,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 13 * s, color: Colors.white),
                  SizedBox(width: 7 * s),
                  Text('MESAJ',
                      style: _mono(
                          size: 8 * s,
                          weight: FontWeight.w700,
                          color: Colors.white,
                          spacing: 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ekip durumu ────────────────────────────────────────────────────────────
class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.scale});
  final double scale;

  static const _members = [
    ('Videographer', 'Bulundu', true),
    ('Editor', 'Bulundu', true),
    ('Colorist', 'Aranıyor', false),
    ('Drone Op.', 'Aranıyor', false),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: _members.map((m) {
        final found = m.$3;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 10 * s),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 56 * s,
                  color: _kTile,
                  child: Icon(Icons.person_outline,
                      size: 24 * s, color: _kTaupe),
                ),
                SizedBox(height: 8 * s),
                Text(m.$1,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _mono(
                        size: 7.5 * s,
                        weight: FontWeight.w700,
                        color: _kInk,
                        spacing: 0.2)),
                SizedBox(height: 4 * s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 5 * s,
                        height: 5 * s,
                        color: found ? _kGreen : _kGold),
                    SizedBox(width: 4 * s),
                    Flexible(
                      child: Text(m.$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _mono(
                              size: 7 * s,
                              color: found ? _kGreen : _kGold,
                              spacing: 0.2)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Meta (bütçe / teslim / lokasyon / escrow) ──────────────────────────────
class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final cells = [
      (Icons.savings_outlined, 'BÜTÇE', '120.000 TL', _kInk),
      (Icons.event_outlined, 'TESLİM', '7 Gün', _kInk),
      (Icons.location_on_outlined, 'LOKASYON', 'Beşiktaş', _kInk),
      (Icons.verified_user_outlined, 'ESCROW', 'Aktif', _kGreen),
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 16 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < cells.length; i++) ...[
            if (i > 0)
              Container(width: 1, height: 40 * s, color: _kDivider),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(cells[i].$1, size: 15 * s, color: _kGold),
                    SizedBox(height: 8 * s),
                    Text(cells[i].$2,
                        style:
                            _mono(size: 7 * s, color: _kMuted, spacing: 0.8)),
                    SizedBox(height: 4 * s),
                    Text(cells[i].$3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _mono(
                            size: 9 * s,
                            weight: FontWeight.w700,
                            color: cells[i].$4,
                            spacing: 0.2)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Proje dosyaları ────────────────────────────────────────────────────────
class _FilesRow extends StatelessWidget {
  const _FilesRow({required this.scale});
  final double scale;

  static const _files = [
    (Icons.grid_view_rounded, 'Moodboard', '5.1 MB'),
    (Icons.picture_as_pdf_outlined, 'Brief', '2.4 MB'),
    (Icons.graphic_eq_rounded, 'Voice Note', '03:21'),
    (Icons.movie_outlined, 'Referanslar', '12 Dosya'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 128 * s,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _files.length,
        separatorBuilder: (_, _) => SizedBox(width: 12 * s),
        itemBuilder: (_, i) {
          final f = _files[i];
          return SizedBox(
            width: 108 * s,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 108 * s,
                  height: 78 * s,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF3A342E), Color(0xFF211E1A)],
                    ),
                  ),
                  child: Icon(f.$1,
                      size: 26 * s,
                      color: Colors.white.withValues(alpha: 0.85)),
                ),
                SizedBox(height: 8 * s),
                Text(f.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _mono(
                        size: 8 * s,
                        weight: FontWeight.w700,
                        color: _kInk,
                        spacing: 0.2)),
                SizedBox(height: 2 * s),
                Text(f.$3,
                    style: _mono(size: 7 * s, color: _kMuted, spacing: 0.3)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Yaklaşan adım ──────────────────────────────────────────────────────────
class _NextStepCard extends StatelessWidget {
  const _NextStepCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: const BoxDecoration(
        color: _kGoldSoft,
        border: Border.fromBorderSide(BorderSide(color: _kGold)),
      ),
      child: Row(
        children: [
          Container(
            width: 44 * s,
            height: 44 * s,
            color: _kGold,
            child: Icon(Icons.movie_filter_outlined,
                size: 22 * s, color: Colors.white),
          ),
          SizedBox(width: 14 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YAKLAŞAN ADIM',
                    style: _mono(
                        size: 7 * s,
                        color: _kInk.withValues(alpha: 0.55),
                        spacing: 1.4)),
                SizedBox(height: 4 * s),
                Text('Çekim Planlaması',
                    style: _serif(
                        size: 20 * s, weight: FontWeight.w600, color: _kInk)),
                SizedBox(height: 2 * s),
                Text('29 Mayıs 2024',
                    style: _mono(size: 8 * s, color: _kInk, spacing: 0.3)),
              ],
            ),
          ),
          SizedBox(width: 10 * s),
          Container(
            width: 40 * s,
            height: 40 * s,
            color: _kDark,
            child: Icon(Icons.arrow_forward_rounded,
                size: 18 * s, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ─── Ortak parçalar ─────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.scale, required this.title});
  final double scale;
  final String title;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: [
        Text(title,
            style:
                _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk)),
        const Spacer(),
        Text('Tümünü Gör',
            style: _mono(size: 8 * s, color: _kTaupe, spacing: 0.5)),
        SizedBox(width: 4 * s),
        Icon(Icons.chevron_right, size: 15 * s, color: _kGold),
      ],
    );
  }
}

class _InitialSquare extends StatelessWidget {
  const _InitialSquare({
    required this.scale,
    required this.text,
    required this.size,
    required this.dark,
  });
  final double scale;
  final String text;
  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: size * s,
      height: size * s,
      color: dark ? _kDark : _kGold,
      alignment: Alignment.center,
      child: Text(text,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 16 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1)),
    );
  }
}
