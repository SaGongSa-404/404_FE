abstract final class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해 주세요.';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해 주세요.';
    }
    if (value.length < minLength) {
      return '비밀번호는 $minLength자 이상이어야 합니다.';
    }
    return null;
  }

  static String? required(String? value, {String fieldName = '값'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName을(를) 입력해 주세요.';
    }
    return null;
  }

  // 예시 — 전화번호
  // static String? phoneKr(String? value) {
  //   if (value == null || value.isEmpty) return '전화번호를 입력해 주세요.';
  //   final digits = value.replaceAll(RegExp(r'\D'), '');
  //   if (digits.length < 10) return '올바른 번호가 아닙니다.';
  //   return null;
  // }
}
