import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fe_app/features/auth/views/login_screen.dart';
import 'package:fe_app/features/home/views/home_screen.dart';
import 'package:fe_app/features/onboarding/views/survey_screen.dart';

final class App extends StatelessWidget {
  const App({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // GoRoute(
      //   path: '/onboarding/nickname',
      //   builder: (context, state) => const NicknameScreen(),
      // ),
      GoRoute(
        path: '/onboarding/survey',
        builder: (context, state) => const SurveyScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WiGul',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      routerConfig: _router,
    );
  }
}
