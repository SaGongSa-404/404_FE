import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fe_app/core/theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          // 공용 컴포넌트나 스타일이 있다면 적용, 여기서는 사진의 < 모양 반영
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '알림',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          const Text(
            '읽지 않은 알림',
            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          // 읽지 않은 알림: 노란색 배경 (디자인 참고)
          _buildAlarmCard('00님이 투표를 했어요', '2분 전', isNew: true),
          _buildAlarmCard('구매 후 후회하고 있진 않나요?\n기록하러 가기', '2분 전', isNew: true),

          const SizedBox(height: 30),
          const Text(
            '최근 알림',
            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          // 최근 알림: 흰색 배경 + 테두리
          _buildAlarmCard('ㅁㅁ님이 댓글을 달았어요', '10분 전', isNew: false),
        ],
      ),
    );
  }

  Widget _buildAlarmCard(String text, String time, {required bool isNew}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        // 읽지 않은 알림은 노란색(AppColors.kakao 계열), 읽은 알림은 흰색
        color: isNew ? const Color(0xFFFDF1C7) : Colors.white,
        borderRadius: BorderRadius.circular(50), // 완전한 타원형(Pill shape)
        border: Border.all(
          color: isNew ? Colors.transparent : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (isNew) ...[
            const SizedBox(width: 6),
            const Icon(Icons.circle, size: 6, color: Color(0xFFE58D8D)), // 빨간 점
          ]
        ],
      ),
    );
  }
}