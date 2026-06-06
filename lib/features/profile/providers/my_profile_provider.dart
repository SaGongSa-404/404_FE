import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/profile/models/my_profile.dart';
import 'package:fe_app/features/profile/services/profile_service.dart';

class MyProfileState {
  const MyProfileState({
    this.profile,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  final MyProfile? profile;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  String get nickname => profile?.nickname ?? '';

  MyProfileState copyWith({
    MyProfile? profile,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
    bool clearProfile = false,
  }) {
    return MyProfileState(
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class MyProfileNotifier extends StateNotifier<MyProfileState> {
  MyProfileNotifier(this._profileService, this._ref)
      : super(const MyProfileState());

  final ProfileService _profileService;
  final Ref _ref;
  bool _hasFetched = false;

  String _errorMessage(Object error) {
    if (error is DioException &&
        (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout)) {
      return '서버에 연결할 수 없습니다. API 주소와 백엔드 실행 여부를 확인해 주세요.';
    }
    final api = apiExceptionFrom(error);
    if (api != null && api.message != '요청을 처리하지 못했습니다.') {
      return api.message;
    }
    if (_statusCode(error) == 401) {
      return '로그인이 필요합니다. 다시 로그인해 주세요.';
    }
    if (_statusCode(error) == 404) {
      return '프로필 정보를 찾을 수 없습니다.';
    }
    if (error is ApiException) return error.message;
    return '프로필 정보를 불러오지 못했습니다.';
  }

  int? _statusCode(Object error) {
    if (error is ApiException) return error.statusCode;
    if (error is DioException) return error.response?.statusCode;
    return null;
  }

  bool _isNotFound(Object error) => _statusCode(error) == 404;

  MyProfile? _profileFromAuth(UserModel? user) {
    if (user == null) return null;
    return MyProfile(
      id: user.userId,
      nickname: user.name,
      provider: user.provider,
      status: 'ACTIVE',
      onboardingStatus: user.onboardingStatus,
    );
  }

  Future<void> load({bool force = false}) async {
    if (state.isLoading) return;
    if (!force && _hasFetched) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _profileService.getMyProfile();
      _hasFetched = true;
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      if (_isNotFound(e) && state.profile != null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      if (_isNotFound(e)) {
        final fallback = _profileFromAuth(_ref.read(authProvider).valueOrNull);
        if (fallback != null) {
          _hasFetched = true;
          state = state.copyWith(profile: fallback, isLoading: false);
          return;
        }
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: _errorMessage(e),
      );
    }
  }

  Future<bool> updateNickname(String nickname) async {
    if (state.isUpdating) return false;

    final trimmed = nickname.trim();
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final profile = await _profileService.updateProfile(nickname: trimmed);
      _hasFetched = true;
      state = state.copyWith(profile: profile, isUpdating: false);

      final authNotifier = _ref.read(authProvider.notifier);
      authNotifier.updateDisplayName(profile.nickname);
      await authNotifier.refreshFromServer();
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: _errorMessage(e),
      );
      return false;
    }
  }

  void reset() {
    _hasFetched = false;
    state = const MyProfileState();
  }

  String withdrawErrorMessage(Object error) {
    if (kDebugMode) {
      debugPrint('[withdraw] failed: $error');
    }
    final api = apiExceptionFrom(error);
    final status = api?.statusCode ??
        (error is DioException ? error.response?.statusCode : null);

    if (kDebugMode && status != null) {
      debugPrint('[withdraw] status=$status message=${api?.message}');
    }

    if (status == 500) {
      return '서버 오류(500)입니다. 백엔드 로그를 확인해 주세요.';
    }
    if (status == 401) {
      return '로그인이 만료되었습니다. 다시 로그인한 뒤 탈퇴를 시도해 주세요.';
    }

    final detail = api?.message;
    if (detail != null &&
        detail.isNotEmpty &&
        detail != '요청을 처리하지 못했습니다.' &&
        detail != '네트워크 오류가 발생했습니다.') {
      return detail;
    }

    if (status != null) {
      return '탈퇴 처리에 실패했습니다 ($status). 잠시 후 다시 시도해 주세요.';
    }
    return '탈퇴 처리에 실패했습니다. 잠시 후 다시 시도해 주세요.';
  }

  /// 탈퇴 API 성공 직후 로컬 세션 정리 (화면 dispose와 무관).
  Future<void> deleteAccountAndSignOut() async {
    await _profileService.deleteMyAccount();
    await _ref.read(authProvider.notifier).logout();
  }
}

final myProfileProvider =
    StateNotifierProvider<MyProfileNotifier, MyProfileState>(
  (ref) => MyProfileNotifier(ref.watch(profileServiceProvider), ref),
);
