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

class NicknameInvalidWhitespace extends NicknameValidationResult {
  const NicknameInvalidWhitespace();
}

class NicknameValidator {
  static const minLength = 2;
  static const maxLength = 8;

  static final _allowedPattern =
      RegExp(r'^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]+$');
  static final _whitespacePattern = RegExp(r'\s');

  const NicknameValidator._();

  static NicknameValidationResult validate(String input) {
    if (input.isEmpty) return const NicknameEmpty();
    if (_whitespacePattern.hasMatch(input)) {
      return const NicknameInvalidWhitespace();
    }
    if (!_allowedPattern.hasMatch(input)) return const NicknameInvalidChars();
    if (input.length < minLength || input.length > maxLength) {
      return const NicknameInvalidLength();
    }
    return const NicknameValid();
  }
}
