import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fe_app/features/profile/models/monthly_stats.dart';
import 'package:fe_app/features/profile/providers/consumption_stats_provider.dart';
import 'package:fe_app/features/profile/services/profile_service.dart';
import 'package:fe_app/features/purchase/purchase_screen.dart';
import 'package:fe_app/features/purchase/purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'purchase_screen_test.dart' as helper;

class DelayedProfile extends ProfileService {
  DelayedProfile() : super(Dio());
  final first = Completer<StatsMonthsResponse>();
  int requests = 0;
  @override
  Future<StatsMonthsResponse> getStatsMonths() {
    if (++requests == 1) return first.future;
    return Future.value(
        const StatsMonthsResponse(months: [], currentMonth: ''));
  }
}

void main() {
  test(
      'OFF keeps new considering notes in purchase flow and untouched items in legacy',
      () async {
    final service = helper.FakePurchaseService();
    service.items = [
      const PurchaseItem(
          id: 'a',
          title: '메모 상품',
          status: 'CONSIDERING',
          revision: 1,
          note: '비교 메모'),
      const PurchaseItem(
          id: 'b', title: '기존 상품', status: 'CONSIDERING', revision: 0),
    ];
    const off = PurchaseAvailability(false, true);
    expect(await service.usesPurchaseFlow('a', off), isTrue);
    expect(await service.usesPurchaseFlow('b', off), isFalse);
  });
  test('loading availability is resolved before choosing the legacy route',
      () async {
    final service = helper.FakePurchaseService();
    expect(await service.usesPurchaseFlow('a', null), isTrue);
  });

  testWidgets('purchase save while previous stats request is still pending',
      (tester) async {
    final profile = DelayedProfile();
    final purchase = helper.FakePurchaseService();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          profileServiceProvider.overrideWithValue(profile),
          purchaseServiceProvider.overrideWithValue(purchase),
        ],
        child: Consumer(builder: (context, ref, _) {
          ref.watch(consumptionStatsProvider);
          return const MaterialApp(home: PurchaseScreen(initialItemId: 'a'));
        })));
    await tester.pumpAndSettle();
    await helper.buy(tester, '85000');
    profile.first
        .complete(const StatsMonthsResponse(months: [], currentMonth: ''));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
