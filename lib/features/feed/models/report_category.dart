/// 신고 사유 카테고리. [serverValue]는 BE `ReportCategory` enum과 일치해야 합니다.
enum ReportCategory {
  profanity('PROFANITY', '욕설/비방 및 혐오 표현'),
  defamation('DEFAMATION', '명예훼손 및 허위 사실 유포'),
  obscene('OBSCENE', '음란물 및 선정적인 콘텐츠'),
  spam('SPAM', '스팸 및 도배'),
  advertising('ADVERTISING', '상업적 광고 및 홍보'),
  privacy('PRIVACY', '개인정보 노출 및 사생활 침해'),
  illegalInformation('ILLEGAL_INFORMATION', '불법 정보 공유'),
  other('OTHER', '기타');

  const ReportCategory(this.serverValue, this.label);

  /// BE로 전송되는 enum 이름.
  final String serverValue;

  /// 모달에 노출되는 한글 라벨.
  final String label;

  /// 직접 입력(기타) 여부. OTHER 선택 시 reason 필수.
  bool get isOther => this == ReportCategory.other;

  static ReportCategory? fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in ReportCategory.values) {
      if (item.serverValue == normalized) return item;
    }
    return null;
  }
}
