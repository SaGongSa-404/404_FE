import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WishlistEditPanel extends StatefulWidget {
  const WishlistEditPanel({
    super.key,
    required this.item,
    required this.onClose,
    required this.onSave,
  });

  final WishlistPlaceholder item;
  final VoidCallback onClose;
  final ValueChanged<WishlistPlaceholder> onSave;

  @override
  State<WishlistEditPanel> createState() => _WishlistEditPanelState();
}

class _WishlistEditPanelState extends State<WishlistEditPanel> {
  late final TextEditingController _linkController;
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _linkController = TextEditingController(text: widget.item.link);
    _nameController = TextEditingController(text: widget.item.title);
    _priceController = TextEditingController(text: _formatPrice(widget.item.price));
    _selectedCategory = _editCategories.contains(widget.item.category)
        ? widget.item.category
        : _editCategories.first;
  }

  @override
  void dispose() {
    _linkController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onClose,
          child: Container(color: Colors.black.withOpacity(0.05)),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF7A7A7A), width: 1.5),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: widget.onClose,
                              icon: const Icon(Icons.close, size: 26),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            IconButton(
                              onPressed: _save,
                              icon: const Icon(Icons.check, size: 26),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Center(
                          child: Text(
                            '위시 수정',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildField(label: '링크', controller: _linkController),
                        const SizedBox(height: 12),
                        _buildField(label: '상품명', controller: _nameController),
                        const SizedBox(height: 12),
                        _buildField(
                          label: '가격',
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '카테고리',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _editCategories.map((category) {
                            final isSelected = _selectedCategory == category;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedCategory = category),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFCBE9FF) : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF0099FF)
                                        : const Color(0xFF666666),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: keyboardType == TextInputType.number
              ? <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  _PriceTextInputFormatter(),
                ]
              : null,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF7A7A7A), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF7A7A7A), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _save() {
    final parsedPrice = int.tryParse(_priceController.text.replaceAll(',', '').trim());
    widget.onSave(
      widget.item.copyWith(
        link: _linkController.text.trim(),
        title: _nameController.text.trim().isEmpty ? widget.item.title : _nameController.text.trim(),
        price: parsedPrice ?? widget.item.price,
        category: _selectedCategory,
      ),
    );
  }
}

const List<String> _editCategories = ['패션', '뷰티', '라이프', '디지털', '기타'];

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

class _PriceTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(',', '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final parsed = int.tryParse(digits);
    if (parsed == null) {
      return oldValue;
    }

    final formatted = _formatPrice(parsed);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
