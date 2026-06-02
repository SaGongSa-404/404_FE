import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WishlistProductFetchFailedScreen extends StatelessWidget {
  const WishlistProductFetchFailedScreen({
    super.key,
    required this.onManualInput,
    this.onBack,
  });

  final VoidCallback onManualInput;
  final VoidCallback? onBack;

  static const Color _titleColor = AppColors.textPrimary;
  static const Color _subtitleColor = AppColors.textSecondary;
  static const Color _buttonBorder = Color(0xFFE2E2E2);

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                padding: EdgeInsets.only(left: 8 * scale, right: 8 * scale),
                onPressed: onBack ?? () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                  size: 18 * scale,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 101 * scale,
                        height: 126.33559 * scale,
                        child: Image.asset(
                          'assets/images/warn.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 25 * scale),
                      Text(
                        '상품 정보를 가져오지 못했어요',
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
                      SizedBox(height: 8 * scale),
                      Text(
                        '직접 입력해서\n솜사탕을 만들어봐요!',
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
                      SizedBox(height: 55 * scale),
                      SizedBox(
                        width: double.infinity,
                        child: Align(
                          alignment: Alignment.center,
                          child: IntrinsicWidth(
                            child: Material(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(34 * scale),
                                side: BorderSide(
                                  color: _buttonBorder,
                                  width: 1.68 * scale,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: onManualInput,
                                borderRadius: BorderRadius.circular(34 * scale),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 22 * scale,
                                  ),
                                  child: SizedBox(
                                    height: 48 * scale,
                                    child: Center(
                                      child: Transform.translate(
                                        offset: Offset(0, 2 * scale),
                                        child: Text(
                                          '직접 입력하기',
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
            ),
          ],
        ),
      ),
    );
  }
}
