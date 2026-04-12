// [예시]

import 'package:fe_app/features/home/viewmodels/home_viewmodel.dart';
import 'package:fe_app/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _viewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
    _viewModel.load();
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _viewModel.state;
    if (s.isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: '불러오는 중'),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      // 예시 — body 전체를 목록으로 바꿀 때
      // body: ListView.builder(
      //   itemCount: items.length,
      //   itemBuilder: (context, i) => ListTile(title: Text(items[i].title)),
      // ),
      body: Center(
        child: Text(s.placeholder?.title ?? ''),
      ),
    );
  }
}
