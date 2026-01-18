import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:otobix_inspection_app/constants/app_colors.dart';

enum ToastType { success, error, warning, info }

class ToastWidget {
  // prevent duplicates currently visible
  static final Set<String> _visibleKeys = <String>{};

  // optional: throttle bursts of identical toasts
  static String? _lastKey;
  static DateTime? _lastShownAt;

  static void show({
    required BuildContext context,
    required String title,
    required ToastType type,
    String? subtitle,
    int toastDuration = 3,
    Duration throttle = const Duration(milliseconds: 800), // optional
  }) {
    final key = _makeKey(type, title, subtitle);

    // If same toast is currently visible → skip
    if (_visibleKeys.contains(key)) return;

    // Optional burst throttle (skip if shown very recently)
    final now = DateTime.now();
    if (_lastKey == key && _lastShownAt != null) {
      if (now.difference(_lastShownAt!) < throttle) return;
    }

    final colorIcon = _colorIconFor(type);
    final color = colorIcon.$1;
    final icon = colorIcon.$2;

    _visibleKeys.add(key);
    _lastKey = key;
    _lastShownAt = now;

    DelightToastBar(
      position: DelightSnackbarPosition.top,
      snackbarDuration: Duration(seconds: toastDuration),
      autoDismiss: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ToastCard(
          color: color,
          leading: Icon(icon, size: 28, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    ).show(context);

    Future.delayed(
      Duration(seconds: toastDuration) + const Duration(milliseconds: 250),
      () => _visibleKeys.remove(key),
    );
  }

  static (Color, IconData) _colorIconFor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return (AppColors.green, Icons.check_circle);
      case ToastType.error:
        return (AppColors.red, Icons.error);
      case ToastType.warning:
        return (AppColors.yellow, Icons.warning);
      case ToastType.info:
        return (AppColors.blue, Icons.info);
    }
  }

  static String _makeKey(ToastType type, String title, String? subtitle) =>
      '${type.name}|$title|${subtitle ?? ""}';
}

// import 'package:delightful_toast/delight_toast.dart';
// import 'package:delightful_toast/toast/components/toast_card.dart';
// import 'package:delightful_toast/toast/utils/enums.dart';
// import 'package:flutter/material.dart';

// enum ToastType { success, error, warning, info }

// class ToastWidget {
//   static void show({
//     required BuildContext context,
//     required String title,
//     required ToastType type,
//     String? subtitle,
//     int toastDuration = 3,
//   }) {
//     Color color;
//     IconData icon;

//     switch (type) {
//       case ToastType.success:
//         color = Colors.green;
//         icon = Icons.check_circle;
//         break;
//       case ToastType.error:
//         color = Colors.red;
//         icon = Icons.error;
//         break;
//       case ToastType.warning:
//         color = Colors.orange;
//         icon = Icons.warning;
//         break;
//       case ToastType.info:
//         color = Colors.blue;
//         icon = Icons.info;
//         break;
//     }

//     DelightToastBar(
//       position: DelightSnackbarPosition.top,
//       snackbarDuration: Duration(seconds: toastDuration),
//       autoDismiss: true,
//       builder:
//           (context) => Padding(
//             padding: const EdgeInsets.only(right: 10),
//             child: ToastCard(
//               color: color,
//               leading: Icon(icon, size: 28, color: Colors.white),
//               title: Text(
//                 title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
//                   color: Colors.white,
//                 ),
//               ),
//               subtitle:
//                   subtitle != null
//                       ? Text(
//                         subtitle,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 12,
//                           color: Colors.white,
//                         ),
//                       )
//                       : null,
//             ),
//           ),
//     ).show(context);
//   }
// }
