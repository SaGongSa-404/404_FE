import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/auth/views/components/login_button_section.dart';
import 'package:fe_app/shared/widgets/app_exit_modal.dart';

/// 로고 연속 탭 횟수 — 심사용 reviewer-token 발급 진입점
const int _reviewerLogoTapCount = 5;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  int _logoTapCount = 0;
  Timer? _logoTapResetTimer;

  @override
  void dispose() {
    _logoTapResetTimer?.cancel();
    super.dispose();
  }

  void _onLogoTap() {
    if (ref.read(authProvider).isLoading) return;

    _logoTapResetTimer?.cancel();
    _logoTapResetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _logoTapCount = 0);
    });

    final nextCount = _logoTapCount + 1;
    if (nextCount >= _reviewerLogoTapCount) {
      _logoTapResetTimer?.cancel();
      setState(() => _logoTapCount = 0);
      unawaited(ref.read(authProvider.notifier).signInWithReviewerToken());
      return;
    }
    setState(() => _logoTapCount = nextCount);
  }

  Future<void> _onOAuthPressed(
    BuildContext context,
    WidgetRef ref,
    String provider,
  ) async {
    final launched =
        await ref.read(authProvider.notifier).launchOAuthSignIn(provider);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('브라우저를 열 수 없어요. 잠시 후 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserModel?>>(authProvider, (previous, next) {
      if (next.hasError && previous?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    });

    final isLoading = ref.watch(authProvider).isLoading;

    return AppExitBackHandler(
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const designWidth = 402.0;
            final horizontalPadding =
                (constraints.maxWidth * (24 / designWidth)).clamp(20.0, 48.0);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      const Spacer(flex: 266),
                      GestureDetector(
                        onTap: _onLogoTap,
                        behavior: HitTestBehavior.opaque,
                        child: SvgPicture.asset(
                          'assets/images/wigul_logo.svg',
                          width: 125,
                          height: 112,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '충동구매는 잠시 멈추고,\n더 현명한 소비를 시작해볼까요?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.34,
                        ),
                      ),
                      const Spacer(flex: 171),
                      LoginButtonSection(
                        onKakaoPressed: () =>
                            _onOAuthPressed(context, ref, 'kakao'),
                        onGooglePressed: () =>
                            _onOAuthPressed(context, ref, 'google'),
                        isLoading: isLoading,
                      ),
                      const Spacer(flex: 134),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}
