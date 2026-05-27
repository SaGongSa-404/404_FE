import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FeedEmptyView extends StatelessWidget {
  const FeedEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/nugul_nothing.png',
            width: (161 * scale).clamp(129.0, 193.0),
          ),
          SizedBox(height: (20 * scale).clamp(16.0, 24.0)),
          Text(
            '아직 게시글이 없어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: (18 * scale).clamp(14.0, 22.0),
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: (8 * scale).clamp(6.0, 10.0)),
          Text(
            '지금 고민 중인 위시를\n첫 게시글로 올려보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              fontSize: (16 * scale).clamp(13.0, 19.0),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
