import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

/// 마이페이지 및 하위 화면에서 바텀 네비게이션을 고정합니다.
class MyPageTabShell extends StatelessWidget {
  const MyPageTabShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
