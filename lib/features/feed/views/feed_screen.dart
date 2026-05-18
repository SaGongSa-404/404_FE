import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/views/components/confirm_modal.dart';
import 'package:fe_app/features/feed/providers/feed_provider.dart';
import 'package:fe_app/features/feed/views/components/comment_sheet.dart';
import 'package:fe_app/features/feed/views/components/feed_empty_view.dart';
import 'package:fe_app/features/feed/views/components/feed_post_card.dart';
import 'package:fe_app/features/feed/views/components/option_modal.dart';
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
    final state = ref.watch(feedProvider);
    final vm = ref.read(feedProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 30,
        title: const Text(
          '피드',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          AlarmButton(onPressed: () => context.push('/notifications')),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          state.posts.isEmpty
              ? const FeedEmptyView()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                  itemCount: state.posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = state.posts[index];
                    return FeedPostCard(
                      post: post,
                      isOptionActive: state.activeOptionPostId == post.id,
                      onVote: (vote) => vm.vote(post.id, vote),
                      onOptionTap: () async {
                        vm.setActiveOption(post.id);
                        final result = await showOptionModal(context);
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
                              SnackBar(
                                content: const Text(
                                  '삭제되었습니다',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor:
                                    AppColors.red_600.withValues(alpha: 0.8),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(47),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 26, vertical: 19),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 9),
                                elevation: 6,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } else if (result == 'share') {
                          showShareModal(context: context, post: post);
                        } else if (result == 'edit') {
                          final editResult = await context
                              .push<String>('/feed/edit/${post.id}');
                          if (editResult == 'edited' && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  '수정되었습니다',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor:
                                    AppColors.skyBlue_400.withValues(alpha: 0.8),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(47),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 26, vertical: 19),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 9),
                                elevation: 6,
                                duration: const Duration(seconds: 2),
                              ),
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
            right: 16,
            bottom: 16,
            child: _WriteFab(
              onTap: () async {
                final posted = await context.push<bool>('/feed/write');
                if (posted == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        '게시글이 등록되었어요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor:
                          AppColors.skyBlue_400.withValues(alpha: 0.8),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(47),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 19),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 9),
                      elevation: 6,
                      duration: const Duration(seconds: 2),
                    ),
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
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: SvgPicture.asset(
        _pressed
            ? 'assets/images/write_button_clicked.svg'
            : 'assets/images/write_button.svg',
        width: 72,
        height: 72,
      ),
    );
  }
}
