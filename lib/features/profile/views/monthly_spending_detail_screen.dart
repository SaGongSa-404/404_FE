import 'dart:math';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/profile/models/monthly_stats.dart';
import 'package:fe_app/features/profile/models/wish_history_item.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_category_ui.dart';
import 'package:fe_app/features/profile/providers/consumption_stats_provider.dart';
import 'package:fe_app/features/profile/providers/monthly_consumption_provider.dart';
import 'package:fe_app/features/profile/utils/month_display.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
import 'package:fe_app/shared/widgets/press_pill_button.dart';
import 'package:fe_app/shared/widgets/loading_indicator.dart';
import 'package:fe_app/shared/widgets/nugul_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MonthlySpendingDetailScreen extends ConsumerStatefulWidget {
  final String yearMonth;

  const MonthlySpendingDetailScreen({super.key, required this.yearMonth});

  @override
  ConsumerState<MonthlySpendingDetailScreen> createState() =>
      _MonthlySpendingDetailScreenState();
}

class _MonthlySpendingDetailScreenState
    extends ConsumerState<MonthlySpendingDetailScreen> {
  bool _hasDataChanged = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(consumptionStatsProvider.notifier).loadMonth(widget.yearMonth);
      ref
          .read(monthlyConsumptionProvider(widget.yearMonth).notifier)
          .load(force: true);
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
    final record = statsState.statsFor(widget.yearMonth);
    final consumptionState =
        ref.watch(monthlyConsumptionProvider(widget.yearMonth));
    final displayMonth = yearMonthToDisplay(widget.yearMonth);
    final monthTitle =
        displayMonth.contains('.') ? displayMonth.split('.')[1] : displayMonth;

    ref.listen<MonthlyConsumptionState>(
      monthlyConsumptionProvider(widget.yearMonth),
      (prev, next) {
        if (!mounted) return;
        if (prev?.errorMessage != next.errorMessage &&
            next.errorMessage != null) {
          showCapsuleToast(
            context,
            backgroundColor: AppColors.red_600.withValues(alpha: 0.8),
            text: next.errorMessage!,
          );
        }
        if (prev != null &&
            !prev.budgetBecameExhausted &&
            next.budgetBecameExhausted &&
            next.errorMessage == null) {
          showCapsuleToast(
            context,
            backgroundColor: AppColors.red_600.withValues(alpha: 0.8),
            text: '예산을 초과했어요!',
          );
        }
      },
    );

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
            '$monthTitle월의 소비 기록',
            style: TextStyle(
              color: AppColors.brown,
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: record == null
            ? const NugulLoadingScreen()
            : RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    ref
                        .read(consumptionStatsProvider.notifier)
                        .refreshMonthStats(widget.yearMonth),
                    ref
                        .read(monthlyConsumptionProvider(widget.yearMonth)
                            .notifier)
                        .load(force: true),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    24 * scale,
                    18 * scale,
                    24 * scale,
                    40 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                        child: Text(
                          '$monthTitle월의 지출',
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF555555),
                          ),
                        ),
                      ),
                      SizedBox(height: 14 * scale),
                      _buildSummaryCard(record, format, scale),
                      SizedBox(height: 32 * scale),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                        child: Text(
                          '$monthTitle월의 소비기록',
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF555555),
                          ),
                        ),
                      ),
                      SizedBox(height: 14 * scale),
                      if (consumptionState.isLoading &&
                          consumptionState.items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 40, top: 40),
                          child: LoadingIndicator(compact: true),
                        )
                      else if (consumptionState.items.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                            left: 8 * scale,
                            bottom: 40 * scale,
                          ),
                          child: Text(
                            '이 달의 소비기록이 없습니다.',
                            style: TextStyle(
                              fontSize: 14 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      else
                        ...consumptionState.items.map(
                          (item) => _buildItemCard(context, item, scale),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
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

  Widget _buildSummaryCard(
    MonthlyStats record,
    String Function(int) format,
    double scale,
  ) {
    final categorySpendAmounts = record.categorySpendAmounts
        .where((categorySpend) => categorySpend.amount > 0)
        .toList();

    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 18 * scale, horizontal: 24 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${format(record.spentAmount)}원',
                style: TextStyle(
                  fontSize: 27 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -2 * scale),
                child: Text(
                  '/${format(record.budgetAmount)}원',
                  style: TextStyle(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          _buildProgressBar(
            factor: record.progressFactor,
            height: 18 * scale,
            backgroundColor: const Color(0xFFF2F2F2),
            fillColor:
                record.isExceeded ? AppColors.red_200 : AppColors.skyBlue_200,
          ),
          if (categorySpendAmounts.isNotEmpty) ...[
            SizedBox(height: 24 * scale),
            ...categorySpendAmounts.map(
              (categorySpend) => _buildCategorySpendRow(
                label: WishlistCategoryUi.toUiLabel(categorySpend.category),
                amount: categorySpend.amount,
                totalSpent: record.spentAmount,
                format: format,
                scale: scale,
              ),
            ),
          ],
          SizedBox(height: 20 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatText(
                label: '합리적 선택률 : ',
                value: _formatRationalChoiceRate(record.rationalChoiceRate),
                scale: scale,
              ),
              _buildStatText(
                label: '비합리적 선택 : ',
                value: '${record.irrationalChoiceCount}회',
                scale: scale,
              ),
            ],
          ),
        ],
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
    final factor = totalSpent > 0 ? (amount / totalSpent).clamp(0.0, 1.0) : 0.0;

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

  Widget _buildStatText({
    required String label,
    required String value,
    required double scale,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15 * scale,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20 * scale,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    WishHistoryItem item,
    double scale,
  ) {
    final consumptionState =
        ref.watch(monthlyConsumptionProvider(widget.yearMonth));
    final isUpdating = consumptionState.updatingItemId == item.itemId;
    final price = item.price;
    final imageUrl = item.imageUrl;
    final reflectionTagLabel = _reflectionTagLabel(item.reflection);
    final reflectionTagColor = _reflectionTagColor(item.reflection);

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: _cardShadow,
      ),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12 * scale),
              child: Container(
                width: 81 * scale,
                height: 81 * scale,
                color: const Color(0xFFE8E8E8),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 81 * scale,
                        height: 81 * scale,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildImagePlaceholder(scale),
                      )
                    : _buildImagePlaceholder(scale),
              ),
            ),
            SizedBox(width: 15 * scale),
            Expanded(
              child: SizedBox(
                height: 81 * scale,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF555555),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (price != null) ...[
                      SizedBox(height: 2 * scale),
                      Text(
                        '${price.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ",")}원',
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF555555),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        _buildTag(
                          item.isGo ? '샀어요' : '참았어요',
                          backgroundColor: item.isGo
                              ? const Color(0xFFFFF3D7)
                              : const Color(0xFFE8F3F9),
                          textColor: item.isGo
                              ? const Color(0xFFD19A13)
                              : const Color(0xFF6D96B2),
                          scale: scale,
                        ),
                        if (reflectionTagLabel != null &&
                            reflectionTagColor != null) ...[
                          SizedBox(width: 4 * scale),
                          _buildTag(
                            reflectionTagLabel,
                            backgroundColor: reflectionTagColor.background,
                            textColor: reflectionTagColor.text,
                            scale: scale,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (item.canEditDecision) SizedBox(width: 10 * scale),
            if (item.canEditDecision)
              SizedBox(
                height: 81 * scale,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isUpdating
                          ? null
                          : () => _showEditDialog(context, item),
                      borderRadius: BorderRadius.circular(18 * scale),
                      highlightColor: Colors.black.withAlpha(25),
                      splashColor: Colors.black.withAlpha(15),
                      child: Ink(
                        padding: EdgeInsets.symmetric(
                            horizontal: 13 * scale, vertical: 6 * scale),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF999999)),
                          borderRadius: BorderRadius.circular(55 * scale),
                        ),
                        child: isUpdating
                            ? SizedBox(
                                width: 14 * scale,
                                height: 14 * scale,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : Text(
                                '수정',
                                style: TextStyle(
                                  fontSize: 15 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String? _reflectionTagLabel(WishHistoryReflection? reflection) {
    if (reflection == null) return null;
    final regretLevel = reflection.regretLevel.toUpperCase();
    if (regretLevel.contains('REGRET') || regretLevel.contains('BAD')) {
      return '후회해요';
    }
    if (regretLevel.contains('NEUTRAL') || regretLevel.contains('NORMAL')) {
      return '그냥 그래요';
    }
    if (regretLevel.contains('GOOD') || regretLevel.contains('NONE')) {
      return '잘했어요';
    }

    final score = reflection.satisfactionScore;
    if (score == null) return null;
    if (score >= 4) return '잘했어요';
    if (score >= 2) return '그냥 그래요';
    return '후회해요';
  }

  ({Color background, Color text})? _reflectionTagColor(
      WishHistoryReflection? reflection) {
    final label = _reflectionTagLabel(reflection);
    return switch (label) {
      '잘했어요' => (
          background: const Color(0xFFE1F7E0),
          text: const Color(0xFF6DA767),
        ),
      '그냥 그래요' => (
          background: const Color(0xFFEFEDFD),
          text: const Color(0xFF9D83AD),
        ),
      '후회해요' => (
          background: const Color(0xFFF7E0E1),
          text: const Color(0xFFA76768),
        ),
      _ => null,
    };
  }

  Widget _buildImagePlaceholder(double scale) {
    return Center(
      child: Icon(
        Icons.photo_camera,
        size: 45 * scale,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTag(
    String label, {
    required Color backgroundColor,
    required Color textColor,
    required double scale,
  }) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 5 * scale),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(33 * scale),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15 * scale,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WishHistoryItem item) {
    var selectedGo = item.isGo;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final scale = responsiveScale(sheetContext);
          final horizontalInset = 21 * scale;
          final consumptionState =
              ref.watch(monthlyConsumptionProvider(widget.yearMonth));
          final isSubmitting = consumptionState.updatingItemId == item.itemId;

          final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
          final systemBottomPadding = MediaQuery.paddingOf(sheetContext).bottom;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalInset,
              0,
              horizontalInset,
              max(systemBottomPadding, bottomInset) + 24 * scale,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(37 * scale),
                boxShadow: _cardShadow,
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 24 * scale, vertical: 31 * scale),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '결정을 바꾸시겠습니까?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 32 * scale),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogButton(
                          '참았어요',
                          !selectedGo,
                          () => setSheetState(() => selectedGo = false),
                          scale,
                        ),
                      ),
                      SizedBox(width: 6 * scale),
                      Expanded(
                        child: _buildDialogButton(
                          '샀어요',
                          selectedGo,
                          () => setSheetState(() => selectedGo = true),
                          scale,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10 * scale),
                  PressPillButton(
                    height: 57 * scale,
                    borderRadius: 57 * scale,
                    defaultColor: isSubmitting
                        ? PressPillButton.blueDefault.withValues(alpha: 0.6)
                        : PressPillButton.blueDefault,
                    pressedColor: PressPillButton.bluePressed,
                    onTap: isSubmitting
                        ? null
                        : () async {
                            final ok = await ref
                                .read(
                                    monthlyConsumptionProvider(widget.yearMonth)
                                        .notifier)
                                .updateDecisionResult(
                                  item: item,
                                  toGo: selectedGo,
                                );
                            if (!sheetContext.mounted) return;
                            if (ok) {
                              Navigator.of(sheetContext).pop();
                              if (context.mounted) {
                                showCapsuleToast(
                                  context,
                                  backgroundColor: const Color(0xFF5F8EAE),
                                  text: '수정되었습니다',
                                );
                              }
                            }
                          },
                    child: Text(
                      '저장하기',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogButton(
      String label, bool isSelected, VoidCallback onTap, double scale) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 57 * scale,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.background : AppColors.white,
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE0E0E0), width: 1),
          borderRadius: BorderRadius.circular(57 * scale),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
