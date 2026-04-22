import 'package:flutter/material.dart';
import 'home_info_container.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeInfoContainer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(60),
          border: Border.all(color: Colors.grey.shade400, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('예산현황', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('50,000 / 250,000', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            _buildGaugeBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildGaugeBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF42D2B1),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6)),
            border: Border.all(color: const Color(0xFF2A9D8F), width: 1.5),
          ),
        ),
        Container(
          width: 120, height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFFBDE4FF),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
            border: Border.all(color: Colors.blue, width: 1.5),
          ),
        ),
      ],
    );
  }
}