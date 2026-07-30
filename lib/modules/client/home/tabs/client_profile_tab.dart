import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/avatar_image.dart';
import '../../../../data/models/project_model.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../../app/auth_controller.dart';
import '../../../app/user_controller.dart';
import '../client_home_controller.dart';
import '../client_projects_controller.dart';
import 'profile_screens.dart';
import '../../../../core/utils/turkish_case.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB); // arka plan
const _kGold = Color(0xFFD9A84E); // kritik / vurgu altın tonu
const _kInk = Color(0xFF35333F);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kDanger = Color(0xFFBE6A5A);
const _kDivider = Color(0x12000000);

// ─── Tipografi yardımcıları ───────────────────────────────────────────────────
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

class ClientProfileTab extends StatefulWidget {
  const ClientProfileTab({super.key});

  @override
  State<ClientProfileTab> createState() => _ClientProfileTabState();
}

class _ClientProfileTabState extends State<ClientProfileTab>
    with SingleTickerProviderStateMixin {
  // Kademeli (staggered) giriş animasyonu
  late final AnimationController _staggerController;
  static const _staggerCount = 7;

  // Profil sekmesinin bottom-nav'daki index'i (bkz. ClientHomeView._tabs)
  static const _profileTabIndex = 4;
  Worker? _tabWorker;

  final UserRepository _userRepo = Get.find<UserRepository>();
  final ClientProjectsController _projectsController =
      Get.find<ClientProjectsController>();
  bool _uploadingAvatar = false;

  Future<void> _editAvatar() async {
    final userC = Get.find<UserController>();
    final u = userC.currentUser;
    if (u == null) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${u.id}.jpg');
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();
      final updated = u.copyWith(avatarUrl: url);
      await _userRepo.upsertUser(updated);
      userC.setUser(updated);
    } catch (_) {
      if (mounted) {
        Get.snackbar(
          'Hata',
          'Yükleme başarısız oldu, tekrar dene',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Sekmeler IndexedStack ile tutulduğu için bu widget açılışta bir kez
    // oluşturulur. Animasyonu yalnızca Profil sekmesi görünürken oynat:
    // sekme her Profil'e geçtiğinde baştan başlat.
    final home = Get.find<ClientHomeController>();
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

    // Ölçek: 390px genişlik referans alınır; böylece her cihazda aynı oranlar
    // korunur. Aşırı büyük/küçük ekranlarda taşmayı önlemek için sınırlanır.
    final width = MediaQuery.sizeOf(context).width;
    final double s = (width / 390).clamp(0.85, 1.15).toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      // Sistem yazı tipi ölçeğini yok say → her cihazda birebir aynı görünüm.
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
                            child: _buildStatsSection(s),
                          ),
                          _StaggeredItem(
                            controller: _staggerController,
                            index: 2,
                            count: _staggerCount,
                            child: _buildSection(s, 'HESAP', [
                              _SettingsRow(
                                scale: s,
                                label: 'Profili Düzenle',
                                sub: 'Ad, bio, konum, dil',
                                onTap: () => Get.to<void>(
                                  () => const ProfileEditScreen(),
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
                            index: 3,
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
                            index: 4,
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
                            index: 5,
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
                          _StaggeredItem(
                            controller: _staggerController,
                            index: 6,
                            count: _staggerCount,
                            child: Padding(
                              padding: EdgeInsets.only(top: 60 * s),
                              child: Center(
                                child: Text(
                                  'SET · v1.0.0',
                                  style: _ui(
                                    size: 8 * s,
                                    color: _kBlack,
                                    spacing: 2,
                                  ),
                                ),
                              ),
                            ),
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

  // ─── Sayfa tepesi: SET · PROFİL + tam genişlik ayraç (sabit, kaymaz) ─────
  Widget _buildTopStrip(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(26 * s, 6 * s, 26 * s, 12 * s),
          child: Text(
            'SET · PROFİL',
            style: _ui(size: 8 * s, color: _kBlack, spacing: 2),
          ),
        ),
        Container(height: 1, color: _kDivider),
      ],
    );
  }

  // ─── Avatar + kimlik bilgisi ─────────────────────────────────────────────
  Widget _buildAvatarSection(UserController user, double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(26 * s, 24 * s, 26 * s, 0),
      child: Obx(() {
        final u = user.currentUser;
        final name = u?.name ?? 'Misafir';
        final email = u?.email ?? '';
        final initial = name.trim().isNotEmpty
            ? name.trim()[0].toUpperCaseTr()
            : '?';
        final avatarUrl = (u?.avatarUrl?.isNotEmpty ?? false)
            ? u!.avatarUrl!
            : placeholderAvatarFor(u?.gender, u?.id ?? name);
        return Row(
          children: [
            // Köşeleri yuvarlatılmış kare avatar
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10 * s),
                    child: SizedBox(
                      width: 72 * s,
                      height: 72 * s,
                      child: buildAvatarImage(
                        avatarUrl,
                        size: 72 * s,
                        placeholder: Text(
                          initial,
                          style: _display(
                            size: 24 * s,
                            weight: FontWeight.w500,
                            color: _kGold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(top: -5 * s, left: -5 * s, child: _corner(s, 0)),
                Positioned(top: -5 * s, right: -5 * s, child: _corner(s, 1)),
                Positioned(bottom: -5 * s, left: -5 * s, child: _corner(s, 2)),
                Positioned(bottom: -5 * s, right: -5 * s, child: _corner(s, 3)),
                Positioned(
                  right: -4 * s,
                  bottom: -4 * s,
                  child: GestureDetector(
                    onTap: _uploadingAvatar ? null : _editAvatar,
                    child: Container(
                      width: 22 * s,
                      height: 22 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kGold,
                        border: Border.all(color: _kCream, width: 1.6),
                      ),
                      alignment: Alignment.center,
                      child: _uploadingAvatar
                          ? SizedBox(
                              width: 10 * s,
                              height: 10 * s,
                              child: const CircularProgressIndicator(
                                strokeWidth: 1.6,
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.edit, size: 11 * s, color: Colors.white),
                    ),
                  ),
                ),
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
                      'MÜŞTERİ',
                      style: _ui(
                        size: 8 * s,
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
                    style: _ui(size: 8 * s, color: _kBlack, spacing: 0.2),
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

  // ─── Projelerim: oluşturulan / devam eden / tamamlanan proje sayıları ───────
  Widget _buildStatsSection(double s) {
    return Padding(
      padding: EdgeInsets.only(top: 58 * s),
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
                  'PROJELERİM',
                  style: _ui(
                    size: 8 * s,
                    weight: FontWeight.w700,
                    color: _kBlack,
                    spacing: 1.8,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    final home = Get.find<ClientHomeController>();
                    home.changeTab(3);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TÜMÜNÜ GÖR',
                        style: _ui(
                          size: 8 * s,
                          weight: FontWeight.w600,
                          color: _kBlack.withValues(alpha: 0.55),
                          spacing: 1,
                        ),
                      ),
                      SizedBox(width: 2 * s),
                      Icon(
                        Icons.chevron_right,
                        size: 12 * s,
                        color: _kBlack.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14 * s),
          Obx(() {
            final created = _projectsController.briefs.length;
            final ongoing = _projectsController.projects
                .where((p) => p.status == ProjectStatus.active)
                .length;
            final completed = _projectsController.projects
                .where((p) => p.status == ProjectStatus.completed)
                .length;
            return Row(
              children: [
                Expanded(
                  child: _StatTile(
                    scale: s,
                    value: created,
                    label: 'OLUŞTURULAN',
                  ),
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: _StatTile(
                    scale: s,
                    value: ongoing,
                    label: 'DEVAM EDEN',
                  ),
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: _StatTile(
                    scale: s,
                    value: completed,
                    label: 'TAMAMLANAN',
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── Bölüm: altın çizgi + başlık + sağda satır sayısı, sonra düz liste ──────
  Widget _buildSection(double s, String title, List<Widget> rows) {
    return Padding(
      // Ana gruplar arasında boşluk
      padding: EdgeInsets.only(top: 30 * s),
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
                    size: 8 * s,
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

// ─── İstatistik karosu ────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.scale,
    required this.value,
    required this.label,
  });

  final double scale;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14 * s, horizontal: 6 * s),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: _display(size: 26 * s, weight: FontWeight.w600, color: _kInk),
          ),
          SizedBox(height: 4 * s),
          Text(
            label,
            textAlign: TextAlign.center,
            style: _ui(size: 7 * s, color: _kBlack, spacing: 0.8),
          ),
        ],
      ),
    );
  }
}

// ─── Staggered giriş animasyonu ───────────────────────────────────────────────
// Her blok, index'ine göre gecikmeli olarak aşağıdan kayıp belirerek gelir.
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
    // Her öğe zaman çizelgesinin bir dilimini kaplar; sıradaki biraz sonra başlar.
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
    final titleColor = danger ? _kDanger : _kInk;

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
                      size: 12 * s,
                      weight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  if (sub != null) ...[
                    SizedBox(height: 3 * s),
                    Text(
                      sub!,
                      style: _ui(size: 8 * s, color: _kBlack, spacing: 0.2),
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
