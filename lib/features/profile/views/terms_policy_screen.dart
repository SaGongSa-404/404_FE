import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/legal/widgets/privacy_policy_body.dart';
import 'package:fe_app/features/legal/widgets/service_terms_body.dart';
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
    final headingStyle = TextStyle(
      fontSize: 14 * scale,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.5,
    );

    final bodyStyle = TextStyle(
      fontSize: 13 * scale,
      color: AppColors.textSecondary,
      height: 1.5,
    );

    final requiredTitleStyle = TextStyle(
      fontSize: 16 * scale,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.5,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 20 * scale),
      child: ServiceTermsBody(
        headingStyle: headingStyle,
        bodyStyle: bodyStyle,
        sectionGap: SizedBox(height: 14 * scale),
        showRequiredTitle: true,
        requiredTitleStyle: requiredTitleStyle,
      ),
    );
  }

  Widget _buildPrivacyContent(double scale) {
    final headingStyle = TextStyle(
      fontSize: 14 * scale,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.5,
    );

    final bodyStyle = TextStyle(
      fontSize: 13 * scale,
      color: AppColors.textSecondary,
      height: 1.5,
    );

    final requiredTitleStyle = TextStyle(
      fontSize: 16 * scale,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.5,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 20 * scale),
      child: PrivacyPolicyBody(
        headingStyle: headingStyle,
        bodyStyle: bodyStyle,
        sectionGap: SizedBox(height: 14 * scale),
        showRequiredTitle: true,
        requiredTitleStyle: requiredTitleStyle,
      ),
    );
  }
}
