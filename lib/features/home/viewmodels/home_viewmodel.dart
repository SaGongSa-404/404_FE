import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_state.dart'; // 같은 폴더에 있다면 이렇게 임포트

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel() : super(const HomeState());

  void selectTab(HomeTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void toggleAlarm() {
    state = state.copyWith(isAlarmOpen: !state.isAlarmOpen);
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel();
});