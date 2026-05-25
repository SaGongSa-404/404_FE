import 'dart:async';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/views/components/block_modal.dart';
import 'package:fe_app/features/feed/views/components/comment_option_modal.dart';
import 'package:fe_app/features/feed/views/components/report_modal.dart';
import 'package:fe_app/features/feed/models/feed_comment.dart';
import 'package:fe_app/features/feed/providers/feed_provider.dart';
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
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCommentOption(String commentId, bool isMyComment) async {
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
      if (blocked) _triggerToast('차단되었습니다');
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
    final comments = feedState.commentsMap[widget.postId] ?? [];
    final scale = MediaQuery.of(context).size.width / 412.0;
    final topPad = (80.0 * scale).clamp(60.0, 100.0);

    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 23, 24, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        'assets/images/close.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '댓글 ${comments.length}',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(24, topPad, 24, 16),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 26),
                  itemBuilder: (_, index) => _CommentItem(
                    comment: comments[index],
                    onOption: () => _handleCommentOption(
                      comments[index].id,
                      comments[index].isMyComment,
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _toastMessage != null
                    ? Padding(
                        key: const ValueKey('toast'),
                        padding: const EdgeInsets.fromLTRB(26, 0, 26, 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 9),
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
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('no-toast')),
              ),
              _CommentInput(
                onSubmit: (text) => vm.addComment(widget.postId, text),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentItem extends StatefulWidget {
  const _CommentItem({
    required this.comment,
    required this.onOption,
  });

  final FeedComment comment;
  final VoidCallback onOption;

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  bool _optionPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.grey_200,
            borderRadius: BorderRadius.circular(9),
          ),
          clipBehavior: Clip.antiAlias,
          child: SvgPicture.asset(
            'assets/images/user_profile.svg',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.comment.authorName,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.comment.createdAt,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: AppColors.textDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                widget.comment.content,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: AppColors.textDark,
                  height: 1.5,
                ),
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
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(28, 19, 28, MediaQuery.of(context).padding.bottom + 19),
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
                          width: (38 * scale).clamp(32.0, 44.0),
                          height: (38 * scale).clamp(32.0, 44.0),
                          decoration: BoxDecoration(
                            color: AppColors.skyBlue_100,
                            borderRadius: BorderRadius.circular((19 * scale).clamp(16.0, 22.0)),
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            _uploadPressed
                                ? 'assets/images/comment_upload_clicked.svg'
                                : 'assets/images/comment_upload.svg',
                            width: (20 * scale).clamp(16.0, 24.0),
                            height: (20 * scale).clamp(16.0, 24.0),
                          ),
                        ),
                      ),
                    )
                  : Opacity(
                      key: const ValueKey('send'),
                      opacity: 0.3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.send_rounded,
                          size: (22 * scale).clamp(18.0, 26.0),
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
