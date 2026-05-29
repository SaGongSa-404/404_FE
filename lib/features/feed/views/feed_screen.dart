import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/providers/feed_provider.dart';
import 'package:fe_app/features/feed/viewmodels/feed_state.dart';
import 'package:fe_app/features/feed/viewmodels/feed_viewmodel.dart';
import 'package:fe_app/features/feed/views/components/block_modal.dart';
import 'package:fe_app/features/feed/views/components/comment_sheet.dart';
import 'package:fe_app/features/feed/views/components/confirm_modal.dart';
import 'package:fe_app/features/feed/views/components/feed_empty_view.dart';
import 'package:fe_app/features/feed/views/components/feed_post_card.dart';
import 'package:fe_app/features/feed/views/components/option_modal.dart';
import 'package:fe_app/features/feed/views/components/report_modal.dart';
import 'package:fe_app/features/feed/views/components/share_modal.dart';
import 'package:fe_app/shared/widgets/alarm/alarm_button.dart';
import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedProvider.notifier).loadInitial();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  SnackBar _buildSnackBar(BuildContext context, String message, Color bgColor) {
    final scale = MediaQuery.of(context).size.width / 412.0;
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

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    final state = ref.watch(feedProvider);
    final vm = ref.read(feedProvider.notifier);

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
          _buildBody(context, state, vm, scale),
          Positioned(
            right: (16 * scale).clamp(12.0, 20.0),
            bottom: (16 * scale).clamp(12.0, 20.0),
            child: _WriteFab(
              onTap: () async {
                final posted = await context.push<bool>('/feed/write');
                if (posted == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    _buildSnackBar(context, '게시글이 등록되었어요!',
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

  Widget _buildBody(BuildContext context, FeedState state, FeedViewModel vm,
      double scale) {
    if (state.isLoading && state.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: (16 * scale).clamp(13.0, 19.0),
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: (16 * scale).clamp(12.0, 20.0)),
            TextButton(
              onPressed: () => vm.refresh(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }
    if (state.posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => vm.refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 120), FeedEmptyView()],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.refresh(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          (24 * scale).clamp(18.0, 30.0),
          (16 * scale).clamp(12.0, 20.0),
          (24 * scale).clamp(18.0, 30.0),
          (100 * scale).clamp(80.0, 120.0),
        ),
        itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            SizedBox(height: (12 * scale).clamp(9.0, 15.0)),
        itemBuilder: (context, index) {
          if (index >= state.posts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final post = state.posts[index];
          return FeedPostCard(
            post: post,
            isOptionActive: state.activeOptionPostId == post.id,
            onVote: (vote) => vm.vote(post.id, vote),
            onOptionTap: () => _onOptionTap(context, vm, post),
            onCommentTap: () => showCommentSheet(
              context: context,
              postId: post.id,
            ),
            onCardTap: () => context.push('/feed/${post.id}'),
          );
        },
      ),
    );
  }

  Future<void> _onOptionTap(
      BuildContext context, FeedViewModel vm, FeedPost post) async {
    vm.setActiveOption(post.id);
    final result = await showOptionModal(
      context,
      isMyPost: post.mine,
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
        final ok = await vm.deletePost(post.id);
        if (ok && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            _buildSnackBar(context, '삭제되었습니다',
                AppColors.red_600.withValues(alpha: 0.8)),
          );
        }
      }
    } else if (result == 'share') {
      showShareModal(context: context, post: post);
    } else if (result == 'edit') {
      final editResult = await context.push<String>('/feed/edit/${post.id}');
      if (editResult == 'edited' && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar(context, '수정되었습니다',
              AppColors.skyBlue_400.withValues(alpha: 0.8)),
        );
      }
    } else if (result == 'report') {
      final reported = await showReportModal(context);
      if (reported && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar(context, '신고가 완료되었습니다',
              AppColors.red_600.withValues(alpha: 0.8)),
        );
      }
    } else if (result == 'block') {
      final blocked = await showBlockModal(context);
      if (blocked && context.mounted) {
        vm.blockUser(post.authorNickname);
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar(context, '차단되었습니다',
              AppColors.red_600.withValues(alpha: 0.8)),
        );
      }
    }
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
