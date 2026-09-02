// GEÇİCİ TANI DOSYASI — hero carousel'deki siyah sütun sorununu izole
// etmek için. Uygulamanın geri kalanına dokunmaz, teşhis bitince silinir.
//
//   flutter run -t lib/dev_hero_probe.dart -d emulator-5554
//
// ESKİ mod: VideoPlayer hep ağaçta, sayfa pasifken sadece pause ediliyor.
// YENİ mod: poster hep ağaçta, sayfa pasifken VideoPlayer ağaçtan çıkıyor.

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const _kCover = 'assets/images/placeholder/mercedes_bg.png';
const _kPoster = 'assets/images/placeholder/mercedes_project_image2.png';
const _kGallery = 'assets/images/placeholder/mercedes_project_image.png';
const _kVideo = 'assets/videos/mercedescampaign.mp4';

void main() => runApp(const _ProbeApp());

class _ProbeApp extends StatelessWidget {
  const _ProbeApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _ProbeHome(),
    );
  }
}

class _ProbeHome extends StatefulWidget {
  const _ProbeHome();

  @override
  State<_ProbeHome> createState() => _ProbeHomeState();
}

class _ProbeHomeState extends State<_ProbeHome> {
  bool _newMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDFB),
      body: SafeArea(
        child: Column(
          children: [
            _Carousel(key: ValueKey(_newMode), newMode: _newMode),
            const SizedBox(height: 20),
            Text(
              _newMode ? 'MOD: YENI (poster altta)' : 'MOD: ESKI (sadece video)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => _newMode = !_newMode),
              child: const Text('MODU DEGISTIR'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Carousel extends StatefulWidget {
  const _Carousel({super.key, required this.newMode});
  final bool newMode;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _activeIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    // Video sayfasında başla; test edilen geçiş video -> ilk görsel.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pageController.jumpToPage(1);
      _activeIndex.value = 1;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _activeIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (i) => _activeIndex.value = i,
            children: [
              Image.asset(_kCover, fit: BoxFit.cover),
              ValueListenableBuilder<int>(
                valueListenable: _activeIndex,
                builder: (_, index, _) => _VideoPage(
                  isActive: index == 1,
                  newMode: widget.newMode,
                ),
              ),
              Image.asset(_kGallery, fit: BoxFit.cover),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: ValueListenableBuilder<int>(
              valueListenable: _activeIndex,
              builder: (_, index, _) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: Colors.black54,
                child: Text(
                  '${index + 1}/3',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPage extends StatefulWidget {
  const _VideoPage({required this.isActive, required this.newMode});
  final bool isActive;
  final bool newMode;

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final c = VideoPlayerController.asset(_kVideo)
      ..setLooping(true)
      ..setVolume(0);
    _controller = c;
    c.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      debugPrint('PROBE video size=${c.value.size} active=${widget.isActive}');
      if (widget.isActive) c.play();
    }).catchError((Object e) {
      debugPrint('PROBE video ERROR: $e');
    });
  }

  @override
  void didUpdateWidget(covariant _VideoPage old) {
    super.didUpdateWidget(old);
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (widget.isActive != old.isActive) {
      widget.isActive ? c.play() : c.pause();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final ready = c != null && c.value.isInitialized;

    final video = ready
        ? FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: c.value.size.width,
              height: c.value.size.height,
              child: VideoPlayer(c),
            ),
          )
        : const ColoredBox(color: Color(0xFF262430));

    if (!widget.newMode) {
      // ESKI: video hep basiliyor, pasifken sadece duraklatiliyor.
      return video;
    }

    // YENI: poster hep altta, video yalnizca sayfa aktifken agacta.
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(_kPoster, fit: BoxFit.cover),
        if (ready && widget.isActive) video,
      ],
    );
  }
}
