import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fe_app/features/onboarding/views/components/onboarding_pill_text_field.dart';

class BudgetInputField extends StatelessWidget {
  const BudgetInputField({
    super.key,
    required this.controller,
    this.errorMessage,
    this.focusNode,
    this.fontSize = 18,
    this.hintFontSize = 20,
  });

  final TextEditingController controller;
  final String? errorMessage;
  final FocusNode? focusNode;
  final double fontSize;
  final double hintFontSize;

  static const _errorColor = Color(0xFFB26D6D);
  static const _errorSlotHeight = 40.0;
  static const _maxDigits = 8;

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
                      horizontal: 16,
                      vertical: 10,
                    ),
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
          hintText: '예) 500,000',
          fontSize: fontSize,
          hintFontSize: hintFontSize,
          keyboardType: TextInputType.number,
          suffix: '원',
          hasError: hasError,
          inputFormatters: [
            _BudgetFormatter(maxDigits: _maxDigits),
          ],
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

class _BudgetFormatter extends TextInputFormatter {
  _BudgetFormatter({required this.maxDigits});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final formatted = int.parse(digits).toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]},',
        );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
