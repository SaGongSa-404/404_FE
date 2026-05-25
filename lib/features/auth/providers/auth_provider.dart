import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/features/auth/models/user.dart';

/// 앱 시작 시 스플래시 화면에서 멈추는 현상을 방지하기 위해 
/// 즉시 AsyncData(null) 상태를 반환하도록 설정된 수동 Provider입니다.
/// FutureOr를 사용하여 초기 로딩 상태(AsyncLoading)를 발생시키지 않습니다.
class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  FutureOr<UserModel?> build() {
    // API 연동 전이므로 동기적으로 null을 반환하여 즉시 완료 상태가 되도록 합니다.
    return null;
  }

  Future<void> handleCallback(Uri uri) async {
    state = const AsyncLoading();
    // OAuth 콜백 처리 (테스트용 임시 완료)
    state = const AsyncData(null);
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    // 로그아웃 처리 (임시 완료)
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
