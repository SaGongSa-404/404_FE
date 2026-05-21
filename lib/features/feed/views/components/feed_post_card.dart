import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/views/components/vote_buttons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FeedPostCard extends StatefulWidget {
  const FeedPostCard({
    super.key,
    required this.post,
    required this.isOptionActive,
    required this.onVote,
    required this.onOptionTap,
    required this.onCommentTap,
    required this.onCardTap,
  });

  final FeedPost post;
  final bool isOptionActive;
  final ValueChanged<VoteType> onVote;
  final VoidCallback onOptionTap;
  final VoidCallback onCommentTap;
  final VoidCallback onCardTap;

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return GestureDetector(
      onTap: widget.onCardTap,
      child: Container(
        width: double.infinity,
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
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/images/user_profile.svg',
              width: 33,
              height: 35,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PostHeader(
                    post: post,
                    isOptionActive: widget.isOptionActive,
                    onOptionTap: widget.onOptionTap,
                  ),
                  const SizedBox(height: 7),
                  _ExpandableText(
                    text: post.content,
                    isExpanded: _isExpanded,
                    onExpand: () => setState(() => _isExpanded = true),
                  ),
                  const SizedBox(height: 16),
                  if (post.productName != null) ...[
                    _ProductCard(
                      name: post.productName!,
                      price: post.productPrice,
                      imageUrl: post.productImageUrl,
                    ),
                    const SizedBox(height: 15),
                  ],
                  GestureDetector(
                    onTap: () {},
                    behavior: HitTestBehavior.opaque,
                    child: VoteButtons(
                      myVote: post.myVote,
                      goCount: post.goVoteCount,
                      stopCount: post.stopVoteCount,
                      onVote: widget.onVote,
                      isDisabled: post.isMyPost,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: widget.onCommentTap,
                    behavior: HitTestBehavior.opaque,
                    child: _CommentPreviewRow(post: post),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({
    required this.post,
    required this.isOptionActive,
    required this.onOptionTap,
  });

  final FeedPost post;
  final bool isOptionActive;
  final VoidCallback onOptionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
        Expanded(
          child: Text(
            post.createdAt,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: AppColors.textDate,
            ),
          ),
        ),
        if (post.isMyPost)
          GestureDetector(
            onTap: onOptionTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SvgPicture.asset(
                isOptionActive
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

class _ExpandableText extends StatelessWidget {
  const _ExpandableText({
    required this.text,
    required this.isExpanded,
    required this.onExpand,
  });

  final String text;
  final bool isExpanded;
  final VoidCallback onExpand;

  static const _contentStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w400,
    fontSize: 17,
    color: AppColors.textDark,
    height: 1.3,
  );

  static const _moreStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w400,
    fontSize: 18,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
      return Text(text, style: _contentStyle);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tp = TextPainter(
          text: TextSpan(text: text, style: _contentStyle),
          maxLines: 3,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        if (!tp.didExceedMaxLines) {
          return Text(text, style: _contentStyle);
        }

        const moreText = '  더보기';
        final moreTp = TextPainter(
          text: const TextSpan(text: moreText, style: _moreStyle),
          textDirection: TextDirection.ltr,
        )..layout();

        final cutPosition = tp.getPositionForOffset(
          Offset(constraints.maxWidth - moreTp.width, tp.height - 1),
        );
        final truncated = text.substring(0, cutPosition.offset);

        return RichText(
          text: TextSpan(
            style: _contentStyle,
            children: [
              TextSpan(text: truncated),
              TextSpan(
                text: moreText,
                style: _moreStyle,
                recognizer: TapGestureRecognizer()..onTap = onExpand,
              ),
            ],
          ),
        );
      },
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
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 150,
                  width: double.infinity,
                  color: AppColors.skyBlue_100.withValues(alpha: 0.4),
                ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
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
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              if (price != null)
                Text(
                  price!,
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

class _CommentPreviewRow extends StatelessWidget {
  const _CommentPreviewRow({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/comment_icon.svg',
          width: 23,
          height: 23,
          colorFilter: const ColorFilter.mode(
            AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '${post.commentCount}',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        if (post.latestCommentText != null) ...[
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              post.latestCommentText!,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
