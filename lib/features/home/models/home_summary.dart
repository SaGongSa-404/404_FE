import 'package:fe_app/core/utils/date_formatter.dart';

class HomeSummaryResponse {
  final HomeUserProfile userProfile;
  final HomeMascotSummary mascot;
  final HomeBudgetSummary budget;
  final HomeNotificationSummary notifications;
  final double? rationalChoiceRate;

  const HomeSummaryResponse({
    required this.userProfile,
    required this.mascot,
    required this.budget,
    required this.notifications,
    this.rationalChoiceRate,
  });

  factory HomeSummaryResponse.fromJson(Map<String, dynamic> json) {
    return HomeSummaryResponse(
      userProfile: HomeUserProfile.fromJson(_asMap(json['userProfile'])),
      mascot: HomeMascotSummary.fromJson(_asMap(json['mascot'])),
      budget: HomeBudgetSummary.fromJson(_asMap(json['budget'])),
      notifications: HomeNotificationSummary.fromJson(
        _asMap(json['notifications']),
      ),
      rationalChoiceRate: _asDouble(json['rationalChoiceRate']),
    );
  }

  HomeSummaryResponse copyWith({
    HomeUserProfile? userProfile,
    HomeMascotSummary? mascot,
    HomeBudgetSummary? budget,
    HomeNotificationSummary? notifications,
    double? rationalChoiceRate,
  }) {
    return HomeSummaryResponse(
      userProfile: userProfile ?? this.userProfile,
      mascot: mascot ?? this.mascot,
      budget: budget ?? this.budget,
      notifications: notifications ?? this.notifications,
      rationalChoiceRate: rationalChoiceRate ?? this.rationalChoiceRate,
    );
  }
}

class HomeUserProfile {
  final String nickname;
  final String mascotName;
  final String timezone;

  const HomeUserProfile({
    required this.nickname,
    required this.mascotName,
    required this.timezone,
  });

  factory HomeUserProfile.fromJson(Map<String, dynamic> json) {
    return HomeUserProfile(
      nickname: _asString(json['nickname']),
      mascotName: _asString(json['mascotName']),
      timezone: _asString(json['timezone']),
    );
  }

  HomeUserProfile copyWith({String? nickname, String? mascotName, String? timezone}) {
    return HomeUserProfile(
      nickname: nickname ?? this.nickname,
      mascotName: mascotName ?? this.mascotName,
      timezone: timezone ?? this.timezone,
    );
  }
}

class HomeMascotSummary {
  final String state;
  final String? lastReactionMessage;
  final DateTime? lastStateChangedAt;
  final DateTime? reactionExpiresAt;

  const HomeMascotSummary({
    required this.state,
    this.lastReactionMessage,
    this.lastStateChangedAt,
    this.reactionExpiresAt,
  });

  factory HomeMascotSummary.fromJson(Map<String, dynamic> json) {
    return HomeMascotSummary(
      state: _asString(json['state']),
      lastReactionMessage: _asNullableString(json['lastReactionMessage']),
      lastStateChangedAt: _asDateTime(json['lastStateChangedAt']),
      reactionExpiresAt: _asDateTime(json['reactionExpiresAt']),
    );
  }

  HomeMascotSummary copyWith({
    String? state,
    String? lastReactionMessage,
    DateTime? lastStateChangedAt,
    DateTime? reactionExpiresAt,
  }) {
    return HomeMascotSummary(
      state: state ?? this.state,
      lastReactionMessage: lastReactionMessage ?? this.lastReactionMessage,
      lastStateChangedAt: lastStateChangedAt ?? this.lastStateChangedAt,
      reactionExpiresAt: reactionExpiresAt ?? this.reactionExpiresAt,
    );
  }
}

class HomeBudgetSummary {
  final String yearMonth;
  final int monthlyBudgetAmount;
  final int spentAmount;
  final int remainingAmount;
  final double warningThresholdRate;
  final bool exhausted;
  final bool showBudgetExhaustionBubble;

  const HomeBudgetSummary({
    required this.yearMonth,
    required this.monthlyBudgetAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.warningThresholdRate,
    required this.exhausted,
    required this.showBudgetExhaustionBubble,
  });

  factory HomeBudgetSummary.fromJson(Map<String, dynamic> json) {
    final monthlyBudgetAmount = _asInt(json['monthlyBudgetAmount']);
    final spentAmount = _asInt(json['spentAmount']);
    final remainingAmount = _asInt(json['remainingAmount'], fallback: monthlyBudgetAmount - spentAmount);
    return HomeBudgetSummary(
      yearMonth: _asString(json['yearMonth']),
      monthlyBudgetAmount: monthlyBudgetAmount,
      spentAmount: spentAmount,
      remainingAmount: remainingAmount,
      warningThresholdRate: _asDouble(json['warningThresholdRate']) ?? 0,
      exhausted: _asBool(json['exhausted']),
      showBudgetExhaustionBubble: _asBool(json['showBudgetExhaustionBubble']),
    );
  }

  bool get isBudgetExhausted => exhausted || remainingAmount <= 0;

  double get budgetProgress {
    if (isBudgetExhausted) return 1.0;
    if (monthlyBudgetAmount <= 0) return 0.0;
    return (spentAmount / monthlyBudgetAmount).clamp(0.0, 1.0);
  }

  HomeBudgetSummary copyWith({
    String? yearMonth,
    int? monthlyBudgetAmount,
    int? spentAmount,
    int? remainingAmount,
    double? warningThresholdRate,
    bool? exhausted,
    bool? showBudgetExhaustionBubble,
  }) {
    return HomeBudgetSummary(
      yearMonth: yearMonth ?? this.yearMonth,
      monthlyBudgetAmount: monthlyBudgetAmount ?? this.monthlyBudgetAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      warningThresholdRate: warningThresholdRate ?? this.warningThresholdRate,
      exhausted: exhausted ?? this.exhausted,
      showBudgetExhaustionBubble:
          showBudgetExhaustionBubble ?? this.showBudgetExhaustionBubble,
    );
  }
}

class HomeNotificationSummary {
  final int unreadCount;
  final List<HomeNotificationPreview> latestNotifications;

  const HomeNotificationSummary({
    required this.unreadCount,
    required this.latestNotifications,
  });

  factory HomeNotificationSummary.fromJson(Map<String, dynamic> json) {
    final rawLatestNotifications = _asList(json['latestNotifications']);
    return HomeNotificationSummary(
      unreadCount: _asInt(json['unreadCount']),
      latestNotifications: rawLatestNotifications
          .map((item) => HomeNotificationPreview.fromJson(_asMap(item)))
          .toList(growable: false),
    );
  }

  HomeNotificationSummary copyWith({
    int? unreadCount,
    List<HomeNotificationPreview>? latestNotifications,
  }) {
    return HomeNotificationSummary(
      unreadCount: unreadCount ?? this.unreadCount,
      latestNotifications: latestNotifications ?? this.latestNotifications,
    );
  }
}

class HomeNotificationPreview {
  final String id;
  final String? type;
  final String title;
  final String? body;
  final String targetPath;
  final bool read;
  final DateTime? createdAt;

  const HomeNotificationPreview({
    required this.id,
    required this.title,
    required this.targetPath,
    required this.read,
    this.type,
    this.body,
    this.createdAt,
  });

  factory HomeNotificationPreview.fromJson(Map<String, dynamic> json) {
    return HomeNotificationPreview(
      id: _asString(json['id']),
      type: _asNullableString(json['type']),
      title: _asString(json['title']),
      body: _asNullableString(json['body']),
      targetPath: _asString(json['targetPath'], fallback: '/home'),
      read: _asBool(json['read']),
      createdAt: _asDateTime(json['createdAt']),
    );
  }

  String get timeLabel {
    final created = createdAt;
    if (created == null) return '';

    final diff = DateTime.now().difference(created.toLocal());
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return DateFormatter.ymd(created.toLocal());
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, dynamic item) => MapEntry(key.toString(), item));
  }
  return const {};
}

List<dynamic> _asList(Object? value) {
  if (value is List<dynamic>) return value;
  if (value is List) return value.cast<dynamic>();
  return const [];
}

String _asString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}

String? _asNullableString(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double? _asDouble(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}

DateTime? _asDateTime(Object? value) {
  if (value is DateTime) return value;
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}

