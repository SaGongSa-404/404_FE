import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class NicknameScreen extends ConsumerStatefulWidget {
  const NicknameScreen({super.key});

  @override
  ConsumerState<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends ConsumerState<NicknameScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final viewModel = ref.read(onboardingProvider.notifier);

    // 키보드 표시 여부 확인
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        // 💡 멈춤/오버플로우 현상을 원천 차단하는 가장 안전한 스크롤 구조
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false, // 내용물이 적어도 화면 전체 높이를 보장
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 73),

                    // 1. 프로그레스 바
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        value: 0.33,
                        minHeight: 4,
                        backgroundColor: Color(0xFFE0E0E0),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC1DBE8)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 2. 메인 타이틀
                    const Text(
                      '환영합니다!',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                        height: 1.36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '사용하실 닉네임을\n선택해주세요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF7B7B7B),
                        height: 1.36,
                      ),
                    ),

                    // 💡 위쪽 여백: 키보드가 없을 때만 밀어냅니다.
                    if (!isKeyboardVisible) const Spacer(),

                    // 3. 캐릭터 (키보드 없을 때만 노출)
                    if (!isKeyboardVisible)
                      Center(
                        child: SizedBox(
                          width: 140,
                          height: 140,
                          child: SvgPicture.asset(
                            'assets/images/nugul.svg', // 🚨 에러 시 아래 엑스박스 아이콘이 뜬다면 경로/이름을 다시 확인해주세요!
                            fit: BoxFit.contain,
                            placeholderBuilder: (context) => const Icon(
                              Icons.image_not_supported,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),

                    if (!isKeyboardVisible) const SizedBox(height: 24),

                    // 4. 에러/안내 메시지 (입력칸 바로 위)
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            state.nicknameError ?? '2~8자까지 입력할 수 있어요.',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: state.nicknameError != null
                                  ? Colors.red
                                  : const Color(0xFF7B7B7B),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 5. TextField
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Color(0xFF7B7B7B),
                          ),
                          decoration: InputDecoration(
                            hintText: '닉네임',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: state.nicknameError != null ? Colors.red : const Color(0xFFE0E0E0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: state.nicknameError != null ? Colors.red : const Color(0xFFC1DBE8),
                                width: 2,
                              ),
                            ),
                            suffixIcon: state.nicknameError != null
                                ? const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(Icons.error_outline, color: Colors.red, size: 20),
                            )
                                : null,
                          ),
                          onChanged: (value) => viewModel.setNickname(value),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[\s]')),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16), // 키보드 올라왔을 때 하단에 숨 쉴 공간 확보

                    // 💡 아래쪽 여백: 키보드가 없을 때 버튼을 바닥으로 밀어냅니다.
                    if (!isKeyboardVisible) const Spacer(),

                    // 6. 다음 버튼 (키보드가 없을 때만 노출)
                    if (!isKeyboardVisible)
                      Center(
                        child: SizedBox(
                          width: 354,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: state.isNicknameValid
                                ? () => context.push('/onboarding/budget')
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.isNicknameValid
                                  ? const Color(0xFFC1DBE8)
                                  : const Color(0xFFE0E0E0),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(75),
                              ),
                            ),
                            child: const Text(
                              '다음',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),

                    if (!isKeyboardVisible) const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}