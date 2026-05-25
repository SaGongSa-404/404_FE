import 'package:fe_app/shared/enums/api_enums.dart';

abstract final class WishlistCategoryUi {
  WishlistCategoryUi._();

  static const List<String> formLabels = ['패션', '뷰티', '라이프', '디지털', '기타'];

  static const Map<String, ItemCategory> _labelToEnum = {
    '패션': ItemCategory.fashion,
    '뷰티': ItemCategory.beauty,
    '라이프': ItemCategory.living,
    '디지털': ItemCategory.digital,
    '기타': ItemCategory.etc,
  };

  static String toApiValue(String uiLabel) {
    return _labelToEnum[uiLabel]?.apiValue ?? ItemCategory.etc.apiValue;
  }

  static String toUiLabel(String? apiCategory) {
    final normalized = apiCategory?.trim();
    if (normalized == null || normalized.isEmpty) return '기타';
    final category = ItemCategory.fromApiValue(normalized.toUpperCase());
    if (category == null) return '기타';
    for (final entry in _labelToEnum.entries) {
      if (entry.value == category) return entry.key;
    }
    return '기타';
  }
}
