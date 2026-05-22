import 'package:fe_app/features/wishlist/models/item_import/item_import_link_response.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_category_ui.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_save_request.dart';
import 'package:fe_app/features/wishlist/models/wishlist_add_form_prefill.dart';

extension ItemImportLinkResponseMapper on ItemImportLinkResponse {
  WishlistAddFormPrefill? toFormPrefill() {
    final draft = saveRequest;
    final itemDraft = item;
    if (draft == null && itemDraft == null) return null;

    final link = _resolveLink(draft, itemDraft);
    final title = (draft?.title ?? itemDraft?.title ?? '').trim();
    if (title.isEmpty) return null;

    final price = (draft?.listedPrice ?? itemDraft?.listedPrice)?.round() ?? 0;
    final category = WishlistCategoryUi.toUiLabel(
      draft?.category ?? itemDraft?.category?.apiValue,
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

  String _resolveLink(
    WishlistItemSaveRequest? draft,
    SavedItemDraft? itemDraft,
  ) {
    final fromSave = (draft?.normalizedUrl ?? draft?.originalUrl ?? '').trim();
    if (fromSave.isNotEmpty) return fromSave;
    return (itemDraft?.normalizedUrl ?? itemDraft?.originalUrl ?? '').trim();
  }
}
