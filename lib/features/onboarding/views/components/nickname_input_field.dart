import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fe_app/features/onboarding/views/components/onboarding_pill_text_field.dart';

class NicknameInputField extends StatelessWidget {
  const NicknameInputField({
    super.key,
    required this.controller,
    this.errorMessage,
    this.focusNode,
    this.maxLength = 8,
  });

  final TextEditingController controller;
  final String? errorMessage;
  final FocusNode? focusNode;
  final int maxLength;

  static const _errorColor = Color(0xFFB26D6D);

  // 13(font) * 1.548(line-height) + 20(vertical padding) ≈ 40
  static const _errorSlotHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _errorSlotHeight,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: hasError
                ? Padding(
                    key: ValueKey(errorMessage),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _errorColor,
                        height: 1.548,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        OnboardingPillTextField(
          controller: controller,
          focusNode: focusNode,
          hintText: '닉네임을 입력해주세요',
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxLength),
          ],
          hasError: hasError,
          trailing: hasError
              ? SvgPicture.asset(
                  'assets/images/error.svg',
                  width: 24,
                  height: 24,
                )
              : null,
        ),
      ],
    );
  }
}
