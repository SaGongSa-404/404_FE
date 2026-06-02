import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConsiderChecklist extends ConsumerWidget {
  const ConsiderChecklist({
    super.key,
    required this.itemId,
  });

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);
    final state = ref.watch(considerViewModelProvider(itemId));
    final viewModel = ref.read(considerViewModelProvider(itemId).notifier);
    final questions = state.detail?.questions ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(questions.length, (index) {
          final question = questions[index];
          final currentAnswer = state.answers[index];

          return Padding(
            padding: EdgeInsets.only(bottom: 30 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: TextStyle(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 4 * scale),
                    Expanded(
                      child: Text(
                        question.text,
                        style: TextStyle(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),
                Row(
                  children: [
                    _SurveyAnswerButton(
                      label: 'Yes',
                      isSelected: currentAnswer == true,
                      scale: scale,
                      onTap: () => viewModel.setAnswer(index, true),
                    ),
                    SizedBox(width: 12 * scale),
                    _SurveyAnswerButton(
                      label: 'No',
                      isSelected: currentAnswer == false,
                      scale: scale,
                      onTap: () => viewModel.setAnswer(index, false),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        if (state.shouldShowWarning) _WarningBanner(scale: scale),
      ],
    );
  }
}

class _SurveyAnswerButton extends StatelessWidget {
  const _SurveyAnswerButton({
    required this.label,
    required this.isSelected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final double scale;
  final VoidCallback onTap;

  static const double _buttonHeight = 48;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: _buttonHeight * scale,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.skyBlue_000_clicked : AppColors.white,
            borderRadius: BorderRadius.circular(_buttonHeight * scale / 2),
            border: Border.all(
              color: isSelected ? AppColors.skyBlue_100 : Color(0xFFE2E2E2),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 22 * scale, vertical: 19 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(22 * scale),
        border: Border.all(color: AppColors.red_100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                size: 18 * scale,
                color: AppColors.red_600,
              ),
              SizedBox(width: 6 * scale),
              Text(
                '잠깐요!',
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.red_600,
                  height: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 17 * scale),
          Text(
            '답변을 보니 지금 이 구매,\n충동적일 수 있어요.',
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w400,
              color: Color(0xFF333333),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
