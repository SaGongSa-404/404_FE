import 'package:flutter/material.dart';

class AlarmPanel extends StatelessWidget {
  const AlarmPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFB8D4F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue, width: 1.5),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: onClose,
                          ),
                          const Text(
                            '알림',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const AlarmCard(
                        text: '00님이 투표를 했어요',
                        isRead: false,
                      ),
                      const SizedBox(height: 12),
                      const AlarmCard(
                        text: '구매 후 후회하고 있진 않나요?\n기록하러 가기 ->',
                        isRead: false,
                      ),
                      const SizedBox(height: 12),
                      const AlarmCard(
                        text: 'ㅁㅁ님이 댓글을 달았어요',
                        isRead: true,
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
  });

  final String text;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(12),
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
                fontSize: 14,
                color: isRead ? Colors.grey.shade600 : Colors.black,
              ),
            ),
          ),
          if (!isRead)
            Container(
              width: 10,
              height: 10,
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
