import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/utils/avatar_image.dart';
import '../../../data/models/freelancer_model.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import 'freelancers_by_category_controller.dart';

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
// Boş seçim kutuları (üstteki yuvalar + kart sağındaki kare) ayraçlardan
// biraz daha belirgin bir çizgi kullanır ki tıklanabilir oldukları anlaşılsın.
const _kBoxBorder = Color(0x2E000000);

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

// Deneyime göre gösterimlik ücret aralığı (bin TL). Kart ve alt özet
// çubuğu aynı hesaplamayı paylaşır ki toplam tutarlı olsun.
(int, int) _feeRangeBoundsFor(FreelancerModel f) {
  if (f.experience >= 15) return (25, 500);
  if (f.experience >= 8) return (15, 250);
  if (f.experience >= 3) return (8, 120);
  return (2, 50);
}

String _feeRangeLabelFor(FreelancerModel f) {
  final (lo, hi) = _feeRangeBoundsFor(f);
  return '${lo}K-${hi}K TL';
}

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopStrip(scale: s),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 40 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 22 * s),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * s),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Ekibini\nsen kur',
                                    style: _display(
                                      size: 34 * s,
                                      weight: FontWeight.w700,
                                      color: _kBlack,
                                      height: 1.02,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '.',
                                    style: _display(
                                      size: 34 * s,
                                      weight: FontWeight.w700,
                                      color: _kGold,
                                      height: 1.02,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8 * s),
                            Text(
                              'En fazla '
                              '${FreelancersByCategoryController.maxSelections}'
                              ' kişiye brief gönderebilirsin.',
                              style: _ui(size: 12 * s, color: _kTaupe, spacing: 0.2),
                            ),
                            SizedBox(height: 22 * s),
                            Obx(() {
                              final selected = controller.selectedFreelancers;
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Sabit genişlik: rakam glifleri (0/1/2..)
                                  // farklı genişlikte olduğu için, bu sütun
                                  // esnek olsaydı seçim değiştikçe sağdaki
                                  // avatar kutuları hafifçe kayardı.
                                  SizedBox(
                                    width: 104 * s,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '0${selected.length}/0${FreelancersByCategoryController.maxSelections}',
                                          style: _display(
                                            size: 30 * s,
                                            weight: FontWeight.w700,
                                            color: _kBlack,
                                          ),
                                        ),
                                        Text(
                                          'SEÇİLDİ',
                                          style: _ui(
                                            size: 8 * s,
                                            weight: FontWeight.w700,
                                            color: _kTaupe,
                                            spacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        for (var i = 0;
                                            i <
                                                FreelancersByCategoryController
                                                    .maxSelections;
                                            i++) ...[
                                          if (i > 0) SizedBox(width: 8 * s),
                                          SizedBox(
                                            width: 56 * s,
                                            height: 56 * s,
                                            child: i < selected.length
                                                ? Image.asset(
                                                    placeholderAvatarFor(
                                                      controller
                                                          .userFor(selected[i])
                                                          .gender,
                                                      selected[i].userId,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: _kBoxBorder,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ],
                                        const Spacer(),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * s),
                      Container(height: 1, color: _kCardBorder),
                      SizedBox(height: 14 * s),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * s),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'SIRALA · PUAN',
                              style: _ui(
                                size: 9 * s,
                                weight: FontWeight.w700,
                                color: _kGold,
                                spacing: 1,
                              ),
                            ),
                            SizedBox(width: 3 * s),
                            Icon(
                              Icons.arrow_downward_rounded,
                              size: 12 * s,
                              color: _kGold,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10 * s),
                      Obx(() {
                        if (controller.isLoading.value) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 60 * s),
                            child: const Center(
                              child: CircularProgressIndicator(color: _kGold),
                            ),
                          );
                        }
                        if (controller.errorMsg.isNotEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24 * s,
                              vertical: 40 * s,
                            ),
                            child: Text(
                              controller.errorMsg.value,
                              style: _ui(size: 10 * s, color: _kBlack, spacing: 0.2),
                            ),
                          );
                        }
                        final list = controller.freelancers;
                        if (list.isEmpty) {
                          return _EmptyState(
                            scale: s,
                            category: controller.category,
                          );
                        }
                        return Padding(
                          // Kartlar sayfa marjininden biraz içeride başlar:
                          // seçili karttaki altın şerit ve profil fotoğrafı
                          // sola yaklaşsın diye sol boşluk daha dar.
                          padding: EdgeInsets.only(left: 16 * s, right: 24 * s),
                          child: Column(
                            children: [
                              for (var i = 0; i < list.length; i++) ...[
                                Obx(() {
                                  final f = list[i];
                                  final order =
                                      controller.selectedIds.indexOf(f.userId);
                                  return _FreelancerCard(
                                    scale: s,
                                    freelancer: f,
                                    user: controller.userFor(f),
                                    selectionIndex:
                                        order >= 0 ? order + 1 : null,
                                    onProfile: () => controller.openDetail(f),
                                    onInvite: () => controller.toggleSelect(f),
                                  );
                                }),
                                if (i < list.length - 1)
                                  Divider(height: 1, color: _kCardBorder),
                              ],
                              Padding(
                                padding: EdgeInsets.only(top: 18 * s),
                                child: Center(
                                  child: Text(
                                    '${list.length} SETTEKİ GÖSTERİLİYOR',
                                    style: _ui(
                                      size: 9 * s,
                                      weight: FontWeight.w600,
                                      color: _kTaupe,
                                      spacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: 28 * s),
                      // Seçim özeti — sayfanın en altında, kaydırmadan
                      // görünmez; üstte sabit/yüzen bir çubuk değildir.
                      _SelectionSummaryBar(scale: s, controller: controller),
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

// ─── Üst şerit — geri oku + adım göstergesi ──────────────────────────────
class _TopStrip extends StatelessWidget {
  const _TopStrip({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10 * s, 6 * s, 24 * s, 12 * s),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back<void>(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(8 * s),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20 * s,
                    color: _kInk,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: _kCardBorder),
      ],
    );
  }
}

// ─── Alt özet çubuğu — seçilen ekip, tahmini toplam ve gönderim ─────────
class _SelectionSummaryBar extends StatelessWidget {
  const _SelectionSummaryBar({required this.scale, required this.controller});

  final double scale;
  final FreelancersByCategoryController controller;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Obx(() {
      final selected = controller.selectedFreelancers;
      final count = selected.length;
      final sending = controller.isSending.value;

      var totalLo = 0;
      var totalHi = 0;
      for (final f in selected) {
        final (lo, hi) = _feeRangeBoundsFor(f);
        totalLo += lo;
        totalHi += hi;
      }
      final totalLabel =
          count == 0 ? '—' : '${totalLo}K-${totalHi}K TL';

      return Container(
        width: double.infinity,
        color: _kInk,
        padding: EdgeInsets.fromLTRB(20 * s, 18 * s, 20 * s, 16 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'SEÇTİKLERİN',
                  style: _ui(
                    size: 9 * s,
                    weight: FontWeight.w700,
                    color: _kGold,
                    spacing: 1.4,
                  ),
                ),
                const Spacer(),
                Text(
                  '$count/${FreelancersByCategoryController.maxSelections}',
                  style: _ui(
                    size: 10 * s,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    spacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * s),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // Seçili kutucukların altında isim satırı var; boş kareler
              // onlarla üstten hizalansın diye satır yüksekliği serbest.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0;
                    i < FreelancersByCategoryController.maxSelections;
                    i++) ...[
                  if (i > 0) SizedBox(width: 8 * s),
                  SizedBox(
                    width: 72 * s,
                    child: i < count
                        ? _SelectedChip(
                            scale: s,
                            index: i + 1,
                            freelancer: selected[i],
                            user: controller.userFor(selected[i]),
                          )
                        : AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 16 * s),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.14)),
            SizedBox(height: 14 * s),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        totalLabel,
                        style: _display(
                          size: 19 * s,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        'TAHMİNİ TOPLAM',
                        style: _ui(
                          size: 8 * s,
                          color: Colors.white.withValues(alpha: 0.5),
                          spacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 30 * s,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
                SizedBox(width: 16 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gerçek yanıt süresi verisi henüz tutulmadığı için
                      // gösterimlik sabit bir ortalama kullanılır.
                      Text(
                        '3 GÜN',
                        style: _display(
                          size: 19 * s,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        'ORT. YANIT SÜRESİ',
                        style: _ui(
                          size: 8 * s,
                          color: Colors.white.withValues(alpha: 0.5),
                          spacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18 * s),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (count == 0 || sending)
                        ? null
                        : controller.sendOffers,
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedOpacity(
                      opacity: count > 0 ? 1 : 0.45,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        height: 46 * s,
                        color: _kGold,
                        alignment: Alignment.center,
                        child: sending
                            ? SizedBox(
                                width: 20 * s,
                                height: 20 * s,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "BRIEF'İ GÖNDER ($count)",
                                style: _ui(
                                  size: 10 * s,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                  spacing: 0.6,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.setProjects),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 46 * s,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'SET HALLETSİN',
                        style: _ui(
                          size: 10 * s,
                          weight: FontWeight.w700,
                          color: Colors.white,
                          spacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// Alt çubuktaki tek bir seçili kişi — küçük fotoğraf + numara rozeti + isim.
class _SelectedChip extends StatelessWidget {
  const _SelectedChip({
    required this.scale,
    required this.index,
    required this.freelancer,
    required this.user,
  });

  final double scale;
  final int index;
  final FreelancerModel freelancer;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  placeholderAvatarFor(user.gender, freelancer.userId),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 3 * s,
                right: 3 * s,
                child: Container(
                  width: 16 * s,
                  height: 16 * s,
                  alignment: Alignment.center,
                  color: _kGold,
                  child: Text(
                    '$index',
                    style: _ui(
                      size: 8 * s,
                      weight: FontWeight.w700,
                      color: _kBlack,
                      spacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4 * s),
        Text(
          freelancer.name.isNotEmpty ? freelancer.name : user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _ui(
            size: 7 * s,
            weight: FontWeight.w700,
            color: Colors.white,
            spacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _FreelancerCard extends StatelessWidget {
  const _FreelancerCard({
    required this.scale,
    required this.freelancer,
    required this.user,
    required this.selectionIndex,
    required this.onProfile,
    required this.onInvite,
  });

  final double scale;
  final FreelancerModel freelancer;
  final UserModel user;
  // Seçiliyse 1 tabanlı seçim sırası (rozette gösterilir); değilse null.
  final int? selectionIndex;
  final VoidCallback onProfile;
  final VoidCallback onInvite;

  bool get selected => selectionIndex != null;

  int get _jobCount => freelancer.experience * 12 + 15;

  String get _feeRangeLabel => _feeRangeLabelFor(freelancer);

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

  String get _roleLabel =>
      _kCategoryRoleLabel[_primaryCategory] ?? 'KREATİF';

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onProfile,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(left: 6 * s),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: selected ? _kGold : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14 * s),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRect(
                child: SizedBox(
                  width: 60 * s,
                  height: 78 * s,
                  child: Image.asset(
                    placeholderAvatarFor(user.gender, freelancer.userId),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 14 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _buildDisplayName(freelancer, user),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _display(
                        size: 19 * s,
                        weight: FontWeight.w700,
                        color: _kBlack,
                      ),
                    ),
                    SizedBox(height: 2 * s),
                    Text(
                      _roleLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _ui(
                        size: 10 * s,
                        weight: FontWeight.w700,
                        color: _kGold,
                        spacing: 0.6,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      '${freelancer.rating.toStringAsFixed(1)} · $_jobCount PROJE · $_feeRangeLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _ui(size: 10 * s, color: _kTaupe, spacing: 0.2),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10 * s),
              GestureDetector(
                onTap: onInvite,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 32 * s,
                  height: 32 * s,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? _kGold : Colors.transparent,
                    border: Border.all(
                      color: selected ? _kGold : _kBoxBorder,
                    ),
                  ),
                  child: selected
                      ? Text(
                          '$selectionIndex',
                          style: _display(
                            size: 15 * s,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
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
            style: _display(size: 24 * s, weight: FontWeight.w600, color: _kInk),
          ),
        ],
      ),
    );
  }
}
