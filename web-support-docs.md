# WiGul(위굴) 웹 지원 작업 문서

Flutter 모바일 앱(위굴)을 웹으로 배포하기 위한 분기 처리 및 수정 사항 정리.
`feat/web-support` 브랜치에서 진행.

> 핵심 전제: **웹에서는 `dart:io`를 import할 수 없다.** 초기 상태에선
> `flutter build web`이 컴파일조차 안 됐다. 작업은 두 부류로 나뉜다.
> ① 컴파일이 되게 만드는 필수 수정, ② 기능이 실제 동작하게 만드는 분기.

## 진행 현황

| Phase | 내용 | 상태 |
|---|---|---|
| Phase 1 | `dart:io` 제거 (컴파일 통과) | ✅ 완료 |
| Phase 2 | OAuth 로그인 웹 분기 | ✅ 완료 (백엔드/콘솔 등록 필요) |
| Phase 3 | 알림(FCM) 웹 분기 | ✅ 완료 (웹은 알림 OFF) |
| Phase 4 | 피드 이미지 업로드 | ✅ 완료 — **대상 없음**(업로드 기능 미존재) |
| Phase 5 | 기타(Analytics·CORS·baseURL 등) | ✅ 완료 |
| Phase 6 | 빌드 & 배포 | ✅ 완료 — **배포 라이브** |

> **배포 URL: https://wigul-d9245.web.app** (Firebase Hosting)
> Phase 1~6 완료. 웹에서 화면·라우팅·로그인 플로우 동작 확인됨.

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

**⚠️ 코드만으로는 로그인 불가 — 외부 협조 필수 (배포 도메인 기준은 하단 부록 참고)**
1. **백엔드 `redirect_uri` 화이트리스트** — 웹 콜백 URL 허용, 토큰을 fragment(권장)/query로 리다이렉트.
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

## Phase 5. 기타 웹 설정 — ✅ 완료

### 5-1. Firebase Analytics 웹 가드 — ✅ 완료

`lib/core/router/app_router.dart`가 라우터 생성 시 항상
`FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)`를 등록했는데, 웹에서 Firebase
미초기화 시 화면 이동마다 `No Firebase App '[DEFAULT]'` 류 에러가 날 수 있었다.

- **조치(택A):** observer를 `if (!kIsWeb && FirebaseBootstrap.isInitialized)`일 때만 등록.
  웹/미초기화 상태에선 observer 자체를 넣지 않아 네비게이션 크래시 방지. 웹 애널리틱스는 포기.
- 나중에 웹 애널리틱스가 필요하면 `web/index.html`에 Firebase JS SDK를 추가해 정식 초기화(택B).

### 5-2. API Base URL 웹 분기 — ✅ 완료

`env_config.dart`의 `apiBaseUrl` getter에 웹 분기 추가:
웹에선 `10.0.2.2`(안드로이드 에뮬 주소)를 `localhost`로 치환 → 브라우저에서 접근 가능.
(실제 배포 `.env`는 공개 HTTPS 백엔드 `https://34-66-55-165.sslip.io/`를 사용하므로 치환과 무관하게 동작.)

### 5-3. CORS (백엔드) — 백엔드 처리 (하단 부록 참고)

프론트 코드 변경 없음. 백엔드가 웹 오리진을 허용해야 함 → **부록. 백엔드 요청 사항** 참고.

### 5-4. 라우팅 / index.html·manifest — ✅ 완료

- URL 전략: Phase 2에서 `usePathUrlStrategy()` 적용. → 배포 호스트에서 SPA rewrite 필요(Phase 6에서 설정).
- `web/index.html` / `web/manifest.json`: 플레이스홀더(`fe_app`, "A new Flutter project") →
  **위굴** 타이틀·설명, 테마/배경색 `#F1F1F1`로 갱신.

---

## Phase 6. 빌드 & 배포 — ✅ 완료 (Firebase Hosting)

**배포 URL: https://wigul-d9245.web.app** (별칭: `https://wigul-d9245.firebaseapp.com`)

### 배포 구성 (신규 파일)

| 파일 | 내용 |
|---|---|
| `firebase.json` | `public: build/web`, SPA rewrite(`"**" → /index.html`), `ignore`에서 dotfile 규칙 제외(아래 함정 참고) |
| `.firebaserc` | 기본 프로젝트 `wigul-d9245` 지정 |

### 최초 배포 절차

1. Firebase CLI 설치: `npm install -g firebase-tools`
2. 로그인(브라우저 인증): `firebase login`
3. 빌드: `flutter build web --release`
4. 배포: `firebase deploy --only hosting`

### 재배포 (코드 수정 후)

```bash
flutter build web --release
firebase deploy --only hosting
```

### 에러 해결 과정
#### error1 — `.env`가 배포 제외되어 백지 화면

- **증상:** 배포 후 스플래시조차 안 뜨는 백지. 콘솔에 `env_config.dart:48`의
  `StateError('BASE_URL or API_BASE_URL is required.')`.
- **원인:** `firebase.json`의 기본 `ignore` 규칙 `"**/.*"`가 **점파일 전체를 배포 제외** →
  `.env`(점파일)가 업로드 안 됨 → 배포 사이트에서 `/assets/.env` 요청이 SPA rewrite에 걸려
  `index.html`을 반환 → `dotenv`가 HTML을 파싱해 env가 비어버림 → `apiBaseUrl`이 예외.
- **해결:** `ignore`에서 `"**/.*"` 제거. (`.env`가 정적 파일로 배포되어 `/assets/.env` 200 응답)
- **검증:** `curl https://wigul-d9245.web.app/assets/.env` → `API_BASE_URL=...` 확인.

#### error2 — 서비스워커 캐시로 옛 빌드가 계속 뜸

- Flutter 웹은 `flutter_service_worker.js`가 이전 빌드를 강하게 캐시. 재배포 후 `Ctrl+Shift+R`
  로도 옛 화면이 뜰 수 있음.
- **확인법:** 시크릿 창으로 열기(캐시/SW 없음). 일반 창은 DevTools → Application →
  Clear site data(또는 Service Workers → Unregister) 후 새로고침.

### `.env` 노출 주의

`.env`는 정적 애셋이라 `https://wigul-d9245.web.app/assets/.env`로 **누구나 다운로드 가능**.
- Firebase API 키는 클라이언트 공개용이라 노출돼도 안전.
- 민감값이 생기면 `.env` 대신 `--dart-define` 주입 방식으로 옮기는 것을 검토.

---

## 요약

- **Phase 1~6 완료** — https://wigul-d9245.web.app 로 배포 라이브, 화면·라우팅·로그인 플로우 동작.
- 웹 전용 분기의 핵심: `dart:io` 제거(io_platform 래퍼), OAuth 콜백을 `Uri.base`로 수신 +
  path URL 전략, 알림/이미지 업로드는 웹에서 비활성(의도된 범위).
- **배포 시 주의 2가지:** `firebase.json` `ignore`의 dotfile 규칙 제거(`.env` 배포),
  재배포 후 서비스워커 캐시 삭제.
- **외부 의존:** OAuth 로그인·API 호출은 백엔드 CORS 허용 + redirect_uri 화이트리스트 +
  카카오/구글 콘솔 등록이 배포 도메인 기준으로 되어 있어야 함 → 아래 부록.

---

## 부록. 백엔드 / OAuth 콘솔 요청 사항

배포 도메인 **`https://wigul-d9245.web.app`** 기준. 아래가 되어 있어야 웹 로그인·API가 동작한다.

### 1. CORS 허용 (없으면 웹에서 API 호출 전부 실패)

- **허용 오리진 (`Access-Control-Allow-Origin`)**
  - 배포: `https://wigul-d9245.web.app` (필요 시 `https://wigul-d9245.firebaseapp.com`도)
  - 로컬 개발: `http://localhost:<고정포트>`
- **허용 메서드**: `GET, POST, PATCH, PUT, DELETE, OPTIONS` (preflight `OPTIONS` 정상 응답)
- **허용 헤더**: `Authorization`, `Content-Type`(멀티파트 포함)
- **인증 방식**: 쿠키 아닌 `Authorization: Bearer` → `Access-Control-Allow-Credentials` 불필요(확인).

### 2. OAuth `redirect_uri` 화이트리스트 (없으면 웹 로그인 불가)

- **추가할 redirect_uri**
  - 배포: `https://wigul-d9245.web.app/auth/callback`
  - 로컬: `http://localhost:<고정포트>/auth/callback`
- **토큰 전달**: 콜백 URL로 리다이렉트 시 토큰을 fragment(`#access_token=...&refresh_token=...`)
  또는 query로 전달. fragment 권장(서버 로그·리퍼러에 토큰 미노출). 프론트는 둘 다 파싱 가능.

### 3. OAuth 콘솔 등록 (카카오 / 구글)

- 카카오/구글 개발자 콘솔 → 각 앱 Redirect URI에 위 웹 콜백 URL 추가.

> 참고: SPA rewrite(호스팅 설정)와 `.env` 값 관리는 프론트/배포 쪽 몫이라 위 요청에서 제외.
