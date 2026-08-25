import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/utils/avatar_image.dart';
import '../../../routes/app_routes.dart';

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kCream = Color(0xFFFEFDFB);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF35333F);
const _kTaupe = Color(0xFF9B8E7B);
const _kMuted = Color(0xFFB6AD9A);
const _kBlack = Color(0xFF000000); // UI etiket fontu - tam siyah
const _kCardBorder = Color(0x14000000);
const _kOnline = Color(0xFF4CAF50);

// ─── Tipografi yardımcıları ───────────────────────────────────────────────────
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

class SetProjectsView extends StatelessWidget {
  const SetProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    final double s = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.85, 1.15)
        .toDouble();

    return Scaffold(
      backgroundColor: _kCream,
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24 * s, 0, 24 * s, 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Geri oku — kendi satırında.
                GestureDetector(
                  onTap: () => Get.back<void>(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4 * s),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 22 * s,
                      color: _kInk,
                    ),
                  ),
                ),
                SizedBox(height: 8 * s),
                // Proje indeksi + dosya no — okun hemen altında, sayfa
                // bu çizgiyle başlar.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'PROJE / 01',
                      style: _ui(
                        size: 8 * s,
                        weight: FontWeight.w700,
                        color: _kGold,
                        spacing: 1.4,
                      ),
                    ),
                    SizedBox(width: 10 * s),
                    Expanded(child: Container(height: 1, color: _kCardBorder)),
                    SizedBox(width: 10 * s),
                    Text(
                      'DOSYA NO · SH-2405-118',
                      style: _ui(size: 8 * s, color: _kTaupe, spacing: 1),
                    ),
                  ],
                ),
                SizedBox(height: 16 * s),

                // Başlık
                Text(
                  'Cafe Tanıtım\nFilmi',
                  style: _display(
                    size: 40 * s,
                    weight: FontWeight.w600,
                    color: _kInk,
                  ),
                ),
                SizedBox(height: 16 * s),

                // Durum rozeti
                Row(
                  children: [
                    Container(
                      width: 8 * s,
                      height: 8 * s,
                      decoration: const BoxDecoration(color: _kGold),
                    ),
                    SizedBox(width: 8 * s),
                    Text(
                      'EKİP KURULUYOR',
                      style: _ui(
                        size: 9 * s,
                        weight: FontWeight.w700,
                        color: _kBlack,
                        spacing: 1.4,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20 * s),

                // Proje sorumlusu kartı (köşe işaretli çerçeve)
                _CornerFramed(
                  scale: s,
                  child: _ManagerCard(scale: s),
                ),
                SizedBox(height: 28 * s),
                Container(height: 1, color: _kCardBorder),
                SizedBox(height: 28 * s),

                // Süreç adımları
                _StepProgress(scale: s),
                SizedBox(height: 24 * s),
                Container(height: 1, color: _kCardBorder),
                SizedBox(height: 18 * s),

                // Güncelleme
                Text(
                  'GÜNCELLEME',
                  style: _ui(size: 8 * s, color: _kBlack, spacing: 1.5),
                ),
                SizedBox(height: 14 * s),
                _UpdateItem(scale: s),
                SizedBox(height: 28 * s),

                // Ekip Durumu
                _SectionHeader(scale: s, title: 'Ekip Durumu'),
                SizedBox(height: 14 * s),
                _TeamRow(scale: s),
                SizedBox(height: 28 * s),
                Container(height: 1, color: _kCardBorder),
                SizedBox(height: 18 * s),

                // Proje kimlik kartı — kenarlardan taşarak ekran
                // kenarlarına dayanır (Projelerim kartlarıyla aynı).
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: -24 * s),
                  child: _ProjectIdentityCard(scale: s),
                ),
                SizedBox(height: 14 * s),

                // Brif bilgileri
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: -24 * s),
                  child: _InfoSection(
                    scale: s,
                    icon: Icons.assignment_outlined,
                    label: 'BRİF BİLGİLERİ',
                    child: _buildBriefGrid(s),
                  ),
                ),
                SizedBox(height: 14 * s),

                // Proje bilgileri
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: -24 * s),
                  child: _InfoSection(
                    scale: s,
                    icon: Icons.info_outline,
                    label: 'PROJE BİLGİLERİ',
                    child: Padding(
                      padding: EdgeInsets.only(top: 14 * s),
                      child: Column(
                        children: [
                          _InfoRow(
                            scale: s,
                            label: 'Oluşturulma Tarihi',
                            value: '20 May 2026 - 09:15',
                          ),
                          SizedBox(height: 12 * s),
                          _InfoRow(
                            scale: s,
                            label: 'Son Güncelleme',
                            value: 'BUGÜN · 14:32',
                          ),
                          SizedBox(height: 12 * s),
                          _InfoRow(
                            scale: s,
                            label: 'Proje ID',
                            value: '#PRJ-2026-SH2405118',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Brif bilgi grid ────────────────────────────────────────────
  Widget _buildBriefGrid(double s) {
    const items = [
      _GridItem(
        icon: Icons.movie_creation_outlined,
        label: 'ÇEKİM TÜRÜ',
        value: 'Tanıtım Filmi',
      ),
      _GridItem(
        icon: Icons.calendar_today_outlined,
        label: 'ÇEKİM TARİHİ',
        value: '26 Mayıs',
      ),
      _GridItem(
        icon: Icons.access_time_outlined,
        label: 'TESLİM SÜRESİ',
        value: '7 Gün',
      ),
    ];
    const location = _GridItem(
      icon: Icons.location_on_outlined,
      label: 'LOKASYON',
      value: 'Beşiktaş',
      singleLine: true,
    );

    return Padding(
      padding: EdgeInsets.only(top: 16 * s),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in items)
                Expanded(
                  child: _GridCell(scale: s, item: item),
                ),
            ],
          ),
          SizedBox(height: 14 * s),
          Row(
            children: [
              Expanded(
                child: _GridCell(scale: s, item: location),
              ),
              const Expanded(child: SizedBox()),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Köşe işaretli çerçeve (kart etrafında dekoratif L köşeler)
// ---------------------------------------------------------------------------

class _CornerFramed extends StatelessWidget {
  const _CornerFramed({required this.scale, required this.child});
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Stack(
      children: [
        child,
        Positioned(top: 0, left: 0, child: _corner(s, 0)),
        Positioned(top: 0, right: 0, child: _corner(s, 1)),
        Positioned(bottom: 0, left: 0, child: _corner(s, 2)),
        Positioned(bottom: 0, right: 0, child: _corner(s, 3)),
      ],
    );
  }

  // quadrant: 0 = top-left, 1 = top-right, 2 = bottom-left, 3 = bottom-right
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
            child: Container(width: len, height: 1.4, color: _kGold),
          ),
          Positioned(
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            child: Container(width: 1.4, height: len, color: _kGold),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Proje sorumlusu kartı
// ---------------------------------------------------------------------------

class _ManagerCard extends StatelessWidget {
  const _ManagerCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipOval(
                    child: buildAvatarImage(
                      placeholderAvatarFor('kadin', 'selin-a-pm'),
                      size: 60 * s,
                      placeholder: Container(
                        width: 60 * s,
                        height: 60 * s,
                        color: const Color(0xFFE8D5C0),
                        child: Icon(Icons.person, size: 32 * s, color: _kTaupe),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 1 * s,
                    right: 1 * s,
                    child: Container(
                      width: 12 * s,
                      height: 12 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kOnline,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 14 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selin A.',
                      style: _display(
                        size: 22 * s,
                        weight: FontWeight.w600,
                        color: _kInk,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      'PROJE SORUMLUSU',
                      style: _ui(
                        size: 8 * s,
                        weight: FontWeight.w700,
                        color: _kGold,
                        spacing: 1,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Row(
                      children: [
                        Container(
                          width: 6 * s,
                          height: 6 * s,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kOnline,
                          ),
                        ),
                        SizedBox(width: 5 * s),
                        Text(
                          'ŞU AN ONLINE',
                          style: _ui(size: 8 * s, color: _kTaupe, spacing: 0.8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18 * s),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: _kCardBorder)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * s),
                child: Container(
                  width: 5 * s,
                  height: 5 * s,
                  decoration: const BoxDecoration(color: _kGold),
                ),
              ),
              Expanded(child: Container(height: 1, color: _kCardBorder)),
            ],
          ),
          SizedBox(height: 16 * s),
          Text(
            'Süreç boyunca tek muhatabın.',
            style: _display(
              size: 15 * s,
              weight: FontWeight.w500,
              color: _kInk,
              italic: true,
            ),
          ),
          SizedBox(height: 16 * s),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.chatDetail,
                    arguments: {'name': 'Selin A.', 'mode': 'set'},
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48 * s,
                    color: _kGold,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 15 * s,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8 * s),
                        Text(
                          'MESAJ GÖNDER',
                          style: _ui(
                            size: 9 * s,
                            weight: FontWeight.w700,
                            color: Colors.white,
                            spacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10 * s),
              GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 48 * s,
                  height: 48 * s,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _kInk, width: 1.2),
                  ),
                  child: Icon(Icons.call_outlined, size: 18 * s, color: _kInk),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Süreç adımları
// ---------------------------------------------------------------------------

class _StepInfo {
  const _StepInfo({
    required this.title,
    required this.description,
    required this.dateLabel,
    required this.icon,
    required this.isDone,
  });

  final String title;
  final String description;
  final String dateLabel;
  final IconData icon;
  final bool isDone;
}

const _steps = [
  _StepInfo(
    title: 'BRİF',
    description: 'Proje kapsamı ve hedefler netleştirildi.',
    dateLabel: '24 MAY',
    icon: Icons.check_rounded,
    isDone: true,
  ),
  _StepInfo(
    title: 'PLANLAMA',
    description: 'Çekim takvimi ve ekip planı oluşturuldu.',
    dateLabel: '25 MAY',
    icon: Icons.check_rounded,
    isDone: true,
  ),
  _StepInfo(
    title: 'EKİP OLUŞUMU',
    description: 'Yönetmen, görüntü yönetmeni ve ekip belirleniyor.',
    dateLabel: '',
    icon: Icons.groups_rounded,
    isDone: false,
  ),
  _StepInfo(
    title: 'ÇEKİM',
    description: 'Sahne çekimleri gerçekleştirilecek.',
    dateLabel: '',
    icon: Icons.videocam_rounded,
    isDone: false,
  ),
  _StepInfo(
    title: 'KURGU',
    description: 'Ham görüntüler kurgulanıp son haline getirilecek.',
    dateLabel: '',
    icon: Icons.content_cut_rounded,
    isDone: false,
  ),
  _StepInfo(
    title: 'TESLİM',
    description: 'Final dosyalar teslim edilecek.',
    dateLabel: '',
    icon: Icons.flag_rounded,
    isDone: false,
  ),
];
const _currentStep = 2;

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      children: [
        for (int i = 0; i < _steps.length; i++)
          _StepRow(scale: s, index: i, isLast: i == _steps.length - 1),
      ],
    );
  }
}

class _StepRow extends StatefulWidget {
  const _StepRow({
    required this.scale,
    required this.index,
    required this.isLast,
  });
  final double scale;
  final int index;
  final bool isLast;

  @override
  State<_StepRow> createState() => _StepRowState();
}

class _StepRowState extends State<_StepRow>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  bool get _isCurrent => widget.index == _currentStep;

  @override
  void initState() {
    super.initState();
    if (_isCurrent) {
      _pulse = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final step = _steps[widget.index];
    final isCurrent = _isCurrent;
    final isDone = step.isDone;
    final circleSize = 36.0 * s;

    Widget circle;
    if (isDone) {
      circle = Container(
        width: circleSize,
        height: circleSize,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: _kGold),
        child: Icon(Icons.check_rounded, size: 16 * s, color: Colors.white),
      );
    } else if (isCurrent) {
      circle = AnimatedBuilder(
        animation: _pulse!,
        builder: (context, child) {
          final t = _pulse!.value;
          return Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kGold,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15 + 0.75 * t),
                width: 2.2 * s,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withValues(alpha: 0.45 * t),
                  blurRadius: 10 * s,
                  spreadRadius: 2 * s,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Icon(step.icon, size: 16 * s, color: Colors.white),
      );
    } else {
      circle = Container(
        width: circleSize,
        height: circleSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.fromBorderSide(BorderSide(color: _kCardBorder)),
        ),
        child: Icon(step.icon, size: 15 * s, color: _kMuted),
      );
    }

    final titleColor = isCurrent ? _kInk : (isDone ? _kTaupe : _kMuted);
    final descColor = isCurrent ? _kInk.withValues(alpha: 0.75) : _kMuted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              circle,
              if (!widget.isLast)
                Expanded(
                  child: Container(
                    width: 1.6,
                    margin: EdgeInsets.symmetric(vertical: 4 * s),
                    color: widget.index < _currentStep
                        ? _kGold.withValues(alpha: 0.5)
                        : _kCardBorder,
                  ),
                ),
            ],
          ),
          SizedBox(width: 14 * s),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 22 * s),
              child: Container(
                padding: isCurrent
                    ? EdgeInsets.all(12 * s)
                    : EdgeInsets.symmetric(vertical: 2 * s),
                decoration: isCurrent
                    ? BoxDecoration(
                        color: _kGold.withValues(alpha: 0.08),
                        border: Border.all(
                          color: _kGold.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          step.title,
                          style: _ui(
                            size: 10.5 * s,
                            weight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: titleColor,
                            spacing: 0.6,
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6 * s,
                              vertical: 3 * s,
                            ),
                            color: _kGold,
                            child: Text(
                              'ŞU AN',
                              style: _ui(
                                size: 6.5 * s,
                                weight: FontWeight.w700,
                                color: Colors.white,
                                spacing: 0.8,
                              ),
                            ),
                          )
                        else if (step.dateLabel.isNotEmpty)
                          Text(
                            step.dateLabel,
                            style: _ui(
                              size: 7 * s,
                              weight: FontWeight.w600,
                              color: _kTaupe,
                              spacing: 0.6,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      step.description,
                      style: _ui(
                        size: 8.5 * s,
                        color: descColor,
                        spacing: 0.2,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Son güncelleme
// ---------------------------------------------------------------------------

class _UpdateItem extends StatelessWidget {
  const _UpdateItem({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6 * s,
          height: 6 * s,
          margin: EdgeInsets.only(top: 6 * s),
          decoration: const BoxDecoration(color: _kGold),
        ),
        SizedBox(width: 12 * s),
        ClipOval(
          child: buildAvatarImage(
            placeholderAvatarFor('kadin', 'set-update-selin'),
            size: 36 * s,
            placeholder: Container(
              width: 36 * s,
              height: 36 * s,
              color: const Color(0xFFEADCBB),
              child: Icon(Icons.person, size: 20 * s, color: _kTaupe),
            ),
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selin A.',
                    style: _ui(
                      size: 10 * s,
                      weight: FontWeight.w700,
                      color: _kInk,
                      spacing: 0.2,
                    ),
                  ),
                  Text(
                    'BUGÜN · 14:32',
                    style: _ui(size: 8 * s, color: _kTaupe, spacing: 0.3),
                  ),
                ],
              ),
              SizedBox(height: 6 * s),
              Text(
                'Yönetmen ve görüntü yönetmeniyle toplantı gerçekleştirildi. Mekan keşfi 26 Mayıs\'ta.',
                style: _ui(
                  size: 9.5 * s,
                  color: _kBlack,
                  spacing: 0.2,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ortak bölüm başlığı
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.scale, required this.title});
  final double scale;
  final String title;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: [
        Text(
          title,
          style: _display(size: 20 * s, weight: FontWeight.w600, color: _kInk),
        ),
        const Spacer(),
        Text(
          'TÜMÜNÜ GÖR',
          style: _ui(
            size: 8 * s,
            weight: FontWeight.w700,
            color: _kGold,
            spacing: 1,
          ),
        ),
        SizedBox(width: 4 * s),
        Icon(Icons.arrow_forward_rounded, size: 12 * s, color: _kGold),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ekip durumu
// ---------------------------------------------------------------------------

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
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipOval(
                      child: buildAvatarImage(
                        placeholderAvatarFor(null, m.$1),
                        size: 52 * s,
                        placeholder: Container(
                          width: 52 * s,
                          height: 52 * s,
                          color: const Color(0xFFE8D5C0),
                          child: Icon(
                            Icons.person,
                            size: 26 * s,
                            color: _kTaupe,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14 * s,
                        height: 14 * s,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: found ? _kOnline : _kGold,
                          border: Border.all(color: Colors.white, width: 1.4),
                        ),
                        child: Icon(
                          found ? Icons.check_rounded : Icons.search_rounded,
                          size: 8 * s,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * s),
                Text(
                  m.$1,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _ui(
                    size: 7.5 * s,
                    weight: FontWeight.w700,
                    color: _kBlack,
                    spacing: 0.2,
                  ),
                ),
                SizedBox(height: 3 * s),
                Text(
                  m.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _ui(
                    size: 7 * s,
                    color: found ? _kOnline : _kGold,
                    spacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Proje kimlik kartı (Projelerim > Proje Detayı ile aynı tasarım dili)
// ---------------------------------------------------------------------------

class _ProjectIdentityCard extends StatelessWidget {
  const _ProjectIdentityCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 42 * s, vertical: 18 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _kCardBorder),
          bottom: BorderSide(color: _kCardBorder),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48 * s,
            height: 48 * s,
            decoration: const BoxDecoration(color: Colors.white),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/main_service_icons/video.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.videocam_rounded, size: 24 * s, color: _kGold),
            ),
          ),
          SizedBox(width: 14 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ONAYLI PROJE',
                  style: _ui(
                    size: 8 * s,
                    weight: FontWeight.w700,
                    color: _kGold,
                    spacing: 1.2,
                  ),
                ),
                SizedBox(height: 5 * s),
                Text(
                  'Video Çekim',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _display(
                    size: 22 * s,
                    weight: FontWeight.w600,
                    color: _kInk,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  'Cafe Tanıtım Filmi',
                  style: _ui(size: 8 * s, color: _kBlack, spacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bilgi bölümü — başlıklı kart (BRİF BİLGİLERİ / PROJE BİLGİLERİ)
// ---------------------------------------------------------------------------

class _InfoSection extends StatelessWidget {
  const _InfoSection({
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
      padding: EdgeInsets.symmetric(horizontal: 42 * s, vertical: 18 * s),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _kCardBorder),
          bottom: BorderSide(color: _kCardBorder),
        ),
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
                  style: _ui(
                    size: 8 * s,
                    weight: FontWeight.w700,
                    color: _kBlack,
                    spacing: 1.4,
                  ),
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

// ── Grid hücresi ─────────────────────────────────────────────────
class _GridItem {
  const _GridItem({
    required this.icon,
    required this.label,
    required this.value,
    this.singleLine = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool singleLine;
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
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _ui(size: 7 * s, color: _kBlack, spacing: 0.8),
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * s),
        if (item.singleLine)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              item.value,
              maxLines: 1,
              style: _ui(
                size: 10 * s,
                weight: FontWeight.w400,
                color: _kBlack,
                spacing: 0.2,
              ),
            ),
          )
        else
          Text(
            item.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _ui(
              size: 10 * s,
              weight: FontWeight.w400,
              color: _kBlack,
              spacing: 0.2,
            ),
          ),
      ],
    );
  }
}

// ── Bilgi satırı ─────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.scale,
    required this.label,
    required this.value,
  });
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
            style: _ui(size: 9 * s, color: _kBlack, spacing: 0.3),
          ),
        ),
        SizedBox(width: 10 * s),
        Text(
          value,
          style: _ui(
            size: 9 * s,
            weight: FontWeight.w700,
            color: _kBlack,
            spacing: 0.3,
          ),
        ),
      ],
    );
  }
}
