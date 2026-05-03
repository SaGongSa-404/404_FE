import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fe_app/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_primary_button.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_progress_indicator.dart';
import 'package:fe_app/core/theme/app_theme.dart';

class SurveyScreen extends ConsumerStatefulWidget {
  const SurveyScreen({super.key});

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  static const _designWidth = 402.0;

  static const _options = <String>[
    '거의 없었어요 (월 1회 미만)',
    '가끔 있었어요 (월 1~3회)',
    '자주 있었어요 (월 4회 이상)',
  ];

  int? _selectedIndex;

  void _onSelect(int index) {
    setState(() => _selectedIndex = index);
    ref.read(onboardingProvider.notifier).selectSurveyOption(
          index,
          _options[index],
        );
  }

  void _onNext() {
    FocusScope.of(context).unfocus();
    context.push('/onboarding/wishlist-tutorial');
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedIndex != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                (constraints.maxWidth * (24 / _designWidth)).clamp(20.0, 48.0);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(flex: 30),
                            OnboardingProgressIndicator(
                              currentStep: 3,
                              totalSteps: 6,
                              onBack: () => context.canPop()
                                  ? context.pop()
                                  : context.go('/'),
                            ),
                            const Spacer(flex: 118),
                            const Text(
                              '최근 한 달 동안,\n물건을 사고 나서 후회한 적이\n얼마나 있었나요?',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.36,
                              ),
                            ),
                            const Spacer(flex: 77),
                            for (var i = 0; i < _options.length; i++) ...[
                              if (i > 0) const SizedBox(height: 10),
                              _SurveyOption(
                                text: _options[i],
                                selected: _selectedIndex == i,
                                onTap: () => _onSelect(i),
                              ),
                            ],
                            const Spacer(flex: 97),
                            OnboardingPrimaryButton(
                              label: '다음',
                              onPressed: hasSelection ? _onNext : null,
                            ),
                            const Spacer(flex: 135),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SurveyOption extends StatelessWidget {
  const _SurveyOption({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  static const _activeBgColor = AppColors.option_clicked;
  static const _activeBorderColor = AppColors.skyBlue;
  static const _textColor = AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(75);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? _activeBgColor : Colors.white,
        border: Border.all(
          width: 2,
          color: selected ? _activeBorderColor : Colors.transparent,
        ),
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: SizedBox(
            height: 58,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                    height: 1.548,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
