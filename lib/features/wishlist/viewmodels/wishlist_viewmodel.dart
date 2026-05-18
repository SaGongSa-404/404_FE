import 'package:flutter/services.dart';
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

  void openAddPanel() {
    state = state.copyWith(
      isAddWishOpen: true,
      clearEditingItemId: true,
      clearAddPrefillLink: true,
      clearAddLinkReadOnly: true,
    );
  }

  void openAddPanelWithLink(String link) {
    final trimmed = link.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(showEmptyClipboardAlert: true);
      return;
    }

    state = state.copyWith(
      isAddWishOpen: true,
      clearEditingItemId: true,
      addPrefillLink: trimmed,
      isAddLinkReadOnly: true,
    );
  }

  Future<void> openAddPanelFromClipboard() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final url = clipboard?.text?.trim() ?? '';
    openAddPanelWithLink(url);
  }

  void clearEmptyClipboardAlert() {
    state = state.copyWith(clearEmptyClipboardAlert: true);
  }

  void openEditPanel(String itemId) {
    state = state.copyWith(
      editingItemId: itemId,
      isAddWishOpen: false,
    );
  }

  void closeEditPanel() {
    state = state.copyWith(
      clearEditingItemId: true,
      clearAddWish: true,
      clearAddPrefillLink: true,
      clearAddLinkReadOnly: true,
    );
  }

  void requestReopenAddEntryModal() {
    state = state.copyWith(reopenAddEntryModal: true);
  }

  void clearReopenAddEntryModal() {
    state = state.copyWith(clearReopenAddEntryModal: true);
  }

  void addItem(WishlistPlaceholder item) {
    state = state.copyWith(
      items: [...state.items, item],
    );
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
      clearAddWish: true,
    );
  }

  WishlistPlaceholder resolveReflectItem({
    WishlistPlaceholder? explicitItem,
    String? itemId,
  }) {
    if (explicitItem != null) return explicitItem;

    if (itemId != null) {
      for (final item in state.items) {
        if (item.id == itemId) return item;
      }
    }

    if (state.items.isNotEmpty) return state.items.first;
    return mockWishlistItems.first;
  }
}

final reflectDisplayItemProvider = Provider.autoDispose
    .family<WishlistPlaceholder, ReflectDisplayItemRequest>((ref, request) {
  ref.watch(wishlistViewModelProvider.select((s) => s.items));
  return ref.read(wishlistViewModelProvider.notifier).resolveReflectItem(
        explicitItem: request.explicitItem,
        itemId: request.itemId,
      );
});

class ReflectDisplayItemRequest {
  const ReflectDisplayItemRequest({this.explicitItem, this.itemId});

  final WishlistPlaceholder? explicitItem;
  final String? itemId;

  @override
  bool operator ==(Object other) {
    return other is ReflectDisplayItemRequest &&
        other.explicitItem == explicitItem &&
        other.itemId == itemId;
  }

  @override
  int get hashCode => Object.hash(explicitItem, itemId);
}

final wishlistViewModelProvider =
    StateNotifierProvider<WishlistViewModel, WishlistState>((ref) {
      final viewModel = WishlistViewModel();
      viewModel.initialize();
      return viewModel;
    });
