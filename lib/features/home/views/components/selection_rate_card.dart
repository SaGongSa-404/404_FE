import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/home/models/home_summary.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionRateCard extends ConsumerWidget {
  const SelectionRateCard({super.key, this.summary});

  final HomeSummaryResponse? summary;

  static const Color _progressFill = Color(0xFF6D96B2);
  static const Color _progressTrack = Color(0xFFEEEEEE);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);
    final data = summary ?? ref.watch(homeSummaryProvider).valueOrNull;
    if (data == null) return const SizedBox.shrink();

    final rate = (data.rationalChoiceRate ?? 0).clamp(0.0, 100.0);
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
            height: 1.2,
          ),
        ),
        SizedBox(height: 10 * scale),
        Expanded(
          child: Center(
            child: SizedBox(
              width: 112 * scale,
              height: 112 * scale,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: rate / 100,
                    strokeWidth: 18 * scale,
                    strokeCap: StrokeCap.round,
                    backgroundColor: _progressTrack,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      _progressFill,
                    ),
                  ),
                  Center(
                    child: Text(
                      '$rateText%',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: const Color(0xFF333333),
                        fontSize: 26 * scale,
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
  }
}
