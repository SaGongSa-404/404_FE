import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18 * scale),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '알림',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18 * scale,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
        children: [
          Text(
            '읽지 않은 알림',
            style: TextStyle(
              fontSize: 14 * scale,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16 * scale),
          _buildAlarmCard(context, '00님이 투표를 했어요', '2분 전', isNew: true),
          _buildAlarmCard(context, '구매 후 후회하고 있진 않나요?\n기록하러 가기', '2분 전', isNew: true),
          SizedBox(height: 30 * scale),
          Text(
            '최근 알림',
            style: TextStyle(
              fontSize: 14 * scale,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16 * scale),
          _buildAlarmCard(context, 'ㅁㅁ님이 댓글을 달았어요', '10분 전', isNew: false),
        ],
      ),
    );
  }

  Widget _buildAlarmCard(BuildContext context, String text, String time, {required bool isNew}) {
    final scale = responsiveScale(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 18 * scale),
      decoration: BoxDecoration(
        color: isNew ? const Color(0xFFFDF1C7) : Colors.white,
        borderRadius: BorderRadius.circular(50 * scale),
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
              style: TextStyle(
                fontSize: 15 * scale,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(width: 10 * scale),
          Text(
            time,
            style: TextStyle(fontSize: 12 * scale, color: Colors.grey),
          ),
          if (isNew) ...[
            SizedBox(width: 6 * scale),
            Icon(Icons.circle, size: 6 * scale, color: const Color(0xFFE58D8D)),
          ],
        ],
      ),
    );
  }
}
