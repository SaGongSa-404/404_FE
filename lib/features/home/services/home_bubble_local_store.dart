import 'package:fe_app/features/home/domain/home_bubble_type.dart';
import 'package:fe_app/features/home/models/bubble_home_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 말풍선 최초 1회·pending 상태 SharedPreferences 저장.
class HomeBubbleLocalStore {
  HomeBubbleLocalStore(this._prefs);

  static const String keyHasShownOnboardingBubble =
      'home_bubble_has_shown_onboarding';
  static const String keyHasShownFirstWishBubble =
      'home_bubble_has_shown_first_wish';
  static const String keyPendingFirstWishBubble =
      'home_balloon_pending_first_wish';
  static const String keyPendingOnboardingBubble =
      'home_balloon_pending_onboarding';
  static const String keyPendingResultBubbleType =
      'home_bubble_pending_result_type';

  /// legacy: consider case name 저장 키 (마이그레이션용).
  static const String legacyKeyPendingDecisionCase =
      'home_balloon_pending_decision_case';

  final SharedPreferences _prefs;

  static Future<HomeBubbleLocalStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return HomeBubbleLocalStore(prefs);
  }

  Future<HomeBubbleLocalFlags> readFlags() async {
    return HomeBubbleLocalFlags(
      hasShownOnboardingBubble:
          _prefs.getBool(keyHasShownOnboardingBubble) ?? false,
      hasShownFirstWishBubble:
          _prefs.getBool(keyHasShownFirstWishBubble) ?? false,
      pendingFirstWishBubble:
          _prefs.getBool(keyPendingFirstWishBubble) ?? false,
      pendingOnboardingBubble:
          _prefs.getBool(keyPendingOnboardingBubble) ?? false,
    );
  }

  Future<void> markPendingOnboarding() async {
    await _prefs.setBool(keyPendingOnboardingBubble, true);
  }

  Future<void> clearPendingOnboarding() async {
    await _prefs.remove(keyPendingOnboardingBubble);
  }

  Future<void> markPendingFirstWish() async {
    await _prefs.setBool(keyPendingFirstWishBubble, true);
  }

  Future<void> clearPendingFirstWish() async {
    await _prefs.remove(keyPendingFirstWishBubble);
  }

  Future<void> markOnboardingBubbleShown() async {
    await _prefs.setBool(keyHasShownOnboardingBubble, true);
    await clearPendingOnboarding();
  }

  Future<void> markFirstWishBubbleShown() async {
    await _prefs.setBool(keyHasShownFirstWishBubble, true);
    await clearPendingFirstWish();
  }

  Future<void> setPendingResultBubble(HomeBubbleType type) async {
    await _prefs.setString(keyPendingResultBubbleType, type.name);
  }

  Future<HomeBubbleType?> peekPendingResultBubble() async {
    final raw = _prefs.getString(keyPendingResultBubbleType);
    if (raw == null || raw.isEmpty) {
      return _readLegacyPendingDecisionCase();
    }
    return _parseBubbleType(raw);
  }

  Future<HomeBubbleType?> consumePendingResultBubble() async {
    final type = await peekPendingResultBubble();
    if (type == null) return null;
    await _prefs.remove(keyPendingResultBubbleType);
    await _prefs.remove(legacyKeyPendingDecisionCase);
    return type;
  }

  Future<void> clearPendingResultBubble() async {
    await _prefs.remove(keyPendingResultBubbleType);
    await _prefs.remove(legacyKeyPendingDecisionCase);
  }

  /// legacy consider case → HomeBubbleType 변환 후 저장.
  Future<void> setLegacyPendingDecisionCase(String caseTypeName) async {
    await _prefs.setString(legacyKeyPendingDecisionCase, caseTypeName);
  }

  Future<HomeBubbleType?> _readLegacyPendingDecisionCase() async {
    final raw = _prefs.getString(legacyKeyPendingDecisionCase);
    if (raw == null || raw.isEmpty) return null;

    switch (raw) {
      case 'caseA':
        return HomeBubbleType.rationalGo;
      case 'caseB':
        return HomeBubbleType.irrationalGo;
      case 'caseC':
        return HomeBubbleType.rationalStop;
      case 'caseD':
        return HomeBubbleType.irrationalStop;
      default:
        return null;
    }
  }

  HomeBubbleType? _parseBubbleType(String raw) {
    for (final type in HomeBubbleType.values) {
      if (type.name == raw) return type;
    }
    return null;
  }
}
