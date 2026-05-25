import 'dart:math' as math;

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/models/feed_comment.dart';
import 'package:fe_app/features/feed/providers/feed_provider.dart';
import 'package:fe_app/features/feed/views/components/comment_option_modal.dart';
import 'package:fe_app/features/feed/views/components/product_link_dialog.dart';
import 'package:fe_app/features/feed/views/components/report_modal.dart';
import 'package:fe_app/features/feed/views/components/vote_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class FeedDetailScreen extends ConsumerStatefulWidget {
  const FeedDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends ConsumerState<FeedDetailScreen> {
  Future<void> _handleCommentOption(String commentId, bool isMyComment) async {
    final result = await showCommentOptionModal(context, isMyComment: isMyComment);
    if (!mounted) return;
    if (result == 'delete') {
      ref.read(feedProvider.notifier).deleteComment(widget.postId, commentId);
      _showCommentToast('삭제되었습니다');
    } else if (result == 'report') {
      final reported = await showReportModal(context);
      if (!mounted) return;
      if (reported) _showCommentToast('신고가 완료되었습니다');
    }
  }

  void _showCommentToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.red_600.withValues(alpha: 0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(47)),
        margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 19),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
        elevation: 6,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Center(
          child: Transform.rotate(
            angle: math.pi,
            child: SvgPicture.asset(
              'assets/images/arrow_forward.svg',
              width: 19,
              height: 19,
              colorFilter: const ColorFilter.mode(
                AppColors.brown,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
      title: const Text(
        '게시글',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: AppColors.brown,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);
    final vm = ref.read(feedProvider.notifier);

    FeedPost? post;
    for (final p in state.posts) {
      if (p.id == widget.postId) {
        post = p;
        break;
      }
    }

    if (post == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: const Center(child: Text('게시글을 찾을 수 없어요')),
      );
    }

    final comments = state.commentsMap[widget.postId] ?? [];
    final currentPost = post;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _DetailPostCard(
                  post: currentPost,
                  onVote: (vote) => vm.vote(widget.postId, vote),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 21, 30, 0),
                  child: Text(
                    '댓글 ${comments.length}개',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 21),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: _CommentList(
                    comments: comments,
                    onOption: _handleCommentOption,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          _BottomCommentBar(
            onSubmit: (text) => vm.addComment(widget.postId, text),
          ),
        ],
      ),
    );
  }
}

class _DetailPostCard extends StatelessWidget {
  const _DetailPostCard({
    required this.post,
    required this.onVote,
  });

  final FeedPost post;
  final ValueChanged<VoteType> onVote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 25, 24, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/user_profile.svg',
                width: 31,
                height: 32,
              ),
              const SizedBox(width: 5),
              Text(
                post.authorName,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                post.createdAt,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: AppColors.textDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            post.content,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: AppColors.textDark,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 19),
          if (post.productName != null) ...[
            GestureDetector(
              onTap: () => showProductLinkDialog(
                context: context,
                productUrl: post.productUrl,
              ),
              child: _DetailProductCard(
                name: post.productName!,
                price: post.productPrice,
                imageUrl: post.productImageUrl,
              ),
            ),
            const SizedBox(height: 17),
          ],
          VoteButtons(
            myVote: post.myVote,
            goCount: post.goVoteCount,
            stopCount: post.stopVoteCount,
            onVote: onVote,
            isDisabled: post.isMyPost,
          ),
        ],
      ),
    );
  }
}

class _DetailProductCard extends StatelessWidget {
  const _DetailProductCard({
    required this.name,
    this.price,
    this.imageUrl,
  });

  final String name;
  final String? price;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: imageUrl != null
              ? Image.network(imageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover)
              : Container(height: 150, width: double.infinity, color: AppColors.skyBlue_100.withValues(alpha: 0.4)),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 3)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
              if (price != null)
                Text(price!, style: const TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentList extends StatelessWidget {
  const _CommentList({
    required this.comments,
    required this.onOption,
  });

  final List<FeedComment> comments;
  final void Function(String commentId, bool isMyComment) onOption;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        for (int i = 0; i < comments.length; i++) ...[
          _DetailCommentItem(
            comment: comments[i],
            onOption: () => onOption(comments[i].id, comments[i].isMyComment),
          ),
          if (i < comments.length - 1) const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _DetailCommentItem extends StatefulWidget {
  const _DetailCommentItem({
    required this.comment,
    required this.onOption,
  });

  final FeedComment comment;
  final VoidCallback onOption;

  @override
  State<_DetailCommentItem> createState() => _DetailCommentItemState();
}

class _DetailCommentItemState extends State<_DetailCommentItem> {
  bool _optionPressed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset('assets/images/user_profile.svg', width: 43, height: 45),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.comment.authorName,
                    style: const TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.comment.createdAt,
                    style: const TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w400, fontSize: 15, color: AppColors.textDate),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                widget.comment.content,
                style: const TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w500, fontSize: 16, color: AppColors.textDark, height: 1.5),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTapDown: (_) => setState(() => _optionPressed = true),
          onTapUp: (_) {
            setState(() => _optionPressed = false);
            widget.onOption();
          },
          onTapCancel: () => setState(() => _optionPressed = false),
          child: Padding(
            padding: const EdgeInsets.only(top: 3, left: 8),
            child: SvgPicture.asset(
              _optionPressed
                  ? 'assets/images/option_clicked.svg'
                  : 'assets/images/option.svg',
              width: 20,
              height: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomCommentBar extends StatefulWidget {
  const _BottomCommentBar({required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<_BottomCommentBar> createState() => _BottomCommentBarState();
}

class _BottomCommentBarState extends State<_BottomCommentBar> {
  final _controller = TextEditingController();
  bool _hasText = false;
  bool _uploadPressed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_hasText) return;
    widget.onSubmit(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        28,
        19,
        28,
        MediaQuery.of(context).padding.bottom + 19,
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 28, right: 12, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(59),
          border: Border.all(color: const Color(0xFFADADAD)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
                decoration: const InputDecoration(
                  hintText: '댓글을 입력해주세요',
                  hintStyle: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Color(0xFFADADAD),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: _hasText
                  ? GestureDetector(
                      key: const ValueKey('upload'),
                      onTapDown: (_) => setState(() => _uploadPressed = true),
                      onTapUp: (_) {
                        setState(() => _uploadPressed = false);
                        _submit();
                      },
                      onTapCancel: () => setState(() => _uploadPressed = false),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.skyBlue_100,
                            borderRadius: BorderRadius.circular(19),
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            _uploadPressed
                                ? 'assets/images/comment_upload_clicked.svg'
                                : 'assets/images/comment_upload.svg',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    )
                  : Opacity(
                      key: const ValueKey('send'),
                      opacity: 0.3,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.send_rounded,
                          size: 22,
                          color: AppColors.skyBlue_200,
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
