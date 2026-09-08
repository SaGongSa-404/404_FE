import 'dart:async';
import 'package:fe_app/features/purchase/purchase_analytics.dart';
import 'package:fe_app/features/profile/providers/consumption_stats_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fe_app/features/purchase/purchase_service.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';

class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen(
      {super.key, this.initialItemId, this.initialRecords = false});
  final String? initialItemId;
  final bool initialRecords;
  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  List<PurchaseItem> _items = [];
  List<PurchaseItem>? _details;
  final Set<String> _selected = {};
  final Map<String, PurchaseChange> _pending = {};
  bool _loading = true, _busy = false, _records = false, _enabled = false;
  String? _error;
  int? _nextOffset;
  int _loadGeneration = 0;
  PurchaseService get _service => ref.read(purchaseServiceProvider);
  @override
  void initState() {
    super.initState();
    _records = widget.initialRecords;
    _load(initial: true);
  }

  Future<void> _load({bool initial = false, bool more = false}) async {
    final generation = ++_loadGeneration;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final availability = await _service.availability();
      final page = await _service.list(
          records: _records, offset: more ? (_nextOffset ?? 0) : 0);
      List<PurchaseItem>? details;
      if (initial && widget.initialItemId != null) {
        details = [await _service.get(widget.initialItemId!)];
      }
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _enabled = availability.enabled;
        _items = more
            ? [
                ..._items,
                ...page.items.where((i) => !_items.any((e) => e.id == i.id))
              ]
            : page.items;
        _nextOffset = page.nextOffset;
        _loading = false;
        if (details != null) _details = details;
      });
    } catch (_) {
      if (mounted && generation == _loadGeneration) {
        setState(() {
          _loading = false;
          _error = '상품을 불러오지 못했어요. 다시 시도해 주세요.';
        });
      }
    }
  }

  void _message(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _open(List<String> ids) async {
    if (ids.length == 2) {
      unawaited(PurchaseAnalytics.record('comparison_opened'));
    }
    setState(() => _busy = true);
    try {
      final items = await Future.wait(ids.map(_service.get));
      if (mounted) {
        setState(() => _details = items);
        if (ids.length == 2) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              unawaited(PurchaseAnalytics.record('comparison_completed'));
            }
          });
        }
      }
    } catch (_) {
      _message('상품을 다시 불러오지 못했어요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(PurchaseChange draft) async {
    if (_busy) return;
    // An uncertain network result must retry with the same mutation ID and revision.
    final previous = _pending[draft.item.id];
    final request =
        previous?.fingerprint == draft.fingerprint ? previous! : draft;
    _pending[draft.item.id] = request;
    setState(() => _busy = true);
    try {
      await _service.change(request);
      final updated = await _service.get(request.item.id);
      if (!mounted) return;
      ref.invalidate(purchaseAvailabilityProvider);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(consumptionStatsProvider);
      if (draft.item.status != updated.status ||
          draft.item.actualPrice != updated.actualPrice) {
        unawaited(PurchaseAnalytics.record('purchase_outcome_saved',
            parameters: {
              'status': updated.status,
              'event_id': request.mutationId
            }));
      }
      _pending.remove(updated.id);
      if (!mounted) return;
      setState(() => _details =
          _details?.map((i) => i.id == updated.id ? updated : i).toList());
      await _load();
      _message('저장했어요.');
    } on DioException catch (e) {
      final data = e.response?.data;
      final serverMessage = data is Map && data['message'] is String
          ? data['message'] as String
          : null;
      if (e.response?.statusCode == 409) {
        _pending.remove(draft.item.id);
        try {
          final updated = await _service.get(draft.item.id);
          if (mounted) {
            setState(() => _details = _details
                ?.map((i) => i.id == updated.id ? updated : i)
                .toList());
          }
        } catch (_) {}
        _message(serverMessage ?? '다른 화면에서 변경됐어요. 최신 내용을 확인해 주세요.');
      } else if (e.response?.statusCode == 403) {
        _message('현재 구매 정리를 사용할 수 없어요.');
      } else if (e.response?.statusCode == 400) {
        _message(serverMessage ?? '금액과 구매 날짜를 확인해 주세요.');
      } else {
        _message('저장을 확인하지 못했어요. 같은 내용으로 다시 시도할 수 있어요.');
      }
    } catch (_) {
      _message('저장을 확인하지 못했어요. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _purchase(PurchaseItem item) async {
    final result = await showDialog<_PurchaseInput>(
        context: context, builder: (_) => _PurchaseDialog(item: item));
    if (result != null && mounted) {
      await _save(PurchaseChange(
          item: item,
          status: 'PURCHASED',
          note: item.note,
          actualPrice: result.price,
          purchasedOn: result.date));
    }
  }

  Future<void> _note(PurchaseItem item) async {
    final result = await showDialog<String>(
        context: context, builder: (_) => _NoteDialog(note: item.note));
    if (result != null && mounted) {
      await _save(PurchaseChange(
          item: item,
          status: item.status,
          note: result,
          actualPrice: item.actualPrice,
          purchasedOn: item.purchasedOn));
    }
  }

  Future<void> _status(PurchaseItem item, String status) async {
    if (item.purchased) {
      final yes = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                  title: const Text('구매 기록을 정정할까요?'),
                  content: const Text('이 상품의 구매 금액을 예산 지출에서 제외합니다.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('정정'))
                  ]));
      if (yes != true || !mounted) return;
    }
    await _save(PurchaseChange(item: item, status: status, note: item.note));
  }

  Future<void> _link(String? value) async {
    final uri = Uri.tryParse(value ?? '');
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      _message('구매 링크가 없어요.');
      return;
    }
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _message('구매 링크를 열지 못했어요.');
      }
    } catch (_) {
      _message('구매 링크를 열지 못했어요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _details;
    return Scaffold(
        appBar: AppBar(
            title: Text(details == null
                ? '비교·구매 정리'
                : details.length == 2
                    ? '두 상품 비교'
                    : '구매 정리'),
            leading: BackButton(
                onPressed: _busy
                    ? null
                    : () {
                        if (details != null) {
                          setState(() {
                            _details = null;
                            _selected.clear();
                          });
                          _load();
                        } else {
                          Navigator.pop(context);
                        }
                      })),
        body: SafeArea(
            child: Column(children: [
          if (_busy || _loading) const LinearProgressIndicator(),
          if (!_enabled && !_loading)
            const Padding(
                padding: EdgeInsets.all(12),
                child: Text('지금은 기록을 확인할 수 있어요. 상태 변경은 준비 중이에요.')),
          if (_error != null)
            Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Text(_error!),
                  TextButton(
                      onPressed: _busy
                          ? null
                          : () => _load(initial: widget.initialItemId != null),
                      child: const Text('다시 시도'))
                ])),
          Expanded(child: details == null ? _list() : _comparison(details)),
        ])));
  }

  Widget _list() => Column(children: [
        Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('고민 중')),
                  ButtonSegment(value: true, label: Text('정리한 기록'))
                ],
                selected: {
                  _records
                },
                onSelectionChanged: _busy || _loading
                    ? null
                    : (v) {
                        setState(() {
                          _records = v.first;
                          _selected.clear();
                        });
                        _load();
                      })),
        Expanded(
            child: RefreshIndicator(
                onRefresh: () => _load(),
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  if (_items.isEmpty && !_loading && _error == null)
                    Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_records
                            ? '아직 정리한 기록이 없어요.'
                            : '위시리스트에서 상품을 담아 주세요.')),
                  ..._items.map((item) => Card(
                      child: ListTile(
                          leading: _photo(item, 48),
                          title: Text(item.title),
                          subtitle: Text(
                              '${money(item.listedPrice, item.currencyCode)} · ${item.statusLabel}'),
                          onTap: _busy ? null : () => _open([item.id]),
                          trailing: _records
                              ? const Icon(Icons.chevron_right)
                              : Checkbox(
                                  value: _selected.contains(item.id),
                                  onChanged: _busy
                                      ? null
                                      : (v) {
                                          setState(() {
                                            if (v == true) {
                                              if (_selected.length < 2) {
                                                _selected.add(item.id);
                                              } else {
                                                _message(
                                                    '비교할 후보는 두 개까지 선택해 주세요.');
                                              }
                                            } else {
                                              _selected.remove(item.id);
                                            }
                                          });
                                        })))),
                  if (_nextOffset != null)
                    TextButton(
                        onPressed:
                            _busy || _loading ? null : () => _load(more: true),
                        child: const Text('더 보기')),
                ]))),
        if (!_records)
          Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: _selected.length == 2 && !_busy
                          ? () => _open(_selected.toList())
                          : null,
                      child: Text('두 상품 비교 (${_selected.length}/2)')))),
      ]);
  Widget _comparison(List<PurchaseItem> items) => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (items.length == 2)
          Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(priceDifference(items[0], items[1]),
                  style: Theme.of(context).textTheme.titleMedium)),
        LayoutBuilder(builder: (context, constraints) {
          final cards = items.map(_card).toList();
          if (cards.length == 1 || constraints.maxWidth < 320) {
            return Column(children: cards);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1])
          ]);
        }),
        const SizedBox(height: 16),
        const ExpansionTile(title: Text('잠깐 생각해 보기 (선택)'), children: [
          Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                  '지금 필요한 물건인가요?\n비슷한 물건을 이미 가지고 있나요?\n내 예산 안에서 괜찮은 선택인가요?\n조금 더 기다려도 괜찮을까요?'))
        ]),
      ]));
  Widget _card(PurchaseItem item) => Card(
      margin: EdgeInsets.zero,
      child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _photo(item, 100),
            const SizedBox(height: 12),
            Text(item.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(money(item.listedPrice, item.currencyCode)),
            const SizedBox(height: 8),
            Text(item.statusLabel),
            if (item.purchased)
              Text('${money(item.actualPrice, 'KRW')} · ${item.purchasedOn}'),
            const SizedBox(height: 12),
            Text(item.note.isEmpty ? '고민 메모를 남겨 보세요.' : item.note),
            if (!item.legacyDecision)
              TextButton(
                  onPressed: _enabled && !_busy ? () => _note(item) : null,
                  child: const Text('메모 수정')),
            TextButton(
                onPressed: _busy ? null : () => _link(item.originalUrl),
                child: const Text('구매 링크 열기')),
            if (item.legacyDecision)
              const Text('기존 설문 기록입니다. 소비 관리에서 확인·수정해 주세요.')
            else ...[
              FilledButton(
                  onPressed: _enabled && !_busy ? () => _purchase(item) : null,
                  child: Text(item.purchased ? '구매 수정' : '샀어요')),
              if (item.status != 'DECLINED')
                OutlinedButton(
                    onPressed: _enabled && !_busy
                        ? () => _status(item, 'DECLINED')
                        : null,
                    child: const Text('안 사요')),
              if (item.status != 'CONSIDERING')
                TextButton(
                    onPressed: _enabled && !_busy
                        ? () => _status(item, 'CONSIDERING')
                        : null,
                    child: const Text('고민 중으로')),
            ],
          ])));
  Widget _photo(PurchaseItem item, double height) {
    final uri = Uri.tryParse(item.imageUrl ?? '');
    final placeholder = Container(
        height: height,
        width: height,
        color: const Color(0xffeeeaf5),
        child: const Icon(Icons.shopping_bag_outlined));
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      return placeholder;
    }
    return Image.network(uri.toString(),
        height: height,
        width: height,
        fit: BoxFit.contain,
        errorBuilder: (_, error, stack) => placeholder);
  }
}

String money(int? value, String? currency) {
  if (value == null) return '가격 미입력';
  final text = value
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  return '$text ${currency == null || currency == 'KRW' ? '원' : currency}';
}

String priceDifference(PurchaseItem a, PurchaseItem b) {
  if (a.listedPrice == null || b.listedPrice == null) {
    return '가격이 없는 후보는 가격 차이를 계산하지 않아요.';
  }
  if ((a.currencyCode ?? 'KRW') != (b.currencyCode ?? 'KRW')) {
    return '통화가 달라 가격 차이를 계산하지 않아요.';
  }
  return '두 후보의 가격 차이 ${money((a.listedPrice! - b.listedPrice!).abs(), a.currencyCode)}';
}

class _PurchaseInput {
  const _PurchaseInput(this.price, this.date);
  final int price;
  final String date;
}

class _PurchaseDialog extends StatefulWidget {
  const _PurchaseDialog({required this.item});
  final PurchaseItem item;
  @override
  State<_PurchaseDialog> createState() => _PurchaseDialogState();
}

class _PurchaseDialogState extends State<_PurchaseDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _price;
  late DateTime _date;
  @override
  void initState() {
    super.initState();
    _price = TextEditingController(
        text: widget.item.actualPrice?.toString() ??
            ((widget.item.currencyCode ?? 'KRW') == 'KRW'
                ? widget.item.listedPrice?.toString()
                : null) ??
            '');
    _date = DateTime.tryParse(widget.item.purchasedOn ?? '') ?? DateTime.now();
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('실제로 구매했나요?'),
          content: SingleChildScrollView(
              child: Form(
                  key: _form,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(widget.item.title),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _price,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: '실제 결제 금액 (원)'),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          return n == null || n < 0 || n > 2147483647
                              ? '0 이상의 결제 금액을 입력해 주세요.'
                              : null;
                        }),
                    TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                              context: context,
                              initialDate: _date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now());
                          if (date != null && mounted) {
                            setState(() => _date = date);
                          }
                        },
                        child: Text(
                            '구매일 ${_date.toIso8601String().substring(0, 10)}')),
                    const Text('확인한 금액만 해당 월 지출에 반영해요.'),
                  ]))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소')),
            FilledButton(
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    Navigator.pop(
                        context,
                        _PurchaseInput(int.parse(_price.text),
                            _date.toIso8601String().substring(0, 10)));
                  }
                },
                child: const Text('구매 기록 저장'))
          ]);
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.note});
  final String note;
  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final TextEditingController _text;
  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.note);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('고민 메모'),
          content: TextField(
              controller: _text, maxLength: 500, minLines: 2, maxLines: 5),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소')),
            FilledButton(
                onPressed: () => Navigator.pop(context, _text.text.trim()),
                child: const Text('저장'))
          ]);
}
