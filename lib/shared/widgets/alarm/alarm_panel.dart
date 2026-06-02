import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class AlarmPanel extends StatelessWidget {
  const AlarmPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: onClose,
          child: Container(
            color: Colors.black.withOpacity(0.05),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(12 * scale),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFB8D4F0),
                borderRadius: BorderRadius.circular(16 * scale),
                border: Border.all(color: Colors.blue, width: 1.5),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close, size: 24 * scale),
                            onPressed: onClose,
                          ),
                          Text(
                            '알림',
                            style: TextStyle(
                              fontSize: 20 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 48 * scale),
                        ],
                      ),
                      SizedBox(height: 16 * scale),
                      AlarmCard(
                        text: '00님이 투표를 했어요',
                        isRead: false,
                        scale: scale,
                      ),
                      SizedBox(height: 12 * scale),
                      AlarmCard(
                        text: '구매 후 후회하고 있진 않나요?\n기록하러 가기 ->',
                        isRead: false,
                        scale: scale,
                      ),
                      SizedBox(height: 12 * scale),
                      AlarmCard(
                        text: 'ㅁㅁ님이 댓글을 달았어요',
                        isRead: true,
                        scale: scale,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AlarmCard extends StatelessWidget {
  const AlarmCard({
    super.key,
    required this.text,
    required this.isRead,
    required this.scale,
  });

  final String text;
  final bool isRead;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: isRead ? Colors.grey.shade300 : const Color(0xFF7B52AB),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14 * scale,
                color: isRead ? Colors.grey.shade600 : Colors.black,
              ),
            ),
          ),
          if (!isRead)
            Container(
              width: 10 * scale,
              height: 10 * scale,
              decoration: const BoxDecoration(
                color: Color(0xFF7B52AB),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
