import 'package:fe_app/features/auth/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/auth/views/signup_screen.dart';
import 'package:fe_app/features/home/views/home_screen.dart';
import 'package:fe_app/features/notification/views/notification_screen.dart';
import 'package:fe_app/features/onboarding/views/budget_screen.dart';
import 'package:fe_app/features/onboarding/views/nickname_screen.dart';
import 'package:fe_app/features/onboarding/views/nugul_intro_screen.dart';
import 'package:fe_app/features/onboarding/views/survey_screen.dart';
import 'package:fe_app/features/onboarding/views/wishlist_tutorial_screen.dart';
import 'package:fe_app/features/splash/views/splash_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_consider_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_screen.dart';
import 'package:fe_app/features/profile/views/my_page_screen.dart';
import 'package:fe_app/features/profile/views/edit_profile_screen.dart';
import 'package:fe_app/features/profile/views/consumption_management_screen.dart';
import 'package:fe_app/features/profile/views/my_posts_screen.dart';
import 'package:fe_app/features/profile/views/terms_policy_screen.dart';

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
        ],
      ),
      GoRoute(
        path: '/my',
        pageBuilder: (context, state) =>
            _bottomTabPage(state, const MyPageScreen()),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'consumption',
            builder: (context, state) => const ConsumptionManagementScreen(),
          ),
          GoRoute(
            path: 'posts',
            builder: (context, state) => const MyPostsScreen(),
          ),
          GoRoute(
            path: 'terms',
            builder: (context, state) => const TermsPolicyScreen(),
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
          GoRoute(
            path: 'wishlist-tutorial',
            builder: (context, state) => WishlistTutorialScreen(
              currentStep: 4,
              label: '위시템 담기 1',
              titleWhilePlaying: '구매하고 싶은 아이템의\n링크를 공유해주세요',
              titleAfterPlay: '위굴 아이콘을 누르면\n저장 완료!',
              videoAsset: 'assets/videos/wishlist_demo.mp4',
              buttonLabel: '다음',
              onComplete: () =>
                  context.push('/onboarding/wishlist-tutorial-2'),
            ),
          ),
          GoRoute(
            path: 'wishlist-tutorial-2',
            builder: (context, state) => WishlistTutorialScreen(
              currentStep: 5,
              label: '위시템 담기 2',
              titleWhilePlaying: '구매하고 싶은 아이템의\n링크를 복사해주세요',
              titleAfterPlay: '링크를 붙여넣으면\n저장 완료!',
              videoAsset: 'assets/videos/wishlist_demo_2.mp4',
              buttonLabel: '다음',
              onComplete: () => context.go('/onboarding/nugul-intro'),
            ),
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

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<UserModel?>>(
      authProvider,
      (_, __) => notifyListeners(),
    );
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

    if (authState.isLoading || splashReady.isLoading) {
      return location == '/' ? null : '/';
    }

    final isLoggedIn = authState.hasValue && authState.value != null;
    final isAuthPage = location == '/login' || location == '/signup';

    if (!isLoggedIn && location == '/') return '/login';

    final allowedPaths = [
      '/home',
      '/wishlist',
      '/wishlist/consider',
      '/notifications',
      '/onboarding',
      '/my'
    ];

    final isAllowed = allowedPaths.any((path) => location.startsWith(path));

    if (!isLoggedIn && isAllowed) return null;

    if (!isLoggedIn && !isAuthPage) return '/login';

    if (isLoggedIn && location == '/') return '/home';

    if (isLoggedIn && isAuthPage) {
      return '/onboarding/nickname';
    }

    return null;
  }
}
