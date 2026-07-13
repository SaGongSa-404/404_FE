// 웹 등 dart:io를 사용할 수 없는 플랫폼용 스텁.

/// 웹에는 프로세스 환경변수 개념이 없으므로 항상 null.
String? platformEnv(String key) => null;

/// 웹의 HTTP 어댑터는 SocketException을 던지지 않으므로 항상 false.
/// (네트워크 오류는 DioExceptionType.connectionError로 분류됨)
bool isSocketException(Object? error) => false;
