import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/profile/services/profile_service.dart';

class NotificationSettingsState {
  const NotificationSettingsState({
    this.notificationEnabled = false,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  final bool notificationEnabled;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  NotificationSettingsState copyWith({
    bool? notificationEnabled,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationSettingsState(
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class NotificationSettingsNotifier
    extends StateNotifier<NotificationSettingsState> {
  NotificationSettingsNotifier(this._profileService)
      : super(const NotificationSettingsState());

  final ProfileService _profileService;
  bool _hasFetched = false;

  String _errorMessage(Object error) =>
      apiExceptionFrom(error)?.message ?? '요청을 처리하지 못했습니다.';

  Future<void> load({bool force = false}) async {
    if (state.isLoading) return;
    if (!force && _hasFetched) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final settings = await _profileService.getNotificationSettings();
      _hasFetched = true;
      state = state.copyWith(
        notificationEnabled: settings.notificationEnabled,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _errorMessage(e),
      );
    }
  }

  Future<bool> toggle() async {
    if (state.isLoading || state.isUpdating) return false;

    final previous = state.notificationEnabled;
    final next = !previous;
    state = state.copyWith(
      notificationEnabled: next,
      isUpdating: true,
      clearError: true,
    );

    try {
      final settings = await _profileService.updateNotificationSettings(
        notificationEnabled: next,
      );
      state = state.copyWith(
        notificationEnabled: settings.notificationEnabled,
        isUpdating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        notificationEnabled: previous,
        isUpdating: false,
        errorMessage: _errorMessage(e),
      );
      return false;
    }
  }
}

final notificationSettingsProvider = StateNotifierProvider<
    NotificationSettingsNotifier, NotificationSettingsState>(
  (ref) => NotificationSettingsNotifier(ref.watch(profileServiceProvider)),
);
