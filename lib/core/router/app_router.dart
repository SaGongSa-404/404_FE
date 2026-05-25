import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/auth/views/login_screen.dart';
import 'package:fe_app/features/auth/views/signup_screen.dart';
import 'package:fe_app/features/feed/views/feed_detail_screen.dart';
import 'package:fe_app/features/feed/views/feed_edit_screen.dart';
import 'package:fe_app/features/feed/views/feed_screen.dart';
import 'package:fe_app/features/feed/views/feed_write_screen.dart';
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
import 'package:fe_app/features/wishlist/views/wishlist_reflect_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _splashMinDurationProvider = FutureProvider<void>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 4000));
});

NoTransitionPage<void> _bottomTabPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: child,
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
            _bottomTabPage(state, const WishlistScreen()),
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
            builder: (context, state) {
              final itemId = state.uri.queryParameters['id'];
              if (itemId == null || itemId.isEmpty) {
                return const WishlistScreen();
              }
              return WishlistConsiderScreen(itemId: itemId);
            },
            routes: [
              GoRoute(
                name: 'wishlist_consider_result',
                path: 'result',
                builder: (context, state) {
                  final extra = state.extra;
                  if (extra is ConsiderRouteResult) {
                    return WishlistConsiderResultScreen(
                      caseType: extra.caseType,
                      itemId: extra.itemId,
                    );
                  }
                  final legacy = extra as ConsiderCaseType?;
                  return WishlistConsiderResultScreen(
                    caseType: legacy ?? ConsiderCaseType.caseC,
                    itemId: '',
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
      return location == '/' ? null : '/';
    }

    final isLoggedIn = authState.hasValue && authState.value != null;
    final isAuthPage = location == '/login' || location == '/signup';

    if (!isLoggedIn && location == '/') return '/login';

    if (!isLoggedIn && _isAllowedPathForGuest(location)) return null;

    if (!isLoggedIn && !isAuthPage) return '/login';

    if (isLoggedIn && location == '/') return '/home';

    if (isLoggedIn && isAuthPage) {
      return '/onboarding/nickname';
    }

    return null;
  }
}
