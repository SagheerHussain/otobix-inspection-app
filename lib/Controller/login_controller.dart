import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:otobix_inspection_app/Screens/dashboard_screen.dart';
import 'package:otobix_inspection_app/Services/api_services.dart';
import 'package:otobix_inspection_app/Services/notification_Service.dart';
import 'package:otobix_inspection_app/constants/app_contstants.dart';
import 'package:otobix_inspection_app/constants/app_urls.dart';
import 'package:otobix_inspection_app/helpers/sharedpreference_helper.dart';
import 'package:otobix_inspection_app/widgets/toast_widget.dart';

class LoginController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    clearFields();
  }

  RxBool isLoading = false.obs;
  RxBool obsecureText = true.obs;

  final userNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();

  // ✅ IMPORTANT: dispose controllers when LoginController removed from memory
  @override
  void onClose() {
    userNameController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        if (Get.context != null && Get.context!.mounted) {
          ToastWidget.show(
            context: Get.context!,
            type: ToastType.error,
            title: "No internet connection",
            subtitle: "Please check your internet connection and try again",
          );
        }
        return false;
      }
      return true;
    } catch (e) {
      debugPrint("❌ Internet check error: $e");
      return false;
    }
  }

  // ✅ DEBUG: FCM token check (same as OneSignal issue diagnose)
  Future<void> _debugFcmToken({String from = ""}) async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      debugPrint("📩 FCM[$from] permission = ${settings.authorizationStatus}");

      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint("📩 FCM[$from] token = $fcmToken");
    } catch (e) {
      debugPrint("❌ FCM[$from] getToken error: $e");
    }
  }

  Future<void> loginUser() async {
    isLoading.value = true;

    try {
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) return;

      final String dealerName = userNameController.text.trim();
      final String contactNumber = phoneNumberController.text.trim();

      final requestBody = {
        "userName": dealerName,
        "phoneNumber": contactNumber,
        "password": passwordController.text.trim(),
      };

      final response = await ApiService.post(
        endpoint: AppUrls.login,
        body: requestBody,
      );

      print('Response: $response');
      print('Response body: ${response.body}');
      print('Response status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        final user = data['user'];

        final userType = user['userType'];
        final userId = user['id'];
        final approvalStatus = user['approvalStatus'];
        final entityType = (user['entityType'] ?? "").toString();
        final phonenumber = (user['phoneNumber']).toString();

        print(phonenumber);

        // ✅ username from API
        final apiUserName = (user['userName'] ?? "").toString();

        print(token);
        print(user);
        print(userType);
        print(userId);
        print(approvalStatus);
        print(entityType);
        print("userid $userId");
        print("API userName: $apiUserName");

        // ✅ DEBUG: check FCM token BEFORE OneSignal login
        await _debugFcmToken(from: "before_onesignal_login");

        // ✅ OneSignal login (external_id attach)
        await NotificationService.instance.login(userId);

        // ✅ DEBUG: check FCM token AFTER OneSignal login
        await _debugFcmToken(from: "after_onesignal_login");

        print("Notification service initialized");

        if (approvalStatus == AppConstants.roles.userStatusApproved) {
          await SharedPrefsHelper.saveString(SharedPrefsHelper.tokenKey, token);
        }

        await SharedPrefsHelper.saveString(
          SharedPrefsHelper.userKey,
          jsonEncode(user),
        );

        await SharedPrefsHelper.saveString(
          SharedPrefsHelper.phoneNumberKey,
          phonenumber,
        );

        await SharedPrefsHelper.saveString(
          SharedPrefsHelper.userIdKey,
          userId,
        );

        await SharedPrefsHelper.saveString(
          SharedPrefsHelper.userTypeKey,
          userType,
        );

        await SharedPrefsHelper.saveString(
          SharedPrefsHelper.entityTypeKey,
          entityType,
        );

        await SharedPrefsHelper.saveString(
          SharedPrefsHelper.userNameKey,
          apiUserName,
        );

        print("Saved username: $apiUserName");

        Get.offAll(() => DashboardScreen());

        if (approvalStatus == AppConstants.roles.userStatusPending) {
          final String? trimmedEntityType =
              (user['entityType'] as String?)?.trim();

          ToastWidget.show(
            context: Get.context!,
            title: "User Status  $approvalStatus",
            type: ToastType.error,
          );

          final entityDocuments = await _fetchEntityDocuments(trimmedEntityType);
          debugPrint("Pending documents: $entityDocuments");
        } else if (approvalStatus == AppConstants.roles.userStatusApproved) {
          // approved
        } else {
          ToastWidget.show(
            context: Get.context!,
            title: "Invalid approval status. Please contact admin.",
            type: ToastType.error,
          );
        }
      } else {
        ToastWidget.show(
          context: Get.context!,
          title: data['message'] ?? "Invalid credentials",
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint("Login Error: $e");
      ToastWidget.show(
        context: Get.context!,
        title: "Something went wrong. Please try again.",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return "Password is required.";
    if (password.length < 8) {
      return "Password must be at least 8 characters long.";
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "At least one uppercase letter required.";
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return "At least one lowercase letter required.";
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(password)) {
      return "At least one special character required.";
    }
    return null;
  }

  Future<List<String>> _fetchEntityDocuments(String? entityType) async {
    final fallback = <String>['No documents found'];

    if (entityType == null || entityType.isEmpty) return fallback;

    try {
      final response = await ApiService.get(
        endpoint: AppUrls.getEntityDocumentsByName(entityName: entityType),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = (json['data'] ?? {}) as Map<String, dynamic>;
        final docs = (data['documents'] ?? []) as List;
        return docs.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint("Fetch docs error: $e");
    }

    return fallback;
  }

  void clearFields() {
    userNameController.clear();
    phoneNumberController.clear();
    passwordController.clear();
    obsecureText.value = true;
  }
}
