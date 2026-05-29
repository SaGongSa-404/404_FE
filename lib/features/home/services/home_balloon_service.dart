import 'dart:math';

import 'package:fe_app/features/home/models/balloon_message.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeBalloonService {
  static const String _keyPendingOnboarding = 'home_balloon_pending_onboarding';
  static const String _keyPendingFirstWish = 'home_balloon_pending_first_wish';
  static const String _keyPendingDecisionCase = 'home_balloon_pending_decision_case';

  static bool _launchEvaluatedThisSession = false;

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  static Future<void> markPendingOnboarding() async {
    final prefs = await _prefs();
    await prefs.setBool(_keyPendingOnboarding, true);
  }

  static Future<bool> consumePendingOnboarding() async {
    final prefs = await _prefs();
    final pending = prefs.getBool(_keyPendingOnboarding) ?? false;
    if (pending) {
      await prefs.remove(_keyPendingOnboarding);
    }
    return pending;
  }

  static Future<void> markPendingFirstWish() async {
    final prefs = await _prefs();
    await prefs.setBool(_keyPendingFirstWish, true);
  }

  static Future<bool> consumePendingFirstWish() async {
    final prefs = await _prefs();
    final pending = prefs.getBool(_keyPendingFirstWish) ?? false;
    if (pending) {
      await prefs.remove(_keyPendingFirstWish);
    }
    return pending;
  }

  static Future<void> markPendingDecisionCase(ConsiderCaseType caseType) async {
    final prefs = await _prefs();
    await prefs.setString(_keyPendingDecisionCase, caseType.name);
  }

  static Future<ConsiderCaseType?> consumePendingDecisionCase() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_keyPendingDecisionCase);
    if (raw == null || raw.isEmpty) return null;
    await prefs.remove(_keyPendingDecisionCase);
    for (final value in ConsiderCaseType.values) {
      if (value.name == raw) return value;
    }
    return null;
  }

  static BalloonMessageType? balloonTypeForDecisionCase(ConsiderCaseType caseType) {
    switch (caseType) {
      case ConsiderCaseType.caseA:
        return BalloonMessageType.rationalBought;
      case ConsiderCaseType.caseB:
        return BalloonMessageType.irrationalBought;
      case ConsiderCaseType.caseC:
        return BalloonMessageType.rationalRefrained;
      case ConsiderCaseType.caseD:
        return BalloonMessageType.irrationalRefrained;
    }
  }

  static String? pickRandomText(BalloonMessageType type) {
    final messages = BalloonMessages.getMessagesByType(type);
    if (messages.isEmpty) return null;
    final selected = messages[Random().nextInt(messages.length)];
    return selected.text;
  }

  static bool get launchEvaluatedThisSession => _launchEvaluatedThisSession;

  static void markLaunchEvaluatedThisSession() {
    _launchEvaluatedThisSession = true;
  }

  static void resetLaunchEvaluationForTests() {
    _launchEvaluatedThisSession = false;
  }
}

