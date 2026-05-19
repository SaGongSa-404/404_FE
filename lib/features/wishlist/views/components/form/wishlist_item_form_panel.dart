import 'dart:math' as math;

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:fe_app/features/wishlist/views/components/modals/wishlist_bottom_sheet.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum WishlistFormMode { add, edit }

abstract final class WishlistItemFormHints {
  WishlistItemFormHints._();

  static const String link = 'URL을 붙여넣으세요';
  static const String productName = '상품명을 입력해주세요';
  static const String price = '가격을 입력해주세요';
}

class WishlistItemFormPanel extends StatefulWidget {
  WishlistItemFormPanel.add({
    super.key,
    required this.onClose,
    required this.onSubmit,
    this.initialLink,
    this.linkReadOnly = false,
  })  : mode = WishlistFormMode.add,
        item = null,
        onDelete = null;

  WishlistItemFormPanel.edit({
    super.key,
    required WishlistPlaceholder item,
    required this.onClose,
    required this.onSubmit,
    this.onDelete,
  })  : mode = WishlistFormMode.edit,
        item = item,
        initialLink = null,
        linkReadOnly = false;

  final WishlistFormMode mode;
  final WishlistPlaceholder? item;
  final VoidCallback onClose;
  final ValueChanged<WishlistPlaceholder> onSubmit;
  final VoidCallback? onDelete;
  final String? initialLink;
  final bool linkReadOnly;

  @override
  State<WishlistItemFormPanel> createState() => _WishlistItemFormPanelState();
}

class _WishlistItemFormPanelState extends State<WishlistItemFormPanel>
    with TickerProviderStateMixin {
  static const Color _dimColor = Color(0x59000000);
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeDx;

  late final TextEditingController _linkController;
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  String? _selectedCategory;

  static const double _sheetTopRadius = 22;
  static const Color _wishlistCardShadowColor = Color(0x22000000);
  static const double _wishlistCardShadowBlur = 4;
  static const double _fieldPillRadius = 30;
  static const double _categoryChipGap = 12;
  static const double _categoryRowGap = 8;
  static const double _beforeSaveButtonGap = 56;
  static const double _extraTopGap = 52;
  static const Color _fieldErrorBorder = Color(0xFF9C4444);
  static const List<String> _categories = ['패션', '뷰티', '라이프', '디지털', '기타'];

  bool get _isAdd => widget.mode == WishlistFormMode.add;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curved);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeDx = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -7), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -7, end: 7), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 7, end: -5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5, end: 5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5, end: -3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    if (_isAdd) {
      _linkController = TextEditingController(text: widget.initialLink?.trim() ?? '');
      _nameController = TextEditingController();
      _priceController = TextEditingController();
      _selectedCategory = null;
    } else {
      final i = widget.item!;
      _linkController = TextEditingController(text: i.link);
      _nameController = TextEditingController(text: i.title);
      _priceController = TextEditingController(text: _formatPrice(i.price));
      _selectedCategory =
          _categories.contains(i.category) ? i.category : _categories.first;
    }

    void onFieldChanged() {
      if (mounted) setState(() {});
    }

    _linkController.addListener(onFieldChanged);
    _nameController.addListener(onFieldChanged);
    _priceController.addListener(onFieldChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _controller.dispose();
    _linkController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool get _linkEmpty => _linkController.text.trim().isEmpty;
  bool get _titleEmpty => _nameController.text.trim().isEmpty;
  bool get _priceEmpty => _priceController.text.replaceAll(',', '').trim().isEmpty;
  bool get _categoryEmpty => _selectedCategory == null || _selectedCategory!.trim().isEmpty;

  bool get _linkRequired => _isAdd && widget.linkReadOnly;

  bool get _linkInvalid => _linkRequired && _linkEmpty;
  bool get _titleInvalid => _titleEmpty;
  bool get _priceInvalid =>
      _priceEmpty || int.tryParse(_priceController.text.replaceAll(',', '').trim()) == null;
  bool get _categoryInvalid => _categoryEmpty;

  bool get _formIsValid {
    final linkOk = !_linkRequired || !_linkEmpty;
    return linkOk &&
        !_titleEmpty &&
        !_priceEmpty &&
        int.tryParse(_priceController.text.replaceAll(',', '').trim()) != null &&
        !_categoryEmpty;
  }

  Future<void> _playDismiss() => _controller.reverse();

  Future<void> _dismiss() async {
    await _playDismiss();
    if (mounted) widget.onClose();
  }

  Future<void> _save() async {
    if (!_formIsValid) {
      await _shakeController.forward(from: 0);
      return;
    }

    final parsedPrice =
        int.parse(_priceController.text.replaceAll(',', '').trim());
    final id = _isAdd
        ? 'w-${DateTime.now().millisecondsSinceEpoch}'
        : widget.item!.id;
    final updated = WishlistPlaceholder(
      id: id,
      title: _nameController.text.trim(),
      price: parsedPrice,
      category: _selectedCategory!,
      link: _linkController.text.trim(),
    );
    await _playDismiss();
    if (!mounted) return;
    widget.onSubmit(updated);
    if (context.mounted) {
      showCapsuleToast(
        context,
        backgroundColor: const Color(0xFF5F8EAE),
        text: _isAdd ? '솜사탕이 생겼어요' : '수정되었습니다',
      );
    }
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
    final maxSheetHeight = math.min(screenH * 0.90, math.max(300.0, spaceBelowStatus));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: _dimColor,
                child: SizedBox(height: topInset),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _dismiss,
                  child: const ColoredBox(color: _dimColor),
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
                                _buildField(
                                  label: '링크',
                                  controller: _linkController,
                                  hintText: WishlistItemFormHints.link,
                                  showError: _linkInvalid,
                                  showErrorBorder: _linkInvalid,
                                  readOnly: widget.linkReadOnly,
                                ),
                                const SizedBox(height: 24),
                                _buildField(
                                  label: '상품명',
                                  controller: _nameController,
                                  hintText: WishlistItemFormHints.productName,
                                  showError: _titleInvalid,
                                  showErrorBorder: _titleInvalid,
                                ),
                                const SizedBox(height: 24),
                                _buildField(
                                  label: '가격',
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  suffix: '원',
                                  hintText: WishlistItemFormHints.price,
                                  showError: _priceInvalid,
                                  showErrorBorder: _priceInvalid,
                                ),
                                const SizedBox(height: 32),
                                _categoryLabelRow(),
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
    final title = _isAdd ? '위시 추가' : '위시 수정';
    final trailing = widget.onDelete != null
        ? TextButton(
            onPressed: _delete,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD46868),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            child: const Text(
              '삭제하기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : const SizedBox(width: 72);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _dismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: const Icon(Icons.close, size: 26, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 72),
            child: Align(
              alignment: Alignment.centerRight,
              child: trailing,
            ),
          ),
        ],
      ),
    );
  }

  static const StrutStyle _labelStrut = StrutStyle(
    fontSize: 16,
    height: 1.25,
    leading: 0,
    forceStrutHeight: true,
  );
  static const TextHeightBehavior _labelTextHeightBehavior = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );
  static const double _labelLineHeight = 16 * 1.25;

  Widget _categoryLabelRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '카테고리',
          strutStyle: _labelStrut,
          textHeightBehavior: _labelTextHeightBehavior,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.25,
          ),
        ),
        _errorIconTrailing(visible: _categoryInvalid),
      ],
    );
  }

  Widget _errorIconTrailing({required bool visible}) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeDx.value, 0),
            child: child,
          );
        },
        child: SizedBox(
          height: _labelLineHeight,
          width: 20,
          child: const Center(
            child: Icon(Icons.error_outline, size: 20, color: AppColors.red_400),
          ),
        ),
      ),
    );
  }

  Widget _footerSaveButton() {
    final label = _isAdd ? '위시 담기' : '수정완료';
    return WishlistModalPillButton(
      label: label,
      background: AppColors.skyBlue_100,
      pressedBackground: AppColors.skyBlue_200,
      onPressed: _save,
      fixedHeight: 54,
      padding: EdgeInsets.zero,
    );
  }

  Widget _categoryGridThreePerRow() {
    final rows = <Widget>[];
    for (var i = 0; i < _categories.length; i += 3) {
      final end = (i + 3 > _categories.length) ? _categories.length : i + 3;
      final chunk = _categories.sublist(i, end);
      final isLastRow = end >= _categories.length;
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
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
    required bool showError,
    required bool showErrorBorder,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              strutStyle: _labelStrut,
              textHeightBehavior: _labelTextHeightBehavior,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
            _errorIconTrailing(visible: showError),
          ],
        ),
        const SizedBox(height: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(_fieldPillRadius),
            border: showErrorBorder
                ? Border.all(color: _fieldErrorBorder, width: 1.5)
                : null,
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
              readOnly: readOnly,
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
                hintText: hintText.isEmpty ? null : hintText,
                hintStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
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
