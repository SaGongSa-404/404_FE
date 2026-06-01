import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:fe_app/shared/widgets/alarm/alarm_button.dart';
import 'package:fe_app/shared/widgets/alarm/alarm_panel.dart';
import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
import 'package:fe_app/shared/widgets/circle_icon_label.dart';
import 'package:fe_app/shared/widgets/loading_indicator.dart';
import 'package:fe_app/shared/widgets/nugul_loading_screen.dart';
import 'package:fe_app/features/wishlist/views/components/form/wishlist_item_form_panel.dart';
import 'package:fe_app/features/wishlist/views/components/item/wishlist_item_card.dart';
import 'package:fe_app/features/wishlist/views/components/list/wishlist_category_filter.dart';
import 'package:fe_app/features/wishlist/views/components/list/wishlist_empty_view.dart';
import 'package:fe_app/features/wishlist/views/components/modals/wishlist_add_entry_modal.dart';
import 'package:fe_app/features/wishlist/views/components/modals/wishlist_share_modal.dart';
import 'package:go_router/go_router.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(wishlistViewModelProvider.notifier).reloadOnScreenOpen();
    });
  }

  Future<void> _openAddEntryModal(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(wishlistViewModelProvider.notifier);
    await showWishlistAddEntryModal(
      context,
      onPasteUrl: viewModel.openAddPanelFromClipboard,
      onManualInput: viewModel.openAddPanel,
      onLearnHow: () => context.push('/tutorial?restoreModal=1'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final ref = this.ref;
    final state = ref.watch(wishlistViewModelProvider);
    final viewModel = ref.read(wishlistViewModelProvider.notifier);

    ref.listen<bool>(
      wishlistViewModelProvider.select((s) => s.reopenAddEntryModal),
      (prev, next) {
        if (next != true) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          viewModel.clearReopenAddEntryModal();
          _openAddEntryModal(context, ref);
        });
      },
    );

    ref.listen<String?>(
      wishlistViewModelProvider.select((s) => s.listErrorMessage),
      (prev, next) {
        if (next == null || next.isEmpty) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          viewModel.clearListError();
          showCapsuleToast(
            context,
            backgroundColor: const Color(0xFFD46868),
            text: next,
          );
        });
      },
    );

    ref.listen<String?>(
      wishlistViewModelProvider.select((s) => s.submitErrorMessage),
      (prev, next) {
        if (next == null || next.isEmpty) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          viewModel.clearSubmitError();
          showCapsuleToast(
            context,
            backgroundColor: const Color(0xFFD46868),
            text: next,
          );
        });
      },
    );

    ref.listen<bool>(
      wishlistViewModelProvider.select((s) => s.isImportingLink),
      (prev, next) {
        if (prev != true || next != false) return;
        final hasPrefill =
            ref.read(wishlistViewModelProvider).addFormPrefill != null;
        if (!hasPrefill) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          showCapsuleToast(
            context,
            backgroundColor: const Color(0xFF5F8EAE),
            text: '성공적으로 불러왔습니다.',
          );
        });
      },
    );

    ref.listen<bool>(
      wishlistViewModelProvider.select((s) => s.pendingImportFailedNavigation),
      (prev, next) {
        if (next != true) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          viewModel.clearPendingImportFailedNavigation();
          context.push('/wishlist/add-fetch-failed');
        });
      },
    );

    ref.listen<bool>(
      wishlistViewModelProvider.select((s) => s.showEmptyClipboardAlert),
      (prev, next) {
        if (next != true) return;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) return;
          viewModel.clearEmptyClipboardAlert();
          final dialogScale = responsiveScale(context);
          await showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(
                '링크를 붙여넣을 수 없어요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18 * dialogScale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              content: Text(
                '클립보드에 복사된 링크가 없어요.\n링크를 복사한 뒤 다시 시도해 주세요.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15 * dialogScale,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16 * dialogScale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.skyBlue_300,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );

    final filteredItems = state.selectedCategories.contains('전체')
        ? state.items
        : state.items
        .where((item) => state.selectedCategories.contains(item.category))
        .toList();

    final editingItem = state.editingItemId == null
        ? null
        : state.items.where((item) => item.id == state.editingItemId).firstOrNull;

    final showInitialLoading =
        state.isLoading && !state.isAddWishOpen && editingItem == null;

    if (showInitialLoading) {
      return const Scaffold(body: LoadingIndicator(message: '로딩 중...'));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: CircleIconLabel(
            backgroundColor: AppColors.skyBlue_100,
            pressedBackgroundColor: AppColors.skyBlue_200,
            icon: Icons.add,
            iconColor: AppColors.textPrimary,
            label: '위시추가',
            labelColor: AppColors.textPrimary,
            onTap: () => _openAddEntryModal(context, ref),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: Stack(
            fit: StackFit.expand,
            children: [
              SafeArea(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ColoredBox(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 8 * scale),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 16 * scale),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 40 * scale,
                                            child: Center(
                                              child: Text(
                                                '${filteredItems.length}',
                                                style: TextStyle(
                                                  fontSize: 27 * scale,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.skyBlue_300,
                                                ),
                                                textHeightBehavior: const TextHeightBehavior(
                                                  applyHeightToFirstAscent: false,
                                                  applyHeightToLastDescent: false,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 1 * scale),
                                          SizedBox(
                                            height: 40 * scale,
                                            child: Center(
                                              child: Text(
                                                '개의 위시리스트',
                                                style: TextStyle(
                                                  fontSize: 20 * scale,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                                textHeightBehavior: const TextHeightBehavior(
                                                  applyHeightToFirstAscent: false,
                                                  applyHeightToLastDescent: false,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 8 * scale),
                                      child: AlarmButton(
                                        onPressed: () => context.push('/notifications'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8 * scale),
                              Padding(
                                padding: EdgeInsets.only(bottom: 16 * scale),
                                child: const CategoryFilter(),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ColoredBox(
                            color: AppColors.background,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: filteredItems.isEmpty
                                      ? EmptyWishlistView(
                                          onLearnHow: () =>
                                              context.push('/tutorial'),
                                        )
                                      : NotificationListener<ScrollNotification>(
                                          onNotification: (notification) {
                                            if (notification.metrics.extentAfter > 200 * scale) {
                                              return false;
                                            }
                                            if (notification is! ScrollUpdateNotification &&
                                                notification is! ScrollEndNotification) {
                                              return false;
                                            }
                                            viewModel.loadMore();
                                            return false;
                                          },
                                          child: ListView.separated(
                                            physics: const BouncingScrollPhysics(
                                              parent: AlwaysScrollableScrollPhysics(),
                                            ),
                                            padding: EdgeInsets.fromLTRB(24 * scale, 20 * scale, 24 * scale, 20 * scale),
                                            itemCount: filteredItems.length +
                                                (state.isLoadingMore ? 1 : 0),
                                            separatorBuilder: (context, index) =>
                                                SizedBox(height: 12 * scale),
                                            itemBuilder: (context, index) {
                                              if (index >= filteredItems.length) {
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 16 * scale),
                                                  child: Center(
                                                    child: SizedBox(
                                                      width: 24 * scale,
                                                      height: 24 * scale,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2 * scale,
                                                        color: AppColors.skyBlue_300,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              final item = filteredItems[index];
                                              return WishlistItemCard(
                                                item: item,
                                                onTap: () {
                                                  if (!item.canOpenDeliberation) {
                                                    showCapsuleToast(
                                                      context,
                                                      backgroundColor:
                                                          const Color(0xFFD46868),
                                                      text:
                                                          '이미 결정된 상품은 숙려 화면을 다시 열 수 없어요.',
                                                    );
                                                    return;
                                                  }
                                                  context.push(
                                                    '/wishlist/consider/${item.id}',
                                                  );
                                                },
                                                onLongPress: () => {},
                                                onEdit: () => viewModel.openEditPanel(item.id),
                                                onDelete: () async {
                                                  final ok =
                                                      await viewModel.dropItem(item.id);
                                                  if (!context.mounted || !ok) return;
                                                  showCapsuleToast(
                                                    context,
                                                    backgroundColor: const Color(0xFFD46868),
                                                    text: '삭제되었습니다',
                                                  );
                                                },
                                                onShare: () {
                                                  showWishlistShareToFeedModal(
                                                    context,
                                                    onConfirm: () {
                                                      if (!context.mounted) return;
                                                      showCapsuleToast(
                                                        context,
                                                        backgroundColor: const Color(0xFF5F8EAE),
                                                        text: '피드에 공유되었습니다',
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (state.isAlarmOpen) AlarmPanel(onClose: viewModel.toggleAlarm),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: const AppBottomNavigationBar(),
        ),
        if (editingItem != null)
          WishlistItemFormPanel.edit(
            item: editingItem,
            onClose: viewModel.closeEditPanel,
            onSubmit: viewModel.updateItem,
            isSubmitting: state.isSubmitting,
            onDelete: () async {
              final ok = await viewModel.dropItem(editingItem.id);
              if (ok && context.mounted) {
                showCapsuleToast(
                  context,
                  backgroundColor: const Color(0xFFD46868),
                  text: '삭제되었습니다',
                );
              }
              return ok;
            },
          )
        else if (state.isAddWishOpen && !state.isImportingLink)
          WishlistItemFormPanel.add(
            onClose: viewModel.closeEditPanel,
            onSubmit: (item) async {
              final ok = await viewModel.addItem(item);
              if (ok && context.mounted) {
                showCapsuleToast(
                  context,
                  backgroundColor: const Color(0xFF5F8EAE),
                  text: '솜사탕이 생겼어요!',
                );
              }
              return ok;
            },
            initialLink: state.addPrefillLink,
            formPrefill: state.addFormPrefill,
            linkReadOnly: state.isAddLinkReadOnly,
            isImporting: state.isImportingLink,
            isSubmitting: state.isSubmitting,
          ),
        if (state.isImportingLink)
          const Positioned.fill(child: NugulLoadingScreen()),
      ],
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}