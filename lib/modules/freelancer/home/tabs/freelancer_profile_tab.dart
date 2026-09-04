import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_fonts.dart';

import '../../../../routes/app_routes.dart';
import '../../../app/auth_controller.dart';
import '../../../app/user_controller.dart';
import '../../../client/home/tabs/profile_screens.dart';
import '../freelancer_home_controller.dart';
import '../../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kDivider = Color(0x12000000);

// Öbekler (PROJELERİM / HESAP / TERCİHLER / DESTEK / OTURUM) arasındaki dikey
// boşluk. Profil fotoğrafının üst payı da aynı değeri kullanır; böylece
// fotoğrafın üstünde ve altında eşit alan kalır.
const double _kGroupGap = 44;

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
}) => AppFonts.ui(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
);

class FreelancerProfileTab extends StatefulWidget {
  const FreelancerProfileTab({super.key});

  @override
  State<FreelancerProfileTab> createState() => _FreelancerProfileTabState();
}

class _FreelancerProfileTabState extends State<FreelancerProfileTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;
  static const _staggerCount = 5;

  // Profil sekmesinin bottom-nav'daki index'i (bkz. FreelancerHomeView._tabs)
  static const _profileTabIndex = 4;
  Worker? _tabWorker;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    final home = Get.find<FreelancerHomeController>();
    if (home.currentIndex.value == _profileTabIndex) {
      _staggerController.forward();
    }
    _tabWorker = ever<int>(home.currentIndex, (index) {
      if (index == _profileTabIndex && mounted) {
        _staggerController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _tabWorker?.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Get.find<UserController>();
    final auth = Get.find<AuthController>();

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
              _buildTopStrip(s),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _StaggeredItem(
                        controller: _staggerController,
                        index: 0,
                        count: _staggerCount,
                        child: _buildAvatarSection(user, s),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(26 * s, 0, 26 * s, 130 * s),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _StaggeredItem(
                            controller: _staggerController,
                            index: 1,
                            count: _staggerCount,
                            child: _buildSection(s, 'HESAP', [
                              _SettingsRow(
                                scale: s,
                                label: 'Profili Düzenle',
                                sub: 'Fotoğraf, portfolyo ve etkileşimlerin',
                                onTap: () => Get.to<void>(
                                  () => const FreelancerOwnProfileScreen(),
                                ),
                              ),
                              _SettingsRow(
                                scale: s,
                                label: 'E-posta & Telefon',
                                sub: 'İletişim bilgilerini güncelle',
                                onTap: () => Get.to<void>(
                                  () => const ContactInfoScreen(),
                                ),
                              ),
                              _SettingsRow(
                                scale: s,
                                label: 'Şifre Değiştir',
                                sub: 'Güvenlik & oturum anahtarları',
                                onTap: () => Get.to<void>(
                                  () => const PasswordChangeScreen(),
                                ),
                              ),
                            ]),
                          ),
                          _StaggeredItem(
                            controller: _staggerController,
                            index: 2,
                            count: _staggerCount,
                            child: _buildSection(s, 'TERCİHLER', [
                              _SettingsRow(
                                scale: s,
                                label: 'Bildirimler',
                                sub: 'Push, e-posta tercihleri',
                                onTap: () => Get.to<void>(
                                  () => const NotificationSettingsScreen(),
                                ),
                              ),
                              _SettingsRow(
                                scale: s,
                                label: 'Dil & Bölge',
                                sub: 'Türkçe',
                                onTap: () => Get.to<void>(
                                  () => const LanguageRegionScreen(),
                                ),
                              ),
                            ]),
                          ),
                          _StaggeredItem(
                            controller: _staggerController,
                            index: 3,
                            count: _staggerCount,
                            child: _buildSection(s, 'DESTEK', [
                              _SettingsRow(
                                scale: s,
                                label: 'Yardım Merkezi',
                                onTap: () => Get.to<void>(
                                  () => const HelpCenterScreen(),
                                ),
                              ),
                              _SettingsRow(
                                scale: s,
                                label: 'Bize Ulaş',
                                onTap: () =>
                                    Get.to<void>(() => const ContactUsScreen()),
                              ),
                              _SettingsRow(
                                scale: s,
                                label: 'Kullanım Koşulları',
                                onTap: () =>
                                    Get.to<void>(() => const TermsScreen()),
                              ),
                            ]),
                          ),
                          _StaggeredItem(
                            controller: _staggerController,
                            index: 4,
                            count: _staggerCount,
                            child: _buildSection(s, 'OTURUM', [
                              _SettingsRow(
                                scale: s,
                                label: 'Rolümü Değiştir',
                                onTap: () =>
                                    Get.offAllNamed(AppRoutes.roleSelection),
                              ),
                              _SettingsRow(
                                scale: s,
                                label: 'Çıkış Yap',
                                danger: true,
                                onTap: () async {
                                  await auth.logout();
                                  Get.offAllNamed(AppRoutes.login);
                                },
                              ),
                              _SettingsRow(
                                scale: s,
                                label: 'Hesabı Sil',
                                danger: true,
                                onTap: () => Get.to<void>(
                                  () => const DeleteAccountScreen(),
                                ),
                              ),
                            ]),
                          ),
                        ]),
                      ),
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

  // ─── Üst başlık: SET / HESABIM (sabit, kaymaz) ──────────────────────────────
  Widget _buildTopStrip(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(26 * s, 22 * s, 26 * s, 14 * s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'SE',
                      style: AppFonts.display(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                        letterSpacing: 2.5,
                      ),
                    ),
                    TextSpan(
                      text: 'T',
                      style: AppFonts.display(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w800,
                        color: _kGold,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'HESABIM',
                style: _ui(size: 10 * s, color: _kBlack, spacing: 2),
              ),
            ],
          ),
        ),
        Container(height: 1, color: _kDivider),
      ],
    );
  }

  // ─── Avatar + kimlik bilgisi ─────────────────────────────────────────────
  Widget _buildAvatarSection(UserController user, double s) {
    return Padding(
      // Fotoğrafın üstündeki pay; altındaki eşdeğer boşluk bir sonraki
      // öbeğin üst payından (_kGroupGap) gelir.
      padding: EdgeInsets.fromLTRB(26 * s, _kGroupGap * s, 26 * s, 0),
      child: Obx(() {
        final u = user.currentUser;
        final name = u?.name ?? 'Freelancer';
        final email = u?.email ?? '';
        final initial = name.trim().isNotEmpty
            ? name.trim()[0].toUpperCaseTr()
            : '?';
        return Row(
          children: [
            // Köşeleri yuvarlatılmış kare avatar + çentik süslemesi
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 72 * s,
                  height: 72 * s,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10 * s),
                    color: Colors.white.withValues(alpha: 0.45),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: _display(
                      size: 24 * s,
                      weight: FontWeight.w500,
                      color: _kGold,
                    ),
                  ),
                ),
                Positioned(top: -5 * s, left: -5 * s, child: _corner(s, 0)),
                Positioned(top: -5 * s, right: -5 * s, child: _corner(s, 1)),
                Positioned(bottom: -5 * s, left: -5 * s, child: _corner(s, 2)),
                Positioned(bottom: -5 * s, right: -5 * s, child: _corner(s, 3)),
              ],
            ),
            SizedBox(width: 18 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9 * s,
                      vertical: 3.5 * s,
                    ),
                    decoration: BoxDecoration(
                      color: _kGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _kGold.withValues(alpha: 0.45)),
                    ),
                    child: Text(
                      'FREELANCER',
                      style: _ui(
                        size: 10 * s,
                        weight: FontWeight.w700,
                        color: _kGold,
                        spacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _display(
                      size: 24 * s,
                      weight: FontWeight.w600,
                      color: _kInk,
                    ),
                  ),
                  SizedBox(height: 3 * s),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ui(size: 13 * s, color: _kBlack, spacing: 0.2),
                  ),
                  SizedBox(height: 10 * s),
                  Text(
                    '12 PROJE · 4.9 PUAN · 3Y DENEYİM',
                    style: _ui(size: 7.5 * s, color: _kBlack, spacing: 1),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // Köşe çentiği: ana hizmet kartlarında kullanılan işaretin aynısı.
  Widget _corner(double s, int quadrant) {
    final len = 12 * s;
    final isLeft = quadrant == 0 || quadrant == 2;
    final isTop = quadrant == 0 || quadrant == 1;
    return SizedBox(
      width: len,
      height: len,
      child: Stack(
        children: [
          Positioned(
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            child: Container(width: len, height: 1.4, color: _kInk),
          ),
          Positioned(
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            child: Container(width: 1.4, height: len, color: _kInk),
          ),
        ],
      ),
    );
  }

  // ─── Bölüm: altın çizgi + başlık + sağda satır sayısı, sonra düz liste ──────
  Widget _buildSection(double s, String title, List<Widget> rows) {
    return Padding(
      // Ana gruplar arasında boşluk
      padding: EdgeInsets.only(top: _kGroupGap * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2 * s),
            child: Row(
              children: [
                Container(width: 18 * s, height: 2, color: _kGold),
                SizedBox(width: 10 * s),
                Text(
                  title,
                  style: _ui(
                    size: 10 * s,
                    weight: FontWeight.w700,
                    color: _kBlack,
                    spacing: 1.8,
                  ),
                ),
                const Spacer(),
                Text(
                  rows.length.toString().padLeft(2, '0'),
                  style: _ui(size: 8 * s, color: _kBlack, spacing: 1),
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * s),
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              const Divider(height: 1, thickness: 1, color: _kDivider),
          ],
        ],
      ),
    );
  }
}

// ─── Staggered giriş animasyonu ───────────────────────────────────────────────
class _StaggeredItem extends StatelessWidget {
  const _StaggeredItem({
    required this.controller,
    required this.index,
    required this.count,
    required this.child,
  });

  final AnimationController controller;
  final int index;
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double slot = 1 / (count + 2);
    final double start = index * slot;
    final double end = (start + slot * 3).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 48),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ─── Ayar satırı ──────────────────────────────────────────────────────────────
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.scale,
    required this.label,
    this.sub,
    this.onTap,
    this.danger = false,
  });

  final double scale;
  final String label;
  final String? sub;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final titleColor = danger ? const Color(0xFFBE6A5A) : _kInk;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20 * s),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: _display(
                      size: 17 * s,
                      weight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  if (sub != null) ...[
                    SizedBox(height: 3 * s),
                    Text(
                      sub!,
                      style: _ui(size: 13 * s, color: _kBlack, spacing: 0.2),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null && !danger)
              Icon(
                Icons.chevron_right,
                size: 16 * s,
                color: Colors.black.withValues(alpha: 0.22),
              ),
          ],
        ),
      ),
    );
  }
}
