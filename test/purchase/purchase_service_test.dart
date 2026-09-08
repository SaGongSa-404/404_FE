import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fe_app/features/purchase/purchase_service.dart';
import 'package:fe_app/features/purchase/purchase_screen.dart';
import 'package:fe_app/features/wishlist/utils/wishlist_item_form_validation.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_mapper.dart';
import 'package:fe_app/shared/enums/api_enums.dart';

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString(
        jsonEncode({
          'id': 'a',
          'title': '후보',
          'status': 'PURCHASED',
          'note': '',
          'revision': 1,
          'actualPrice': 9000,
          'purchasedOn': '2026-09-08'
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('mutation retry keeps identifier, revision and actual purchase date',
      () async {
    final adapter = _Adapter();
    final dio = Dio()..httpClientAdapter = adapter;
    const item =
        PurchaseItem(id: 'a', title: '후보', status: 'CONSIDERING', revision: 0);
    final command = PurchaseChange(
        item: item,
        status: 'PURCHASED',
        note: '',
        actualPrice: 9000,
        purchasedOn: '2026-09-08');
    final service = PurchaseService(dio);
    await service.change(command);
    await service.change(command);
    expect(adapter.requests.length, 2);
    expect(adapter.requests.first.data, adapter.requests.last.data);
    expect(adapter.requests.first.path, '/api/v1/purchase-items/a');
    expect(adapter.requests.first.data['expectedRevision'], 0);
    expect(
        command.mutationId,
        matches(RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
  });
  test('unknown price stays null through save and is not shown as free', () {
    expect(
        WishlistItemFormValidation.isFormValid(
            link: '',
            title: '후보',
            priceText: '',
            category: '기타',
            isAdd: true,
            linkReadOnly: false,
            editLinkReadOnly: false),
        isTrue);
    final draft = WishlistItemFormValidation.buildAddDraft(
        title: '후보', priceText: '', category: '기타', link: '');
    expect(draft.priceKnown, isFalse);
    expect(
        draft
            .toSaveRequest(inputSource: ItemInputSource.directInput)
            .listedPrice,
        isNull);
    expect(money(null, 'KRW'), '가격 미입력');
    const a = PurchaseItem(
        id: 'a',
        title: 'A',
        status: 'CONSIDERING',
        revision: 0,
        listedPrice: 50000);
    const b =
        PurchaseItem(id: 'b', title: 'B', status: 'CONSIDERING', revision: 0);
    expect(priceDifference(a, b), contains('계산하지'));
    const usd = PurchaseItem(
        id: 'b',
        title: 'B',
        status: 'CONSIDERING',
        revision: 0,
        listedPrice: 50,
        currencyCode: 'USD');
    expect(priceDifference(a, usd), contains('통화가 달라'));
  });
  test('malformed and out of range prices cannot be submitted', () {
    for (final price in ['-1', '0', 'abc', '2147483648']) {
      expect(
          WishlistItemFormValidation.isFormValid(
              link: '',
              title: '후보',
              priceText: price,
              category: '기타',
              isAdd: true,
              linkReadOnly: false,
              editLinkReadOnly: false),
          isFalse);
    }
  });
}
