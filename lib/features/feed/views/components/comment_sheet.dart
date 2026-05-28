import 'dart:async';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/views/components/block_modal.dart';
import 'package:fe_app/features/feed/views/components/comment_option_modal.dart';
import 'package:fe_app/features/feed/views/components/report_modal.dart';
import 'package:fe_app/features/feed/models/feed_comment.dart';
import 'package:fe_app/features/feed/providers/feed_provider.dart';
import 'package:fe_app/features/feed/utils/feed_date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

void showCommentSheet({
  required BuildContext context,
  required String postId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder: (_) => _CommentSheetContent(postId: postId),
  );
}

class _CommentSheetContent extends ConsumerStatefulWidget {
  const _CommentSheetContent({required this.postId});

  final String postId;

  @override
  ConsumerState<_CommentSheetContent> createState() =>
      _CommentSheetContentState();
}

class _CommentSheetContentState extends ConsumerState<_CommentSheetContent> {
  String? _toastMessage;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedProvider.notifier).loadComments(widget.postId, refresh: true);
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMoreComments(widget.postId);
    }
    return false;
  }

  Future<void> _handleCommentOption(String commentId, bool isMyComment, String authorNickname) async {
    final result = await showCommentOptionModal(context, isMyComment: isMyComment);
    if (!mounted) return;
    if (result == 'delete') {
      ref.read(feedProvider.notifier).deleteComment(widget.postId, commentId);
      _triggerToast('삭제되었습니다');
    } else if (result == 'report') {
      final reported = await showReportModal(context);
      if (!mounted) return;
      if (reported) _triggerToast('신고가 완료되었습니다');
    } else if (result == 'block') {
      final blocked = await showBlockModal(context);
      if (!mounted) return;
      if (blocked) {
        ref.read(feedProvider.notifier).blockUser(authorNickname);
        _triggerToast('차단되었습니다');
      }
    }
  }

  void _triggerToast(String message) {
    setState(() => _toastMessage = message);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final vm = ref.read(feedProvider.notifier);
    final commentsPage = feedState.commentsMap[widget.postId];
    final comments = commentsPage?.items ?? const <FeedComment>[];
    final commentTotal = commentsPage?.total ?? 0;
    final isLoading = commentsPage?.isLoading ?? false;
    final scale = MediaQuery.of(context).size.width / 412.0;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          snap: true,
          builder: (sheetContext, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      (24 * scale).clamp(18.0, 30.0),
                      (23 * scale).clamp(17.0, 29.0),
                      (24 * scale).clamp(18.0, 30.0),
                      0,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(sheetContext).pop(),
                          child: SvgPicture.asset(
                            'assets/images/close.svg',
                            width: (14 * scale).clamp(11.0, 17.0),
                            height: (14 * scale).clamp(11.0, 17.0),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '댓글 $commentTotal',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                fontSize: (20 * scale).clamp(16.0, 24.0),
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: (14 * scale).clamp(11.0, 17.0)),
                      ],
                    ),
                  ),
                  SizedBox(height: (30 * scale).clamp(22.0, 38.0)),
                  Expanded(
                    child: comments.isEmpty && isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : NotificationListener<ScrollNotification>(
                            onNotification: _onScrollNotification,
                            child: ListView.separated(
                              controller: scrollController,
                              padding: EdgeInsets.symmetric(
                                horizontal: (24 * scale).clamp(18.0, 30.0),
                              ),
                              itemCount: comments.length +
                                  (isLoading && comments.isNotEmpty ? 1 : 0),
                              separatorBuilder: (_, __) => SizedBox(
                                  height: (26 * scale).clamp(20.0, 32.0)),
                              itemBuilder: (_, index) {
                                if (index >= comments.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                return _CommentItem(
                                  comment: comments[index],
                                  onOption: () => _handleCommentOption(
                                    comments[index].id,
                                    comments[index].mine,
                                    comments[index].authorNickname,
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  _CommentInput(
                    onSubmit: (text) => vm.addComment(widget.postId, text),
                  ),
                ],
              ),
            );
          },
        ),
        Positioned(
          bottom: (134 * scale).clamp(100.0, 168.0),
          left: (26 * scale).clamp(20.0, 32.0),
          right: (26 * scale).clamp(20.0, 32.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _toastMessage != null
                ? Container(
                    key: const ValueKey('toast'),
                    padding: EdgeInsets.symmetric(
                      horizontal: (24 * scale).clamp(18.0, 30.0),
                      vertical: (9 * scale).clamp(7.0, 12.0),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.red_600.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(47),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _toastMessage!,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: (18 * scale).clamp(14.0, 22.0),
                        color: AppColors.white,
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no-toast')),
          ),
        ),
      ],
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({
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
        Container(
          width: (18 * scale).clamp(14.0, 22.0),
          height: (18 * scale).clamp(14.0, 22.0),
          decoration: BoxDecoration(
            color: AppColors.grey_200,
            borderRadius: BorderRadius.circular((9 * scale).clamp(7.0, 11.0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: SvgPicture.asset(
            'assets/images/user_profile.svg',
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: (7 * scale).clamp(5.0, 9.0)),
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
                  fontSize: (18 * scale).clamp(14.0, 22.0),
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
              width: (20.0 * scale).clamp(16.0, 24.0),
              height: (20.0 * scale).clamp(16.0, 24.0),
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentInput extends StatefulWidget {
  const _CommentInput({required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
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
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final iconSize = (54 * scale).clamp(43.0, 65.0);
    final iconRight = (16 * scale).clamp(12.0, 20.0);

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        (26 * scale).clamp(20.0, 32.0),
        (19 * scale).clamp(14.0, 24.0),
        (26 * scale).clamp(20.0, 32.0),
        safeBottom + (19 * scale).clamp(14.0, 24.0),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              (28 * scale).clamp(22.0, 34.0),
              (26 * scale).clamp(20.0, 32.0),
              (iconSize + iconRight + (8 * scale).clamp(6.0, 10.0)),
              (26 * scale).clamp(20.0, 32.0),
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                  (59 * scale).clamp(47.0, 72.0)),
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
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }
}
