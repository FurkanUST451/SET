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
  bool _isMuted = false;

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

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
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
                                      color:
                                          Colors.black.withValues(alpha: 0.35),
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
                    ),
                    _VideoControlsBar(
                      controller: _controller,
                      isMuted: _isMuted,
                      onTogglePlayback: _togglePlayback,
                      onToggleMute: _toggleMute,
                      formatDuration: _formatDuration,
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

// Video altındaki sabit kontrol çubuğu: oynat/duraklat, ilerleme çubuğu
// (görünür top/thumb'lı, sürüklenebilir), süre ve sessize alma.
//
// Sürükleme sırasında controller.seekTo() HER hareket için değil, sadece
// parmak kalktığında (onChangeEnd) çağrılıyor — aksi halde her piksel
// hareketinde bir network seek isteği tetiklenip (video faststart/HLS
// olmadığından) istekler kuyruğa yığılıyor ve pozisyon "çok sonra" yerine
// oturuyordu. Sürüklerken slider'ın kendi değeri (_dragValue) anlık ve akıcı
// güncellenir; gerçek video pozisyonuyla senkron değil, sadece görsel.
class _VideoControlsBar extends StatefulWidget {
  const _VideoControlsBar({
    required this.controller,
    required this.isMuted,
    required this.onTogglePlayback,
    required this.onToggleMute,
    required this.formatDuration,
  });

  final VideoPlayerController controller;
  final bool isMuted;
  final VoidCallback onTogglePlayback;
  final VoidCallback onToggleMute;
  final String Function(Duration) formatDuration;

  @override
  State<_VideoControlsBar> createState() => _VideoControlsBarState();
}

class _VideoControlsBarState extends State<_VideoControlsBar> {
  double? _dragValueMs;
  bool _wasPlayingBeforeDrag = false;

  void _onChangeStart(double value) {
    _wasPlayingBeforeDrag = widget.controller.value.isPlaying;
    widget.controller.pause();
    setState(() => _dragValueMs = value);
  }

  void _onChanged(double value) {
    setState(() => _dragValueMs = value);
  }

  Future<void> _onChangeEnd(double value) async {
    await widget.controller
        .seekTo(Duration(milliseconds: value.round()));
    if (_wasPlayingBeforeDrag) widget.controller.play();
    if (mounted) setState(() => _dragValueMs = null);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: widget.controller,
          builder: (_, value, _) {
            final durationMs = value.duration.inMilliseconds > 0
                ? value.duration.inMilliseconds.toDouble()
                : 1.0;
            final positionMs =
                _dragValueMs ?? value.position.inMilliseconds.toDouble();
            final clampedPositionMs =
                positionMs.clamp(0.0, durationMs).toDouble();

            return Row(
              children: [
                IconButton(
                  icon: Icon(
                    value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  onPressed: widget.onTogglePlayback,
                ),
                Text(
                  widget.formatDuration(
                    Duration(milliseconds: clampedPositionMs.round()),
                  ),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.5,
                      activeTrackColor: const Color(0xFFD9A84E),
                      inactiveTrackColor: Colors.white24,
                      thumbColor: const Color(0xFFD9A84E),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14),
                    ),
                    child: Slider(
                      min: 0,
                      max: durationMs,
                      value: clampedPositionMs,
                      onChangeStart: _onChangeStart,
                      onChanged: _onChanged,
                      onChangeEnd: _onChangeEnd,
                    ),
                  ),
                ),
                Text(
                  widget.formatDuration(value.duration),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                IconButton(
                  icon: Icon(
                    widget.isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: Colors.white,
                  ),
                  onPressed: widget.onToggleMute,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
