// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:otobix/Services/notification_router.dart';
// import 'package:otobix/Utils/app_constants.dart';
// import 'package:otobix/Widgets/toast_widget.dart';

// class NotificationService {
//   NotificationService._();
//   static final NotificationService instance = NotificationService._();

//   bool _inited = false;

//   /// 1) Init OneSignal with your App ID and ask for permission
//   Future<void> init() async {
//     if (_inited) return;

//     OneSignal.initialize(AppConstants.oneSignalAppId); // start SDK
//     await OneSignal.Notifications.requestPermission(true); // show OS prompt

//     // When a notification arrives in foreground: just show it
//     OneSignal.Notifications.addForegroundWillDisplayListener((event) {
//       // Access custom payload
//       final Map<String, dynamic> data = Map<String, dynamic>.from(
//         event.notification.additionalData ?? {},
//       );
//       final String type = '${data['type'] ?? ''}';

//       if (type == 'OUTBID') {
//         // Stop the push notification
//         // event.preventDefault();

//         // Show your own toast
//         final ctx = Get.context;
//         if (ctx != null) {
//           final carName = '${data['carName'] ?? ''}';
//           final newBid = data['newBid']?.toString() ?? '';
//           final body =
//               data['body'] ?? 'You’ve been outbid on $carName at Rs. $newBid.';
//           Future.delayed(Duration(seconds: 2), () {
//             ToastWidget.show(
//               context: ctx,
//               toastDuration: 5,
//               title: 'You’ve been outbid',
//               subtitle: body.toString(),
//               type: ToastType.error,
//             );
//           });
//         }
//         // If you ALSO want the OS banner, remove preventDefault() and keep display()
//         // event.notification.display();
//         return;
//       }

//       // Only call this if you want to stop the default auto-display:
//       event.preventDefault();

//       // v5: display the SAME notification object
//       event.notification.display();
//     });

//     // When the user taps a notification
//     OneSignal.Notifications.addClickListener((event) {
//       // Navigate to specific screen when notification is clicked
//       final Map<String, dynamic> data = Map<String, dynamic>.from(
//         event.notification.additionalData ?? {},
//       );

//       // If your splash does async work, deferring avoids navigator race conditions:
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         NotificationRouter.go(data);
//       });
//     });

//     _inited = true;
//   }

//   /// 2) Link this device to YOUR user id (so server can target them)
//   Future<void> login(String mongoUserId) async {
//     final externalUserId = AppConstants.externalIdForNotifications(
//       mongoUserId,
//     ); // "dev:<id>" or "prod:<id>"
//     await OneSignal.login(externalUserId);
//     await OneSignal.User.addTagWithKey(
//       "env",
//       AppConstants.envName,
//     ); // "dev"|"prod"
//   }

//   /// 3) unlink the device from the current user (call on sign-out)
//   Future<void> logout() async {
//     await OneSignal.logout();
//   }
// }
