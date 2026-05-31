class DecisionSelfCheckAnswer {
  const DecisionSelfCheckAnswer({
    required this.questionCode,
    required this.answerBoolean,
  });

  final String questionCode;
  final bool answerBoolean;

  Map<String, dynamic> toJson() => {
        'questionCode': questionCode,
        'answerBoolean': answerBoolean,
      };
}

class DecisionCreateRequest {
  const DecisionCreateRequest({
    required this.itemId,
    required this.result,
    this.finalPrice,
    this.rationaleText,
    required this.selfCheckAnswers,
  });

  final String itemId;
  final String result;
  final num? finalPrice;
  final String? rationaleText;
  final List<DecisionSelfCheckAnswer> selfCheckAnswers;

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'result': result,
        if (finalPrice != null) 'finalPrice': finalPrice,
        if (rationaleText != null && rationaleText!.trim().isNotEmpty)
          'rationaleText': rationaleText,
        'selfCheckAnswers':
            selfCheckAnswers.map((answer) => answer.toJson()).toList(),
      };
}
