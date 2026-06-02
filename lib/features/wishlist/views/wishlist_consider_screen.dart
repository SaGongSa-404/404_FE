import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/wishlist/models/deliberation/deliberation_detail.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_category_ui.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:fe_app/features/wishlist/views/components/consider/consider_budget_card.dart';
import 'package:fe_app/features/wishlist/views/components/consider/consider_checklist.dart';
import 'package:fe_app/features/wishlist/views/components/consider/consider_insight_cards.dart';
import 'package:fe_app/features/wishlist/views/components/consider/consider_product_header.dart';
import 'package:fe_app/features/wishlist/views/components/consider/consider_result_card.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
import 'package:fe_app/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WishlistConsiderScreen extends ConsumerWidget {
  const WishlistConsiderScreen({
    super.key,
    required this.itemId,
  });

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);
    final state = ref.watch(considerViewModelProvider(itemId));

    ref.listen<ConsiderState>(considerViewModelProvider(itemId), (prev, next) {
      final loadMessage = next.errorMessage;
      if (loadMessage != null &&
          loadMessage.isNotEmpty &&
          prev?.errorMessage != loadMessage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          showCapsuleToast(
            context,
            backgroundColor: const Color(0xFFD46868),
            text: loadMessage,
          );
          context.pop();
        });
      }

      final submitMessage = next.submitErrorMessage;
      if (submitMessage != null &&
          submitMessage.isNotEmpty &&
          prev?.submitErrorMessage != submitMessage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          ref.read(considerViewModelProvider(itemId).notifier).clearSubmitError();
          showCapsuleToast(
            context,
            backgroundColor: const Color(0xFFD46868),
            text: submitMessage,
          );
        });
      }
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context, scale),
          body: _buildBody(context, scale, state),
        ),
        if (state.isSubmitting)
          ColoredBox(
            color: const Color(0x99000000),
            child: LoadingIndicator(message: '결정 저장 중...'),
          ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, double scale) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      toolbarHeight: 56 * scale,
      leadingWidth: 72 * scale,
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.pop(),
        child: Padding(
          padding: EdgeInsets.only(left: 16 * scale),
          child: Row(
            children: [
              Icon(
                Icons.arrow_back_ios_new,
                size: 16 * scale,
                color: AppColors.brown,
              ),
              SizedBox(width: 4 * scale),
              Text(
                '위시',
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w500,
                  color: AppColors.brown,
                ),
              ),
            ],
          ),
        ),
      ),
      title: Text(
        '너굴과 위시 고민',
        style: TextStyle(
          fontSize: 20 * scale,
          fontWeight: FontWeight.w600,
          color: AppColors.brown,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context, double scale, ConsiderState state) {
    if (state.isLoading) {
      return const LoadingIndicator(message: '불러오는 중...');
    }

    if (state.errorMessage != null) {
      return const SizedBox.shrink();
    }

    final detail = state.detail;
    if (detail == null) {
      return const LoadingIndicator(message: '불러오는 중...');
    }

    final categoryLabel = WishlistCategoryUi.toUiLabel(detail.item.category);
    final rawAdded =
        detail.budget.projectedSpentAmount - detail.budget.spentAmount;
    final addedAmount = rawAdded > 0 ? rawAdded : 0;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24 * scale, 18 * scale, 24 * scale, 40 * scale),
          child: Column(
            children: [
              ConsiderProductHeader(
                title: detail.item.title,
                price: detail.item.listedPrice,
                category: categoryLabel,
                imageUrl: detail.item.imageUrl,
              ),
              SizedBox(height: 12 * scale),
              ConsiderBudgetCard(
                totalBudget: detail.budget.monthlyBudgetAmount,
                currentSpent: detail.budget.spentAmount,
                addedAmount: addedAmount,
                budgetPercent: state.budgetPercent,
                statusLabel: deliberationBudgetStatusLabel(
                  detail.budget.projectedUsageRate,
                ),
              ),
              SizedBox(height: 12 * scale),
              ConsiderInsightCards(
                opportunityCostValue:
                    '${formatDeliberationPrice(detail.item.listedPrice)}원',
                opportunityCostDescription: detail.opportunityCostMessage,
                spendingHistoryValue:
                    '${formatDeliberationPrice(detail.similarCategorySpendAmount)}원',
                spendingHistoryDescription: _similarCategorySpendDescription(
                  categoryLabel,
                  detail.similarCategorySpendAmount,
                ),
              ),
              SizedBox(height: 40 * scale),
              ConsiderChecklist(itemId: itemId),
              SizedBox(height: 40 * scale),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFC3C3C3),
              ),
              SizedBox(height: 26 * scale),
              ConsiderResultCard(itemId: itemId),
              SizedBox(height: 24 * scale),
              _BottomActionButtons(scale: scale, itemId: itemId),
              SizedBox(height: 40 * scale),
            ],
          ),
        ),
      ),
    );
  }

  String _similarCategorySpendDescription(String categoryLabel, int amount) {
    if (amount <= 0) {
      return '지난 달 $categoryLabel\n구매 이력이 없어요';
    }
    return '지난 달 $categoryLabel\n카테고리 소비 금액';
  }
}

class _BottomActionButtons extends ConsumerWidget {
  const _BottomActionButtons({
    required this.scale,
    required this.itemId,
  });

  final double scale;
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(considerViewModelProvider(itemId));

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: state.isSubmitting
                ? null
                : () => _submit(
                      context,
                      ref,
                      PurchaseDecision.purchase,
                    ),
            child: Container(
              height: 61 * scale,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.skyBlue_100, width: 1),
                borderRadius: BorderRadius.circular(100 * scale),
              ),
              child: Center(
                child: Text(
                  '살게요',
                  style: TextStyle(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: GestureDetector(
            onTap: state.isSubmitting
                ? null
                : () => _submit(
                      context,
                      ref,
                      PurchaseDecision.refrain,
                    ),
            child: Container(
              height: 61 * scale,
              decoration: BoxDecoration(
                color: AppColors.skyBlue_100,
                borderRadius: BorderRadius.circular(100 * scale),
              ),
              child: Center(
                child: Text(
                  '참을게요',
                  style: TextStyle(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    PurchaseDecision decision,
  ) async {
    final state = ref.read(considerViewModelProvider(itemId));
    if (!state.isAllAnswered) {
      _showAnswerRequiredToast(context, state.totalQuestions);
      return;
    }

    final response = await ref
        .read(considerViewModelProvider(itemId).notifier)
        .submitDecision(decision);
    if (!context.mounted || response == null) return;

    context.push(
      '/wishlist/consider/$itemId/result',
      extra: response,
    );
  }

  void _showAnswerRequiredToast(BuildContext context, int questionCount) {
    showCapsuleToast(
      context,
      backgroundColor: AppColors.red_600,
      text: questionCount > 0
          ? '1~$questionCount번 질문에 모두 답변해 주세요.'
          : '질문에 모두 답변해 주세요.',
    );
  }
}
