import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FeedEmptyView extends StatelessWidget {
  const FeedEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/nugul_nothing.png',
            width: 161,
          ),
          const SizedBox(height: 20),
          const Text(
            '아직 게시글이 없어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '지금 고민 중인 위시를\n첫 게시글로 올려보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
