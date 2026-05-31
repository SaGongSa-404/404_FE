import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
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
    this.itemId,
    this.purchasedAtLabel = '구매일 2026.06.27',
  });

  final WishlistPlaceholder? item;
  final String? itemId;
  final String purchasedAtLabel;

  @override
  ConsumerState<WishlistReflectScreen> createState() =>
      _WishlistReflectScreenState();
}

class _WishlistReflectScreenState extends ConsumerState<WishlistReflectScreen> {
  ReflectFeedback? _feedback;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final displayItem = ref.watch(
      reflectDisplayItemProvider(
        ReflectDisplayItemRequest(
          explicitItem: widget.item,
          itemId: widget.itemId,
        ),
      ),
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight * scale),
        child: ColoredBox(
          color: AppColors.background,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight * scale,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: 44 * scale,
                        minHeight: 44 * scale,
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.brown,
                        size: 18 * scale,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '위시 돌아보기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brown,
                            height: 1.0,
                          ),
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 44 * scale),
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
          padding: EdgeInsets.fromLTRB(
            24 * scale,
            28 * scale,
            24 * scale,
            24 * scale,
          ),
          child: Column(
            children: [
              SizedBox(
                width: 137 * scale,
                height: 166 * scale,
                child: Image.asset(
                  'assets/images/nugul_reflect.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 15 * scale),
              ReflectItemCard(
                item: displayItem,
                purchasedAtLabel: widget.purchasedAtLabel,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 32 * scale),
                child: Divider(
                  height: 1 * scale,
                  thickness: 1 * scale,
                  color: const Color(0xFFCBCBCB),
                ),
              ),
              Text(
                '지금 돌아보아도\n구매하길 잘했다고 생각하시나요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24 * scale),
              ReflectFeedbackSelector(
                selected: _feedback,
                onSelected: (value) => setState(() => _feedback = value),
              ),
              SizedBox(height: 32 * scale),
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
