import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/views/components/confirm_modal.dart';
import 'package:fe_app/features/feed/models/create_post_request.dart';
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
    final shouldDiscard = await showConfirmBottomSheet(
      context: context,
      title: '게시글 작성을\n정말 그만두실 건가요?',
      subtitle: '작성 중인 내용은 저장되지 않아요',
      actionLabel: '그만두기',
    );
    if (shouldDiscard == true && mounted) context.pop();
  }

  Future<void> _onPickFromWishlist() async {
    final selected = await showWishlistPickerSheet(context);
    if (selected != null) setState(() => _selectedItem = selected);
  }

  Future<void> _onSubmit() async {
    if (!_hasContent) return;
    final body = _controller.text.trim();
    final created = await ref.read(feedProvider.notifier).addPost(
          CreatePostRequest(
            body: body,
            itemId: _selectedItem?.id,
          ),
        );
    if (!mounted) return;
    if (created != null) context.pop(true);
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
              width: (16 * scale).clamp(13.0, 19.0),
              height: (16 * scale).clamp(13.0, 19.0),
              colorFilter: const ColorFilter.mode(
                AppColors.brown,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        title: Text(
          '게시글 작성하기',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: (20 * scale).clamp(16.0, 24.0),
            color: AppColors.brown,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                (24 * scale).clamp(18.0, 30.0),
                (20 * scale).clamp(15.0, 25.0),
                (24 * scale).clamp(18.0, 30.0),
                (16 * scale).clamp(12.0, 20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    minLines: 6,
                    autofocus: true,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: (20 * scale).clamp(16.0, 24.0),
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                    decoration: InputDecoration(
                      hintText: '다른 사람과 함께 고민하고 싶은 걸 적어보세요',
                      hintStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: (20 * scale).clamp(16.0, 24.0),
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (_selectedItem != null) ...[
                    SizedBox(height: (16 * scale).clamp(12.0, 20.0)),
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

class _AttachedProductCard extends StatelessWidget {
  const _AttachedProductCard({
    required this.item,
    required this.formatPrice,
  });

  final WishlistPlaceholder item;
  final String Function(int) formatPrice;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular((22 * scale).clamp(17.0, 27.0)),
          ),
          child: item.imageUrl != null
              ? Image.network(
                  item.imageUrl!,
                  height: (150 * scale).clamp(120.0, 180.0),
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: (150 * scale).clamp(120.0, 180.0),
                  width: double.infinity,
                  color: AppColors.skyBlue_100.withValues(alpha: 0.4),
                  alignment: Alignment.center,
                  child: Text(
                    item.category.substring(0, 1),
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      fontSize: (40 * scale).clamp(32.0, 48.0),
                      color: AppColors.skyBlue_200,
                    ),
                  ),
                ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: (12 * scale).clamp(9.0, 15.0),
            vertical: (10 * scale).clamp(8.0, 12.0),
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular((22 * scale).clamp(17.0, 27.0)),
            ),
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
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: (15 * scale).clamp(12.0, 18.0),
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${formatPrice(item.price)}원',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: (14 * scale).clamp(11.0, 17.0),
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
    final scale = MediaQuery.of(context).size.width / 412.0;
    final hasItem = selectedItem != null;

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        (24 * scale).clamp(18.0, 30.0),
        (8 * scale).clamp(6.0, 10.0),
        (24 * scale).clamp(18.0, 30.0),
        MediaQuery.of(context).padding.bottom + (16 * scale).clamp(12.0, 20.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onPickFromWishlist,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: (15 * scale).clamp(12.0, 18.0)),
              decoration: BoxDecoration(
                color: hasItem ? AppColors.yellow_200 : AppColors.yellow,
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
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: (20 * scale).clamp(16.0, 24.0),
                        color: AppColors.textDark,
                      ),
                    )
                  : Text(
                      '위시 목록에서 가져오기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: (20 * scale).clamp(16.0, 24.0),
                        color: AppColors.textDark,
                      ),
                    ),
            ),
          ),
          SizedBox(height: (12 * scale).clamp(9.0, 15.0)),
          AnimatedOpacity(
            opacity: canSubmit ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: canSubmit ? onSubmit : null,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: (15 * scale).clamp(12.0, 18.0)),
                decoration: BoxDecoration(
                  color: AppColors.skyBlue_100,
                  borderRadius: BorderRadius.circular(40),
                ),
                alignment: Alignment.center,
                child: Text(
                  '완료',
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
    );
  }
}
