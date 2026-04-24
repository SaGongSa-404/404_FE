import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:fe_app/shared/widgets/alarm/alarm_button.dart';
import 'package:fe_app/shared/widgets/alarm/alarm_panel.dart';
import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';
import 'package:fe_app/shared/widgets/loading_indicator.dart';
import 'package:fe_app/features/wishlist/views/components/category_filter.dart';
import 'package:fe_app/features/wishlist/views/components/empty_wishlist_view.dart';
import 'package:fe_app/features/wishlist/views/components/wishlist_edit_panel.dart';
import 'package:fe_app/features/wishlist/views/components/wishlist_item_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wishlistViewModelProvider);
    final viewModel = ref.read(wishlistViewModelProvider.notifier);

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, top: 8),
                    child: AlarmButton(onPressed: viewModel.toggleAlarm),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '내 위시리스트',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${filteredItems.length}개',
                        style: const TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const CategoryFilter(),
                Expanded(
                  child: filteredItems.isEmpty
                      ? const EmptyWishlistView()
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    itemCount: filteredItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return WishlistItemCard(
                        item: item,
                        onTap: () {},
                        onLongPress: () => viewModel.openEditPanel(item.id),
                        onDelete: () => {},
                        onShare: () {},
                      );
                    },
                  ),
                ),
              ],
            ),
            if (state.isAlarmOpen) AlarmPanel(onClose: viewModel.toggleAlarm),
            if (editingItem != null)
              WishlistEditPanel(
                item: editingItem,
                onClose: viewModel.closeEditPanel,
                onSave: (updatedItem) {
                  viewModel.updateItem(updatedItem);
                  viewModel.closeEditPanel();
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}