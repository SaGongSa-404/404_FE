import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage.g.dart';

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(Ref ref) => SecureStorageService();

class SecureStorageService {
  static const _accessTokenKey  = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // 웹의 flutter_secure_storage는 값을 SubtleCrypto(AES-GCM)로 암복호화한다.
  // AES 키 초기화가 동시 접근에 안전하지 않아, 여러 read/write가 겹치면
  // Web Crypto가 `OperationError`를 던지고 이게 uncaught로 새어 흐름이 끊긴다.
  // 모든 접근을 단일 큐로 직렬화해 동시 crypto 연산을 원천 차단한다.
  Future<void> _queue = Future<void>.value();

  Future<T> _synchronized<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _queue = _queue.then((_) async {
      try {
        completer.complete(await action());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    // 순차 write (동시 write 금지).
    return _synchronized(() async {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    });
  }

  Future<String?> getAccessToken() => _synchronized(() async {
        try {
          return await _storage.read(key: _accessTokenKey);
        } catch (error, stackTrace) {
          // 복호화 실패(OperationError 등)는 토큰 없음으로 처리 — 크래시 방지.
          debugPrint('[storage] getAccessToken failed: $error\n$stackTrace');
          return null;
        }
      });

  Future<String?> getRefreshToken() => _synchronized(() async {
        try {
          return await _storage.read(key: _refreshTokenKey);
        } catch (error, stackTrace) {
          debugPrint('[storage] getRefreshToken failed: $error\n$stackTrace');
          return null;
        }
      });

  Future<void> clearTokens() {
    return _synchronized(() async {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    });
  }
}
