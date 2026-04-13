import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/survey_question.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class SurveyScreen extends ConsumerStatefulWidget {
  const SurveyScreen({super.key});

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _onAnswer(String answer) {
    ref.read(onboardingProvider.notifier).addSurveyAnswer(answer);

    if (_currentIndex < surveyQuestions.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      setState(() => _currentIndex++);
    } else {
      // 모든 설문 완료 시 홈 또는 결과로 이동
      // context.go('/home');

      //테스트용
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('설문이 완료되었습니다!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / surveyQuestions.length,
            backgroundColor: Colors.grey[200],
            color: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: surveyQuestions.length,
              itemBuilder: (context, index) {
                final q = surveyQuestions[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(q.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 32),
                      ...q.options.map((opt) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OutlinedButton(
                          onPressed: () => _onAnswer(opt),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(opt, style: const TextStyle(color: Colors.black87)),
                        ),
                      )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}