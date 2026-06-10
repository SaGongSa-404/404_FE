import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';

abstract final class WishlistItemFormValidation {
  WishlistItemFormValidation._();

  static const int maxTitleLength = 200;

  static int? parsePriceDigits(String priceText) {
    final digits = priceText.replaceAll(',', '').trim();
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  static bool isLinkFormatInvalid(String link) {
    final trimmed = link.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    return !lower.startsWith('http://') && !lower.startsWith('https://');
  }

  static bool isLinkInvalid({
    required bool isAdd,
    required bool linkReadOnly,
    required bool editLinkReadOnly,
    required String link,
  }) {
    final linkEmpty = link.trim().isEmpty;
    final linkRequired = isAdd && linkReadOnly;
    final linkEditable = isAdd ? !linkReadOnly : !editLinkReadOnly;
    if (linkRequired && linkEmpty) return true;
    if (linkEditable && isLinkFormatInvalid(link)) return true;
    return false;
  }

  static bool isFormValid({
    required String link,
    required String title,
    required String priceText,
    required String? category,
    required bool isAdd,
    required bool linkReadOnly,
    required bool editLinkReadOnly,
  }) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty || trimmedTitle.length > maxTitleLength) return false;
    if (category == null || category.trim().isEmpty) return false;
    if (isLinkInvalid(
      isAdd: isAdd,
      linkReadOnly: linkReadOnly,
      editLinkReadOnly: editLinkReadOnly,
      link: link,
    )) {
      return false;
    }
    final parsed = parsePriceDigits(priceText);
    if (parsed == null || parsed == 0) return false;
    return true;
  }

  static String? linkErrorMessage({
    required bool validationAttempted,
    required String link,
  }) {
    if (!validationAttempted || !isLinkFormatInvalid(link)) return null;
    return 'http 또는 https로 시작하는 링크를 입력해주세요';
  }

  static String? priceErrorMessage({
    required bool validationAttempted,
    required String priceText,
  }) {
    final parsed = parsePriceDigits(priceText);
    if (validationAttempted && parsed == 0) return '1원 이상 입력해주세요';
    return null;
  }

  static WishlistPlaceholder buildAddDraft({
    required String title,
    required String priceText,
    required String category,
    required String link,
    String? imageUrl,
  }) {
    return WishlistPlaceholder(
      id: 'w-${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      price: parsePriceDigits(priceText)!,
      category: category,
      link: link.trim(),
      imageUrl: imageUrl,
    );
  }

  static WishlistPlaceholder buildEditDraft({
    required WishlistPlaceholder existing,
    required String title,
    required String priceText,
    required String category,
    required String link,
  }) {
    return WishlistPlaceholder(
      id: existing.id,
      title: title.trim(),
      price: parsePriceDigits(priceText)!,
      category: category,
      link: link.trim(),
      imageUrl: existing.imageUrl,
      inputSource: existing.inputSource,
    );
  }
}
