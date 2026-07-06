import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomeMascotVideo extends StatelessWidget {
  const HomeMascotVideo({
    super.key,
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final videoSize = controller.value.size;
    if (videoSize.width <= 0 || videoSize.height <= 0) {
      return const SizedBox.expand();
    }

    // 단일 FittedBox만 사용해 이중 스케일링으로 인한 화질 저하를 방지한다.
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: videoSize.width,
          height: videoSize.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
