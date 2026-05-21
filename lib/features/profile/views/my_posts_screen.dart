import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  static const Color _backgroundColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18 * scale),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '나의 게시글',
          style: TextStyle(
            fontSize: 18 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/nugul_empty.png',
                      width: 150 * scale,
                      height: 150 * scale,
                    ),
                    SizedBox(height: 24 * scale),
                    Text(
                      '아직 작성한 게시글이 없어요!',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    Text(
                      '커뮤니티에서 다른 너구리들과\n함께 소통하며 현명한 소비를 해봐요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 80 * scale),
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
