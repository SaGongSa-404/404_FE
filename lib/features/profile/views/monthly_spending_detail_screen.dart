import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MonthlySpendingDetailScreen extends ConsumerWidget {
  final String month;

  const MonthlySpendingDetailScreen({super.key, required this.month});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);
    final profile = ref.watch(profileNotifierProvider);
    final record = profile.monthlyRecords.firstWhere((r) => r.month == month);

    final numberFormat = RegExp(r'\B(?=(\d{3})+(?!\d))');
    String format(int val) => val.toString().replaceAllMapped(numberFormat, (m) => ',');

    final monthTitle = month.contains('.') ? month.split('.')[1] : month;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18 * scale),
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
      body: SingleChildScrollView(
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
                    style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${format(record.spentAmount)}원',
                        style: TextStyle(fontSize: 24 * scale, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '/${format(record.budget)}원',
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
                      widthFactor: (record.spentAmount / record.budget).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: record.isExceeded ? AppColors.red_200 : AppColors.skyBlue_200,
                          borderRadius: BorderRadius.circular(6 * scale),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  _buildCategoryRow('패션', 45000, 0.4, scale),
                  _buildCategoryRow('뷰티', 15000, 0.2, scale),
                  _buildCategoryRow('기타', 27000, 0.3, scale),
                  SizedBox(height: 24 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '합리적 선택률 : ${record.rationalRate}%',
                        style: TextStyle(fontSize: 14 * scale, color: AppColors.textSecondary),
                      ),
                      Text(
                        '비합리적 선택 : ${record.irrationalCount}회',
                        style: TextStyle(fontSize: 14 * scale, color: AppColors.textSecondary),
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
                    style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16 * scale),
                  ...record.items.map((item) => _buildItemCard(context, ref, month, item, scale)),
                  SizedBox(height: 40 * scale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String label, int amount, double ratio, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Row(
        children: [
          SizedBox(
            width: 40 * scale,
            child: Text(
              label,
              style: TextStyle(fontSize: 12 * scale, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Container(
              height: 6 * scale,
              margin: EdgeInsets.symmetric(horizontal: 8 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(3 * scale),
              ),
              child: FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(3 * scale),
                  ),
                ),
              ),
            ),
          ),
          Text(
            '${amount.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ",")}원',
            style: TextStyle(fontSize: 12 * scale, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    WidgetRef ref,
    String month,
    ConsumptionItem item,
    double scale,
  ) {
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
            Container(
              width: 60 * scale,
              height: 60 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: Center(
                child: Text(
                  '상품 사진',
                  style: TextStyle(fontSize: 8 * scale, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(fontSize: 13 * scale, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    '${item.price.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ",")}원',
                    style: TextStyle(fontSize: 12 * scale, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      _buildTag(
                        item.status == ConsumptionStatus.bought ? '샀어요' : '참았어요',
                        item.status == ConsumptionStatus.bought ? AppColors.yellow : const Color(0xFFE8F3F9),
                        scale,
                      ),
                      if (item.review != null) ...[
                        SizedBox(width: 4 * scale),
                        _buildTag(item.review!, const Color(0xFFE8F9E9), scale),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showEditDialog(context, ref, month, item),
                borderRadius: BorderRadius.circular(15 * scale),
                highlightColor: Colors.black.withAlpha(25),
                splashColor: Colors.black.withAlpha(15),
                child: Ink(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(15 * scale),
                  ),
                  child: Text(
                    '수정',
                    style: TextStyle(fontSize: 12 * scale, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ],
        ),
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

  void _showEditDialog(BuildContext context, WidgetRef ref, String month, ConsumptionItem item) {
    ConsumptionStatus selectedStatus = item.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setState) {
          final scale = responsiveScale(sheetContext);
          final horizontalInset = 21 * scale;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalInset,
              0,
              horizontalInset,
              MediaQuery.paddingOf(sheetContext).bottom + 24 * scale,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(37 * scale),
                boxShadow: _cardShadow,
              ),
              padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 31 * scale),
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
                  SizedBox(height: 20 * scale),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogButton(
                          '참았어요',
                          selectedStatus == ConsumptionStatus.refrained,
                          () => setState(() => selectedStatus = ConsumptionStatus.refrained),
                          scale,
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: _buildDialogButton(
                          '샀어요',
                          selectedStatus == ConsumptionStatus.bought,
                          () => setState(() => selectedStatus = ConsumptionStatus.bought),
                          scale,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24 * scale),
                  GestureDetector(
                    onTap: () {
                      ref.read(profileNotifierProvider.notifier).updateItemStatus(month, item.id, selectedStatus);
                      Navigator.of(sheetContext).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 57 * scale,
                      decoration: BoxDecoration(
                        color: AppColors.skyBlue_100,
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

  Widget _buildDialogButton(String label, bool isSelected, VoidCallback onTap, double scale) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16 * scale),
        highlightColor: Colors.black.withAlpha(20),
        child: Ink(
          height: 48 * scale,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8F3F9) : const Color(0xFFF5F5F5),
            border: Border.all(
              color: isSelected ? AppColors.skyBlue_300 : const Color(0xFFE0E0E0),
              width: 1.5 * scale,
            ),
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15 * scale,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.skyBlue_300 : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
