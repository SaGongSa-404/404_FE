import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_save_request.dart';
import 'package:fe_app/features/wishlist/models/wishlist_add_form_prefill.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';

class WishlistState {
  final bool isLoading;
  final bool isSubmitting;
  final bool isImportingLink;
  final String? submitErrorMessage;
  final bool isAlarmOpen;
  final String? editingItemId;
  final bool isAddWishOpen;
  final bool isAddLinkReadOnly;
  final bool reopenAddEntryModal;
  final bool showEmptyClipboardAlert;
  final bool pendingImportFailedNavigation;
  final String? addPrefillLink;
  final WishlistAddFormPrefill? addFormPrefill;
  final WishlistItemSaveRequest? addImportSaveRequest;
  final Set<String> selectedCategories;
  final List<WishlistPlaceholder> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final String? listErrorMessage;

  const WishlistState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isImportingLink = false,
    this.submitErrorMessage,
    this.isAlarmOpen = false,
    this.editingItemId,
    this.isAddWishOpen = false,
    this.isAddLinkReadOnly = false,
    this.reopenAddEntryModal = false,
    this.showEmptyClipboardAlert = false,
    this.pendingImportFailedNavigation = false,
    this.addPrefillLink,
    this.addFormPrefill,
    this.addImportSaveRequest,
    this.selectedCategories = const {'전체'},
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.listErrorMessage,
  });

  WishlistState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isImportingLink,
    String? submitErrorMessage,
    bool clearSubmitErrorMessage = false,
    bool? isAlarmOpen,
    String? editingItemId,
    bool clearEditingItemId = false,
    bool? isAddWishOpen,
    bool clearAddWish = false,
    bool? isAddLinkReadOnly,
    bool clearAddLinkReadOnly = false,
    bool? reopenAddEntryModal,
    bool clearReopenAddEntryModal = false,
    bool? showEmptyClipboardAlert,
    bool clearEmptyClipboardAlert = false,
    bool? pendingImportFailedNavigation,
    bool clearPendingImportFailedNavigation = false,
    String? addPrefillLink,
    bool clearAddPrefillLink = false,
    WishlistAddFormPrefill? addFormPrefill,
    bool clearAddFormPrefill = false,
    WishlistItemSaveRequest? addImportSaveRequest,
    bool clearAddImportSaveRequest = false,
    Set<String>? selectedCategories,
    List<WishlistPlaceholder>? items,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? hasMore,
    bool? isLoadingMore,
    String? listErrorMessage,
    bool clearListErrorMessage = false,
  }) {
    return WishlistState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isImportingLink: clearAddWish
          ? false
          : (isImportingLink ?? this.isImportingLink),
      submitErrorMessage: clearSubmitErrorMessage
          ? null
          : (submitErrorMessage ?? this.submitErrorMessage),
      isAlarmOpen: isAlarmOpen ?? this.isAlarmOpen,
      editingItemId: clearEditingItemId ? null : (editingItemId ?? this.editingItemId),
      isAddWishOpen: clearAddWish ? false : (isAddWishOpen ?? this.isAddWishOpen),
      isAddLinkReadOnly: clearAddLinkReadOnly
          ? false
          : (isAddLinkReadOnly ?? this.isAddLinkReadOnly),
      reopenAddEntryModal: clearReopenAddEntryModal
          ? false
          : (reopenAddEntryModal ?? this.reopenAddEntryModal),
      showEmptyClipboardAlert: clearEmptyClipboardAlert
          ? false
          : (showEmptyClipboardAlert ?? this.showEmptyClipboardAlert),
      pendingImportFailedNavigation: clearPendingImportFailedNavigation
          ? false
          : (pendingImportFailedNavigation ?? this.pendingImportFailedNavigation),
      addPrefillLink: (clearAddPrefillLink || clearAddWish)
          ? null
          : (addPrefillLink ?? this.addPrefillLink),
      addFormPrefill: (clearAddFormPrefill || clearAddWish)
          ? null
          : (addFormPrefill ?? this.addFormPrefill),
      addImportSaveRequest: (clearAddImportSaveRequest || clearAddWish)
          ? null
          : (addImportSaveRequest ?? this.addImportSaveRequest),
      selectedCategories: Set.unmodifiable(
        selectedCategories ?? this.selectedCategories,
      ),
      items: List.unmodifiable(items ?? this.items),
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      listErrorMessage: clearListErrorMessage
          ? null
          : (listErrorMessage ?? this.listErrorMessage),
    );
  }
}