import 'dart:async';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/profile/providers/my_profile_provider.dart';
import 'package:fe_app/features/profile/utils/provider_label.dart';
import 'package:fe_app/features/onboarding/validators/nickname_validator.dart';
import 'package:fe_app/shared/widgets/confirm_bottom_sheet.dart';
import 'package:fe_app/shared/widgets/press_pill_button.dart';
import 'package:fe_app/shared/widgets/profile_modal_text_field.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myProfileProvider.notifier).load(force: true);
    });
  }

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
    final auth = ref.watch(authProvider);
    final myProfile = ref.watch(myProfileProvider);
    final user = auth.valueOrNull;
    final loginAccount = user?.email?.trim().isNotEmpty == true
        ? user!.email!
        : (user?.principalName ?? '-');
    final provider = myProfile.profile?.provider ?? user?.provider ?? '';
    final linkedText =
        provider.isNotEmpty ? providerLinkedText(provider) : '';

    ref.listen(authProvider, (prev, next) {
      if (next.hasValue &&
          next.value != null &&
          prev?.valueOrNull == null) {
        ref.read(myProfileProvider.notifier).load(force: true);
      }
    });

    ref.listen<MyProfileState>(myProfileProvider, (prev, next) {
      if (prev?.errorMessage != next.errorMessage && next.errorMessage != null) {
        showCapsuleToast(
          context,
          backgroundColor: AppColors.red_600.withValues(alpha: 0.8),
          text: next.errorMessage!,
        );
      }
    });

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
      body: SafeArea(
        top: false,
        child: Padding(
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
                loginAccount,
                style: TextStyle(
                  color: const Color(0xFF555555),
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 8 * scale),
            if (linkedText.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 8 * scale),
                child: Text(
                  linkedText,
                  style: TextStyle(
                    color: const Color(0xFF9E9E9E),
                    fontSize: 13 * scale,
                  ),
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
              onTap: myProfile.isUpdating
                  ? null
                  : () => _showNicknameEditDialog(
                        context,
                        ref,
                        myProfile.nickname,
                      ),
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
                      myProfile.isLoading && myProfile.nickname.isEmpty
                          ? '...'
                          : myProfile.nickname,
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
      ),
    );
  }

  void _showNicknameEditDialog(
    BuildContext context,
    WidgetRef ref,
    String currentNickname,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _NicknameEditModal(
          initialNickname: currentNickname,
          onSave: (newName) async {
            final ok =
                await ref.read(myProfileProvider.notifier).updateNickname(newName);
            if (!sheetContext.mounted) return;
            if (ok) {
              Navigator.of(sheetContext).pop();
              if (context.mounted) {
                showCapsuleToast(
                  context,
                  backgroundColor: const Color(0xFF5F8EAE),
                  text: '수정되었습니다',
                );
              }
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
      await ref.read(authProvider.notifier).logout();
      if (!context.mounted) return;
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
    if (confirmed != true || !context.mounted) return;

    final profileNotifier = ref.read(myProfileProvider.notifier);
    try {
      await profileNotifier.deleteAccountAndSignOut();
    } catch (e) {
      if (!context.mounted) return;
      showCapsuleToast(
        context,
        backgroundColor: AppColors.red_600.withValues(alpha: 0.8),
        text: profileNotifier.withdrawErrorMessage(e),
      );
      return;
    }

    if (!context.mounted) return;
    showCapsuleToast(
      context,
      backgroundColor: const Color(0xFFD46868),
      text: '계정이 삭제되었습니다',
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!context.mounted) return;
    context.go('/login');
  }
}

class _NicknameEditModal extends StatefulWidget {
  final String initialNickname;
  final Future<void> Function(String newName) onSave;

  const _NicknameEditModal({
    required this.initialNickname,
    required this.onSave,
  });

  @override
  State<_NicknameEditModal> createState() => _NicknameEditModalState();
}

class _NicknameEditModalState extends State<_NicknameEditModal> {
  late final TextEditingController _controller;
  NicknameValidationResult _validation = const NicknameEmpty();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNickname);
    _validation = NicknameValidator.validate(widget.initialNickname);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _validation = NicknameValidator.validate(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  String? get _errorMessage => switch (_validation) {
        NicknameEmpty() => '닉네임을 입력해주세요',
        NicknameInvalidWhitespace() => '공백을 제거해주세요',
        NicknameInvalidChars() => '한글, 영어, 숫자만 입력할 수 있어요',
        NicknameInvalidLength() => '2자 이상 8자 이내로 입력해주세요',
        _ => null,
      };

  bool get _canSave =>
      _validation is NicknameValid &&
      !_isSaving &&
      _controller.text.trim() != widget.initialNickname.trim();

  Future<void> _handleSave() async {
    final newName = _controller.text.trim();
    if (!_canSave) return;
    setState(() => _isSaving = true);
    await widget.onSave(newName);
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final systemBottomPadding = MediaQuery.paddingOf(context).bottom;
    final hasError = _errorMessage != null;

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
            if (hasError)
              Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: AppColors.red_400,
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ProfileModalTextField(
              controller: _controller,
              scale: scale,
              hasError: hasError,
              autofocus: true,
              maxLength: NicknameValidator.maxLength,
            ),
            SizedBox(height: 24 * scale),
            Row(
              children: [
                Expanded(
                  child: PressPillButton(
                    height: 57 * scale,
                    borderRadius: 57 * scale,
                    defaultColor: PressPillButton.greyDefault,
                    pressedColor: PressPillButton.greyPressed,
                    onTap: () => Navigator.of(context).pop(),
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
                SizedBox(width: 6 * scale),
                Expanded(
                  child: PressPillButton(
                    height: 57 * scale,
                    borderRadius: 57 * scale,
                    defaultColor: _canSave
                        ? PressPillButton.blueDefault
                        : PressPillButton.blueDefault.withValues(alpha: 0.5),
                    pressedColor: PressPillButton.bluePressed,
                    onTap: _canSave ? _handleSave : null,
                    child: _isSaving
                        ? SizedBox(
                            width: 22 * scale,
                            height: 22 * scale,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            '수정완료',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20 * scale,
                              color: AppColors.textPrimary,
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
