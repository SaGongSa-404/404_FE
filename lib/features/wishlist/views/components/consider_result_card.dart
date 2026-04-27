import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';

class ConsiderResultCard extends ConsumerWidget {
  const ConsiderResultCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(considerViewModelProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF0),
        border: Border.all(color: const Color(0xFFA6DEFF), width: 2.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '지금까지 확인한 내용',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF616161)),
          ),
          const SizedBox(height: 25),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildItem(state.budgetPercent, '예산 사용'),
                _buildVerticalDivider(),
                _buildItem('${state.yesCount}개', '비합리 답변'),
                _buildVerticalDivider(),
                _buildItem(state.opportunityCost, '기회비용'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF757575), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return const VerticalDivider(
      color: Color(0xFFE0E0E0),
      thickness: 1.5,
      indent: 5,
      endIndent: 5,
    );
  }
}