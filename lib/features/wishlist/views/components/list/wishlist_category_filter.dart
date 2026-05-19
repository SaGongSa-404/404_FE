import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart'
    as wishlist_vm;

class CategoryFilter extends ConsumerWidget {
  const CategoryFilter({super.key, this.categories = wishlist_vm.categories});

  final List<String> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wishlist_vm.wishlistViewModelProvider);
    final vm = ref.read(wishlist_vm.wishlistViewModelProvider.notifier);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = state.selectedCategories.contains(category);

          return GestureDetector(
            onTap: () => vm.toggleCategory(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8F3F9) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.skyBlue_100 : const Color(0xFFD0D0D0),
                  width: 1,
                ),
              ),
              child: Text(
                category,
                strutStyle: const StrutStyle(
                  fontSize: 16,
                  height: 1.2,
                  leadingDistribution: TextLeadingDistribution.even,
                  forceStrutHeight: true,
                ),
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}