import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';

class WishlistState {
  final bool isLoading;
  final bool isSubmitting;
  final String? submitErrorMessage;
  final bool isAlarmOpen;
  final String? editingItemId;
  final bool isAddWishOpen;
  final bool isAddLinkReadOnly;
  final bool reopenAddEntryModal;
  final bool showEmptyClipboardAlert;
  final String? addPrefillLink;
  final Set<String> selectedCategories;
  final List<WishlistPlaceholder> items;

  const WishlistState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.submitErrorMessage,
    this.isAlarmOpen = false,
    this.editingItemId,
    this.isAddWishOpen = false,
    this.isAddLinkReadOnly = false,
    this.reopenAddEntryModal = false,
    this.showEmptyClipboardAlert = false,
    this.addPrefillLink,
    this.selectedCategories = const {'전체'},
    this.items = const [],
  });

  WishlistState copyWith({
    bool? isLoading,
    bool? isSubmitting,
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
    String? addPrefillLink,
    bool clearAddPrefillLink = false,
    Set<String>? selectedCategories,
    List<WishlistPlaceholder>? items,
  }) {
    return WishlistState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
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
      addPrefillLink: clearAddPrefillLink ? null : (addPrefillLink ?? this.addPrefillLink),
      selectedCategories: Set.unmodifiable(
        selectedCategories ?? this.selectedCategories,
      ),
      items: List.unmodifiable(items ?? this.items),
    );
  }
}