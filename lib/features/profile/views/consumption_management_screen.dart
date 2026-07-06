import 'dart:math';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/profile/models/monthly_stats.dart';
import 'package:fe_app/features/profile/providers/consumption_stats_provider.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_category_ui.dart';
import 'package:fe_app/features/profile/views/monthly_spending_detail_screen.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
import 'package:fe_app/shared/widgets/press_pill_button.dart';
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

    final pastRecords = _pastMonthlyRecords(statsState);

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
              style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.bold, color: Color(0xFF555555)),
            ),
            SizedBox(height: 14 * scale),
            _buildCurrentBudgetCard(context, current, format, scale),
            SizedBox(height: 32 * scale),
            Text(
              '월별 소비기록',
              style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.bold, color: Color(0xFF555555)),
            ),
            SizedBox(height: 14 * scale),
            if (pastRecords.isEmpty)
              Text(
                '소비 기록이 없습니다.',
                style: TextStyle(
                  fontSize: 14 * scale,
                  color: AppColors.textSecondary,
                ),
              )
            else
              ...pastRecords.map(
                (record) => _buildMonthlyRecordCard(
                  context,
                  record,
                  format,
                  scale,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<MonthlyStats> _pastMonthlyRecords(ConsumptionStatsState statsState) {
    final currentMonth = statsState.currentMonth;
    return statsState.monthlyRecordStats
        .where((record) => record.yearMonth != currentMonth)
        .toList();
  }

  String _formatRationalChoiceRate(double? rate) {
    if (rate == null) return '-';
    final clamped = rate.clamp(0.0, 100.0);
    if (clamped % 1 == 0) return '${clamped.toInt()}%';
    return '${clamped.toStringAsFixed(1)}%';
  }

  Widget _buildProgressBar({
    required double factor,
    required double height,
    required Color backgroundColor,
    required Color fillColor,
    double? width,
  }) {
    final clampedFactor = factor.clamp(0.0, 1.0);

    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final radius = BorderRadius.circular(height / 2);
          final fillWidth = maxWidth.isFinite && clampedFactor > 0
              ? min(maxWidth, max(maxWidth * clampedFactor, height))
              : 0.0;

          return Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: radius,
            ),
            alignment: Alignment.centerLeft,
            child: fillWidth <= 0
                ? null
                : Container(
                    width: fillWidth,
                    height: height,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: radius,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentBudgetCard(
    BuildContext context,
    MonthlyStats current,
    String Function(int) format,
    double scale,
  ) {
    final categorySpendAmounts = current.categorySpendAmounts
        .where((categorySpend) => categorySpend.amount > 0)
        .toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: _cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22 * scale),
        child: InkWell(
          onTap: () async {
            final changed = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) =>
                    MonthlySpendingDetailScreen(yearMonth: current.yearMonth),
              ),
            );
            if (changed == true && mounted) {
              setState(() => _hasDataChanged = true);
            }
          },
          borderRadius: BorderRadius.circular(22 * scale),
          highlightColor: Colors.black.withAlpha(25),
          splashColor: Colors.black.withAlpha(15),
          child: Ink(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22 * scale),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${format(current.budgetAmount)}원',
                      style: TextStyle(fontSize: 27 * scale, fontWeight: FontWeight.w600, color : Color(0xFF333333)),
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
                              horizontal: 13 * scale, vertical: 5 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFF999999)),
                            borderRadius: BorderRadius.circular(20 * scale),
                          ),
                          child: Text(
                            '예산 수정',
                            style: TextStyle(
                                fontSize: 15 * scale, color: Color(0xFF333333), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20 * scale),
                _buildProgressBar(
                  factor: current.progressFactor,
                  height: 18 * scale,
                  backgroundColor: const Color(0xFFF2F2F2),
                  fillColor:
                      current.isExceeded ? AppColors.red_200 : AppColors.skyBlue_200,
                ),
                SizedBox(height: 12 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${format(current.spentAmount)}원',
                      style: TextStyle(fontSize: 16 * scale, color: AppColors.textPrimary, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      '${format(current.budgetAmount)}원',
                      style: TextStyle(fontSize: 16 * scale, color: AppColors.textPrimary, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                if (categorySpendAmounts.isNotEmpty) ...[
                  SizedBox(height: 20 * scale),
                  ...categorySpendAmounts.map(
                    (categorySpend) => _buildCategorySpendRow(
                      label: WishlistCategoryUi.toUiLabel(categorySpend.category),
                      amount: categorySpend.amount,
                      totalSpent: current.spentAmount,
                      format: format,
                      scale: scale,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySpendRow({
    required String label,
    required int amount,
    required int totalSpent,
    required String Function(int) format,
    required double scale,
  }) {
    final factor =
        totalSpent > 0 ? (amount / totalSpent).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: 10 * scale),
      child: Row(
        children: [
          SizedBox(
            width: 48 * scale,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF555555),
              ),
            ),
          ),
          SizedBox(width: 10 * scale),
          _buildProgressBar(
            factor: factor,
            width: 176 * scale,
            height: 8 * scale,
            backgroundColor: const Color(0xFFF1F1F1),
            fillColor: const Color(0xFFC0C0C0),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              '${format(amount)}원',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyRecordCard(
    BuildContext context,
    MonthlyStats record,
    String Function(int) format,
    double scale,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22 * scale),
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
          borderRadius: BorderRadius.circular(22 * scale),
          highlightColor: Colors.black.withAlpha(25),
          splashColor: Colors.black.withAlpha(15),
          child: Ink(
            padding: EdgeInsets.symmetric(vertical: 22, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22 * scale),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      record.displayMonth,
                      style: TextStyle(
                        fontSize: 17 * scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8 * scale, vertical: 4 * scale),
                      decoration: BoxDecoration(
                        color: record.isExceeded
                            ? Color(0xFFF9DEDE)
                            : AppColors.skyBlue_000_clicked,
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                      child: Text(
                        record.isExceeded ? '예산초과' : '예산 내',
                        style: TextStyle(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w500,
                          color: record.isExceeded
                              ? AppColors.red_400
                              : AppColors.skyBlue_300,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${format(record.spentAmount)}원',
                      style:
                          TextStyle(fontSize: 27 * scale, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                    ),
                    Transform.translate(
                      offset: Offset(0, -2 * scale),
                      child: Text(
                        '/${format(record.budgetAmount)}원',
                        style: TextStyle(
                            fontSize: 15 * scale, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * scale),
                _buildProgressBar(
                  factor: record.progressFactor,
                  height: 18 * scale,
                  backgroundColor: const Color(0xFFF2F2F2),
                  fillColor: record.isExceeded
                      ? AppColors.red_200
                      : AppColors.skyBlue_200,
                ),
                SizedBox(height: 20 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '합리적 선택률 : ',
                          style: TextStyle(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _formatRationalChoiceRate(record.rationalChoiceRate),
                          style: TextStyle(
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '비합리적 선택 : ',
                          style: TextStyle(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${record.irrationalChoiceCount}회',
                          style: TextStyle(
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
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
    final initialText = _formatAmount(widget.currentBudget);
    _controller = TextEditingController(text: initialText)
      ..selection = TextSelection.collapsed(offset: initialText.length);
    _digits = widget.currentBudget.toString();
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
              '현재 예산 ${_formatAmount(widget.currentBudget)}원',
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
              suffixText: '원',
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
                  child: PressPillButton(
                    height: 57 * scale,
                    borderRadius: 57 * scale,
                    defaultColor: PressPillButton.greyDefault,
                    pressedColor: PressPillButton.greyPressed,
                    onTap: () => Navigator.of(context).pop(),
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
                SizedBox(width: 6 * scale),
                Expanded(
                  child: PressPillButton(
                    height: 57 * scale,
                    borderRadius: 57 * scale,
                    defaultColor: _canSave
                        ? PressPillButton.blueDefault
                        : PressPillButton.blueDefault.withValues(alpha: 0.6),
                    pressedColor: PressPillButton.bluePressed,
                    onTap: _canSave ? _handleSave : null,
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
