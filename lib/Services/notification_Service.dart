import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:otobix_inspection_app/constants/app_contstants.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _inited = false;

  // ✅ Store last external id locally for debug
  String? _lastExternalId;

  Future<void> init() async {
    if (_inited) return;

    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize(AppConstants.oneSignalAppId);

    final granted = await OneSignal.Notifications.requestPermission(true);
    debugPrint("🔔 OneSignal permission granted = $granted");

    OneSignal.User.pushSubscription.optIn();

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.preventDefault();
      event.notification.display();
    });

    OneSignal.Notifications.addClickListener((event) {
      final data = Map<String, dynamic>.from(
        event.notification.additionalData ?? {},
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('🔔 Notification Tapped: ${data.toString()}');
      });
    });

    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint("🔔 PushSubscription changed:");
      debugPrint("   optIn=${state.current.optedIn}");
      debugPrint("   id=${state.current.id}");
      debugPrint("   token=${state.current.token}");
    });

    _inited = true;
  }

  Future<void> login(String mongoUserId) async {
    if (mongoUserId.trim().isEmpty) {
      debugPrint("🔔 OneSignal.login skipped (empty userId)");
      return;
    }

    final externalUserId = AppConstants.externalIdForNotifications(mongoUserId);
    _lastExternalId = externalUserId; // ✅ save for debug

    await OneSignal.login(externalUserId);
    await OneSignal.User.addTagWithKey("env", AppConstants.envName);

    debugPrint("🔔 OneSignal logged in as externalId=$externalUserId");
  }

  Future<void> logout() async {
    _lastExternalId = null;
    await OneSignal.logout();
  }

  Future<void> debugPrintState({String from = ""}) async {
    try {
      final permission = OneSignal.Notifications.permission;
      final sub = OneSignal.User.pushSubscription;

      debugPrint("🔎 OneSignalState[$from]");
      debugPrint("   permission=$permission");
      debugPrint("   optedIn=${sub.optedIn}");
      debugPrint("   subId=${sub.id}");
      debugPrint("   token=${sub.token}");
      debugPrint("   externalId=$_lastExternalId"); // ✅ fixed
    } catch (e) {
      debugPrint("❌ OneSignal debugPrintState error: $e");
    }
  }
}
