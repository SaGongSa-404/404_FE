import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConsumptionStatus {
  bought,    // 샀어요
  refrained, // 참았어요
}

class ConsumptionItem {
  final String id;
  final String name;
  final int price;
  final String imageUrl;
  final ConsumptionStatus status;
  final String? review;

  ConsumptionItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.status,
    this.review,
  });

  ConsumptionItem copyWith({ConsumptionStatus? status}) {
    return ConsumptionItem(
      id: id,
      name: name,
      price: price,
      imageUrl: imageUrl,
      status: status ?? this.status,
      review: review,
    );
  }
}

class MonthlyRecord {
  final String month; // e.g. "2026.03"
  final int budget;
  final List<ConsumptionItem> items;
  final int rationalRate;
  final int irrationalCount;

  MonthlyRecord({
    required this.month,
    required this.budget,
    required this.items,
    required this.rationalRate,
    required this.irrationalCount,
  });

  int get spentAmount {
    return items.where((item) => item.status == ConsumptionStatus.bought)
                .fold(0, (sum, item) => sum + item.price);
  }

  bool get isExceeded => spentAmount > budget;
}

class ProfileState {
  final String nickname;
  final int monthlyBudget;
  final List<MonthlyRecord> monthlyRecords;

  ProfileState({
    required this.nickname,
    required this.monthlyBudget,
    required this.monthlyRecords,
  });

  MonthlyRecord get currentMonthRecord => monthlyRecords.first;

  ProfileState copyWith({
    String? nickname,
    int? monthlyBudget,
    List<MonthlyRecord>? monthlyRecords,
  }) {
    return ProfileState(
      nickname: nickname ?? this.nickname,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      monthlyRecords: monthlyRecords ?? this.monthlyRecords,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return ProfileState(
      nickname: '너구리구리',
      monthlyBudget: 500000,
      monthlyRecords: [
        MonthlyRecord(
          month: '2026.03',
          budget: 500000,
          rationalRate: 85,
          irrationalCount: 3,
          items: [
            ConsumptionItem(id: '1', name: 'PWC RIBBED EVERYDAY SHORT', price: 29000, imageUrl: '', status: ConsumptionStatus.bought, review: '잘했어요'),
            ConsumptionItem(id: '2', name: '브리즈 커브드 밴딩 팬츠_ash', price: 153000, imageUrl: '', status: ConsumptionStatus.bought, review: '그냥 그래요'),
            ConsumptionItem(id: '3', name: '킨 샨티 슬라이드 Black', price: 94000, imageUrl: '', status: ConsumptionStatus.refrained),
            ConsumptionItem(id: '4', name: '클리오 에센셜 블러쉬 탭', price: 18000, imageUrl: '', status: ConsumptionStatus.bought, review: '후회해요'),
          ],
        ),
        MonthlyRecord(
          month: '2026.02',
          budget: 500000,
          rationalRate: 72,
          irrationalCount: 5,
          items: [],
        ),
      ],
    );
  }

  void updateNickname(String newNickname) {
    state = state.copyWith(nickname: newNickname);
  }

  void updateBudget(int newBudget) {
    final updatedRecords = [...state.monthlyRecords];
    if (updatedRecords.isNotEmpty) {
      final current = updatedRecords[0];
      updatedRecords[0] = MonthlyRecord(
        month: current.month,
        budget: newBudget,
        rationalRate: current.rationalRate,
        irrationalCount: current.irrationalCount,
        items: current.items,
      );
    }
    state = state.copyWith(
      monthlyBudget: newBudget,
      monthlyRecords: updatedRecords,
    );
  }

  void updateItemStatus(String month, String itemId, ConsumptionStatus status) {
    final updatedRecords = state.monthlyRecords.map((record) {
      if (record.month == month) {
        final updatedItems = record.items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(status: status);
          }
          return item;
        }).toList();
        return MonthlyRecord(
          month: record.month,
          budget: record.budget,
          rationalRate: record.rationalRate,
          irrationalCount: record.irrationalCount,
          items: updatedItems,
        );
      }
      return record;
    }).toList();
    state = state.copyWith(monthlyRecords: updatedRecords);
  }
}

// 수동 Provider 정의 (에러 해결 핵심)
final profileNotifierProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});
