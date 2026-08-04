import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/utils/avatar_image.dart';
import '../../../data/models/freelancer_model.dart';
import '../../../data/models/user_model.dart';
import 'freelancers_by_category_controller.dart';
import '../../../core/utils/turkish_case.dart';

const Map<String, String> _kCategoryShortLabel = {
  'Video Çekim': 'VİDEO',
  'Kurgu': 'KURGU',
  'Ses Tasarımı': 'SES',
  'CGI & VFX': 'CGI&VFX',
  'Fotoğraf': 'FOTOĞRAF',
};

const Map<String, String> _kCategoryRoleLabel = {
  'Video Çekim': 'YÖNETMEN',
  'Kurgu': 'KURGU YÖNETMENİ',
  'Ses Tasarımı': 'SES TASARIMCISI',
  'CGI & VFX': 'CGI SANATÇISI',
  'Fotoğraf': 'FOTOĞRAFÇI',
};

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
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

class FreelancersByCategoryView
    extends GetView<FreelancersByCategoryController> {
  const FreelancersByCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final double s = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.85, 1.15)
        .toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back<void>(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(12 * s),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 22 * s,
                        color: _kInk,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24 * s, 4 * s, 24 * s, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'sana uygun',
                          style: _display(
                            size: 15 * s,
                            weight: FontWeight.w500,
                            color: _kTaupe,
                          ).copyWith(fontStyle: FontStyle.italic),
                        ),
                        SizedBox(height: 2 * s),
                        Obx(
                          () => RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${controller.freelancers.isEmpty ? 0 : controller.freelancers.length * 10} ',
                                  style: _display(
                                    size: 42 * s,
                                    weight: FontWeight.w700,
                                    color: _kGold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'kreatif',
                                  style: _display(
                                    size: 42 * s,
                                    weight: FontWeight.w600,
                                    color: _kInk,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10 * s),
                        Row(
                          children: [
                            Container(
                              width: 6 * s,
                              height: 6 * s,
                              color: _kGold,
                            ),
                            SizedBox(width: 8 * s),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: _kCardBorder,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10 * s),
                        Text(
                          '5 KİŞİYE ÜCRETSİZ TEKLİF  ·  FAZLASI KREDİ İLE',
                          style: _ui(
                            size: 8.5 * s,
                            weight: FontWeight.w600,
                            color: _kBlack,
                            spacing: 0.8,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 16 * s),
                        Obx(
                          () => Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16 * s,
                              vertical: 12 * s,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                left: BorderSide(color: _kGold, width: 3),
                                top: BorderSide(color: _kCardBorder),
                                right: BorderSide(color: _kCardBorder),
                                bottom: BorderSide(color: _kCardBorder),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${controller.selectedIds.length}/5 seçildi',
                                  style: _display(
                                    size: 17 * s,
                                    weight: FontWeight.w600,
                                    color: _kInk,
                                  ),
                                ),
                                SizedBox(height: 2 * s),
                                Text(
                                  'Öne çıkan işlere bak, doğru ekibi seç',
                                  style: _ui(
                                    size: 8 * s,
                                    color: _kBlack,
                                    spacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 14 * s),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: _kGold),
                        );
                      }
                      if (controller.errorMsg.isNotEmpty) {
                        return Center(
                          child: Text(
                            controller.errorMsg.value,
                            style: _ui(
                              size: 10 * s,
                              color: _kBlack,
                              spacing: 0.2,
                            ),
                          ),
                        );
                      }
                      if (controller.freelancers.isEmpty) {
                        return _EmptyState(
                          scale: s,
                          category: controller.category,
                        );
                      }
                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          24 * s,
                          10 * s,
                          24 * s,
                          120 * s,
                        ),
                        itemCount: controller.freelancers.length,
                        separatorBuilder: (_, _) => _DotDivider(scale: s),
                        itemBuilder: (_, i) {
                          final f = controller.freelancers[i];
                          return Obx(
                            () => Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _FreelancerCard(
                                  scale: s,
                                  freelancer: f,
                                  user: controller.userFor(f),
                                  selected: controller.isSelected(f),
                                  onProfile: () => controller.openDetail(f),
                                  onInvite: () => controller.toggleSelect(f),
                                ),
                                Positioned(
                                  top: -8 * s,
                                  left: -8 * s,
                                  child: _CornerBracket(
                                    scale: s,
                                    top: true,
                                    left: true,
                                  ),
                                ),
                                Positioned(
                                  bottom: -8 * s,
                                  right: -8 * s,
                                  child: _CornerBracket(
                                    scale: s,
                                    top: false,
                                    left: false,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
              // Alt CTA
              Positioned(
                left: 0,
                right: 0,
                bottom: 14 * s,
                child: Column(
                  children: [
                    Obx(() {
                      final count = controller.selectedIds.length;
                      final sending = controller.isSending.value;
                      return GestureDetector(
                        onTap: sending ? null : controller.sendOffers,
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedOpacity(
                          opacity: count > 0 ? 1.0 : 0.45,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            height: 54 * s,
                            color: _kGold,
                            alignment: Alignment.center,
                            child: sending
                                ? SizedBox(
                                    width: 22 * s,
                                    height: 22 * s,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'SEÇİLENLERE TEKLİF GÖNDER  →',
                                    style: _ui(
                                      size: 10 * s,
                                      weight: FontWeight.w700,
                                      color: Colors.white,
                                      spacing: 1.2,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 10 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 11 * s,
                          color: _kTaupe,
                        ),
                        SizedBox(width: 6 * s),
                        Flexible(
                          child: Text(
                            'Tüm bilgilerin güvenliği SET güvencesiyle korunur.'
                                .toUpperCaseTr(),
                            style: _ui(
                              size: 7.5 * s,
                              weight: FontWeight.w600,
                              color: _kTaupe,
                              spacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _FreelancerCard extends StatelessWidget {
  const _FreelancerCard({
    required this.scale,
    required this.freelancer,
    required this.user,
    required this.selected,
    required this.onProfile,
    required this.onInvite,
  });

  final double scale;
  final FreelancerModel freelancer;
  final UserModel user;
  final bool selected;
  final VoidCallback onProfile;
  final VoidCallback onInvite;

  int get _jobCount => freelancer.experience * 12 + 15;

  String get _feeRangeLabel {
    if (freelancer.experience >= 15) return '25K-500K TL';
    if (freelancer.experience >= 8) return '15K-250K TL';
    if (freelancer.experience >= 3) return '8K-120K TL';
    return '2K-50K TL';
  }

  String _buildDisplayName(FreelancerModel f, UserModel u) {
    final name = f.name.isNotEmpty ? f.name : u.name;
    final surname = (f.surname?.isNotEmpty == true)
        ? f.surname!
        : (u.surname ?? '');
    final full = surname.isNotEmpty ? '$name $surname' : name;
    if (full.trim().isEmpty) return full;
    final parts = full.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first;
    final initial = parts.last.isNotEmpty ? '${parts.last[0]}.' : '';
    return '${parts.first} $initial'.trim();
  }

  String get _primaryCategory =>
      freelancer.categories.isNotEmpty ? freelancer.categories.first : '';

  String get _categoryShortLabel =>
      _kCategoryShortLabel[_primaryCategory] ??
      _primaryCategory.toUpperCaseTr();

  String get _roleLabel =>
      _kCategoryRoleLabel[_primaryCategory] ?? 'KREATİF';

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onProfile,
                      behavior: HitTestBehavior.opaque,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6 * s),
                        child: SizedBox(
                          width: 66 * s,
                          height: 92 * s,
                          child: Image.asset(
                            placeholderAvatarFor(
                              user.gender,
                              freelancer.userId,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: GestureDetector(
                        onTap: onProfile,
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _categoryShortLabel,
                              style: _ui(
                                size: 8 * s,
                                weight: FontWeight.w700,
                                color: _kGold,
                                spacing: 1,
                              ),
                            ),
                            SizedBox(height: 4 * s),
                            Text(
                              _buildDisplayName(freelancer, user),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _display(
                                size: 20 * s,
                                weight: FontWeight.w600,
                                color: _kInk,
                              ),
                            ),
                            SizedBox(height: 2 * s),
                            Text(
                              _roleLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _ui(
                                size: 8 * s,
                                weight: FontWeight.w700,
                                color: _kBlack,
                                spacing: 0.6,
                              ),
                            ),
                            SizedBox(height: 6 * s),
                            Text(
                              freelancer.bio.isNotEmpty
                                  ? freelancer.bio
                                  : '${_roleLabel.toLowerCase()} olarak $_jobCount projede yer aldı.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _ui(
                                size: 8 * s,
                                color: _kBlack,
                                spacing: 0.2,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 6 * s),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 11 * s,
                                  color: _kTaupe,
                                ),
                                SizedBox(width: 3 * s),
                                Text(
                                  freelancer.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _ui(
                                    size: 8 * s,
                                    color: _kTaupe,
                                    spacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _StatItem(
                          scale: s,
                          icon: Icons.star_border_rounded,
                          label: 'DENEYİM',
                          value: '${freelancer.experience} YIL',
                        ),
                        SizedBox(height: 6 * s),
                        _StatItem(
                          scale: s,
                          icon: Icons.folder_outlined,
                          label: 'PROJE',
                          value: '$_jobCount',
                        ),
                        SizedBox(height: 6 * s),
                        _StatItem(
                          scale: s,
                          icon: Icons.sell_outlined,
                          label: 'ÜCRET',
                          value: _feeRangeLabel,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12 * s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onProfile,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'PROJELERİNİ GÖRÜNTÜLE',
                            style: _ui(
                              size: 8.5 * s,
                              weight: FontWeight.w700,
                              color: _kInk,
                              spacing: 0.8,
                            ),
                          ),
                          SizedBox(width: 4 * s),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 12 * s,
                            color: _kInk,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onInvite,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 30 * s,
                        height: 30 * s,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8 * s),
                          color: selected ? _kGold : Colors.white,
                          border: Border.all(
                            color: selected ? _kGold : _kInk,
                            width: 1.6,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: _kGold.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          selected ? Icons.check_rounded : Icons.add_rounded,
                          size: 18 * s,
                          color: selected ? Colors.white : _kInk,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12 * s),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10 * s, color: _kGold),
            SizedBox(width: 3 * s),
            Text(
              label,
              style: _ui(
                size: 7 * s,
                weight: FontWeight.w600,
                color: _kTaupe,
                spacing: 0.4,
              ),
            ),
          ],
        ),
        SizedBox(height: 1 * s),
        Text(
          value,
          style: _ui(
            size: 9 * s,
            weight: FontWeight.w700,
            color: _kInk,
            spacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ─── Kart köşe süslemesi ──────────────────────────────────────────────────
class _CornerBracket extends StatelessWidget {
  const _CornerBracket({
    required this.scale,
    required this.top,
    required this.left,
  });

  final double scale;
  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    final double len = 22 * scale;
    const double thickness = 2;
    return SizedBox(
      width: len,
      height: len,
      child: Stack(
        children: [
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: left ? 0 : null,
            right: left ? null : 0,
            child: Container(width: len, height: thickness, color: _kGold),
          ),
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: left ? 0 : null,
            right: left ? null : 0,
            child: Container(width: thickness, height: len, color: _kGold),
          ),
        ],
      ),
    );
  }
}

// ─── Kartlar arası nokta ayracı ───────────────────────────────────────────
class _DotDivider extends StatelessWidget {
  const _DotDivider({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12 * s),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: _kCardBorder)),
          SizedBox(width: 8 * s),
          Container(width: 5 * s, height: 5 * s, color: _kGold),
          SizedBox(width: 8 * s),
          Expanded(child: Container(height: 1, color: _kCardBorder)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scale, required this.category});
  final double scale;
  final String category;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 52 * s, color: _kMuted),
          SizedBox(height: 16 * s),
          Text(
            '"$category" alanında\nhenüz kreatif yok',
            textAlign: TextAlign.center,
            style: _display(size: 20 * s, weight: FontWeight.w600, color: _kInk),
          ),
        ],
      ),
    );
  }
}
