import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginButtonSection extends StatelessWidget {
  const LoginButtonSection({
    super.key,
    required this.onKakaoPressed,
    required this.onGooglePressed,
    this.isLoading = false,
  });

  final VoidCallback onKakaoPressed;
  final VoidCallback onGooglePressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 128,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFEE500),
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Column(
      children: [
        _KakaoButton(onPressed: onKakaoPressed),
        const SizedBox(height: 12),
        _GoogleButton(onPressed: onGooglePressed),
      ],
    );
  }
}

class _KakaoButton extends StatelessWidget {
  const _KakaoButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE500),
          foregroundColor: const Color(0xFF3C1E1E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(75),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                    'assets/images/kakao_logo.png',
                    width: 22,
                    height: 22,
                    color: const Color(0xFF3C1E1E),
                    colorBlendMode: BlendMode.srcIn,
                  ),
            const SizedBox(width: 10),
            const Text(
              '카카오로 시작하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3C1E1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF555555),
          side: const BorderSide(color: Color(0xFFDDDDDD)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(75),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/google_logo.svg', width: 22, height: 22),
            const SizedBox(width: 10),
            const Text(
              '구글로 시작하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
