import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 링크 파싱 실패 시 안내 (empty 위시 화면과 동일한 레이아웃 리듬).
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                padding: const EdgeInsets.only(left: 8, right: 8),
                onPressed: onBack ?? () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 101,
                        height: 126.33559,
                        child: Image.asset(
                          'assets/images/warn.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        '상품 정보를 가져오지 못했어요',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _titleColor,
                              fontSize: 18,
                              height: 1.25,
                            ) ??
                            const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _titleColor,
                              height: 1.25,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '직접 입력해서\n솜사탕을 만들어봐요!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.55,
                              color: _subtitleColor,
                            ) ??
                            const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.55,
                              color: _subtitleColor,
                            ),
                      ),
                      const SizedBox(height: 55),
                      SizedBox(
                        width: double.infinity,
                        child: Align(
                          alignment: Alignment.center,
                          child: IntrinsicWidth(
                            child: Material(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(34),
                                side: const BorderSide(color: _buttonBorder, width: 1.68),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: onManualInput,
                                borderRadius: BorderRadius.circular(34),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 22),
                                  child: SizedBox(
                                    height: 48,
                                    child: Center(
                                      child: Transform.translate(
                                        offset: const Offset(0, 2),
                                        child: Text(
                                          '직접 입력하기',
                                          strutStyle: const StrutStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            height: 1.0,
                                            leading: 0,
                                            forceStrutHeight: true,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 18,
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
