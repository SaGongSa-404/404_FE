import 'package:fe_app/features/splash/views/splash_screen.dart';
import 'package:fe_app/features/wishlist/views/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fe_app/features/auth/views/login_screen.dart';
import 'package:fe_app/features/auth/views/signup_screen.dart';
import 'package:fe_app/features/home/views/home_screen.dart';
import 'package:fe_app/features/onboarding/views/nickname_screen.dart';
import 'package:fe_app/features/onboarding/views/budget_screen.dart';

final class App extends StatelessWidget {
  const App({super.key});

  static final GoRouter _router = GoRouter(
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
      ),
      GoRoute(
        path: '/onboarding/nickname',
        builder: (context, state) => const NicknameScreen(),
      ),
      GoRoute(
        path: '/onboarding/budget',
        builder: (context, state) => const BudgetScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WiGul',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard',
      ),
      routerConfig: _router,
    );
  }
}
