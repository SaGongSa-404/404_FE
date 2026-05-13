import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/providers/feed_provider.dart';
import 'package:fe_app/features/feed/views/components/wishlist_picker_sheet.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class FeedWriteScreen extends ConsumerStatefulWidget {
  const FeedWriteScreen({super.key});

  @override
  ConsumerState<FeedWriteScreen> createState() => _FeedWriteScreenState();
}

class _FeedWriteScreenState extends ConsumerState<FeedWriteScreen> {
  final _controller = TextEditingController();
  WishlistPlaceholder? _selectedItem;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasContent = _controller.text.trim().isNotEmpty;
      if (hasContent != _hasContent) setState(() => _hasContent = hasContent);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onClose() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const _DiscardDialog(),
    );
    if (shouldDiscard == true && mounted) context.pop();
  }

  Future<void> _onPickFromWishlist() async {
    final selected = await showWishlistPickerSheet(context);
    if (selected != null) setState(() => _selectedItem = selected);
  }

  void _onSubmit() {
    if (!_hasContent) return;
    ref.read(feedProvider.notifier).addPost(FeedPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: '익명의 너굴',
      createdAt: '방금 전',
      content: _controller.text.trim(),
      productName: _selectedItem?.title,
      productPrice: _selectedItem != null
          ? '${_formatPrice(_selectedItem!.price)}원'
          : null,
      productImageUrl: _selectedItem?.imageUrl,
      productUrl: _selectedItem?.link,
      goVoteCount: 0,
      stopVoteCount: 0,
      commentCount: 0,
      isMyPost: true,
    ));
    context.pop(true);
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: _onClose,
          child: Center(
            child: SvgPicture.asset(
              'assets/images/close.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.brown,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        title: const Text(
          '게시글 작성하기',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: AppColors.brown,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    minLines: 6,
                    autofocus: true,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                    decoration: const InputDecoration(
                      hintText: '다른 사람과 함께 고민하고 싶은 걸 적어보세요',
                      hintStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (_selectedItem != null) ...[
                    const SizedBox(height: 16),
                    _AttachedProductCard(
                      item: _selectedItem!,
                      formatPrice: _formatPrice,
                    ),
                  ],
                ],
              ),
            ),
          ),
          _BottomButtonSection(
            canSubmit: _hasContent,
            selectedItem: _selectedItem,
            formatPrice: _formatPrice,
            onPickFromWishlist: _onPickFromWishlist,
            onSubmit: _onSubmit,
          ),
        ],
      ),
    );
  }
}

class _DiscardDialog extends StatelessWidget {
  const _DiscardDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '게시글 작성을\n정말 그만두실 건가요?',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.textDark,
                      height: 1.29,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '한 번 삭제된 위시리스트는 되돌릴 수 없어요',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFF979797),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 27),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 57,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(57),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 57,
                      decoration: BoxDecoration(
                        color: AppColors.red_600,
                        borderRadius: BorderRadius.circular(57),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '삭제하기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 위시리스트에서 선택된 상품의 풀 이미지 카드 (피그마 553:2151 기준)
class _AttachedProductCard extends StatelessWidget {
  const _AttachedProductCard({
    required this.item,
    required this.formatPrice,
  });

  final WishlistPlaceholder item;
  final String Function(int) formatPrice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: item.imageUrl != null
              ? Image.network(
                  item.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 150,
                  width: double.infinity,
                  color: AppColors.skyBlue_100.withValues(alpha: 0.4),
                  alignment: Alignment.center,
                  child: Text(
                    item.category.substring(0, 1),
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      fontSize: 40,
                      color: AppColors.skyBlue_200,
                    ),
                  ),
                ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${formatPrice(item.price)}원',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomButtonSection extends StatelessWidget {
  const _BottomButtonSection({
    required this.canSubmit,
    required this.selectedItem,
    required this.formatPrice,
    required this.onPickFromWishlist,
    required this.onSubmit,
  });

  final bool canSubmit;
  final WishlistPlaceholder? selectedItem;
  final String Function(int) formatPrice;
  final VoidCallback onPickFromWishlist;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final hasItem = selectedItem != null;

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onPickFromWishlist,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: hasItem ? AppColors.yellowLight : AppColors.yellow,
                borderRadius: BorderRadius.circular(40),
                border: hasItem
                    ? Border.all(color: AppColors.yellow, width: 2)
                    : null,
              ),
              alignment: Alignment.center,
              child: hasItem
                  ? Text(
                      '${selectedItem!.title} ${formatPrice(selectedItem!.price)}원',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: AppColors.textDark,
                      ),
                    )
                  : const Text(
                      '위시 목록에서 가져오기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: AppColors.textDark,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedOpacity(
            opacity: canSubmit ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: canSubmit ? onSubmit : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.skyBlue_100,
                  borderRadius: BorderRadius.circular(40),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '완료',
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
    );
  }
}
