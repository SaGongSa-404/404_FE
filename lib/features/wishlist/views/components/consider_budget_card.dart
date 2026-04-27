import 'package:flutter/material.dart';

class ConsiderBudgetCard extends StatelessWidget {
  const ConsiderBudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBE9FF), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이번달 예산',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBox('지금', '90,000원', 0.18, const Color(0xFFF9EDE3)),
              const Icon(Icons.arrow_forward, color: Color(0xFF3BA2EA)),
              _buildStatusBox('구매 시', '115,000원', 0.23, const Color(0xFFCBE9FF), isHighlight: true),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('추가 부담', style: TextStyle(fontSize: 16)),
              Text('+25,000원', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3BA2EA))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE0E0E0)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('남은 예산', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Text('385,000원', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFBCF4CD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('여유있음', style: TextStyle(fontSize: 12, color: Color(0xFF2D6A4F), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBox(String title, String price, double percent, Color bgColor, {bool isHighlight = false}) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isHighlight ? Border.all(color: const Color(0xFF3BA2EA), width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF3BA2EA), fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white,
              color: const Color(0xFF3BA2EA),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text('${(percent * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}