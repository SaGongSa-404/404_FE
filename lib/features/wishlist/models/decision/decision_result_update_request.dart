import 'package:fe_app/features/wishlist/models/decision/decision_create_request.dart';

class DecisionResultUpdateRequest {
  const DecisionResultUpdateRequest({
    required this.result,
    this.finalPrice,
    this.changeReason,
    this.selfCheckAnswers,
  });

  final String result;
  final num? finalPrice;
  final String? changeReason;
  final List<DecisionSelfCheckAnswer>? selfCheckAnswers;

  Map<String, dynamic> toJson() => {
        'result': result,
        if (finalPrice != null) 'finalPrice': finalPrice,
        if (changeReason != null && changeReason!.trim().isNotEmpty)
          'changeReason': changeReason,
        if (selfCheckAnswers != null)
          'selfCheckAnswers':
              selfCheckAnswers!.map((answer) => answer.toJson()).toList(),
      };
}
