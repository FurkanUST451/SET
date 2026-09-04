import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../../routes/app_routes.dart';

// "Nasıl işliyor?" tanıtımı için ayrı bir video henüz assets'te yok; yer
// tutucu olarak vitrindeki tek video dosyası oynatılıyor. Gerçek tanıtım
// eklendiğinde yalnızca bu sabitin ve _kChapters'ın güncellenmesi yeterli.
const String _kVideoAsset = 'assets/videos/mercedescampaign.mp4';

// (sıra no, başlık, videodaki başlangıç saniyesi)
const _kChapters = <(String, String, int)>[
  ('01', 'Brief\'ini anlat', 0),
  ('02', 'Yolunu seç', 14),
  ('03', 'Süreci izle', 29),
];

// ─── Palet ────────────────────────────────────────────────────────────────────
const _kPanel = Color(0xFFFAF9F6);
const _kGold = Color(0xFFD9A84E);
const _kInk = Color(0xFF1F1D26);
const _kBlack = Color(0xFF000000);
const _kTaupe = Color(0xFF8E8778);
const _kMuted = Color(0xFF6E685E);
const _kHair = Color(0x14000000);
const _kVideoBg = Color(0xFF14130F);

TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w700,
  required Color color,
  double height = 1.02,
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
  double spacing = 0.2,
  double height = 1.35,
}) => AppFonts.ui(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
  height: height,
);

/// Ana sayfadaki "İZLE" düğmesinin ve brief akışındaki video çubuğunun
/// açtığı tanıtım penceresi.
///
/// [ctaLabel] verilmezse (ör. brief akışının içinden açıldığında, kullanıcı
/// zaten brief oluşturmuşken) alttaki altın düğme gizlenir; pencere yalnızca
/// [closeLabel] bağlantısıyla kapanır.
Future<void> showHowItWorksModal({
  String? ctaLabel = 'İLK BRIEF\'İNİ OLUŞTUR',
  VoidCallback? onCta,
  String closeLabel = 'Şimdilik geç',
}) => Get.dialog<void>(
  _HowItWorksModal(
    ctaLabel: ctaLabel,
    onCta: onCta,
    closeLabel: closeLabel,
  ),
  barrierColor: _kBlack.withValues(alpha: 0.62),
);

class _HowItWorksModal extends StatefulWidget {
  const _HowItWorksModal({
    required this.ctaLabel,
    required this.onCta,
    required this.closeLabel,
  });

  final String? ctaLabel;
  final VoidCallback? onCta;
  final String closeLabel;

  @override
  State<_HowItWorksModal> createState() => _HowItWorksModalState();
}

class _HowItWorksModalState extends State<_HowItWorksModal> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(_kVideoAsset)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
      }).catchError((Object _) {
        if (!mounted) return;
        setState(() => _failed = true);
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    c.value.isPlaying ? c.pause() : c.play();
  }

  void _seekToChapter(int seconds) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    c.seekTo(Duration(seconds: seconds));
    c.play();
  }

  void _close() => Get.back<void>();

  @override
  Widget build(BuildContext context) {
    final double s = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.85, 1.15)
        .toDouble();
    final pad = EdgeInsets.symmetric(horizontal: 22 * s);

    return MediaQuery.withNoTextScaling(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 24 * s),
          child: Material(
            color: _kPanel,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Başlık çubuğu ────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(22 * s, 16 * s, 14 * s, 12 * s),
                    child: Row(
                      children: [
                        Text(
                          'SET · 01',
                          style: _ui(
                            size: 10 * s,
                            weight: FontWeight.w700,
                            color: _kGold,
                            spacing: 1.6,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _close,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: EdgeInsets.all(6 * s),
                            child: Icon(
                              Icons.close_rounded,
                              size: 20 * s,
                              color: _kInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: pad,
                    child: Container(height: 1, color: _kHair),
                  ),

                  // ── Başlık ───────────────────────────────────────────────
                  SizedBox(height: 18 * s),
                  Padding(
                    padding: pad,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nasıl işliyor?',
                          style: _display(size: 26 * s, color: _kInk),
                        ),
                        SizedBox(height: 7 * s),
                        Text(
                          '40 saniyede tüm süreç.',
                          style: _ui(size: 12.5 * s, color: _kTaupe),
                        ),
                      ],
                    ),
                  ),

                  // ── Video ────────────────────────────────────────────────
                  SizedBox(height: 16 * s),
                  _VideoBlock(
                    scale: s,
                    controller: _controller,
                    ready: _ready,
                    failed: _failed,
                    onToggle: _togglePlay,
                  ),

                  // ── Bölümler ─────────────────────────────────────────────
                  SizedBox(height: 18 * s),
                  Padding(
                    padding: pad,
                    child: Container(
                      width: 26 * s,
                      height: 2 * s,
                      color: _kGold,
                    ),
                  ),
                  SizedBox(height: 11 * s),
                  Padding(
                    padding: pad,
                    child: Text(
                      'BÖLÜMLER',
                      style: _ui(
                        size: 9.5 * s,
                        weight: FontWeight.w700,
                        color: _kGold,
                        spacing: 1.6,
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  _ChapterList(
                    scale: s,
                    controller: _controller,
                    horizontalPadding: 22 * s,
                    onSelect: _seekToChapter,
                  ),

                  // ── Aksiyonlar ───────────────────────────────────────────
                  SizedBox(height: 18 * s),
                  if (widget.ctaLabel != null) ...[
                    Padding(
                      padding: pad,
                      child: GestureDetector(
                        onTap: () {
                          _close();
                          final onCta = widget.onCta;
                          if (onCta != null) {
                            onCta();
                          } else {
                            Get.toNamed(AppRoutes.categoryPicker);
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 46 * s,
                          alignment: Alignment.center,
                          color: _kGold,
                          child: Text(
                            widget.ctaLabel!,
                            style: _ui(
                              size: 10.5 * s,
                              weight: FontWeight.w700,
                              color: _kBlack,
                              spacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 14 * s),
                  ],
                  Center(
                    child: GestureDetector(
                      onTap: _close,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12 * s,
                          vertical: 4 * s,
                        ),
                        child: Text(
                          widget.closeLabel,
                          style:
                              _ui(
                                size: 12 * s,
                                weight: FontWeight.w500,
                                color: _kMuted,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: _kMuted,
                              ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18 * s),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Video bloğu — kart genişliğince, altında zaman şeridi ────────────────────
class _VideoBlock extends StatelessWidget {
  const _VideoBlock({
    required this.scale,
    required this.controller,
    required this.ready,
    required this.failed,
    required this.onToggle,
  });

  final double scale;
  final VideoPlayerController? controller;
  final bool ready;
  final bool failed;
  final VoidCallback onToggle;

  static String _clock(Duration d) {
    final m = d.inMinutes;
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final c = controller;

    return AspectRatio(
      aspectRatio: 1.9,
      child: GestureDetector(
        onTap: onToggle,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: _kVideoBg,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (ready && c != null)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: c.value.size.width,
                    height: c.value.size.height,
                    child: VideoPlayer(c),
                  ),
                ),

              // Karartma — üstteki zaman/oynat katmanı okunur kalsın.
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0x33000000)),
                ),
              ),

              if (failed)
                Center(
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 34 * s,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                )
              else if (c == null)
                const SizedBox.shrink()
              else
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: c,
                  builder: (_, value, _) {
                    final total = value.duration;
                    final position = value.position;
                    final progress =
                        total.inMilliseconds == 0
                        ? 0.0
                        : (position.inMilliseconds / total.inMilliseconds)
                              .clamp(0.0, 1.0);

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        if (!value.isPlaying)
                          Center(
                            child: Container(
                              width: 52 * s,
                              height: 40 * s,
                              alignment: Alignment.center,
                              color: _kGold,
                              child: Icon(
                                Icons.play_arrow_rounded,
                                size: 26 * s,
                                color: _kBlack,
                              ),
                            ),
                          ),

                        // Zaman etiketleri ve ilerleme şeridi
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14 * s,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _clock(position),
                                      style: _ui(
                                        size: 10 * s,
                                        weight: FontWeight.w600,
                                        color: Colors.white,
                                        spacing: 0.6,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _clock(total),
                                      style: _ui(
                                        size: 10 * s,
                                        weight: FontWeight.w600,
                                        color: Colors.white,
                                        spacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8 * s),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  14 * s,
                                  0,
                                  14 * s,
                                  10 * s,
                                ),
                                child: SizedBox(
                                  height: 2 * s,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: (progress * 1000).round(),
                                        child: Container(color: _kGold),
                                      ),
                                      Expanded(
                                        flex: 1000 - (progress * 1000).round(),
                                        child: Container(
                                          color: Colors.white.withValues(
                                            alpha: 0.45,
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
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bölüm listesi — oynatma konumuna göre aktif satır vurgulanır ─────────────
class _ChapterList extends StatelessWidget {
  const _ChapterList({
    required this.scale,
    required this.controller,
    required this.horizontalPadding,
    required this.onSelect,
  });

  final double scale;
  final VideoPlayerController? controller;
  final double horizontalPadding;
  final ValueChanged<int> onSelect;

  static String _clock(int seconds) {
    final m = seconds ~/ 60;
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  /// Konumu kapsayan son bölümün sırası.
  int _activeIndex(Duration position) {
    var active = 0;
    for (var i = 0; i < _kChapters.length; i++) {
      if (position.inSeconds >= _kChapters[i].$3) active = i;
    }
    return active;
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null) return _build(0);
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: c,
      builder: (_, value, _) => _build(_activeIndex(value.position)),
    );
  }

  Widget _build(int activeIndex) {
    final s = scale;
    final rows = <Widget>[];

    for (var i = 0; i < _kChapters.length; i++) {
      final chapter = _kChapters[i];
      final isActive = i == activeIndex;

      if (i > 0) {
        rows.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Container(height: 1, color: _kHair),
          ),
        );
      }

      rows.add(
        GestureDetector(
          onTap: () => onSelect(chapter.$3),
          behavior: HitTestBehavior.opaque,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isActive ? _kGold : Colors.transparent,
                  width: 2.5 * s,
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding - (isActive ? 2.5 * s : 0),
              13 * s,
              horizontalPadding,
              13 * s,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 34 * s,
                  child: Text(
                    chapter.$1,
                    style: _ui(
                      size: 11 * s,
                      weight: FontWeight.w600,
                      color: isActive ? _kInk : _kTaupe,
                      spacing: 0.8,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    chapter.$2,
                    style: _ui(
                      size: 13 * s,
                      weight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: _kInk,
                      spacing: 0.1,
                    ),
                  ),
                ),
                SizedBox(width: 10 * s),
                Text(
                  _clock(chapter.$3),
                  style: _ui(
                    size: 11 * s,
                    weight: FontWeight.w600,
                    color: isActive ? _kGold : _kTaupe,
                    spacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}
