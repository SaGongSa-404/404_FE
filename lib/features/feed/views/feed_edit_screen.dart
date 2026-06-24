import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/models/update_post_request.dart';
import 'package:fe_app/features/feed/providers/feed_provider.dart';
import 'package:fe_app/shared/widgets/confirm_bottom_sheet.dart';
import 'package:fe_app/features/feed/views/components/feed_product_card.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

FeedPost? _findPostById(List<FeedPost> posts, String id) {
  for (final p in posts) {
    if (p.id == id) return p;
  }
  return null;
}

class FeedEditScreen extends ConsumerStatefulWidget {
  const FeedEditScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<FeedEditScreen> createState() => _FeedEditScreenState();
}

class _FeedEditScreenState extends ConsumerState<FeedEditScreen> {
  static const int _maxBodyLength = 500;

  late final TextEditingController _controller;
  bool _hasContent = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final post = _findPostById(ref.read(feedProvider).posts, widget.postId);
    final initial = post?.body ?? '';
    _controller = TextEditingController(text: initial);
    _hasContent = initial.trim().isNotEmpty;
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
      context,
      title: '게시글 수정을 중단하시겠어요?',
      subtitle: '수정 중인 내용은 저장되지 않아요',
      actionLabel: '중단하기',
    );
    if (shouldDiscard == true && mounted) context.pop();
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    final post = _findPostById(ref.read(feedProvider).posts, widget.postId);
    // 글 또는 위시리스트 중 하나라도 있으면 수정 완료 가능 (작성 화면과 동일 기준)
    if (!_hasContent && post?.product == null) return;

    final body = _controller.text.trim();
    if (body.characters.length > _maxBodyLength) {
      showCapsuleToast(
        context,
        backgroundColor: AppColors.skyBlue_400,
        text: '게시글은 $_maxBodyLength자까지 작성할 수 있어요',
      );
      return;
    }

    _isSubmitting = true;
    final updated = await ref.read(feedProvider.notifier).updatePost(
          widget.postId,
          UpdatePostRequest(body: body.isEmpty ? null : body),
        );
    if (!mounted) return;
    if (updated != null) {
      context.pop('edited');
    } else {
      // 수정 실패 시 버튼을 다시 활성화해 재시도할 수 있게 합니다.
      _isSubmitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    final FeedPost? post =
        _findPostById(ref.watch(feedProvider).posts, widget.postId);

    if (post == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text('게시글 수정하기'),
        ),
        body: const Center(child: Text('게시글을 찾을 수 없어요')),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // 안드로이드 뒤로가기 시에도 X 버튼과 동일하게 그만두기 모달을 띄웁니다.
        if (!didPop) _onClose();
      },
      child: Scaffold(
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
                  if (post.product != null) ...[
                    SizedBox(height: (16 * scale).clamp(12.0, 20.0)),
                    FeedProductCard(
                      name: post.product!.name,
                      price: post.product!.price,
                      imageUrl: post.imageUrl ?? post.product!.imageUrl,
                    ),
                  ],
                ],
              ),
            ),
          ),
          _BottomButtons(
            canSubmit: _hasContent || post.product != null,
            onCancel: _onClose,
            onSubmit: _onSubmit,
          ),
        ],
      ),
      ),
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
