import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/home/providers/home_special_effect_provider.dart';
import 'package:fe_app/features/wishlist/models/decision/decision_create_response.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WishlistConsiderResultScreen extends ConsumerWidget {
  const WishlistConsiderResultScreen({
    super.key,
    required this.itemId,
    required this.response,
  });

  final String itemId;
  final DecisionCreateResponse response;

  ConsiderCaseType get caseType => considerCaseTypeFromDecision(response);

  Widget _caseImage(double scale) {
    switch (caseType) {
      case ConsiderCaseType.caseA:
      case ConsiderCaseType.caseC:
        return Image.asset(
          'assets/images/wishlist_consider_case_A.png',
          width: 140 * scale,
          height: 127 * scale,
          fit: BoxFit.contain,
        );
      case ConsiderCaseType.caseB:
        return Image.asset(
          'assets/images/wishlist_consider_case_B.png',
          width: 140 * scale,
          height: 127 * scale,
          fit: BoxFit.contain,
        );
      case ConsiderCaseType.caseD:
        return Image.asset(
          'assets/images/wishlist_consider_case_D.png',
          width: 140 * scale,
          height: 127 * scale,
          fit: BoxFit.contain,
        );
    }
  }

  String _title() {
    switch (caseType) {
      case ConsiderCaseType.caseA:
        return '잘 생각하고 샀구리!';
      case ConsiderCaseType.caseB:
        return '결국 질러버렸구리...';
      case ConsiderCaseType.caseC:
        return '솜사탕을 지켜냈구리!';
      case ConsiderCaseType.caseD:
        return '솜사탕 수호자구리!';
    }
  }

  String _subtitle() {
    switch (caseType) {
      case ConsiderCaseType.caseA:
        return '고민한 만큼 가치 있을 거구리\n너구리도 인정하는 현명한 소비예요';
      case ConsiderCaseType.caseB:
        return '솜사탕이 비에 녹아버렸구리\n다음 솜사탕은 너굴이와 함께 꼭 지켜봐요';
      case ConsiderCaseType.caseC:
        return '오늘 햇살이 따뜻하구리\n신중한 선택이 쌓이면 더 큰 기쁨이 돼요';
      case ConsiderCaseType.caseD:
        return '너무 기뻐서 날아다니구리\n유혹을 이겨낸 오늘, 스스로를 칭찬해요';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 56 * scale,
        leadingWidth: 72 * scale,
        leading: SizedBox(
          height: 56 * scale,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ref.invalidate(considerViewModelProvider(itemId));
              context.go('/wishlist');
            },
            child: Padding(
              padding: EdgeInsets.only(left: 16 * scale),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 16 * scale,
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 16 * scale,
                          color: AppColors.brown,
                        ),
                      ),
                    ),
                    SizedBox(width: 4 * scale),
                    Text(
                      '위시',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brown,
                        height: 1.0,
                      ),
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        title: Text(
          '너굴과 위시 고민',
          style: TextStyle(
            fontSize: 20 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.brown,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                  child: Column(
                    children: [
                      SizedBox(height: 84 * scale),
                      _caseImage(scale),
                      SizedBox(height: 18 * scale),
                      Text(
                        _title(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Text(
                        _subtitle(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24 * scale, 0, 24 * scale, 24 * scale),
              child: Column(
                children: [
                  Text(
                    response.resultMessage.isNotEmpty
                        ? response.resultMessage
                        : '7일 후 만족도를 물어볼게요',
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  SizedBox(
                    width: double.infinity,
                    height: 52 * scale,
                    child: ElevatedButton(
                      onPressed: () async {
                        final special = ref.read(homeSpecialEffectProvider.notifier);
                        // Home 화면에서 딜레이 없이 재생하기 위해 결과를 바탕으로 비디오를 미리 로드합니다.
                        await special.preloadCase(caseType);
                        special.markCase(caseType);
                        ref.invalidate(considerViewModelProvider(itemId));
                        context.go('/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.skyBlue_100,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30 * scale),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '홈으로 돌아가기',
                        style: TextStyle(
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
