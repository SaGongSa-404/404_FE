import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/auth/views/login_screen.dart';
import 'package:fe_app/features/auth/views/signup_screen.dart';
import 'package:fe_app/features/feed/views/feed_detail_screen.dart';
import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/features/feed/views/feed_edit_screen.dart';
import 'package:fe_app/features/feed/views/feed_screen.dart';
import 'package:fe_app/features/feed/views/feed_write_screen.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:fe_app/features/onboarding/views/privacy_policy_screen.dart';
import 'package:fe_app/features/onboarding/views/service_terms_screen.dart';
import 'package:fe_app/features/onboarding/views/terms_screen.dart';
import 'package:fe_app/features/home/views/home_screen.dart';
import 'package:fe_app/features/notification/views/notification_screen.dart';
import 'package:fe_app/features/onboarding/views/budget_screen.dart';
import 'package:fe_app/features/onboarding/views/nickname_screen.dart';
import 'package:fe_app/features/onboarding/views/nugul_intro_screen.dart';
import 'package:fe_app/features/onboarding/views/survey_screen.dart';
import 'package:fe_app/features/profile/views/consumption_management_screen.dart';
import 'package:fe_app/features/profile/views/edit_profile_screen.dart';
import 'package:fe_app/features/profile/views/my_page_screen.dart';
import 'package:fe_app/features/profile/views/my_posts_screen.dart';
import 'package:fe_app/features/profile/views/terms_policy_screen.dart';
import 'package:fe_app/shared/widgets/my_tab_shell.dart';
import 'package:fe_app/features/splash/views/splash_screen.dart';
import 'package:fe_app/features/tutorial/views/wishlist_tutorial_route_screen.dart';
import 'package:fe_app/features/wishlist/models/decision/decision_create_response.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:fe_app/features/wishlist/views/components/form/wishlist_product_fetch_failed_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_consider_result_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_consider_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_item_entry_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_reflect_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_screen.dart';
import 'package:fe_app/shared/widgets/app_exit_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _splashMinDurationProvider = FutureProvider<void>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 4000));
});

NoTransitionPage<void> _bottomTabPage(
  GoRouterState state,
  Widget child, {
  bool exitOnBack = false,
}) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: exitOnBack ? AppExitBackHandler(child: child) : child,
  );
}

const Set<String> _guestAllowExactPaths = {
  '/home',
  '/notifications',
};

const Set<String> _guestAllowPathPrefixes = {
  '/onboarding',
  '/wishlist',
  '/tutorial',
  '/feed',
  '/my',
};

bool _isAllowedPathForGuest(String location) {
  if (_guestAllowExactPaths.contains(location)) return true;
  for (final prefix in _guestAllowPathPrefixes) {
    if (location == prefix || location.startsWith('$prefix/')) return true;
  }
  return false;
}

/// 스플래시(`/`) 또는 인증 화면 이후 첫 화면.
/// 로컬 `X-User-Id` 테스트는 COMPLETED 여부와 관계없이 온보딩 플로우를 탑니다.
String _postSplashDestination(AsyncValue<UserModel?> authState) {
  if (EnvConfig.isDevXUserIdAuth) return '/onboarding/terms';
  final isCompleted = authState.value?.onboardingStatus == 'COMPLETED';
  return isCompleted ? '/home' : '/onboarding/terms';
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
            _bottomTabPage(state, const HomeScreen(), exitOnBack: true),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        pageBuilder: (context, state) =>
            _bottomTabPage(state, const WishlistScreen(), exitOnBack: true),
        routes: [
          GoRoute(
            path: 'consider/:itemId',
            builder: (context, state) {
              final itemId = state.pathParameters['itemId']!;
              return WishlistConsiderScreen(itemId: itemId);
            },
            routes: [
              GoRoute(
                name: 'wishlist_consider_result',
                path: 'result',
                builder: (context, state) {
                  final itemId = state.pathParameters['itemId']!;
                  final response = state.extra as DecisionCreateResponse;
                  return WishlistConsiderResultScreen(
                    itemId: itemId,
                    response: response,
                  );
                },
              ),
            ],
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
          GoRoute(
            path: 'item',
            builder: (context, state) => WishlistItemEntryScreen(
              itemId: state.uri.queryParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => MyTabShell(child: child),
        routes: [
          GoRoute(
            path: '/my',
            pageBuilder: (context, state) => _bottomTabPage(
              state,
              const MyPageScreen(),
              exitOnBack: true,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'consumption',
                builder: (context, state) =>
                    const ConsumptionManagementScreen(),
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
        ],
      ),
      GoRoute(
        path: '/feed',
        pageBuilder: (context, state) =>
            _bottomTabPage(state, const FeedScreen(), exitOnBack: true),
        routes: [
          GoRoute(
            path: 'write',
            builder: (context, state) {
              final initialItem = state.extra is WishlistPlaceholder
                  ? state.extra! as WishlistPlaceholder
                  : null;
              return FeedWriteScreen(initialItem: initialItem);
            },
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
            state.uri.path == '/onboarding' ? '/onboarding/terms' : null,
        routes: [
          GoRoute(
            path: 'terms',
            builder: (context, state) => const TermsScreen(),
          ),
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
          GoRoute(
            path: 'service-terms',
            builder: (context, state) => const ServiceTermsScreen(),
          ),
          GoRoute(
            path: 'privacy-policy',
            builder: (context, state) => const PrivacyPolicyScreen(),
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
    final authState = _ref.read(authProvider);
    final splashReady = _ref.read(_splashMinDurationProvider);
    final location = state.matchedLocation;

    // 스플래시(/)는 auth·최소 노출 시간이 끝날 때까지 유지
    if (location == '/' && (authState.isLoading || splashReady.isLoading)) {
      return null;
    }

    // auth 확인 중: 로그인·회원가입 화면은 그대로 두고, 나머지만 스플래시로
    if (authState.isLoading) {
      if (location == '/login' || location == '/signup') return null;
      if (location != '/') return '/';
      return null;
    }

    final isLoggedIn = authState.hasValue && authState.value != null;
    final isAuthPage = location == '/login' || location == '/signup';
    final isDevUser = EnvConfig.devUserId != null;

    // 로컬 dev user(X-User-Id): 소셜 로그인 없이 온보딩 약관부터 진행
    if (isDevUser) {
      if (location == '/' || isAuthPage) {
        return _postSplashDestination(authState);
      }
      return null;
    }

    if (!isLoggedIn && location == '/') return '/onboarding/terms';

    if (!isLoggedIn && _isAllowedPathForGuest(location)) return null;

    // 비로그인 상태 + 보호된 경로 → 로그인으로
    if (!isLoggedIn && !isAuthPage) return '/login';

    if (isLoggedIn &&
        !EnvConfig.isDevXUserIdAuth &&
        authState.value?.onboardingStatus == 'COMPLETED' &&
        location.startsWith('/onboarding')) {
      return '/home';
    }

    if (isLoggedIn && (location == '/' || isAuthPage)) {
      return _postSplashDestination(authState);
    }

    return null;
  }
}
