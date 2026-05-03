import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NugulVideo extends StatefulWidget {
  const NugulVideo({
    super.key,
    required this.size,
    this.assetPath = 'assets/videos/nugul.mp4',
  });

  final double size;
  final String assetPath;

  @override
  State<NugulVideo> createState() => _NugulVideoState();
}

class _NugulVideoState extends State<NugulVideo> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..setLooping(true)
      ..setVolume(0);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _initialized = true);
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: _initialized
          ? Align(
              alignment: Alignment.bottomCenter,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : null,
    );
  }
}
