import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _handleKakaoLogin(BuildContext context) async {
    try {
      if (await isKakaoTalkInstalled()) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }

      if (context.mounted) {
        // go_router를 사용하여 닉네임 설정 화면으로 이동
        // context.go('/onboarding/nickname');

        // test용
        context.go('/onboarding/survey');
      }
    } catch (error) {
      debugPrint('카카오 로그인 실패: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                '위굴',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '현명한 소비 습관의 시작',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _handleKakaoLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE500),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('카카오로 시작하기', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}