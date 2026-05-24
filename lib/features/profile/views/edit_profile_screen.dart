import 'dart:async';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/profile/providers/profile_provider.dart';
import 'package:fe_app/shared/widgets/confirm_bottom_sheet.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
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
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final profile = ref.watch(profileNotifierProvider);

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
            // Nickname box: opens modal on tap
            GestureDetector(
              onTap: () => _showNicknameEditDialog(context, ref, profile.nickname),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 18 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30 * scale),
                  boxShadow: _cardShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      profile.nickname,
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      color: AppColors.textPrimary,
                      size: 22 * scale,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showLogoutDialog(context, ref),
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
                  onTap: () => _showWithdrawDialog(context, ref),
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

  void _showNicknameEditDialog(BuildContext context, WidgetRef ref, String currentNickname) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _NicknameEditModal(
          initialNickname: currentNickname,
          onSave: (newName) {
            ref.read(profileNotifierProvider.notifier).updateNickname(newName);
            Navigator.of(sheetContext).pop();
            if (context.mounted) {
              showCapsuleToast(
                context,
                backgroundColor: const Color(0xFF5F8EAE),
                text: '수정되었습니다',
              );
            }
          },
        );
      },
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmBottomSheet(
      context,
      title: '로그아웃 하시겠습니까?',
      actionLabel: '로그아웃',
    );
    if (confirmed == true && context.mounted) {
      ref.read(authProvider.notifier).logout();
      context.go('/login');
    }
  }

  Future<void> _showWithdrawDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmBottomSheet(
      context,
      title: '계정을 정말 탈퇴하실 건가요?',
      subtitle: '한 번 탈퇴한 계정은 되돌릴 수 없어요',
      actionLabel: '탈퇴하기',
    );
    if (confirmed == true && context.mounted) {
      showCapsuleToast(
        context,
        backgroundColor: const Color(0xFFD46868),
        text: '계정이 삭제되었습니다',
      );

      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        ref.read(authProvider.notifier).logout();
        context.go('/login');
      }
    }
  }
}

class _NicknameEditModal extends StatefulWidget {
  final String initialNickname;
  final Function(String) onSave;

  const _NicknameEditModal({required this.initialNickname, required this.onSave});

  @override
  State<_NicknameEditModal> createState() => _NicknameEditModalState();
}

class _NicknameEditModalState extends State<_NicknameEditModal> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final systemBottomPadding = MediaQuery.paddingOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(
        21 * scale,
        0,
        21 * scale,
        (bottomInset > 0 ? bottomInset : systemBottomPadding) + 24 * scale,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(37 * scale),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 31 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '닉네임 수정',
              style: TextStyle(
                fontSize: 20 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20 * scale),
            TextField(
              controller: _controller,
              autofocus: true,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '입력하기',
                hintStyle: const TextStyle(color: Color(0xFFADADAD)),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 16 * scale),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '입력하기',
                        style: TextStyle(
                          color: const Color(0xFFADADAD),
                          fontSize: 14 * scale,
                        ),
                      ),
                    ],
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                contentPadding: EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 20 * scale),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25 * scale),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25 * scale),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25 * scale),
                  borderSide: BorderSide(color: AppColors.textPrimary, width: 1.5 * scale),
                ),
              ),
            ),
            SizedBox(height: 24 * scale),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 57 * scale,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(57 * scale),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20 * scale,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 6 * scale),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final newName = _controller.text.trim();
                      if (newName.isNotEmpty) {
                        widget.onSave(newName);
                      }
                    },
                    child: Container(
                      height: 57 * scale,
                      decoration: BoxDecoration(
                        color: AppColors.skyBlue_100,
                        borderRadius: BorderRadius.circular(57 * scale),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '수정완료',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20 * scale,
                          color: AppColors.textPrimary,
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
    );
  }
}
