import 'dart:async';
import 'dart:math' as math;

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_category_ui.dart';
import 'package:fe_app/features/wishlist/models/wishlist_add_form_prefill.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:fe_app/features/wishlist/utils/wishlist_item_form_validation.dart';
import 'package:fe_app/features/wishlist/views/components/modals/wishlist_bottom_sheet.dart';
import 'package:fe_app/shared/enums/api_enums.dart';
import 'package:fe_app/shared/widgets/app_exit_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum WishlistFormMode { add, edit }

abstract final class WishlistItemFormHints {
  WishlistItemFormHints._();

  static const String link = 'URL을 붙여넣으세요';
  static const String productName = '상품명을 입력해주세요';
  static const String price = '가격 (선택)';
}

class WishlistItemFormPanel extends StatefulWidget {
  WishlistItemFormPanel.add({
    super.key,
    required this.onClose,
    required this.onSubmit,
    this.initialLink,
    this.formPrefill,
    this.linkReadOnly = false,
    this.isImporting = false,
    this.isSubmitting = false,
  })  : mode = WishlistFormMode.add,
        item = null,
        onDelete = null;

  WishlistItemFormPanel.edit({
    super.key,
    required WishlistPlaceholder item,
    required this.onClose,
    required this.onSubmit,
    this.onDelete,
    this.isSubmitting = false,
  })  : mode = WishlistFormMode.edit,
        item = item,
        initialLink = null,
        formPrefill = null,
        linkReadOnly = false,
        isImporting = false;

  final WishlistFormMode mode;
  final WishlistPlaceholder? item;
  final VoidCallback onClose;
  final Future<bool> Function(WishlistPlaceholder item) onSubmit;
  final Future<bool> Function()? onDelete;
  final String? initialLink;
  final WishlistAddFormPrefill? formPrefill;
  final bool linkReadOnly;
  final bool isImporting;
  final bool isSubmitting;

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
  bool _validationAttempted = false;

  static const double _sheetTopRadius = 22;
  static const Color _wishlistCardShadowColor = Color(0x22000000);
  static const double _wishlistCardShadowBlur = 4;
  static const double _fieldPillRadius = 30;
  static const double _categoryChipGap = 12;
  static const double _categoryRowGap = 8;
  static const double _beforeSaveButtonGap = 56;
  static const double _extraTopGap = 52;
  static const Color _fieldErrorBorder = Color(0xFF9C4444);
  static const Color _disabledButtonBackground = Color(0xFFDAE9F1);
  static const Color _disabledButtonForeground = Color(0xFF8F8F8F);
  static const int _maxPriceDigits = 8;
  static const List<String> _categories = WishlistCategoryUi.formLabels;

  late final FocusNode _priceFocusNode;

  bool get _isAdd => widget.mode == WishlistFormMode.add;

  bool get _editLinkReadOnly =>
      !_isAdd && widget.item?.inputSource == ItemInputSource.share;

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
    _priceFocusNode = FocusNode()..addListener(_onPriceFocusChanged);

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
      _selectedCategory = '기타';
      _applyFormPrefill(widget.formPrefill);
    } else {
      final i = widget.item!;
      _linkController = TextEditingController(text: i.link);
      _nameController = TextEditingController(text: i.title);
      _priceController = TextEditingController(text: i.priceKnown ? _formatPrice(i.price) : '');
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
  void didUpdateWidget(covariant WishlistItemFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isAdd) {
      final oldItem = oldWidget.item;
      final newItem = widget.item;
      if (oldItem == null || newItem == null) return;
      if (oldItem.id == newItem.id) return;
      _syncEditFieldsFromItem(newItem);
      return;
    }
    if (widget.isImporting && !oldWidget.isImporting) return;

    final prefill = widget.formPrefill;
    if (prefill == null) return;

    final finishingImport = oldWidget.isImporting && !widget.isImporting;
    if (!finishingImport && identical(prefill, oldWidget.formPrefill)) return;

    _applyFormPrefill(prefill, rebuild: true);
  }

  void _onPriceFocusChanged() {
    if (mounted) setState(() {});
  }

  void _syncEditFieldsFromItem(WishlistPlaceholder item) {
    _linkController.text = item.link;
    _nameController.text = item.title;
    _priceController.text = item.priceKnown ? _formatPrice(item.price) : '';
    _selectedCategory =
        _categories.contains(item.category) ? item.category : _categories.first;
    _validationAttempted = false;
  }

  void _applyFormPrefill(WishlistAddFormPrefill? prefill, {bool rebuild = false}) {
    if (prefill == null) return;

    void apply() {
      if (prefill.link.isNotEmpty) {
        _linkController.text = prefill.link;
      }
      if (prefill.title.isNotEmpty) {
        _nameController.text = prefill.title;
      }
      if (prefill.price > 0) {
        _priceController.text = _formatPrice(prefill.price);
      }
      _selectedCategory = WishlistCategoryUi.resolveFormChipSelection(
        uiLabel: prefill.category,
      );
    }

    if (rebuild && mounted) {
      setState(apply);
    } else {
      apply();
    }
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _shakeController.dispose();
    _controller.dispose();
    _linkController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool get _titleEmpty => _nameController.text.trim().isEmpty;
  bool get _categoryEmpty =>
      _selectedCategory == null || _selectedCategory!.trim().isEmpty;

  bool get _linkInvalid => WishlistItemFormValidation.isLinkInvalid(
        isAdd: _isAdd,
        linkReadOnly: widget.linkReadOnly,
        editLinkReadOnly: _editLinkReadOnly,
        link: _linkController.text,
      );

  bool get _titleInvalid => _titleEmpty;
  bool get _categoryInvalid => _categoryEmpty;

  bool get _priceInvalid =>
      _priceController.text.trim().isNotEmpty &&
      WishlistItemFormValidation.parsePriceDigits(_priceController.text) == null;

  bool get _priceIsZero =>
      WishlistItemFormValidation.parsePriceDigits(_priceController.text) == 0;

  bool get _linkShowsError => _validationAttempted && _linkInvalid;
  bool get _titleShowsError => _validationAttempted && _titleInvalid;
  bool get _categoryShowsError => _validationAttempted && _categoryInvalid;
  bool get _priceShowsError =>
      _validationAttempted && (_priceInvalid || _priceIsZero);

  String? get _linkErrorMessage => WishlistItemFormValidation.linkErrorMessage(
        validationAttempted: _validationAttempted,
        link: _linkController.text,
      );

  String? get _priceErrorMessage => WishlistItemFormValidation.priceErrorMessage(
        validationAttempted: _validationAttempted,
        priceText: _priceController.text,
      );

  bool get _formIsValid => WishlistItemFormValidation.isFormValid(
        link: _linkController.text,
        title: _nameController.text,
        priceText: _priceController.text,
        category: _selectedCategory,
        isAdd: _isAdd,
        linkReadOnly: widget.linkReadOnly,
        editLinkReadOnly: _editLinkReadOnly,
      );

  bool get _canSubmit =>
      _formIsValid && !widget.isSubmitting && !widget.isImporting;

  Future<void> _playDismiss() => _controller.reverse();

  Future<void> _dismiss() async {
    await _playDismiss();
    if (mounted) widget.onClose();
  }

  Future<void> _onSavePressed() async {
    if (widget.isSubmitting || widget.isImporting) return;

    setState(() => _validationAttempted = true);
    if (!_formIsValid) {
      await _shakeController.forward(from: 0);
      return;
    }

    if (_priceIsZero) {
      await _shakeController.forward(from: 0);
      return;
    }

    await _save();
  }

  Future<void> _save() async {
    if (widget.isSubmitting || widget.isImporting) return;

    final WishlistPlaceholder updated;
    if (_isAdd) {
      updated = WishlistItemFormValidation.buildAddDraft(
        title: _nameController.text,
        priceText: _priceController.text,
        category: _selectedCategory!,
        link: _linkController.text,
        imageUrl: widget.formPrefill?.imageUrl,
      );
    } else {
      updated = WishlistItemFormValidation.buildEditDraft(
        existing: widget.item!,
        title: _nameController.text,
        priceText: _priceController.text,
        category: _selectedCategory!,
        link: _linkController.text,
      );
    }
    final ok = await widget.onSubmit(updated);
    if (!mounted) return;
    if (!ok) return;

    await _playDismiss();
    if (!mounted) return;
    widget.onClose();
  }

  Future<void> _delete() async {
    if (widget.onDelete == null || widget.isSubmitting) return;
    final ok = await widget.onDelete!();
    if (!mounted || !ok) return;
    await _playDismiss();
    if (mounted) widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final mq = MediaQuery.of(context);
    final topInset = mq.padding.top;
    final bottomInset = mq.padding.bottom;
    final screenH = mq.size.height;
    final spaceBelowStatus = screenH - topInset - _extraTopGap * scale;
    final maxSheetHeight = math.min(screenH * 0.90, math.max(300.0 * scale, spaceBelowStatus));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          AppExitBackHandler.markBackHandledByChild();
          unawaited(_dismiss());
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(_sheetTopRadius * scale),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _header(context, scale),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              24 * scale,
                              56 * scale,
                              24 * scale,
                              88 * scale + bottomInset,
                            ),
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildField(
                                  scale: scale,
                                  label: '링크',
                                  controller: _linkController,
                                  hintText: _editLinkReadOnly || widget.linkReadOnly
                                      ? ''
                                      : WishlistItemFormHints.link,
                                  showError: _linkShowsError,
                                  showErrorBorder: _linkShowsError,
                                  errorMessage: _linkErrorMessage,
                                  readOnly:
                                      _isAdd ? widget.linkReadOnly : _editLinkReadOnly,
                                ),
                                SizedBox(height: 24 * scale),
                                _buildField(
                                  scale: scale,
                                  label: '상품명',
                                  controller: _nameController,
                                  hintText: WishlistItemFormHints.productName,
                                  showError: _titleShowsError,
                                  showErrorBorder: _titleShowsError,
                                ),
                                SizedBox(height: 24 * scale),
                                _buildField(
                                  scale: scale,
                                  label: '가격',
                                  controller: _priceController,
                                  focusNode: _priceFocusNode,
                                  keyboardType: TextInputType.number,
                                  suffix: '원',
                                  hintText: WishlistItemFormHints.price,
                                  showError: _priceShowsError,
                                  showErrorBorder: _priceShowsError,
                                  errorMessage: _priceErrorMessage,
                                ),
                                SizedBox(height: 32 * scale),
                                _categoryLabelRow(scale),
                                SizedBox(height: 12 * scale),
                                _categoryGridThreePerRow(scale),
                                SizedBox(height: _beforeSaveButtonGap * scale),
                                _footerSaveButton(scale),
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
          _numericKeyboardDoneBar(scale),
        ],
      ),
      ),
    );
  }

  Widget _numericKeyboardDoneBar(double scale) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    if (bottomInset == 0 || !_priceFocusNode.hasFocus) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomInset,
      child: Material(
        elevation: 4,
        color: const Color(0xFFF1F1F1),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 44 * scale,
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _priceFocusNode.unfocus(),
                child: Text(
                  '완료',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, double scale) {
    final title = _isAdd ? '위시 추가' : '위시 수정';
    final trailing = widget.onDelete != null
        ? TextButton(
            onPressed: widget.isSubmitting ? null : _delete,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD46868),
              padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 8 * scale),
            ),
            child: Text(
              '삭제하기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : SizedBox(width: 72 * scale);

    return Padding(
      padding: EdgeInsets.fromLTRB(4 * scale, 12 * scale, 4 * scale, 4 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _dismiss,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 44 * scale, minHeight: 44 * scale),
            icon: Icon(Icons.close, size: 26 * scale, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 72 * scale),
            child: Align(
              alignment: Alignment.centerRight,
              child: trailing,
            ),
          ),
        ],
      ),
    );
  }

  StrutStyle _labelStrut(double scale) => StrutStyle(
    fontSize: 16 * scale,
    height: 1.25,
    leading: 0,
    forceStrutHeight: true,
  );
  static const TextHeightBehavior _labelTextHeightBehavior = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );
  double _labelLineHeight(double scale) => 16 * scale * 1.25;

  Widget _categoryLabelRow(double scale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '카테고리',
          strutStyle: _labelStrut(scale),
          textHeightBehavior: _labelTextHeightBehavior,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.25,
          ),
        ),
        _errorIconOnly(visible: _categoryShowsError, scale: scale),
      ],
    );
  }

  Widget _errorIconOnly({required bool visible, required double scale}) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(left: 6 * scale),
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeDx.value * scale, 0),
            child: child,
          );
        },
        child: SizedBox(
          height: _labelLineHeight(scale),
          width: 20 * scale,
          child: Center(
            child: Icon(
              Icons.error_outline,
              size: 20 * scale,
              color: AppColors.red_400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldErrorFeedback({
    required bool visible,
    required double scale,
    String? message,
  }) {
    if (!visible) return const SizedBox.shrink();
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 6 * scale),
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeDx.value * scale, 0),
              child: child,
            );
          },
          child: Row(
            children: [
              SizedBox(
                height: _labelLineHeight(scale),
                width: 20 * scale,
                child: Center(
                  child: Icon(
                    Icons.error_outline,
                    size: 20 * scale,
                    color: AppColors.red_400,
                  ),
                ),
              ),
              if (message != null) ...[
                SizedBox(width: 4 * scale),
                Flexible(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w500,
                      color: AppColors.red_400,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerSaveButton(double scale) {
    final String label;
    if (widget.isSubmitting) {
      label = _isAdd ? '담는 중...' : '수정 중...';
    } else {
      label = _isAdd ? '위시 담기' : '수정완료';
    }
    return WishlistModalPillButton(
      label: label,
      background:
          _canSubmit ? AppColors.skyBlue_100 : _disabledButtonBackground,
      pressedBackground:
          _canSubmit ? AppColors.skyBlue_200 : _disabledButtonBackground,
      foreground:
          _canSubmit ? AppColors.textPrimary : _disabledButtonForeground,
      onPressed:
          widget.isSubmitting || widget.isImporting ? null : _onSavePressed,
      fixedHeight: 54 * scale,
      padding: EdgeInsets.zero,
    );
  }

  Widget _categoryGridThreePerRow(double scale) {
    final rows = <Widget>[];
    for (var i = 0; i < _categories.length; i += 3) {
      final end = (i + 3 > _categories.length) ? _categories.length : i + 3;
      final chunk = _categories.sublist(i, end);
      final isLastRow = end >= _categories.length;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: isLastRow ? 0 : _categoryRowGap * scale),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var j = 0; j < 3; j++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: j == 0 ? 0 : _categoryChipGap * scale / 2,
                      right: j == 2 ? 0 : _categoryChipGap * scale / 2,
                    ),
                    child: j < chunk.length
                        ? _categoryChipFilterStyle(chunk[j], scale: scale)
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

  Widget _categoryChipFilterStyle(String category, {required double scale}) {
    final isSelected = _selectedCategory == category;
    final borderColor =
        isSelected ? AppColors.skyBlue_100 : const Color(0xFFD0D0D0);
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 25 * scale, vertical: 8 * scale),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F3F9) : Colors.white,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: borderColor, width: 1 * scale),
        ),
        child: Text(
          category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          strutStyle: StrutStyle(
            fontSize: 16 * scale,
            height: 1.2,
            leadingDistribution: TextLeadingDistribution.even,
            forceStrutHeight: true,
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: TextStyle(
            fontSize: 16 * scale,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required double scale,
    required String label,
    required TextEditingController controller,
    required String hintText,
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
    required bool showError,
    required bool showErrorBorder,
    String? errorMessage,
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
              strutStyle: _labelStrut(scale),
              textHeightBehavior: _labelTextHeightBehavior,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
            _fieldErrorFeedback(
              visible: showError,
              scale: scale,
              message: errorMessage,
            ),
          ],
        ),
        SizedBox(height: 10 * scale),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(_fieldPillRadius * scale),
            border: showErrorBorder
                ? Border.all(color: _fieldErrorBorder, width: 1 * scale)
                : null,
            boxShadow: showErrorBorder
                ? null
                : [
                    BoxShadow(
                      color: _wishlistCardShadowColor,
                      blurRadius: _wishlistCardShadowBlur * scale,
                      spreadRadius: 0,
                      offset: Offset.zero,
                    ),
                  ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            keyboardType: keyboardType,
            textInputAction:
                keyboardType == TextInputType.number ? TextInputAction.done : null,
            onSubmitted: keyboardType == TextInputType.number
                ? (_) => focusNode?.unfocus()
                : null,
            inputFormatters: keyboardType == TextInputType.number
                ? <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    _PriceTextInputFormatter(maxDigits: _maxPriceDigits),
                  ]
                : null,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16 * scale,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.white,
              hintText: hintText.isEmpty ? null : hintText,
              hintStyle: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              suffixText: suffix,
              suffixStyle: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 16 * scale),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_fieldPillRadius * scale),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_fieldPillRadius * scale),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_fieldPillRadius * scale),
                borderSide: BorderSide.none,
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
  _PriceTextInputFormatter({required this.maxDigits});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(',', '');
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }
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
