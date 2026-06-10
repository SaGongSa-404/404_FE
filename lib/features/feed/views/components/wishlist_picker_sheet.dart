import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<WishlistPlaceholder?> showWishlistPickerSheet(
  BuildContext context, {
  WishlistPlaceholder? currentSelection,
}) {
  return showModalBottomSheet<WishlistPlaceholder>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => _WishlistPickerDialog(
      currentSelection: currentSelection,
    ),
  );
}

class _WishlistPickerDialog extends ConsumerStatefulWidget {
  const _WishlistPickerDialog({this.currentSelection});

  final WishlistPlaceholder? currentSelection;

  @override
  ConsumerState<_WishlistPickerDialog> createState() =>
      _WishlistPickerDialogState();
}

class _WishlistPickerDialogState
    extends ConsumerState<_WishlistPickerDialog> {
  WishlistPlaceholder? _selected;

  @override
  void initState() {
    super.initState();
    _selected = _resolveItem(
      ref.read(wishlistViewModelProvider).items,
      widget.currentSelection,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wishlistViewModelProvider.notifier).reloadOnScreenOpen();
    });
  }

  WishlistPlaceholder? _resolveItem(
    List<WishlistPlaceholder> items,
    WishlistPlaceholder? source,
  ) {
    if (source == null) return null;
    for (final item in items) {
      if (item.id == source.id) return item;
    }
    return source;
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    final items = ref.watch(wishlistViewModelProvider).items;
    final selected =
        _selected == null ? null : _resolveItem(items, _selected);
    final horizontalInset = MediaQuery.of(context).size.width * 21 / 412;
    final hasSelection = selected != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalInset,
        0,
        horizontalInset,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Container(
        height: (390 * scale).clamp(312.0, 468.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular((22 * scale).clamp(17.0, 27.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 3,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: (24 * scale).clamp(18.0, 30.0),
          vertical: (31 * scale).clamp(24.0, 38.0),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: (7 * scale).clamp(5.0, 9.0)),
              child: Text(
                '나의 위시',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: (20 * scale).clamp(16.0, 24.0),
                  color: AppColors.textDark,
                  height: 1.29,
                ),
              ),
            ),
            SizedBox(height: (27 * scale).clamp(21.0, 33.0)),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        '위시 목록이 없어요',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: (16 * scale).clamp(13.0, 19.0),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: (9 * scale).clamp(7.0, 11.0)),
                      itemBuilder: (_, index) {
                        final item = items[index];
                        final isSelected = selected?.id == item.id;
                        return GestureDetector(
                          onTap: () => setState(
                            () => _selected = isSelected ? null : item,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            height: (57 * scale).clamp(46.0, 68.0),
                            padding: EdgeInsets.symmetric(
                              horizontal: (10 * scale).clamp(8.0, 12.0),
                            ),
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
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: (18 * scale).clamp(14.0, 22.0),
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: (27 * scale).clamp(21.0, 33.0)),
            AnimatedOpacity(
              opacity: hasSelection ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: hasSelection
                    ? () => Navigator.of(context).pop(selected)
                    : null,
                child: Container(
                  width: double.infinity,
                  height: (57 * scale).clamp(46.0, 68.0),
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(57),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '선택',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: (20 * scale).clamp(16.0, 24.0),
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
