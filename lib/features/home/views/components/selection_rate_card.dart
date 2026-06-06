import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionRateCard extends ConsumerWidget {
  const SelectionRateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);

    return ref.watch(homeSummaryProvider).when(
      data: (summary) {
        final rate = (summary?.rationalChoiceRate ?? 0).clamp(0.0, 100.0);
        final rateText = rate.toStringAsFixed(rate % 1 == 0 ? 0 : 1);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '합리적 선택률',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: const Color(0xFF555555),
                fontSize: 16 * scale,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 96 * scale,
                  height: 96 * scale,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: rate / 100,
                        strokeWidth: 18 * scale,
                        strokeCap: StrokeCap.round,
                        backgroundColor: const Color(0xFFEEEEEE),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6D96B2),
                        ),
                      ),
                      Center(
                        child: Text(
                          '$rateText%',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            color: const Color(0xFF333333),
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => _placeholder(scale, '선택률 정보를 불러오는 중이에요.'),
      error: (_, __) => _placeholder(scale, '선택률 정보를 불러오지 못했어요.'),
    );
  }

  Widget _placeholder(double scale, String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontFamily: 'Pretendard',
          color: const Color(0xFF555555),
          fontSize: 12 * scale,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}