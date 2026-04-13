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
    initialLocation: '/onboarding/nickname', // 테스트를 위해 온보딩 시작점으로 설정
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
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
        useMaterial3: true,
        fontFamily: 'Pretendard', // 필요 시 폰트 설정
      ),
      routerConfig: _router,
    );
  }
}
