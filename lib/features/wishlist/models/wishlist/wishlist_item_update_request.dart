import 'package:fe_app/features/wishlist/models/wishlist/wishlist_category_ui.dart';
import 'package:fe_app/features/wishlist/utils/share_link_url.dart';
import 'package:fe_app/shared/enums/api_enums.dart';

class WishlistItemUpdateRequest {
  WishlistItemUpdateRequest._({
    required this.title,
    required this.category,
    this.originalUrl,
    this.normalizedUrl,
    this.listedPrice,
    this.includeListedPrice = false,
    this.includeUrls = false,
  });

  final String title;
  final String category;
  final String? originalUrl;
  final String? normalizedUrl;
  final num? listedPrice;
  final bool includeListedPrice;
  final bool includeUrls;

  factory WishlistItemUpdateRequest.fromForm({
    required String title,
    required String uiCategoryLabel,
    required ItemInputSource inputSource,
    String? link,
    required int? listedPrice,
  }) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Title must not be blank', 'title');
    }

    final isDirectInput = inputSource == ItemInputSource.directInput;
    final trimmedLink = link?.trim() ?? '';
    final hasLink = trimmedLink.isNotEmpty;
    final normalizedLink =
        hasLink ? (ShareLinkUrl.normalize(trimmedLink) ?? trimmedLink) : null;

    return WishlistItemUpdateRequest._(
      title: trimmedTitle,
      category: WishlistCategoryUi.toApiValue(uiCategoryLabel),
      includeListedPrice: true,
      listedPrice: listedPrice,
      includeUrls: isDirectInput,
      originalUrl: isDirectInput && hasLink ? trimmedLink : null,
      normalizedUrl: isDirectInput ? normalizedLink : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title,
      'category': category,
      'categoryLockedByUser': true,
    };
    if (includeListedPrice) {
      json['listedPrice'] = listedPrice;
    }
    if (includeUrls) {
      json['originalUrl'] = originalUrl;
      json['normalizedUrl'] = normalizedUrl;
    }
    return json;
  }
}
