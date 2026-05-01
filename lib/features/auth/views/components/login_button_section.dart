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
        height: 129,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFDB82),
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Column(
      children: [
        _LoginButton(
          onPressed: onKakaoPressed,
          backgroundColor: const Color(0xFFFFDB82),
          icon: Image.asset(
            'assets/images/kakao_logo.png',
            width: 25,
            height: 23,
            fit: BoxFit.contain,
          ),
          label: '카카오로 시작하기',
        ),
        const SizedBox(height: 13),
        _LoginButton(
          onPressed: onGooglePressed,
          backgroundColor: Colors.white,
          icon: SvgPicture.asset(
            'assets/images/google_logo.svg',
            width: 25,
            height: 25,
          ),
          label: '구글로 시작하기',
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final Color backgroundColor;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(75);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 3,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555),
                    height: 1.548,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
