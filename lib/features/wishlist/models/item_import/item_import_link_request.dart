import 'package:fe_app/features/wishlist/utils/share_link_url.dart';
import 'package:fe_app/shared/enums/api_enums.dart';

class ItemImportLinkRequest {
  const ItemImportLinkRequest({
    required this.inputSource,
    this.url,
    this.title,
    this.brandName,
    this.price,
    this.imageUrl,
  });

  final ItemInputSource inputSource;
  final String? url;
  final String? title;
  final String? brandName;
  final num? price;
  final String? imageUrl;

  factory ItemImportLinkRequest.share(String url) {
    final normalized = ShareLinkUrl.normalize(url);
    if (normalized == null) {
      throw ArgumentError('Invalid share URL', 'url');
    }
    return ItemImportLinkRequest(
      inputSource: ItemInputSource.share,
      url: normalized,
    );
  }

  factory ItemImportLinkRequest.directInput({
    required String title,
    String? brandName,
    num? price,
    String? imageUrl,
  }) {
    return ItemImportLinkRequest(
      inputSource: ItemInputSource.directInput,
      title: title.trim(),
      brandName: brandName,
      price: price,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inputSource': inputSource.apiValue,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (brandName != null) 'brandName': brandName,
      if (price != null) 'price': price,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
