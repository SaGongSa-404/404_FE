import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: const Text(
                  '⚠️ 이 화면은 스플래시 화면이지만'
                      '\n임시로 화면 이동 테스트 용도로 동작합니다.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '화면 목록',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildNavButton(context, '홈 화면', '/home'),
              _buildNavButton(context, '위시 목록 화면', '/wishlist'),
              _buildNavButton(context, '구매 숙려 화면', '/wishlist/consider'),
              _buildNavButton(context, '로그인 화면', '/login'),
              _buildNavButton(context, '회원가입 화면', '/signup'),
              _buildNavButton(context, '닉네임 설정 (온보딩)', '/onboarding/nickname'),
              _buildNavButton(context, '예산 설정 (온보딩)', '/onboarding/budget'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String label, String path) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () => context.push(path),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}