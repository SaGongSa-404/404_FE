import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// "앞으로 이 창을 표시하지 않음" 기기 저장 키.
const String _kSkipLinkConfirmKey = 'feed_product_link_skip_confirm';

/// http/https 형식이 유효하면 [Uri]를, 아니면 null을 반환합니다.
Uri? _validHttpUri(String? url) {
  final trimmed = url?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  if (uri.host.isEmpty) return null;
  return uri;
}

void _showInvalidLinkToast(BuildContext context) {
  if (!context.mounted) return;
  showCapsuleToast(
    context,
    backgroundColor: AppColors.red_600,
    text: '링크가 유효하지 않습니다',
  );
}

Future<void> _launch(BuildContext context, Uri uri) async {
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) _showInvalidLinkToast(context);
  } catch (_) {
    _showInvalidLinkToast(context);
  }
}

/// 상품 링크로 이동합니다.
/// - 링크가 없거나 유효하지 않으면 즉시 안내 토스트만 띄웁니다.
/// - "앞으로 표시하지 않음"이 저장돼 있으면 확인 창 없이 바로 이동합니다.
/// - 그 외에는 확인 바텀시트를 띄운 뒤 확인 시 이동합니다.
Future<void> openProductLink({
  required BuildContext context,
  required String? url,
}) async {
  // 유효성 검사는 어떤 await보다 먼저(동기) 수행해 토스트 컨텍스트를 안전하게 유지합니다.
  final uri = _validHttpUri(url);
  if (uri == null) {
    _showInvalidLinkToast(context);
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  final skip = prefs.getBool(_kSkipLinkConfirmKey) ?? false;
  if (skip) {
    await _launch(context, uri);
    return;
  }

  if (!context.mounted) return;
  final confirmed = await _showConfirmSheet(context);
  if (confirmed == true) {
    await _launch(context, uri);
  }
}

Future<bool?> _showConfirmSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => const _ProductLinkBottomSheet(),
  );
}

class _ProductLinkBottomSheet extends StatefulWidget {
  const _ProductLinkBottomSheet();

  @override
  State<_ProductLinkBottomSheet> createState() =>
      _ProductLinkBottomSheetState();
}

class _ProductLinkBottomSheetState extends State<_ProductLinkBottomSheet> {
  bool _dontShowAgain = false;

  Future<void> _onConfirm() async {
    if (_dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kSkipLinkConfirmKey, true);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    final horizontalInset = MediaQuery.of(context).size.width * 21 / 412;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalInset,
        0,
        horizontalInset,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular((22 * scale).clamp(17.0, 27.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 3,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: (24 * scale).clamp(18.0, 30.0),
          vertical: (31 * scale).clamp(24.0, 38.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: (7 * scale).clamp(5.0, 9.0)),
              child: Text(
                '해당 상품의 링크로 이동할까요?',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: (20 * scale).clamp(16.0, 24.0),
                  color: AppColors.textDark,
                  height: 1.29,
                ),
              ),
            ),
            SizedBox(height: (12 * scale).clamp(9.0, 15.0)),
            GestureDetector(
              onTap: () => setState(() => _dontShowAgain = !_dontShowAgain),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: (7 * scale).clamp(5.0, 9.0)),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      _dontShowAgain
                          ? 'assets/images/link_check_clicked.svg'
                          : 'assets/images/link_check.svg',
                      width: (20 * scale).clamp(16.0, 24.0),
                      height: (20 * scale).clamp(16.0, 24.0),
                    ),
                    SizedBox(width: (5 * scale).clamp(4.0, 6.0)),
                    Text(
                      '앞으로 이 창을 표시하지 않음',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: (16 * scale).clamp(13.0, 19.0),
                        color: const Color(0xFF979797),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: (27 * scale).clamp(21.0, 33.0)),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: (57 * scale).clamp(46.0, 68.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(57),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: (20 * scale).clamp(16.0, 24.0),
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: (6 * scale).clamp(4.0, 8.0)),
                Expanded(
                  child: GestureDetector(
                    onTap: _onConfirm,
                    child: Container(
                      height: (57 * scale).clamp(46.0, 68.0),
                      decoration: BoxDecoration(
                        color: AppColors.skyBlue_100,
                        borderRadius: BorderRadius.circular(57),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: (20 * scale).clamp(16.0, 24.0),
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
