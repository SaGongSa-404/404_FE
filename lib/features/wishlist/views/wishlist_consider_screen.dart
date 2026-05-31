import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:fe_app/features/wishlist/views/components/consider/consider_budget_card.dart';
import 'package:fe_app/features/wishlist/views/components/consider/consider_checklist.dart';
import 'package:fe_app/features/wishlist/views/components/consider/consider_insight_cards.dart';
import 'package:fe_app/features/wishlist/views/components/consider/consider_product_header.dart';
import 'package:fe_app/features/wishlist/views/components/consider/consider_result_card.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WishlistConsiderScreen extends ConsumerWidget {
  const WishlistConsiderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 56 * scale,
        leadingWidth: 72 * scale,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ref.read(considerViewModelProvider.notifier).reset();
            context.pop();
          },
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24 * scale, 18 * scale, 24 * scale, 40 * scale),
            child: Column(
              children: [
                const ConsiderProductHeader(),
                SizedBox(height: 12 * scale),
                const ConsiderBudgetCard(),
                SizedBox(height: 12 * scale),
                const ConsiderInsightCards(),
                SizedBox(height: 40 * scale),
                const ConsiderChecklist(),
                SizedBox(height: 40 * scale),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFC3C3C3),
                ),
                SizedBox(height: 26 * scale),
                const ConsiderResultCard(),
                SizedBox(height: 24 * scale),
                _BottomActionButtons(scale: scale),
                SizedBox(height: 40 * scale),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomActionButtons extends ConsumerWidget {
  const _BottomActionButtons({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(considerViewModelProvider);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!state.isAllAnswered) {
                _showAnswerRequiredToast(context);
                return;
              }

              final resultCase = ref
                  .read(considerViewModelProvider.notifier)
                  .recordDecision(PurchaseDecision.purchase);
              context.push('/wishlist/consider/result', extra: resultCase);
            },
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
            onTap: () {
              if (!state.isAllAnswered) {
                _showAnswerRequiredToast(context);
                return;
              }

              final resultCase = ref
                  .read(considerViewModelProvider.notifier)
                  .recordDecision(PurchaseDecision.refrain);
              context.push('/wishlist/consider/result', extra: resultCase);
            },
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

  void _showAnswerRequiredToast(BuildContext context) {
    showCapsuleToast(
      context,
      backgroundColor: AppColors.red_600,
      text: '1~4번 질문에 모두 답변해 주세요.',
    );
  }
}
