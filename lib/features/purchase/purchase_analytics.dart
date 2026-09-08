import 'package:fe_app/core/firebase/firebase_bootstrap.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Reuses the app's existing Firebase setup. Never sends product URLs or notes.
abstract final class PurchaseAnalytics {
  static Future<void> record(String name,
      {Map<String, Object>? parameters}) async {
    if (!FirebaseBootstrap.isInitialized) return;
    try {
      await FirebaseAnalytics.instance
          .logEvent(name: name, parameters: parameters);
    } catch (_) {
      // Analytics availability must not block saving a purchase.
    }
  }
}
