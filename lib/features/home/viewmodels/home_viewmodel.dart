import 'package:flutter/foundation.dart';

// import 'package:fe_app/core/network/api_client.dart';
// import 'package:fe_app/core/network/api_endpoints.dart';

import 'package:fe_app/features/home/viewmodels/home_state.dart';

/// 홈 데이터 로드. API 준비되면 주석 예시를 해제해 연동하세요.
class HomeViewModel extends ChangeNotifier {
  HomeState _state = const HomeState();

  HomeState get state => _state;

  Future<void> load() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      // 예시 — GET
      // final client = ApiClient();
      // final res = await client.dio.get<Map<String, dynamic>>(
      //   '${ApiEndpoints.basePath}/home',
      // );

      await Future<void>.delayed(Duration.zero);
      _state = _state.copyWith(isLoading: false);
    } catch (_) {
      _state = _state.copyWith(isLoading: false);
    }
    notifyListeners();
  }
}
