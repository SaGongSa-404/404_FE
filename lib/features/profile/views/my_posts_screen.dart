import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/views/components/comment_sheet.dart';
import 'package:fe_app/features/feed/views/components/confirm_modal.dart';
import 'package:fe_app/features/feed/views/components/deleted_post_modal.dart';
import 'package:fe_app/features/feed/views/components/feed_post_card.dart';
import 'package:fe_app/features/feed/views/components/option_modal.dart';
import 'package:fe_app/features/profile/providers/my_posts_provider.dart';
import 'package:fe_app/features/profile/viewmodels/my_posts_state.dart';
import 'package:fe_app/features/profile/viewmodels/my_posts_viewmodel.dart';
import 'package:fe_app/shared/widgets/loading_indicator.dart';
import 'package:fe_app/shared/widgets/nugul_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyPostsScreen extends ConsumerStatefulWidget {
  const MyPostsScreen({super.key});

  static const Color _backgroundColor = Color(0xFFF5F5F5);

  @override
  ConsumerState<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends ConsumerState<MyPostsScreen> {
  final _scrollController = ScrollController();
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myPostsProvider.notifier).refresh();
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
      ref.read(myPostsProvider.notifier).loadMore();
    }
  }

  SnackBar _buildSnackBar(BuildContext context, String message, Color bgColor) {
    final scale = responsiveScale(context);
    return SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16 * scale,
          color: Colors.white,
        ),
      ),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(47)),
      margin: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 16 * scale),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final state = ref.watch(myPostsProvider);
    final vm = ref.read(myPostsProvider.notifier);

    return Scaffold(
      backgroundColor: MyPostsScreen._backgroundColor,
      appBar: AppBar(
        backgroundColor: MyPostsScreen._backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.brown,
            size: 18 * scale,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '나의 게시글',
          style: TextStyle(
            fontSize: 18 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.brown,
          ),
        ),
      ),
      body: SafeArea(child: _buildBody(context, state, vm, scale)),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MyPostsState state,
    MyPostsViewModel vm,
    double scale,
  ) {
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
                fontSize: 16 * scale,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16 * scale),
            TextButton(onPressed: () => vm.refresh(), child: const Text('다시 시도')),
          ],
        ),
      );
    }
    if (state.posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => vm.refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: _MyPostsEmptyView(scale: scale),
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.refresh(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(24 * scale, 16 * scale, 24 * scale, 24 * scale),
        itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
        itemBuilder: (context, index) {
          if (index >= state.posts.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 24 * scale),
              child: const Center(child: LoadingIndicator(compact: true)),
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
            onCommentTap: () => showCommentSheet(context: context, postId: post.id),
            onCardTap: () => _openPost(context, vm, post.id),
          );
        },
      ),
    );
  }

  /// 상세 진입 전 삭제(404) 여부를 확인하고, 삭제된 글이면 진입 대신 안내 모달을 띄웁니다.
  Future<void> _openPost(
      BuildContext context, MyPostsViewModel vm, String postId) async {
    if (_opening) return;
    _opening = true;
    try {
      final deleted = await vm.checkDeletedAndRemove(postId);
      if (!context.mounted) return;
      if (deleted) {
        await showDeletedPostModal(context);
        return;
      }
      if (context.mounted) context.push('/feed/$postId');
    } finally {
      _opening = false;
    }
  }

  Future<void> _onOptionTap(
    BuildContext context,
    MyPostsViewModel vm,
    FeedPost post,
  ) async {
    vm.setActiveOption(post.id);
    final result = await showOptionModal(context, isMyPost: true);
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
            _buildSnackBar(
              context,
              '삭제되었습니다',
              AppColors.red_600.withValues(alpha: 0.8),
            ),
          );
        }
      }
    } else if (result == 'edit') {
      final editResult = await context.push<String>('/feed/edit/${post.id}');
      if (editResult == 'edited' && context.mounted) {
        await vm.refresh();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            _buildSnackBar(
              context,
              '수정되었습니다',
              AppColors.skyBlue_400.withValues(alpha: 0.8),
            ),
          );
        }
      }
    }
  }
}

class _MyPostsEmptyView extends StatelessWidget {
  const _MyPostsEmptyView({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/nugul_empty.png',
          width: 150 * scale,
          height: 150 * scale,
        ),
        SizedBox(height: 24 * scale),
        Text(
          '아직 작성한 게시글이 없어요!',
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12 * scale),
        Text(
          '커뮤니티에서 다른 너구리들과\n함께 소통하며 현명한 소비를 해봐요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14 * scale,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
