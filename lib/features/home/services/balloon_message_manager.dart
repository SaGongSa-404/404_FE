import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:fe_app/features/home/models/balloon_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 말풍선 표시 상태
class BalloonDisplayState {
  final String? message;
  final BalloonMessageType? messageType;
  final bool shouldShow;

  const BalloonDisplayState({
    this.message,
    this.messageType,
    this.shouldShow = false,
  });

  const BalloonDisplayState.empty()
      : message = null,
        messageType = null,
        shouldShow = false;
}

/// 말풍선 메시지 관리자
/// 
/// 책임:
/// 1. 현재 상태에서 표시할 메시지 결정
/// 2. 우선순위 처리 (동시 해당 시 1개만 노출)
/// 3. 확률 기반 분기 (70/30%)
/// 4. 최초 1회 처리 (SharedPreferences 사용)
class BalloonMessageManager {
  static const String _keyFirstWishShown = 'balloon_first_wish_shown';
  static const int _displayDurationMs = 3000; // 3초

  final SharedPreferences _prefs;
  final Random _random = Random();

  BalloonMessageManager(this._prefs);

  /// 현재 상태에서 표시할 메시지 결정
  /// 
  /// 우선순위:
  /// 1. 예산 마이너스
  /// 2. 예산 소진 (0원)
  /// 3. 위시 첫 추가 (최초 1회)
  /// 4. 위시 없는 빈 상태
  /// 5. 위시 미결정 (70%) or 기본 홈 (30%)
  /// 6. 게시글 투표 대기 (70%) or 기본 홈 (30%)
  /// 7. 평상시 기본 홈
  Future<BalloonDisplayState> determineMessage({
    required bool isBudgetNegative,
    required bool isBudgetExhausted,
    required bool isWishlistEmpty,
    required bool hasUndecidedWish,
    required bool hasPostsAwaitingVote,
    required bool isOnboardingCompleted,
    required bool isFirstWishAdded,
  }) async {
    try {
      // 우선순위 1: 예산 마이너스
      if (isBudgetNegative) {
        return _selectRandomMessage(BalloonMessageType.budgetNegative);
      }

      // 우선순위 2: 예산 소진 (0원)
      if (isBudgetExhausted) {
        return _selectRandomMessage(BalloonMessageType.budgetExhausted);
      }

      // 우선순위 3: 위시 첫 추가 (최초 1회)
      if (isFirstWishAdded) {
        final hasShown = await _hasShownFirstWish();
        if (!hasShown) {
          await _markFirstWishShown();
          return _selectRandomMessage(BalloonMessageType.firstWishAdded);
        }
      }

      // 우선순위 4: 위시 없는 빈 상태
      if (isWishlistEmpty) {
        return _selectRandomMessage(BalloonMessageType.emptyWishlist);
      }

      // 우선순위 5: 위시 미결정 (70% 또는 기본 홈 30%)
      if (hasUndecidedWish) {
        if (_shouldShowByProbability(0.7)) {
          return _selectRandomMessage(BalloonMessageType.undecidedWish);
        } else {
          return _selectRandomMessage(BalloonMessageType.normalHome);
        }
      }

      // 우선순위 6: 게시글 투표 대기 (70% 또는 기본 홈 30%)
      if (hasPostsAwaitingVote) {
        if (_shouldShowByProbability(0.7)) {
          return _selectRandomMessage(BalloonMessageType.awaitingVote);
        } else {
          return _selectRandomMessage(BalloonMessageType.normalHome);
        }
      }

      // 우선순위 7: 평상시 기본 홈
      return _selectRandomMessage(BalloonMessageType.normalHome);
    } catch (e) {
      debugPrint('❌ Balloon message determination error: $e');
      return _selectRandomMessage(BalloonMessageType.normalHome);
    }
  }

  /// 특정 타입에서 랜덤 메시지 선택
  BalloonDisplayState _selectRandomMessage(BalloonMessageType type) {
    final messages = BalloonMessages.getMessagesByType(type);
    if (messages.isEmpty) return const BalloonDisplayState.empty();

    final selectedMessage =
        messages[_random.nextInt(messages.length)];
    return BalloonDisplayState(
      message: selectedMessage.text,
      messageType: type,
      shouldShow: true,
    );
  }

  /// 확률에 따라 표시 여부 결정 (0.0 ~ 1.0)
  bool _shouldShowByProbability(double probability) {
    return _random.nextDouble() < probability;
  }



  /// 위시 첫 추가 후 메시지가 표시되었는지 확인
  Future<bool> _hasShownFirstWish() async {
    return _prefs.getBool(_keyFirstWishShown) ?? false;
  }

  /// 위시 첫 추가 후 메시지를 표시했음 표시
  Future<void> _markFirstWishShown() async {
    await _prefs.setBool(_keyFirstWishShown, true);
  }
}





