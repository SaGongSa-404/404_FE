import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/auth/views/components/login_button_section.dart';
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  static const _redirectUri = 'sagongsa404://auth/callback';

  Future<void> _launchOAuth(BuildContext context, String provider) async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final url = Uri.parse(
      '$baseUrl${ApiEndpoints.oauthAuthorization(provider, _redirectUri)}',
    );

    try {
      if (!await canLaunchUrl(url)) throw Exception('Cannot launch $url');
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('브라우저를 열 수 없어요. 잠시 후 다시 시도해주세요.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show a SnackBar when /api/auth/me fails after the deep link arrives.
    ref.listen<AsyncValue<UserModel?>>(authProvider, (previous, next) {
      if (next.hasError && previous?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
          ),
        );
      }
    });

    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
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
                      SvgPicture.asset(
                        'assets/images/wigul_logo.svg',
                        width: 125,
                        height: 112,
                        fit: BoxFit.contain,
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
                        onKakaoPressed: () => _launchOAuth(context, 'kakao'),
                        onGooglePressed: () => _launchOAuth(context, 'google'),
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
    );
  }
}
