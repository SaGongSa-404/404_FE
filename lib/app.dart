import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/router/app_router.dart';
import 'package:fe_app/features/auth/providers/deep_link_provider.dart';

final class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 딥링크 핸들러를 앱 생명주기 동안 유지 (keepAlive: true)
    ref.watch(deepLinkHandlerProvider);

    final appRouter = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'WiGul',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Pretendard',
      ),
      routerConfig: appRouter,
    );
  }
}
