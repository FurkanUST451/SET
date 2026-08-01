import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../data/models/portfolio_project_model.dart';
import '../../../routes/app_routes.dart';
import 'portfolio_project_detail_controller.dart';
import '../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000);
const _kDivider = Color(0x12000000);
const _kCardBorder = Color(0x14000000);
const _kThumbTop = Color(0xFF262430);
const _kThumbBot = Color(0xFF141219);

TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double height = 1.05,
  bool italic = false,
}) => AppFonts.display(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
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

const _kThumbGradient = DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_kThumbTop, _kThumbBot],
    ),
  ),
);

class PortfolioProjectDetailView extends StatelessWidget {
  const PortfolioProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioProjectDetailController>();
    final project = controller.project;
    final double s = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.85, 1.15)
        .toDouble();

    return MediaQuery.withNoTextScaling(
      key: ValueKey('portfolio-detail-${project.id}'),
      child: Scaffold(
        backgroundColor: _kCream,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(scale: s),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20 * s, 6 * s, 20 * s, 40 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroCard(scale: s, project: project),
                      SizedBox(height: 22 * s),
                      _TabBar(scale: s, controller: controller),
                      SizedBox(height: 22 * s),
                      Obx(() {
                        switch (controller.activeTab.value) {
                          case PortfolioDetailTab.overview:
                            return _OverviewTab(scale: s, project: project);
                          case PortfolioDetailTab.team:
                            return _TeamTab(scale: s, project: project);
                          case PortfolioDetailTab.process:
                            return _ProcessTab(scale: s, project: project);
                        }
                      }),
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

// ─────────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.fromLTRB(8 * s, 8 * s, 8 * s, 8 * s),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back<void>(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(8 * s),
              child: Icon(Icons.arrow_back_rounded, size: 22 * s, color: _kInk),
            ),
          ),
          Expanded(
            child: Text(
              'PROJE DETAYI',
              textAlign: TextAlign.center,
              style: _ui(
                size: 10 * s,
                weight: FontWeight.w700,
                color: _kBlack,
                spacing: 1.6,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8 * s),
            child: Icon(Icons.more_vert_rounded, size: 20 * s, color: _kInk),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HERO CARD
// ─────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.scale, required this.project});
  final double scale;
  final PortfolioProjectModel project;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    // RepaintBoundary + proje bazlı key: bu kartın katmanları farklı
    // projeler arasında veya rebuild'ler sırasında başka widget'ların
    // render katmanlarıyla karışmasın diye izole ediyoruz.
    return RepaintBoundary(
      key: ValueKey('hero-card-${project.id}'),
      child: ClipRRect(
      borderRadius: BorderRadius.circular(18 * s),
      child: AspectRatio(
        // Gerçek kapak görseli genelde geniş/sinematik bir kadrajla geliyor
        // (ör. mercedes_bg.png, ~1.93:1); kartı yeteri kadar dikeyde büyük
        // tutup hem görseli hem "ÖNE ÇIKAN PROJE" etiketine, başlığa ve alt
        // bilgilere üst üste binmeden yer açıyoruz. Görsel yoksa (yer
        // tutucu) daha dikey bir kart kullanıyoruz.
        aspectRatio: project.coverImageUrl != null ? 3 / 2 : 4 / 5,
        child: Stack(
          key: ValueKey('hero-${project.id}'),
          fit: StackFit.expand,
          children: [
            if (project.coverImageUrl != null)
              Image.asset(
                project.coverImageUrl!,
                key: const ValueKey('hero-cover'),
                fit: BoxFit.cover,
              )
            else
              ColoredBox(
                key: const ValueKey('hero-placeholder'),
                color: Colors.transparent,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _kThumbGradient,
                    Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 40 * s,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            // scrim
            Positioned.fill(
              key: const ValueKey('hero-scrim'),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
            ),
            // brand mark placeholder (top-right) — yalnızca gerçek görsel
            // yokken gösterilir; sağlanan fotoğraflarda marka logosu zaten
            // görselin içinde geliyor.
            if (project.coverImageUrl == null)
              Positioned(
                key: const ValueKey('hero-brand-mark'),
                top: 18 * s,
                right: 18 * s,
                child: Container(
                  width: 40 * s,
                  height: 40 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.workspace_premium_outlined,
                    size: 18 * s,
                    color: Colors.white,
                  ),
                ),
              ),
            // featured tag (top-left) — kartın büyümüş boyu sayesinde artık
            // başlıkla üst üste binmiyor.
            if (project.isFeatured)
              Positioned(
                key: const ValueKey('hero-featured-tag'),
                top: 18 * s,
                left: 20 * s,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5 * s,
                      height: 5 * s,
                      decoration: const BoxDecoration(
                        color: _kGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6 * s),
                    Text(
                      'ÖNE ÇIKAN PROJE',
                      style: _ui(
                        size: 8 * s,
                        weight: FontWeight.w700,
                        color: _kGold,
                        spacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            // bottom content
            Positioned(
              key: const ValueKey('hero-bottom-content'),
              left: 20 * s,
              right: 20 * s,
              bottom: 18 * s,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    project.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _display(
                      size: 26 * s,
                      weight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 6 * s),
                  Text(
                    project.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _ui(
                      size: 9 * s,
                      color: Colors.white.withValues(alpha: 0.75),
                      spacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 14 * s),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * s,
                      vertical: 5 * s,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      borderRadius: BorderRadius.circular(3 * s),
                    ),
                    child: Text(
                      project.tagLabel,
                      style: _ui(
                        size: 8 * s,
                        weight: FontWeight.w700,
                        color: Colors.white,
                        spacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * s),
                  Row(
                    children: [
                      _HeroMeta(scale: s, label: 'YIL', value: project.year),
                      _HeroMetaDivider(scale: s),
                      _HeroMeta(
                        scale: s,
                        label: 'SÜRE',
                        value: project.durationLabel,
                      ),
                      _HeroMetaDivider(scale: s),
                      _HeroMeta(
                        scale: s,
                        label: 'DURUM',
                        value: project.status.label,
                        icon: project.status == PortfolioStatus.completed
                            ? Icons.check_circle_rounded
                            : null,
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

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({
    required this.scale,
    required this.label,
    required this.value,
    this.icon,
  });
  final double scale;
  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: _ui(
            size: 7 * s,
            color: Colors.white.withValues(alpha: 0.55),
            spacing: 1,
          ),
        ),
        SizedBox(height: 3 * s),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: _ui(
                size: 9 * s,
                weight: FontWeight.w700,
                color: Colors.white,
                spacing: 0.3,
              ),
            ),
            if (icon != null) ...[
              SizedBox(width: 4 * s),
              Icon(icon, size: 11 * s, color: _kGold),
            ],
          ],
        ),
      ],
    );
  }
}

class _HeroMetaDivider extends StatelessWidget {
  const _HeroMetaDivider({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14 * s),
      child: Container(
        width: 1,
        height: 22 * s,
        color: Colors.white.withValues(alpha: 0.18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TAB BAR
// ─────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  const _TabBar({required this.scale, required this.controller});
  final double scale;
  final PortfolioProjectDetailController controller;

  static const _tabs = [
    (PortfolioDetailTab.overview, 'GENEL BAKIŞ'),
    (PortfolioDetailTab.team, 'KİMLER ÇALIŞTI'),
    (PortfolioDetailTab.process, 'SÜREÇ'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Obx(() {
      final active = controller.activeTab.value;
      return SizedBox(
        height: 30 * s,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _tabs.length,
          separatorBuilder: (_, _) => SizedBox(width: 22 * s),
          itemBuilder: (_, i) {
            final (tab, label) = _tabs[i];
            final selected = tab == active;
            return GestureDetector(
              onTap: () => controller.selectTab(tab),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: _ui(
                      size: 9 * s,
                      weight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected ? _kGold : _kTaupe,
                      spacing: 1,
                    ),
                  ),
                  SizedBox(height: 6 * s),
                  Container(
                    height: 2 * s,
                    width: 18 * s,
                    color: selected ? _kGold : Colors.transparent,
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────
// OVERVIEW TAB
// ─────────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.scale, required this.project});
  final double scale;
  final PortfolioProjectModel project;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proje Hakkında',
          style: _display(size: 20 * s, weight: FontWeight.w600, color: _kInk),
        ),
        SizedBox(height: 10 * s),
        Text(
          project.description,
          style: _ui(size: 10 * s, color: _kBlack, spacing: 0.2, height: 1.7),
        ),
        SizedBox(height: 18 * s),
        // Sayfa geneli 20*s yatay boşlukla kaydırılıyor; ilk (Kategori) ve
        // son (Yer) kartın ekranın kenarlarına kadar uzaması için burada
        // OverflowBox ile tam ekran genişliği veriyoruz (negatif padding
        // Flutter'da assertion hatası verdiğinden kullanılmıyor). IntrinsicHeight,
        // OverflowBox'a Column'dan gelen sınırsız (infinite) yükseklik yerine
        // sonlu bir yükseklik kısıtı sağlar — aksi halde OverflowBox kendi
        // boyutunu Infinity raporlayıp içerik ortalanırken NaN üretir.
        IntrinsicHeight(
          child: OverflowBox(
          maxWidth: MediaQuery.sizeOf(context).width,
          minWidth: MediaQuery.sizeOf(context).width,
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(
                child: _InfoChip(
                  scale: s,
                  icon: Icons.videocam_outlined,
                  label: 'KATEGORİ',
                  value: project.category,
                  edgeInset: 20 * s,
                  flushLeft: true,
                ),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: _InfoChip(
                  scale: s,
                  icon: Icons.sell_outlined,
                  label: 'BÜTÇE ARALIĞI',
                  value: project.budgetRangeLabel,
                ),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: _InfoChip(
                  scale: s,
                  icon: Icons.location_on_outlined,
                  label: 'YER',
                  value: project.location,
                  edgeInset: 20 * s,
                  flushRight: true,
                ),
              ),
            ],
          ),
          ),
        ),
        SizedBox(height: 26 * s),
        _SectionHeader(
          scale: s,
          title: 'Proje Görselleri',
          actionLabel: 'Tümünü Gör',
          onAction: () {},
        ),
        SizedBox(height: 12 * s),
        _GalleryRow(scale: s, project: project),
        SizedBox(height: 26 * s),
        _SectionHeader(
          scale: s,
          title: 'Kimler Çalıştı?',
          actionLabel: 'Tüm Ekibi Gör',
          onAction: () {},
        ),
        SizedBox(height: 14 * s),
        _TeamRow(scale: s, project: project),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.scale,
    required this.icon,
    required this.label,
    required this.value,
    this.edgeInset = 0,
    this.flushLeft = false,
    this.flushRight = false,
  });
  final double scale;
  final IconData icon;
  final String label;
  final String value;
  // Ekran kenarına taşan (flush) kartlarda dış tarafta normal sayfa
  // boşluğunu koruyup yalnızca ekran kenarına bakan köşeyi köşeli yapıyoruz.
  final double edgeInset;
  final bool flushLeft;
  final bool flushRight;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = BorderRadius.circular(10 * s);
    return Container(
      padding: EdgeInsets.only(
        left: flushLeft ? edgeInset : 10 * s,
        right: flushRight ? edgeInset : 10 * s,
        top: 8 * s,
        bottom: 8 * s,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kCardBorder),
        borderRadius: BorderRadius.only(
          topLeft: flushLeft ? Radius.zero : radius.topLeft,
          bottomLeft: flushLeft ? Radius.zero : radius.bottomLeft,
          topRight: flushRight ? Radius.zero : radius.topRight,
          bottomRight: flushRight ? Radius.zero : radius.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13 * s, color: _kGold),
          SizedBox(height: 5 * s),
          Text(
            label,
            style: _ui(size: 6.5 * s, color: _kTaupe, spacing: 0.8),
          ),
          SizedBox(height: 2 * s),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _ui(
              size: 8.5 * s,
              weight: FontWeight.w700,
              color: _kBlack,
              spacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.scale,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });
  final double scale;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: _display(size: 18 * s, weight: FontWeight.w600, color: _kInk),
          ),
        ),
        GestureDetector(
          onTap: onAction,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionLabel,
                style: _ui(
                  size: 8 * s,
                  weight: FontWeight.w700,
                  color: _kGold,
                  spacing: 0.5,
                ),
              ),
              SizedBox(width: 3 * s),
              Icon(Icons.arrow_forward_rounded, size: 12 * s, color: _kGold),
            ],
          ),
        ),
      ],
    );
  }
}

class _GalleryRow extends StatelessWidget {
  const _GalleryRow({required this.scale, required this.project});
  final double scale;
  final PortfolioProjectModel project;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final images = project.galleryImageUrls;
    final count = images.isEmpty ? 4 : images.length;
    return SizedBox(
      height: 88 * s,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, _) => SizedBox(width: 10 * s),
        itemBuilder: (_, i) {
          final url = images.isEmpty ? null : images[i];
          return ClipRRect(
            borderRadius: BorderRadius.circular(10 * s),
            child: SizedBox(
              width: 88 * s,
              height: 88 * s,
              child: url != null
                  ? Image.asset(url, fit: BoxFit.cover)
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        _kThumbGradient,
                        Center(
                          child: Icon(
                            Icons.crop_original_rounded,
                            size: 22 * s,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.scale, required this.project});
  final double scale;
  final PortfolioProjectModel project;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    if (project.team.isEmpty) {
      return Text(
        'Ekip bilgisi henüz eklenmedi.',
        style: _ui(size: 9 * s, color: _kTaupe, spacing: 0.2),
      );
    }
    return SizedBox(
      height: 78 * s,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: project.team.length,
        separatorBuilder: (_, _) => SizedBox(width: 18 * s),
        itemBuilder: (_, i) => _TeamAvatar(scale: s, member: project.team[i]),
      ),
    );
  }
}

class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({required this.scale, required this.member});
  final double scale;
  final PortfolioTeamMember member;

  String get _initials {
    final parts = member.name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCaseTr();
    }
    return member.name.isNotEmpty ? member.name[0].toUpperCaseTr() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      width: 60 * s,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48 * s,
            height: 48 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kGold.withValues(alpha: 0.10),
              border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
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
                    _initials,
                    style: _ui(
                      size: 11 * s,
                      weight: FontWeight.w700,
                      color: _kBlack,
                      spacing: 0.3,
                    ),
                  )
                : null,
          ),
          SizedBox(height: 6 * s),
          Text(
            member.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _ui(
              size: 8 * s,
              weight: FontWeight.w700,
              color: _kBlack,
              spacing: 0.2,
            ),
          ),
          SizedBox(height: 2 * s),
          Text(
            member.role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _ui(size: 6.5 * s, color: _kGold, spacing: 0.5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TEAM TAB (full list)
// ─────────────────────────────────────────────────────────────────
class _TeamTab extends StatelessWidget {
  const _TeamTab({required this.scale, required this.project});
  final double scale;
  final PortfolioProjectModel project;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    if (project.team.isEmpty) {
      return const _EmptyTab(
        icon: Icons.groups_outlined,
        text: 'Ekip bilgisi henüz eklenmedi.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kimler Çalıştı?',
          style: _display(size: 20 * s, weight: FontWeight.w600, color: _kInk),
        ),
        SizedBox(height: 16 * s),
        // Sayfa geneli 20*s yatay boşlukla kaydırılıyor; kartların ekranın
        // sağına/soluna kadar uzaması için OverflowBox ile tam ekran
        // genişliği veriyoruz (negatif padding Flutter'da assertion hatası
        // verdiğinden kullanılmıyor). Kartın kendi iç dolgusunu (20*s)
        // artırarak içerik hizasını korumuş oluyoruz. IntrinsicHeight,
        // OverflowBox'a sonlu bir yükseklik kısıtı sağlayıp Infinity/NaN
        // hatasını önlüyor.
        IntrinsicHeight(
          child: OverflowBox(
          maxWidth: MediaQuery.sizeOf(context).width,
          minWidth: MediaQuery.sizeOf(context).width,
          alignment: Alignment.center,
          child: Column(
            children: [
              for (final member in project.team) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * s,
                    vertical: 12 * s,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border.symmetric(
                      horizontal: BorderSide(color: _kCardBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      _TeamAvatarSmall(scale: s, member: member),
                      SizedBox(width: 12 * s),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _display(
                                size: 14 * s,
                                weight: FontWeight.w600,
                                color: _kInk,
                              ),
                            ),
                            SizedBox(height: 2 * s),
                            Text(
                              member.role,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _ui(
                                size: 8 * s,
                                color: _kGold,
                                spacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      GestureDetector(
                        onTap: () => Get.toNamed(
                          AppRoutes.portfolioTeamProfile,
                          arguments: {'member': member},
                        ),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * s,
                            vertical: 6 * s,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _kGold.withValues(alpha: 0.6),
                            ),
                            borderRadius: BorderRadius.circular(20 * s),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Profili Gör',
                                style: _ui(
                                  size: 7.5 * s,
                                  weight: FontWeight.w700,
                                  color: _kGold,
                                  spacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 3 * s),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 11 * s,
                                color: _kGold,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          ),
        ),
      ],
    );
  }
}

class _TeamAvatarSmall extends StatelessWidget {
  const _TeamAvatarSmall({required this.scale, required this.member});
  final double scale;
  final PortfolioTeamMember member;

  String get _initials {
    final parts = member.name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCaseTr();
    }
    return member.name.isNotEmpty ? member.name[0].toUpperCaseTr() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 44 * s,
      height: 44 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _kGold.withValues(alpha: 0.10),
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
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
              _initials,
              style: _ui(
                size: 11 * s,
                weight: FontWeight.w700,
                color: _kBlack,
                spacing: 0.3,
              ),
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PROCESS TAB (full vertical list)
// ─────────────────────────────────────────────────────────────────
// Aşama başlıklarına eşlik eden kısa, karizmatik yorum satırları.
// Bilinmeyen bir etiket gelirse jenerik bir metne düşer.
String _stageCaption(String label) {
  switch (label) {
    case 'Brief & Analiz':
      return 'Vizyon netleşti, yol haritası çizildi.';
    case 'Pre-Prodüksiyon':
      return 'Set kurulmadan önce her ayrıntı planlandı.';
    case 'Prodüksiyon':
      return 'Kamera arkası enerji, kadraj önünde hikaye.';
    case 'Post-Prodüksiyon':
      return 'Ham görüntüden anlatıya doğru ince işçilik.';
    case 'Teslim':
      return 'Vizyon, ekrana taşınmaya hazır.';
    default:
      return 'Bu aşama özenle yürütüldü.';
  }
}

class _ProcessTab extends StatelessWidget {
  const _ProcessTab({required this.scale, required this.project});
  final double scale;
  final PortfolioProjectModel project;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final stages = project.processStages;
    if (stages.isEmpty) {
      return const _EmptyTab(
        icon: Icons.timeline_outlined,
        text: 'Süreç bilgisi henüz eklenmedi.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Süreç Aşamaları',
          style: _display(size: 20 * s, weight: FontWeight.w600, color: _kInk),
        ),
        SizedBox(height: 18 * s),
        for (var i = 0; i < stages.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 26 * s,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: stages[i].done
                      ? Icon(Icons.check_rounded, size: 20 * s, color: _kGold)
                      : Text(
                          '${i + 1}'.padLeft(2, '0'),
                          style: _ui(
                            size: 9 * s,
                            weight: FontWeight.w700,
                            color: _kMuted,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 14 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stages[i].label,
                      style: _ui(
                        size: 11 * s,
                        weight: FontWeight.w700,
                        color: _kBlack,
                        spacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      _stageCaption(stages[i].label),
                      style: _ui(
                        size: 9 * s,
                        weight: FontWeight.w400,
                        color: _kBlack,
                        spacing: 0.2,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (i < stages.length - 1)
            Padding(
              // Üstte/altta boşluk bırakarak çizginin tik/rakam işaretlerine
              // değmemesini sağlıyoruz.
              padding: EdgeInsets.only(left: 12.3 * s, top: 6 * s, bottom: 6 * s),
              child: Container(
                width: 1.4 * s,
                height: 16 * s,
                color: stages[i].done
                    ? _kGold.withValues(alpha: 0.5)
                    : _kDivider,
              ),
            ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EMPTY TAB
// ─────────────────────────────────────────────────────────────────
class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: _kMuted),
            const SizedBox(height: 10),
            Text(
              text,
              style: _ui(size: 9, color: _kTaupe, spacing: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}
