import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fe_app/features/purchase/purchase_screen.dart';
import 'package:fe_app/features/purchase/purchase_service.dart';

class FakePurchaseService extends PurchaseService {
  FakePurchaseService() : super(Dio());
  bool enabled = true, failList = false, loseFirstResponse = false;
  final commands = <PurchaseChange>[];
  final receipts = <String, PurchaseItem>{};
  List<PurchaseItem> items = [
    const PurchaseItem(
        id: 'a',
        title: '운동화 A',
        status: 'CONSIDERING',
        revision: 0,
        listedPrice: 89000),
    const PurchaseItem(
        id: 'b',
        title: '운동화 B',
        status: 'CONSIDERING',
        revision: 0,
        listedPrice: 69000),
  ];
  @override
  Future<PurchaseAvailability> availability() async =>
      PurchaseAvailability(enabled, false);
  @override
  Future<PurchasePage> list({bool records = false, int offset = 0}) async {
    if (failList) {
      throw DioException.connectionError(
          requestOptions: RequestOptions(), reason: 'offline');
    }
    return PurchasePage(
        items
            .where((i) =>
                records ? i.status != 'CONSIDERING' : i.status == 'CONSIDERING')
            .toList(),
        null);
  }

  @override
  Future<PurchaseItem> get(String id) async =>
      items.firstWhere((i) => i.id == id);
  @override
  Future<PurchaseItem> change(PurchaseChange c) async {
    commands.add(c);
    if (receipts.containsKey(c.mutationId)) return receipts[c.mutationId]!;
    final previous = await get(c.item.id);
    final updated = PurchaseItem(
        id: previous.id,
        title: previous.title,
        listedPrice: previous.listedPrice,
        status: c.status,
        note: c.note,
        revision: previous.revision + 1,
        actualPrice: c.actualPrice,
        purchasedOn: c.purchasedOn);
    items = items.map((i) => i.id == updated.id ? updated : i).toList();
    receipts[c.mutationId] = updated;
    if (loseFirstResponse) {
      loseFirstResponse = false;
      throw DioException.connectionError(
          requestOptions: RequestOptions(), reason: 'response lost');
    }
    return updated;
  }
}

Future<void> open(WidgetTester tester, FakePurchaseService service,
    {String? id}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(ProviderScope(
      overrides: [purchaseServiceProvider.overrideWithValue(service)],
      child: MaterialApp(home: PurchaseScreen(initialItemId: id))));
  await tester.pumpAndSettle();
}

Future<void> buy(WidgetTester tester, String amount) async {
  final buy = find.widgetWithText(FilledButton, '샀어요').first;
  await tester.ensureVisible(buy);
  await tester.tap(buy);
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField), amount);
  await tester.tap(find.widgetWithText(FilledButton, '구매 기록 저장'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('two selected candidates compare and purchase without a survey',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = FakePurchaseService();
    await open(tester, service);
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, '두 상품 비교 (0/2)'))
            .onPressed,
        isNull);
    await tester.tap(find.byType(Checkbox).at(0));
    await tester.pump();
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '두 상품 비교 (2/2)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('20,000'), findsOneWidget);
    await buy(tester, '85000');
    expect(service.commands.single.status, 'PURCHASED');
    expect(service.items.first.actualPrice, 85000);
    expect(find.text('구매 수정'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final back = find.widgetWithText(TextButton, '고민 중으로');
    await tester.ensureVisible(back);
    await tester.tap(back);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '정정'));
    await tester.pumpAndSettle();
    expect(service.items.first.status, 'CONSIDERING');
    expect(service.items.first.actualPrice, isNull);
  });
  testWidgets(
      'lost response retries same mutation rather than making a second purchase',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = FakePurchaseService()..loseFirstResponse = true;
    await open(tester, service, id: 'a');
    await buy(tester, '85000');
    await buy(tester, '85000');
    expect(service.commands.length, 2);
    expect(service.commands[0].mutationId, service.commands[1].mutationId);
    expect(service.items.first.revision, 1);
  });
  testWidgets(
      'request failure has retry and is not presented as an empty wishlist',
      (tester) async {
    final service = FakePurchaseService()..failList = true;
    await open(tester, service);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    expect(find.text('다시 시도'), findsOneWidget);
    expect(find.text('위시리스트에서 상품을 담아 주세요.'), findsNothing);
    service.failList = false;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('운동화 A'), findsOneWidget);
  });
  testWidgets('disabled writes leave existing records readable',
      (tester) async {
    final service = FakePurchaseService()..enabled = false;
    await open(tester, service, id: 'a');
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    expect(find.text('운동화 A'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, '샀어요'))
            .onPressed,
        isNull);
  });
}
