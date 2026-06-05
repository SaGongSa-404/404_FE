import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/models/vote_type.dart';
import 'package:fe_app/features/feed/utils/feed_date_formatter.dart';
import 'package:fe_app/features/feed/views/components/product_link_dialog.dart';
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
    required this.onBlockedVote,
    required this.onOptionTap,
    required this.onCommentTap,
    required this.onCardTap,
  });

  final FeedPost post;
  final bool isOptionActive;
  final ValueChanged<VoteType> onVote;
  final VoidCallback onBlockedVote;
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
    final scale = MediaQuery.of(context).size.width / 412.0;

    return GestureDetector(
      onTap: widget.onCardTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular((22 * scale).clamp(17.0, 27.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 3,
            ),
          ],
        ),
        padding: EdgeInsets.all((16 * scale).clamp(13.0, 19.0)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/images/user_profile.svg',
              width: (33 * scale).clamp(26.0, 40.0),
              height: (35 * scale).clamp(28.0, 42.0),
            ),
            SizedBox(width: (8 * scale).clamp(6.0, 10.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PostHeader(
                    post: post,
                    isOptionActive: widget.isOptionActive,
                    onOptionTap: widget.onOptionTap,
                  ),
                  // 글이 없는(위시리스트만 있는) 게시글은 본문 영역을 그리지 않습니다.
                  if ((post.body?.trim().isNotEmpty ?? false)) ...[
                    SizedBox(height: (7 * scale).clamp(5.0, 9.0)),
                    _ExpandableText(
                      text: post.body!,
                      isExpanded: _isExpanded,
                      onExpand: () => setState(() => _isExpanded = true),
                    ),
                  ],
                  SizedBox(height: (16 * scale).clamp(12.0, 20.0)),
                  if (post.product != null) ...[
                    _ProductCard(
                      name: post.product!.name,
                      price: post.product!.price,
                      imageUrl: post.imageUrl ?? post.product!.imageUrl,
                      link: post.product!.link,
                    ),
                    SizedBox(height: (15 * scale).clamp(12.0, 18.0)),
                  ],
                  GestureDetector(
                    onTap: () {},
                    behavior: HitTestBehavior.opaque,
                    child: VoteButtons(
                      myVote: post.myVote,
                      goCount: post.goCount,
                      stopCount: post.stopCount,
                      onVote: widget.onVote,
                      isDisabled: post.mine,
                      onDisabledTap: widget.onBlockedVote,
                    ),
                  ),
                  SizedBox(height: (6 * scale).clamp(4.0, 8.0)),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
                  SizedBox(height: (6 * scale).clamp(4.0, 8.0)),
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

class _PostHeader extends StatefulWidget {
  const _PostHeader({
    required this.post,
    required this.isOptionActive,
    required this.onOptionTap,
  });

  final FeedPost post;
  final bool isOptionActive;
  final VoidCallback onOptionTap;

  @override
  State<_PostHeader> createState() => _PostHeaderState();
}

class _PostHeaderState extends State<_PostHeader> {
  bool _optionPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    return Row(
      children: [
        Text(
          widget.post.authorNickname,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: (15 * scale).clamp(12.0, 18.0),
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: (10 * scale).clamp(8.0, 12.0)),
        Expanded(
          child: Text(
            formatFeedTimestamp(widget.post.createdAt),
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              fontSize: (15 * scale).clamp(12.0, 18.0),
              color: AppColors.textDate,
            ),
          ),
        ),
        GestureDetector(
          onTapDown: (_) => setState(() => _optionPressed = true),
          onTapUp: (_) {
            setState(() => _optionPressed = false);
            widget.onOptionTap();
          },
          onTapCancel: () => setState(() => _optionPressed = false),
          child: Padding(
            padding: EdgeInsets.only(left: (8 * scale).clamp(6.0, 10.0)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: (38 * scale).clamp(32.0, 44.0),
              height: (38 * scale).clamp(32.0, 44.0),
              decoration: BoxDecoration(
                color: _optionPressed ? AppColors.grey_300 : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                widget.isOptionActive
                    ? 'assets/images/option_clicked.svg'
                    : 'assets/images/option.svg',
                width: (28 * scale).clamp(24.0, 32.0),
                height: (28 * scale).clamp(24.0, 32.0),
              ),
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

  TextStyle _contentStyle(double scale) => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        fontSize: (17 * scale).clamp(14.0, 20.0),
        color: AppColors.textDark,
        height: 1.3,
      );

  TextStyle _moreStyle(double scale) => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        fontSize: (18 * scale).clamp(14.0, 22.0),
        color: AppColors.textPrimary,
        height: 1.3,
      );

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    final contentStyle = _contentStyle(scale);
    final moreStyle = _moreStyle(scale);

    if (isExpanded) {
      return Text(text, style: contentStyle);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tp = TextPainter(
          text: TextSpan(text: text, style: contentStyle),
          maxLines: 3,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        if (!tp.didExceedMaxLines) {
          return Text(text, style: contentStyle);
        }

        const moreText = '  더보기';
        final moreTp = TextPainter(
          text: TextSpan(text: moreText, style: moreStyle),
          textDirection: TextDirection.ltr,
        )..layout();

        final cutPosition = tp.getPositionForOffset(
          Offset(constraints.maxWidth - moreTp.width, tp.height - 1),
        );
        final truncated = text.substring(0, cutPosition.offset);

        return RichText(
          text: TextSpan(
            style: contentStyle,
            children: [
              TextSpan(text: truncated),
              TextSpan(
                text: moreText,
                style: moreStyle,
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
    this.link,
  });

  final String name;
  final int? price;
  final String? imageUrl;
  final String? link;

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
    return GestureDetector(
      // 카드 탭(상세 진입)보다 우선 — 상세 화면과 동일하게 링크 이동 처리
      behavior: HitTestBehavior.opaque,
      onTap: () => openProductLink(context: context, url: link),
      child: Column(
        children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular((22 * scale).clamp(17.0, 27.0))),
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
                bottom: Radius.circular((22 * scale).clamp(17.0, 27.0))),
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
      ),
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

class _CommentPreviewRow extends StatelessWidget {
  const _CommentPreviewRow({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/comment_icon.svg',
          width: (23 * scale).clamp(18.0, 28.0),
          height: (23 * scale).clamp(18.0, 28.0),
          colorFilter: const ColorFilter.mode(
            AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: (3 * scale).clamp(2.0, 4.0)),
        Text(
          '${post.commentCount}',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: (16 * scale).clamp(13.0, 19.0),
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
