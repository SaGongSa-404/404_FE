import 'dart:math';

/// 앱 프로세스 생존 중 in-memory로만 유지되는 홈 말풍선 세션 상태.
class HomeBubbleSessionManager {
  HomeBubbleSessionManager({Random? random}) : _sessionId = _newSessionId(random);

  final String _sessionId;
  bool _hasShownHomeBubbleInCurrentSession = false;

  String get sessionId => _sessionId;

  bool get hasShownHomeBubbleInCurrentSession =>
      _hasShownHomeBubbleInCurrentSession;

  void markHomeBubbleShownInCurrentSession() {
    _hasShownHomeBubbleInCurrentSession = true;
  }

  /// 테스트용 초기화.
  void resetForTests() {
    _hasShownHomeBubbleInCurrentSession = false;
  }

  static String _newSessionId(Random? random) {
    final value = random ?? Random();
    return '${DateTime.now().microsecondsSinceEpoch}_${value.nextInt(1 << 32)}';
  }
}

/// 앱 전역 단일 세션 매니저.
final HomeBubbleSessionManager homeBubbleSessionManager =
    HomeBubbleSessionManager();
