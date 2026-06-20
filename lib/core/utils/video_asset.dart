import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

Iterable<String> _assetPathsForBaseName(String baseName) {
  final webmPath = 'assets/videos/$baseName.WebM';
  final mp4Path = 'assets/videos/$baseName.mp4';
  final preferMp4 = defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
  if (preferMp4) {
    return [mp4Path, webmPath];
  }
  return [webmPath, mp4Path];
}

String? videoBaseNameFromDataSource(String dataSource) {
  if (dataSource.isEmpty) return null;
  final fileName = dataSource.split('/').last;
  final dotIndex = fileName.lastIndexOf('.');
  if (dotIndex <= 0) {
    return fileName.isEmpty ? null : fileName;
  }
  return fileName.substring(0, dotIndex);
}

/// Creates an initialized [VideoPlayerController] for the given video base name.
Future<VideoPlayerController> createVideoAssetController(
  String baseName, {
  bool loop = false,
}) async {
  for (final path in _assetPathsForBaseName(baseName)) {
    final controller = VideoPlayerController.asset(
      path,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
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
