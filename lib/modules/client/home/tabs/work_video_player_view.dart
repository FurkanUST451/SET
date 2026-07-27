import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

const _kGold = Color(0xFFD9A84E);

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
      body: _hasError
          ? const Center(
              child: Text(
                'Video oynatılamadı',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : _controller.value.isInitialized
              ? Stack(
                  children: [
                    Center(
                      child: GestureDetector(
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
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _VideoControlsBar(
                        controller: _controller,
                        onTogglePlay: _togglePlayback,
                      ),
                    ),
                  ],
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
    );
  }
}

// ─── Alt kontrol çubuğu: oynat/durdur, 10sn geri/ileri sarma, ilerleme
// çubuğu (sürüklenebilir) ve süre göstergesi. controller'ı doğrudan
// dinlediği için (ValueListenableBuilder) üst widget'ın setState'ine
// bağımlı değil — sürükleyerek sarma anında yansır.
class _VideoControlsBar extends StatelessWidget {
  const _VideoControlsBar({
    required this.controller,
    required this.onTogglePlay,
  });

  final VideoPlayerController controller;
  final VoidCallback onTogglePlay;

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  void _seekBy(Duration offset) {
    final target = controller.value.position + offset;
    final duration = controller.value.duration;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > duration ? duration : target);
    controller.seekTo(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return Container(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  padding: EdgeInsets.zero,
                  colors: const VideoProgressColors(
                    playedColor: _kGold,
                    bufferedColor: Colors.white30,
                    backgroundColor: Colors.white12,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white),
                      onPressed: () => _seekBy(const Duration(seconds: -10)),
                    ),
                    IconButton(
                      icon: Icon(
                        value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                      onPressed: onTogglePlay,
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10, color: Colors.white),
                      onPressed: () => _seekBy(const Duration(seconds: 10)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        value.volume == 0
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          controller.setVolume(value.volume == 0 ? 1.0 : 0.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
