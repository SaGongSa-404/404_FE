// [기본 구조] 아래 [LocalStorage] 추상 클래스 + [SharedPreferencesLocalStorage]가 앱의 기본 뼈대입니다.
// [예시] [InMemoryLocalStorage]는 테스트·임시용이며, 실서비스에서는 보통 쓰지 않습니다.

import 'package:shared_preferences/shared_preferences.dart';

// ─── 기본 구조: 저장소 계약 (토큰·설정 등 키-값) ───

abstract class LocalStorage {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
  Future<void> clear();
}

// ─── 기본 구조: 실제 앱에서 쓰는 구현 (SharedPreferences) ───

class SharedPreferencesLocalStorage implements LocalStorage {
  SharedPreferencesLocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPreferencesLocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesLocalStorage(prefs);
  }

  @override
  Future<void> clear() => _prefs.clear();

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
}

// ─── 예시: 인메모리 구현 (단위 테스트·UI만 돌릴 때 등) ───

class InMemoryLocalStorage implements LocalStorage {
  final Map<String, String> _map = {};

  @override
  Future<void> clear() async => _map.clear();

  @override
  Future<String?> getString(String key) async => _map[key];

  @override
  Future<void> remove(String key) async => _map.remove(key);

  @override
  Future<void> setString(String key, String value) async => _map[key] = value;
}
