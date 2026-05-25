import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/wishlist/models/item_import/item_import_link_request.dart';
import 'package:fe_app/features/wishlist/utils/share_link_url.dart';
import 'package:fe_app/features/wishlist/models/item_import/item_import_mapper.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_category_ui.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_category_update_request.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_mapper.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_save_request.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:fe_app/features/wishlist/services/item_import_service.dart';
import 'package:fe_app/features/wishlist/services/wishlist_service.dart';
import 'package:fe_app/shared/enums/api_enums.dart';
import 'wishlist_state.dart';

const List<String> categories = ['전체', '패션', '뷰티', '라이프', '디지털', '기타'];

const WishlistPlaceholder _emptyReflectItem = WishlistPlaceholder(
  id: '',
  title: '',
  price: 0,
  category: '기타',
  link: '',
);

class WishlistViewModel extends StateNotifier<WishlistState> {
  WishlistViewModel(this._ref) : super(const WishlistState());

  final Ref _ref;
  int _linkImportGeneration = 0;

  WishlistService get _wishlistService => _ref.read(wishlistServiceProvider);

  ItemImportService get _itemImportService => _ref.read(itemImportServiceProvider);

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearListErrorMessage: true);
    await _fetchFirstPage();
  }

  Future<void> refreshItems() async {
    state = state.copyWith(clearListErrorMessage: true);
    await _fetchFirstPage();
  }

  /// 위시 탭/화면 진입 시 서버 목록으로 동기화합니다.
  Future<void> reloadOnScreenOpen() async {
    state = state.copyWith(clearListErrorMessage: true);
    if (state.items.isEmpty) {
      state = state.copyWith(isLoading: true);
    }
    await _fetchFirstPage();
  }

  Future<void> _fetchFirstPage() async {
    try {
      final page = await _wishlistService.listItems();
      state = state.copyWith(
        isLoading: false,
        items: page.items.map((e) => e.toPlaceholder()).toList(),
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        clearNextCursor: page.nextCursor == null,
      );
    } catch (e) {
      final api = apiExceptionFrom(e);
      if (api != null) {
        state = state.copyWith(
          isLoading: false,
          items: [],
          hasMore: false,
          clearNextCursor: true,
          listErrorMessage: api.statusCode == 403
              ? '온보딩을 먼저 완료해 주세요.'
              : api.message,
        );
        return;
      }
      state = state.copyWith(
        isLoading: false,
        items: [],
        hasMore: false,
        clearNextCursor: true,
        listErrorMessage: '위시리스트를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.',
      );
    }
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (state.isLoadingMore || !state.hasMore || cursor == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await _wishlistService.listItems(cursor: cursor);
      final existingIds = state.items.map((item) => item.id).toSet();
      final appended = page.items
          .map((e) => e.toPlaceholder())
          .where((item) => !existingIds.contains(item.id))
          .toList();

      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...appended],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        clearNextCursor: page.nextCursor == null,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void clearListError() {
    state = state.copyWith(clearListErrorMessage: true);
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
      clearAddFormPrefill: true,
      clearAddImportSaveRequest: true,
      clearSubmitErrorMessage: true,
    );
  }

  void openAddPanelWithLink(String link) {
    final trimmed = link.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(showEmptyClipboardAlert: true);
      return;
    }

    final normalized = ShareLinkUrl.normalize(trimmed);
    if (normalized == null) {
      state = state.copyWith(
        submitErrorMessage: 'http 또는 https로 시작하는 상품 링크를 붙여넣어 주세요.',
      );
      return;
    }

    final generation = ++_linkImportGeneration;
    state = state.copyWith(
      isAddWishOpen: true,
      clearEditingItemId: true,
      addPrefillLink: normalized,
      isAddLinkReadOnly: true,
      isImportingLink: true,
      clearAddFormPrefill: true,
      clearAddImportSaveRequest: true,
      clearSubmitErrorMessage: true,
    );
    _importShareLink(normalized, generation);
  }

  Future<void> _importShareLink(String url, int generation) async {
    try {
      final response = await _itemImportService.importLink(
        ItemImportLinkRequest.share(url),
      );
      if (!_isLinkImportStillActive(generation, url)) return;

      final prefill = response.toFormPrefill();
      final saveRequest = response.resolvedSaveRequest();

      if (prefill == null) {
        if (_isLinkImportStillActive(generation, url)) {
          _handleImportFailure();
        }
        return;
      }

      if (!_isLinkImportStillActive(generation, url)) return;

      state = state.copyWith(
        isImportingLink: false,
        addFormPrefill: prefill,
        addImportSaveRequest: saveRequest,
        addPrefillLink: prefill.link.isNotEmpty ? prefill.link : state.addPrefillLink,
      );
    } on ArgumentError {
      if (_isLinkImportStillActive(generation, url)) {
        _handleImportFailure();
      }
    } catch (_) {
      if (_isLinkImportStillActive(generation, url)) {
        _handleImportFailure();
      }
    }
  }

  bool _isLinkImportStillActive(int generation, String url) {
    return generation == _linkImportGeneration &&
        state.isAddWishOpen &&
        state.isImportingLink &&
        state.addPrefillLink == url;
  }

  void _handleImportFailure() {
    state = state.copyWith(
      clearAddWish: true,
      clearAddPrefillLink: true,
      clearAddLinkReadOnly: true,
      clearAddFormPrefill: true,
      clearAddImportSaveRequest: true,
      isImportingLink: false,
      pendingImportFailedNavigation: true,
    );
  }

  void clearPendingImportFailedNavigation() {
    state = state.copyWith(clearPendingImportFailedNavigation: true);
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
      clearAddFormPrefill: true,
      clearAddImportSaveRequest: true,
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
    return ItemInputSource.directInput;
  }

  WishlistItemSaveRequest _buildSaveRequestForAdd(WishlistPlaceholder draft) {
    final imported = state.addImportSaveRequest;
    if (imported != null) {
      return imported.copyWith(
        title: draft.title.trim(),
        listedPrice: draft.price > 0 ? draft.price : null,
        currencyCode: draft.price > 0 ? (imported.currencyCode ?? 'KRW') : null,
        category: WishlistCategoryUi.toApiValue(draft.category),
        categoryLockedByUser: imported.categoryLockedByUser ?? true,
        imageUrl: draft.imageUrl ?? imported.imageUrl,
        originalUrl: draft.link.trim().isNotEmpty
            ? draft.link.trim()
            : imported.originalUrl,
        normalizedUrl: draft.link.trim().isNotEmpty
            ? draft.link.trim()
            : imported.normalizedUrl,
      );
    }

    return draft.toSaveRequest(
      inputSource: _resolveInputSourceForAdd(draft),
      categoryLockedByUser: true,
    );
  }

  Future<bool> addItem(WishlistPlaceholder draft) async {
    state = state.copyWith(
      isSubmitting: true,
      clearSubmitErrorMessage: true,
    );

    try {
      final request = _buildSaveRequestForAdd(draft);
      await _wishlistService.createItem(request);

      state = state.copyWith(
        isSubmitting: false,
        clearAddWish: true,
        clearAddPrefillLink: true,
        clearAddLinkReadOnly: true,
        clearAddFormPrefill: true,
        clearAddImportSaveRequest: true,
      );
      await _fetchFirstPage();
      return true;
    } catch (e) {
      final api = apiExceptionFrom(e);
      if (api != null &&
          api.statusCode == 409 &&
          api.code == 'DUPLICATE_SAVED_ITEM') {
        final existing = WishlistService.parseDuplicateExistingItem(api);
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
            clearAddFormPrefill: true,
            clearAddImportSaveRequest: true,
          );
          return false;
        }
      }

      state = state.copyWith(
        isSubmitting: false,
        submitErrorMessage: api?.message ??
            '위시를 담지 못했어요. 잠시 후 다시 시도해 주세요.',
      );
      return false;
    }
  }

  Future<bool> updateItem(WishlistPlaceholder updatedItem) async {
    final exists = state.items.any((item) => item.id == updatedItem.id);
    if (!exists) return false;

    state = state.copyWith(
      isSubmitting: true,
      clearSubmitErrorMessage: true,
    );

    try {
      await _wishlistService.updateItemCategory(
        itemId: updatedItem.id,
        request: WishlistItemCategoryUpdateRequest(
          category: WishlistCategoryUi.toApiValue(updatedItem.category),
        ),
      );
      await _fetchFirstPage();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      final api = apiExceptionFrom(e);
      state = state.copyWith(
        isSubmitting: false,
        submitErrorMessage: api?.message ??
            '카테고리를 수정하지 못했어요. 잠시 후 다시 시도해 주세요.',
      );
      return false;
    }
  }

  Future<bool> dropItem(String id) async {
    state = state.copyWith(
      isSubmitting: true,
      clearSubmitErrorMessage: true,
    );

    try {
      await _wishlistService.dropItem(itemId: id);
      await _fetchFirstPage();
      state = state.copyWith(
        isSubmitting: false,
        clearEditingItemId: true,
        clearAddWish: true,
      );
      return true;
    } catch (e) {
      final api = apiExceptionFrom(e);
      state = state.copyWith(
        isSubmitting: false,
        submitErrorMessage: api?.message ??
            '위시를 삭제하지 못했어요. 잠시 후 다시 시도해 주세요.',
      );
      return false;
    }
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
    return _emptyReflectItem;
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
  return WishlistViewModel(ref);
});
