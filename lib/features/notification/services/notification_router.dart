import 'package:fe_app/features/notification/models/notification_model.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// API [targetPath]를 앱 GoRouter 경로로 변환합니다.
abstract final class NotificationRouter {
  static const _playStorePackage = 'com.example.fe_app';

  /// 외부 URL을 외부 앱으로 엽니다. 실패해도 예외를 전파하지 않습니다.
  static Future<void> launchExternalUrl(Uri uri) async {
    try {
      if (!await canLaunchUrl(uri)) return;
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error, stackTrace) {
      debugPrint('notification external link failed: $error\n$stackTrace');
    }
  }

  static bool isExternalUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) return false;
    return uri.scheme == 'http' ||
        uri.scheme == 'https' ||
        uri.scheme == 'market';
  }

  /// 이동 가능한 경로인지 확인합니다. null/empty이면 false.
  static bool shouldNavigate(String? path) {
    final resolved = resolveRoute(targetPath: path);
    return resolved != null && resolved.isNotEmpty && resolved != '/notifications';
  }

  /// [targetPath]와 API 보조 필드를 앱 내부 route로 변환합니다.
  /// 외부 URL은 그대로 반환하고, 이동 불가 시 null을 반환합니다.
  static String? resolveRoute({
    String? targetPath,
    String? itemId,
    String? decisionId,
    String? reminderId,
  }) {
    final trimmed = (targetPath ?? '').trim();
    if (trimmed.isEmpty) {
      return _resolveFromIds(
        itemId: itemId,
        decisionId: decisionId,
        reminderId: reminderId,
      );
    }

    if (isExternalUrl(trimmed)) return trimmed;

    final normalized = trimmed.startsWith('/') ? trimmed : '/$trimmed';

    final socialPost = RegExp(r'^/social/posts/([^/]+)$').firstMatch(normalized);
    if (socialPost != null) {
      return '/feed/${socialPost.group(1)}';
    }

    final wishlistItem = RegExp(r'^/wishlist/items/([^/]+)$').firstMatch(normalized);
    if (wishlistItem != null) {
      return '/wishlist/item?id=${wishlistItem.group(1)}';
    }

    final reflection = RegExp(r'^/wishlist/reflections/([^/]+)$').firstMatch(normalized);
    if (reflection != null) {
      final id = itemId ?? reflection.group(1);
      if (id != null && id.isNotEmpty) {
        return '/wishlist/reflect?id=$id';
      }
    }

    final apiReflection = RegExp(r'^/reflections/([^/]+)$').firstMatch(normalized);
    if (apiReflection != null) {
      final id = decisionId ?? apiReflection.group(1);
      if (id != null && id.isNotEmpty) {
        return '/wishlist/reflect?id=$id';
      }
    }

    if (normalized == '/home' ||
        normalized.startsWith('/feed/') ||
        normalized.startsWith('/wishlist/') ||
        normalized.startsWith('/my')) {
      return normalized;
    }

    return normalized;
  }

  static String? resolveFromNotification(NotificationModel notification) {
    return resolveRoute(
      targetPath: notification.targetPath,
      itemId: notification.itemId,
      decisionId: notification.decisionId,
      reminderId: notification.reminderId,
    );
  }

  /// 투표 알림 중복 방지용 게시글 ID 추출.
  static String? extractPostId(NotificationModel notification) {
    final fromPath = _extractPostIdFromPath(notification.targetPath);
    if (fromPath != null) return fromPath;
    return null;
  }

  static String? _extractPostIdFromPath(String? path) {
    final trimmed = (path ?? '').trim();
    if (trimmed.isEmpty) return null;

    final normalized = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    final social = RegExp(r'^/social/posts/([^/]+)$').firstMatch(normalized);
    if (social != null) return social.group(1);

    final feed = RegExp(r'^/feed/([^/]+)$').firstMatch(normalized);
    if (feed != null) return feed.group(1);

    return null;
  }

  static String? _resolveFromIds({
    String? itemId,
    String? decisionId,
    String? reminderId,
  }) {
    if (itemId != null && itemId.isNotEmpty) {
      return '/wishlist/item?id=$itemId';
    }
    if (decisionId != null && decisionId.isNotEmpty) {
      return '/wishlist/reflect?id=$decisionId';
    }
    if (reminderId != null && reminderId.isNotEmpty) {
      return '/wishlist/item?id=$reminderId';
    }
    return null;
  }

  static String playStoreUrl({String? packageName}) {
    final pkg = packageName ?? _playStorePackage;
    return 'market://details?id=$pkg';
  }
}
