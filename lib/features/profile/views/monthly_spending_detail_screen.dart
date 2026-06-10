import 'dart:math';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/profile/models/wish_history_item.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_category_ui.dart';
import 'package:fe_app/features/profile/providers/consumption_stats_provider.dart';
import 'package:fe_app/features/profile/providers/monthly_consumption_provider.dart';
import 'package:fe_app/features/profile/utils/month_display.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
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
    final consumptionState = ref.watch(monthlyConsumptionProvider(widget.yearMonth));
    final displayMonth = yearMonthToDisplay(widget.yearMonth);
    final monthTitle = displayMonth.contains('.')
        ? displayMonth.split('.')[1]
        : displayMonth;

    ref.listen<MonthlyConsumptionState>(
      monthlyConsumptionProvider(widget.yearMonth),
      (prev, next) {
        if (!mounted) return;
        if (prev?.errorMessage != next.errorMessage && next.errorMessage != null) {
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

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 18 * scale),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '$monthTitle월의 소비 기록',
          style: TextStyle(
            color: AppColors.textPrimary,
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
                      .read(monthlyConsumptionProvider(widget.yearMonth).notifier)
                      .load(force: true),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(24 * scale),
                      padding: EdgeInsets.all(24 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30 * scale),
                        boxShadow: _cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$monthTitle월의 지출',
                            style: TextStyle(
                                fontSize: 16 * scale, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20 * scale),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${format(record.spentAmount)}원',
                                style: TextStyle(
                                    fontSize: 24 * scale,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '/${format(record.budgetAmount)}원',
                                style: TextStyle(
                                  color: const Color(0xFFADADAD),
                                  fontSize: 14 * scale,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16 * scale),
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
                          if (record.restrainedAmount > 0) ...[
                            SizedBox(height: 16 * scale),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '절제한 금액',
                                  style: TextStyle(
                                      fontSize: 13 * scale,
                                      color: AppColors.textSecondary),
                                ),
                                Text(
                                  '${format(record.restrainedAmount)}원',
                                  style: TextStyle(
                                      fontSize: 13 * scale,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: 24 * scale),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '예산 사용률 : ${record.usageRate}%',
                                style: TextStyle(
                                    fontSize: 14 * scale,
                                    color: AppColors.textSecondary),
                              ),
                              Text(
                                '구매 : ${record.boughtCount}회 · 참음 : ${record.restrainedCount}회',
                                style: TextStyle(
                                    fontSize: 14 * scale,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$monthTitle월의 소비기록',
                            style: TextStyle(
                                fontSize: 16 * scale, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16 * scale),
                          if (consumptionState.isLoading &&
                              consumptionState.items.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 40),
                              child: LoadingIndicator(compact: true),
                            )
                          else if (consumptionState.items.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: 40 * scale),
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
                          SizedBox(height: 40 * scale),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: _cardShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(12 * scale),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10 * scale),
              child: Container(
                width: 60 * scale,
                height: 60 * scale,
                color: const Color(0xFFF2F2F2),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 60 * scale,
                        height: 60 * scale,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImagePlaceholder(scale),
                      )
                    : _buildImagePlaceholder(scale),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                        fontSize: 13 * scale, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (price != null) ...[
                    SizedBox(height: 4 * scale),
                    Text(
                      '${price.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ",")}원',
                      style: TextStyle(
                          fontSize: 12 * scale, color: AppColors.textSecondary),
                    ),
                  ],
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      _buildTag(
                        item.isGo ? '샀어요' : '참았어요',
                        item.isGo ? AppColors.yellow : const Color(0xFFE8F3F9),
                        scale,
                      ),
                      SizedBox(width: 4 * scale),
                      _buildTag(
                        WishlistCategoryUi.toUiLabel(item.category),
                        const Color(0xFFF2F2F2),
                        scale,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (item.canEditDecision)
              Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isUpdating ? null : () => _showEditDialog(context, item),
                borderRadius: BorderRadius.circular(15 * scale),
                highlightColor: Colors.black.withAlpha(25),
                splashColor: Colors.black.withAlpha(15),
                child: Ink(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12 * scale, vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(15 * scale),
                  ),
                  child: isUpdating
                      ? SizedBox(
                          width: 14 * scale,
                          height: 14 * scale,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          '수정',
                          style: TextStyle(
                              fontSize: 12 * scale,
                              color: AppColors.textSecondary),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(double scale) {
    return Center(
      child: Text(
        '상품 사진',
        style: TextStyle(fontSize: 8 * scale, color: Colors.grey),
      ),
    );
  }

  Widget _buildTag(String label, Color color, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10 * scale, fontWeight: FontWeight.bold),
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
                  GestureDetector(
                    onTap: isSubmitting
                        ? null
                        : () async {
                            final ok = await ref
                                .read(monthlyConsumptionProvider(widget.yearMonth)
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
                    child: Container(
                      width: double.infinity,
                      height: 57 * scale,
                      decoration: BoxDecoration(
                        color: isSubmitting
                            ? AppColors.skyBlue_100.withValues(alpha: 0.6)
                            : AppColors.skyBlue_100,
                        borderRadius: BorderRadius.circular(57 * scale),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '저장하기',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.w600,
                        ),
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
