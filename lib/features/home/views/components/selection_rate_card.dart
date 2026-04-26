import 'package:flutter/material.dart';
import 'home_info_container.dart';

class SelectionRateCard extends StatelessWidget {
  const SelectionRateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeInfoContainer(
      child: Stack(
        children: [
          const Positioned(
            top: 4, left: 8,
            child: Text('합리적 선택률', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade600, width: 6),
              ),
              child: const Center(
                child: Text('51%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}