import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/shared/content/terms_content.dart';
import 'package:fe_app/shared/widgets/terms_document_view.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _designWidth = 412.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / _designWidth;
            final hPad = (constraints.maxWidth * (24 / _designWidth))
                .clamp(20.0, 48.0);
            final headerHPad = (constraints.maxWidth * (28 / _designWidth))
                .clamp(22.0, 56.0);
            final arrowSize = (18.658 * scale).clamp(15.0, 24.0);

            return Column(
              children: [
                _Header(
                  title: TermsContent.privacyPolicyScreenTitle,
                  arrowSize: arrowSize,
                  hPad: headerHPad,
                  bottomPad: (18 * scale).clamp(14.0, 22.0),
                  fontSize: (20 * scale).clamp(15.0, 26.0),
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      (17 * scale).clamp(12.0, 22.0),
                      hPad,
                      (80 * scale).clamp(48.0, 80.0),
                    ),
                    child: TermsDocumentView(
                      sections: TermsContent.privacyPolicy,
                      scale: scale,
                      documentTitle: TermsContent.privacyPolicyDocumentTitle,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
      padding: EdgeInsets.fromLTRB(hPad, bottomPad, hPad, bottomPad),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                'assets/images/arrow_forward.svg',
                width: arrowSize,
                height: arrowSize,
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