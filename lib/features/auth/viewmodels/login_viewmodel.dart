import 'package:flutter/foundation.dart';

// import 'package:fe_app/core/network/api_client.dart';
// import 'package:fe_app/core/network/api_endpoints.dart';

import 'package:fe_app/features/auth/viewmodels/login_state.dart';

/// 로그인 로직. [ApiEndpoints.login] 등 정의 후 아래 주석 블록을 해제해 연동하세요.
class LoginViewModel extends ChangeNotifier {
  LoginState _state = const LoginState();

  LoginState get state => _state;

  Future<void> submit({
    required String email,
    required String password,
  }) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      // 예시 — 실제 API
      // final client = ApiClient();
      // await client.dio.post<Map<String, dynamic>>(
      //   ApiEndpoints.login,
      //   data: {'email': email, 'password': password},
      // );

      // 스켈레톤: UI 흐름만 확인할 때 (연동 시 위 블록으로 교체)
      await Future<void>.delayed(Duration.zero);

      _state = _state.copyWith(isLoading: false);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
    notifyListeners();
  }
}
