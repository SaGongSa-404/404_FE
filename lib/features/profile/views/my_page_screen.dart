import 'package:fe_app/core/services/notification_permission_service.dart';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/profile/providers/my_profile_provider.dart';
import 'package:fe_app/features/profile/providers/notification_settings_provider.dart';
import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
import 'package:fe_app/shared/widgets/confirm_bottom_sheet.dart';
import 'package:fe_app/shared/widgets/main_tab_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myProfileProvider.notifier).load(force: true);
      ref.read(notificationSettingsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final myProfile = ref.watch(myProfileProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);

    ref.listen(authProvider, (prev, next) {
      if (next.hasValue &&
          next.value != null &&
          prev?.valueOrNull == null) {
        ref.read(myProfileProvider.notifier).load(force: true);
      }
    });

    ref.listen<MyProfileState>(myProfileProvider, (prev, next) {
      if (prev?.errorMessage != next.errorMessage && next.errorMessage != null) {
        showCapsuleToast(
          context,
          backgroundColor: AppColors.red_600.withValues(alpha: 0.8),
          text: next.errorMessage!,
        );
      }
    });

    ref.listen<NotificationSettingsState>(notificationSettingsProvider, (prev, next) {
      if (prev?.errorMessage != next.errorMessage && next.errorMessage != null) {
        showCapsuleToast(
          context,
          backgroundColor: AppColors.red_600.withValues(alpha: 0.8),
          text: next.errorMessage!,
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const AppBottomNavigationBar(),
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
                      Image.asset(
                        'assets/images/nugul_face.png',
                        width: 118 * scale,
                        height: 118 * scale,

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
                              text: myProfile.isLoading && myProfile.nickname.isEmpty
                                  ? '...'
                                  : myProfile.nickname,
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
                      _buildAlarmToggle(
                        scale,
                        notificationSettings: notificationSettings,
                      ),
                      SizedBox(height: 40 * scale),
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

  Widget _buildAlarmToggle(
    double scale, {
    required NotificationSettingsState notificationSettings,
  }) {
    final isEnabled = notificationSettings.notificationEnabled;
    final isInteractive =
        !notificationSettings.isLoading && !notificationSettings.isUpdating;

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
            onTap: isInteractive ? () => _onAlarmToggleTap() : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44 * scale,
              height: 24 * scale,
              padding: EdgeInsets.symmetric(horizontal: 4 * scale),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12 * scale),
                color: isEnabled
                    ? const Color(0xFFF2E4BE)
                    : const Color(0xFFE5E5E5),
              ),
              child: AlignmentGuidedAnimatedWidget(
                alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
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

  Future<void> _onAlarmToggleTap() async {
    final settings = ref.read(notificationSettingsProvider);
    if (settings.isLoading || settings.isUpdating) return;

    final notifier = ref.read(notificationSettingsProvider.notifier);

    if (settings.notificationEnabled) {
      final ok = await notifier.setEnabled(false);
      if (!mounted) return;
      if (ok) {
        _showAlarmToast('알람이 꺼졌습니다');
      }
      return;
    }

    final status = await NotificationPermissionService.status;
    if (!mounted) return;

    if (status.isGranted) {
      final ok = await notifier.setEnabled(true);
      if (!mounted) return;
      if (ok) {
        _showAlarmToast('알람이 설정되었습니다');
      }
      return;
    }

    if (status.isPermanentlyDenied) {
      await _showNotificationPermissionBottomSheet();
      return;
    }

    final result = await NotificationPermissionService.requestPermission();
    if (!mounted) return;

    if (result.isGranted) {
      final ok = await notifier.setEnabled(true);
      if (!mounted) return;
      if (ok) {
        _showAlarmToast('알람이 설정되었습니다');
      }
      return;
    }

    if (result.isPermanentlyDenied) {
      await _showNotificationPermissionBottomSheet();
    }
  }

  void _showAlarmToast(String text) {
    showCapsuleToast(
      context,
      backgroundColor: AppColors.skyBlue_400,
      text: text,
    );
  }

  Future<void> _showNotificationPermissionBottomSheet() async {
    final goToSettings = await showConfirmBottomSheet(
      context,
      title: '알림 권한이 꺼져 있어요',
      subtitle: '푸시 알림을 받으려면 기기 설정에서 알림을 허용해 주세요.',
      actionLabel: '설정으로 이동',
      destructive: false,
    );
    if (goToSettings == true) {
      await NotificationPermissionService.openSettings();
    }
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
