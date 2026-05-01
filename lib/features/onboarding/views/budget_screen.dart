import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:fe_app/features/onboarding/views/components/onboarding_header.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_pill_text_field.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_primary_button.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_progress_indicator.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  static const _designWidth = 402.0;

  final _controller = TextEditingController();
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    final hasValue = _controller.text.trim().isNotEmpty;
    if (hasValue != _hasValue) setState(() => _hasValue = hasValue);
  }

  void _onNext() {
    FocusScope.of(context).unfocus();
    context.push('/onboarding/survey');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                (constraints.maxWidth * (24 / _designWidth)).clamp(20.0, 48.0);
            final innerWidth =
                constraints.maxWidth - (horizontalPadding * 2);
            final coinSize = (innerWidth * 0.32).clamp(96.0, 130.0);

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
                              currentStep: 2,
                              totalSteps: 6,
                              onBack: () => context.canPop()
                                  ? context.pop()
                                  : context.go('/'),
                            ),
                            const Spacer(flex: 118),
                            const OnboardingHeader(
                              title: '이번 달 나를 위한 소비,\n얼마까지 괜찮아요?',
                              subtitle: '매달 예산을 설정하고,\n합리적인 소비를 관리해보세요',
                              textAlign: TextAlign.left,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              titleFontSize: 25,
                              titleHeight: 1.36,
                            ),
                            const Spacer(flex: 135),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Image.asset(
                                'assets/images/nugul_coin.png',
                                width: coinSize,
                                height: coinSize * (92 / 113),
                                fit: BoxFit.contain,
                              ),
                            ),
                            OnboardingPillTextField(
                              controller: _controller,
                              hintText: '예) 500,000',
                              hintFontSize: 20,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                _BudgetFormatter(maxDigits: 9),
                              ],
                            ),
                            const SizedBox(height: 14),
                            OnboardingPrimaryButton(
                              label: '다음',
                              onPressed: _hasValue ? _onNext : null,
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
