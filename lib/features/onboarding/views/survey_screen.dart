import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class SurveyScreen extends ConsumerStatefulWidget {
  const SurveyScreen({super.key});

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  int? _selectedIndex;

  final List<Map<String, String>> _surveyOptions = [
    {'text': '거의 없었어요', 'subtext': '(월 1회 미만)'},
    {'text': '가끔 있었어요', 'subtext': '(월 1~3회)'},
    {'text': '자주 있었어요', 'subtext': '(월 4회 이상)'},
  ];

  void _onSelectOption(int index) {
    setState(() {
      _selectedIndex = index;
    });
    ref.read(onboardingProvider.notifier).selectSurveyOption(
      index,
      _surveyOptions[index]['text']!,
    );
  }

  void _onStart() {
    if (_selectedIndex != null) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 73),
              // 프로그레스 바
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: 1.0,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC1DBE8)),
                ),
              ),
              const SizedBox(height: 32),
              // 메인 타이틀
              const Text(
                '최근 한 달 동안,\n물건을 사고 나서 후회한 적이\n얼마나 있었어요?',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                  height: 1.36,
                ),
              ),
              const SizedBox(height: 48),
              // 선택지 버튼들
              ...List.generate(_surveyOptions.length, (index) {
                final option = _surveyOptions[index];
                final isSelected = _selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton(
                      onPressed: () => _onSelectOption(index),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFFE8F3F9)
                            : Colors.white,
                        foregroundColor: const Color(0xFFC1DBE8),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFFC1DBE8)
                              : Colors.white,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            option['text']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option['subtext']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              // 에러 메시지
              if (_selectedIndex == null)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '항목을 선택해주세요',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
                ),
              // 시작하기 버튼
              Center(
                child: SizedBox(
                  width: 354,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _selectedIndex != null ? _onStart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedIndex != null
                          ? const Color(0xFFC1DBE8)
                          : const Color(0xFFE0E0E0),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(75),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 114,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      '시작하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF555555),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 135),
            ],
          ),
        ),
      ),
    );
  }
}