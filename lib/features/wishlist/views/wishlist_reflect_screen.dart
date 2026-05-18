import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:fe_app/features/wishlist/views/components/reflect/reflect_complete_button.dart';
import 'package:fe_app/features/wishlist/views/components/reflect/reflect_feedback_selector.dart';
import 'package:fe_app/features/wishlist/views/components/reflect/reflect_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WishlistReflectScreen extends ConsumerStatefulWidget {
  const WishlistReflectScreen({
    super.key,
    this.item,
    this.purchasedAtLabel = '구매일 2026.06.27',
  });

  final WishlistPlaceholder? item;
  final String purchasedAtLabel;

  @override
  ConsumerState<WishlistReflectScreen> createState() =>
      _WishlistReflectScreenState();
}

class _WishlistReflectScreenState extends ConsumerState<WishlistReflectScreen> {
  ReflectFeedback? _feedback;

  WishlistPlaceholder get _item {
    if (widget.item != null) return widget.item!;
    final items = ref.watch(wishlistViewModelProvider).items;
    if (items.isNotEmpty) return items.first;
    return mockWishlistItems.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ColoredBox(
          color: AppColors.background,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.brown,
                        size: 18,
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          '위시 돌아보기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brown,
                            height: 1.0,
                          ),
                          textHeightBehavior: TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            children: [
              SizedBox(
                width: 137,
                height: 166,
                child: Image.asset(
                  'assets/images/nugul_reflect.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 15),
              ReflectItemCard(
                item: _item,
                purchasedAtLabel: widget.purchasedAtLabel,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFCBCBCB),
                ),
              ),
              const Text(
                '지금 돌아보아도\n구매하길 잘했다고생각하시나요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ReflectFeedbackSelector(
                selected: _feedback,
                onSelected: (value) => setState(() => _feedback = value),
              ),
              const SizedBox(height: 32),
              ReflectCompleteButton(
                enabled: _feedback != null,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
