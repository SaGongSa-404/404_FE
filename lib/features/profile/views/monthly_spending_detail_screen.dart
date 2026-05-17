import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MonthlySpendingDetailScreen extends ConsumerWidget {
  final String month;

  const MonthlySpendingDetailScreen({super.key, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider);
    final record = profile.monthlyRecords.firstWhere((r) => r.month == month);

    final numberFormat = RegExp(r'\B(?=(\d{3})+(?!\d))');
    String format(int val) => val.toString().replaceAllMapped(numberFormat, (m) => ',');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${month.split('.')[1]}월의 소비 기록',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 지출 요약 카드
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${month.split('.')[1]}월의 지출', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${format(record.spentAmount)}원', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('/${format(record.budget)}원', style: const TextStyle(color: Color(0xFFADADAD), fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 24),
                  _buildCategoryRow('패션', 45000, 0.4),
                  _buildCategoryRow('뷰티', 15000, 0.2),
                  _buildCategoryRow('기타', 27000, 0.3),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('합리적 선택률 : ${record.rationalRate}%', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      Text('비합리적 선택 : ${record.irrationalCount}회', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            // 아이템 리스트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${month.split('.')[1]}월의 소비기록', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...record.items.map((item) => _buildItemCard(context, ref, month, item)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String label, int amount, double ratio) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
            child: Container(
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(3)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio,
                child: Container(decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(3))),
              ),
            ),
          ),
          Text('${amount.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ",")}원', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, WidgetRef ref, String month, ConsumptionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('상품 사진', style: TextStyle(fontSize: 8, color: Colors.grey))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${item.price.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ",")}원', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTag(item.status == ConsumptionStatus.bought ? '샀어요' : '참았어요', item.status == ConsumptionStatus.bought ? AppColors.yellow : const Color(0xFFE8F3F9)),
                    if (item.review != null) ...[
                      const SizedBox(width: 4),
                      _buildTag(item.review!, const Color(0xFFE8F9E9)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showEditDialog(context, ref, month, item),
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              side: const BorderSide(color: Color(0xFFE0E0E0)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('수정', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, String month, ConsumptionItem item) {
    ConsumptionStatus selectedStatus = item.status;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('결정을 바꾸시겠습니까?', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Row(
            children: [
              Expanded(
                child: _buildDialogButton('참았어요', selectedStatus == ConsumptionStatus.refrained, () => setState(() => selectedStatus = ConsumptionStatus.refrained)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDialogButton('샀어요', selectedStatus == ConsumptionStatus.bought, () => setState(() => selectedStatus = ConsumptionStatus.bought)),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(profileNotifierProvider.notifier).updateItemStatus(month, item.id, selectedStatus);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.skyBlue_100,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('저장하기', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2F2F2) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? AppColors.textPrimary : const Color(0xFFF2F2F2)),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: isSelected ? AppColors.textPrimary : Colors.grey)),
      ),
    );
  }
}
