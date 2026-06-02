import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fe_app/features/home/services/balloon_message_manager.dart';

/// SharedPreferences 프로바이더
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// BalloonMessageManager 프로바이더
final balloonMessageManagerProvider =
    FutureProvider<BalloonMessageManager>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return BalloonMessageManager(prefs);
});

/// 말풍선 메시지 결정 프로바이더
/// 
/// 홈 화면에서 현재 상태에 맞는 메시지를 결정할 때 사용
final balloonMessageProvider =
    FutureProvider.family<BalloonDisplayState, BalloonMessageParams>(
        (ref, params) async {
  final manager = await ref.watch(balloonMessageManagerProvider.future);
  return manager.determineMessage(
    isBudgetNegative: params.isBudgetNegative,
    isBudgetExhausted: params.isBudgetExhausted,
    isWishlistEmpty: params.isWishlistEmpty,
    hasUndecidedWish: params.hasUndecidedWish,
    hasPostsAwaitingVote: params.hasPostsAwaitingVote,
    isOnboardingCompleted: params.isOnboardingCompleted,
    isFirstWishAdded: params.isFirstWishAdded,
  );
});

/// 말풍선 결정을 위한 파라미터
class BalloonMessageParams {
  final bool isBudgetNegative;
  final bool isBudgetExhausted;
  final bool isWishlistEmpty;
  final bool hasUndecidedWish;
  final bool hasPostsAwaitingVote;
  final bool isOnboardingCompleted;
  final bool isFirstWishAdded;

  BalloonMessageParams({
    required this.isBudgetNegative,
    required this.isBudgetExhausted,
    required this.isWishlistEmpty,
    required this.hasUndecidedWish,
    required this.hasPostsAwaitingVote,
    required this.isOnboardingCompleted,
    required this.isFirstWishAdded,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BalloonMessageParams &&
          runtimeType == other.runtimeType &&
          isBudgetNegative == other.isBudgetNegative &&
          isBudgetExhausted == other.isBudgetExhausted &&
          isWishlistEmpty == other.isWishlistEmpty &&
          hasUndecidedWish == other.hasUndecidedWish &&
          hasPostsAwaitingVote == other.hasPostsAwaitingVote &&
          isOnboardingCompleted == other.isOnboardingCompleted &&
          isFirstWishAdded == other.isFirstWishAdded;

  @override
  int get hashCode =>
      isBudgetNegative.hashCode ^
      isBudgetExhausted.hashCode ^
      isWishlistEmpty.hashCode ^
      hasUndecidedWish.hashCode ^
      hasPostsAwaitingVote.hashCode ^
      isOnboardingCompleted.hashCode ^
      isFirstWishAdded.hashCode;
}

