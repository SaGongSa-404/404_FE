import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:fe_app/features/wishlist/views/components/consider_scroll_indicator.dart';

class ConsiderChecklist extends ConsumerWidget {
  final PageController pageController;

  const ConsiderChecklist({super.key, required this.pageController});

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

    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              '점검 질문',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...List.generate(_questions.length, (index) {
              final question = _questions[index];
              final currentAnswer = state.answers[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question,
                      style: const TextStyle(fontSize: 16, height: 1.3),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildButton(viewModel, index, 'Yes', true, currentAnswer == true),
                        const SizedBox(width: 12),
                        _buildButton(viewModel, index, 'No', false, currentAnswer == false),
                      ],
                    ),
                  ],
                ),
              );
            }),

            if (state.shouldShowWarning) ...[
              const Divider(thickness: 2, color: Color(0xFFE0E0E0), height: 24), // height 줄임
              _buildWarningBanner(),
            ],

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Center(
                child: GestureDetector(
                  onTap: () => pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ),
                  child: const ConsiderScrollIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(ConsiderViewModel vm, int index, String label, bool value, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => vm.setAnswer(index, value),
        child: Container(
          height: 40, // 네 디자인 높이 30 유지
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFCBE9FF) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF3BA2EA) : const Color(0xFF7A7A7A),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF3BA2EA) : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC1C1), width: 1),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🦝', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text('잠깐요!',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE54327))),
            ],
          ),
          SizedBox(height: 6),
          Text('답변을 보니 지금 이 구매,\n충동적일 수 있어요.',
              style: TextStyle(fontSize: 14, height: 1.3)),
        ],
      ),
    );
  }
}