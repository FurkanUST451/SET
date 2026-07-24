import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

/// Keşfet kartındaki videoya dokunulduğunda açılan tam ekran oynatıcı.
class WorkVideoPlayerView extends StatefulWidget {
  const WorkVideoPlayerView({
    super.key,
    required this.videoUrl,
    required this.title,
    this.thumbnailUrl,
  });

  final String videoUrl;
  final String title;

  // Video buffer/initialize olurken boş siyah ekran yerine anında gösterilir;
  // algılanan açılış hızını iyileştirir (gerçek buffer süresini değiştirmez).
  final String? thumbnailUrl;

  @override
  State<WorkVideoPlayerView> createState() => _WorkVideoPlayerViewState();
}

class _WorkVideoPlayerViewState extends State<WorkVideoPlayerView> {
  late final VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      }).catchError((_) {
        if (mounted) setState(() => _hasError = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: _hasError
            ? const Text(
                'Video oynatılamadı',
                style: TextStyle(color: Colors.white70),
              )
            : _controller.value.isInitialized
                ? GestureDetector(
                    onTap: _togglePlayback,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_controller),
                          if (!_controller.value.isPlaying)
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.35),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget.thumbnailUrl?.isNotEmpty ?? false)
                        CachedNetworkImage(
                          imageUrl: widget.thumbnailUrl!,
                          fit: BoxFit.contain,
                          errorWidget: (_, _, _) => const SizedBox.shrink(),
                        ),
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ],
                  ),
      ),
    );
  }
}
