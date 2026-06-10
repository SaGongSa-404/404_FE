import 'package:flutter/material.dart';

import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';

/// 마이 탭 하위 화면 공통 셸 — 본문만 전환되고 하단 네비게이션은 고정됩니다.
class MyTabShell extends StatelessWidget {
  const MyTabShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
