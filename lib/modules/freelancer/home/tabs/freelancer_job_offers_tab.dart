import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/models/brief_model.dart';
import '../../../../routes/app_routes.dart';
import '../freelancer_job_offers_controller.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kCardBorder = Color(0x0F000000);

// ─── Tipografi yardımcıları ───────────────────────────────────────────────────
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
}) =>
    GoogleFonts.spaceMono(
        fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing);

class FreelancerJobOffersTab extends GetView<FreelancerJobOffersController> {
  const FreelancerJobOffersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => _buildHeader(s, controller.offers.length)),
              SizedBox(height: 12 * s),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: _kGold),
                    );
                  }
                  if (controller.offers.isEmpty) {
                    return _EmptyState(scale: s);
                  }
                  return RefreshIndicator(
                    color: _kGold,
                    onRefresh: controller.loadOffers,
                    child: ListView.separated(
                      padding:
                          EdgeInsets.fromLTRB(24 * s, 6 * s, 24 * s, 130 * s),
                      itemCount: controller.offers.length,
                      separatorBuilder: (_, _) => SizedBox(height: 18 * s),
                      itemBuilder: (_, i) => _OfferCard(
                        scale: s,
                        brief: controller.offers[i],
                        onReload: controller.loadOffers,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double s, int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(26 * s, 22 * s, 18 * s, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SET · GELEN İŞLER',
            style: _mono(size: 8 * s, color: _kMuted, spacing: 2),
          ),
          SizedBox(height: 8 * s),
          Text(
            'Teklifler',
            style: _serif(size: 40 * s, weight: FontWeight.w600, color: _kInk),
          ),
          SizedBox(height: 6 * s),
          Text(
            '$count teklif görüntüleniyor',
            style: _mono(size: 8 * s, color: _kTaupe, spacing: 0.5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// OFFER CARD
// ─────────────────────────────────────────────────────────────────
class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.scale,
    required this.brief,
    required this.onReload,
  });

  final double scale;
  final BriefModel brief;
  final Future<void> Function() onReload;

  String get _displayTitle =>
      brief.title.isNotEmpty ? brief.title : brief.category;

  IconData get _categoryIcon {
    final cat = brief.category.toLowerCase();
    if (cat.contains('video') || cat.contains('film')) {
      return Icons.videocam_rounded;
    } else if (cat.contains('fotoğraf') || cat.contains('photo')) {
      return Icons.camera_alt_rounded;
    } else if (cat.contains('ses') || cat.contains('müzik')) {
      return Icons.music_note_rounded;
    } else if (cat.contains('cgi') || cat.contains('vfx')) {
      return Icons.auto_awesome_rounded;
    }
    return Icons.work_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _kCardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Durum satırı
            Padding(
              padding: EdgeInsets.fromLTRB(18 * s, 16 * s, 14 * s, 0),
              child: Row(
                children: [
                  Container(width: 8 * s, height: 8 * s, color: _kGold),
                  SizedBox(width: 8 * s),
                  Text(
                    'YENİ TEKLİF',
                    style: _mono(
                        size: 8 * s,
                        weight: FontWeight.w700,
                        color: _kInk,
                        spacing: 1.4),
                  ),
                ],
              ),
            ),

            // Kimlik satırı
            Padding(
              padding: EdgeInsets.fromLTRB(18 * s, 16 * s, 18 * s, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48 * s,
                    height: 48 * s,
                    color: _kGold,
                    child: Icon(_categoryIcon, size: 24 * s, color: Colors.white),
                  ),
                  SizedBox(width: 14 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _serif(
                              size: 20 * s, weight: FontWeight.w600, color: _kInk),
                        ),
                        if (brief.category.isNotEmpty) ...[
                          SizedBox(height: 3 * s),
                          Text(
                            brief.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _mono(size: 8 * s, color: _kMuted, spacing: 1),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Meta satırı (bütçe / çekim / lokasyon)
            if (brief.answers.budget != null ||
                brief.answers.dateRange != null ||
                brief.answers.location != null) ...[
              SizedBox(height: 18 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (brief.answers.budget != null)
                      Expanded(
                        child: _MetaCell(
                          scale: s,
                          icon: Icons.payments_outlined,
                          label: 'BÜTÇE',
                          value: brief.answers.budget!,
                        ),
                      ),
                    if (brief.answers.dateRange != null)
                      Expanded(
                        child: _MetaCell(
                          scale: s,
                          icon: Icons.calendar_today_rounded,
                          label: 'ÇEKİM',
                          value: brief.answers.dateRange!,
                        ),
                      ),
                    if (brief.answers.location != null)
                      Expanded(
                        child: _MetaCell(
                          scale: s,
                          icon: Icons.location_on_outlined,
                          label: 'LOKASYON',
                          value: brief.answers.location!,
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // Açıklama
            if (brief.answers.notes != null &&
                brief.answers.notes!.isNotEmpty) ...[
              SizedBox(height: 14 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18 * s),
                child: Text(
                  brief.answers.notes!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _mono(size: 9 * s, color: _kInk, spacing: 0.2),
                ),
              ),
            ],

            // İncele butonu
            SizedBox(height: 18 * s),
            Container(
              width: double.infinity,
              height: 46 * s,
              color: _kInk,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'İNCELE',
                    style: _mono(
                        size: 10 * s,
                        weight: FontWeight.w700,
                        color: Colors.white,
                        spacing: 1.4),
                  ),
                  SizedBox(width: 6 * s),
                  Icon(Icons.arrow_forward_rounded, size: 14 * s, color: _kGold),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetail(BuildContext context) async {
    final result = await Get.toNamed(
      AppRoutes.freelancerOfferDetail,
      arguments: {'brief': brief},
    );
    if (result == 'rejected') {
      await onReload();
    }
  }
}

// ─── Meta hücresi ─────────────────────────────────────────────────
class _MetaCell extends StatelessWidget {
  const _MetaCell({
    required this.scale,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double scale;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.only(right: 8 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11 * s, color: _kTaupe),
              SizedBox(width: 4 * s),
              Text(label, style: _mono(size: 7 * s, color: _kMuted, spacing: 1)),
            ],
          ),
          SizedBox(height: 5 * s),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _mono(
                size: 10 * s, weight: FontWeight.w700, color: _kInk, spacing: 0.3),
          ),
        ],
      ),
    );
  }
}

// ─── Boş durum ────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68 * s,
            height: 68 * s,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
            ),
            child: Icon(Icons.inbox_outlined, size: 30 * s, color: _kMuted),
          ),
          SizedBox(height: 18 * s),
          Text(
            'Henüz teklif yok',
            style: _serif(size: 22 * s, weight: FontWeight.w600, color: _kInk),
          ),
          SizedBox(height: 6 * s),
          Text(
            'Müşteriler teklif gönderince burada görünür.',
            style: _mono(size: 9 * s, color: _kTaupe, spacing: 0.3),
          ),
        ],
      ),
    );
  }
}
