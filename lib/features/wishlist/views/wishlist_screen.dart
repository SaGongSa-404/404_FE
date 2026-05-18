import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:fe_app/shared/widgets/alarm/alarm_button.dart';
import 'package:fe_app/shared/widgets/alarm/alarm_panel.dart';
import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
import 'package:fe_app/shared/widgets/circle_icon_label.dart';
import 'package:fe_app/shared/widgets/loading_indicator.dart';
import 'package:fe_app/features/wishlist/views/components/form/wishlist_item_form_panel.dart';
import 'package:fe_app/features/wishlist/views/components/item/wishlist_item_card.dart';
import 'package:fe_app/features/wishlist/views/components/list/wishlist_category_filter.dart';
import 'package:fe_app/features/wishlist/views/components/list/wishlist_empty_view.dart';
import 'package:fe_app/features/wishlist/views/components/modals/wishlist_add_entry_modal.dart';
import 'package:fe_app/features/wishlist/views/components/modals/wishlist_share_modal.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  static const TextStyle _wishlistCountStyle = TextStyle(
    fontSize: 27,
    fontWeight: FontWeight.w600,
    color: AppColors.skyBlue_300,
  );
  static const TextStyle _wishlistTitleSuffixStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  Future<void> _openAddPanelFromClipboard(WidgetRef ref) async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final url = clipboard?.text?.trim() ?? '';
    ref.read(wishlistViewModelProvider.notifier).openAddPanelWithLink(url);
  }

  Future<void> _openAddEntryModal(BuildContext context, WidgetRef ref) async {
    await showWishlistAddEntryModal(
      context,
      onPasteUrl: () {
        _openAddPanelFromClipboard(ref);
      },
      onManualInput: () {
        ref.read(wishlistViewModelProvider.notifier).openAddPanel();
      },
      onLearnHow: () {
        context.push('/tutorial?restoreModal=1');
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final filteredItems = state.selectedCategories.contains('전체')
        ? state.items
        : state.items
        .where((item) => state.selectedCategories.contains(item.category))
        .toList();

    final editingItem = state.editingItemId == null
        ? null
        : state.items.where((item) => item.id == state.editingItemId).firstOrNull;

    if (state.isLoading) {
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 40,
                                            child: Center(
                                              child: Text(
                                                '${filteredItems.length}',
                                                style: _wishlistCountStyle,
                                                textHeightBehavior: const TextHeightBehavior(
                                                  applyHeightToFirstAscent: false,
                                                  applyHeightToLastDescent: false,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 1),
                                          SizedBox(
                                            height: 40,
                                            child: Center(
                                              child: Text(
                                                '개의 위시리스트',
                                                style: _wishlistTitleSuffixStyle,
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
                                      padding: const EdgeInsets.only(right: 8),
                                      child: AlarmButton(
                                        onPressed: () => context.push('/notifications'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: CategoryFilter(),
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
                                      : ListView.separated(
                                          physics: const BouncingScrollPhysics(
                                            parent: AlwaysScrollableScrollPhysics(),
                                          ),
                                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                                          itemCount: filteredItems.length,
                                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                                          itemBuilder: (context, index) {
                                            final item = filteredItems[index];
                                            return WishlistItemCard(
                                              item: item,
                                              onTap: () => context.push('/wishlist/consider'),
                                              onLongPress: () => {},
                                              onEdit: () => viewModel.openEditPanel(item.id),
                                              onDelete: () {
                                                if (context.mounted) {
                                                  showCapsuleToast(
                                                    context,
                                                    backgroundColor: const Color(0xFFD46868),
                                                    text: '삭제되었습니다',
                                                  );
                                                }
                                                viewModel.removeItem(item.id);
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
            onDelete: () => viewModel.removeItem(editingItem.id),
          )
        else if (state.isAddWishOpen)
          WishlistItemFormPanel.add(
            onClose: viewModel.closeEditPanel,
            onSubmit: viewModel.addItem,
            initialLink: state.addPrefillLink,
            linkReadOnly: state.isAddLinkReadOnly,
          ),
      ],
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}