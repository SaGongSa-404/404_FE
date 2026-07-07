# WiGul(위굴) 웹 지원 작업 문서

Flutter 모바일 앱(위굴)을 웹으로 배포하기 위한 분기 처리 및 수정 사항 정리.

> 핵심 전제: **웹에서는 `dart:io`를 import할 수 없다.** 따라서 현재 상태로는
> `flutter build web`이 **컴파일조차 안 된다.** 작업은 두 부류로 나뉜다.
> ① 컴파일이 되게 만드는 필수 수정, ② 기능이 실제 동작하게 만드는 분기.

---

## Phase 0. 준비

1. `feat/web-support` 브랜치에서 작업.
2. `flutter run -d chrome` 실행 → 실제 컴파일 에러 목록을 뽑아 기준점 확보.

---

## Phase 1. 컴파일 통과시키기 (필수 — `dart:io` 제거)

웹은 `dart:io`를 지원하지 않아, 아래 6개 파일이 컴파일을 막는다.
`Platform`은 `flutter/foundation`의 `defaultTargetPlatform` + `kIsWeb`으로,
`File` / `SocketException`은 조건부 처리로 바꾼다.

| 파일 | 문제 | 조치 |
|---|---|---|
| `lib/core/config/env_config.dart:1` | `Platform.isIOS/isMacOS/isAndroid`, `Platform.environment` | `defaultTargetPlatform`로 대체. `Platform.environment`(시뮬레이터 판별)는 웹에 없으니 `kIsWeb` 가드로 분리 |
| `lib/core/network/network_error.dart:1` | `SocketException` | 조건부 import 스텁 or 타입명 문자열 체크로 우회 |
| `lib/features/notification/services/fcm_service.dart:3` | `Platform.isAndroid/isIOS` | `defaultTargetPlatform`로 대체 |
| `lib/features/notification/services/push_token_service.dart:1` | `Platform.isIOS/isAndroid` | `defaultTargetPlatform`로 대체 |
| `lib/features/feed/services/feed_service.dart:1` | `File`, `MultipartFile.fromFile` | Phase 4에서 처리 |
| `lib/features/feed/viewmodels/feed_viewmodel.dart:1` | `File` 파라미터 | Phase 4에서 처리 |

**권장 패턴:** `Platform.isX` → `!kIsWeb && defaultTargetPlatform == TargetPlatform.X`.
이러면 `dart:io` import 자체를 지울 수 있다.

이 Phase만 끝나면 **웹에서 화면은 뜬다** (로그인/알림/업로드 제외).

---

## Phase 2. OAuth 로그인 웹 분기 (필수 — 안 하면 로그인 불가)

**현재 흐름 (모바일 전용):** 외부 브라우저 → 커스텀 스킴 딥링크(`sagongsa404://auth/callback`)
→ `app_links`가 캐치 → `handleCallback`.

3. **리다이렉트 URI 웹용 분리** — `lib/features/auth/utils/oauth_launch.dart:5`의
   `kOAuthRedirectUri`를 웹에선 `https://<web-domain>/auth/callback` 같은 실제 URL로 분기.
4. **콜백 수신 방식 교체** — `lib/features/auth/providers/deep_link_provider.dart`의
   `app_links`는 웹에서 안 뜨므로, 웹에서는 앱 시작 시 현재 URL(`Uri.base`)의
   쿼리/프래그먼트에서 토큰을 읽어 `handleCallback` 호출하는 경로 추가.
5. **launch 방식** — `launchOAuthSignIn`(`lib/features/auth/providers/auth_provider.dart:60`)에서
   웹은 같은 탭 리다이렉트가 자연스러움 (`url_launcher`의 `webOnlyWindowName: '_self'`).
6. **백엔드 협의** — OAuth `redirect_uri` 화이트리스트에 웹 도메인 추가 필요.
   카카오/구글 콘솔에도 웹 리다이렉트 등록.
7. **토큰 저장** — `flutter_secure_storage`는 웹에서 컴파일·동작은 되지만 내부적으로
   브라우저 스토리지라 "secure"하지 않음. 동작엔 문제없으니 일단 유지, 보안 요건 있으면 별도 검토.

---

## Phase 3. 알림 (FCM) 웹 분기

8. **필수(컴파일/크래시 방지)** — `firebase_messaging` 웹 초기화 시 서비스워커가 없으면 에러.
   웹에서 FCM을 **끄는** 게 가장 간단: `lib/features/notification/providers/push_token_provider.dart`의
   부트스트랩을 `if (!kIsWeb)`로 감싸고, `syncForAuthenticatedUser`도 웹 조기 반환.
9. `fcm_service.dart`의 `LocalNotificationPresenter`는 이미 `_canShowNotification`이
   `kIsWeb`에서 `false` 반환(`:343`)하도록 되어 있어 OK. `flutter_local_notifications` 자체는
   웹 미지원이므로 `show`/`initialize` 경로가 웹에서 호출되지 않게만 유지.
10. **(선택) 웹 푸시까지 지원하려면** — `web/firebase-messaging-sw.js` 서비스워커 추가
    + VAPID 키 발급 + `getToken(vapidKey:)` 분기. 초기 배포엔 8·9만으로
    "알림 없이 동작" 상태로 두는 걸 권장.

---

## Phase 4. 피드 이미지 업로드 웹 분기

`uploadImage(File)`은 정의돼 있으나 아직 UI에서 호출되진 않는 것으로 보임(latent).
하지만 `dart:io`/`File` 타입 때문에 컴파일은 막으므로 처리 필요.

11. `image_picker` 의존성 추가 (웹 지원됨) → `XFile`로 통일.
12. `lib/features/feed/services/feed_service.dart:93`의 `uploadImage(File file)` →
    `uploadImage(XFile file)`로 시그니처 변경, 내부를
    `MultipartFile.fromBytes(await file.readAsBytes(), filename: file.name)`로 교체
    (경로 대신 바이트 사용 → 모바일·웹 공통 동작).
13. `lib/features/feed/viewmodels/feed_viewmodel.dart:403` 시그니처도 `XFile`로 맞춤.

---

## Phase 5. 기타 웹 설정

14. **API Base URL** — `env_config.dart`의 `10.0.2.2 → 127.0.0.1` 치환이 `!kIsWeb`
    조건이라 웹에선 안 바뀜. 웹 실행 시 `.env`의 `API_BASE_URL`을 실제 접근 가능한
    주소로(로컬이면 `localhost`) 두거나, 웹 분기 치환 추가.
15. **CORS (백엔드 필수)** — 브라우저는 CORS를 강제하므로, 백엔드가 웹 오리진
    (`http://localhost:xxxx`, 배포 도메인)을 `Access-Control-Allow-Origin`에 허용해야
    API 호출이 감. 안 되면 로그인 이후 모든 요청이 막힘.
16. **`web/index.html`, `web/manifest.json`** — 이미 존재. 앱 타이틀/파비콘/테마 정도만 다듬기.
17. **라우팅** — `go_router` 사용 중이라 웹에서 URL 경로가 그대로 노출됨.
    필요 시 해시 전략(`usePathUrlStrategy`) 여부 결정.

---

## Phase 6. 빌드 & 배포

18. `flutter build web --release`.
19. `build/web/` 정적 파일을 호스팅(Firebase Hosting, Netlify, S3+CloudFront 등)에 배포.
    `.env`는 애셋으로 번들되므로 웹에선 **민감값이 노출**됨 → 웹 빌드엔 공개돼도 되는 값만
    두거나 `--dart-define`로 주입 검토.

---

## 요약

- **Phase 1 (dart:io 제거)**, **Phase 2 (OAuth)**, **Phase 4 (업로드 시그니처)** 는
  컴파일·기본 동작을 위해 **반드시** 필요.
- **Phase 3 (알림)** 은 "웹에선 끄기"로 최소화 가능, 웹푸시는 나중에.
- **Phase 5의 CORS** 는 프론트가 아무리 맞춰도 **백엔드 협조가 없으면 못 씀** —
  팀과 먼저 확인 필요.

**추천 순서:** Phase 1(컴파일 통과) → `flutter run -d chrome`로 화면 확인 → Phase 2(로그인).
