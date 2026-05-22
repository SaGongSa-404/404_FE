import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_mapper.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:fe_app/features/wishlist/services/wishlist_service.dart';
import 'package:fe_app/shared/enums/api_enums.dart';
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
  WishlistViewModel(this._ref) : super(const WishlistState());

  final Ref _ref;

  WishlistService get _wishlistService => _ref.read(wishlistServiceProvider);

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
      clearSubmitErrorMessage: true,
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
      clearSubmitErrorMessage: true,
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
      clearSubmitErrorMessage: true,
    );
  }

  void requestReopenAddEntryModal() {
    state = state.copyWith(reopenAddEntryModal: true);
  }

  void clearReopenAddEntryModal() {
    state = state.copyWith(clearReopenAddEntryModal: true);
  }

  void clearSubmitError() {
    state = state.copyWith(clearSubmitErrorMessage: true);
  }

  ItemInputSource _resolveInputSourceForAdd(WishlistPlaceholder draft) {
    final link = draft.link.trim();
    if (link.isEmpty) return ItemInputSource.directInput;
    if (state.isAddLinkReadOnly) return ItemInputSource.share;
    return ItemInputSource.share;
  }

  /// POST /api/v1/wishlist/items — 추가 성공 시 true.
  Future<bool> addItem(WishlistPlaceholder draft) async {
    state = state.copyWith(
      isSubmitting: true,
      clearSubmitErrorMessage: true,
    );

    try {
      final request = draft.toSaveRequest(
        inputSource: _resolveInputSourceForAdd(draft),
        categoryLockedByUser: true,
      );
      final created = await _wishlistService.createItem(request);
      final item = created.toPlaceholder();

      state = state.copyWith(
        isSubmitting: false,
        items: [...state.items, item],
        clearAddWish: true,
        clearAddPrefillLink: true,
        clearAddLinkReadOnly: true,
      );
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 409 && e.code == 'DUPLICATE_SAVED_ITEM') {
        final existing = WishlistService.parseDuplicateExistingItem(e);
        if (existing != null) {
          final placeholder = existing.toPlaceholder();
          final alreadyListed = state.items.any((i) => i.id == placeholder.id);
          state = state.copyWith(
            isSubmitting: false,
            items: alreadyListed ? state.items : [...state.items, placeholder],
            submitErrorMessage: '이미 담긴 상품이에요',
            clearAddWish: true,
            clearAddPrefillLink: true,
            clearAddLinkReadOnly: true,
          );
          return false;
        }
      }

      state = state.copyWith(
        isSubmitting: false,
        submitErrorMessage: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        submitErrorMessage: '위시를 담지 못했어요. 잠시 후 다시 시도해 주세요.',
      );
      return false;
    }
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
      final viewModel = WishlistViewModel(ref);
      viewModel.initialize();
      return viewModel;
    });
