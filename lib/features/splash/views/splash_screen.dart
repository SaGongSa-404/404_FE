import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/shared/widgets/nugul_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _slide;
  bool _logoFinished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slide = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _controller.forward().whenComplete(() {
      if (mounted) setState(() => _logoFinished = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authLoading = ref.watch(authProvider).isLoading;

    if (_logoFinished && authLoading) {
      return const NugulLoadingScreen();
    }

    final logoWidth = MediaQuery.of(context).size.width * 0.35;
    final logoHeight = logoWidth * (112 / 125);

    return Scaffold(
      backgroundColor: const Color(0xFFB0CFDF),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Opacity(
            opacity: _opacity.value,
            child: Transform.translate(
              offset: Offset(0, _slide.value * logoHeight * 0.5),
              child: child,
            ),
          ),
          child: SvgPicture.asset(
            'assets/images/wigul_logo.svg',
            width: logoWidth,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
