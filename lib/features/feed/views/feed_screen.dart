import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/providers/feed_provider.dart';
import 'package:fe_app/features/feed/viewmodels/feed_state.dart';
import 'package:fe_app/features/feed/viewmodels/feed_viewmodel.dart';
import 'package:fe_app/features/feed/views/components/block_modal.dart';
import 'package:fe_app/features/feed/views/components/comment_sheet.dart';
import 'package:fe_app/features/feed/views/components/confirm_modal.dart';
import 'package:fe_app/features/feed/views/components/deleted_post_modal.dart';
import 'package:fe_app/features/feed/views/components/feed_empty_view.dart';
import 'package:fe_app/features/feed/views/components/feed_post_card.dart';
import 'package:fe_app/features/feed/views/components/option_modal.dart';
import 'package:fe_app/features/feed/views/components/report_modal.dart';
import 'package:fe_app/features/feed/views/components/share_modal.dart';
import 'package:fe_app/features/notification/utils/notification_navigation.dart';
import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';
import 'package:fe_app/shared/widgets/circle_icon_label.dart';
import 'package:fe_app/shared/widgets/loading_indicator.dart';
import 'package:fe_app/shared/widgets/main_tab_header.dart';
import 'package:fe_app/shared/widgets/nugul_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();
  bool _opening = false;

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
    final scale = responsiveScale(context);
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
    final scale = responsiveScale(context);
    final state = ref.watch(feedProvider);
    final vm = ref.read(feedProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: CircleIconLabel(
        backgroundColor: AppColors.skyBlue_100,
        pressedBackgroundColor: AppColors.skyBlue_200,
        icon: Icons.edit_outlined,
        iconColor: AppColors.textPrimary,
        label: '글쓰기',
        labelColor: AppColors.textPrimary,
        onTap: () async {
          final posted = await context.push<bool>('/feed/write');
          if (posted == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              _buildSnackBar(
                context,
                '게시글이 등록되었어요!',
                AppColors.skyBlue_400.withValues(alpha: 0.8),
              ),
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainTabHeader(
              backgroundColor: AppColors.white,
              leading: MainTabHeader.tabTitle('피드', scale),
              onAlarmPressed: () => openNotificationsPage(ref, context),
            ),
            Expanded(child: _buildBody(context, state, vm, scale)),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  Widget _buildBody(BuildContext context, FeedState state, FeedViewModel vm,
      double scale) {
    if (state.isLoading && state.posts.isEmpty) {
      return const NugulLoadingScreen();
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
          24 * scale,
          16 * scale,
          24 * scale,
          96 * scale,
        ),
        itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            SizedBox(height: (12 * scale).clamp(9.0, 15.0)),
        itemBuilder: (context, index) {
          if (index >= state.posts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: LoadingIndicator(compact: true),
            );
          }
          final post = state.posts[index];
          return FeedPostCard(
            post: post,
            isOptionActive: state.activeOptionPostId == post.id,
            onVote: (vote) => vm.vote(post.id, vote),
            onBlockedVote: () => ScaffoldMessenger.of(context).showSnackBar(
              _buildSnackBar(context, '본인 게시글은 투표할 수 없습니다',
                  AppColors.red_600.withValues(alpha: 0.8)),
            ),
            onOptionTap: () => _onOptionTap(context, vm, post),
            onCommentTap: () => showCommentSheet(
              context: context,
              postId: post.id,
            ),
            onCardTap: () => _openPost(context, vm, post.id),
          );
        },
      ),
    );
  }

  /// 상세 진입 전 삭제(404) 여부를 확인하고, 삭제된 글이면 진입 대신 안내 모달을 띄웁니다.
  Future<void> _openPost(
      BuildContext context, FeedViewModel vm, String postId) async {
    if (_opening) return;
    _opening = true;
    try {
      final deleted = await vm.refreshPost(postId);
      if (!context.mounted) return;
      if (deleted) {
        vm.removePost(postId);
        await showDeletedPostModal(context);
        return;
      }
      if (context.mounted) context.push('/feed/$postId');
    } finally {
      _opening = false;
    }
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
      final submission = await showReportModal(context);
      if (submission == null || !context.mounted) return;
      final ok = await vm.reportPost(
        post.id,
        category: submission.category.serverValue,
        reason: submission.reason,
      );
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar(context, '신고가 완료되었습니다',
              AppColors.red_600.withValues(alpha: 0.8)),
        );
      }
    } else if (result == 'block') {
      final blocked = await showBlockModal(context);
      if (!blocked || !context.mounted) return;
      final ok = await vm.blockUser(authorUserId: post.authorUserId);
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar(context, '차단되었습니다',
              AppColors.red_600.withValues(alpha: 0.8)),
        );
      }
    }
  }
}
