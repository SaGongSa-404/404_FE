import 'package:flutter/material.dart';

class EmptyWishlistView extends StatelessWidget {
  const EmptyWishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF7A7A7A), width: 2),
              ),
              child: const Text(
                '너굴',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444444),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: double.infinity,
              child: Text(
                '갖고 싶은 게 생겼나요?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(
              width: double.infinity,
              child: Text(
                '바로 사기 전에, 여기 담아두고\n진짜 원하는지 확인해봐요!',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF222222),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 160),
          ],
        ),
      ),
    );
  }
}
