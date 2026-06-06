import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fe_app/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:fe_app/features/onboarding/views/components/budget_input_field.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_header.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_primary_button.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_progress_indicator.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  static const _designWidth = 412.0;
  static const _maxDigits = 8;

  final _controller = TextEditingController();
  String _digits = '';

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
    final digits = _controller.text.replaceAll(',', '');
    if (digits != _digits) {
      setState(() => _digits = digits);
    }
  }

  String? get _errorMessage {
    if (_digits.isEmpty) return null;
    final amount = int.tryParse(_digits) ?? 0;
    if (amount < 1) return '1원 이상 입력해주세요';
    return null;
  }

  bool get _isValid {
    if (_digits.isEmpty) return false;
    final amount = int.tryParse(_digits) ?? 0;
    return amount >= 1 && _digits.length <= _maxDigits;
  }

  void _onNext() {
    FocusScope.of(context).unfocus();
    final amount = int.tryParse(_digits) ?? 0;
    ref.read(onboardingProvider.notifier).setMonthlyBudget(amount);
    context.push('/onboarding/survey');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / _designWidth;
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
                              totalSteps: 4,
                              onBack: () => context.pop(),
                            ),
                            const Spacer(flex: 118),
                            OnboardingHeader(
                              title: '이번 달 나를 위한 소비,\n얼마까지 괜찮아요?',
                              subtitle: '매달 예산을 설정하고,\n합리적인 소비를 관리해보세요',
                              textAlign: TextAlign.left,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              titleFontSize: (25 * scale).clamp(18.0, 32.0),
                              titleHeight: 1.36,
                              subtitleFontSize: (18 * scale).clamp(14.0, 23.0),
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
                            BudgetInputField(
                              controller: _controller,
                              errorMessage: _errorMessage,
                              fontSize: (18 * scale).clamp(14.0, 23.0),
                              hintFontSize: (20 * scale).clamp(15.0, 26.0),
                            ),
                            const SizedBox(height: 14),
                            OnboardingPrimaryButton(
                              label: '다음',
                              onPressed: _isValid ? _onNext : null,
                              fontSize: (18 * scale).clamp(14.0, 23.0),
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
