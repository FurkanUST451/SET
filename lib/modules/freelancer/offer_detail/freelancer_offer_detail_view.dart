import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'freelancer_offer_detail_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kDivider = Color(0x12000000);
const _kCardBorder = Color(0x14000000);
const _kDanger = Color(0xFFBE6A5A);

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

class FreelancerOfferDetailView
    extends GetView<FreelancerOfferDetailController> {
  const FreelancerOfferDetailView({super.key});

  // ── Category helper (aynı mantık: BriefDetailView) ─────────────────────────

  static IconData _categoryIcon(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('video') || c.contains('film')) return Icons.videocam_rounded;
    if (c.contains('fotoğraf') || c.contains('photo')) {
      return Icons.camera_alt_rounded;
    }
    if (c.contains('ses') || c.contains('müzik')) return Icons.music_note_rounded;
    if (c.contains('cgi') || c.contains('vfx')) return Icons.auto_awesome_rounded;
    return Icons.work_rounded;
  }

  static const _months = [
    '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  String _fmtDate(DateTime d) => '${d.day} ${_months[d.month]} ${d.year}';

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brief = controller.brief;
    final a = brief.answers;
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
              // ── Üst bar ────────────────────────────────────────────────────
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
                        'İş Teklifi',
                        textAlign: TextAlign.center,
                        style: _serif(
                            size: 22 * s, weight: FontWeight.w600, color: _kInk),
                      ),
                    ),
                    SizedBox(width: 38 * s),
                  ],
                ),
              ),

              // ── Kaydırılabilir gövde ────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20 * s, 6 * s, 20 * s, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(brief.category, brief.title, s),
                      SizedBox(height: 14 * s),

                      if (a.shootingType != null ||
                          a.vibes != null ||
                          a.dateRange != null ||
                          a.deliveryTime != null ||
                          a.budget != null ||
                          a.location != null) ...[
                        _Section(
                          scale: s,
                          icon: Icons.assignment_outlined,
                          label: 'BRIEF BİLGİLERİ',
                          child: _buildBriefGrid(a, s),
                        ),
                        SizedBox(height: 14 * s),
                      ],

                      if (a.notes != null && a.notes!.isNotEmpty) ...[
                        _Section(
                          scale: s,
                          icon: Icons.description_outlined,
                          label: 'İŞ TARİFİ',
                          child: Padding(
                            padding: EdgeInsets.only(top: 12 * s),
                            child: Text(
                              a.notes!,
                              style: _mono(
                                  size: 10 * s,
                                  color: _kInk,
                                  spacing: 0.2,
                                  height: 1.6),
                            ),
                          ),
                        ),
                        SizedBox(height: 14 * s),
                      ],

                      _Section(
                        scale: s,
                        icon: Icons.info_outline,
                        label: 'PROJE BİLGİLERİ',
                        child: Padding(
                          padding: EdgeInsets.only(top: 14 * s),
                          child: Column(
                            children: [
                              _InfoRow(
                                scale: s,
                                label: 'Gönderilme Tarihi',
                                value: _fmtDate(brief.updatedAt),
                              ),
                              SizedBox(height: 12 * s),
                              _InfoRow(
                                scale: s,
                                label: 'Proje ID',
                                value:
                                    '#PRJ-${brief.createdAt.year}-${brief.id.substring(0, 8).toUpperCase()}',
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 120 * s),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: _buildBottomBar(s),
      ),
    );
  }

  // ── Header kartı ────────────────────────────────────────────────────────────

  Widget _buildHeaderCard(String category, String title, double s) {
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
            width: 56 * s,
            height: 56 * s,
            color: _kGold,
            alignment: Alignment.center,
            child: Icon(_categoryIcon(category), size: 28 * s, color: Colors.white),
          ),
          SizedBox(width: 14 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YENİ TEKLİF',
                  style: _mono(
                      size: 8 * s,
                      weight: FontWeight.w700,
                      color: _kGold,
                      spacing: 1.2),
                ),
                SizedBox(height: 5 * s),
                Text(
                  title.isNotEmpty ? title : category,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _serif(
                      size: 24 * s, weight: FontWeight.w600, color: _kInk),
                ),
                SizedBox(height: 2 * s),
                Text(
                  category,
                  style: _mono(size: 8 * s, color: _kMuted, spacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Brief bilgi grid ─────────────────────────────────────────────────────────

  Widget _buildBriefGrid(dynamic a, double s) {
    final items = <_GridItem>[];

    if (a.shootingType != null && (a.shootingType as String).isNotEmpty) {
      items.add(_GridItem(
        icon: Icons.movie_creation_outlined,
        label: 'Çekim Türü',
        value: a.shootingType as String,
      ));
    }
    if (a.vibes != null && (a.vibes as List).isNotEmpty) {
      items.add(_GridItem(
        icon: Icons.show_chart_rounded,
        label: 'Duygu',
        value: (a.vibes as List<String>).join(', '),
      ));
    }
    if (a.dateRange != null && (a.dateRange as String).isNotEmpty) {
      items.add(_GridItem(
        icon: Icons.calendar_today_outlined,
        label: 'Çekim Tarihi',
        value: a.dateRange as String,
      ));
    }
    if (a.deliveryTime != null && (a.deliveryTime as String).isNotEmpty) {
      items.add(_GridItem(
        icon: Icons.access_time_outlined,
        label: 'Teslim Süresi',
        value: a.deliveryTime as String,
      ));
    }
    if (a.budget != null && (a.budget as String).isNotEmpty) {
      items.add(_GridItem(
        icon: Icons.payments_outlined,
        label: 'Bütçe',
        value: a.budget as String,
      ));
    }
    if (a.location != null && (a.location as String).isNotEmpty) {
      items.add(_GridItem(
        icon: Icons.location_on_outlined,
        label: 'Lokasyon',
        value: a.location as String,
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 3) {
      final rowItems =
          items.sublist(i, i + 3 > items.length ? items.length : i + 3);
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(3, (j) {
          if (j >= rowItems.length) return const Expanded(child: SizedBox());
          return Expanded(child: _GridCell(scale: s, item: rowItems[j]));
        }),
      ));
      if (i + 3 < items.length) rows.add(SizedBox(height: 14 * s));
    }

    return Padding(
      padding: EdgeInsets.only(top: 16 * s),
      child: Column(children: rows),
    );
  }

  // ── Alt bar ────────────────────────────────────────────────────────────────

  Widget _buildBottomBar(double s) {
    return Container(
      padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 28 * s),
      decoration: const BoxDecoration(
        color: _kCream,
        border: Border(top: BorderSide(color: _kDivider)),
      ),
      child: Row(
        children: [
          // Reddet
          Expanded(
            flex: 2,
            child: Obx(() => GestureDetector(
                  onTap:
                      controller.isRejecting.value ? null : controller.rejectOffer,
                  child: Container(
                    height: 52 * s,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: _kDanger.withValues(alpha: 0.4)),
                    ),
                    child: controller.isRejecting.value
                        ? Center(
                            child: SizedBox(
                              width: 20 * s,
                              height: 20 * s,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _kDanger,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded,
                                  size: 16 * s, color: _kDanger),
                              SizedBox(width: 6 * s),
                              Text(
                                'REDDET',
                                style: _mono(
                                    size: 10 * s,
                                    weight: FontWeight.w700,
                                    color: _kDanger,
                                    spacing: 1),
                              ),
                            ],
                          ),
                  ),
                )),
          ),
          SizedBox(width: 10 * s),
          // Mesajlaş
          Expanded(
            flex: 3,
            child: Obx(() => GestureDetector(
                  onTap:
                      controller.isOpeningChat.value ? null : controller.openChat,
                  child: Container(
                    height: 52 * s,
                    color: _kGold,
                    child: controller.isOpeningChat.value
                        ? Center(
                            child: SizedBox(
                              width: 22 * s,
                              height: 22 * s,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 16 * s, color: Colors.white),
                              SizedBox(width: 8 * s),
                              Text(
                                'MESAJLAŞ',
                                style: _mono(
                                    size: 11 * s,
                                    weight: FontWeight.w700,
                                    color: Colors.white,
                                    spacing: 1.2),
                              ),
                            ],
                          ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

// ── Bölüm sarmalayıcı ────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.scale,
    required this.icon,
    required this.label,
    required this.child,
  });

  final double scale;
  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16 * s, 14 * s, 16 * s, 16 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14 * s, color: _kGold),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  label,
                  style: _mono(
                      size: 8 * s,
                      weight: FontWeight.w700,
                      color: _kInk,
                      spacing: 1.4),
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

// ── Grid hücresi ─────────────────────────────────────────────────────────────

class _GridItem {
  const _GridItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.scale, required this.item});
  final double scale;
  final _GridItem item;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(item.icon, size: 11 * s, color: _kTaupe),
            SizedBox(width: 4 * s),
            Expanded(
              child: Text(
                item.label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _mono(size: 7 * s, color: _kMuted, spacing: 0.8),
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * s),
        Text(
          item.value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _mono(
              size: 10 * s, weight: FontWeight.w700, color: _kInk, spacing: 0.2),
        ),
      ],
    );
  }
}

// ── Bilgi satırı ─────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.scale, required this.label, required this.value});
  final double scale;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.3),
          ),
        ),
        SizedBox(width: 10 * s),
        Text(
          value,
          style: _mono(
              size: 9 * s, weight: FontWeight.w700, color: _kInk, spacing: 0.3),
        ),
      ],
    );
  }
}
