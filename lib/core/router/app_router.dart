import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/auth/views/login_screen.dart';
import 'package:fe_app/features/auth/views/signup_screen.dart';
import 'package:fe_app/features/feed/views/feed_detail_screen.dart';
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
import 'package:fe_app/features/splash/views/splash_screen.dart';
import 'package:fe_app/features/tutorial/views/wishlist_tutorial_route_screen.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:fe_app/features/wishlist/views/components/form/wishlist_product_fetch_failed_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_consider_result_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_consider_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_item_entry_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_reflect_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_screen.dart';
import 'package:fe_app/shared/widgets/app_exit_modal.dart';
import 'package:fe_app/shared/widgets/my_page_tab_shell.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final _splashMinDurationProvider = FutureProvider<void>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 4000));
});

NoTransitionPage<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: child,
  );
}

NoTransitionPage<void> _bottomTabPage(
  GoRouterState state,
  Widget child, {
  bool exitOnBack = false,
}) {
  return _noTransitionPage(
    state,
    exitOnBack ? AppExitBackHandler(child: child) : child,
  );
}

bool _isAuthPage(String location) =>
    location == '/login' || location == '/signup';

String _postSplashDestination(AsyncValue<UserModel?> authState) {
  if (EnvConfig.isDevXUserIdAuth) return '/onboarding/terms';
  final isCompleted = authState.value?.onboardingStatus == 'COMPLETED';
  return isCompleted ? '/home' : '/onboarding/terms';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
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
                  final extra = state.extra;
                  if (extra is! ConsiderResultRouteArgs) {
                    return WishlistConsiderScreen(itemId: itemId);
                  }
                  return WishlistConsiderResultScreen(
                    itemId: itemId,
                    response: extra.response,
                    caseType: extra.caseType,
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
      GoRoute(
        path: '/my',
        pageBuilder: (context, state) => _bottomTabPage(
          state,
          const MyPageTabShell(child: MyPageScreen()),
          exitOnBack: true,
        ),
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const MyPageTabShell(child: EditProfileScreen()),
            ),
          ),
          GoRoute(
            path: 'consumption',
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const MyPageTabShell(child: ConsumptionManagementScreen()),
            ),
          ),
          GoRoute(
            path: 'posts',
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const MyPageTabShell(child: MyPostsScreen()),
            ),
          ),
          GoRoute(
            path: 'terms',
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const MyPageTabShell(child: TermsPolicyScreen()),
            ),
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
          final restoreModal = state.uri.queryParameters['restoreModal'] == '1';
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

    // auth 확인 중: 스플래시·로그인·회원가입만 허용
    if (authState.isLoading) {
      if (location == '/' || _isAuthPage(location)) return null;
      return '/';
    }

    final isLoggedIn = authState.hasValue && authState.value != null;
    final isDevUser = EnvConfig.devUserId != null;

    // 로컬 dev user(X-User-Id): 스플래시 직후에만 온보딩 약관으로 보냄 (로그인 화면 복귀 허용)
    if (isDevUser) {
      if (location == '/' || _isAuthPage(location)) {
        return _postSplashDestination(authState);
      }
      return null;
    }

    // 비로그인: 로그인 화면만 허용 (온보딩·기타 페이지 차단)
    if (!isLoggedIn) {
      if (location == '/') return '/login';
      if (_isAuthPage(location)) return null;
      return '/login';
    }

    if (!EnvConfig.isDevXUserIdAuth &&
        authState.value?.onboardingStatus == 'COMPLETED' &&
        location.startsWith('/onboarding')) {
      return '/home';
    }

    if (location == '/' || _isAuthPage(location)) {
      return _postSplashDestination(authState);
    }

    return null;
  }
}
