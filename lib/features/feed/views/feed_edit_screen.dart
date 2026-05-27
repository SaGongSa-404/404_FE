import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/views/components/confirm_modal.dart';
import 'package:fe_app/features/feed/providers/feed_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class FeedEditScreen extends ConsumerStatefulWidget {
  const FeedEditScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<FeedEditScreen> createState() => _FeedEditScreenState();
}

class _FeedEditScreenState extends ConsumerState<FeedEditScreen> {
  late final TextEditingController _controller;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    final post = ref
        .read(feedProvider)
        .posts
        .firstWhere((p) => p.id == widget.postId);
    _controller = TextEditingController(text: post.content);
    _hasContent = post.content.trim().isNotEmpty;
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
      title: '게시글 작성을 그만두시겠나요?',
      subtitle: '한 번 삭제된 게시글은 되돌릴 수 없어요',
      actionLabel: '그만두기',
    );
    if (shouldDiscard == true && mounted) context.pop();
  }

  void _onSubmit() {
    if (!_hasContent) return;
    ref
        .read(feedProvider.notifier)
        .updatePost(widget.postId, _controller.text.trim());
    context.pop('edited');
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    final post = ref
        .watch(feedProvider)
        .posts
        .firstWhere((p) => p.id == widget.postId);

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
          '게시글 수정하기',
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
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (post.productName != null) ...[
                    SizedBox(height: (16 * scale).clamp(12.0, 20.0)),
                    _ProductCard(
                      name: post.productName!,
                      price: post.productPrice,
                      imageUrl: post.productImageUrl,
                    ),
                  ],
                ],
              ),
            ),
          ),
          _BottomButtons(
            canSubmit: _hasContent,
            onCancel: _onClose,
            onSubmit: _onSubmit,
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.name,
    this.price,
    this.imageUrl,
  });

  final String name;
  final String? price;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular((22 * scale).clamp(17.0, 27.0)),
          ),
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  height: (150 * scale).clamp(120.0, 180.0),
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: (150 * scale).clamp(120.0, 180.0),
                  width: double.infinity,
                  color: AppColors.skyBlue_100.withValues(alpha: 0.4),
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
                name,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: (15 * scale).clamp(12.0, 18.0),
                  color: AppColors.textPrimary,
                ),
              ),
              if (price != null)
                Text(
                  price!,
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

class _BottomButtons extends StatefulWidget {
  const _BottomButtons({
    required this.canSubmit,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool canSubmit;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  State<_BottomButtons> createState() => _BottomButtonsState();
}

class _BottomButtonsState extends State<_BottomButtons> {
  bool _cancelPressed = false;
  bool _submitPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        (24 * scale).clamp(18.0, 30.0),
        (8 * scale).clamp(6.0, 10.0),
        (24 * scale).clamp(18.0, 30.0),
        MediaQuery.of(context).padding.bottom + (16 * scale).clamp(12.0, 20.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTapDown: (_) => setState(() => _cancelPressed = true),
              onTapUp: (_) {
                setState(() => _cancelPressed = false);
                widget.onCancel();
              },
              onTapCancel: () => setState(() => _cancelPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: EdgeInsets.symmetric(vertical: (15 * scale).clamp(12.0, 18.0)),
                decoration: BoxDecoration(
                  color: _cancelPressed ? AppColors.grey_300 : AppColors.grey_100,
                  borderRadius: BorderRadius.circular(40),
                ),
                alignment: Alignment.center,
                child: Text(
                  '취소',
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
          SizedBox(width: (12 * scale).clamp(9.0, 15.0)),
          Expanded(
            child: AnimatedOpacity(
              opacity: widget.canSubmit ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTapDown: widget.canSubmit ? (_) => setState(() => _submitPressed = true) : null,
                onTapUp: widget.canSubmit ? (_) {
                  setState(() => _submitPressed = false);
                  widget.onSubmit();
                } : null,
                onTapCancel: () => setState(() => _submitPressed = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: EdgeInsets.symmetric(vertical: (15 * scale).clamp(12.0, 18.0)),
                  decoration: BoxDecoration(
                    color: _submitPressed ? AppColors.skyBlue_200 : AppColors.skyBlue_100,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '수정완료',
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
          ),
        ],
      ),
    );
  }
}
