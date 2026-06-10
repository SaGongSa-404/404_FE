import 'package:flutter/material.dart';

import 'package:fe_app/features/legal/widgets/legal_text.dart';

class ServiceTermsBody extends StatelessWidget {
  const ServiceTermsBody({
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
            text: '[필수] 위굴 서비스 이용약관',
            style: requiredTitleStyle!,
          ),
          sectionGap,
        ],
        LegalBodyText(text: '제 1 조 (목적)', style: headingStyle),
        LegalBodyText(
          text:
              '본 약관은 사용자의 충동구매 방지 및 합리적인 예산 관리를 돕는 서비스 '
              '\'위굴\'(이하 \'서비스\')의 이용과 관련하여, 회사(이하 \'팀\')와 회원 간의 '
              '권리, 의무, 책임사항 및 기타 필요한 사항을 규정함을 목적으로 합니다.',
          style: bodyStyle,
        ),
        sectionGap,
        LegalBodyText(
          text: '제 2 조 (회원가입, 연령 제한 및 계정 관리)',
          style: headingStyle,
        ),
        LegalRichBodyText(
          baseStyle: bodyStyle,
          children: [
            legalPlainSpan('① 본 서비스는 관련 법령에 따라 '),
            legalBoldSpan('만 14세 이상만 가입 및 이용이 가능', bodyStyle),
            legalPlainSpan(
              '합니다. 가입 시 만 14세 이상임을 확인하며, 만 14세 미만의 가입이 확인될 경우 '
              '사전 통보 없이 계정이 탈퇴 처리될 수 있습니다.',
            ),
          ],
        ),
        LegalBodyText(
          text: '② 회원은 카카오, 구글 등 제공되는 소셜 로그인 방식을 통해 서비스에 가입할 수 있습니다.',
          style: bodyStyle,
        ),
        LegalBodyText(
          text:
              '③ 회원은 가입 시 연동한 계정 정보를 안전하게 관리할 책임이 있으며, '
              '타인에게 양도하거나 대여할 수 없습니다.',
          style: bodyStyle,
        ),
        sectionGap,
        LegalBodyText(text: '제 3 조 (서비스의 제공 및 내용)', style: headingStyle),
        LegalBodyText(
          text: '팀은 회원에게 다음의 서비스를 제공합니다.',
          style: bodyStyle,
        ),
        LegalRichBodyText(
          baseStyle: bodyStyle,
          children: [
            legalPlainSpan('1. '),
            legalBoldSpan('위시 및 소비 관리:', bodyStyle),
            legalPlainSpan(
              ' 타 앱 공유(크롤링) 또는 직접 입력을 통한 구매 희망 물품 등록, '
              '당월 예산 설정 및 합리적 선택률 등 소비 관리 지표 제공',
            ),
          ],
        ),
        LegalRichBodyText(
          baseStyle: bodyStyle,
          children: [
            legalPlainSpan('2. '),
            legalBoldSpan('구매 숙려 및 평가:', bodyStyle),
            legalPlainSpan(
              ' 등록된 위시에 대한 구매 보류 기간 제공, 구매 후 7일 경과 시점에 발송되는 '
              '알림을 통한 만족도 평가 데이터 수집',
            ),
          ],
        ),
        LegalRichBodyText(
          baseStyle: bodyStyle,
          children: [
            legalPlainSpan('3. '),
            legalBoldSpan('소셜 피드 커뮤니티:', bodyStyle),
            legalPlainSpan(
              ' 익명 기반의 게시글 업로드, 댓글 작성, 구매 찬반 투표 기능',
            ),
          ],
        ),
        LegalBodyText(
          text: '4. 기타 팀이 추가 개발하여 회원에게 제공하는 일체의 서비스',
          style: bodyStyle,
        ),
        sectionGap,
        LegalBodyText(
          text: '제 4 조 (게시물 및 데이터의 관리, 악성 유저 제재)',
          style: headingStyle,
        ),
        LegalBodyText(
          text:
              '① 회원이 소셜 피드에 작성한 게시물(게시글, 댓글 등)에 대한 책임과 권리는 '
              '작성자인 회원에게 있습니다.',
          style: bodyStyle,
        ),
        LegalBodyText(
          text:
              '② 소셜 피드는 철저한 익명 기반으로 운영되며, 회원은 본인이 작성한 게시글 및 '
              '댓글을 언제든지 삭제할 수 있습니다. 단, 게시글의 경우 본문 텍스트만 수정이 '
              '가능하며 연결된 위시 물품 정보는 수정할 수 없습니다.',
          style: bodyStyle,
        ),
        LegalBodyText(
          text:
              '③ [제재 조항] 욕설, 비방, 타인 명예훼손, 음란물, 도배, 부적절한 광고 등 '
              '커뮤니티의 목적을 훼손하거나 타인에게 불쾌감을 주는 게시물을 작성할 경우, '
              '사전 통보 없이 해당 게시물이 삭제될 수 있으며 해당 유저의 서비스 이용이 '
              '정지되거나 영구 차단될 수 있습니다.',
          style: bodyStyle,
        ),
        LegalBodyText(
          text:
              '④ [신고 및 차단 기능] 회원은 불쾌감을 주거나 본 약관을 위반하는 게시글 및 '
              '댓글을 발견할 경우, 앱 내 신고 기능을 통해 사유를 직접 입력하여 신고할 수 있습니다. '
              '또한, 특정 사용자를 차단할 수 있으며, 차단된 사용자가 작성한 게시글 및 댓글은 '
              '차단한 회원에게 더 이상 노출되지 않습니다. 팀은 신고된 콘텐츠를 신속하게 검토하고 '
              '정책에 따라 적절한 조치를 취합니다.',
          style: bodyStyle,
        ),
        sectionGap,
        LegalBodyText(
          text: '제 5 조 (외부 서비스 연동 및 면책 조항)',
          style: headingStyle,
        ),
        LegalBodyText(
          text:
              '① \'타 앱에서 공유하기\' 기능을 통해 자동으로 수집(크롤링)되는 물품의 이름, '
              '이미지, 가격 등의 정보는 해당 외부 쇼핑몰의 상황에 따라 변동될 수 있으며, '
              '팀은 수집된 정보의 최신성 및 정확성을 보증하지 않습니다.',
          style: bodyStyle,
        ),
        LegalBodyText(
          text:
              '② 팀이 제공하는 소비 관리 지표(합리적 선택률, 예산 현황 등) 및 커뮤니티 투표 '
              '결과는 회원의 합리적인 의사결정을 돕기 위한 보조 수단입니다. 회원의 최종 구매 '
              '결정에 대한 책임은 회원 본인에게 있으며, 서비스 이용으로 인해 발생하는 어떠한 '
              '금전적 손실이나 외부 쇼핑몰과의 거래 분쟁에 대해서도 팀은 법적 책임을 지지 않습니다.',
          style: bodyStyle,
        ),
        sectionGap,
        LegalBodyText(text: '제 6 조 (회원 탈퇴 및 데이터 처리)', style: headingStyle),
        LegalBodyText(
          text: '① 회원은 언제든지 앱 내 마이페이지를 통해 계정 탈퇴를 요청할 수 있습니다.',
          style: bodyStyle,
        ),
        LegalBodyText(
          text:
              '② 회원 탈퇴 시, 서비스 생태계 유지 및 원활한 커뮤니티 운영을 위해 데이터는 '
              '다음과 같이 처리됩니다.',
          style: bodyStyle,
        ),
        LegalRichBodyText(
          baseStyle: bodyStyle,
          children: [
            legalPlainSpan('1. '),
            legalBoldSpan('게시글:', bodyStyle),
            legalPlainSpan(
              ' 회원이 소셜 피드에 직접 업로드한 게시글은 삭제 처리됩니다.',
            ),
          ],
        ),
        LegalRichBodyText(
          baseStyle: bodyStyle,
          children: [
            legalPlainSpan('2. '),
            legalBoldSpan('댓글 및 투표:', bodyStyle),
            legalPlainSpan(
              ' 타인의 게시글에 작성한 댓글은 \'알 수 없음\'으로 비식별화되어 '
              '유지되며, 투표 기록 또한 통계를 위해 유지됩니다.',
            ),
          ],
        ),
        LegalRichBodyText(
          baseStyle: bodyStyle,
          children: [
            legalPlainSpan('3. '),
            legalBoldSpan('소비 통계:', bodyStyle),
            legalPlainSpan(
              ' 예산 및 구매 만족도 등은 개인을 식별할 수 없는 데이터로 보존됩니다.',
            ),
          ],
        ),
        sectionGap,
        LegalBodyText(text: '제 7 조 (서비스의 변경 및 중지)', style: headingStyle),
        LegalBodyText(
          text:
              '팀은 정책 개정이나 서비스 업데이트 시 개정 약관의 적용일자 최소 7일 전'
              '(회원에게 권리 침해나 불리한 변경이 발생하는 경우 최소 30일 전)에 '
              '앱 내 공지사항을 통해 사전 공지하며, 필수 약관 개정 시 재동의를 요청할 수 있습니다.',
          style: bodyStyle,
        ),
      ],
    );
  }
}
