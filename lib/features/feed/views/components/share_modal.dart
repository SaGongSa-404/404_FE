import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

void showShareModal({
  required BuildContext context,
  required FeedPost post,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => _ShareBottomSheet(post: post),
  );
}

class _ShareBottomSheet extends StatefulWidget {
  const _ShareBottomSheet({required this.post});

  final FeedPost post;

  @override
  State<_ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<_ShareBottomSheet> {
  bool _kakaoPressed = false;
  bool _optionPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    const mockUrl = 'www.wigulwigulwigul.co.kr';
    final horizontalInset = MediaQuery.of(context).size.width * 21 / 412;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 25;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalInset, 0, horizontalInset, bottomPadding),
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
        padding: EdgeInsets.fromLTRB(
          (24 * scale).clamp(18.0, 30.0),
          (28 * scale).clamp(21.0, 35.0),
          (24 * scale).clamp(18.0, 30.0),
          (28 * scale).clamp(21.0, 35.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '링크로 공유하기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: (20 * scale).clamp(16.0, 24.0),
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: (20 * scale).clamp(15.0, 25.0)),
            GestureDetector(
              onTap: () async {
                await Clipboard.setData(
                    ClipboardData(text: 'https://$mockUrl/post/${widget.post.id}'));
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '링크가 복사되었어요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: (18 * scale).clamp(14.0, 22.0),
                        color: AppColors.white,
                      ),
                    ),
                    backgroundColor: AppColors.skyBlue_400.withValues(alpha: 0.8),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(47),
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: (26 * scale).clamp(20.0, 32.0),
                      vertical: (16 * scale).clamp(12.0, 20.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: (24 * scale).clamp(18.0, 30.0),
                      vertical: (9 * scale).clamp(7.0, 12.0),
                    ),
                    elevation: 6,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                height: (57 * scale).clamp(46.0, 68.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular((56 * scale).clamp(45.0, 67.0)),
                  border: Border.all(color: const Color(0xFFC4C4C4)),
                ),
                padding: EdgeInsets.symmetric(horizontal: (16 * scale).clamp(12.0, 20.0)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        mockUrl,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: (15 * scale).clamp(12.0, 18.0),
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: (8 * scale).clamp(6.0, 10.0)),
                    SvgPicture.asset(
                      'assets/images/content_copy.svg',
                      width: (20 * scale).clamp(16.0, 24.0),
                      height: (20 * scale).clamp(16.0, 24.0),
                      colorFilter: const ColorFilter.mode(
                        AppColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: (16 * scale).clamp(12.0, 20.0)),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _kakaoPressed = true),
                    onTapUp: (_) {
                      setState(() => _kakaoPressed = false);
                      Navigator.of(context).pop();
                    },
                    onTapCancel: () => setState(() => _kakaoPressed = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: (58 * scale).clamp(46.0, 70.0),
                      decoration: BoxDecoration(
                        color: _kakaoPressed ? AppColors.yellow_100 : AppColors.yellow,
                        borderRadius: BorderRadius.circular(75),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/kakao_logo.png',
                            width: (24 * scale).clamp(19.0, 29.0),
                            height: (24 * scale).clamp(19.0, 29.0),
                          ),
                          SizedBox(width: (8 * scale).clamp(6.0, 10.0)),
                          Text(
                            '카카오로 공유',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: (14 * scale).clamp(10.0, 17.0),
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: (27 * scale).clamp(21.0, 33.0)),
                GestureDetector(
                  onTapDown: (_) => setState(() => _optionPressed = true),
                  onTapUp: (_) {
                    setState(() => _optionPressed = false);
                    Navigator.of(context).pop();
                  },
                  onTapCancel: () => setState(() => _optionPressed = false),
                  child: SvgPicture.asset(
                    _optionPressed
                        ? 'assets/images/option_clicked2.svg'
                        : 'assets/images/option_clicked.svg',
                    width: (60 * scale).clamp(48.0, 72.0),
                    height: (60 * scale).clamp(48.0, 72.0),
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
