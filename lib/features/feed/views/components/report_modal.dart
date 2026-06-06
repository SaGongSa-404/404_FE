import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/models/report_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 신고 모달 제출 결과. [reason]은 '기타' 선택 시 직접 입력한 사유입니다.
class ReportSubmission {
  const ReportSubmission({required this.category, this.reason});

  final ReportCategory category;
  final String? reason;
}

/// 신고 사유 카테고리를 선택받아 반환합니다. 취소하거나 닫으면 null을 반환합니다.
Future<ReportSubmission?> showReportModal(BuildContext context) async {
  return showDialog<ReportSubmission>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => const _ReportDialog(),
  );
}

/// BE `reason` 길이 제한(@Size max 100)에 맞춥니다.
const int _kReasonMaxLength = 100;

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _otherController = TextEditingController();
  ReportCategory? _selected;
  bool _cancelPressed = false;
  bool _submitPressed = false;

  @override
  void initState() {
    super.initState();
    _otherController.addListener(() {
      // '기타' 사유 입력 시 제출 버튼 활성 상태가 바뀔 수 있어 다시 그립니다.
      if (_selected == ReportCategory.other) setState(() {});
    });
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final selected = _selected;
    if (selected == null) return false;
    if (selected.isOther) return _otherController.text.trim().isNotEmpty;
    return true;
  }

  void _select(ReportCategory category) {
    if (_selected == category) return;
    setState(() => _selected = category);
    if (!category.isOther) FocusScope.of(context).unfocus();
  }

  void _submit() {
    if (!_canSubmit) return;
    final selected = _selected!;
    Navigator.of(context).pop(
      ReportSubmission(
        category: selected,
        reason: selected.isOther ? _otherController.text.trim() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final scale = mq.size.width / 412.0;
    final horizontalInset = mq.size.width * 21 / 412;
    final keyboard = mq.viewInsets.bottom;
    final bottomInset = (keyboard > 0 ? keyboard : mq.padding.bottom) + 31 * scale;
    final maxHeight = mq.size.height - mq.padding.top - keyboard - 40 * scale;

    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.fromLTRB(horizontalInset, 0, horizontalInset, bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular((22 * scale).clamp(17.0, 27.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 3,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: (24 * scale).clamp(18.0, 32.0),
              vertical: (31 * scale).clamp(24.0, 40.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: (7 * scale).clamp(5.0, 9.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '신고하시는 이유가 무엇인가요?',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: (20 * scale).clamp(16.0, 24.0),
                          color: AppColors.textPrimary,
                          height: 1.29,
                        ),
                      ),
                      SizedBox(height: (12 * scale).clamp(9.0, 15.0)),
                      Text(
                        '※ 운영 원칙에 위배되는 게시물인지 확인 후 조치됩니다.\n허위 신고 시 서비스 이용에 제한이 있을 수 있습니다.',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: (13 * scale).clamp(11.0, 16.0),
                          color: const Color(0xFF979797),
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (27 * scale).clamp(21.0, 33.0)),
                _CategoryList(
                  selected: _selected,
                  onSelect: _select,
                  otherController: _otherController,
                  scale: scale,
                ),
                SizedBox(height: (27 * scale).clamp(21.0, 33.0)),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => _cancelPressed = true),
                        onTapUp: (_) {
                          setState(() => _cancelPressed = false);
                          Navigator.of(context).pop();
                        },
                        onTapCancel: () => setState(() => _cancelPressed = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          height: (57 * scale).clamp(46.0, 68.0),
                          decoration: BoxDecoration(
                            color: _cancelPressed ? AppColors.grey_300 : AppColors.grey_100,
                            borderRadius: BorderRadius.circular(57),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '취소',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: (20 * scale).clamp(16.0, 24.0),
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: (6 * scale).clamp(4.0, 8.0)),
                    Expanded(
                      child: GestureDetector(
                        onTapDown: _canSubmit ? (_) => setState(() => _submitPressed = true) : null,
                        onTapUp: _canSubmit
                            ? (_) {
                                setState(() => _submitPressed = false);
                                _submit();
                              }
                            : null,
                        onTapCancel: () => setState(() => _submitPressed = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          height: (57 * scale).clamp(46.0, 68.0),
                          decoration: BoxDecoration(
                            color: _canSubmit
                                ? (_submitPressed ? AppColors.red_500 : AppColors.red_600)
                                : AppColors.grey_100,
                            borderRadius: BorderRadius.circular(57),
                          ),
                          alignment: Alignment.center,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 150),
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: (20 * scale).clamp(16.0, 24.0),
                              color: _canSubmit ? AppColors.white : AppColors.textPrimary,
                            ),
                            child: const Text('신고접수'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.selected,
    required this.onSelect,
    required this.otherController,
    required this.scale,
  });

  final ReportCategory? selected;
  final ValueChanged<ReportCategory> onSelect;
  final TextEditingController otherController;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final rowGap = (27 * scale).clamp(21.0, 33.0);
    final rows = <Widget>[];
    for (final category in ReportCategory.values) {
      if (rows.isNotEmpty) rows.add(SizedBox(height: rowGap));
      rows.add(
        category.isOther
            ? _OtherRow(
                selected: selected == category,
                onSelect: () => onSelect(category),
                controller: otherController,
                scale: scale,
              )
            : _CategoryRow(
                label: category.label,
                selected: selected == category,
                onTap: () => onSelect(category),
                scale: scale,
              ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

class _RadioIcon extends StatelessWidget {
  const _RadioIcon({required this.selected, required this.scale});

  final bool selected;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Icon(
      selected ? Icons.check_circle : Icons.check_circle_outline,
      size: (30 * scale).clamp(24.0, 36.0),
      color: selected ? AppColors.red_600 : AppColors.grey_300,
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scale,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          _RadioIcon(selected: selected, scale: scale),
          SizedBox(width: (6 * scale).clamp(4.0, 8.0)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: (16 * scale).clamp(13.0, 20.0),
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherRow extends StatelessWidget {
  const _OtherRow({
    required this.selected,
    required this.onSelect,
    required this.controller,
    required this.scale,
  });

  final bool selected;
  final VoidCallback onSelect;
  final TextEditingController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSelect,
          child: Row(
            children: [
              _RadioIcon(selected: selected, scale: scale),
              SizedBox(width: (6 * scale).clamp(4.0, 8.0)),
              Text(
                '기타',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: (16 * scale).clamp(13.0, 20.0),
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: (10 * scale).clamp(8.0, 14.0)),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular((24 * scale).clamp(18.0, 30.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2.5,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: (20 * scale).clamp(15.0, 25.0),
              vertical: (6 * scale).clamp(4.0, 9.0),
            ),
            child: TextField(
              controller: controller,
              onTap: onSelect,
              maxLength: _kReasonMaxLength,
              inputFormatters: [
                LengthLimitingTextInputFormatter(_kReasonMaxLength),
              ],
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: (15 * scale).clamp(12.0, 18.0),
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: '신고 사유 입력하기',
                hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: (15 * scale).clamp(12.0, 18.0),
                  color: const Color(0xFFADADAD),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                counterText: '',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
