class DecisionMascotResponse {
  const DecisionMascotResponse({
    required this.state,
    required this.message,
  });

  final String state;
  final String message;

  factory DecisionMascotResponse.fromJson(Map<String, dynamic> json) {
    return DecisionMascotResponse(
      state: json['state'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}

class DecisionReminderResponse {
  const DecisionReminderResponse({
    required this.id,
    required this.type,
    required this.status,
    this.scheduledFor,
  });

  final String id;
  final String type;
  final String status;
  final DateTime? scheduledFor;

  factory DecisionReminderResponse.fromJson(Map<String, dynamic> json) {
    final scheduledForRaw = json['scheduledFor'];
    return DecisionReminderResponse(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      scheduledFor: scheduledForRaw is String
          ? DateTime.tryParse(scheduledForRaw)
          : null,
    );
  }
}

class DecisionCreateResponse {
  const DecisionCreateResponse({
    required this.decisionId,
    required this.itemId,
    required this.itemTitle,
    required this.itemStatus,
    required this.result,
    this.finalPrice,
    required this.budgetYearMonth,
    required this.budgetAfterAmount,
    required this.budgetExhaustedAfter,
    required this.budgetBecameExhausted,
    required this.similarCategorySpendAmount,
    required this.selfCheckYesCount,
    required this.rationalityResult,
    required this.resultMessage,
    this.mascot,
    this.reminder,
    this.decidedAt,
    required this.budgetExhausted,
  });

  final String decisionId;
  final String itemId;
  final String itemTitle;
  final String itemStatus;
  final String result;
  final num? finalPrice;
  final String budgetYearMonth;
  final int budgetAfterAmount;
  final bool budgetExhaustedAfter;
  final bool budgetBecameExhausted;
  final int similarCategorySpendAmount;
  final int selfCheckYesCount;
  final String rationalityResult;
  final String resultMessage;
  final DecisionMascotResponse? mascot;
  final DecisionReminderResponse? reminder;
  final DateTime? decidedAt;
  final bool budgetExhausted;

  factory DecisionCreateResponse.fromJson(Map<String, dynamic> json) {
    int readInt(Object? value) {
      if (value is num) return value.round();
      return 0;
    }

    final decidedAtRaw = json['decidedAt'];
    return DecisionCreateResponse(
      decisionId: json['decisionId'] as String? ?? '',
      itemId: json['itemId'] as String? ?? '',
      itemTitle: json['itemTitle'] as String? ?? '',
      itemStatus: json['itemStatus'] as String? ?? '',
      result: json['result'] as String? ?? '',
      finalPrice: json['finalPrice'] as num?,
      budgetYearMonth: json['budgetYearMonth'] as String? ?? '',
      budgetAfterAmount: readInt(json['budgetAfterAmount']),
      budgetExhaustedAfter: json['budgetExhaustedAfter'] as bool? ?? false,
      budgetBecameExhausted: json['budgetBecameExhausted'] as bool? ?? false,
      similarCategorySpendAmount: readInt(json['similarCategorySpendAmount']),
      selfCheckYesCount: readInt(json['selfCheckYesCount']),
      rationalityResult: json['rationalityResult'] as String? ?? '',
      resultMessage: json['resultMessage'] as String? ?? '',
      mascot: json['mascot'] is Map<String, dynamic>
          ? DecisionMascotResponse.fromJson(
              json['mascot'] as Map<String, dynamic>,
            )
          : null,
      reminder: json['reminder'] is Map<String, dynamic>
          ? DecisionReminderResponse.fromJson(
              json['reminder'] as Map<String, dynamic>,
            )
          : null,
      decidedAt: decidedAtRaw is String ? DateTime.tryParse(decidedAtRaw) : null,
      budgetExhausted: json['budgetExhausted'] as bool? ?? false,
    );
  }
}
