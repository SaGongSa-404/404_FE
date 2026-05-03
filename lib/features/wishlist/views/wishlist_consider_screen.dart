import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fe_app/features/wishlist/views/components/consider_product_header.dart';
import 'package:fe_app/features/wishlist/views/components/consider_budget_card.dart';
import 'package:fe_app/features/wishlist/views/components/consider_checklist.dart';
import 'package:fe_app/features/wishlist/views/components/consider_result_card.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:fe_app/core/theme/app_theme.dart';

class WishlistConsiderScreen extends ConsumerWidget {
  const WishlistConsiderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(considerViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () {
            ref.read(considerViewModelProvider.notifier).reset();
            context.pop();
          },
        ),
        title: const Text(
          '살까 말까',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const ConsiderProductHeader(),
            const Divider(thickness: 1, color: Color(0xFFF2F2F2), indent: 24, endIndent: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConsiderBudgetCard(),
            ),
            const SizedBox(height: 20),
            // 체크리스트 영역 (ConsiderChecklist 내부의 Column만 가져와서 배치하거나 그대로 사용)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ConsiderChecklistBody(),
            ),
            const SizedBox(height: 32),
            // 결과 카드
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ConsiderResultCard(),
            ),
            const SizedBox(height: 40),
            // 하단 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(considerViewModelProvider.notifier).reset();
                        context.pop();
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            '참을게요',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(considerViewModelProvider.notifier).reset();
                        context.pop();
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F3F9),
                          border: Border.all(color: AppColors.skyBlue, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            '살게요',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.skyBlue),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ConsiderChecklist의 내용을 자연스러운 스크롤 흐름으로 배치하기 위한 서브 위젯
class ConsiderChecklistBody extends ConsumerWidget {
  const ConsiderChecklistBody({super.key});

  static const List<String> _questions = [
    '1. 이미 집에 이것과 비슷하게 대체할 수 있는 물건이 있나요?',
    '2. \'세일 중\'이라서, 혹은 \'마지막 수량\'이라서 조급함을 느끼고 있지는 않은가요?',
    '3. 이미 집에 이것과 비슷하게 대체할 수 있는 물건이 있나요?',
    '4. 지금 내 기분이 우울하거나, 피곤하거나, 혹은 너무 들떠있어서 사고 싶은 건 아닌가요?',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(considerViewModelProvider);
    final viewModel = ref.read(considerViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_questions.length, (index) {
          final question = _questions[index];
          final currentAnswer = state.answers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildAnswerButton(viewModel, index, 'Yes', true, currentAnswer == true),
                    const SizedBox(width: 12),
                    _buildAnswerButton(viewModel, index, 'No', false, currentAnswer == false),
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

  Widget _buildAnswerButton(ConsiderViewModel vm, int index, String label, bool value, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => vm.setAnswer(index, value),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF2F2F2) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF555555) : const Color(0xFFF2F2F2),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF555555) : Colors.grey,
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
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('⚠️', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('잠깐요!',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE54327))),
            ],
          ),
          SizedBox(height: 8),
          Text('답변을 보니 지금 이 구매,\n충동적일 수 있어요.',
              style: TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.4)),
        ],
      ),
    );
  }
}
