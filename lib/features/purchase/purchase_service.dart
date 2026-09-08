import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/network/api_client.dart';

final purchaseServiceProvider = Provider<PurchaseService>(
    (ref) => PurchaseService(ref.watch(apiClientProvider).dio));
final purchaseAvailabilityProvider =
    FutureProvider.autoDispose<PurchaseAvailability>(
        (ref) => ref.watch(purchaseServiceProvider).availability());

class PurchaseAvailability {
  const PurchaseAvailability(this.enabled, this.hasRecords);
  final bool enabled;
  final bool hasRecords;
}

class PurchaseItem {
  const PurchaseItem(
      {required this.id,
      required this.title,
      required this.status,
      required this.revision,
      this.note = '',
      this.listedPrice,
      this.actualPrice,
      this.purchasedOn,
      this.imageUrl,
      this.originalUrl,
      this.currencyCode,
      this.legacyDecision = false});
  final String id, title, status, note;
  final int revision;
  final int? listedPrice, actualPrice;
  final String? purchasedOn, imageUrl, originalUrl, currencyCode;
  final bool legacyDecision;
  bool get purchased => status == 'PURCHASED';
  String get statusLabel => switch (status) {
        'PURCHASED' => '샀어요',
        'DECLINED' => '안 사요',
        'LEGACY_GO' => '기존 구매 결정',
        'LEGACY_STOP' => '기존 보류 결정',
        _ => '고민 중',
      };
  factory PurchaseItem.fromJson(Map<String, dynamic> j) => PurchaseItem(
      id: j['id'] as String,
      title: j['title'] as String,
      status: j['status'] as String,
      revision: (j['revision'] as num).toInt(),
      note: j['note'] as String? ?? '',
      listedPrice: (j['listedPrice'] as num?)?.toInt(),
      actualPrice: (j['actualPrice'] as num?)?.toInt(),
      purchasedOn: j['purchasedOn'] as String?,
      imageUrl: j['imageUrl'] as String?,
      originalUrl: j['originalUrl'] as String?,
      currencyCode: j['currencyCode'] as String?,
      legacyDecision: j['legacyDecision'] == true);
}

class PurchasePage {
  const PurchasePage(this.items, this.nextOffset);
  final List<PurchaseItem> items;
  final int? nextOffset;
}

class PurchaseChange {
  PurchaseChange(
      {required this.item,
      required this.status,
      required this.note,
      this.actualPrice,
      this.purchasedOn})
      : mutationId = _uuid();
  final PurchaseItem item;
  final String status, note, mutationId;
  final int? actualPrice;
  final String? purchasedOn;
  Map<String, dynamic> toJson() => {
        'mutationId': mutationId,
        'expectedRevision': item.revision,
        'status': status,
        'note': note,
        'actualPrice': actualPrice,
        'purchasedOn': purchasedOn
      };
  String get fingerprint => jsonEncode(
      [item.id, item.revision, status, note, actualPrice, purchasedOn]);
  static String _uuid() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final h = bytes.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }
}

class PurchaseService {
  const PurchaseService(this.dio);
  final Dio dio;
  static const path = '/api/v1/purchase-items';
  Future<PurchaseAvailability> availability() async {
    final response = await dio.get<Map<String, dynamic>>('$path/availability');
    final j = response.data!;
    return PurchaseAvailability(j['enabled'] == true, j['hasRecords'] == true);
  }

  Future<PurchasePage> list({bool records = false, int offset = 0}) async {
    final response = await dio.get<Map<String, dynamic>>(path,
        queryParameters: {'records': records, 'offset': offset, 'limit': 50});
    return PurchasePage(
        (response.data!['items'] as List)
            .map((j) =>
                PurchaseItem.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList(),
        response.data!['nextOffset'] as int?);
  }

  /// OFF accounts can still open their own new records without entering the legacy survey.
  Future<bool> usesPurchaseFlow(String id, PurchaseAvailability? cached) async {
    PurchaseAvailability current;
    try {
      current = cached ?? await availability();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return false;
      rethrow;
    }
    if (current.enabled) return true;
    if (!current.hasRecords) return false;
    return (await get(id)).revision > 0;
  }

  Future<PurchaseItem> get(String id) async => PurchaseItem.fromJson(
      (await dio.get<Map<String, dynamic>>('$path/$id')).data!);
  Future<PurchaseItem> change(PurchaseChange change) async =>
      PurchaseItem.fromJson((await dio.put<Map<String, dynamic>>(
              '$path/${change.item.id}',
              data: change.toJson()))
          .data!);
}
