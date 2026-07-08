# WiGul(위굴) 웹 지원 작업 문서

Flutter 모바일 앱(위굴)을 웹으로 배포하기 위한 분기 처리 및 수정 사항 정리.
`feat/web-support` 브랜치에서 진행.

> 핵심 전제: **웹에서는 `dart:io`를 import할 수 없다.** 초기 상태에선
> `flutter build web`이 컴파일조차 안 됐다. 작업은 두 부류로 나뉜다.
> ① 컴파일이 되게 만드는 필수 수정, ② 기능이 실제 동작하게 만드는 분기.

## 진행 현황

| Phase | 내용 | 상태 |
|---|---|---|
| Phase 1 | `dart:io` 제거 (컴파일 통과) | ✅ 완료 — 웹 빌드 성공 |
| Phase 2 | OAuth 로그인 웹 분기 | ✅ 완료 (백엔드/콘솔 등록은 외부 협조 필요) |
| Phase 3 | 알림(FCM) 웹 분기 | ✅ 완료 (웹은 알림 OFF) |
| Phase 4 | 피드 이미지 업로드 | ✅ 완료 — **대상 없음**(업로드 기능 미존재) |
| Phase 5 | 기타(Analytics·CORS·baseURL 등) | ⬜ 남음 |
| Phase 6 | 빌드 & 배포 | ⬜ 남음 |

> `flutter build web`은 현재 **성공**한다. 단, 웹에서 실제 구동 시
> **Phase 5의 Firebase Analytics 이슈**가 화면 이동을 막을 수 있어 우선 처리 대상.

---

## Phase 1. 컴파일 통과시키기 (`dart:io` 제거) — ✅ 완료

웹은 `dart:io`를 지원하지 않아 관련 파일이 컴파일을 막았다.
`Platform`은 `flutter/foundation`의 `defaultTargetPlatform` + `kIsWeb`으로,
`File`/`SocketException`은 조건부 import로 감싸 해결.

**신규 파일 — dart:io 조건부 래퍼**
- `lib/core/platform/io_platform.dart` — 진입점. `export ... if (dart.library.io) ...`로 분기
- `lib/core/platform/io_platform_io.dart` — 네이티브용: `platformEnv(key)`, `isSocketException(e)`
- `lib/core/platform/io_platform_stub.dart` — 웹 스텁: 각각 `null`, `false`

**수정 파일**

| 파일 | 변경 |
|---|---|
| `lib/core/config/env_config.dart` | `Platform.isIOS/isMacOS/isAndroid` → `defaultTargetPlatform`, `Platform.environment` → `platformEnv()`. `dart:io` 제거 |
| `lib/core/network/network_error.dart` | `SocketException` 체크 → `isSocketException()`. `dart:io` 제거 |
| `lib/features/notification/services/fcm_service.dart` | `Platform.isAndroid/isIOS` → `defaultTargetPlatform`. `dart:io` 제거 |
| `lib/features/notification/services/push_token_service.dart` | 동일. `dart:io` 제거 |
| `lib/features/feed/services/feed_service.dart` | `uploadImage(File)` → `uploadImage(List<int> bytes, {required String filename})` + `MultipartFile.fromBytes`. `dart:io` 제거 |
| `lib/features/feed/viewmodels/feed_viewmodel.dart` | `uploadImage` 시그니처를 바이트 기반으로 맞춤. `dart:io` 제거 |

**적용 패턴:** `Platform.isX` → `!kIsWeb && defaultTargetPlatform == TargetPlatform.X`.
`defaultTargetPlatform`은 실기기에서 실제 OS를 반환하므로 모바일 동작은 기존과 동일
(단 테스트의 `debugDefaultTargetPlatformOverride`로만 오버라이드 가능 — 프로덕션 무관).

이후 `dart:io` import는 `io_platform_io.dart`(네이티브 전용, 웹은 컴파일 안 함)에만 남음.

---

## Phase 2. OAuth 로그인 웹 분기 — ✅ 완료 (외부 협조 필요)

**네이티브 흐름:** 외부 브라우저 → 커스텀 스킴 딥링크(`sagongsa404://auth/callback`)
→ `app_links` 캐치 → `handleCallback`.
**웹 흐름:** 같은 탭 리다이렉트 → 백엔드 OAuth → `https://<origin>/auth/callback#access_token=...`
로 복귀 → 앱 로드 시 `Uri.base`에서 토큰 추출 → 저장 → 라우터가 홈/온보딩으로 이동
(주소창의 토큰 fragment도 이 과정에서 사라짐).

**수정 파일**

| 파일 | 변경 |
|---|---|
| `lib/features/auth/utils/oauth_launch.dart` | `kOAuthRedirectUri` 상수 → `oauthRedirectUri()` 함수. 웹은 `${Uri.base.origin}/auth/callback`, 네이티브는 커스텀 스킴 |
| `lib/features/auth/providers/auth_provider.dart` | `launchOAuthSignIn`에서 `oauthRedirectUri()` 사용 + `launchUrl(webOnlyWindowName: '_self')` |
| `lib/features/auth/utils/oauth_callback_uri.dart` | `isOAuthCallbackUri`가 웹의 `http(s)://.../auth/callback` + 토큰 보유 URL도 인식 |
| `lib/features/auth/providers/deep_link_provider.dart` | 웹은 `app_links` 대신 앱 시작 시 `Uri.base`를 **동기적으로**(await 이전) 읽어 콜백 처리 |
| `lib/main.dart` | 웹에서 `usePathUrlStrategy()` — OAuth fragment 토큰이 라우터와 충돌하지 않게 |
| `pubspec.yaml` | `flutter_web_plugins`(SDK) 추가 |

**⚠️ 코드만으로는 로그인 불가 — 외부 협조 필수**
1. **백엔드 `redirect_uri` 화이트리스트** — 웹 콜백 URL(`http://localhost:<포트>/auth/callback`,
   배포 도메인의 `/auth/callback`) 허용. 토큰을 fragment(권장) 또는 query로 실어 리다이렉트.
2. **카카오/구글 콘솔** — 각 OAuth 앱 Redirect URI에 웹 콜백 URL 등록.
3. **로컬 실행 포트 고정** — `flutter run -d chrome --web-port=<고정포트>` (redirect_uri 일치용).
4. **토큰 저장** — `flutter_secure_storage`는 웹에서 동작하나 내부적으로 브라우저 스토리지라
   "secure"하지 않음. 동작엔 문제없어 유지, 보안 요건 있으면 별도 검토.

---

## Phase 3. 알림 (FCM) 웹 분기 — ✅ 완료 (웹은 알림 OFF)

웹은 초기 배포에서 **알림을 끄는** 방향. 런타임 크래시를 유발하는 3개 지점을 가드.

**수정 파일**

| 파일 | 변경 |
|---|---|
| `lib/core/services/notification_permission_service.dart` | `permission_handler` 호출 전부에 `kIsWeb` 가드 — `shouldPrompt`/`isGranted`/`isPermanentlyDenied`→`false`, `request`/`requestPermission`→no-op·`denied`, `status`→`denied`, `openSettings`→`false` |
| `lib/features/notification/providers/push_token_provider.dart` | `pushTokenLifecycleProvider`를 웹에서 조기 반환(FCM 부트스트랩·토큰 등록 미실행) |
| `lib/features/notification/services/fcm_service.dart` | `start()`·`syncForAuthenticatedUser()`에 방어적 `kIsWeb` 조기 반환 |

**그대로 유지:** `LocalNotificationPresenter._canShowNotification()`이 웹에서 `false` 반환(로컬 알림 미표시).
`deactivateStoredPushToken`은 웹에서 저장 토큰이 없어 자동 early-return.
**앱 내 알림 목록**(API 조회 기반 `notification_screen`)은 웹에서도 정상 동작 — 끈 건 OS 푸시/로컬 알림뿐.

**(선택) 웹 푸시까지 지원하려면** — `web/firebase-messaging-sw.js` 서비스워커 추가
+ VAPID 키 발급 + `getToken(vapidKey:)` 분기. 초기 배포엔 불필요.

---

## Phase 4. 피드 이미지 업로드 — ✅ 완료 (대상 없음)

**결론: 앱에 사용자 이미지 업로드 기능이 없어 웹 분기할 대상이 없다.**

- 피드 게시글 이미지는 사용자가 파일을 올리는 게 아니라 **위시 아이템의 상품 이미지 URL**
  (`item?.imageUrl`)을 붙이는 방식. 표시는 전부 `Image.network`(웹 기본 지원).
- `uploadImage`는 **죽은 코드** — 호출하는 UI 없음. Phase 1에서 이미 바이트 기반 시그니처로
  바꿔 웹 컴파일도 통과. **그대로 유지**하기로 결정.
- 향후 실제 업로드 기능이 필요하면 `image_picker`의 `XFile.readAsBytes()`를 현재 시그니처에
  그대로 넘기면 됨(모바일·웹 공통). 그때 백엔드 업로드 엔드포인트 확인 필요.

---

## Phase 5. 기타 웹 설정 — ⬜ 남음

### 5-1. Firebase Analytics / Core 웹 초기화 (우선 처리 — 웹 구동 차단 가능)

`lib/core/router/app_router.dart`가 라우터 생성 시 항상
`FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)`를 등록한다(`observers`).
웹에서 Firebase가 초기화되지 않은 상태(=`web/index.html`에 Firebase JS SDK/설정 없음, 또는
`FIREBASE_*` env 미설정)라면, 화면 이동 시 `FirebaseAnalytics.instance` 사용에서
`No Firebase App '[DEFAULT]' has been created` 류 에러가 나 **네비게이션이 깨질 수 있다.**

- 관련: `lib/main.dart`의 `FirebaseBootstrap.initialize()`는 웹에서 JS SDK가 없으면 실패하고
  (try/catch로 무시되어) 미초기화 상태로 남는다. `AppFirebaseOptions.currentPlatform`은
  `kIsWeb`이면 env 설정 시 옵션을 반환하도록 되어 있음.

**처리 방향 (택1):**
- (A) 웹에서 analytics observer를 조건부로 제외 — `observers`를 `kIsWeb`(또는 Firebase 미초기화)
  일 때 빈 리스트로. 가장 간단, 웹 애널리틱스 포기.
- (B) `web/index.html`에 Firebase JS SDK + config를 추가해 정식 초기화 — 웹 애널리틱스 유지.

> 초기 배포엔 (A) 권장. FCM도 웹에선 끈 상태이므로 웹 Firebase 의존을 최소화하는 편이 단순.

### 5-2. API Base URL

`env_config.dart`의 `10.0.2.2 → 127.0.0.1` 치환이 `!kIsWeb` 조건이라 웹에선 미적용.
웹 실행 시 `.env`의 `API_BASE_URL`을 브라우저에서 접근 가능한 주소(로컬이면 `localhost`)로
두거나, 웹 분기 치환을 추가.

### 5-3. CORS (백엔드 필수)

브라우저는 CORS를 강제. 백엔드가 웹 오리진(`http://localhost:<포트>`, 배포 도메인)을
`Access-Control-Allow-Origin`에 허용해야 API 호출이 감. 안 되면 로그인 이후 모든 요청이 막힘.
- 허용 메서드: `GET/POST/PATCH/PUT/DELETE/OPTIONS`(preflight `OPTIONS` 응답 포함)
- 허용 헤더: `Authorization`, `Content-Type`(멀티파트 포함)
- 본 앱은 Bearer 토큰 방식(쿠키 아님) → `Access-Control-Allow-Credentials` 불필요(확인 요망)

### 5-4. 라우팅 / index.html

- URL 전략: **Phase 2에서 `usePathUrlStrategy()` 적용 완료.** 경로가 그대로 노출됨.
  → 배포 호스트에서 SPA rewrite 필요(아래 Phase 6).
- `web/index.html`, `web/manifest.json`은 이미 존재. 앱 타이틀/파비콘/테마 다듬기.

---

## Phase 6. 빌드 & 배포 — ⬜ 남음

1. `flutter build web --release`.
   - 참고: `flutter_secure_storage_web`가 `dart:html`을 써서 **wasm dry-run 경고**가 뜨지만
     기본 JS 빌드(dart2js)는 정상. wasm 타겟이 필요할 때만 대안 검토.
2. `build/web/` 정적 파일을 호스팅(Firebase Hosting, Netlify, S3+CloudFront 등)에 배포.
   - **SPA rewrite 필수** — path URL 전략이라 `/auth/callback`, `/home` 등 직접 진입 시
     `index.html`로 fallback 되도록 설정(로컬 `flutter run`은 자동 처리).
   - **`.env` 노출 주의** — 애셋으로 번들되어 웹에선 값이 노출됨. 공개돼도 되는 값만 두거나
     `--dart-define`로 주입 검토.

---

## 요약

- **Phase 1~4는 완료**되어 `flutter build web`이 성공한다.
- 웹에서 **실제로 앱이 뜨는 것**을 막을 수 있는 코드성 이슈는 **Phase 5-1(Firebase Analytics)** 이
  거의 유일 — 우선 처리 권장.
- **Phase 2(OAuth)** 와 **Phase 5-3(CORS)** 는 프론트 코드만으로 끝나지 않음 —
  백엔드 redirect_uri 화이트리스트·CORS 설정, OAuth 콘솔 등록이 반드시 선행돼야 함.
- **웹은 알림 OFF, 이미지 업로드 없음** 상태로 배포됨(둘 다 의도된 범위).
