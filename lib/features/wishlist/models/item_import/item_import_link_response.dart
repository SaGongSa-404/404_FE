import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_save_request.dart';
import 'package:fe_app/shared/enums/api_enums.dart';

class ItemImportLinkResponse {
  const ItemImportLinkResponse({
    required this.retrievalStatus,
    this.item,
    this.sourceMetadata,
    this.saveRequest,
    this.warnings = const [],
  });

  final String retrievalStatus;
  final SavedItemDraft? item;
  final ItemSourceMetadataDraft? sourceMetadata;
  final WishlistItemSaveRequest? saveRequest;
  final List<String> warnings;

  factory ItemImportLinkResponse.fromJson(Map<String, dynamic> json) {
    final rawWarnings = json['warnings'];
    final item = json['item'] is Map<String, dynamic>
        ? SavedItemDraft.fromJson(json['item'] as Map<String, dynamic>)
        : null;
    return ItemImportLinkResponse(
      retrievalStatus: json['retrievalStatus'] as String? ?? '',
      item: item,
      sourceMetadata: json['sourceMetadata'] is Map<String, dynamic>
          ? ItemSourceMetadataDraft.fromJson(
              json['sourceMetadata'] as Map<String, dynamic>,
            )
          : null,
      saveRequest: _tryParseSaveRequest(json['saveRequest'], item: item),
      warnings: rawWarnings is List
          ? rawWarnings.map((e) => e.toString()).toList()
          : const [],
    );
  }

  static WishlistItemSaveRequest? _tryParseSaveRequest(
    Object? raw, {
    SavedItemDraft? item,
  }) {
    if (raw is! Map<String, dynamic>) return null;
    final map = Map<String, dynamic>.from(raw);
    final categoryRaw = map['category'];
    final category = categoryRaw == null
        ? null
        : categoryRaw.toString().trim();
    if ((category == null || category.isEmpty) && item?.category != null) {
      map['category'] = item!.category!.apiValue;
    }
    try {
      return WishlistItemSaveRequest.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}

class SavedItemDraft {
  const SavedItemDraft({
    required this.inputSource,
    this.originalUrl,
    this.normalizedUrl,
    required this.title,
    this.brandName,
    this.summary,
    this.imageUrl,
    this.listedPrice,
    this.currencyCode,
    this.category,
    this.categoryConfidence,
    this.categoryLockedByUser,
    this.status,
  });

  final ItemInputSource? inputSource;
  final String? originalUrl;
  final String? normalizedUrl;
  final String title;
  final String? brandName;
  final String? summary;
  final String? imageUrl;
  final num? listedPrice;
  final String? currencyCode;
  final ItemCategory? category;
  final num? categoryConfidence;
  final bool? categoryLockedByUser;
  final ItemStatus? status;

  factory SavedItemDraft.fromJson(Map<String, dynamic> json) {
    return SavedItemDraft(
      inputSource: ItemInputSource.fromApiValue(json['inputSource'] as String?),
      originalUrl: json['originalUrl'] as String?,
      normalizedUrl: json['normalizedUrl'] as String?,
      title: json['title'] as String? ?? '',
      brandName: json['brandName'] as String?,
      summary: json['summary'] as String?,
      imageUrl: json['imageUrl'] as String?,
      listedPrice: json['listedPrice'] as num?,
      currencyCode: json['currencyCode'] as String?,
      category: ItemCategory.fromApiValue(json['category'] as String?),
      categoryConfidence: json['categoryConfidence'] as num?,
      categoryLockedByUser: json['categoryLockedByUser'] as bool?,
      status: ItemStatus.fromApiValue(json['status'] as String?),
    );
  }

  WishlistItemSaveRequest? toSaveRequest() {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return null;

    final link = (normalizedUrl ?? originalUrl ?? '').trim();
    final host = link.isNotEmpty ? Uri.tryParse(link)?.host : null;

    return WishlistItemSaveRequest(
      inputSource: inputSource?.apiValue ?? ItemInputSource.share.apiValue,
      originalUrl: originalUrl,
      normalizedUrl: normalizedUrl,
      title: trimmedTitle,
      imageUrl: imageUrl,
      listedPrice: listedPrice,
      currencyCode: currencyCode,
      category: category?.apiValue ?? ItemCategory.etc.apiValue,
      categoryConfidence: categoryConfidence,
      categoryLockedByUser: categoryLockedByUser,
      sourceDomain: host,
    );
  }
}

class ItemSourceMetadataDraft {
  const ItemSourceMetadataDraft({
    this.sourceDomain,
    this.rawTitle,
    this.rawDescription,
    this.rawPriceText,
    this.rawPayloadJson,
    this.extractedAt,
    this.extractionMethod,
  });

  final String? sourceDomain;
  final String? rawTitle;
  final String? rawDescription;
  final String? rawPriceText;
  final String? rawPayloadJson;
  final DateTime? extractedAt;
  final String? extractionMethod;

  factory ItemSourceMetadataDraft.fromJson(Map<String, dynamic> json) {
    final extractedAtRaw = json['extractedAt'];
    return ItemSourceMetadataDraft(
      sourceDomain: json['sourceDomain'] as String?,
      rawTitle: json['rawTitle'] as String?,
      rawDescription: json['rawDescription'] as String?,
      rawPriceText: json['rawPriceText'] as String?,
      rawPayloadJson: json['rawPayloadJson'] as String?,
      extractedAt: extractedAtRaw is String
          ? DateTime.tryParse(extractedAtRaw)
          : null,
      extractionMethod: json['extractionMethod'] as String?,
    );
  }
}
