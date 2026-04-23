import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';

class WishlistState {
  final bool isLoading;
  final bool isAlarmOpen;
  final String? editingItemId;
  final Set<String> selectedCategories;
  final List<WishlistPlaceholder> items;

  const WishlistState({
    this.isLoading = false,
    this.isAlarmOpen = false,
    this.editingItemId,
    this.selectedCategories = const {'전체'},
    this.items = const [],
  });

  WishlistState copyWith({
    bool? isLoading,
    bool? isAlarmOpen,
    String? editingItemId,
    bool clearEditingItemId = false,
    Set<String>? selectedCategories,
    List<WishlistPlaceholder>? items,
  }) {
    return WishlistState(
      isLoading: isLoading ?? this.isLoading,
      isAlarmOpen: isAlarmOpen ?? this.isAlarmOpen,
      editingItemId: clearEditingItemId ? null : (editingItemId ?? this.editingItemId),
      selectedCategories: selectedCategories ?? this.selectedCategories,
      items: items ?? this.items,
    );
  }
}