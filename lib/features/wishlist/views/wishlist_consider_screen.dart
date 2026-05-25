import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:fe_app/features/wishlist/views/components/consider_budget_card.dart';
import 'package:fe_app/features/wishlist/views/components/consider_product_header.dart';
import 'package:fe_app/features/wishlist/views/components/consider_result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WishlistConsiderScreen extends ConsumerWidget {
  const WishlistConsiderScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(considerViewModelProvider(itemId));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: () {
            ref.read(considerViewModelProvider(itemId).notifier).resetAnswers();
            context.pop();
          },
        ),
        title: Text(
          '살까 말까',
          style: AppTextStyles.heading.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ConsiderState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.skyBlue_300),
      );
    }

    if (state.loadError != null) {
      return _LoadErrorView(
        message: state.loadError!,
        onRetry: () =>
            ref.read(considerViewModelProvider(itemId).notifier).load(),
        onBack: () => context.pop(),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          ConsiderProductHeader(itemId: itemId),
          const Divider(
            thickness: 1,
            color: AppColors.grey,
            indent: 24,
            endIndent: 24,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConsiderBudgetCard(itemId: itemId),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConsiderChecklistBody(itemId: itemId),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConsiderResultCard(itemId: itemId),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: _BottomActionButtons(itemId: itemId),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    child: const Text('돌아가기'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.skyBlue_100,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 0,
                    ),
                    child: const Text('다시 시도'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionButtons extends ConsumerWidget {
  const _BottomActionButtons({required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(considerViewModelProvider(itemId));
    final questionCount = state.totalQuestions;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!state.isAllAnswered) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('1~$questionCount번 질문에 모두 답변해 주세요.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                return;
              }

              final resultCase = ref
                  .read(considerViewModelProvider(itemId).notifier)
                  .recordDecision(PurchaseDecision.refrain);
              context.push(
                '/wishlist/consider/result',
                extra: ConsiderRouteResult(
                  caseType: resultCase,
                  itemId: itemId,
                ),
              );
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.grey, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '참을게요',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!state.isAllAnswered) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('1~$questionCount번 질문에 모두 답변해 주세요.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                return;
              }

              final resultCase = ref
                  .read(considerViewModelProvider(itemId).notifier)
                  .recordDecision(PurchaseDecision.purchase);
              context.push(
                '/wishlist/consider/result',
                extra: ConsiderRouteResult(
                  caseType: resultCase,
                  itemId: itemId,
                ),
              );
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.skyBlue_000_clicked,
                border: Border.all(color: AppColors.skyBlue_300, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '살게요',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 16,
                    color: AppColors.skyBlue_300,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ConsiderChecklistBody extends ConsumerWidget {
  const ConsiderChecklistBody({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(considerViewModelProvider(itemId));
    final viewModel = ref.read(considerViewModelProvider(itemId).notifier);
    final questions = state.questions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(questions.length, (index) {
          final question = questions[index];
          final currentAnswer = state.answers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${question.text}',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildAnswerButton(
                      viewModel,
                      index,
                      'Yes',
                      true,
                      currentAnswer == true,
                    ),
                    const SizedBox(width: 12),
                    _buildAnswerButton(
                      viewModel,
                      index,
                      'No',
                      false,
                      currentAnswer == false,
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        if (state.shouldShowWarning) _buildWarningBanner(),
      ],
    );
  }

  Widget _buildAnswerButton(
    ConsiderViewModel vm,
    int index,
    String label,
    bool value,
    bool isSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => vm.setAnswer(index, value),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.grey : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.textPrimary : AppColors.grey,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.red_100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚨', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                '잠깐요!',
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.red_400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '답변을 보니 지금 이 구매,\n충동적일 수 있어요.',
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
