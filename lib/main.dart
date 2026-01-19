import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:otobix_inspection_app/Screens/dashboard_screen.dart';
import 'package:otobix_inspection_app/Screens/login_screen.dart';
import 'package:otobix_inspection_app/Services/socket_service.dart';
import 'package:otobix_inspection_app/constants/app_colors.dart';
import 'package:otobix_inspection_app/constants/app_urls.dart';
import 'package:otobix_inspection_app/helpers/sharedpreference_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Widget start = await init();
  runApp(MyApp(home: start));
}

class MyApp extends StatelessWidget {
  final Widget home;

  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // ✅ apne UI design ke base par set karo
      // Agar apka Figma/Design 390x844 hai to ye perfect hai
      designSize: const Size(390, 844),

      minTextAdapt: true,

      // ✅ split screen support (tabs etc.)
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

      // ✅ yahan apka start widget pass hoga (login/dashboard)
      child: home,
    );
  }
}

Future<Widget> init() async {
  Get.config(enableLog: false);

  await SharedPrefsHelper.init();

  final userId = await SharedPrefsHelper.getString(SharedPrefsHelper.userIdKey);

  if (userId != null && userId.isNotEmpty) {
    // await NotificationService.instance.login(userId);
  }

  // Initialize socket globally
  SocketService.instance.initSocket(AppUrls.socketBaseUrl);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final token = await SharedPrefsHelper.getString(SharedPrefsHelper.tokenKey);

  Widget start = LoginPage();

  if (token != null && token.isNotEmpty) {
    start = DashboardScreen();
  }

  return start;
}
