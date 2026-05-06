import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'wishlist_state.dart';

const List<String> categories = ['전체', '패션', '뷰티', '라이프', '디지털', '기타'];
const List<WishlistPlaceholder> mockWishlistItems = [
  WishlistPlaceholder(
    id: 'w-1',
    title: 'PWC PIBBED EVERYDAY SHORT SLEEVE TEE',
    price: 29000,
    category: '패션',
    link: 'musinsa.com/app/goods/hoodie',
  ),
  WishlistPlaceholder(
    id: 'w-3',
    title: 'PWC PIBBED EVERYDAY SHORT SLEEVE TEE',
    price: 29000,
    category: '패션',
    link: 'musinsa.com/app/goods/headphone',
  ),
  WishlistPlaceholder(
    id: 'w-4',
    title: 'PWC PIBBED EVERYDAY SHORT SLEEVE TEE',
    price: 29000,
    category: '패션',
    link: 'musinsa.com/app/goods/coffee',
  ),
];

class WishlistViewModel extends StateNotifier<WishlistState> {
  WishlistViewModel() : super(const WishlistState());

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    await Future<void>.delayed(Duration.zero);

    state = state.copyWith(
      isLoading: false,
      items: mockWishlistItems,
    );
  }

  void toggleAlarm() {
    state = state.copyWith(isAlarmOpen: !state.isAlarmOpen);
  }

  void toggleCategory(String category) {
    if (!categories.contains(category)) {
      return;
    }
    final nextCategories = Set<String>.from(state.selectedCategories);

    if (category == '전체') {
      state = state.copyWith(selectedCategories: {'전체'});
      return;
    }

    nextCategories.remove('전체');

    if (nextCategories.contains(category)) {
      nextCategories.remove(category);
    } else {
      nextCategories.add(category);
    }

    if (nextCategories.isEmpty) {
      nextCategories.add('전체');
    }

    state = state.copyWith(selectedCategories: nextCategories);
  }

  void openEditPanel(String itemId) {
    state = state.copyWith(editingItemId: itemId);
  }

  void closeEditPanel() {
    state = state.copyWith(clearEditingItemId: true);
  }

  void updateItem(WishlistPlaceholder updatedItem) {
    final nextItems = state.items
        .map((item) => item.id == updatedItem.id ? updatedItem : item)
        .toList();

    state = state.copyWith(items: nextItems);
  }

  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
      clearEditingItemId: true,
    );
  }
}

final wishlistViewModelProvider =
    StateNotifierProvider<WishlistViewModel, WishlistState>((ref) {
      final viewModel = WishlistViewModel();
      viewModel.initialize();
      return viewModel;
    });
