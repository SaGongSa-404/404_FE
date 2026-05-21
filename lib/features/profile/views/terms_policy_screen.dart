import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsPolicyScreen extends StatefulWidget {
  const TermsPolicyScreen({super.key});

  @override
  State<TermsPolicyScreen> createState() => _TermsPolicyScreenState();
}

class _TermsPolicyScreenState extends State<TermsPolicyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: _backgroundColor,
              padding: EdgeInsets.only(
                left: 30 * scale,
                right: 30 * scale,
                top: 54 * scale,
                bottom: 16 * scale,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                        size: 18 * scale,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  Text(
                    '약관 및 정책',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: _backgroundColor,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: const Color(0xFFADADAD),
                indicatorColor: AppColors.textPrimary,
                indicatorWeight: 2 * scale,
                labelStyle: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.bold),
                unselectedLabelStyle: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: '이용약관'),
                  Tab(text: '개인정보 처리방침'),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                color: _backgroundColor,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTermsContent(scale),
                    _buildPrivacyContent(scale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsContent(double scale) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 20 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[필수] 위굴 서비스 이용약관',
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16 * scale),
          _buildParagraphTitle('제 1 조 (목적)', scale),
          _buildParagraphBody(
            '본 약관은 사용자의 충동구매 방지 및 합리적인 예산 관리를 돕는 서비스 \'위굴\'(이하 \'서비스\')의 이용과 관련하여, 회사(이하 \'팀\')와 회원 간의 권리, 의무, 책임사항 및 기타 필요한 사항을 규정함을 목적으로 합니다.',
            scale,
          ),
          _buildParagraphTitle('제 2 조 (회원가입, 연령 제한 및 계정 관리)', scale),
          _buildParagraphBody(
            '1. 본 서비스는 관련 법령에 따라 만 14세 이상만 가입 및 이용이 가능합니다. 가입 시 만 14세 이상임을 확인하며, 만 14세 미만의 가입이 확인될 경우 사전 통보 없이 계정이 탈퇴 처리될 수 있습니다.\n'
                '2. 회원은 카카오, 구글 등 제공되는 소셜 로그인 방식을 통해 서비스에 가입할 수 있습니다.\n'
                '3. 회원은 가입 시 연동한 계정 정보를 안전하게 관리할 책임이 있으며, 타인에게 양도하거나 대여할 수 없습니다.',
            scale,
          ),
          _buildParagraphTitle('제 3 조 (서비스의 제공 및 내용)', scale),
          _buildParagraphBody(
            '팀은 회원에게 다음의 서비스를 제공합니다.\n\n'
                '• 위시 및 소비 관리: 타 앱 공유(크롤링) 또는 직접 입력을 통한 구매 희망 물품 등록, 당월 예산 설정 및 합리적 선택률 등 소비 관리 지표 제공\n'
                '• 구매 숙려 및 평가: 등록된 위시에 대한 구매 보류 기간 제공, 구매 후 7일 경과 시점에 발송되는 알림을 통한 만족도 평가 데이터 수집\n'
                '• 소셜 피드 커뮤니티: 익명 기반의 게시글 업로드, 댓글 작성, 구매 찬반 투표 기능\n'
                '• 기타 팀이 추가 개발하여 회원에게 제공하는 일체의 서비스',
            scale,
          ),
          _buildParagraphTitle('제 4 조 (게시물 및 데이터의 관리, 악성 유저 제재)', scale),
          _buildParagraphBody(
            '1. 회원이 소셜 피드에 작성한 게시물(게시글, 댓글 등)에 대한 책임과 권리는 작성자인 회원에게 있습니다.\n'
                '2. 소셜 피드는 철저한 익명 기반으로 운영되며, 회원은 본인이 작성한 게시글 및 댓글을 언제든지 삭제할 수 있습니다. 단, 게시글의 경우 본문 텍스트만 수정이 가능하며 연결된 위시 물품 정보는 수정할 수 없습니다.\n'
                '3. [제재 조항] 욕설, 비방, 타인 명예훼손, 음란물, 도배, 부적절한 광고 등 커뮤니티의 목적을 훼손하거나 타인에게 불쾌감을 주는 게시물을 작성할 경우, 사전 통보 없이 해당 게시물이 삭제될 수 있으며 해당 유저의 서비스 이용이 정지되거나 영구 차단될 수 있습니다.',
            scale,
          ),
          _buildParagraphTitle('제 5 조 (외부 서비스 연동 및 면책 조항)', scale),
          _buildParagraphBody(
            '1. \'타 앱에서 공유하기\' 기능을 통해 자동으로 수집(크롤링)되는 물품의 이름, 이미지, 가격 등의 정보는 해당 외부 쇼핑몰의 상황에 따라 변동될 수 있으며, 팀은 수집된 정보의 최신성 및 정확성을 보증하지 않습니다.\n'
                '2. 팀이 제공하는 소비 관리 지표(합리적 선택률, 예산 현황 등) 및 커뮤니티 투표 결과는 회원의 합리적인 의사결정을 돕기 위한 보조 수단입니다. 회원의 최종 구매 결정에 대한 책임은 회원 본인에게 있으며, 서비스 이용으로 인해 발생하는 어떠한 금전적 손실이나 외부 쇼핑몰과의 거래 분쟁에 대해서도 팀은 법적 책임을 지지 않습니다.',
            scale,
          ),
          _buildParagraphTitle('제 6 조 (회원 탈퇴 및 데이터 처리)', scale),
          _buildParagraphBody(
            '1. 회원은 언제든지 앱 내 마이페이지를 통해 계정 탈퇴를 요청할 수 있습니다.\n'
                '2. 회원 탈퇴 시, 서비스 생태계 유지 및 원활한 커뮤니티 운영을 위해 데이터는 다음과 같이 처리됩니다.\n\n'
                '• 게시글: 회원이 소셜 피드에 직접 업로드한 게시글은 삭제 처리됩니다.\n'
                '• 댓글 및 투표: 타인의 게시글에 작성한 댓글은 \'알 수 없음\'으로 비식별화되어 유지되며, 투표 기록 또한 통계를 위해 유지됩니다.\n'
                '• 소비 통계: 예산 및 구매 만족도 등은 개인을 식별할 수 없는 데이터로 보존됩니다.',
            scale,
          ),
          _buildParagraphTitle('제 7 조 (서비스의 변경 및 중지)', scale),
          _buildParagraphBody(
            '팀은 정책 개정이나 서비스 업데이트 시 회원에게 사전 공지하며, 필수 약관 개정 시 재동의를 요청할 수 있습니다.',
            scale,
          ),
          SizedBox(height: 30 * scale),
        ],
      ),
    );
  }

  Widget _buildPrivacyContent(double scale) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 20 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[필수] 개인정보 처리방침',
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16 * scale),
          _buildParagraphTitle('1. 수집하는 개인정보의 항목 및 수집 방법', scale),
          _buildParagraphBody(
            '위굴은 원활한 서비스 제공을 위해 아래의 개인정보를 수집합니다.\n\n'
                '• 필수 항목: 소셜 로그인 시 제공되는 고유 식별자, 이메일 주소, 서비스 닉네임, 서비스 이용 기록(위시 등록 내역, 예산, 구매 여부 등), 접속 로그\n'
                '• 선택 항목: 프로필 이미지\n'
                '• 수집 제한: 본 앱은 만 14세 미만 아동의 개인정보를 수집하지 않으며, 기기의 연락처나 실제 금융 결제 정보 등 목적과 무관한 민감 정보는 요구하지 않습니다.',
            scale,
          ),
          _buildParagraphTitle('2. 개인정보의 수집 및 이용 목적', scale),
          _buildParagraphBody(
            '• 소셜 계정 연동을 통한 본인 식별, 연령 확인 및 부정이용 방지\n'
                '• 충동구매 억제를 위한 맞춤형 예산 현황, 합리적 선택률 시각적 지표 제공\n'
                '• 구매 후 만족도 조사 등 서비스 맞춤형 푸시 알림 발송\n'
                '• 익명 기반 소셜 커뮤니티(게시글, 댓글, 투표) 운영 및 악성 유저 제재\n'
                '• 서비스 품질 개선 및 통계 분석',
            scale,
          ),
          _buildParagraphTitle('3. 개인정보의 제3자 제공 및 공유', scale),
          _buildParagraphBody(
            '위굴은 이용자의 개인정보를 원칙적으로 외부에 제공하지 않습니다. 단, 수사 목적으로 법령에 정해진 절차에 따라 수사기관의 요구가 있는 경우는 예외로 합니다.',
            scale,
          ),
          _buildParagraphTitle('4. 개인정보의 보유, 파기 절차 및 방법', scale),
          _buildParagraphBody(
            '이용자가 탈퇴를 요청하는 경우, 개인 식별 정보는 즉시 파기합니다. 단, 커뮤니티 및 통계 품질을 위해 다음은 예외로 합니다.\n\n'
                '• 소셜 피드 게시글: 탈퇴 시 즉시 삭제\n'
                '• 소셜 피드 댓글 및 투표: 작성자를 \'알 수 없음\'으로 변경하여 비식별화 처리 후 보존, 투표 기록 유지\n'
                '• 소비 통계 데이터: 완전히 비식별화된 상태로 서비스 분석을 위해 보존',
            scale,
          ),
          _buildParagraphTitle('5. 보안 및 사용자 권리', scale),
          _buildParagraphBody(
            '이용자는 마이페이지를 통해 언제든지 개인정보를 수정하거나, 회원 탈퇴를 통해 동의를 철회할 수 있습니다. 위굴은 암호화 통신을 통해 데이터를 안전하게 전송하고 보호합니다.',
            scale,
          ),
          _buildParagraphTitle('6. 개인정보보호책임자 및 고객센터', scale),
          _buildParagraphBody(
            '위굴 서비스를 운영하는 앱티브 404호 팀은 이용자의 개인정보를 보호하고 관련 문의 및 불만 사항을 처리하기 위해 아래와 같이 고객 문의 창구를 운영하고 있습니다.',
            scale,
          ),
          SizedBox(height: 30 * scale),
        ],
      ),
    );
  }

  Widget _buildParagraphTitle(String title, double scale) {
    return Padding(
      padding: EdgeInsets.only(top: 18 * scale, bottom: 6 * scale),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14 * scale,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildParagraphBody(String body, double scale) {
    return Text(
      body,
      style: TextStyle(
        fontSize: 13 * scale,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }
}
