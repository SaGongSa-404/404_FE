import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/models/feed_comment.dart';
import 'package:fe_app/features/feed/models/vote_type.dart';
import 'package:fe_app/features/feed/providers/feed_provider.dart';
import 'package:fe_app/features/feed/utils/feed_date_formatter.dart';
import 'package:fe_app/features/feed/views/components/block_modal.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 삭제 여부는 진입 전(피드/내 글 탭 시점)에 이미 확인합니다.
      final vm = ref.read(feedProvider.notifier);
      vm.refreshPost(widget.postId);
      vm.loadComments(widget.postId, refresh: true);
    });
  }

  Future<void> _handleCommentOption(
    String commentId,
    bool isMyComment,
    String authorUserId,
  ) async {
    final result = await showCommentOptionModal(context, isMyComment: isMyComment);
    if (!mounted) return;
    if (result == 'delete') {
      ref.read(feedProvider.notifier).deleteComment(widget.postId, commentId);
      _showCommentToast('삭제되었습니다');
    } else if (result == 'report') {
      final reason = await showReportModal(context);
      if (!mounted || reason == null) return;
      final ok = await ref
          .read(feedProvider.notifier)
          .reportComment(widget.postId, commentId, reason);
      if (!mounted) return;
      if (ok) _showCommentToast('신고가 완료되었습니다');
    } else if (result == 'block') {
      final blocked = await showBlockModal(context);
      if (!mounted || !blocked) return;
      final ok = await ref
          .read(feedProvider.notifier)
          .blockUser(authorUserId: authorUserId);
      if (!mounted || !ok) return;
      // 현재 보고 있는 글의 작성자를 차단했다면 글이 사라지므로 피드로 돌아갑니다.
      final postGone =
          !ref.read(feedProvider).posts.any((p) => p.id == widget.postId);
      if (postGone) {
        context.pop();
        return;
      }
      _showCommentToast('차단되었습니다');
    }
  }

  void _showCommentToast(String message) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: (18 * scale).clamp(14.0, 22.0),
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.red_600.withValues(alpha: 0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(47)),
        margin: EdgeInsets.fromLTRB(
          (26 * scale).clamp(20.0, 32.0),
          0,
          (26 * scale).clamp(20.0, 32.0),
          (134 * scale).clamp(100.0, 168.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: (24 * scale).clamp(18.0, 30.0),
          vertical: (9 * scale).clamp(7.0, 12.0),
        ),
        elevation: 6,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  AppBar _buildAppBar() {
    final scale = MediaQuery.of(context).size.width / 412.0;
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/arrow_forward.svg',
            width: (19 * scale).clamp(15.0, 23.0),
            height: (19 * scale).clamp(15.0, 23.0),
            colorFilter: const ColorFilter.mode(
              AppColors.brown,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      title: Text(
        '게시글',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
          fontSize: (20 * scale).clamp(16.0, 24.0),
          color: AppColors.brown,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
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

    final commentsPage = state.commentsMap[widget.postId];
    final comments = commentsPage?.items ?? const <FeedComment>[];
    final commentTotal = commentsPage?.total ?? post.commentCount;
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
                  onBlockedVote: () =>
                      _showCommentToast('본인 게시글은 투표할 수 없습니다'),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    (30 * scale).clamp(24.0, 36.0),
                    (21 * scale).clamp(16.0, 26.0),
                    (30 * scale).clamp(24.0, 36.0),
                    0,
                  ),
                  child: Text(
                    '댓글 $commentTotal개',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: (16 * scale).clamp(13.0, 19.0),
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: (21 * scale).clamp(16.0, 26.0)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (30 * scale).clamp(24.0, 36.0),
                  ),
                  child: _CommentList(
                    comments: comments,
                    onOption: _handleCommentOption,
                  ),
                ),
                SizedBox(height: (100 * scale).clamp(80.0, 120.0)),
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
    required this.onBlockedVote,
  });

  final FeedPost post;
  final ValueChanged<VoteType> onVote;
  final VoidCallback onBlockedVote;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular((22 * scale).clamp(17.0, 27.0)),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        (24 * scale).clamp(18.0, 30.0),
        (25 * scale).clamp(19.0, 31.0),
        (24 * scale).clamp(18.0, 30.0),
        (25 * scale).clamp(19.0, 31.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/user_profile.svg',
                width: (31 * scale).clamp(25.0, 37.0),
                height: (32 * scale).clamp(26.0, 38.0),
              ),
              SizedBox(width: (5 * scale).clamp(4.0, 6.0)),
              Text(
                post.authorNickname,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: (15 * scale).clamp(12.0, 18.0),
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: (10 * scale).clamp(8.0, 12.0)),
              Text(
                formatFeedTimestamp(post.createdAt),
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: (15 * scale).clamp(12.0, 18.0),
                  color: AppColors.textDate,
                ),
              ),
            ],
          ),
          SizedBox(height: (16 * scale).clamp(12.0, 20.0)),
          // 글이 없는(위시리스트만 있는) 게시글은 본문 영역을 그리지 않습니다.
          if ((post.body?.trim().isNotEmpty ?? false)) ...[
            Text(
              post.body!,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: (18 * scale).clamp(14.0, 22.0),
                color: AppColors.textDark,
                height: 1.43,
              ),
            ),
            SizedBox(height: (19 * scale).clamp(15.0, 23.0)),
          ],
          if (post.product != null) ...[
            GestureDetector(
              onTap: () => showProductLinkDialog(
                context: context,
                productUrl: post.product?.link,
              ),
              child: _DetailProductCard(
                name: post.product!.name,
                price: post.product!.price,
                imageUrl: post.imageUrl ?? post.product!.imageUrl,
              ),
            ),
            SizedBox(height: (17 * scale).clamp(13.0, 21.0)),
          ],
          VoteButtons(
            myVote: post.myVote,
            goCount: post.goCount,
            stopCount: post.stopCount,
            onVote: onVote,
            isDisabled: post.mine,
            onDisabledTap: onBlockedVote,
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
  final int? price;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    final imageHeight = (150 * scale).clamp(120.0, 180.0);
    final placeholder = Container(
      height: imageHeight,
      width: double.infinity,
      color: AppColors.skyBlue_100.withValues(alpha: 0.4),
    );
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular((22 * scale).clamp(17.0, 27.0)),
          ),
          child: hasImage
              ? Image.network(
                  imageUrl!,
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => placeholder,
                )
              : placeholder,
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
                  _formatKrw(price!),
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

String _formatKrw(int price) {
  final body = price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
  return '$body원';
}

class _CommentList extends StatelessWidget {
  const _CommentList({
    required this.comments,
    required this.onOption,
  });

  final List<FeedComment> comments;
  final void Function(String commentId, bool isMyComment, String authorUserId) onOption;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    if (comments.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        for (int i = 0; i < comments.length; i++) ...[
          _DetailCommentItem(
            comment: comments[i],
            onOption: () => onOption(comments[i].id, comments[i].mine, comments[i].authorUserId),
          ),
          if (i < comments.length - 1) SizedBox(height: (20 * scale).clamp(15.0, 25.0)),
        ],
      ],
    );
  }
}

class _DetailCommentItem extends StatelessWidget {
  const _DetailCommentItem({
    required this.comment,
    required this.onOption,
  });

  final FeedComment comment;
  final VoidCallback onOption;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/images/user_profile.svg',
          width: (43 * scale).clamp(34.0, 52.0),
          height: (45 * scale).clamp(36.0, 54.0),
        ),
        SizedBox(width: (11 * scale).clamp(8.0, 14.0)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.authorNickname,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: (15 * scale).clamp(12.0, 18.0),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: (10 * scale).clamp(8.0, 12.0)),
                  Text(
                    formatFeedTimestamp(comment.createdAt),
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: (15 * scale).clamp(12.0, 18.0),
                      color: AppColors.textDate,
                    ),
                  ),
                ],
              ),
              SizedBox(height: (3 * scale).clamp(2.0, 4.0)),
              Text(
                comment.body,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: (16 * scale).clamp(13.0, 19.0),
                  color: AppColors.textDark,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onOption,
          child: Padding(
            padding: EdgeInsets.only(
              top: (3 * scale).clamp(2.0, 4.0),
              left: (8 * scale).clamp(6.0, 10.0),
            ),
            child: SvgPicture.asset(
              'assets/images/comment_option.svg',
              width: (20 * scale).clamp(16.0, 24.0),
              height: (20 * scale).clamp(16.0, 24.0),
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
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    final iconSize = (54 * scale).clamp(43.0, 65.0);
    final iconRight = (16 * scale).clamp(12.0, 20.0);

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        (26 * scale).clamp(20.0, 32.0),
        (19 * scale).clamp(14.0, 24.0),
        (26 * scale).clamp(20.0, 32.0),
        MediaQuery.of(context).padding.bottom + (19 * scale).clamp(14.0, 24.0),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              (28 * scale).clamp(22.0, 34.0),
              (26 * scale).clamp(20.0, 32.0),
              iconSize + iconRight + (8 * scale).clamp(6.0, 10.0),
              (26 * scale).clamp(20.0, 32.0),
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular((59 * scale).clamp(47.0, 72.0)),
              border: Border.all(color: const Color(0xFFADADAD)),
            ),
            child: TextField(
              controller: _controller,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: (18 * scale).clamp(14.0, 22.0),
                color: AppColors.textDark,
                height: 1.548,
              ),
              decoration: InputDecoration(
                hintText: '댓글을 입력해주세요',
                hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: (18 * scale).clamp(14.0, 22.0),
                  color: const Color(0xFFADADAD),
                  height: 1.548,
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
                ? Padding(
                    key: const ValueKey('upload'),
                    padding: EdgeInsets.only(right: iconRight),
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _uploadPressed = true),
                      onTapUp: (_) {
                        setState(() => _uploadPressed = false);
                        _submit();
                      },
                      onTapCancel: () => setState(() => _uploadPressed = false),
                      child: SvgPicture.asset(
                        _uploadPressed
                            ? 'assets/images/comment_upload_clicked.svg'
                            : 'assets/images/comment_upload.svg',
                        width: iconSize,
                        height: iconSize,
                      ),
                    ),
                  )
                : Padding(
                    key: const ValueKey('empty'),
                    padding: EdgeInsets.only(right: iconRight),
                    child: Opacity(
                      opacity: 0,
                      child: SvgPicture.asset(
                        'assets/images/comment_upload.svg',
                        width: iconSize,
                        height: iconSize,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
