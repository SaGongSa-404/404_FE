import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:fe_app/core/services/notification_permission_service.dart';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_back_button.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_layout.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_primary_button.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_spaced_scroll_view.dart';
import 'package:fe_app/shared/widgets/app_exit_modal.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  static const _designWidth = 412.0;
  static const Color _dimColor = Color(0x59000000);

  bool _agreeAll = false;
  bool _agreeService = false;
  bool _agreePrivacy = false;
  bool _showNotificationDim = false;

  bool get _canStart => _agreeService && _agreePrivacy;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_promptNotificationPermissionIfNeeded());
    });
  }

  Future<void> _promptNotificationPermissionIfNeeded() async {
    if (!mounted) return;

    // 스플래시·라우트 전환 직후에는 Activity가 준비되기 전이라 OS 모달이 안 뜰 수 있음
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (!await NotificationPermissionService.shouldPrompt()) return;

    setState(() => _showNotificationDim = true);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    await NotificationPermissionService.request();

    if (mounted) {
      setState(() => _showNotificationDim = false);
    }
  }

  void _toggleAll() {
    setState(() {
      final next = !_agreeAll;
      _agreeAll = next;
      _agreeService = next;
      _agreePrivacy = next;
    });
  }

  void _toggleService() {
    setState(() {
      _agreeService = !_agreeService;
      _agreeAll = _agreeService && _agreePrivacy;
    });
  }

  void _togglePrivacy() {
    setState(() {
      _agreePrivacy = !_agreePrivacy;
      _agreeAll = _agreeService && _agreePrivacy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppExitBackHandler(
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / _designWidth;
            final hPad = (constraints.maxWidth * (24 / _designWidth))
                .clamp(20.0, 48.0);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: OnboardingSpacedScrollView(
                    viewportHeight: constraints.maxHeight,
                    children: [
                            OnboardingLayout.topSpacer(),
                            OnboardingBackButton(
                              onTap: () => confirmAppExit(context),
                            ),
                            SizedBox(height: (74 * scale).clamp(55.0, 92.0)),
                            // 제목 영역
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: (8 * scale).clamp(6.0, 10.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '이용약관 및 개인정보 처리방침',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize:
                                          (26 * scale).clamp(19.0, 33.0),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                      height: 1.36,
                                    ),
                                  ),
                                  SizedBox(
                                      height: (12 * scale).clamp(9.0, 16.0)),
                                  Text(
                                    '위굴을 시작하기 전, 약관을 확인해 주세요',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize:
                                          (18 * scale).clamp(14.0, 23.0),
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textPrimary,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: (40 * scale).clamp(30.0, 52.0)),
                            // 수집 항목 요약 카드
                            _SummaryCard(scale: scale, allAgreed: _canStart),
                            SizedBox(height: (37 * scale).clamp(28.0, 48.0)),
                            // 동의 체크박스 목록
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ConsentCheckRow(
                                  checked: _agreeAll,
                                  onTap: _toggleAll,
                                  label: '전체 동의',
                                  scale: scale,
                                ),
                                SizedBox(
                                    height: (12 * scale).clamp(9.0, 16.0)),
                                _ConsentCheckRow(
                                  checked: _agreeService,
                                  onTap: _toggleService,
                                  label: '서비스 이용약관 동의',
                                  scale: scale,
                                  isRequired: true,
                                  onRequiredTap: () => context.push('/onboarding/service-terms'),
                                ),
                                SizedBox(
                                    height: (12 * scale).clamp(9.0, 16.0)),
                                _ConsentCheckRow(
                                  checked: _agreePrivacy,
                                  onTap: _togglePrivacy,
                                  label: '개인정보 처리방침 동의',
                                  scale: scale,
                                  isRequired: true,
                                  onRequiredTap: () => context.push('/onboarding/privacy-policy'),
                                ),
                              ],
                            ),
                            SizedBox(height: (16 * scale).clamp(12.0, 20.0)),
                            // 안내 문구
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '※ ',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize:
                                          (14 * scale).clamp(11.0, 18.0),
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                      height: 1.45,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '동의를 거부하실 수 있으나, 거부 시 서비스 이용이 제한됩니다.',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize:
                                          (14 * scale).clamp(11.0, 18.0),
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondary,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(flex: 118),
                            // 시작하기 버튼
                            OnboardingPrimaryButton(
                              label: '시작하기',
                              onPressed: _canStart
                                  ? () =>
                                      context.push('/onboarding/nickname')
                                  : null,
                              fontSize: (18 * scale).clamp(14.0, 23.0),
                            ),
                            const Spacer(flex: 40),
                    ],
                  ),
                ),
              ),
            );
          },
            ),
          ),
          if (_showNotificationDim)
            const Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(color: _dimColor),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.scale, required this.allAgreed});

  final double scale;
  final bool allAgreed;

  @override
  Widget build(BuildContext context) {
    final fontSize14 = (14 * scale).clamp(11.0, 18.0);
    final fontSize16 = (16 * scale).clamp(12.0, 20.0);
    final fontSize17 = (17 * scale).clamp(13.0, 22.0);
    final rowGap = (3 * scale).clamp(2.0, 4.0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular((22 * scale).clamp(16.0, 28.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: (18 * scale).clamp(14.0, 22.0),
        vertical: (16 * scale).clamp(12.0, 20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '수집 항목 요약 ',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: fontSize17,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
                TextSpan(
                  text: '[필수]',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: fontSize16,
                    fontWeight: FontWeight.w500,
                    color: allAgreed
                        ? AppColors.skyBlue_300
                        : AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: (12 * scale).clamp(9.0, 16.0)),
          _InfoRow(
            label: '수집 항목',
            value: '이메일, 프로필 이름, 고유 식별자',
            fontSize: fontSize14,
          ),
          SizedBox(height: rowGap),
          _InfoRow(
            label: '수집 목적',
            value: '회원 식별, 서비스 제공',
            fontSize: fontSize14,
          ),
          SizedBox(height: rowGap),
          _InfoRow(
            label: '보유 기간',
            value: '탈퇴 시 즉시 파기',
            fontSize: fontSize14,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.fontSize,
  });

  final String label;
  final String value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            height: 1.45,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            softWrap: true,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsentCheckRow extends StatelessWidget {
  const _ConsentCheckRow({
    required this.checked,
    required this.onTap,
    required this.label,
    required this.scale,
    this.isRequired = false,
    this.onRequiredTap,
  });

  final bool checked;
  final VoidCallback onTap;
  final String label;
  final double scale;
  final bool isRequired;
  final VoidCallback? onRequiredTap;

  @override
  Widget build(BuildContext context) {
    final iconSize = (30 * scale).clamp(24.0, 38.0);
    final fontSize18 = (18 * scale).clamp(14.0, 23.0);
    final fontSize16 = (16 * scale).clamp(12.0, 20.0);
    final gap = (6 * scale).clamp(5.0, 8.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: SvgPicture.asset(
              checked
                  ? 'assets/images/link_check_clicked.svg'
                  : 'assets/images/link_check.svg',
              width: iconSize,
              height: iconSize,
            ),
          ),
        ),
        SizedBox(width: gap),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: fontSize18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRequiredTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                '[필수]',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: fontSize16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.skyBlue_300,
                  height: 1.45,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.skyBlue_300,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
