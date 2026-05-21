import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/profile/providers/profile_provider.dart';
import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';
import 'package:fe_app/shared/widgets/main_tab_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset.zero,
    ),
  ];

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  bool _isAlarmEnabled = true;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final profile = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            MainTabHeader(
              backgroundColor: Colors.white,
              leading: MainTabHeader.tabTitle('마이페이지', scale),
              onAlarmPressed: () => context.push('/notifications'),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF5F5F5),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                  child: Column(
                    children: [
                      SizedBox(height: 32 * scale),
                      SvgPicture.asset(
                        'assets/images/nugul_face.svg',
                        width: 90 * scale,
                        height: 90 * scale,
                        placeholderBuilder: (context) => SizedBox(
                          width: 90 * scale,
                          height: 90 * scale,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                          children: [
                            TextSpan(
                              text: profile.nickname,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18 * scale,
                              ),
                            ),
                            TextSpan(
                              text: '님 안녕하세요!',
                              style: TextStyle(fontSize: 18 * scale),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      Container(
                        decoration: const BoxDecoration(
                          boxShadow: MyPageScreen._cardShadow,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/my/edit'),
                            borderRadius: BorderRadius.circular(20 * scale),
                            highlightColor: Colors.black.withAlpha(20),
                            splashColor: Colors.black.withAlpha(10),
                            child: Ink(
                              padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 6 * scale),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20 * scale),
                                border: Border.all(color: const Color(0xFFDBDBDB)),
                              ),
                              child: Text(
                                '프로필 편집',
                                style: TextStyle(
                                  fontSize: 13 * scale,
                                  color: const Color(0xFF7B7B7B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 36 * scale),
                      _buildMenuItem(
                        scale: scale,
                        iconPath: 'assets/images/bar_chart.svg',
                        label: '소비 관리',
                        onTap: () => context.push('/my/consumption'),
                      ),
                      SizedBox(height: 12 * scale),
                      _buildMenuItem(
                        scale: scale,
                        iconPath: 'assets/images/toast.svg',
                        label: '나의 게시글',
                        onTap: () => context.push('/my/posts'),
                      ),
                      SizedBox(height: 12 * scale),
                      _buildMenuItem(
                        scale: scale,
                        iconPath: 'assets/images/ink_highlighter.svg',
                        label: '약관 및 정책',
                        onTap: () => context.push('/my/terms'),
                      ),
                      SizedBox(height: 12 * scale),
                      _buildAlarmToggle(scale),
                      SizedBox(height: 40 * scale),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  Widget _buildMenuItem({
    required double scale,
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: MyPageScreen._cardShadow,
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30 * scale),
          highlightColor: Colors.black.withAlpha(25),
          splashColor: Colors.black.withAlpha(15),
          child: Ink(
            height: 60 * scale,
            padding: EdgeInsets.symmetric(horizontal: 24 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30 * scale),
            ),
            child: Row(
              children: [
                SvgPicture.asset(iconPath, width: 20 * scale, height: 20 * scale),
                SizedBox(width: 12 * scale),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmToggle(double scale) {
    return Container(
      height: 60 * scale,
      padding: EdgeInsets.symmetric(horizontal: 24 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30 * scale),
        boxShadow: MyPageScreen._cardShadow,
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_none_outlined, color: Colors.black, size: 22 * scale),
          SizedBox(width: 12 * scale),
          Text(
            '알림',
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _isAlarmEnabled = !_isAlarmEnabled;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44 * scale,
              height: 24 * scale,
              padding: EdgeInsets.symmetric(horizontal: 4 * scale),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12 * scale),
                color: _isAlarmEnabled
                    ? const Color(0xFFF2E4BE)
                    : const Color(0xFFE5E5E5),
              ),
              child: AlignmentGuidedAnimatedWidget(
                alignment: _isAlarmEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16 * scale,
                  height: 16 * scale,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AlignmentGuidedAnimatedWidget extends StatelessWidget {
  final Alignment alignment;
  final Widget child;

  const AlignmentGuidedAnimatedWidget({
    super.key,
    required this.alignment,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      alignment: alignment,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: child,
    );
  }
}
