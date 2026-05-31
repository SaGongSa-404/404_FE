import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart'
    as wishlist_vm;

class CategoryFilter extends ConsumerWidget {
  const CategoryFilter({super.key, this.categories = wishlist_vm.categories});

  final List<String> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);
    final state = ref.watch(wishlist_vm.wishlistViewModelProvider);
    final vm = ref.read(wishlist_vm.wishlistViewModelProvider.notifier);

    return SizedBox(
      height: 40 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
        itemCount: categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 6 * scale),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = state.selectedCategories.contains(category);

          return GestureDetector(
            onTap: () => vm.toggleCategory(category),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25 * scale, vertical: 8 * scale),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8F3F9) : Colors.white,
                borderRadius: BorderRadius.circular(20 * scale),
                border: Border.all(
                  color: isSelected ? AppColors.skyBlue_100 : const Color(0xFFD0D0D0),
                  width: 1,
                ),
              ),
              child: Text(
                category,
                strutStyle: StrutStyle(
                  fontSize: 16 * scale,
                  height: 1.2,
                  leadingDistribution: TextLeadingDistribution.even,
                  forceStrutHeight: true,
                ),
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: TextStyle(
                  fontSize: 16 * scale,
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
