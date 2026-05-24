import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:fe_app/core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _designWidth = 412.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / _designWidth;
          final hPad = (constraints.maxWidth * (24 / _designWidth))
              .clamp(20.0, 48.0);
          final headerHPad = (constraints.maxWidth * (28 / _designWidth))
              .clamp(22.0, 56.0);
          final arrowSize = (18.658 * scale).clamp(15.0, 24.0);

          return Column(
            children: [
              SafeArea(
                bottom: false,
                child: _Header(
                  title: '개인정보 처리방침',
                  arrowSize: arrowSize,
                  hPad: headerHPad,
                  bottomPad: (18 * scale).clamp(14.0, 22.0),
                  fontSize: (20 * scale).clamp(15.0, 26.0),
                  onBack: () => context.pop(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    (17 * scale).clamp(12.0, 22.0),
                    hPad,
                    (40 * scale).clamp(30.0, 52.0),
                  ),
                  child: _PrivacyPolicyContent(scale: scale),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.arrowSize,
    required this.hPad,
    required this.bottomPad,
    required this.fontSize,
    required this.onBack,
  });

  final String title;
  final double arrowSize;
  final double hPad;
  final double bottomPad;
  final double fontSize;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, bottomPad),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Transform.rotate(
                angle: pi,
                child: SvgPicture.asset(
                  'assets/images/arrow_forward.svg',
                  width: arrowSize,
                  height: arrowSize,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brown,
                  height: 1.2,
                ),
              ),
            ),
          ),
          SizedBox(width: arrowSize + 8),
        ],
      ),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final fontSize = (14 * scale).clamp(11.0, 18.0);

    final headingStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.548,
    );

    final bodyStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.548,
    );

    final gap = SizedBox(height: (14 * scale).clamp(10.0, 18.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('1. 수집하는 개인정보의 항목 및 수집 방법', style: headingStyle),
        Text(
          '위굴은 원활한 서비스 제공을 위해 아래의 개인정보를 수집합니다.',
          style: bodyStyle,
        ),
        Text(
          '필수 항목: 소셜 로그인 시 제공되는 고유 식별자, 이메일 주소, 서비스 닉네임, '
          '서비스 이용 기록(위시 등록 내역, 예산, 구매 여부 등), 접속 로그',
          style: bodyStyle,
        ),
        Text('선택 항목: 프로필 이미지', style: bodyStyle),
        Text(
          '수집 제한: 본 앱은 만 14세 미만 아동의 개인정보를 수집하지 않으며, '
          '기기의 연락처나 실제 금융 결제 정보 등 목적과 무관한 민감 정보는 요구하지 않습니다.',
          style: bodyStyle,
        ),
        gap,
        Text('2. 개인정보의 수집 및 이용 목적', style: headingStyle),
        Text(
          '소셜 계정 연동을 통한 본인 식별, 연령 확인 및 부정이용 방지',
          style: bodyStyle,
        ),
        Text(
          '충동구매 억제를 위한 맞춤형 예산 현황, 합리적 선택률 시각적 지표 제공',
          style: bodyStyle,
        ),
        Text(
          '구매 후 만족도 조사 등 서비스 맞춤형 푸시 알림 발송',
          style: bodyStyle,
        ),
        Text(
          '익명 기반 소셜 커뮤니티(게시글, 댓글, 투표) 운영 및 악성 유저 제재',
          style: bodyStyle,
        ),
        Text('서비스 품질 개선 및 통계 분석', style: bodyStyle),
        gap,
        Text('3. 개인정보의 제3자 제공 및 공유', style: headingStyle),
        Text(
          '위굴은 이용자의 개인정보를 원칙적으로 외부에 제공하지 않습니다. '
          '단, 수사 목적으로 법령에 정해진 절차에 따라 수사기관의 요구가 있는 경우는 예외로 합니다.',
          style: bodyStyle,
        ),
        gap,
        Text('4. 개인정보의 보유, 파기 절차 및 방법', style: headingStyle),
        Text(
          '이용자가 탈퇴를 요청하는 경우, 개인 식별 정보는 즉시 파기합니다. '
          '단, 커뮤니티 및 통계 품질을 위해 다음은 예외로 합니다.',
          style: bodyStyle,
        ),
        Text(
          '소셜 피드 게시글: 탈퇴 시 즉시 삭제',
          style: bodyStyle,
        ),
        Text(
          "소셜 피드 댓글 및 투표: 작성자를 '알 수 없음'으로 변경하여 비식별화 처리 후 보존, 투표 기록 유지",
          style: bodyStyle,
        ),
        Text(
          '소비 통계 데이터: 완전히 비식별화된 상태로 서비스 분석을 위해 보존',
          style: bodyStyle,
        ),
        gap,
        Text('5. 보안 및 사용자 권리', style: headingStyle),
        Text(
          '이용자는 마이페이지를 통해 언제든지 개인정보를 수정하거나, '
          '회원 탈퇴를 통해 동의를 철회할 수 있습니다. '
          '위굴은 암호화 통신을 통해 데이터를 안전하게 전송하고 보호합니다.',
          style: bodyStyle,
        ),
        gap,
        Text('6. 개인정보보호책임자 및 고객센터', style: headingStyle),
        Text(
          '위굴 서비스를 운영하는 앱티브 404호 팀은 이용자의 개인정보를 보호하고 '
          '관련 문의 및 불만 사항을 처리하기 위해 아래와 같이 고객 문의 창구를 운영하고 있습니다.',
          style: bodyStyle,
        ),
        Text('담당 부서: 앱티브 404호 기획팀', style: bodyStyle),
        Text('이메일: [대표 이메일 주소 기입]', style: bodyStyle),
      ],
    );
  }
}
