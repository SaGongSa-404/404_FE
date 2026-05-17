import 'package:fe_app/core/theme/app_theme.dart';
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
    final profile = ref.watch(profileNotifierProvider);

    final numberFormat = RegExp(r'\B(?=(\d{3})+(?!\d))');
    String format(int val) => val.toString().replaceAllMapped(numberFormat, (m) => ',');

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '소비 관리',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이번 달 예산',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCurrentBudgetCard(context, ref, profile.currentMonthRecord, format),
            const SizedBox(height: 40),
            const Text(
              '월별 소비기록',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...profile.monthlyRecords.map(
                  (record) => _buildMonthlyRecordCard(context, record, format),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBudgetCard(BuildContext context, WidgetRef ref, MonthlyRecord current, String Function(int) format) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${format(current.budget)}원', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showBudgetEditDialog(context, ref, current.budget),
                  borderRadius: BorderRadius.circular(20),
                  highlightColor: Colors.black.withAlpha(25),
                  splashColor: Colors.black.withAlpha(15),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '예산 수정',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(8)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (current.spentAmount / current.budget).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: current.isExceeded ? AppColors.red_200 : AppColors.skyBlue_200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${format(current.spentAmount)}원', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              Text('${format(current.budget)}원', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 24),
          _buildMinimalCategoryRow('패션', current.budget, 45000),
          _buildMinimalCategoryRow('뷰티', current.budget, 15000),
          _buildMinimalCategoryRow('기타', current.budget, 27000),
          if (current.isExceeded) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFFFFEBEB), borderRadius: BorderRadius.circular(10)),
              child: const Text('⚠️ 예산을 초과했어요!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.red_400, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMinimalCategoryRow(String label, int total, int amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(2)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (amount / total).clamp(0.0, 1.0),
                child: Container(decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(2))),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('${amount.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ",")}원', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildMonthlyRecordCard(BuildContext context, MonthlyRecord record, String Function(int) format) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MonthlySpendingDetailScreen(month: record.month))),
          borderRadius: BorderRadius.circular(30),
          highlightColor: Colors.black.withAlpha(25),
          splashColor: Colors.black.withAlpha(15),
          child: Ink(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(record.month, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: record.isExceeded ? AppColors.red_100 : const Color(0xFFE8F3F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        record.isExceeded ? '예산초과' : '예산 내',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: record.isExceeded ? AppColors.red_400 : AppColors.skyBlue_300),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${format(record.spentAmount)}원', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('/${format(record.budget)}원', style: const TextStyle(fontSize: 13, color: Color(0xFFADADAD))),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(6)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (record.spentAmount / record.budget).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: record.isExceeded ? AppColors.red_200 : AppColors.skyBlue_200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('합리적 선택률 : ${record.rationalRate}%', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text('비합리적 선택 : ${record.irrationalCount}회', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // [수정] 다이얼로그의 버튼 디자인, 폰트, 온클릭 피드백 완벽 통일
  void _showBudgetEditDialog(BuildContext context, WidgetRef ref, int currentBudget) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '현재 예산 ${currentBudget.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ",")}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                '수정할 예산을 입력해주세요',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '입력하기',
                  hintStyle: const TextStyle(color: Color(0xFFADADAD)),
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: AppColors.textPrimary, width: 1.5)),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  // 취소 버튼
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => context.pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2F2F2),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 수정완료 버튼
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          final newBudget = int.tryParse(controller.text.replaceAll(',', ''));
                          if (newBudget != null) {
                            ref.read(profileNotifierProvider.notifier).updateBudget(newBudget);
                            context.pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.skyBlue_100, // 브랜드 정체성에 맞춘 디자인 컬러톤
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          '수정완료',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}