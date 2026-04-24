import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class WishlistItemCard extends StatelessWidget {
  const WishlistItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onDelete,
    this.onShare,
  });

  final WishlistPlaceholder item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Slidable(
        key: ValueKey(item),
        // 슬라이드 방향 설정 (오른쪽에서 버튼이 나옴)
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.5, // 슬라이드 버튼 영역 너비 비중
          children: [
            // 공유 버튼 (파란색)
            Expanded(
              child: GestureDetector(
                onTap: () => onShare?.call(),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3BA2EA),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    border: Border.all(color: const Color(0xFF7A7A7A), width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.reply, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
            // 삭제 버튼 (빨간색)
            Expanded(
              child: GestureDetector(
                onTap: () => onDelete?.call(),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE54327),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    border: Border.all(color: const Color(0xFF7A7A7A), width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.close, color: Colors.black, size: 30),
                  ),
                ),
              ),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF7A7A7A), width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBE9FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF3BA2EA), width: 2),
                    ),
                    child: const Text(
                      '상품\n사진',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${_formatPrice(item.price)}원',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatPrice(int value) {
  final chars = value.toString().split('').reversed.toList();
  final buffer = StringBuffer();
  for (var i = 0; i < chars.length; i++) {
    if (i != 0 && i % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(chars[i]);
  }
  return buffer.toString().split('').reversed.join();
}