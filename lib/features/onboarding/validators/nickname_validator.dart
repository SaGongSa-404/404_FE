sealed class NicknameValidationResult {
  const NicknameValidationResult();
}

class NicknameValid extends NicknameValidationResult {
  const NicknameValid();
}

class NicknameEmpty extends NicknameValidationResult {
  const NicknameEmpty();
}

class NicknameInvalidChars extends NicknameValidationResult {
  const NicknameInvalidChars();
}

class NicknameInvalidLength extends NicknameValidationResult {
  const NicknameInvalidLength();
}

class NicknameValidator {
  static const minLength = 2;
  static const maxLength = 8;

  static final _allowedPattern =
      RegExp(r'^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]+$');

  const NicknameValidator._();

  static NicknameValidationResult validate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return const NicknameEmpty();
    if (!_allowedPattern.hasMatch(trimmed)) return const NicknameInvalidChars();
    if (trimmed.length < minLength || trimmed.length > maxLength) {
      return const NicknameInvalidLength();
    }
    return const NicknameValid();
  }
}
