import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/auth/views/login_screen.dart';
import 'package:fe_app/features/auth/views/signup_screen.dart';
import 'package:fe_app/features/home/views/home_screen.dart';
import 'package:fe_app/features/onboarding/views/budget_screen.dart';
import 'package:fe_app/features/onboarding/views/nickname_screen.dart';
import 'package:fe_app/features/onboarding/views/survey_screen.dart';
import 'package:fe_app/features/splash/views/splash_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_consider_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_screen.dart';

// 스플래시 최소 표시 시간: 1sec로 설정함
final _splashMinDurationProvider = FutureProvider<void>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 1000));
});

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
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistScreen(),
        routes: [
          GoRoute(
            path: 'consider',
            builder: (context, state) => const WishlistConsiderScreen(),
          ),
        ],
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

    // ui test용: 비로그인 상태에서도 onboarding 및 home 접근 허용
    // ui test: 백엔드 연동 시 아래 줄 제거하면 비로그인 /home 접근이 막힘
    if (!isLoggedIn && (location.startsWith('/onboarding') || location == '/home')) return null;

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