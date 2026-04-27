import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';

const List<String> categories = ['전체', '패션', '뷰티', '라이프', '디지털', '기타'];

class CategoryFilter extends ConsumerWidget {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wishlistViewModelProvider);
    final vm = ref.read(wishlistViewModelProvider.notifier);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = state.selectedCategories.contains(category);

          return GestureDetector(
            onTap: () => vm.toggleCategory(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFCBE9FF) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0099FF) : const Color(0xFF666666),
                  width: 2,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}