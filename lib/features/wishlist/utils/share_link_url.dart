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
    if (h.contains(':')) return _isBlockedIpv6Host(h);
    return _isBlockedIpv4Host(h);
  }

  static bool _isBlockedIpv4Host(String host) {
    if (host == '0.0.0.0') return true;
    if (host.startsWith('127.')) return true;
    if (host.startsWith('10.')) return true;
    if (host.startsWith('192.168.')) return true;
    if (host.startsWith('169.254.')) return true;
    if (host.startsWith('172.')) {
      final parts = host.split('.');
      if (parts.length >= 2) {
        final second = int.tryParse(parts[1]);
        if (second != null && second >= 16 && second <= 31) return true;
      }
    }
    return false;
  }

  static bool _isBlockedIpv6Host(String host) {
    var normalized = host;
    if (normalized.startsWith('[') && normalized.endsWith(']')) {
      normalized = normalized.substring(1, normalized.length - 1);
    }
    if (normalized == '::1' || normalized == '0:0:0:0:0:0:0:1') return true;

    if (normalized.startsWith('::ffff:')) {
      final embedded = normalized.substring('::ffff:'.length);
      if (embedded.contains('.')) {
        return _isBlockedIpv4Host(embedded);
      }
    }

    final firstHextet = normalized.split(':').first;
    if (firstHextet.startsWith('fc') || firstHextet.startsWith('fd')) {
      return true;
    }
    if (firstHextet.startsWith('fe8') ||
        firstHextet.startsWith('fe9') ||
        firstHextet.startsWith('fea') ||
        firstHextet.startsWith('feb')) {
      return true;
    }
    return false;
  }
}
