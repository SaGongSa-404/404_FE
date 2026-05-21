abstract final class ApiEndpoints {
  static const String v1 = '/api/v1';
  static const String auth = '/api/auth';
  static const String dev = '/api/dev';

  // ── OAuth ────────────────────────────────────────────────────────────────
  static String oauthAuthorization(String provider, String redirectUri) =>
      '/oauth2/authorization/$provider?redirect_uri=${Uri.encodeComponent(redirectUri)}';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String me = '$auth/me';
  static const String tokenRefresh = '$auth/token/refresh';
  /// 명세 본문에 없음. 백엔드 제공 시 경로 확인 후 사용.
  static const String logout = '/api/logout';

  // ── Terms ────────────────────────────────────────────────────────────────
  static const String terms = '$v1/terms';
  static String termDetail(String type) => '$v1/terms/$type';

  // ── Onboarding ───────────────────────────────────────────────────────────
  static const String onboardingComplete = '$v1/onboarding/complete';

  // ── Home ─────────────────────────────────────────────────────────────────
  static const String homeSummary = '$v1/home/summary';
  static const String homeBudgetExhaustionBubbleSeen =
      '$v1/home/budget-exhaustion-bubble/seen';

  // ── Item import ──────────────────────────────────────────────────────────
  static const String itemsImportLink = '$v1/items/import-link';

  // ── Wishlist ─────────────────────────────────────────────────────────────
  static const String wishlistItems = '$v1/wishlist/items';
  static String wishlistItem(String itemId) => '$v1/wishlist/items/$itemId';
  static String wishlistItemCategory(String itemId) =>
      '$v1/wishlist/items/$itemId/category';

  // ── Deliberation ─────────────────────────────────────────────────────────
  static String deliberationItem(String itemId) =>
      '$v1/deliberations/items/$itemId';

  // ── Decision ─────────────────────────────────────────────────────────────
  static const String decisions = '$v1/decisions';
  static String decisionResult(String decisionId) =>
      '$v1/decisions/$decisionId/result';

  // ── Notifications ────────────────────────────────────────────────────────
  static const String notifications = '$v1/notifications';
  static String notificationRead(String notificationId) =>
      '$v1/notifications/$notificationId/read';

  // ── Reflection ───────────────────────────────────────────────────────────
  static const String reflections = '$v1/reflections';

  // ── Mypage ───────────────────────────────────────────────────────────────
  static const String usersMe = '$v1/users/me';
  static const String usersMeProfile = '$v1/users/me/profile';
  static const String usersMeBudget = '$v1/users/me/budget';
  static const String usersMeNotificationSettings =
      '$v1/users/me/notification-settings';
  static const String usersMeStatsMonths = '$v1/users/me/stats/months';
  static const String usersMeStats = '$v1/users/me/stats';
  static const String usersMeWishesHistory = '$v1/users/me/wishes/history';
  static const String usersMePosts = '$v1/users/me/posts';
  static const String usersMeVotes = '$v1/users/me/votes';

  // ── Consumption ──────────────────────────────────────────────────────────
  static const String myConsumption = '$v1/my/consumption';
  static String myConsumptionRecord(String decisionId) =>
      '$v1/my/consumption/$decisionId';

  // ── Social ───────────────────────────────────────────────────────────────
  static const String socialPosts = '$v1/social/posts';
  static const String socialPostUploads = '$v1/social/posts/uploads';
  static String socialPost(String postId) => '$v1/social/posts/$postId';
  static String socialPostVotes(String postId) =>
      '$v1/social/posts/$postId/votes';
  static String socialPostComments(String postId) =>
      '$v1/social/posts/$postId/comments';
  static String socialPostComment(String postId, String commentId) =>
      '$v1/social/posts/$postId/comments/$commentId';

  // ── Dev (개발/테스트 보조) ───────────────────────────────────────────────
  static const String devUsersTest = '$dev/users/test';
  static String devProfile(String userId) => '$dev/profiles/$userId';
  static const String devItemsTest = '$dev/items/test';
  static const String devWishesTest = '$dev/wishes/test';
}
