import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/features/notification/services/notification_settings_service.dart';

class NotificationSettingsState {
  const NotificationSettingsState({
    required this.enabled,
    required this.isLoading,
    this.error,
  });

  final bool enabled;
  final bool isLoading;
  final Object? error;

  const NotificationSettingsState.initial()
      : enabled = true,
        isLoading = true,
        error = null;

  NotificationSettingsState copyWith({
    bool? enabled,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return NotificationSettingsState(
      enabled: enabled ?? this.enabled,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>(
  (ref) => NotificationSettingsNotifier(ref.watch(notificationSettingsServiceProvider)),
);

class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  NotificationSettingsNotifier(this._service)
      : super(const NotificationSettingsState.initial()) {
    unawaited(load());
  }

  final NotificationSettingsService _service;
  CancelToken? _cancelToken;

  Future<void> load() async {
    _cancelToken?.cancel('reload');
    final token = CancelToken();
    _cancelToken = token;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final enabled = await _service.fetchEnabled(cancelToken: token);
      if (token.isCancelled) return;
      state = state.copyWith(enabled: enabled, isLoading: false);
    } catch (error, stackTrace) {
      if (token.isCancelled) return;
      debugPrint('notification settings load failed: $error\n$stackTrace');
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    final previous = state.enabled;
    state = state.copyWith(enabled: enabled, clearError: true);
    try {
      final saved = await _service.updateEnabled(enabled);
      state = state.copyWith(enabled: saved, isLoading: false);
    } catch (error, stackTrace) {
      debugPrint('notification settings update failed: $error\n$stackTrace');
      state = state.copyWith(enabled: previous, error: error);
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel('disposed');
    super.dispose();
  }
}
