import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<WishlistPlaceholder?> showWishlistPickerSheet(BuildContext context) {
  return showDialog<WishlistPlaceholder>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => const _WishlistPickerDialog(),
  );
}

class _WishlistPickerDialog extends ConsumerStatefulWidget {
  const _WishlistPickerDialog();

  @override
  ConsumerState<_WishlistPickerDialog> createState() =>
      _WishlistPickerDialogState();
}

class _WishlistPickerDialogState
    extends ConsumerState<_WishlistPickerDialog> {
  WishlistPlaceholder? _selected;

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(wishlistViewModelProvider).items;
    final screenHeight = MediaQuery.of(context).size.height;
    final hasSelection = _selected != null;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.75),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 3,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 31),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: const Text(
                  '나의 위시',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppColors.textDark,
                    height: 1.29,
                  ),
                ),
              ),
              const SizedBox(height: 27),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '위시 목록이 없어요',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 9),
                    itemBuilder: (_, index) {
                      final item = items[index];
                      final isSelected = _selected?.id == item.id;
                      return GestureDetector(
                        onTap: () => setState(
                          () => _selected = isSelected ? null : item,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 57,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE6E6E6)
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(56),
                            border: Border.all(
                              color: const Color(0xFFC4C4C4),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${item.title} ${_formatPrice(item.price)}원',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 27),
              AnimatedOpacity(
                opacity: hasSelection ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: hasSelection
                      ? () => Navigator.of(context).pop(_selected)
                      : null,
                  child: Container(
                    width: double.infinity,
                    height: 57,
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(57),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '선택',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
