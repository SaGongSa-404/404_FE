import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/views/components/confirm_modal.dart';
import 'package:fe_app/features/feed/providers/feed_provider.dart';
import 'package:fe_app/features/feed/views/components/comment_sheet.dart';
import 'package:fe_app/features/feed/views/components/feed_empty_view.dart';
import 'package:fe_app/features/feed/views/components/feed_post_card.dart';
import 'package:fe_app/features/feed/views/components/option_modal.dart';
import 'package:fe_app/features/feed/views/components/block_modal.dart';
import 'package:fe_app/features/feed/views/components/report_modal.dart';
import 'package:fe_app/features/feed/views/components/share_modal.dart';
import 'package:fe_app/shared/widgets/alarm/alarm_button.dart';
import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    final state = ref.watch(feedProvider);
    final vm = ref.read(feedProvider.notifier);

    SnackBar _buildSnackBar(String message, Color bgColor) {
      return SnackBar(
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
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(47),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: (26 * scale).clamp(20.0, 32.0),
          vertical: (19 * scale).clamp(15.0, 23.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: (24 * scale).clamp(18.0, 30.0),
          vertical: (9 * scale).clamp(7.0, 12.0),
        ),
        elevation: 6,
        duration: const Duration(seconds: 2),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: (30 * scale).clamp(24.0, 36.0),
        title: Text(
          '피드',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: (20 * scale).clamp(16.0, 24.0),
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          AlarmButton(onPressed: () => context.push('/notifications')),
          SizedBox(width: (8 * scale).clamp(6.0, 10.0)),
        ],
      ),
      body: Stack(
        children: [
          state.posts.isEmpty
              ? const FeedEmptyView()
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    (24 * scale).clamp(18.0, 30.0),
                    (16 * scale).clamp(12.0, 20.0),
                    (24 * scale).clamp(18.0, 30.0),
                    (100 * scale).clamp(80.0, 120.0),
                  ),
                  itemCount: state.posts.length,
                  separatorBuilder: (_, __) => SizedBox(height: (12 * scale).clamp(9.0, 15.0)),
                  itemBuilder: (context, index) {
                    final post = state.posts[index];
                    return FeedPostCard(
                      post: post,
                      isOptionActive: state.activeOptionPostId == post.id,
                      onVote: (vote) => vm.vote(post.id, vote),
                      onOptionTap: () async {
                        vm.setActiveOption(post.id);
                        final result = await showOptionModal(
                          context,
                          isMyPost: post.isMyPost,
                        );
                        vm.setActiveOption(null);
                        if (!context.mounted) return;
                        if (result == 'delete') {
                          final confirmed = await showConfirmBottomSheet(
                            context: context,
                            title: '작성한 게시글을\n정말 삭제하실 건가요?',
                            subtitle: '한 번 삭제된 게시글은 되돌릴 수 없어요',
                            actionLabel: '삭제하기',
                          );
                          if (confirmed == true && context.mounted) {
                            vm.deletePost(post.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              _buildSnackBar('삭제되었습니다',
                                  AppColors.red_600.withValues(alpha: 0.8)),
                            );
                          }
                        } else if (result == 'share') {
                          showShareModal(context: context, post: post);
                        } else if (result == 'edit') {
                          final editResult = await context
                              .push<String>('/feed/edit/${post.id}');
                          if (editResult == 'edited' && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              _buildSnackBar('수정되었습니다',
                                  AppColors.skyBlue_400.withValues(alpha: 0.8)),
                            );
                          }
                        } else if (result == 'report') {
                          final reported = await showReportModal(context);
                          if (reported && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              _buildSnackBar('신고가 완료되었습니다',
                                  AppColors.red_600.withValues(alpha: 0.8)),
                            );
                          }
                        } else if (result == 'block') {
                          final blocked = await showBlockModal(context);
                          if (blocked && context.mounted) {
                            vm.blockUser(post.authorName);
                            ScaffoldMessenger.of(context).showSnackBar(
                              _buildSnackBar('차단되었습니다',
                                  AppColors.red_600.withValues(alpha: 0.8)),
                            );
                          }
                        }
                      },
                      onCommentTap: () => showCommentSheet(
                        context: context,
                        postId: post.id,
                      ),
                      onCardTap: () => context.push('/feed/${post.id}'),
                    );
                  },
                ),
          Positioned(
            right: (16 * scale).clamp(12.0, 20.0),
            bottom: (16 * scale).clamp(12.0, 20.0),
            child: _WriteFab(
              onTap: () async {
                final posted = await context.push<bool>('/feed/write');
                if (posted == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    _buildSnackBar('게시글이 등록되었어요!',
                        AppColors.skyBlue_400.withValues(alpha: 0.8)),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

class _WriteFab extends StatefulWidget {
  const _WriteFab({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_WriteFab> createState() => _WriteFabState();
}

class _WriteFabState extends State<_WriteFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: SvgPicture.asset(
        _pressed
            ? 'assets/images/write_button_clicked.svg'
            : 'assets/images/write_button.svg',
        width: (72 * scale).clamp(58.0, 86.0),
        height: (72 * scale).clamp(58.0, 86.0),
      ),
    );
  }
}
