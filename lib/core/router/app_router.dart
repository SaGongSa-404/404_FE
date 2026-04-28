import 'package:go_router/go_router.dart';
import 'package:fe_app/features/splash/views/splash_screen.dart';
import 'package:fe_app/features/auth/views/login_screen.dart';
import 'package:fe_app/features/auth/views/signup_screen.dart';
import 'package:fe_app/features/home/views/home_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_consider_screen.dart';
import 'package:fe_app/features/onboarding/views/nickname_screen.dart';
import 'package:fe_app/features/onboarding/views/budget_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
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
      redirect: (context, state) => '/onboarding/nickname', // /onboarding 단독 접근 시
      routes: [
        GoRoute(
          path: 'nickname',
          builder: (context, state) => const NicknameScreen(),
        ),
        GoRoute(
          path: 'budget',
          builder: (context, state) => const BudgetScreen(),
        ),
      ],
    ),
  ],
);