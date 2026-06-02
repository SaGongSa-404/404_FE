import 'package:fe_app/features/home/domain/home_bubble_type.dart';

/// 타입별 말풍선 문구 상수.
abstract final class HomeBubbleMessages {
  static const List<String> onboarding = [
    '반가워요! 같이 현명한 소비해봐요',
  ];

  static const List<String> emptyWish = [
    '뭔가 사고 싶은 게 있다면, 여기서 같이 고민해봐요',
  ];

  static const List<String> firstWish = [
    '첫 번째 위시템이 생겼어요. 같이 잘 고민해봐요 :)',
  ];

  static const List<String> undecidedWish = [
    '고민 중인 것들이 있네요. 같이 결정 내려볼까요?',
    '아직 결정 못 한 위시템이 있어요. 같이 살펴볼까요?',
    '고민되는 위시템을 너굴과 함께 확인해볼까요?',
  ];

  static const List<String> socialReaction = [
    '투표 결과가 쌓이고 있어요. 슬쩍 확인해볼까요?',
    '다른 사람들의 반응이 궁금하다면, 피드를 확인해봐요',
  ];

  static const List<String> defaultHome = [
    '너굴이가 항상 응원하고 있어요 :)',
    '잠깐 멈추면 보이는 것들이 있어요 :)',
    '오늘의 절제가 내일의 여유예요 :)',
    '갖고 싶은 것과 필요한 것, 천천히 구별해봐요 :)',
    '사지 않는 것도 선택이에요 :)',
    '오늘의 소비 상태는 안정적이에요. 이대로만 가봐요 :)',
    '지갑을 지키는 건 생각보다 쉬워요. 같이 해봐요 :)',
    '혼자 고민하지 않아도 돼요. 다른 사람들의 생각도 들어봐요',
  ];

  static const List<String> budgetZero = [
    '이번 달 예산을 다 썼어요. 다음 달을 기다려 봐요',
    '예산이 딱 0원 남았어요. 지갑이 쉬어야 할 타이밍이에요',
    '예산이 다 찼어요. 다음 달을 위해 잠깐 멈춰볼까요?',
  ];

  static const List<String> budgetNegative = [
    '마이너스 상태예요. 지금은 지갑을 닫을 타이밍이에요',
    '마이너스가 됐어요. 다음 달을 위해 지금은 멈춰볼까요?',
    '예산을 넘어섰어요. 잠깐 쉬어가는 게 어떨까요?',
    '조금 예산을 넘어섰지만 괜찮아요. 지금부터 잘 관리하면 돼요 :)',
  ];

  static const List<String> rationalGo = [
    '필요한 걸 제대로 샀네요. 좋은 선택이었어요 :)',
    '달콤하고 현명한 소비였어요 :)',
    '솜사탕 냠냠! 고민한 만큼 좋은 선택이었어요 :)',
    '지갑도, 마음도 모두 만족스러운 소비였어요 :)',
    '충분히 고민하고 샀으니 후회 없을 거예요 :)',
  ];

  static const List<String> rationalStop = [
    '참을수록 솜사탕이 더 달콤해져요 :)',
    '안 사는 것도 때로는 훌륭한 결정이에요 :)',
    '참는 것도 연습이에요. 잘하고 있어요 :)',
  ];

  static const List<String> irrationalStop = [
    '쉽지 않았을 텐데 잘 참아냈어요 :)',
    '갖고 싶었을 텐데 잘 이겨냈어요 :)',
    '지름신을 이겨냈어요. 대단해요 :)',
    '한 번 참으면 다음엔 더 쉬워요 :)',
  ];

  static const List<String> irrationalGo = [
    '솜사탕이 다 녹아버렸어요. 다음엔 함께 지켜봐요',
    '너무 자책하지 말아요. 다음이 있어요',
    '오늘은 비가 왔지만 다음엔 맑은 날을 만들어봐요',
    '가끔은 이런 날도 있어요. 다음엔 너굴이가 더 잘 도울게요 :)',
  ];

  static List<String> messagesFor(HomeBubbleType type) {
    switch (type) {
      case HomeBubbleType.onboarding:
        return onboarding;
      case HomeBubbleType.emptyWish:
        return emptyWish;
      case HomeBubbleType.firstWish:
        return firstWish;
      case HomeBubbleType.undecidedWish:
        return undecidedWish;
      case HomeBubbleType.socialReaction:
        return socialReaction;
      case HomeBubbleType.defaultHome:
        return defaultHome;
      case HomeBubbleType.budgetZero:
        return budgetZero;
      case HomeBubbleType.budgetNegative:
        return budgetNegative;
      case HomeBubbleType.rationalGo:
        return rationalGo;
      case HomeBubbleType.rationalStop:
        return rationalStop;
      case HomeBubbleType.irrationalStop:
        return irrationalStop;
      case HomeBubbleType.irrationalGo:
        return irrationalGo;
    }
  }
}
