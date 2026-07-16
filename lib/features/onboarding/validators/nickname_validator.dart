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

  // 완성형 한글(가-힣) + 영문 + 숫자만 허용.
  // 단독 자모(ㄱ-ㅎ, ㅏ-ㅣ)는 백엔드가 거부하므로 여기서도 막아 입력 단계에서 즉시 걸러낸다.
  static final _allowedPattern = RegExp(r'^[가-힣a-zA-Z0-9]+$');
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
