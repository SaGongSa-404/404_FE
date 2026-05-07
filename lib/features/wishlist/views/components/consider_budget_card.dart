import 'package:flutter/material.dart';
import 'package:fe_app/core/theme/app_theme.dart';

class ConsiderBudgetCard extends StatelessWidget {
  const ConsiderBudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF2F2F2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('다음 달 예산', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  Text('500,000원', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar
              Stack(
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.23,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE58D8D), // 약간 붉은 계열
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Color(0xFFE0E0E0)),
                      const SizedBox(width: 4),
                      const Text('현재 90,000원', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 12),
                      const Icon(Icons.circle, size: 8, color: Color(0xFFE58D8D)),
                      const SizedBox(width: 4),
                      const Text('+25,000원', style: TextStyle(fontSize: 12, color: Color(0xFFE58D8D))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '예산의 23%',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('여유 있음', style: TextStyle(fontSize: 12, color: AppColors.skyBlue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildInfoTile('기회비용', '라떼 6잔', '25,000원으로\n살 수 있어요')),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoTile('소비이력', '0원', '지난 달 패션\n구매 이력이 없어요')),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String value, String sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3)),
        ],
      ),
    );
  }
}
