import 'package:fe_app/features/home/viewmodels/home_state.dart';
import 'package:fe_app/features/home/viewmodels/home_viewmodel.dart';
import 'package:fe_app/features/home/views/components/budget_card.dart';
import 'package:fe_app/features/home/views/components/selection_rate_card.dart';
import 'package:fe_app/features/home/views/components/tab_button.dart';
import 'package:fe_app/shared/widgets/alarm/alarm_button.dart';
import 'package:fe_app/shared/widgets/alarm/alarm_panel.dart';
import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';
import 'package:fe_app/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(homeViewModelProvider);
    final vm = ref.read(homeViewModelProvider.notifier);

    if (s.isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: '불러오는 중'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. 메인 배경 레이아웃 (캐릭터 및 하단 카드)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Spacer(),
                  // 캐릭터 표시 영역
                  Center(
                    child: Container(
                      width: 250,
                      height: 350,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Center(
                        child: Text('너구리', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // 하단 정보 카드 및 탭 전환 버튼
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      s.selectedTab == HomeTab.budget
                          ? const BudgetCard()
                          : const SelectionRateCard(),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Row(
                          children: [
                            TabButton(
                              color: s.selectedTab == HomeTab.selectionRate ? Colors.red : Colors.orange,
                              onTap: () => vm.selectTab(HomeTab.selectionRate),
                            ),
                            const SizedBox(width: 8),
                            TabButton(
                              color: s.selectedTab == HomeTab.budget ? Colors.red : Colors.orange,
                              onTap: () => vm.selectTab(HomeTab.budget),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // 2. 상단 알림 아이콘 버튼
            Positioned(
              top: 8,
              right: 8,
              child: AlarmButton(
                onPressed: () => vm.toggleAlarm(),
              ),
            ),
            // 3. 알림창 오버레이 패널
            if (s.isAlarmOpen)
              AlarmPanel(
                onClose: () => vm.toggleAlarm(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}