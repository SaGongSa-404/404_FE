# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**WiGul (위굴)** — Flutter mobile app that helps users overcome impulse buying. Built with Dart/Flutter for Android and iOS.

## Commands

```bash
flutter pub get                           # Install dependencies
flutter run                               # Run on connected device/emulator
flutter analyze                           # Lint (Dart analyzer)
flutter test                              # Run tests
flutter test test/path/to/test.dart       # Run a single test file

# Code generation (required after adding/modifying freezed models, Riverpod providers, or JSON serializable classes)
flutter pub run build_runner build        # One-time generation
flutter pub run build_runner watch        # Watch mode during development
```

## Architecture

Clean Architecture with feature-based modules under `lib/`:

```
lib/
├── main.dart            # Entry point: loads .env, wraps app in ProviderScope
├── app.dart             # MaterialApp.router setup
├── core/
│   ├── network/         # Dio HTTP client + AuthInterceptor + API endpoints
│   ├── router/          # Go Router setup and redirect logic
│   ├── storage/         # Secure token storage (flutter_secure_storage)
│   ├── theme/           # AppColors, AppTextStyles
│   └── utils/           # Validators, date formatters
├── features/            # Feature modules (auth, home, onboarding, splash, notification, wishlist, profile)
│   └── <feature>/
│       ├── models/
│       ├── viewmodels/  # StateNotifier + State classes
│       ├── views/       # Widgets/screens
│       ├── providers/   # Riverpod providers
│       └── services/    # API call wrappers
└── shared/
    ├── models/
    └── widgets/         # Reusable UI components (buttons, loaders, bottom nav)
```

`profile` (마이페이지: 프로필/닉네임, 예산·소비 통계, 위시 히스토리, 알림설정, 내 게시글, 약관)은 위 레이어 구조를 가장 충실히 따르는 모듈이라 다른 feature 작업 시 참고하기 좋음.

## Feature Module: profile (`lib/features/profile/`)

**models/**
- `MyProfile` — 내 프로필 요약(`id`, `nickname`, `provider`, `status`, `onboardingStatus`, `postCount`, `createdAt`). `isValid`, `userStatus`/`isRestrictedAccount`(제재 여부) 게터.
- `MonthlyStats` (+`CategorySpendAmount`) — 월별 예산/지출/절제 통계. `displayMonth`, `isExceeded`, `progressFactor` 게터.
- `ConsumptionRecord` (+`ConsumptionListResponse`) — 월별 소비기록(구매/절제 결정) 원본. `lookupKey`/`titleResultKey`로 위시 아이템과 매칭할 때 사용.
- `WishHistoryItem` (+`WishHistoryReflection`) — 위시/결정 히스토리. `isGo`, `isDecided`, `canEditDecision` 게터.
- `NotificationSettings` — 알림 수신 여부.
- 모든 모델이 `_asInt`/`_asIntOrNull`/`_asDouble` 같은 안전 파싱 헬퍼로 서버 응답 타입 불일치를 방어.

**services/**
- `ProfileService` (`profile_service.dart`, `/api/v1/users/me/*`) — 프로필 조회·닉네임 수정·예산 수정·탈퇴·알림설정·통계월목록·월별통계·위시히스토리·내 게시글 목록.
- `ConsumptionService` (`consumption_service.dart`, `/api/v1/my/consumption`) — 월별 소비기록 조회.
- 둘 다 `@Riverpod(keepAlive: true)`.

**providers/** (모두 `StateNotifierProvider`)
- `myProfileProvider` — 프로필 로드(404 시 auth 상태로 폴백), 닉네임 수정, 탈퇴+로그아웃.
- `consumptionStatsProvider` — 월별 통계 캐시(`statsByMonth`); 예산 수정 시 `applyBudgetOverride`로 낙관적 갱신.
- `monthlyConsumptionProvider` (family+autoDispose, key=yearMonth) — 위시히스토리와 소비기록을 병합해 `decisionId`를 휴리스틱으로 역추정(`_resolveDecisionId`); GO/STOP 결정 수정 후 `consumptionStatsProvider`도 함께 갱신.
- `notificationSettingsProvider` — 알림 on/off.
- `myPostsProvider` → `MyPostsViewModel` — 내가 쓴 피드 글 커서 페이지네이션, 투표/삭제/수정, 삭제 여부(404) 선확인 후 상세 진입.

**views/**
- `my_page_screen` — 마이페이지 허브(닉네임/프로필 편집 진입, 메뉴 목록, 알림 토글).
- `edit_profile_screen` — 닉네임 수정, 로그아웃, 회원 탈퇴.
- `consumption_management_screen` → `monthly_spending_detail_screen` — 이번 달/월별 예산·소비 상세, 예산 수정 모달, 소비 결정(GO/STOP) 수정 모달.
- `my_posts_screen` — 내 게시글 목록.
- `terms_policy_screen` — 이용약관/개인정보 처리방침.

**utils/validators/**
- `month_display` — `yyyy-MM` ↔ `yyyy.MM` 변환.
- `profile_json` — API 응답 언랩(`data`/`result`/`payload` 키 처리).
- `provider_label` — 카카오/구글 로그인 provider 라벨.
- `profile_nickname_validator` — 닉네임 길이/허용 문자 검증.

## Navigation

**Go Router** with a `_RouterNotifier` class. Routes are defined in `lib/core/router/app_router.dart`.

Key redirect rules:
- `/` (splash) checks auth state → routes to `/home` or `/login`
- Logged-in users hitting `/login` → redirect to `/onboarding/nickname`
- Unauthenticated access to protected routes → redirect to `/login`

Onboarding is a sequential multi-step flow: nickname → budget → survey → wishlist tutorial → nugul intro.

## State Management

**Flutter Riverpod 2.x** with MVVM pattern:
- Providers are auto-generated from `@riverpod` annotations (requires `build_runner`)
- `StateNotifierProvider<ViewModel, State>` for mutable feature state
- `authProvider` is `keepAlive: true` — persists across navigation

## Network / Auth Layer

**Dio** client in `lib/core/network/api_client.dart`:
- Base URL from `.env` (`API_BASE_URL`)
- `AuthInterceptor` injects `Authorization: Bearer {token}` on every request
- On 401: automatically refreshes token via `/api/auth/token/refresh` and retries
- Tokens stored with `flutter_secure_storage` (encrypted shared prefs on Android)

**OAuth flow:** External browser → deep link callback (tokens in URL fragment) → `app_links` captures URI → `auth.handleCallback(uri)` stores tokens.

## Code Generation

This project uses `freezed`, `json_serializable`, and `riverpod_generator`. Any `.freezed.dart`, `.g.dart` files are generated — never edit them manually. Run `build_runner build` after modifying annotated classes.

## Linting

`analysis_options.yaml` inherits `package:flutter_lints/flutter.yaml`. Use **absolute imports** (`package:fe_app/...`) — `prefer_relative_imports` is disabled.

## Environment

Requires a `.env` file in the project root (not tracked in git):
```
API_BASE_URL=http://localhost:8080
```

## Git Workflow

GitHub Flow: feature branches named `frontend/<name>/<task>`. Squash merge to main. Commit messages are written in Korean.
