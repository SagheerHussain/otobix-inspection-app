import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:otobix_inspection_app/helpers/sharedpreference_helper.dart';
import 'package:otobix_inspection_app/models/profile_model.dart';

class ProfileController extends GetxController {
  final String profileUrl =
      "https://otobix-app-backend-development.onrender.com/api/user/user-profile";

  final isLoading = false.obs;
  final error = ''.obs;
  final profile = Rxn<ProfileModel>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  // ✅ Simple: token get + clean in one place
  Future<String> _getToken() async {
    final raw = await SharedPrefsHelper.getString(SharedPrefsHelper.tokenKey);
    if (raw == null) return "";

    var t = raw.trim();

    // remove quotes
    if (t.startsWith('"') && t.endsWith('"') && t.length >= 2) {
      t = t.substring(1, t.length - 1);
    }

    // remove Bearer if already saved
    if (t.toLowerCase().startsWith("bearer ")) {
      t = t.substring(7).trim();
    }

    return t;
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      error.value = '';

      final token = await _getToken();

      if (token.isEmpty) {
        error.value = "Token missing. Please login again.";
        Get.snackbar("Auth Error", error.value);
        return;
      }

      final res = await http.get(
        Uri.parse(profileUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token", // ✅ token used here
        },
      );

      print("PROFILE STATUS => ${res.statusCode}");
      print("PROFILE BODY => ${res.body}");

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final parsed = ProfileResponseModel.fromJson(data);

        if (parsed.success == true) {
          profile.value = parsed.profile;
        } else {
          error.value = parsed.message.isNotEmpty
              ? parsed.message
              : "Profile fetch failed.";
          Get.snackbar("Error", error.value);
        }
      } else if (res.statusCode == 401) {
        error.value = "401 Unauthorized: token invalid/expired.";
        Get.snackbar("Auth Error", error.value);
      } else {
        error.value = "Server error: ${res.statusCode}";
        Get.snackbar("Error", error.value);
      }
    } catch (e) {
      error.value = "Something went wrong: $e";
      Get.snackbar("Error", error.value);
    } finally {
      isLoading.value = false;
    }
  }

  // helpers
  String get displayName =>
      profile.value?.name.isNotEmpty == true ? profile.value!.name : "—";
  String get displayEmail =>
      profile.value?.email.isNotEmpty == true ? profile.value!.email : "—";
  String get displayPhone => profile.value?.phoneNumber.isNotEmpty == true
      ? profile.value!.phoneNumber
      : "—";
  String get displayRole =>
      profile.value?.role.isNotEmpty == true ? profile.value!.role : "—";
  String get displayLocation => profile.value?.location.isNotEmpty == true
      ? profile.value!.location
      : "—";

  String get primaryAddress {
    final list = profile.value?.addressList ?? [];
    return list.isNotEmpty ? list.first : "—";
  }

  bool get hasImage => (profile.value?.image ?? "").trim().isNotEmpty;
  String get imageUrl => (profile.value?.image ?? "").trim();

  String get initials {
    final n = (profile.value?.name ?? "").trim();
    if (n.isEmpty) return "?";
    final parts = n.split(RegExp(r"\s+")).where((p) => p.isNotEmpty).toList();
    final first = parts.isNotEmpty ? parts.first[0] : "?";
    final second = parts.length > 1 ? parts[1][0] : "";
    return (first + second).toUpperCase();
  }
}
