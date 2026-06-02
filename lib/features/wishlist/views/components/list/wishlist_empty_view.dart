import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class EmptyWishlistView extends StatelessWidget {
  const EmptyWishlistView({super.key, this.onLearnHow});

  final VoidCallback? onLearnHow;

  static const Color _screenBg = AppColors.background;
  static const Color _titleColor = AppColors.textPrimary;
  static const Color _subtitleColor = AppColors.textSecondary;
  static const Color _buttonBorder = Color(0xFFE2E2E2);

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return ColoredBox(
      color: _screenBg,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 161 * scale,
                height: 154 * scale,
                child: Image.asset(
                  'assets/images/nugul_empty.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20 * scale),
              Text(
                '갖고 싶은 게 생겼나요?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _titleColor,
                      fontSize: 18 * scale,
                      height: 1.25,
                    ) ??
                    TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w600,
                      color: _titleColor,
                      height: 1.25,
                    ),
              ),
              SizedBox(height: 14 * scale),
              Text(
                '바로 사기 전에, 여기 담아두고\n정말로 필요한 소비인지 확인해봐요',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16 * scale,
                      height: 1.55,
                      color: _subtitleColor,
                    ) ??
                    TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w500,
                      height: 1.55,
                      color: _subtitleColor,
                    ),
              ),
              SizedBox(height: 27 * scale),
              SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.center,
                  child: IntrinsicWidth(
                    child: Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34 * scale),
                        side: const BorderSide(color: _buttonBorder, width: 1.68),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: onLearnHow ?? () {},
                        borderRadius: BorderRadius.circular(34 * scale),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22 * scale),
                          child: SizedBox(
                            height: 48 * scale,
                            child: Center(
                              child: Transform.translate(
                                offset: Offset(0, 2 * scale),
                                child: Text(
                                  '담는 방법 보러가기',
                                  strutStyle: StrutStyle(
                                    fontSize: 18 * scale,
                                    fontWeight: FontWeight.w500,
                                    height: 1.0,
                                    leading: 0,
                                    forceStrutHeight: true,
                                  ),
                                  style: TextStyle(
                                    fontSize: 18 * scale,
                                    fontWeight: FontWeight.w500,
                                    height: 1.0,
                                    color: _titleColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
