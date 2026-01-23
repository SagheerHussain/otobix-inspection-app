import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:otobix_inspection_app/Screens/dashboard_screen.dart';
import 'package:otobix_inspection_app/Screens/login_screen.dart';
import 'package:otobix_inspection_app/Services/notification_Service.dart';
import 'package:otobix_inspection_app/Services/socket_service.dart';
import 'package:otobix_inspection_app/constants/app_colors.dart';
import 'package:otobix_inspection_app/constants/app_urls.dart';
import 'package:otobix_inspection_app/helpers/sharedpreference_helper.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ If you are using firebase_messaging anywhere (you are), Firebase must be initialized.
  // Uncomment and ensure firebase_options.dart exists.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // If you DON'T have firebase_options.dart yet, then either:
  // 1) add it via flutterfire configure, OR
  // 2) remove firebase_messaging usage.
  await Firebase.initializeApp();

  Get.config(enableLog: false);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SharedPrefsHelper.init();

  final token = await SharedPrefsHelper.getString(SharedPrefsHelper.tokenKey);
  final userId = await SharedPrefsHelper.getString(SharedPrefsHelper.userIdKey);

  final bool isLoggedIn = (token != null && token.isNotEmpty);
  final Widget start = isLoggedIn ? DashboardScreen() : LoginPage();

  SocketService.instance.initSocket(AppUrls.socketBaseUrl);

  runApp(MyApp(home: start));

  // ✅ IMPORTANT: request permission AFTER first frame (so Android prompt actually shows)
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await NotificationService.instance.init(); // will request permission
    if (isLoggedIn && userId != null && userId.isNotEmpty) {
      await NotificationService.instance.login(userId);
    } else {
      debugPrint("🔔 OneSignal[main] skipped login (not logged in)");
    }
    await NotificationService.instance.debugPrintState(from: "main_postframe");
  });
}

class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          navigatorKey: Get.key,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.white,
            canvasColor: AppColors.white,
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: AppColors.white,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.white,
              brightness: Brightness.light,
            ),
          ),
          home: child,
        );
      },
      child: home,
    );
  }
}
