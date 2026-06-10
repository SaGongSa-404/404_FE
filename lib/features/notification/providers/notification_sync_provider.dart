import 'dart:async';

import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:fe_app/features/notification/providers/notification_live_provider.dart';
import 'package:fe_app/features/notification/providers/notification_provider.dart';
import 'package:fe_app/features/notification/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 알림 목록·라이브 상태·홈 요약을 함께 갱신하는 오케스트레이터.
///
/// 화면(View)은 이 유스케이스의 고수준 메서드만 호출하고,
/// 실제 refresh/sync 조합과 순서는 이 계층에서 관리합니다.
final notificationSyncProvider = Provider<NotificationSyncUseCase>((ref) {
  return NotificationSyncUseCase(ref);
});

class NotificationSyncUseCase {
  NotificationSyncUseCase(this._ref);

  final Ref _ref;

  NotificationListNotifier get _list =>
      _ref.read(notificationListProvider(false).notifier);

  NotificationLiveNotifier get _live =>
      _ref.read(notificationLiveProvider.notifier);

  HomeSummaryNotifier get _homeSummary =>
      _ref.read(homeSummaryProvider.notifier);

  /// 알림 화면 진입 시 목록과 라이브 상태를 동시에(비동기) 새로고침합니다.
  void syncOnScreenEntered() {
    unawaited(_list.refresh());
    unawaited(_live.sync(queueNewBanners: false));
  }

  /// 알림 목록만 새로고침합니다. (알림 라우팅 복귀 후 등)
  Future<void> refreshList() => _list.refresh();

  /// 당겨서 새로고침: 알림 목록과 홈 요약을 차례로 갱신합니다.
  Future<void> refreshListAndHomeSummary() async {
    await _list.refresh();
    await _homeSummary.refresh();
  }

  /// 알림 화면 이동 직전 데이터 준비: 목록을 갱신하고
  /// 홈 요약·라이브 상태는 백그라운드로 동기화합니다.
  Future<void> prepareNotificationsScreen() async {
    await _list.refresh();
    unawaited(_homeSummary.refresh());
    unawaited(_live.sync(queueNewBanners: false));
  }

  /// 알림 읽음 처리. 목록 상태 갱신 후 라이브 상태에도 반영합니다.
  /// 404(만료/삭제)인 경우 라이브 반영 없이 결과만 돌려줍니다.
  Future<MarkAsReadResult> markAsRead(String id) async {
    final result = await _list.markAsRead(id);
    if (result == MarkAsReadResult.notFound) return result;
    await _live.markAsRead(id, syncRemote: false);
    return result;
  }

  /// 인앱 배너 탭 처리: 읽음 처리 후 배너를 제거하고 홈 요약을 갱신합니다.
  Future<void> markBannerAsRead(String id) async {
    await _live.markAsRead(id);
    _live.consumeBanner(id);
    unawaited(_homeSummary.refresh());
  }
}
