import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fe_app/features/onboarding/validators/nickname_validator.dart';
import 'package:fe_app/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:fe_app/features/onboarding/views/components/nickname_input_field.dart';
import 'package:fe_app/features/onboarding/views/components/nugul_video.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_header.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_layout.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_primary_button.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_progress_indicator.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_spaced_scroll_view.dart';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/shared/widgets/app_exit_modal.dart';

class NicknameScreen extends ConsumerStatefulWidget {
  const NicknameScreen({super.key});

  @override
  ConsumerState<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends ConsumerState<NicknameScreen> {
  static const _designWidth = 412.0;

  final _controller = TextEditingController();
  NicknameValidationResult _result = const NicknameEmpty();

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
    setState(() {
      _result = NicknameValidator.validate(_controller.text);
    });
  }

  String? get _errorMessage => switch (_result) {
        NicknameInvalidWhitespace() => '공백을 제거해주세요',
        NicknameInvalidChars() => '한글, 영어, 숫자만 입력할 수 있어요',
        NicknameInvalidLength() => '2자 이상 8자 이내로 입력해주세요',
        _ => null,
      };

  void _onNext() {
    FocusScope.of(context).unfocus();
    ref.read(onboardingProvider.notifier).setNickname(_controller.text);
    context.push('/onboarding/budget');
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _result is NicknameValid;

    return AppExitBackHandler(
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / _designWidth;
            final horizontalPadding =
                (constraints.maxWidth * (24 / _designWidth)).clamp(20.0, 48.0);
            final innerWidth =
                constraints.maxWidth - (horizontalPadding * 2);
            final nugulSize = (innerWidth * 0.5).clamp(140.0, 200.0);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: OnboardingSpacedScrollView(
                    viewportHeight: constraints.maxHeight,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                            OnboardingLayout.topSpacer(),
                            OnboardingProgressIndicator(
                              currentStep: 1,
                              totalSteps: 4,
                              onBack: () => context.go('/login'),
                            ),
                            const Spacer(flex: 122),
                            OnboardingHeader(
                              title: '환영합니다!',
                              subtitle: '사용하실 닉네임을\n선택해주세요',
                              textAlign: TextAlign.left,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              titleFontSize: (30 * scale).clamp(22.0, 38.0),
                              subtitleFontSize: (18 * scale).clamp(14.0, 23.0),
                            ),
                            const Spacer(flex: 54),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                end: _errorMessage == null ? 40.0 : 0.0,
                              ),
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              builder: (context, value, child) =>
                                  Transform.translate(
                                offset: Offset(0, value),
                                child: child,
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: NugulVideo(size: nugulSize),
                              ),
                            ),
                            NicknameInputField(
                              controller: _controller,
                              errorMessage: _errorMessage,
                            ),
                            const SizedBox(height: 14),
                            OnboardingPrimaryButton(
                              label: '다음',
                              onPressed: isValid ? _onNext : null,
                              fontSize: (18 * scale).clamp(14.0, 23.0),
                            ),
                            const Spacer(flex: 135),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}
