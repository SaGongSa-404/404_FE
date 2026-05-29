import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);
    final summaryAsync = ref.watch(homeSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        if (summary == null) {
          return _ErrorPlaceholder(
            scale: scale,
            message: '예산 정보를 불러오지 못했어요.',
          );
        }

        final budget = summary.budget;
        final numberFormat = RegExp(r'\B(?=(\d{3})+(?!\d))');
        String format(int val) =>
            val.toString().replaceAllMapped(numberFormat, (m) => ',');

        final isExceeded = budget.isBudgetExhausted;

        // 게이지 바 비율 계산 (0.0 ~ 1.0)
        final progress = budget.monthlyBudgetAmount <= 0
            ? 0.0
            : (budget.spentAmount / budget.monthlyBudgetAmount).clamp(0.0, 1.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀 + 화살표
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '이번 달 예산 현황',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/my/consumption'),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: 14 * scale,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8 * scale),

            // 남은 금액
            Text(
              '${format(budget.remainingAmount)}원 남음',
              style: TextStyle(
                color: isExceeded ? AppColors.red_200 : AppColors.textPrimary,
                fontSize: 24 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20 * scale),

            // 이미지 맞춤형 구현: 예산 진척도 바 (Progress Bar)
            Container(
              height: 12 * scale, // 이미지 속 얇고 정교한 바 높이 반영
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBEB), // 뒷배경 연한 회색 바 색상
                borderRadius: BorderRadius.circular(6 * scale), // 완벽한 라운딩 처리
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // ClipRRect를 사용하여 채워지는 바도 모서리가 잘 깎이도록 처리
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6 * scale),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress, // 백엔드에서 받아온 소비 비율 대입
                            child: Container(
                              decoration: BoxDecoration(
                                color: isExceeded
                                    ? AppColors.red_200
                                    : const Color(0xFF7B97B1), // 이미지의 차분한 블루그레이 톤 반영
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 12 * scale),

            // 금액 표시 (양쪽 정렬)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${format(budget.spentAmount)}원',
                  style: TextStyle(
                    color: const Color(0xFF7A7A7A), // 이미지와 유사한 회색조 폰트 컬러
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${format(budget.monthlyBudgetAmount)}원',
                  style: TextStyle(
                    color: const Color(0xFF7A7A7A),
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => _LoadingPlaceholder(scale: scale),
      error: (error, stackTrace) => _ErrorPlaceholder(
        scale: scale,
        message: '예산 정보를 불러오지 못했어요.',
        onRetry: () => ref.refresh(homeSummaryProvider),
      ),
    );
  }
}

// 공용 컴포넌트: 로딩 상태
class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 24 * scale,
        height: 24 * scale,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// 공용 컴포넌트: 에러 상태
class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({
    required this.scale,
    required this.message,
    this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12 * scale,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 12 * scale),
            TextButton(
              onPressed: onRetry,
              child: Text(
                '다시 시도',
                style: TextStyle(fontSize: 12 * scale),
              ),
            ),
          ],
        ],
      ),
    );
  }
}