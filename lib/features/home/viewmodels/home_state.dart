import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HomeTab { budget, selectionRate }

class HomeState {
  final bool isLoading;
  final HomeTab selectedTab;
  final bool isAlarmOpen;

  const HomeState({
    this.isLoading = false,
    this.selectedTab = HomeTab.budget,
    this.isAlarmOpen = false,
  });

  HomeState copyWith({bool? isLoading, HomeTab? selectedTab, bool? isAlarmOpen}) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      selectedTab: selectedTab ?? this.selectedTab,
      isAlarmOpen: isAlarmOpen ?? this.isAlarmOpen,
    );
  }
}