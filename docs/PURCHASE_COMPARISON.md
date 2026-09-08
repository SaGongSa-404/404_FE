# 비교하고 실제 구매를 정리하는 첫 업데이트

기획: https://github.com/SaGongSa-404/404_BE/issues/263

## 사용자 흐름

1. 기존 Android 공유 메뉴 또는 상품 추가에서 링크/상품을 저장한다. 가격을 모르면 비워둘 수 있고 카테고리는 기본 기타다.
2. 위시리스트의 `비교·구매 정리`에서 상품 두 개를 선택한다. 사진·이름·가격·링크·메모를 보고 비교한다.
3. `고민 중 / 샀어요 / 안 사요`를 기록한다. 설문 응답은 필수가 아니다. 생각 정리 질문은 펼쳐 볼 수 있는 선택 도움말이다.
4. `샀어요`에 실제 원화 결제 금액과 구매일을 입력한다. 금액 정정·구매 취소 시 월 예산을 함께 정정한다.
5. `정리한 기록`에서 새 기록을 다시 읽고 수정한다. 이전 설문 결정은 읽기만 제공하고 기존 소비 기록으로 안내한다.

기존 Android 공유 수신 기능을 재사용한다. 친구 초대·설치 없는 투표·카카오 SDK 추가·커뮤니티 개편은 이번 범위에 포함하지 않는다.

## API와 장애 처리

BE의 `/api/v1/purchase-items` 계약이 필요하다. availability의 enabled가 true인 계정에 새 진입을 노출한다. 서버 OFF여도 hasRecords 계정에는 읽기 진입을 유지한다. 배포 전 서버에서는 availability 404이므로 기존 위시리스트 흐름을 유지한다.

저장 요청은 item revision과 UUID mutationId를 사용한다. 같은 입력의 응답 유실 재시도는 화면에 유지한 같은 키를 사용하고, 성공 후 상세를 다시 읽는다. 앱 재시작 후에는 상세의 최신 revision을 읽어 새 명령을 만든다. 중복 클릭 중에는 버튼을 막는다. 목록 실패는 빈 목록과 구분하고 재시도 버튼을 제공한다.

가격 미입력은 null로 전송한다. 통화가 다르거나 한쪽 가격이 없으면 가격 차이를 계산하지 않는다. 실제 결제 입력은 원화 기준이다.

## 통계와 제한

새 구매 기록은 월 지출·구매 건수·카테고리 금액에 포함된다. 합리성 평가, 캐릭터 평가, 기존 월 상세 목록, 7일 회고는 기존 설문 결정 기준이다. 새 기록에는 가짜 설문이나 등급을 만들지 않는다. 소비 관리 화면에 구분 안내와 새 기록 진입점을 둔다. 새로운 7일 회고 연결은 후속 범위다.

Firebase 초기화 시 comparison_opened / comparison_completed / purchase_outcome_saved를 기록한다. 상품 링크·제목·메모·금액은 이벤트에 전송하지 않는다. 저장 이벤트의 무작위 event_id는 재시도 중복 집계 구분용이다. 분석 전송 실패는 구매 저장을 막지 않는다. 실기기 수집 여부는 별도 확인한다.

## 재현 환경과 검증

Flutter 3.35.7 / Dart 3.9.2를 .fvmrc와 CI에 고정했다. 현재 잠긴 analyzer/code generator가 이 Dart 버전과 호환되며, 설치된 Flutter 3.47/Dart 3.13에서는 코드 생성이 완료되지 않았다. 의존성을 대규모 업그레이드하지 않고 meta/test_api만 SDK 잠금 버전에 맞췄다. 앱 version은 아직 변경하지 않았다.

```sh
flutter --version
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze --no-fatal-infos --no-fatal-warnings
dart analyze --fatal-infos lib/features/purchase test/purchase test/widget_test.dart
flutter test --reporter expanded
```

빌드 자산으로 .env가 필요하다. 테스트는 `API_BASE_URL=http://127.0.0.1:8080`만 들어간 로컬 파일을 사용하며 실제 서버로 요청하지 않는다. 운영 환경값과 서명 파일은 커밋하지 않는다. 전체 분석의 기존 warning/info는 남겨 보고하고 신규 구매 모듈은 엄격 분석한다.

기존 앱 스모크 테스트의 누락된 ProviderScope/로그아웃 설정을 보완했다. 이 테스트가 발견한 NotificationAppShell 종료 시 disposed ref 접근도 수정했다. 실제 라우터가 스플래시 이후 로그인 화면으로 이동하고 종료되는지 검증한다.

## 출시 순서

이 PR은 병합/서버 배포/Play 업로드를 실행하지 않는다.

1. 두 PR 검토 후 호환 BE를 기능 OFF로 배포한다.
2. 본인 계정만 서버 허용 목록에 넣고 새 앱을 내부 테스트한다.
3. 아래 RUNBOOK의 실기기 항목을 확인한다.
4. Play Console에서 현재 최대 versionCode와 앱 서명/업로드 권한을 확인하고 새 AAB를 빌드한다.
5. 본인 테스트 통과 후 작은 GA 업데이트를 진행한다. 실제 사용자 확보 없이 형식적인 외부 비공개 베타를 전제하지 않는다.

CI/위젯 테스트는 Android 서명 빌드, Play 설치, 실제 API 로그인/공유/알림 수신을 증명하지 않는다.
