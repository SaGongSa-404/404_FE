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
            // 레이어 1: 메인 UI 구성
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // [1단] 알람 버튼
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, top: 8),
                    child: AlarmButton(onPressed: viewModel.toggleAlarm),
                  ),
                ),

                // [2단] 타이틀 영역
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '내 위시리스트',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${filteredItems.length}개',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // [3단] 카테고리 필터
                const CategoryFilter(),

                // [4단] 나머지 위시리스트 목록 영역
                Expanded(
                  child: filteredItems.isEmpty
                      ? const EmptyWishlistView()
                      : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                              itemCount: filteredItems.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) => WishlistItemCard(
                                item: filteredItems[index],
                                onTap: () => viewModel.openEditPanel(filteredItems[index].id),
                              ),
                            ),
                ),
              ],
            ),

            // 레이어 2: 알림 패널
            if (state.isAlarmOpen)
              AlarmPanel(onClose: viewModel.toggleAlarm),
            if (editingItem != null)
              WishlistEditPanel(
                item: editingItem,
                onClose: viewModel.closeEditPanel,
                onSave: viewModel.updateItem,
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }
    return first;
  }
}