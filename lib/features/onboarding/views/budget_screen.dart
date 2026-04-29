import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<int> presets = [100000, 300000, 500000];
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FDF9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                '이번 달 나를 위한 소비,',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Text(
                '얼마까지 괜찮아요?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '매달 예산을 설정하고',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF758780),
                ),
              ),
              const Text(
                '합리적인 소비를 관리해보세요',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF758780),
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '예) 500000',
                    hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                    filled: true,
                    fillColor: const Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF758780)),
                          onChanged: (value) {
                            if (value != null) {
                              _controller.text = value.toString();
                            }
                          },
                          items: presets.map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('${value ~/ 10000}만원'),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _hasText
                      ? () => context.push('/onboarding/survey')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasText
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFA8DAB5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
