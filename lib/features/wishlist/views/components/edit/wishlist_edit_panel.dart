import 'dart:math' as math;

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WishlistEditPanel extends StatefulWidget {
  const WishlistEditPanel({
    super.key,
    required this.item,
    required this.onClose,
    required this.onSave,
    this.onDelete,
  });

  final WishlistPlaceholder item;
  final VoidCallback onClose;
  final ValueChanged<WishlistPlaceholder> onSave;
  final VoidCallback? onDelete;

  @override
  State<WishlistEditPanel> createState() => _WishlistEditPanelState();
}

class _WishlistEditPanelState extends State<WishlistEditPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  late final TextEditingController _linkController;
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late String _selectedCategory;

  static const double _sheetTopRadius = 22;
  static const Color _wishlistCardShadowColor = Color(0x22000000);
  static const double _wishlistCardShadowBlur = 4;
  static const double _fieldPillRadius = 30;
  static const double _categoryChipGap = 12;
  static const double _categoryRowGap = 8;
  static const double _beforeSaveButtonGap = 56;
  static const double _extraTopGap = 52;
  static const List<String> _editCategories = ['패션', '뷰티', '라이프', '디지털', '기타'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curved);

    _linkController = TextEditingController(text: widget.item.link);
    _nameController = TextEditingController(text: widget.item.title);
    _priceController = TextEditingController(text: _formatPrice(widget.item.price));
    _selectedCategory = _editCategories.contains(widget.item.category)
        ? widget.item.category
        : _editCategories.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _linkController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _playDismiss() => _controller.reverse();

  Future<void> _dismiss() async {
    await _playDismiss();
    if (mounted) widget.onClose();
  }

  Future<void> _save() async {
    final parsedPrice = int.tryParse(_priceController.text.replaceAll(',', '').trim());
    final updated = widget.item.copyWith(
      link: _linkController.text.trim(),
      title: _nameController.text.trim().isEmpty ? widget.item.title : _nameController.text.trim(),
      price: parsedPrice ?? widget.item.price,
      category: _selectedCategory,
    );
    await _playDismiss();
    if (!mounted) return;
    widget.onSave(updated);
    widget.onClose();
  }

  Future<void> _delete() async {
    await _playDismiss();
    if (!mounted) return;
    widget.onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topInset = mq.padding.top;
    final bottomInset = mq.padding.bottom;
    final screenH = mq.size.height;
    final spaceBelowStatus = screenH - topInset - _extraTopGap;
    final maxSheetHeight = math.min(screenH * 0.82, math.max(200.0, spaceBelowStatus));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: AppColors.white,
                child: SizedBox(height: topInset),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _dismiss,
                  child: const ColoredBox(color: Color(0x59000000)),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slide,
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxSheetHeight),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(_sheetTopRadius)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _header(context),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(24, 56, 24, 88 + bottomInset),
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildField(label: '링크', controller: _linkController),
                                const SizedBox(height: 24),
                                _buildField(label: '상품명', controller: _nameController),
                                const SizedBox(height: 24),
                                _buildField(
                                  label: '가격',
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  suffix: '원',
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  '카테고리',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _categoryGridThreePerRow(),
                                SizedBox(height: _beforeSaveButtonGap),
                                _footerSaveButton(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: _dismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: const Icon(Icons.close, size: 26, color: AppColors.textPrimary),
          ),
          const Spacer(),
          if (widget.onDelete != null)
            TextButton(
              onPressed: _delete,
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFD46868),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text(
                '삭제하기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _footerSaveButton() {
    return Material(
      color: AppColors.skyBlue_100,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _save,
        child: const SizedBox(
          width: double.infinity,
          height: 54,
          child: Center(
            child: Text(
              '수정완료',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// `CategoryFilter`와 동일 색·테두리·타이포, 한 줄에 3개.
  Widget _categoryGridThreePerRow() {
    final rows = <Widget>[];
    for (var i = 0; i < _editCategories.length; i += 3) {
      final end = (i + 3 > _editCategories.length) ? _editCategories.length : i + 3;
      final chunk = _editCategories.sublist(i, end);
      final isLastRow = end >= _editCategories.length;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: isLastRow ? 0 : _categoryRowGap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var j = 0; j < 3; j++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: j == 0 ? 0 : _categoryChipGap / 2,
                      right: j == 2 ? 0 : _categoryChipGap / 2,
                    ),
                    child: j < chunk.length
                        ? _categoryChipFilterStyle(chunk[j])
                        : const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  Widget _categoryChipFilterStyle(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F3F9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.skyBlue_100 : const Color(0xFFD0D0D0),
            width: 1,
          ),
        ),
        child: Text(
          category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          strutStyle: const StrutStyle(
            fontSize: 16,
            height: 1.2,
            leadingDistribution: TextLeadingDistribution.even,
            forceStrutHeight: true,
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(_fieldPillRadius),
            boxShadow: const [
              BoxShadow(
                color: _wishlistCardShadowColor,
                blurRadius: _wishlistCardShadowBlur,
                spreadRadius: 0,
                offset: Offset.zero,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_fieldPillRadius),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: keyboardType == TextInputType.number
                  ? <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      _PriceTextInputFormatter(),
                    ]
                  : null,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.white,
                suffixText: suffix,
                suffixStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_fieldPillRadius),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_fieldPillRadius),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_fieldPillRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
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
