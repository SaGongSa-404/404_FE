import 'package:fe_app/features/wishlist/models/item_import/item_import_link_response.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_category_ui.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_save_request.dart';
import 'package:fe_app/features/wishlist/models/wishlist_add_form_prefill.dart';
import 'package:fe_app/shared/enums/api_enums.dart';

extension ItemImportLinkResponseMapper on ItemImportLinkResponse {
  WishlistAddFormPrefill? toFormPrefill() {
    final draft = saveRequest;
    final itemDraft = item;
    if (draft == null && itemDraft == null) return null;

    final link = _resolveLink(draft, itemDraft);
    final title = (draft?.title ?? itemDraft?.title ?? '').trim();
    if (title.isEmpty) return null;

    final price = (draft?.listedPrice ?? itemDraft?.listedPrice)?.round() ?? 0;
    final categoryApi = _resolveCategoryApiValue(draft, itemDraft);
    final category = WishlistCategoryUi.resolveFormChipSelection(
      apiCategory: categoryApi,
    );
    final imageUrl = draft?.imageUrl ?? itemDraft?.imageUrl;

    return WishlistAddFormPrefill(
      link: link,
      title: title,
      price: price,
      category: category,
      imageUrl: imageUrl,
    );
  }

  WishlistItemSaveRequest? enrichedSaveRequest() {
    final draft = saveRequest;
    if (draft == null) return null;
    return _mergeSourceMetadata(_ensureCategory(draft));
  }

  WishlistItemSaveRequest? resolvedSaveRequest() {
    final fromSave = enrichedSaveRequest() ?? item?.toSaveRequest();
    if (fromSave == null) return null;
    return _mergeSourceMetadata(_ensureCategory(fromSave));
  }

  WishlistItemSaveRequest _ensureCategory(WishlistItemSaveRequest draft) {
    if (draft.category.trim().isNotEmpty) return draft;
    return draft.copyWith(category: ItemCategory.etc.apiValue);
  }

  WishlistItemSaveRequest _mergeSourceMetadata(WishlistItemSaveRequest draft) {
    final meta = sourceMetadata;
    if (meta == null) return draft;

    return draft.copyWith(
      sourceDomain: draft.sourceDomain ?? meta.sourceDomain,
      rawTitle: draft.rawTitle ?? meta.rawTitle,
      rawDescription: draft.rawDescription ?? meta.rawDescription,
      rawPriceText: draft.rawPriceText ?? meta.rawPriceText,
      rawPayloadJson: draft.rawPayloadJson ?? meta.rawPayloadJson,
    );
  }

  String? _resolveCategoryApiValue(
    WishlistItemSaveRequest? draft,
    SavedItemDraft? itemDraft,
  ) {
    final fromSave = draft?.category.trim();
    if (fromSave != null && fromSave.isNotEmpty) return fromSave;
    return itemDraft?.category?.apiValue;
  }

  String _resolveLink(
    WishlistItemSaveRequest? draft,
    SavedItemDraft? itemDraft,
  ) {
    final fromSave = (draft?.normalizedUrl ?? draft?.originalUrl ?? '').trim();
    if (fromSave.isNotEmpty) return fromSave;
    return (itemDraft?.normalizedUrl ?? itemDraft?.originalUrl ?? '').trim();
  }
}
