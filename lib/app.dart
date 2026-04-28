import 'package:flutter/material.dart';
import 'package:fe_app/core/router/app_router.dart';

final class App extends StatelessWidget {
  const App({super.key});
  
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
      routerConfig: appRouter
    );
  }
}