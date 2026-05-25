/// POST /api/v1/items/import-link (SHARE)용 URL 정규화·검증.
abstract final class ShareLinkUrl {
  ShareLinkUrl._();

  static final RegExp _httpUrlPattern = RegExp(
    r'https?://[^\s<>"\]]+',
    caseSensitive: false,
  );

  static String? normalize(String raw) {
    var candidate = raw.trim();
    if (candidate.isEmpty) return null;

    final match = _httpUrlPattern.firstMatch(candidate);
    if (match != null) {
      candidate = _stripTrailingUrlPunctuation(match.group(0)!);
    } else if (!candidate.contains('://')) {
      candidate = 'https://$candidate';
    }

    final uri = Uri.tryParse(candidate);
    if (uri == null || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    if (uri.userInfo.isNotEmpty) return null;
    if (_isBlockedHost(uri.host)) return null;

    return uri.toString();
  }

  static String _stripTrailingUrlPunctuation(String url) {
    var end = url.length;
    while (end > 0 && ',.;)]}'.contains(url[end - 1])) {
      end--;
    }
    return url.substring(0, end);
  }

  static bool _isBlockedHost(String host) {
    final h = host.toLowerCase();
    if (h == 'localhost' || h.endsWith('.localhost')) return true;
    if (h.startsWith('127.')) return true;
    if (h.startsWith('10.')) return true;
    if (h.startsWith('192.168.')) return true;
    if (h.startsWith('172.')) {
      final parts = h.split('.');
      if (parts.length >= 2) {
        final second = int.tryParse(parts[1]);
        if (second != null && second >= 16 && second <= 31) return true;
      }
    }
    return false;
  }
}
