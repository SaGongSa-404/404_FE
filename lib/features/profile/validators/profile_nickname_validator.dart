sealed class ProfileNicknameValidationResult {
  const ProfileNicknameValidationResult();
}

class ProfileNicknameValid extends ProfileNicknameValidationResult {
  const ProfileNicknameValid();
}

class ProfileNicknameEmpty extends ProfileNicknameValidationResult {
  const ProfileNicknameEmpty();
}

class ProfileNicknameInvalidChars extends ProfileNicknameValidationResult {
  const ProfileNicknameInvalidChars();
}

class ProfileNicknameInvalidLength extends ProfileNicknameValidationResult {
  const ProfileNicknameInvalidLength();
}

class ProfileNicknameValidator {
  static const minLength = 1;
  static const maxLength = 10;

  // 완성형 한글(가-힣) + 영문 + 숫자만 허용 (단독 자모는 백엔드가 거부하므로 제외).
  static final _allowedPattern = RegExp(r'^[가-힣a-zA-Z0-9]+$');

  const ProfileNicknameValidator._();

  static ProfileNicknameValidationResult validate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return const ProfileNicknameEmpty();
    if (!_allowedPattern.hasMatch(trimmed)) {
      return const ProfileNicknameInvalidChars();
    }
    if (trimmed.length < minLength || trimmed.length > maxLength) {
      return const ProfileNicknameInvalidLength();
    }
    return const ProfileNicknameValid();
  }
}
