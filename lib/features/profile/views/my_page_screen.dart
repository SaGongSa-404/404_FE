import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/profile/providers/profile_provider.dart';
import 'package:fe_app/shared/widgets/alarm/alarm_button.dart';
import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';
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

  static const TextStyle _appBarTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // [수정] 닉네임 외의 일반 텍스트 스타일에 사용하기 위해 w400 기본 유지
  static const TextStyle _greetingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle _menuLabelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const EdgeInsets _contentPadding = EdgeInsets.symmetric(horizontal: 24);

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  bool _isAlarmEnabled = true;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경은 흰색 (헤더용)
      body: SafeArea(
        top: false, // 커스텀 앱바 크기를 고정하기 위해 상단 시스템 제한 해제
        child: Column(
          children: [
            // 1. 상단 헤더 영역 (높이를 정확히 126으로 고정하고 내부 요소만 아래로 배치)
            Container(
              height: 126,
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 16), // 아래쪽 여백으로 위치 조절
              alignment: Alignment.bottomCenter, // 내부 요소를 아래쪽으로 밀어내기
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('마이페이지', style: MyPageScreen._appBarTitleStyle),
                  AlarmButton(onPressed: () => context.push('/notifications')),
                ],
              ),
            ),

            // 2. 프로필 + 메뉴 영역 (회색 배경)
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF5F5F5),
                child: SingleChildScrollView(
                  padding: MyPageScreen._contentPadding,
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      // 프로필 이미지
                      SvgPicture.asset(
                        'assets/images/nugul_face.svg',
                        width: 90,
                        height: 90,
                        placeholderBuilder: (context) => const SizedBox(
                          width: 90,
                          height: 90,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // [수정] RichText를 활용해서 닉네임 영역에만 개별 볼드(Bold) 스타일 적용
                      RichText(
                        text: TextSpan(
                          style: MyPageScreen._greetingStyle, // 기본 폰트 스타일 적용
                          children: [
                            TextSpan(
                              text: profile.nickname,
                              style: const TextStyle(fontWeight: FontWeight.bold), // 닉네임만 굵게!
                            ),
                            const TextSpan(text: '님 안녕하세요!'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 프로필 편집 버튼 (그림자 추가)
                      Container(
                        decoration: const BoxDecoration(
                          boxShadow: MyPageScreen._cardShadow, // [수정] 그림자 적용
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/my/edit'),
                            borderRadius: BorderRadius.circular(20),
                            highlightColor: Colors.black.withAlpha(20),
                            splashColor: Colors.black.withAlpha(10),
                            child: Ink(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFDBDBDB)),
                              ),
                              child: const Text(
                                '프로필 편집',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7B7B7B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // 메뉴 리스트
                      _buildMenuItem(
                        iconPath: 'assets/images/bar_chart.svg',
                        label: '소비 관리',
                        onTap: () => context.push('/my/consumption'),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        iconPath: 'assets/images/toast.svg',
                        label: '나의 게시글',
                        onTap: () => context.push('/my/posts'),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        iconPath: 'assets/images/ink_highlighter.svg',
                        label: '약관 및 정책',
                        onTap: () => context.push('/my/terms'),
                      ),
                      const SizedBox(height: 12),
                      _buildAlarmToggle(),
                      const SizedBox(height: 40),
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

  // 메뉴 아이템 빌더 (그림자 추가)
  Widget _buildMenuItem({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: MyPageScreen._cardShadow, // [수정] 카드 뒷면에 그림자 배치
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          highlightColor: Colors.black.withAlpha(25),
          splashColor: Colors.black.withAlpha(15),
          child: Ink(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                SvgPicture.asset(iconPath, width: 20, height: 20),
                const SizedBox(width: 12),
                Text(label, style: MyPageScreen._menuLabelStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 알림 토글 빌더 (그림자 추가)
  Widget _buildAlarmToggle() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: MyPageScreen._cardShadow, // [수정] 알림 토글 상자에도 그림자 적용
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_none_outlined, color: Colors.black, size: 22),
          const SizedBox(width: 12),
          const Text('알림', style: MyPageScreen._menuLabelStyle),
          const Spacer(),

          // 축소된 커스텀 스위치 영역
          GestureDetector(
            onTap: () {
              setState(() {
                _isAlarmEnabled = !_isAlarmEnabled;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,  // 54 -> 44로 축소
              height: 24, // 30 -> 24로 축소
              padding: const EdgeInsets.symmetric(horizontal: 4), // 내부 동그라미 여백 유지
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _isAlarmEnabled
                    ? const Color(0xFFF2E4BE)  // 켜졌을 때 부드러운 노란색
                    : const Color(0xFFE5E5E5), // 꺼졌을 때 회색
              ),
              child: AlignmentGuidedAnimatedWidget(
                alignment: _isAlarmEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16,  // 22 -> 16으로 축소 (타원 안에 쏙 파묻힘)
                  height: 16, // 22 -> 16으로 축소
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