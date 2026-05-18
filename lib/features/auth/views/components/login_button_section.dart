import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fe_app/core/theme/app_theme.dart';

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
            color: AppColors.kakao,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Column(
      children: [
        _LoginButton(
          onPressed: onKakaoPressed,
          backgroundColor: AppColors.kakao,
          pressedColor: AppColors.kakao_clicked,
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
          backgroundColor: AppColors.white,
          pressedColor: AppColors.grey_300,
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

class _LoginButton extends StatefulWidget {
  const _LoginButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.pressedColor,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color pressedColor;
  final Widget icon;
  final String label;

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(75);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _pressed ? widget.pressedColor : widget.backgroundColor,
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
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          borderRadius: borderRadius,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.icon,
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
