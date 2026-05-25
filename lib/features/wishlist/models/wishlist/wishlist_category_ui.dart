import 'package:fe_app/shared/enums/api_enums.dart';

abstract final class WishlistCategoryUi {
  WishlistCategoryUi._();

  static const List<String> formLabels = ['패션', '뷰티', '라이프', '디지털', '기타'];

  static const Map<String, ItemCategory> _labelToEnum = {
    '패션': ItemCategory.fashion,
    '뷰티': ItemCategory.beauty,
    '라이프': ItemCategory.living,
    '디지털': ItemCategory.digital,
    '식품': ItemCategory.food,
    '취미': ItemCategory.hobby,
    '구독': ItemCategory.subscription,
    '기타': ItemCategory.etc,
  };

  static const Map<ItemCategory, String> _enumToLabel = {
    ItemCategory.fashion: '패션',
    ItemCategory.beauty: '뷰티',
    ItemCategory.living: '라이프',
    ItemCategory.digital: '디지털',
    ItemCategory.food: '식품',
    ItemCategory.hobby: '취미',
    ItemCategory.subscription: '구독',
    ItemCategory.etc: '기타',
  };

  static String toApiValue(String uiLabel) {
    return _labelToEnum[uiLabel]?.apiValue ?? ItemCategory.etc.apiValue;
  }

  static String toUiLabel(String? apiCategory) {
    final normalized = apiCategory?.trim();
    if (normalized == null || normalized.isEmpty) return '기타';
    final category = ItemCategory.fromApiValue(normalized.toUpperCase());
    if (category == null) return '기타';
    return _enumToLabel[category] ?? '기타';
  }
}
