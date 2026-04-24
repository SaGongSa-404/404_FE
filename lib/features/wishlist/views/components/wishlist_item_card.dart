import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class WishlistItemCard extends StatelessWidget {
  const WishlistItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onShare,
  });

  final WishlistPlaceholder item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.5,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onShare?.call(),
              child: _buildActionButton(
                color: const Color(0xFF3BA2EA),
                icon: Icons.reply,
                isLeft: true,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onDelete?.call(),
              child: _buildActionButton(
                color: const Color(0xFFE54327),
                icon: Icons.close,
                isLeft: false,
                iconColor: Colors.black,
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
          onLongPress: onLongPress,
          child: _buildCardContent(),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required Color color,
    required IconData icon,
    required bool isLeft,
    Color iconColor = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: isLeft
            ? const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))
            : const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
        border: Border.all(color: const Color(0xFF7A7A7A), width: 2),
      ),
      child: Center(child: Icon(icon, color: iconColor, size: 30)),
    );
  }

  // 기존 카드 내용 UI
  Widget _buildCardContent() {
    return Container(
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
            child: const Text('상품\n사진', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text('${_formatPrice(item.price)}원', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPrice(int value) {
  final chars = value.toString().split('').reversed.toList();
  final buffer = StringBuffer();
  for (var i = 0; i < chars.length; i++) {
    if (i != 0 && i % 3 == 0) buffer.write(',');
    buffer.write(chars[i]);
  }
  return buffer.toString().split('').reversed.join();
}