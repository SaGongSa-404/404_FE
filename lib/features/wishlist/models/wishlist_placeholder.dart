import 'package:fe_app/shared/enums/api_enums.dart';

class WishlistPlaceholder {
  const WishlistPlaceholder({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.link,
    this.imageUrl,
    this.inputSource,
    this.status = 'SAVED',
    this.hasFeedPost = false,
  });

  final String id;
  final String title;
  final int price;
  final String category;
  final String link;
  final String? imageUrl;
  final ItemInputSource? inputSource;

  /// 서버 item status (예: SAVED, GO, STOP). 숙려 화면은 SAVED만 진입 가능.
  final String status;

  /// 본인이 이 위시로 작성한 살아있는 피드 글 존재 여부 (BE `selected`).
  final bool hasFeedPost;

  bool get canOpenDeliberation =>
      status.trim().toUpperCase() == 'SAVED' || status.trim().isEmpty;

  WishlistPlaceholder copyWith({
    String? id,
    String? title,
    int? price,
    String? category,
    String? link,
    String? imageUrl,
    ItemInputSource? inputSource,
    String? status,
    bool? hasFeedPost,
    bool clearImageUrl = false,
  }) {
    return WishlistPlaceholder(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      category: category ?? this.category,
      link: link ?? this.link,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      inputSource: inputSource ?? this.inputSource,
      status: status ?? this.status,
      hasFeedPost: hasFeedPost ?? this.hasFeedPost,
    );
  }
}
