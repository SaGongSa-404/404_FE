import 'package:flutter/material.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    this.trailing,
  }) : assert(currentStep >= 1 && currentStep <= totalSteps);

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final Widget? trailing;

  static const _activeColor = Color(0xFFC1DBE8);
  static const _inactiveColor = Color(0xFFD2D2D2);
  static const _activeWidth = 22.0;
  static const _inactiveWidth = 10.0;
  static const _dotHeight = 7.0;
  static const _dotGap = 9.0;
  static const _slotSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _slotSize,
      child: Row(
        children: [
          SizedBox(
            width: _slotSize,
            height: _slotSize,
            child: onBack == null
                ? null
                : IconButton(
                    onPressed: onBack,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 18,
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF555555),
                    ),
                  ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalSteps, (index) {
                final isActive = index == currentStep - 1;
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : _dotGap),
                  child: Container(
                    width: isActive ? _activeWidth : _inactiveWidth,
                    height: _dotHeight,
                    decoration: BoxDecoration(
                      color: isActive ? _activeColor : _inactiveColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            width: _slotSize,
            height: _slotSize,
            child: trailing,
          ),
        ],
      ),
    );
  }
}
