import 'package:flutter/material.dart';

import 'package:fe_app/features/legal/widgets/legal_text.dart';

class PrivacyPolicyBody extends StatelessWidget {
  const PrivacyPolicyBody({
    super.key,
    required this.headingStyle,
    required this.bodyStyle,
    required this.sectionGap,
    this.showRequiredTitle = false,
    this.requiredTitleStyle,
  });

  final TextStyle headingStyle;
  final TextStyle bodyStyle;
  final Widget sectionGap;
  final bool showRequiredTitle;
  final TextStyle? requiredTitleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showRequiredTitle && requiredTitleStyle != null) ...[
          LegalBodyText(
            text: '[필수] 개인정보 처리방침',
            style: requiredTitleStyle!,
          ),
          sectionGap,
        ],
        LegalBodyText(
          text: '1. 수집하는 개인정보의 항목 및 수집 방법',
          style: headingStyle,
        ),
        LegalBodyText(
          text: '위굴은 원활한 서비스 제공을 위해 아래의 개인정보를 수집합니다.',
          style: bodyStyle,
        ),
        LegalRichBodyText(
          baseStyle: bodyStyle,
          children: [
            legalPlainSpan('- '),
            legalBoldSpan('필수 항목:', bodyStyle),
            legalPlainSpan(
              ' 소셜 로그인 시 제공되는 고유 식별자, 이메일 주소, 서비스 닉네임, '
              '서비스 이용 기록(위시 등록 내역, 예산, 구매 여부 등), 접속 로그, '
              '기기 식별자(Device Token), OS 버전',
            ),
          ],
        ),
        LegalRichBodyText(
          baseStyle: bodyStyle,
          children: [
            legalPlainSpan('- '),
            legalBoldSpan('선택 항목:', bodyStyle),
            legalPlainSpan(' 프로필 이미지'),
          ],
        ),
        LegalRichBodyText(
          baseStyle: bodyStyle,
          children: [
            legalPlainSpan('- '),
            legalBoldSpan('수집 제한:', bodyStyle),
            legalPlainSpan(
              ' 본 앱은 만 14세 미만 아동의 개인정보를 수집하지 않으며, '
              '기기의 연락처나 실제 금융 결제 정보 등 목적과 무관한 민감 정보는 요구하지 않습니다.',
            ),
          ],
        ),
        sectionGap,
        LegalBodyText(
          text: '2. 개인정보의 수집 및 이용 목적',
          style: headingStyle,
        ),
        LegalBodyText(
          text: '- 소셜 계정 연동을 통한 본인 식별, 연령 확인 및 부정이용 방지',
          style: bodyStyle,
        ),
        LegalBodyText(
          text: '- 충동구매 억제를 위한 맞춤형 예산 현황, 합리적 선택률 시각적 지표 제공',
          style: bodyStyle,
        ),
        LegalBodyText(
          text: '- 구매 후 만족도 조사 등 서비스 맞춤형 푸시 알림 발송',
          style: bodyStyle,
        ),
        LegalBodyText(
          text: '- 익명 기반 소셜 커뮤니티(게시글, 댓글, 투표) 운영 및 악성 유저 제재',
          style: bodyStyle,
        ),
        LegalBodyText(
          text: '- 서비스 품질 개선 및 통계 분석',
          style: bodyStyle,
        ),
        sectionGap,
        LegalBodyText(
          text: '3. 개인정보의 제3자 제공 및 공유',
          style: headingStyle,
        ),
        LegalBodyText(
          text:
              '위굴은 이용자의 개인정보를 원칙적으로 외부에 제공하지 않습니다. '
              '단, 수사 목적으로 법령에 정해진 절차에 따라 수사기관의 요구가 있는 경우는 예외로 합니다.',
          style: bodyStyle,
        ),
        sectionGap,
        LegalBodyText(
          text: '4. 개인정보의 보유, 파기 절차 및 방법',
          style: headingStyle,
        ),
        LegalBodyText(
          text:
              '이용자가 탈퇴를 요청하는 경우 개인 식별 정보는 원칙적으로 지체 없이 파기합니다. '
              '단, 통신비밀보호법 등 관련 법령에 따라 접속 로그 기록은 3개월간 보관 후 파기하며, '
              '커뮤니티 생태계 및 통계 품질을 위해 다음은 예외로 처리하여 보존합니다.',
          style: bodyStyle,
        ),
        LegalRichBodyText(
          baseStyle: bodyStyle,
          children: [
            legalPlainSpan('- '),
            legalBoldSpan('소셜 피드 게시글:', bodyStyle),
            legalPlainSpan(' 탈퇴 시 즉시 삭제'),
          ],
        ),
        LegalRichBodyText(
          baseStyle: bodyStyle,
          children: [
            legalPlainSpan('- '),
            legalBoldSpan('소셜 피드 댓글 및 투표:', bodyStyle),
            legalPlainSpan(
              ' 작성자를 \'알 수 없음\'으로 변경하여 비식별화 처리 후 보존, 투표 기록 유지',
            ),
          ],
        ),
        LegalRichBodyText(
          baseStyle: bodyStyle,
          children: [
            legalPlainSpan('- '),
            legalBoldSpan('소비 통계 데이터:', bodyStyle),
            legalPlainSpan(' 완전히 비식별화된 상태로 서비스 분석을 위해 보존'),
          ],
        ),
        sectionGap,
        LegalBodyText(text: '5. 보안 및 사용자 권리', style: headingStyle),
        LegalBodyText(
          text:
              '이용자는 마이페이지를 통해 언제든지 개인정보를 수정하거나, '
              '회원 탈퇴를 통해 동의를 철회할 수 있습니다. '
              '위굴은 암호화 통신을 통해 데이터를 안전하게 전송하고 보호합니다.',
          style: bodyStyle,
        ),
        sectionGap,
        LegalBodyText(
          text: '6. 개인정보보호책임자 및 고객센터',
          style: headingStyle,
        ),
        LegalBodyText(
          text:
              '위굴 서비스를 운영하는 앱티브 404호 팀은 이용자의 개인정보를 보호하고 '
              '관련 문의 및 불만 사항을 처리하기 위해 아래와 같이 고객 문의 창구를 운영하고 있습니다.',
          style: bodyStyle,
        ),
        LegalBodyText(
          text: '- 담당 부서: 앱티브 404호 기획팀',
          style: bodyStyle,
        ),
        LegalBodyText(
          text: '개인정보보호책임자',
          style: bodyStyle,
        ),
        LegalBodyText(
          text: '1) 성명: 문성원',
          style: bodyStyle,
        ),
        LegalBodyText(
          text: '2) 직책: 404 PO',
          style: bodyStyle,
        ),
        LegalBodyText(
          text: '3) 전화번호: 010-5929-1325',
          style: bodyStyle,
        ),
        LegalBodyText(
          text: '4) 이메일: wigul.help@gmail.com',
          style: bodyStyle,
        ),
      ],
    );
  }
}
