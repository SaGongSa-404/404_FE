import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nicknameController;
  final FocusNode _nicknameFocusNode = FocusNode();
  bool _isEditing = false;

  static const Color _backgroundColor = Color(0xFFF5F5F5);
  static const Color _cardShadowColor = Color(0x22000000);
  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: _cardShadowColor,
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset.zero,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileNotifierProvider);
    _nicknameController = TextEditingController(text: profile.nickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _nicknameFocusNode.dispose();
    super.dispose();
  }

  void _showNicknameConfirmDialog() {
    final newName = _nicknameController.text.trim();
    if (newName.isEmpty) return;

    _showCustomActionDialog(
      title: '닉네임을 변경하시겠습니까?',
      subtitle: '($newName)으로 수정됩니다.',
      confirmText: '수정하기',
      onConfirm: () {
        ref.read(profileNotifierProvider.notifier).updateNickname(newName);
        setState(() => _isEditing = false);
        context.pop();
      },
    );
  }

  void _showCustomActionDialog({
    required String title,
    String? subtitle,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E8E),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => context.pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2F2F2),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red_400,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    _showCustomActionDialog(
      title: '로그아웃 하시겠습니까?',
      confirmText: '로그아웃',
      onConfirm: () {
        ref.read(authProvider.notifier).logout();
        context.go('/login');
      },
    );
  }

  void _showWithdrawDialog() {
    _showCustomActionDialog(
      title: '계정을 정말 탈퇴하실 건가요?',
      subtitle: '한 번 탈퇴한 계정은 되돌릴 수 없어요',
      confirmText: '탈퇴하기',
      onConfirm: () async {
        context.pop();

        final snackBar = SnackBar(
          content: const Text('계정이 삭제되었습니다', textAlign: TextAlign.center),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.red_200,
          margin: const EdgeInsets.only(bottom: 50, left: 40, right: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        await Future.delayed(const Duration(seconds: 2));
        ref.read(authProvider.notifier).logout();
        if (mounted) context.go('/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '프로필 편집',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                '로그인 계정',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E2E2),
                borderRadius: BorderRadius.circular(30),
                boxShadow: _cardShadow,
              ),
              child: const Text(
                'sjrnfl97@gmail.com',
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                '카카오와 연동됨',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
              ),
            ),
            const SizedBox(height: 36),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                '닉네임',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: _cardShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    if (!_isEditing) {
                      setState(() => _isEditing = true);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _nicknameFocusNode.requestFocus();
                      });
                    }
                  },
                  child: TextField(
                    controller: _nicknameController,
                    focusNode: _nicknameFocusNode,
                    readOnly: !_isEditing,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _showNicknameConfirmDialog(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: Icon(
                            _isEditing ? Icons.check : Icons.edit_outlined,
                            color: AppColors.textPrimary,
                            size: 22,
                          ),
                          onPressed: () {
                            if (_isEditing) {
                              _showNicknameConfirmDialog();
                            } else {
                              setState(() => _isEditing = true);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _nicknameFocusNode.requestFocus();
                              });
                            }
                          },
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: AppColors.textPrimary, width: 1.5),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                '카카오와 연동됨',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _showLogoutDialog,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '로그아웃',
                      style: TextStyle(
                        color: Color(0xFF8E8E8E),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text('|', style: TextStyle(color: Color(0xFFD9D9D9), fontSize: 14)),
                ),
                GestureDetector(
                  onTap: _showWithdrawDialog,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '탈퇴하기',
                      style: TextStyle(
                        color: Color(0xFF8E8E8E),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}