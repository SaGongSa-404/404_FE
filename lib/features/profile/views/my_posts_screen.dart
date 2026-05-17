import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  // 위시탭과 동일한 배경색 설정
  static const Color _backgroundColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      // 상단 바를 원래의 AppBar 스타일로 되돌림
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '나의 게시글',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 비어있는 상태 영역
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 위시탭에서 사용하는 이미지와 동일한 설정
                    Image.asset(
                      'assets/images/nugul_empty.png',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      '아직 작성한 게시글이 없어요!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      '커뮤니티에서 다른 너구리들과\n함께 소통하며 현명한 소비를 해봐요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}