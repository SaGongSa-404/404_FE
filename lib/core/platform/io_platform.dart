/// dart:io에 의존하는 유틸을 웹/네이티브 공통으로 노출하는 단일 진입점.
///
/// 웹에서는 dart:io를 import할 수 없으므로 조건부 export로 스텁을 사용한다.
/// - 네이티브(dart:io 사용 가능): [io_platform_io.dart]
/// - 웹 등 그 외: [io_platform_stub.dart]
library;

export 'io_platform_stub.dart' if (dart.library.io) 'io_platform_io.dart';
