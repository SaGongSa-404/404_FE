/// 말풍선 메시지 타입 정의
enum BalloonMessageType {
  onboarding,              // 1. 온보딩 (최초 1회)
  emptyWishlist,           // 2. 위시 없는 빈 상태
  firstWishAdded,          // 3. 위시 처음 추가 (최초 1회)
  undecidedWish,           // 4. 위시 미결정 상태
  awaitingVote,            // 5. 게시글 투표 대기
  normalHome,              // 6. 평상시 기본 홈
  budgetExhausted,         // 7. 예산 소진 (0원)
  budgetNegative,          // 8. 예산 마이너스
  rationalBought,          // 9. 합리적 + 샀어요
  rationalRefrained,       // 10. 합리적 + 참았어요
  irrationalRefrained,     // 11. 비합리적 + 참았어요
  irrationalBought,        // 12. 비합리적 + 샀어요
}

/// 말풍선 메시지 정보
class BalloonMessage {
  final BalloonMessageType type;
  final String text;
  final bool isOneTimeOnly; // 최초 1회만 노출 여부
  final double probability; // 노출될 확률 (0.0 ~ 1.0)

  const BalloonMessage({
    required this.type,
    required this.text,
    this.isOneTimeOnly = false,
    this.probability = 1.0,
  });
}

/// 말풍선 메시지 저장소
class BalloonMessages {
  // 1. 온보딩 (최초 1회)
  static const List<BalloonMessage> onboarding = [
    BalloonMessage(
      type: BalloonMessageType.onboarding,
      text: '반가워요! 같이 현명한 소비해봐요',
      isOneTimeOnly: true,
      probability: 1.0,
    ),
  ];

  // 2. 위시 없는 빈 상태
  static const List<BalloonMessage> emptyWishlist = [
    BalloonMessage(
      type: BalloonMessageType.emptyWishlist,
      text: '뭔가 사고 싶은 게 있다면,\n여기서 같이 고민해봐요',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
  ];

  // 3. 위시 처음 추가 (최초 1회)
  static const List<BalloonMessage> firstWishAdded = [
    BalloonMessage(
      type: BalloonMessageType.firstWishAdded,
      text: '첫 번째 위시템이 생겼어요.\n같이 잘 고민해봐요 :)',
      isOneTimeOnly: true,
      probability: 1.0,
    ),
  ];

  // 4. 위시 미결정 상태
  static const List<BalloonMessage> undecidedWish = [
    BalloonMessage(
      type: BalloonMessageType.undecidedWish,
      text: '고민 중인 것들이 있네요. 같이 결정 내려볼까요?',
      isOneTimeOnly: false,
      probability: 0.7,
    ),
    BalloonMessage(
      type: BalloonMessageType.undecidedWish,
      text: '아직 결정 못 한 위시템이 있어요. 같이 살펴볼까요?',
      isOneTimeOnly: false,
      probability: 0.7,
    ),
    BalloonMessage(
      type: BalloonMessageType.undecidedWish,
      text: '고민되는 위시템을 너굴과 함께 확인해볼까요?',
      isOneTimeOnly: false,
      probability: 0.7,
    ),
  ];

  // 5. 게시글 투표 대기
  static const List<BalloonMessage> awaitingVote = [
    BalloonMessage(
      type: BalloonMessageType.awaitingVote,
      text: '투표 결과가 쌓이고 있어요. 슬쩍 확인해볼까요?',
      isOneTimeOnly: false,
      probability: 0.7,
    ),
    BalloonMessage(
      type: BalloonMessageType.awaitingVote,
      text: '다른 사람들의 반응이 궁금하다면, 피드를 확인해봐요',
      isOneTimeOnly: false,
      probability: 0.7,
    ),
  ];

  // 6. 평상시 기본 홈
  static const List<BalloonMessage> normalHome = [
    BalloonMessage(
      type: BalloonMessageType.normalHome,
      text: '너굴이가 항상 응원하고 있어요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.normalHome,
      text: '잠깐 멈추면 보이는 것들이 있어요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.normalHome,
      text: '오늘의 절제가 내일의 여유예요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.normalHome,
      text: '갖고 싶은 것과 필요한 것, 천천히 구별해봐요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.normalHome,
      text: '사지 않는 것도 선택이에요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.normalHome,
      text: '오늘의 소비 상태는 안정적이에요. 이대로만 가봐요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.normalHome,
      text: '지갑을 지키는 건 생각보다 쉬워요. 같이 해봐요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.normalHome,
      text: '혼자 고민하지 않아도 돼요. 다른 사람들의 생각도 들어봐요',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
  ];

  // 7. 예산 소진 (0원)
  static const List<BalloonMessage> budgetExhausted = [
    BalloonMessage(
      type: BalloonMessageType.budgetExhausted,
      text: '이번 달 예산을 다 썼어요. 다음 달을 기다려 봐요',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.budgetExhausted,
      text: '예산이 딱 0원 남았어요. 지갑이 쉬어야 할 타이밍이에요',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.budgetExhausted,
      text: '예산이 다 찼어요. 다음 달을 위해 잠깐 멈춰볼까요?',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
  ];

  // 8. 예산 마이너스
  static const List<BalloonMessage> budgetNegative = [
    BalloonMessage(
      type: BalloonMessageType.budgetNegative,
      text: '마이너스 상태예요. 지금은 지갑을 닫을 타이밍이에요',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.budgetNegative,
      text: '마이너스가 됐어요. 다음 달을 위해 지금은 멈춰볼까요?',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.budgetNegative,
      text: '예산을 넘어섰어요. 잠깐 쉬어가는 게 어떨까요?',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.budgetNegative,
      text: '조금 예산을 넘어섰지만 괜찮아요. 지금부터 잘 관리하면 돼요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
  ];

  // 9. 합리적 + 샀어요
  static const List<BalloonMessage> rationalBought = [
    BalloonMessage(
      type: BalloonMessageType.rationalBought,
      text: '필요한 걸 제대로 샀네요. 좋은 선택이었어요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.rationalBought,
      text: '달콤하고 현명한 소비였어요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.rationalBought,
      text: '솜사탕 냠냠! 고민한 만큼 좋은 선택이었어요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.rationalBought,
      text: '지갑도, 마음도 모두 만족스러운 소비였어요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.rationalBought,
      text: '충분히 고민하고 샀으니 후회 없을 거예요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
  ];

  // 10. 합리적 + 참았어요
  static const List<BalloonMessage> rationalRefrained = [
    BalloonMessage(
      type: BalloonMessageType.rationalRefrained,
      text: '참을수록 솜사탕이 더 달콤해져요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.rationalRefrained,
      text: '안 사는 것도 때로는 훌륭한 결정이에요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.rationalRefrained,
      text: '참는 것도 연습이에요. 잘하고 있어요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
  ];

  // 11. 비합리적 + 참았어요
  static const List<BalloonMessage> irrationalRefrained = [
    BalloonMessage(
      type: BalloonMessageType.irrationalRefrained,
      text: '쉽지 않았을 텐데 잘 참아냈어요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.irrationalRefrained,
      text: '갖고 싶었을 텐데 잘 이겨냈어요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.irrationalRefrained,
      text: '지름신을 이겨냈어요. 대단해요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.irrationalRefrained,
      text: '한 번 참으면 다음엔 더 쉬워요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
  ];

  // 12. 비합리적 + 샀어요
  static const List<BalloonMessage> irrationalBought = [
    BalloonMessage(
      type: BalloonMessageType.irrationalBought,
      text: '솜사탕이 다 녹아버렸어요. 다음엔 함께 지켜봐요',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.irrationalBought,
      text: '너무 자책하지 말아요. 다음이 있어요',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.irrationalBought,
      text: '오늘은 비가 왔지만 다음엔 맑은 날을 만들어봐요',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
    BalloonMessage(
      type: BalloonMessageType.irrationalBought,
      text: '가끔은 이런 날도 있어요. 다음엔 너굴이가 더 잘 도울게요 :)',
      isOneTimeOnly: false,
      probability: 1.0,
    ),
  ];

  /// 타입에 해당하는 메시지 목록 반환
  static List<BalloonMessage> getMessagesByType(BalloonMessageType type) {
    switch (type) {
      case BalloonMessageType.onboarding:
        return onboarding;
      case BalloonMessageType.emptyWishlist:
        return emptyWishlist;
      case BalloonMessageType.firstWishAdded:
        return firstWishAdded;
      case BalloonMessageType.undecidedWish:
        return undecidedWish;
      case BalloonMessageType.awaitingVote:
        return awaitingVote;
      case BalloonMessageType.normalHome:
        return normalHome;
      case BalloonMessageType.budgetExhausted:
        return budgetExhausted;
      case BalloonMessageType.budgetNegative:
        return budgetNegative;
      case BalloonMessageType.rationalBought:
        return rationalBought;
      case BalloonMessageType.rationalRefrained:
        return rationalRefrained;
      case BalloonMessageType.irrationalRefrained:
        return irrationalRefrained;
      case BalloonMessageType.irrationalBought:
        return irrationalBought;
    }
  }
}

