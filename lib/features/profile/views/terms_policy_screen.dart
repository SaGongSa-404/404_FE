import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/shared/content/terms_content.dart';
import 'package:fe_app/shared/widgets/terms_document_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsPolicyScreen extends StatelessWidget {
  const TermsPolicyScreen({super.key});

  static const Color _backgroundColor = Color(0xFFF5F5F5);

  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset.zero,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final cardHeight = (MediaQuery.sizeOf(context).height * 0.34).clamp(240.0, 275.0);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.brown,
            size: 18 * scale,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '이용약관 및 개인정보 처리방침',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.brown,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24 * scale,
            12 * scale,
            24 * scale,
            32 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24 * scale),
              _TermsPolicySection(
                scale: scale,
                cardHeight: cardHeight,
                title: TermsContent.serviceTermsScreenTitle,
                child: TermsDocumentView(
                  sections: TermsContent.serviceTerms,
                  scale: scale,
                  compact: true,
                  bottomSpacing: 8 * scale,
                ),
              ),
              SizedBox(height: 25 * scale),
              _TermsPolicySection(
                scale: scale,
                cardHeight: cardHeight,
                title: TermsContent.privacyPolicyScreenTitle,
                child: TermsDocumentView(
                  sections: TermsContent.privacyPolicy,
                  scale: scale,
                  compact: true,
                  bottomSpacing: 8 * scale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsPolicySection extends StatefulWidget {
  const _TermsPolicySection({
    required this.scale,
    required this.cardHeight,
    required this.title,
    required this.child,
  });

  final double scale;
  final double cardHeight;
  final String title;
  final Widget child;

  @override
  State<_TermsPolicySection> createState() => _TermsPolicySectionState();
}

class _TermsPolicySectionState extends State<_TermsPolicySection> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10 * scale),
        Container(
          height: widget.cardHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22 * scale),
            boxShadow: TermsPolicyScreen._cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22 * scale),
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thickness: WidgetStateProperty.all((6 * scale).clamp(5.0, 8.0)),
                radius: Radius.circular(4 * scale),
                crossAxisMargin: (8 * scale).clamp(6.0, 12.0),
                mainAxisMargin: (12 * scale).clamp(8.0, 16.0),
                thumbVisibility: WidgetStateProperty.all(true),
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24 * scale,
                    vertical: 18 * scale,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}