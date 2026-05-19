import 'package:fe_app/features/auth/views/login_screen.dart';
import 'package:fe_app/features/feed/views/feed_detail_screen.dart';
import 'package:fe_app/features/feed/views/feed_edit_screen.dart';
import 'package:fe_app/features/feed/views/feed_screen.dart';
import 'package:fe_app/features/feed/views/feed_write_screen.dart';
import 'package:fe_app/features/notification/views/notification_screen.dart';
import 'package:fe_app/features/onboarding/views/nugul_intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/auth/views/signup_screen.dart';
import 'package:fe_app/features/home/views/home_screen.dart';
import 'package:fe_app/features/onboarding/views/budget_screen.dart';
import 'package:fe_app/features/onboarding/views/nickname_screen.dart';
import 'package:fe_app/features/onboarding/views/survey_screen.dart';
import 'package:fe_app/features/tutorial/views/wishlist_tutorial_route_screen.dart';
import 'package:fe_app/features/splash/views/splash_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_consider_screen.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:fe_app/features/wishlist/views/components/form/wishlist_product_fetch_failed_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_reflect_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_screen.dart';

// 스플래시 최소 표시 시간: 애니메이션과 동기화 (4sec)
final _splashMinDurationProvider = FutureProvider<void>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 4000));
});

/// 하단 탭 루트 간 이동 시 Material 기본 슬라이드 대신 전환 없음(탭 전환 느낌)
NoTransitionPage<void> _bottomTabPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: child,
  );
}

/// 비로그인에서도 접근 허용 — **경로와 정확히 일치**할 때만.
/// (UI 테스트용. 프로덕션에서 막으려면 항목 제거.)
const Set<String> _guestAllowExactPaths = {
  '/home',
  '/notifications',
};

/// 비로그인에서도 접근 허용 — **이 접두어**이면 본인 + 하위 경로 (`/wishlist/consider` 등).
const Set<String> _guestAllowPathPrefixes = {
  '/onboarding',
  '/wishlist',
  '/tutorial',
  '/feed',
};

bool _isAllowedPathForGuest(String location) {
  if (_guestAllowExactPaths.contains(location)) return true;
  for (final prefix in _guestAllowPathPrefixes) {
    if (location == prefix || location.startsWith('$prefix/')) return true;
  }
  return false;
}

/// GoRouter를 Riverpod Provider로 감싸 auth 상태 변화 시 자동 redirect를 지원합니다.
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _bottomTabPage(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            _bottomTabPage(state, const HomeScreen()),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        pageBuilder: (context, state) =>
            _bottomTabPage(state, const WishlistScreen()),
        routes: [
          GoRoute(
            path: 'consider',
            builder: (context, state) => const WishlistConsiderScreen(),
          ),
          GoRoute(
            path: 'add-fetch-failed',
            builder: (context, state) {
              return WishlistProductFetchFailedScreen(
                onBack: () => context.pop(),
                onManualInput: () {
                  context.pop();
                  ProviderScope.containerOf(context)
                      .read(wishlistViewModelProvider.notifier)
                      .openAddPanel();
                },
              );
            },
          ),
          GoRoute(
            path: 'reflect',
            builder: (context, state) => WishlistReflectScreen(
              itemId: state.uri.queryParameters['id'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/feed',
        pageBuilder: (context, state) =>
            _bottomTabPage(state, const FeedScreen()),
        routes: [
          GoRoute(
            path: 'write',
            builder: (context, state) => const FeedWriteScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) => FeedEditScreen(
              postId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => FeedDetailScreen(
              postId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/tutorial',
        builder: (context, state) {
          final restoreModal =
              state.uri.queryParameters['restoreModal'] == '1';
          return WishlistTutorialRouteScreen(
            restoreAddEntryModalOnExit: restoreModal,
          );
        },
      ),
      GoRoute(
        path: '/onboarding',
        redirect: (context, state) =>
            state.uri.path == '/onboarding' ? '/onboarding/nickname' : null,
        routes: [
          GoRoute(
            path: 'nickname',
            builder: (context, state) => const NicknameScreen(),
          ),
          GoRoute(
            path: 'budget',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: 'survey',
            builder: (context, state) => const SurveyScreen(),
          ),
          GoRoute(
            path: 'nugul-intro',
            builder: (context, state) => const NugulIntroScreen(),
          ),
        ],
      ),
    ],
  );
});

// auth 상태와 스플래시 최소 시간이 바뀔 때 GoRouter에 알림을 보내는 ChangeNotifier 어댑터
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<UserModel?>>(
      authProvider,
      (_, __) => notifyListeners(),
    );
    // 스플래시 최소 시간이 완료되면 redirect를 재평가
    _ref.listen<AsyncValue<void>>(
      _splashMinDurationProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState    = _ref.read(authProvider);
    final splashReady  = _ref.read(_splashMinDurationProvider);
    final location     = state.matchedLocation;

    // auth 로딩 중이거나 스플래시 최소 시간 미경과 → 스플래시 유지
    if (authState.isLoading || splashReady.isLoading) {
      return location == '/' ? null : '/';
    }

    final isLoggedIn = authState.hasValue && authState.value != null;
    final isAuthPage = location == '/login' || location == '/signup';

    // 비로그인 상태 + 스플래시 → 로그인으로
    if (!isLoggedIn && location == '/') return '/login';

    // 비로그인 + [_guestAllowExactPaths / _guestAllowPathPrefixes] 허용 목록이면 통과
    if (!isLoggedIn && _isAllowedPathForGuest(location)) return null;

    // 비로그인 상태 + 보호된 경로 → 로그인으로
    if (!isLoggedIn && !isAuthPage) return '/login';

    // 로그인 완료 + 스플래시 → 홈으로 (앱 재실행 시 자동 복귀)
    if (isLoggedIn && location == '/') return '/home';

    // 로그인 완료 + 로그인 페이지 → 닉네임 설정으로 (소셜 로그인 성공 직후)
    if (isLoggedIn && isAuthPage) {
      return '/onboarding/nickname';
    }

    return null;
  }
}