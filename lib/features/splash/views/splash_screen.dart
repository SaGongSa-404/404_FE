import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Navigation is handled entirely by GoRouter redirect in app_router.dart.
// This widget simply shows the logo while auth state is being resolved.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC1DBE8),
      body: Center(
        child: SvgPicture.asset(
          'assets/images/wigul_logo.svg',
          width: MediaQuery.of(context).size.width * 0.35,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
