import 'dart:math' as math;

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/models/feed_comment.dart';
import 'package:fe_app/features/feed/providers/feed_provider.dart';
import 'package:fe_app/features/feed/views/components/product_link_dialog.dart';
import 'package:fe_app/features/feed/views/components/vote_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class FeedDetailScreen extends ConsumerWidget {
  const FeedDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedProvider);
    final vm = ref.read(feedProvider.notifier);

    FeedPost? post;
    for (final p in state.posts) {
      if (p.id == postId) {
        post = p;
        break;
      }
    }

    if (post == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: const Center(child: Text('게시글을 찾을 수 없어요')),
      );
    }

    final comments = state.commentsMap[postId] ?? [];
    final currentPost = post;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _DetailPostCard(
                  post: currentPost,
                  onVote: (vote) => vm.vote(postId, vote),
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
                    onLike: (commentId) =>
                        vm.toggleCommentLike(postId, commentId),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          _BottomCommentBar(
            onSubmit: (text) => vm.addComment(postId, text),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
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
    required this.onLike,
  });

  final List<FeedComment> comments;
  final ValueChanged<String> onLike;

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
            onLike: () => onLike(comments[i].id),
          ),
          if (i < comments.length - 1) const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _DetailCommentItem extends StatelessWidget {
  const _DetailCommentItem({
    required this.comment,
    required this.onLike,
  });

  final FeedComment comment;
  final VoidCallback onLike;

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
                    comment.authorName,
                    style: const TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    comment.createdAt,
                    style: const TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w400, fontSize: 15, color: AppColors.textDate),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                comment.content,
                style: const TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w500, fontSize: 16, color: AppColors.textDark, height: 1.5),
              ),
              const SizedBox(height: 3),
              const Text('답글', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textSecondary)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onLike,
          child: Padding(
            padding: const EdgeInsets.only(top: 3, left: 8),
            child: SvgPicture.asset(
              'assets/images/heart.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                comment.isLiked ? AppColors.red_600 : AppColors.textDate,
                BlendMode.srcIn,
              ),
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
            AnimatedOpacity(
              opacity: _hasText ? 1.0 : 0.3,
              duration: const Duration(milliseconds: 150),
              child: GestureDetector(
                onTap: _submit,
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
