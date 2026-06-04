import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/auth/views/login_screen.dart';
import 'package:fe_app/features/auth/views/signup_screen.dart';
import 'package:fe_app/features/feed/views/feed_detail_screen.dart';
import 'package:fe_app/features/feed/views/feed_edit_screen.dart';
import 'package:fe_app/features/feed/views/feed_screen.dart';
import 'package:fe_app/features/feed/views/feed_write_screen.dart';
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
            _bottomTabPage(state, const LoginScreen(), exitOnBack: true),
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
      GoRoute(
        path: '/my',
        pageBuilder: (context, state) =>
            _bottomTabPage(state, const MyPageScreen(), exitOnBack: true),
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
        path: '/feed',
        pageBuilder: (context, state) =>
            _bottomTabPage(state, const FeedScreen(), exitOnBack: true),
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

    if (authState.isLoading || splashReady.isLoading) {
      if (location == '/') return null;
      // OAuth 외부 브라우저 복귀 시 로그인 화면 유지 (iOS 스플래시 깜빡임·no route 방지)
      if (location == '/login' && authState.isLoading) return null;
      return '/';
    }

    final isLoggedIn = authState.hasValue && authState.value != null;
    final isAuthPage = location == '/login' || location == '/signup';

    if (!isLoggedIn && location == '/') {
      if (EnvConfig.isDevXUserIdAuth) return '/onboarding/terms';
      return '/login';
    }

    if (!isLoggedIn && _isAllowedPathForGuest(location)) return null;

    // 비로그인 상태 + 보호된 경로 → 로그인으로
    if (!isLoggedIn && !isAuthPage) return '/login';

    if (EnvConfig.isDevXUserIdAuth && isAuthPage) {
      final isCompleted =
          authState.value?.onboardingStatus == 'COMPLETED';
      return isCompleted ? '/home' : '/onboarding/terms';
    }

    if (isLoggedIn && (location == '/' || isAuthPage)) {
      final isCompleted =
          authState.value?.onboardingStatus == 'COMPLETED';
      return isCompleted ? '/home' : '/onboarding/terms';
    }

    return null;
  }
}
