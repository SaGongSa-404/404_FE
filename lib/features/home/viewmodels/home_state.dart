// [예시] 홈 화면용 상태

import 'package:fe_app/features/home/models/home_placeholder.dart';

class HomeState {
  const HomeState({
    this.isLoading = false,
    this.placeholder,
  });

  final bool isLoading;
  final HomePlaceholder? placeholder;

  HomeState copyWith({
    bool? isLoading,
    HomePlaceholder? placeholder,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      placeholder: placeholder ?? this.placeholder,
    );
  }
}
