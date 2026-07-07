import 'dart:io' as io;

/// 환경변수 조회. 웹에는 존재하지 않으므로 스텁은 항상 null을 반환한다.
String? platformEnv(String key) => io.Platform.environment[key];

/// dart:io의 [io.SocketException] 여부 판별. 웹에서는 발생하지 않는다.
bool isSocketException(Object? error) => error is io.SocketException;
