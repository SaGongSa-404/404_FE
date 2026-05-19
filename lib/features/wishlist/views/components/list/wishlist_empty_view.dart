import 'package:fe_app/core/theme/app_theme.dart';
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
    return ColoredBox(
      color: _screenBg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 161,
                height: 154,
                child: Image.asset(
                  'assets/images/nugul_empty.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '갖고 싶은 게 생겼나요?',
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
              const SizedBox(height: 14),
              Text(
                '바로 사기 전에, 여기 담아두고\n정말로 필요한 소비인지 확인해봐요',
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
              const SizedBox(height: 27),
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
                        onTap: onLearnHow ?? () {},
                        borderRadius: BorderRadius.circular(34),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: SizedBox(
                            height: 48,
                            child: Center(
                              child: Transform.translate(
                                offset: const Offset(0, 2),
                                child: Text(
                                  '담는 방법 보러가기',
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
    );
  }
}
