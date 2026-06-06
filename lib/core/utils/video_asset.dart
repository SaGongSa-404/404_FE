import 'package:video_player/video_player.dart';

/// Creates an initialized [VideoPlayerController] for the given video base name.
Future<VideoPlayerController> createVideoAssetController(
  String baseName, {
  bool loop = false,
}) async {
  final webmPath = 'assets/videos/$baseName.WebM';
  final mp4Path = 'assets/videos/$baseName.mp4';

  for (final path in [webmPath, mp4Path]) {
    final controller = VideoPlayerController.asset(path);
    try {
      await controller.setVolume(0);
      await controller.initialize();
      controller.setLooping(loop);
      return controller;
    } catch (_) {
      await controller.dispose();
    }
  }

  throw StateError('Failed to load video asset: $baseName');
}
