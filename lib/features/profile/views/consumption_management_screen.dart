import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/profile/providers/profile_provider.dart';
import 'package:fe_app/features/profile/views/monthly_spending_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ConsumptionManagementScreen extends ConsumerWidget {
  const ConsumptionManagementScreen({super.key});

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

    final numberFormat = RegExp(r'\B(?=(\d{3})+(?!\d))');
    String format(int val) => val.toString().replaceAllMapped(numberFormat, (m) => ',');

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
          '소비 관리',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이번 달 예산',
              style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16 * scale),
            _buildCurrentBudgetCard(context, ref, profile.currentMonthRecord, format, scale),
            SizedBox(height: 40 * scale),
            Text(
              '월별 소비기록',
              style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16 * scale),
            ...profile.monthlyRecords.map(
              (record) => _buildMonthlyRecordCard(context, record, format, scale),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBudgetCard(
    BuildContext context,
    WidgetRef ref,
    MonthlyRecord current,
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
                '${format(current.budget)}원',
                style: TextStyle(fontSize: 24 * scale, fontWeight: FontWeight.bold),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showBudgetEditDialog(context, ref, current.budget),
                  borderRadius: BorderRadius.circular(20 * scale),
                  highlightColor: Colors.black.withAlpha(25),
                  splashColor: Colors.black.withAlpha(15),
                  child: Ink(
                    padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(20 * scale),
                    ),
                    child: Text(
                      '예산 수정',
                      style: TextStyle(fontSize: 12 * scale, color: AppColors.textSecondary),
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
              widthFactor: (current.spentAmount / current.budget).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: current.isExceeded ? AppColors.red_200 : AppColors.skyBlue_200,
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
                '${format(current.budget)}원',
                style: TextStyle(fontSize: 14 * scale, color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 24 * scale),
          _buildMinimalCategoryRow('패션', current.budget, 45000, scale),
          _buildMinimalCategoryRow('뷰티', current.budget, 15000, scale),
          _buildMinimalCategoryRow('기타', current.budget, 27000, scale),
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

  Widget _buildMinimalCategoryRow(String label, int total, int amount, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 12 * scale, color: AppColors.textSecondary)),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Container(
              height: 4 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(2 * scale),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (amount / total).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(2 * scale),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Text(
            '${amount.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ",")}원',
            style: TextStyle(fontSize: 12 * scale, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyRecordCard(
    BuildContext context,
    MonthlyRecord record,
    String Function(int) format,
    double scale,
  ) {
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
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MonthlySpendingDetailScreen(month: record.month),
            ),
          ),
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
                    Text(
                      record.month,
                      style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                      decoration: BoxDecoration(
                        color: record.isExceeded ? AppColors.red_100 : const Color(0xFFE8F3F9),
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                      child: Text(
                        record.isExceeded ? '예산초과' : '예산 내',
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.bold,
                          color: record.isExceeded ? AppColors.red_400 : AppColors.skyBlue_300,
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
                      style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '/${format(record.budget)}원',
                      style: TextStyle(fontSize: 13 * scale, color: const Color(0xFFADADAD)),
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
                    widthFactor: (record.spentAmount / record.budget).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: record.isExceeded ? AppColors.red_200 : AppColors.skyBlue_200,
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
                      '합리적 선택률 : ${record.rationalRate}%',
                      style: TextStyle(fontSize: 13 * scale, color: AppColors.textSecondary),
                    ),
                    Text(
                      '비합리적 선택 : ${record.irrationalCount}회',
                      style: TextStyle(fontSize: 13 * scale, color: AppColors.textSecondary),
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

  void _showBudgetEditDialog(BuildContext context, WidgetRef ref, int currentBudget) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
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
                  '현재 예산 ${currentBudget.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ",")}',
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
                SizedBox(height: 16 * scale),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '입력하기',
                    hintStyle: const TextStyle(color: Color(0xFFADADAD)),
                    filled: true,
                    fillColor: const Color(0xFFF2F2F2),
                    contentPadding: EdgeInsets.symmetric(vertical: 14 * scale),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25 * scale),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25 * scale),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25 * scale),
                      borderSide: BorderSide(color: AppColors.textPrimary, width: 1.5 * scale),
                    ),
                  ),
                ),
                SizedBox(height: 20 * scale),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(sheetContext).pop(),
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
                        onTap: () {
                          final newBudget = int.tryParse(controller.text.replaceAll(',', ''));
                          if (newBudget != null) {
                            ref.read(profileNotifierProvider.notifier).updateBudget(newBudget);
                            Navigator.of(sheetContext).pop();
                          }
                        },
                        child: Container(
                          height: 57 * scale,
                          decoration: BoxDecoration(
                            color: AppColors.skyBlue_100,
                            borderRadius: BorderRadius.circular(57 * scale),
                          ),
                          alignment: Alignment.center,
                          child: Text(
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
      },
    );
  }
}
