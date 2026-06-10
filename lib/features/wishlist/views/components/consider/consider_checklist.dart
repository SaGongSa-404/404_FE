import 'dart:async';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConsiderChecklist extends ConsumerStatefulWidget {
  const ConsiderChecklist({
    super.key,
    required this.itemId,
  });

  final String itemId;

  @override
  ConsumerState<ConsiderChecklist> createState() => _ConsiderChecklistState();
}

class _ConsiderChecklistState extends ConsumerState<ConsiderChecklist>
    with SingleTickerProviderStateMixin {
  final GlobalKey _warningKey = GlobalKey();
  late final AnimationController _shakeController;
  late final Animation<double> _shakeDx;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeDx = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -7), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -7, end: 7), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 7, end: -5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5, end: 5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5, end: -3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  bool _shouldShowWarning(ConsiderState state) =>
      state.isAllAnswered && state.shouldShowWarning;

  Future<void> _presentWarningCard() async {
    if (!mounted) return;

    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

    if (_warningKey.currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_presentWarningCard());
      });
      return;
    }

    await _scrollToWarningIfNeeded();
    if (!mounted) return;
    await _shakeController.forward(from: 0);
  }

  Future<void> _scrollToWarningIfNeeded() async {
    final targetContext = _warningKey.currentContext;
    if (targetContext == null) return;

    final renderBox = targetContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final scale = responsiveScale(context);
    final mediaQuery = MediaQuery.of(context);
    final viewportHeight = mediaQuery.size.height;
    final topInset = mediaQuery.padding.top + 56 * scale;
    final bottomInset = mediaQuery.padding.bottom + 24 * scale;
    final visibleBottom = viewportHeight - bottomInset;

    final cardTop = renderBox.localToGlobal(Offset.zero).dy;
    final cardBottom = cardTop + renderBox.size.height;
    final isFullyVisible = cardTop >= topInset && cardBottom <= visibleBottom;

    if (isFullyVisible) return;

    await Scrollable.ensureVisible(
      targetContext,
      alignment: 1.0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final state = ref.watch(considerViewModelProvider(widget.itemId));
    final viewModel = ref.read(considerViewModelProvider(widget.itemId).notifier);
    final questions = state.detail?.questions ?? const [];
    final showWarning = _shouldShowWarning(state);

    ref.listen<ConsiderState>(considerViewModelProvider(widget.itemId), (prev, next) {
      final wasShowing = prev != null && _shouldShowWarning(prev);
      final nowShowing = _shouldShowWarning(next);
      if (nowShowing && !wasShowing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _presentWarningCard();
        });
      }
    });

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
        if (showWarning)
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeDx.value * scale, 0),
                child: child,
              );
            },
            child: _WarningBanner(
              key: _warningKey,
              scale: scale,
            ),
          ),
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
  const _WarningBanner({super.key, required this.scale});

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
