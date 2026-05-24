import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:fe_app/core/theme/app_theme.dart';

class ServiceTermsScreen extends StatelessWidget {
  const ServiceTermsScreen({super.key});

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
                  title: '서비스 이용약관',
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
                  child: _ServiceTermsContent(scale: scale),
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
          // 타이틀 가운데 정렬을 위한 좌우 균형 패딩
          SizedBox(width: arrowSize + 8),
        ],
      ),
    );
  }
}

class _ServiceTermsContent extends StatelessWidget {
  const _ServiceTermsContent({required this.scale});

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
        Text('제 1 조 (목적)', style: headingStyle),
        Text(
          '본 약관은 사용자의 충동구매 방지 및 합리적인 예산 관리를 돕는 서비스 '
          '\'위굴\'(이하 \'서비스\')의 이용과 관련하여, 회사(이하 \'팀\')와 회원 간의 '
          '권리, 의무, 책임사항 및 기타 필요한 사항을 규정함을 목적으로 합니다.',
          style: bodyStyle,
        ),
        gap,
        Text('제 2 조 (회원가입, 연령 제한 및 계정 관리)', style: headingStyle),
        Text(
          '① 본 서비스는 관련 법령에 따라 만 14세 이상만 가입 및 이용이 가능합니다. '
          '가입 시 만 14세 이상임을 확인하며, 만 14세 미만의 가입이 확인될 경우 '
          '사전 통보 없이 계정이 탈퇴 처리될 수 있습니다.',
          style: bodyStyle,
        ),
        Text(
          '② 회원은 카카오, 구글 등 제공되는 소셜 로그인 방식을 통해 서비스에 가입할 수 있습니다.',
          style: bodyStyle,
        ),
        Text(
          '③ 회원은 가입 시 연동한 계정 정보를 안전하게 관리할 책임이 있으며, '
          '타인에게 양도하거나 대여할 수 없습니다.',
          style: bodyStyle,
        ),
        gap,
        Text('제 3 조 (서비스의 제공 및 내용)', style: headingStyle),
        Text('팀은 회원에게 다음의 서비스를 제공합니다.', style: bodyStyle),
        Text(
          '1. 위시 및 소비 관리: 타 앱 공유(크롤링) 또는 직접 입력을 통한 구매 희망 '
          '물품 등록, 당월 예산 설정 및 합리적 선택률 등 소비 관리 지표 제공',
          style: bodyStyle,
        ),
        Text(
          '2. 구매 숙려 및 평가: 등록된 위시에 대한 구매 보류 기간 제공, 구매 후 7일 '
          '경과 시점에 발송되는 알림을 통한 만족도 평가 데이터 수집',
          style: bodyStyle,
        ),
        Text(
          '3. 소셜 피드 커뮤니티: 익명 기반의 게시글 업로드, 댓글 작성, 구매 찬반 투표 기능',
          style: bodyStyle,
        ),
        Text(
          '4. 기타 팀이 추가 개발하여 회원에게 제공하는 일체의 서비스',
          style: bodyStyle,
        ),
        gap,
        Text('제 4 조 (게시물 및 데이터의 관리, 악성 유저 제재)', style: headingStyle),
        Text(
          '① 회원이 소셜 피드에 작성한 게시물(게시글, 댓글 등)에 대한 책임과 권리는 '
          '작성자인 회원에게 있습니다.',
          style: bodyStyle,
        ),
        Text(
          '② 소셜 피드는 철저한 익명 기반으로 운영되며, 회원은 본인이 작성한 게시글 및 '
          '댓글을 언제든지 삭제할 수 있습니다. 단, 게시글의 경우 본문 텍스트만 수정이 '
          '가능하며 연결된 위시 물품 정보는 수정할 수 없습니다.',
          style: bodyStyle,
        ),
        Text(
          '③ [제재 조항] 욕설, 비방, 타인 명예훼손, 음란물, 도배, 부적절한 광고 등 '
          '커뮤니티의 목적을 훼손하거나 타인에게 불쾌감을 주는 게시물을 작성할 경우, '
          '사전 통보 없이 해당 게시물이 삭제될 수 있으며 해당 유저의 서비스 이용이 '
          '정지되거나 영구 차단될 수 있습니다.',
          style: bodyStyle,
        ),
        gap,
        Text('제 5 조 (외부 서비스 연동 및 면책 조항)', style: headingStyle),
        Text(
          '① \'타 앱에서 공유하기\' 기능을 통해 자동으로 수집(크롤링)되는 물품의 이름, '
          '이미지, 가격 등의 정보는 해당 외부 쇼핑몰의 상황에 따라 변동될 수 있으며, '
          '팀은 수집된 정보의 최신성 및 정확성을 보증하지 않습니다.',
          style: bodyStyle,
        ),
        Text(
          '② 팀이 제공하는 소비 관리 지표(합리적 선택률, 예산 현황 등) 및 커뮤니티 투표 '
          '결과는 회원의 합리적인 의사결정을 돕기 위한 보조 수단입니다. 회원의 최종 구매 '
          '결정에 대한 책임은 회원 본인에게 있으며, 서비스 이용으로 인해 발생하는 어떠한 '
          '금전적 손실이나 외부 쇼핑몰과의 거래 분쟁에 대해서도 팀은 법적 책임을 지지 않습니다.',
          style: bodyStyle,
        ),
        gap,
        Text('제 6 조 (회원 탈퇴 및 데이터 처리)', style: headingStyle),
        Text(
          '① 회원은 언제든지 앱 내 마이페이지를 통해 계정 탈퇴를 요청할 수 있습니다.',
          style: bodyStyle,
        ),
        Text(
          '② 회원 탈퇴 시, 서비스 생태계 유지 및 원활한 커뮤니티 운영을 위해 데이터는 '
          '다음과 같이 처리됩니다.',
          style: bodyStyle,
        ),
        Text(
          '1. 게시글: 회원이 소셜 피드에 직접 업로드한 게시글은 삭제 처리됩니다.',
          style: bodyStyle,
        ),
        Text(
          "2. 댓글 및 투표: 타인의 게시글에 작성한 댓글은 '알 수 없음'으로 비식별화되어 "
          '유지되며, 투표 기록 또한 통계를 위해 유지됩니다.',
          style: bodyStyle,
        ),
        Text(
          '3. 소비 통계: 예산 및 구매 만족도 등은 개인을 식별할 수 없는 데이터로 보존됩니다.',
          style: bodyStyle,
        ),
        gap,
        Text('제 7 조 (서비스의 변경 및 중지)', style: headingStyle),
        Text(
          '팀은 정책 개정이나 서비스 업데이트 시 회원에게 사전 공지하며, '
          '필수 약관 개정 시 재동의를 요청할 수 있습니다.',
          style: bodyStyle,
        ),
      ],
    );
  }
}
