import 'package:dio/dio.dart';
import 'package:fe_app/app.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/auth/providers/deep_link_provider.dart';
import 'package:fe_app/features/auth/views/login_screen.dart';
import 'package:fe_app/features/notification/providers/push_token_provider.dart';
import 'package:fe_app/features/notification/services/notification_settings_service.dart';
import 'package:fe_app/features/wishlist/providers/android_share_intent_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _LoggedOutAuth extends AuthNotifier {
  @override
  Future<UserModel?> build() async => null;
}

class _NoDeepLinks extends DeepLinkHandler {
  @override
  void build() {}
}

class _NoShareIntents extends AndroidShareIntentNotifier {
  @override
  void start() {}
}

class _LocalNotificationSettings extends NotificationSettingsService {
  _LocalNotificationSettings() : super(Dio());
  @override
  Future<bool> fetchEnabled({CancelToken? cancelToken}) async => false;
}

void main() {
  testWidgets('logged-out startup reaches login after splash', (tester) async {
    dotenv.testLoad(
        fileInput: 'API_BASE_URL=http://127.0.0.1:8080\nAUTH_MODE=oauth');
    await tester.pumpWidget(ProviderScope(overrides: [
      authProvider.overrideWith(_LoggedOutAuth.new),
      deepLinkHandlerProvider.overrideWith(_NoDeepLinks.new),
      androidShareIntentProvider.overrideWith((ref) => _NoShareIntents()),
      pushTokenLifecycleProvider.overrideWith((ref) {}),
      notificationSettingsServiceProvider
          .overrideWithValue(_LocalNotificationSettings()),
    ], child: const App()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
