/// 신고 사유 카테고리. [serverValue]는 BE `ReportCategory` enum과 일치해야 합니다.
enum ReportCategory {
  profanity('PROFANITY', '욕설/비방 및 혐오 표현'),
  obscene('OBSCENE', '음란물 및 선정적인 콘텐츠'),
  illegal('ILLEGAL_INFORMATION', '불법 정보 공유'),
  spam('SPAM', '스팸 및 상업적 광고'),
  privacy('PRIVACY', '개인정보 노출 및 사생활 침해'),
  other('OTHER', '기타');

  const ReportCategory(this.serverValue, this.label);

  /// BE로 전송되는 enum 이름.
  final String serverValue;

  /// 모달에 노출되는 한글 라벨.
  final String label;

  /// 직접 입력(기타) 여부.
  bool get isOther => this == ReportCategory.other;
}
