import 'dart:math';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/profile/models/monthly_stats.dart';
import 'package:fe_app/features/profile/providers/consumption_stats_provider.dart';
import 'package:fe_app/features/profile/views/monthly_spending_detail_screen.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
import 'package:fe_app/shared/widgets/profile_modal_text_field.dart';
import 'package:fe_app/shared/widgets/nugul_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ConsumptionManagementScreen extends ConsumerStatefulWidget {
  const ConsumptionManagementScreen({super.key});

  @override
  ConsumerState<ConsumptionManagementScreen> createState() =>
      _ConsumptionManagementScreenState();
}

class _ConsumptionManagementScreenState
    extends ConsumerState<ConsumptionManagementScreen> {
  bool _hasDataChanged = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(consumptionStatsProvider.notifier).refresh();
    });
  }

  static const Color _backgroundColor = Color(0xFFF5F5F5);
  static const Color _cardShadowColor = Color(0x22000000);
  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: _cardShadowColor,
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset.zero,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final statsState = ref.watch(consumptionStatsProvider);
    final current = statsState.currentMonthStats;

    ref.listen<ConsumptionStatsState>(consumptionStatsProvider, (prev, next) {
      if (prev?.errorMessage != next.errorMessage && next.errorMessage != null) {
        showCapsuleToast(
          context,
          backgroundColor: AppColors.red_600.withValues(alpha: 0.8),
          text: next.errorMessage!,
        );
      }
    });

    final numberFormat = RegExp(r'\B(?=(\d{3})+(?!\d))');
    String format(int val) =>
        val.toString().replaceAllMapped(numberFormat, (m) => ',');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.pop(_hasDataChanged);
      },
      child: Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 18 * scale),
          onPressed: () => context.pop(_hasDataChanged),
        ),
        title: Text(
          '소비 관리',
          style: TextStyle(
            color: AppColors.brown,
            fontSize: 18 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(statsState, current, format, scale),
      ),
    );
  }

  Widget _buildBody(
    ConsumptionStatsState statsState,
    MonthlyStats? current,
    String Function(int) format,
    double scale,
  ) {
    if (statsState.isLoading && current == null) {
      return const NugulLoadingScreen();
    }

    if (current == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                statsState.errorMessage ?? '소비 통계를 불러올 수 없습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16 * scale),
              TextButton(
                onPressed: () =>
                    ref.read(consumptionStatsProvider.notifier).refresh(),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(consumptionStatsProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이번 달 예산',
              style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16 * scale),
            _buildCurrentBudgetCard(context, current, format, scale),
            SizedBox(height: 40 * scale),
            Text(
              '월별 소비기록',
              style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16 * scale),
            if (statsState.monthlyRecordStats.isEmpty)
              Text(
                '소비 기록이 없습니다.',
                style: TextStyle(
                  fontSize: 14 * scale,
                  color: AppColors.textSecondary,
                ),
              )
            else
              ...statsState.monthlyRecordStats.map(
                (record) => _buildMonthlyRecordCard(
                  context,
                  record,
                  format,
                  scale,
                  isCurrentMonth: record.yearMonth == statsState.currentMonth,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBudgetCard(
    BuildContext context,
    MonthlyStats current,
    String Function(int) format,
    double scale,
  ) {
    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30 * scale),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${format(current.budgetAmount)}원',
                style: TextStyle(fontSize: 24 * scale, fontWeight: FontWeight.bold),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      _showBudgetEditDialog(context, current.budgetAmount),
                  borderRadius: BorderRadius.circular(20 * scale),
                  highlightColor: Colors.black.withAlpha(25),
                  splashColor: Colors.black.withAlpha(15),
                  child: Ink(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12 * scale, vertical: 6 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(20 * scale),
                    ),
                    child: Text(
                      '예산 수정',
                      style: TextStyle(
                          fontSize: 12 * scale, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * scale),
          Container(
            height: 16 * scale,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: current.progressFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: current.isExceeded
                      ? AppColors.red_200
                      : AppColors.skyBlue_200,
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
              ),
            ),
          ),
          SizedBox(height: 12 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${format(current.spentAmount)}원',
                style: TextStyle(fontSize: 14 * scale, color: AppColors.textSecondary),
              ),
              Text(
                '${format(current.budgetAmount)}원',
                style: TextStyle(fontSize: 14 * scale, color: AppColors.textSecondary),
              ),
            ],
          ),
          if (current.restrainedAmount > 0) ...[
            SizedBox(height: 16 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '절제한 금액',
                  style:
                      TextStyle(fontSize: 12 * scale, color: AppColors.textSecondary),
                ),
                Text(
                  '${format(current.restrainedAmount)}원',
                  style:
                      TextStyle(fontSize: 12 * scale, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
          if (current.isExceeded) ...[
            SizedBox(height: 16 * scale),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8 * scale),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEB),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: Text(
                '⚠️ 예산을 초과했어요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.red_400,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthlyRecordCard(
    BuildContext context,
    MonthlyStats record,
    String Function(int) format,
    double scale, {
    bool isCurrentMonth = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30 * scale),
        boxShadow: _cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final changed = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) =>
                    MonthlySpendingDetailScreen(yearMonth: record.yearMonth),
              ),
            );
            if (changed == true && mounted) {
              setState(() => _hasDataChanged = true);
            }
          },
          borderRadius: BorderRadius.circular(30 * scale),
          highlightColor: Colors.black.withAlpha(25),
          splashColor: Colors.black.withAlpha(15),
          child: Ink(
            padding: EdgeInsets.all(24 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30 * scale),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          record.displayMonth,
                          style: TextStyle(
                              fontSize: 15 * scale, fontWeight: FontWeight.bold),
                        ),
                        if (isCurrentMonth) ...[
                          SizedBox(width: 8 * scale),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8 * scale, vertical: 2 * scale),
                            decoration: BoxDecoration(
                              color: AppColors.skyBlue_100,
                              borderRadius: BorderRadius.circular(8 * scale),
                            ),
                            child: Text(
                              '이번 달',
                              style: TextStyle(
                                fontSize: 10 * scale,
                                fontWeight: FontWeight.bold,
                                color: AppColors.skyBlue_300,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10 * scale, vertical: 4 * scale),
                      decoration: BoxDecoration(
                        color: record.isExceeded
                            ? AppColors.red_100
                            : const Color(0xFFE8F3F9),
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                      child: Text(
                        record.isExceeded ? '예산초과' : '예산 내',
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.bold,
                          color: record.isExceeded
                              ? AppColors.red_400
                              : AppColors.skyBlue_300,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${format(record.spentAmount)}원',
                      style:
                          TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '/${format(record.budgetAmount)}원',
                      style: TextStyle(
                          fontSize: 13 * scale, color: const Color(0xFFADADAD)),
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),
                Container(
                  height: 12 * scale,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(6 * scale),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: record.progressFactor,
                    child: Container(
                      decoration: BoxDecoration(
                        color: record.isExceeded
                            ? AppColors.red_200
                            : AppColors.skyBlue_200,
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '예산 사용률 : ${record.usageRate}%',
                      style:
                          TextStyle(fontSize: 13 * scale, color: AppColors.textSecondary),
                    ),
                    Text(
                      '참은 선택 : ${record.restrainedCount}회',
                      style:
                          TextStyle(fontSize: 13 * scale, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBudgetEditDialog(BuildContext context, int currentBudget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _BudgetEditModal(
        currentBudget: currentBudget,
        onSave: (newBudget) async {
          final ok = await ref
              .read(consumptionStatsProvider.notifier)
              .updateBudget(newBudget);
          if (ok) setState(() => _hasDataChanged = true);
          return ok;
        },
      ),
    );
  }
}

class _BudgetEditModal extends StatefulWidget {
  const _BudgetEditModal({
    required this.currentBudget,
    required this.onSave,
  });

  final int currentBudget;
  final Future<bool> Function(int newBudget) onSave;

  @override
  State<_BudgetEditModal> createState() => _BudgetEditModalState();
}

class _BudgetEditModalState extends State<_BudgetEditModal> {
  static const _maxDigits = 8;

  late final TextEditingController _controller;
  String _digits = '';
  bool _isSaving = false;
  bool _maxDigitsExceeded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    final digits = _controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits != _digits || _maxDigitsExceeded) {
      setState(() {
        _digits = digits;
        if (digits.length < _maxDigits) {
          _maxDigitsExceeded = false;
        }
      });
    }
  }

  void _onExceededMaxDigits() {
    if (!_maxDigitsExceeded) {
      setState(() => _maxDigitsExceeded = true);
    }
  }

  String? get _errorMessage {
    if (_maxDigitsExceeded) return '8자 이내로 입력해주세요';
    if (_digits.isEmpty) return null;
    final amount = int.tryParse(_digits) ?? 0;
    if (amount < 1) return '1원 이상 입력해주세요';
    return null;
  }

  bool get _canSave {
    if (_isSaving) return false;
    if (_digits.isEmpty) return false;
    final amount = int.tryParse(_digits) ?? 0;
    return amount >= 1 && _digits.length <= _maxDigits;
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
        );
  }

  Future<void> _handleSave() async {
    if (!_canSave) return;
    final newBudget = int.parse(_digits);
    setState(() => _isSaving = true);
    final ok = await widget.onSave(newBudget);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final systemBottomPadding = MediaQuery.paddingOf(context).bottom;
    final hasError = _errorMessage != null;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(
        21 * scale,
        0,
        21 * scale,
        max(systemBottomPadding, bottomInset) + 24 * scale,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(37 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 3,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 31 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '현재 예산 ${_formatAmount(widget.currentBudget)}',
              style: TextStyle(
                fontSize: 20 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              '수정할 예산을 입력해주세요',
              style: TextStyle(fontSize: 16 * scale, color: AppColors.textSecondary),
            ),
            SizedBox(height: 25 * scale),
            if (hasError)
              Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: AppColors.red_400,
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ProfileModalTextField(
              controller: _controller,
              scale: scale,
              hasError: hasError,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                _BudgetAmountFormatter(
                  maxDigits: _maxDigits,
                  onExceededMaxDigits: _onExceededMaxDigits,
                ),
              ],
            ),
            SizedBox(height: 20 * scale),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 57 * scale,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(57 * scale),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20 * scale,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 6 * scale),
                Expanded(
                  child: GestureDetector(
                    onTap: _canSave ? _handleSave : null,
                    child: Container(
                      height: 57 * scale,
                      decoration: BoxDecoration(
                        color: _canSave
                            ? AppColors.skyBlue_100
                            : AppColors.skyBlue_100.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(57 * scale),
                      ),
                      alignment: Alignment.center,
                      child: _isSaving
                          ? SizedBox(
                              width: 24 * scale,
                              height: 24 * scale,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              '수정완료',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20 * scale,
                                color: AppColors.textPrimary,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetAmountFormatter extends TextInputFormatter {
  _BudgetAmountFormatter({
    required this.maxDigits,
    this.onExceededMaxDigits,
  });

  final int maxDigits;
  final VoidCallback? onExceededMaxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > maxDigits) {
      onExceededMaxDigits?.call();
      digits = digits.substring(0, maxDigits);
    }
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final formatted = int.parse(digits).toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]},',
        );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
