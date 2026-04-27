import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'wishlist_state.dart';

const List<String> categories = ['전체', '패션', '뷰티', '라이프', '디지털', '기타'];
const List<WishlistPlaceholder> mockWishlistItems = [
  WishlistPlaceholder(
    id: 'w-1',
    title: '오프화이트 후드',
    price: 289000,
    category: '패션',
    link: 'musinsa.com/app/goods/hoodie',
  ),
  WishlistPlaceholder(
    id: 'w-3',
    title: '오버이어 헤드폰',
    price: 349000,
    category: '디지털',
    link: 'musinsa.com/app/goods/headphone',
  ),
  WishlistPlaceholder(
    id: 'w-4',
    title: '에스프레소 머신',
    price: 159000,
    category: '라이프',
    link: 'musinsa.com/app/goods/coffee',
  ),
  WishlistPlaceholder(
    id: 'w-5',
    title: '빈티지 데님 자켓',
    price: 129000,
    category: '패션',
    link: 'musinsa.com/app/goods/jacket',
  ),
  WishlistPlaceholder(
    id: 'w-7',
    title: '무선 키보드',
    price: 89000,
    category: '디지털',
    link: 'musinsa.com/app/goods/keyboard',
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

    state = state.copyWith(
      items: nextItems,
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
