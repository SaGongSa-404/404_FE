import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/profile/providers/profile_provider.dart';
import 'package:fe_app/shared/widgets/confirm_bottom_sheet.dart';
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

  Future<void> _showNicknameConfirmDialog() async {
    final newName = _nicknameController.text.trim();
    if (newName.isEmpty) return;

    final confirmed = await showConfirmBottomSheet(
      context,
      title: '닉네임을 변경하시겠습니까?',
      subtitle: '($newName)으로 수정됩니다.',
      actionLabel: '수정하기',
      destructive: false,
    );
    if (confirmed == true && mounted) {
      ref.read(profileNotifierProvider.notifier).updateNickname(newName);
      setState(() => _isEditing = false);
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showConfirmBottomSheet(
      context,
      title: '로그아웃 하시겠습니까?',
      actionLabel: '로그아웃',
    );
    if (confirmed == true && mounted) {
      ref.read(authProvider.notifier).logout();
      context.go('/login');
    }
  }

  Future<void> _showWithdrawDialog() async {
    final confirmed = await showConfirmBottomSheet(
      context,
      title: '계정을 정말 탈퇴하실 건가요?',
      subtitle: '한 번 탈퇴한 계정은 되돌릴 수 없어요',
      actionLabel: '탈퇴하기',
    );
    if (confirmed != true || !mounted) return;

    final scale = responsiveScale(context);
    final snackBar = SnackBar(
      content: Text(
        '계정이 삭제되었습니다',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14 * scale),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.red_200,
      margin: EdgeInsets.only(bottom: 50 * scale, left: 40 * scale, right: 40 * scale),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30 * scale)),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    await Future.delayed(const Duration(seconds: 2));
    ref.read(authProvider.notifier).logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18 * scale),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '프로필 편집',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 16 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4 * scale, bottom: 8 * scale),
              child: Text(
                '로그인 계정',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 18 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E2E2),
                borderRadius: BorderRadius.circular(30 * scale),
                boxShadow: _cardShadow,
              ),
              child: Text(
                'sjrnfl97@gmail.com',
                style: TextStyle(
                  color: const Color(0xFF555555),
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 8 * scale),
            Padding(
              padding: EdgeInsets.only(left: 8 * scale),
              child: Text(
                '카카오와 연동됨',
                style: TextStyle(color: const Color(0xFF9E9E9E), fontSize: 13 * scale),
              ),
            ),
            SizedBox(height: 36 * scale),
            Padding(
              padding: EdgeInsets.only(left: 4 * scale, bottom: 8 * scale),
              child: Text(
                '닉네임',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30 * scale),
                boxShadow: _cardShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30 * scale),
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
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 18 * scale),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 8 * scale),
                        child: IconButton(
                          icon: Icon(
                            _isEditing ? Icons.check : Icons.edit_outlined,
                            color: AppColors.textPrimary,
                            size: 22 * scale,
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
                        borderRadius: BorderRadius.circular(30 * scale),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30 * scale),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30 * scale),
                        borderSide: BorderSide(color: AppColors.textPrimary, width: 1.5 * scale),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30 * scale),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8 * scale),
            Padding(
              padding: EdgeInsets.only(left: 8 * scale),
              child: Text(
                '카카오와 연동됨',
                style: TextStyle(color: const Color(0xFF9E9E9E), fontSize: 13 * scale),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _showLogoutDialog,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8 * scale),
                    child: Text(
                      '로그아웃',
                      style: TextStyle(
                        color: const Color(0xFF8E8E8E),
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                  child: Text(
                    '|',
                    style: TextStyle(color: const Color(0xFFD9D9D9), fontSize: 14 * scale),
                  ),
                ),
                GestureDetector(
                  onTap: _showWithdrawDialog,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8 * scale),
                    child: Text(
                      '탈퇴하기',
                      style: TextStyle(
                        color: const Color(0xFF8E8E8E),
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * scale),
          ],
        ),
      ),
    );
  }
}
