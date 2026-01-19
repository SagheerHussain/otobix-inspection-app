// car_inspection_stepper_controller.dart - APPOINTMENT SPECIFIC STORAGE
// ✅ Fixed: Each appointment has its own isolated storage
// ✅ Fixed: Dropdown values specific to each appointment
// ✅ Fixed: Images and videos specific to each appointment
// ✅ Fixed: All form fields specific to each appointment

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:otobix_inspection_app/Screens/dashboard_screen.dart';
import 'package:otobix_inspection_app/helpers/sharedpreference_helper.dart';
import 'package:otobix_inspection_app/widgets/toast_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../models/leads_model.dart';

class CarInspectionStepperController extends GetxController {
  final RxInt currentStep = 0.obs;
  final RxInt uiTick = 0.obs;
  void touch() => uiTick.value++;

  final RxBool rcFetchLoading = false.obs;
  final RxBool submitLoading = false.obs;

  final List<Map<String, dynamic>> steps = const [
    {"title": "Docs", "icon": Icons.description_outlined},
    {"title": "Basic", "icon": Icons.info_outline},
    {"title": "Front", "icon": Icons.directions_car},
    {"title": "Rear/Sides", "icon": Icons.car_repair},
    {"title": "Engine", "icon": Icons.build_circle_outlined},
    {"title": "Interior", "icon": Icons.airline_seat_recline_normal},
    {"title": "TestDrive", "icon": Icons.drive_eta},
  ];

  late final List<GlobalKey<FormState>> formKeys;

  final RxMap<String, dynamic> data = <String, dynamic>{}.obs;
  final RxSet<String> lockedKeys = <String>{}.obs;

  bool isLocked(String key) => lockedKeys.contains(key);

  void lockKey(String key, {bool lock = true}) {
    if (lock) {
      lockedKeys.add(key);
    } else {
      lockedKeys.remove(key);
    }
    touch();
  }

  static Future<bool> hasInternet(BuildContext context) async {
    final result = await Connectivity().checkConnectivity();

    late final List<ConnectivityResult> list;
    list = result;

    final online = list.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn ||
          r == ConnectivityResult.bluetooth ||
          r == ConnectivityResult.other,
    );

    if (!online) {
      ToastWidget.show(
        context: context,
        type: ToastType.error,
        title: "No internet connection",
      );
      return false;
    }

    return true;
  }

  void setAndLockString(String key, String value, {bool silent = false}) {
    setString(key, value, silent: true, force: true);
    lockKey(key);
    _pushToController(key);

    if (!silent) touch();
  }

  void setAndLockInt(String key, int value, {bool silent = false}) {
    setInt(key, value, silent: true, force: true);
    lockKey(key);
    if (!silent) touch();
  }

  void setAndLockDate(String key, DateTime? value, {bool silent = false}) {
    setDate(key, value, silent: true, force: true);
    lockKey(key);

    if (_tcs.containsKey(key)) {
      _pushToController(key);
    }

    if (!silent) touch();
  }

  // =====================================================
  // API ENDPOINTS
  // =====================================================
  static const String deleteCloudinaryMediaUrl =
      "https://otobix-app-backend-development.onrender.com/api/inspection/car/delete-media-from-cloudinary";
  static const String uploadCarImagesUrl =
      "https://otobix-app-backend-development.onrender.com/api/inspection/car/upload-car-images-to-cloudinary";

  static const String uploadCarVideoUrl =
      "https://otobix-app-backend-development.onrender.com/api/inspection/car/upload-car-video-to-cloudinary";

  static const String submitCarInspectionUrl =
      "https://otobix-app-backend-development.onrender.com/api/inspection/car/add-car-through-inspection";

  static const String getDropdownsUrl =
      "https://otobix-app-backend-development.onrender.com/api/inspection/dropdowns/get-all-dropdowns-list";

  final RxMap<String, List<String>> localPickedImages =
      <String, List<String>>{}.obs;

  final RxSet<String> uploadingFields = <String>{}.obs;

  final String _storagePrefix = "car_inspection_data__";
  bool _isRestoring = false;
  bool _isAutoSaving = false;

  // =====================================================
  // ✅ APPOINTMENT-SPECIFIC STORAGE
  // =====================================================
  final RxMap<String, List<String>> _localImagesCache =
      <String, List<String>>{}.obs;
  final RxMap<String, String?> _localVideosCache = <String, String?>{}.obs;

  // ✅ Current appointment ID
  String _currentAppointmentId = "";

  String get currentAppointmentId => _currentAppointmentId;

  // =====================================================
  // ✅ DROPDOWN DATA MANAGEMENT
  // =====================================================
  final RxMap<String, List<String>> dropdownData = <String, List<String>>{}.obs;
  final RxBool isLoadingDropdowns = false.obs;

  Future<void> _loadAllDropdowns() async {
    try {
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) return;
      isLoadingDropdowns.value = true;

      final token = await _getBearerToken();
      if (token.isEmpty) {
        debugPrint("❌ Token missing for dropdown API");
        return;
      }

      final response = await http.get(
        Uri.parse(getDropdownsUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic> && decoded["success"] == true) {
          final data = decoded["data"] as List<dynamic>;

          for (final item in data) {
            if (item is Map<String, dynamic>) {
              final dropdownName = item["dropdownName"]?.toString() ?? "";
              final dropdownValues = item["dropdownValues"] as List<dynamic>?;

              if (dropdownName.isNotEmpty) {
                final values =
                    dropdownValues?.map((e) => e.toString()).toList() ?? [];

                final key = _normalizeDropdownKey(dropdownName);
                dropdownData[key] = values;
              }
            }
          }
        }
      } else {
        debugPrint("❌ Failed to load dropdowns: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error loading dropdowns: $e");
    } finally {
      isLoadingDropdowns.value = false;
    }
  }

  String _normalizeDropdownKey(String keyName) {
    for (final apiKey in dropdownData.keys) {
      if (apiKey.toLowerCase() == keyName.toLowerCase()) {
        return apiKey;
      }
    }

    final lowerKey = keyName.toLowerCase();
    final cleanKey = lowerKey.replaceAll('dropdownlist', '');
    return cleanKey.trim().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  List<String> getDropdownItems(String keyName) {
    final normalizedKey = _normalizeDropdownKey(keyName);

    if (dropdownData.containsKey(normalizedKey)) {
      final apiItems = dropdownData[normalizedKey] ?? [];
      if (apiItems.isNotEmpty) {
        return apiItems;
      }
    }

    return _getStaticDropdownItems(keyName);
  }

  List<String> _getStaticDropdownItems(String keyName) {
    switch (keyName) {
      case "rcBookAvailability":
      case "rcBookAvailabilityDropdownList":
        return const [
          'Original',
          'Photocopy',
          'Duplicate',
          'Lost',
          'Lost with Photocopy',
        ];

      case "rcCondition":
        return const ['Okay', 'Damaged', 'Faded'];

      case "mismatchInRc":
      case "mismatchInRcDropdownList":
        return const [
          'No Mismatch',
          'Make',
          'Model',
          'Variant',
          'Ownership Serial Number',
          'Fuel Type',
          'Color',
          'Seating Capacity',
          'Month & Year of Manufacture',
        ];

      case "roadTaxValidity":
        return const ['Limited Period', 'OTT', 'LTT'];

      case "insurance":
      case "insuranceDropdownList":
        return const [
          'Policy Not Available',
          'Expired',
          'Third Party',
          'Comprehensive',
          'Zero Depreciation',
        ];

      case "hypothecationDetails":
        return const [
          'Not Hypothecated',
          'Loan Active',
          'Valid Bank NOC Available',
          'NOC Not Available',
          'Loan Closed',
        ];

      case "rtoNoc":
        return const [
          'Not Applicable',
          'Issued',
          'Expired (issued 90 days ago)',
          'Missing',
        ];

      case "rtoForm28":
        return const [
          'Not Applicable',
          'Issued',
          'Expired (issued 90 days ago)',
          'Missing',
        ];

      case "partyPeshi":
        return const [
          'Seller will not appear',
          'Seller will attend anywhere in West Bengal',
          'Seller will appear in Kolkata region only',
        ];

      case "toBeScrapped":
        return const ['Yes', 'No'];

      case "duplicateKey":
        return const ['Yes', 'No'];

      case "fuelType":
        return const [
          'Diesel',
          'Petrol',
          'Petrol+CNG',
          'Petrol+LPG',
          'Electric Vehicle',
          'Mild Hybrid',
          'Petrol / Hybrid',
          'Plug-in Hybrid',
          'Diesel / Hybrid',
        ];

      case "bonnet":
      case "bonnetDropdownList":
        return const [
          'Okay',
          'Scratch',
          'Major Scratch',
          'Dent',
          'Major Dent',
          'Rust',
          'Major Rust',
          'Repainted',
          'Faded',
          'Vinyl Wrapped',
          'Prop Stand Missing',
          'Prop Stand Damaged',
          'Hydraulic Not Working',
          'Repaired',
          'Replaced',
          'Damaged',
          'Not Opening',
        ];

      case "frontWindshield":
      case "frontWindshieldDropdownList":
        return const ['Okay', 'Scratched', 'Spots', 'Replaced', 'Damaged'];

      case "roof":
      case "roofDropdownList":
        return const [
          'Okay',
          'Scratch',
          'Major Scratch',
          'Dent',
          'Major Dent',
          'Rust',
          'Major Rust',
          'Repainted',
          'Faded',
          'Vinyl Wrapped',
          'Repaired',
          'Replaced',
          'Damaged',
        ];

      case "frontBumper":
      case "frontBumperDropdownList":
        return const [
          'Okay',
          'Scratch',
          'Major Scratch',
          'Dent',
          'Major Dent',
          'Rust',
          'Major Rust',
          'Repainted',
          'Faded',
          'Vinyl Wrapped',
          'Repaired',
          'Welded',
          'Replaced',
          'Damaged',
          'Grill Damaged',
        ];

      case "lhsHeadlamp":
      case "rhsHeadlamp":
      case "lhsHeadlampDropdownList":
      case "rhsHeadlampDropdownList":
        return const [
          'Okay',
          'Scratched',
          'Repaired',
          'Headlamp Not Working',
          'High Beam Not Working',
          'Low Beam Not Working',
          'DRL Not Working',
          'DRL Damaged',
          'Damaged',
          'Missing',
        ];

      case "battery":
      case "batteryDropdownList":
        return const [
          'Okay',
          'Changed',
          'Weak',
          'Dead',
          'Jumpstart',
          'Acid Leakage',
          'Discharge Light Glowing',
          'Damaged',
        ];

      case "yesNo":
        return const ["Yes", "No"];

      case "okIssue":
        return const ["Okay", "Issue"];

      case "workingNA":
        return const ["Working", "Not Working", "N/A"];

      case "transmissionOptions":
        return const ["Manual", "Automatic", "CVT", "AMT"];

      case "driveTrainOptions":
        return const ["FWD", "RWD", "AWD", "4WD"];

      case "additionalDetails":
      case "additionalDetailsDropdownList":
        return const [
          "Migrated From Other State",
          "Car Converted From Commercial To Private",
        ];

      default:
        debugPrint("⚠️ No static items found for key: $keyName");
        return [];
    }
  }

  void printCompleteJson() {
    try {
      final jsonData = _buildSubmitPayload();
      final jsonString = JsonEncoder.withIndent('  ').convert(jsonData);

      debugPrint("\n" + "=" * 80);
      debugPrint("📋 COMPLETE JSON DATA");
      debugPrint("=" * 80);
      debugPrint(jsonString);
      debugPrint("=" * 80);
      debugPrint("Total keys: ${jsonData.keys.length}");
      debugPrint("=" * 80 + "\n");
    } catch (e) {
      debugPrint("❌ JSON PRINT ERROR: $e");
    }
  }

  // =====================================================
  // ✅ UPDATED: STORAGE METHODS WITH APPOINTMENT ID
  // =====================================================

  String _getStorageKey(String appointmentId, String fieldKey) {
    return "${_storagePrefix}${appointmentId.trim()}__$fieldKey";
  }

  List<String> _getAllStorageKeys(String appointmentId) {
    final prefs = Get.find<SharedPreferences>();
    final prefix = "${_storagePrefix}${appointmentId.trim()}__";
    return prefs.getKeys().where((key) => key.startsWith(prefix)).toList();
  }

  Future<void> _autoSaveField(String key, dynamic value) async {
    if (_isAutoSaving) return;

    final appt = getString("appointmentId", def: "").trim();
    if (appt.isEmpty || appt == "N/A") return;

    _isAutoSaving = true;
    try {
      await _saveFieldToStorage(
        appointmentId: appt,
        fieldKey: key,
        value: value,
      );
    } catch (e) {
      debugPrint("❌ AUTO-SAVE ERROR: $key - $e");
    } finally {
      _isAutoSaving = false;
    }
  }

  Future<void> _saveFieldToStorage({
    required String appointmentId,
    required String fieldKey,
    required dynamic value,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(appointmentId, fieldKey);

      if (value == null) {
        await prefs.remove(key);
        return;
      }

      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      } else if (value is DateTime) {
        await prefs.setString(key, value.toIso8601String());
      } else if (value is List) {
        final encoded = jsonEncode(value);
        await prefs.setString(key, encoded);
      } else {
        await prefs.setString(key, value.toString());
      }

      debugPrint(
        "💾 Saved to storage: $fieldKey = $value for appt: $appointmentId",
      );
    } catch (e) {
      debugPrint("❌ STORAGE SAVE ERROR: $fieldKey - $e");
    }
  }

  // =====================================================
  // ✅ NEW: LOAD DATA FOR SPECIFIC APPOINTMENT
  // =====================================================

  Future<void> loadDataForAppointment(String appointmentId) async {
    if (appointmentId.isEmpty || appointmentId == "N/A") return;

    try {
      _isRestoring = true;
      _currentAppointmentId = appointmentId;

      debugPrint("🔄 LOADING data for appointment: $appointmentId");

      // Clear current data first
      _seedDefaults();

      // Set the appointment ID
      setString("appointmentId", appointmentId, silent: true, force: true);

      // Load all stored data for this appointment
      await _loadAllStoredData(appointmentId);

      // Load local images and videos
      await _restoreLocalImagesAndVideos(appointmentId);

      // Update text controllers
      for (final key in _tcs.keys) {
        _pushToController(key);
      }

      _ensureMirrors(silent: true);
      touch();

      debugPrint("✅ LOAD COMPLETE for appointment: $appointmentId");

      // Auto-fetch RC data if registration number exists
      final regNo = getString("registrationNumber", def: "").trim();
      if (regNo.isNotEmpty && regNo != "N/A") {
        Future.delayed(const Duration(milliseconds: 500), () {
          fetchRcAdvancedAndFill();
        });
      }
    } catch (e, stack) {
      debugPrint("❌ LOAD ERROR for $appointmentId: $e");
      debugPrint("Stack trace: $stack");
    } finally {
      _isRestoring = false;
    }
  }

  Future<void> _loadAllStoredData(String appointmentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = _getAllStorageKeys(appointmentId);

      debugPrint("📁 Found ${keys.length} stored keys for $appointmentId");

      for (final fullKey in keys) {
        final prefix = "${_storagePrefix}${appointmentId}__";
        final fieldKey = fullKey.substring(prefix.length);

        // Skip local images/videos keys (handled separately)
        if (fieldKey.endsWith("_local_images") ||
            fieldKey.endsWith("_local_video")) {
          continue;
        }

        final value = await _loadFieldFromStorage(
          appointmentId: appointmentId,
          fieldKey: fieldKey,
        );

        if (value != null) {
          _setValueByType(fieldKey, value);
          debugPrint("✅ Loaded $fieldKey = $value");
        }
      }
    } catch (e) {
      debugPrint("❌ Error loading stored data: $e");
    }
  }

  void _setValueByType(String fieldKey, dynamic value) {
    if (value is String) {
      setString(fieldKey, value, silent: true, force: true);
    } else if (value is int) {
      setInt(fieldKey, value, silent: true, force: true);
    } else if (value is bool) {
      data[fieldKey] = value;
    } else if (value is double) {
      data[fieldKey] = value;
    } else if (value is List<String>) {
      setList(fieldKey, value, silent: true, force: true);
    } else if (value is DateTime) {
      setDate(fieldKey, value, silent: true, force: true);
    }
  }

  // =====================================================
  // ✅ UPDATED: IMAGES LOCAL STORAGE METHODS
  // =====================================================
  Future<void> saveLocalImagesToStorage(
    String fieldKey,
    List<String> imagePaths,
  ) async {
    final appt = getString("appointmentId", def: "").trim();
    if (appt.isEmpty || appt == "N/A") return;

    try {
      // Store in cache with appointment ID prefix
      final cacheKey = "${appt}_$fieldKey";
      _localImagesCache[cacheKey] = List<String>.from(imagePaths);

      // Store in persistent storage
      await _saveFieldToStorage(
        appointmentId: appt,
        fieldKey: "${fieldKey}_local_images",
        value: imagePaths,
      );

      debugPrint(
        "💾 Saved local images for $fieldKey (appt: $appt): ${imagePaths.length} images",
      );
    } catch (e) {
      debugPrint("❌ Error saving local images: $e");
    }
  }

  // ✅ NEW: Remove image method
  Future<void> removeImage(String fieldKey, String imagePath) async {
    try {
      debugPrint("🗑️ Removing image: $imagePath from field: $fieldKey");

      // Get current images for this field
      final currentImages = getLocalImages(fieldKey);
      if (!currentImages.contains(imagePath)) {
        debugPrint("⚠️ Image not found in current list");
        return;
      }

      // Check if it's a URL (already uploaded to Cloudinary)
      final isUploadedUrl =
          imagePath.startsWith('http://') || imagePath.startsWith('https://');

      // If it's a Cloudinary URL, delete from Cloudinary
      if (isUploadedUrl) {
        final deleted = await deleteMediaFromCloudinary(
          mediaUrl: imagePath,
          fieldKey: fieldKey,
        );

        if (!deleted) {
          debugPrint("❌ Failed to delete from Cloudinary");
        } else {
          debugPrint("✅ Deleted from Cloudinary");
        }
      }

      // Remove from local memory
      final updatedImages = List<String>.from(currentImages)
        ..removeWhere((path) => path == imagePath);

      localPickedImages[fieldKey] = updatedImages;

      // Also remove from uploaded URLs list if it exists there
      final uploadedUrls = getList(fieldKey);
      if (uploadedUrls.contains(imagePath)) {
        final updatedUrls = List<String>.from(uploadedUrls)
          ..removeWhere((url) => url == imagePath);
        setList(fieldKey, updatedUrls, silent: true, force: true);
      }

      // ✅ Save updated list to persistent storage
      final appt = getString("appointmentId", def: "").trim();
      if (appt.isNotEmpty && appt != "N/A") {
        await saveLocalImagesToStorage(fieldKey, updatedImages);
      }

      // Show success message

      touch(); // Update UI
    } catch (e) {
      debugPrint("❌ Error removing image: $e");

      ToastWidget.show(
        context: Get.context!,
        title: "Error",
        subtitle: "Failed to remove image: $e",
        type: ToastType.error,
      );
    }
  }

  Future<List<String>> loadLocalImagesFromStorage(String fieldKey) async {
    final appt = getString("appointmentId", def: "").trim();
    if (appt.isEmpty || appt == "N/A") return [];

    try {
      // Check cache with appointment ID prefix
      final cacheKey = "${appt}_$fieldKey";
      if (_localImagesCache.containsKey(cacheKey)) {
        final cached = _localImagesCache[cacheKey]!;
        debugPrint(
          "📸 Using cached images for $fieldKey (appt: $appt): ${cached.length} images",
        );
        return List<String>.from(cached);
      }

      // Load from storage
      debugPrint(
        "📸 Loading local images from storage for: $fieldKey (appt: $appt)",
      );
      final value = await _loadFieldFromStorage(
        appointmentId: appt,
        fieldKey: "${fieldKey}_local_images",
      );

      if (value != null) {
        if (value is List) {
          final imagePaths = value.cast<String>().toList();
          _localImagesCache[cacheKey] = imagePaths;
          debugPrint(
            "✅ Loaded local images for $fieldKey (appt: $appt): ${imagePaths.length} images",
          );
          return imagePaths;
        } else if (value is String && value.isNotEmpty) {
          final imagePaths = [value];
          _localImagesCache[cacheKey] = imagePaths;
          debugPrint(
            "✅ Loaded single local image for $fieldKey (appt: $appt): $value",
          );
          return imagePaths;
        }
      }
    } catch (e) {
      debugPrint(
        "❌ Error loading local images for $fieldKey (appt: $appt): $e",
      );
    }

    return [];
  }

  // =====================================================
  // ✅ UPDATED: VIDEOS LOCAL STORAGE METHODS
  // =====================================================
  Future<void> saveLocalVideoToStorage(
    String fieldKey,
    String? videoPath,
  ) async {
    final appt = getString("appointmentId", def: "").trim();
    if (appt.isEmpty || appt == "N/A") return;

    try {
      // Store in cache with appointment ID prefix
      final cacheKey = "${appt}_$fieldKey";
      _localVideosCache[cacheKey] = videoPath;

      // Store in persistent storage
      await _saveFieldToStorage(
        appointmentId: appt,
        fieldKey: "${fieldKey}_local_video",
        value: videoPath ?? "",
      );

      debugPrint(
        "💾 Saved local video for $fieldKey (appt: $appt): $videoPath",
      );
    } catch (e) {
      debugPrint("❌ Error saving local video: $e");
    }
  }

  Future<String?> loadLocalVideoFromStorage(String fieldKey) async {
    final appt = getString("appointmentId", def: "").trim();
    if (appt.isEmpty || appt == "N/A") return null;

    try {
      // Check cache with appointment ID prefix
      final cacheKey = "${appt}_$fieldKey";
      if (_localVideosCache.containsKey(cacheKey)) {
        final cached = _localVideosCache[cacheKey];
        debugPrint(
          "🎬 Using cached video for $fieldKey (appt: $appt): $cached",
        );
        return cached;
      }

      // Load from storage
      debugPrint(
        "🎬 Loading local video from storage for: $fieldKey (appt: $appt)",
      );
      final value = await _loadFieldFromStorage(
        appointmentId: appt,
        fieldKey: "${fieldKey}_local_video",
      );

      if (value != null) {
        if (value is String && value.isNotEmpty) {
          _localVideosCache[cacheKey] = value;
          debugPrint(
            "✅ Loaded local video for $fieldKey (appt: $appt): $value",
          );
          return value;
        } else if (value is List && value.isNotEmpty) {
          final videoPath = value.first.toString();
          if (videoPath.isNotEmpty) {
            _localVideosCache[cacheKey] = videoPath;
            debugPrint(
              "✅ Loaded local video from list for $fieldKey (appt: $appt): $videoPath",
            );
            return videoPath;
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Error loading local video for $fieldKey (appt: $appt): $e");
    }

    return null;
  }

  Future<dynamic> _loadFieldFromStorage({
    required String appointmentId,
    required String fieldKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(appointmentId, fieldKey);

      if (!prefs.containsKey(key)) {
        debugPrint("⚠️ Key not found: $key");
        return null;
      }

      debugPrint("🔍 Loading $fieldKey for appt: $appointmentId - key: $key");

      // Handle local images/videos fields
      if (fieldKey.endsWith("_local_images") ||
          fieldKey.endsWith("_local_video")) {
        debugPrint("  → Detected as local media field");

        if (fieldKey.endsWith("_local_images")) {
          try {
            final listVal = prefs.getStringList(key);
            if (listVal != null) {
              debugPrint("  → Loaded as IMAGE LIST: ${listVal.length} items");
              return listVal;
            }
          } catch (e) {
            debugPrint("  → Error loading as string list: $e");
          }
        }

        if (fieldKey.endsWith("_local_video")) {
          try {
            final stringVal = prefs.getString(key);
            if (stringVal != null && stringVal.isNotEmpty) {
              debugPrint("  → Loaded as VIDEO PATH: $stringVal");
              return stringVal;
            }
          } catch (e) {
            debugPrint("  → Error loading as string: $e");
          }
        }

        return null;
      }

      // Try different data types
      // 1. Try String List
      try {
        final listVal = prefs.getStringList(key);
        if (listVal != null) {
          debugPrint("  → Loaded as STRING LIST: ${listVal.length} items");
          return listVal;
        }
      } catch (e) {
        debugPrint("  → Not a string list: $e");
      }

      // 2. Try String
      try {
        final stringVal = prefs.getString(key);
        if (stringVal != null) {
          // Check if it's JSON array
          if (stringVal.startsWith('[') && stringVal.endsWith(']')) {
            try {
              final decoded = jsonDecode(stringVal);
              if (decoded is List) {
                debugPrint("  → Loaded as JSON LIST: ${decoded.length} items");
                return decoded.map((e) => e.toString()).toList();
              }
            } catch (_) {}
          }

          // Check if it's DateTime
          final dateTime = DateTime.tryParse(stringVal);
          if (dateTime != null) {
            debugPrint("  → Loaded as DATETIME: $dateTime");
            return dateTime;
          }

          debugPrint("  → Loaded as STRING: $stringVal");
          return stringVal;
        }
      } catch (e) {
        debugPrint("  → Not a string: $e");
      }

      // 3. Try Int
      try {
        if (!fieldKey.contains("Images") &&
            !fieldKey.contains("Video") &&
            !fieldKey.contains("images") &&
            !fieldKey.contains("video")) {
          final intVal = prefs.getInt(key);
          if (intVal != null) {
            debugPrint("  → Loaded as INT: $intVal");
            return intVal;
          }
        }
      } catch (e) {
        debugPrint("  → Not an int: $e");
      }

      // 4. Try Bool
      try {
        final boolVal = prefs.getBool(key);
        if (boolVal != null) {
          debugPrint("  → Loaded as BOOL: $boolVal");
          return boolVal;
        }
      } catch (_) {}

      // 5. Try Double
      try {
        final doubleVal = prefs.getDouble(key);
        if (doubleVal != null) {
          debugPrint("  → Loaded as DOUBLE: $doubleVal");
          return doubleVal;
        }
      } catch (_) {}

      debugPrint("⚠️ No value found for $fieldKey");
      return null;
    } catch (e, stack) {
      debugPrint("❌ STORAGE LOAD ERROR: $fieldKey - $e");
      debugPrint("Stack trace: $stack");
      return null;
    }
  }

  Future<void> clearAllStorageForAppointment(String appointmentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = _getAllStorageKeys(appointmentId);

      for (final key in keys) {
        await prefs.remove(key);
      }

      // Clear caches for this appointment
      final cachePrefix = "${appointmentId}_";
      _localImagesCache.removeWhere(
        (key, value) => key.startsWith(cachePrefix),
      );
      _localVideosCache.removeWhere(
        (key, value) => key.startsWith(cachePrefix),
      );

      debugPrint("🧹 STORAGE CLEARED for $appointmentId (${keys.length} keys)");
    } catch (e) {
      debugPrint("❌ STORAGE CLEAR ERROR: $e");
    }
  }

  // =====================================================
  // ✅ UPDATED: RESTORE LOCAL IMAGES AND VIDEOS
  // =====================================================
  Future<void> _restoreLocalImagesAndVideos(String appointmentId) async {
    try {
      debugPrint("🔄 Restoring local images and videos for $appointmentId");

      // Restore all local images
      for (final imageFieldKey in allImageFieldKeys) {
        final localImages = await loadLocalImagesFromStorage(imageFieldKey);
        if (localImages.isNotEmpty) {
          localPickedImages[imageFieldKey] = List<String>.from(localImages);
          debugPrint(
            "✅ Restored local images for $imageFieldKey: ${localImages.length} images",
          );
        }
      }

      // Restore all local videos
      final videoFields = ["engineVideo", "exhaustSmokeVideo"];
      for (final videoFieldKey in videoFields) {
        final localVideo = await loadLocalVideoFromStorage(videoFieldKey);
        if (localVideo != null && localVideo.isNotEmpty) {
          localPickedVideos[videoFieldKey] = localVideo;
          debugPrint("✅ Restored local video for $videoFieldKey");
        }
      }
    } catch (e) {
      debugPrint("❌ Error restoring local images/videos: $e");
    }
  }

  // =====================================================
  // DATA MAPPING CONSTANTS
  // =====================================================
  static const Map<String, String> stringPair = {
    "emailAddress": "ieName",
    "city": "inspectionCity",
    "insurancePolicyNumber": "policyNumber",
  };

  static const Map<String, String> datePair = {
    "fitnessTill": "fitnessValidity",
    "yearMonthOfManufacture": "yearAndMonthOfManufacture",
  };

  static const Map<String, String> intPair = {
    "odometerReadingInKms": "odometerReadingBeforeTestDrive",
  };

  static const Map<String, String> listPair = {
    "rcTaxToken": "rcTokenImages",
    "insuranceCopy": "insuranceImages",
    "bothKeys": "duplicateKeyImages",
    "form26GdCopyIfRcIsLost": "form26AndGdCopyIfRcIsLostImages",
    "frontMain": "frontMainImages",
    "lhsFront45Degree": "lhsFullViewImages",
    "lhsFrontAlloyImages": "lhsFrontWheelImages",
    "lhsRearAlloyImages": "lhsRearWheelImages",
    "rearMain": "rearMainImages",
    "rhsRear45Degree": "rhsFullViewImages",
    "engineBay": "engineBayImages",
    "additionalImages": "additionalEngineImages",
    "engineSound": "engineVideo",
    "exhaustSmokeImages": "exhaustSmokeVideo",
    "meterConsoleWithEngineOn": "meterConsoleWithEngineOnImages",
    "airbags": "airbagImages",
    "frontSeatsFromDriverSideDoorOpen": "frontSeatsFromDriverSideImages",
    "rearSeatsFromRightSideDoorOpen": "rearSeatsFromRightSideImages",
    "dashboardFromRearSeat": "dashboardImages",
    "additionalImages2": "additionalInteriorImages",
  };

  static const Map<String, String> stringToDropdownList = {
    "rcBookAvailability": "rcBookAvailabilityDropdownList",
    "mismatchInRc": "mismatchInRcDropdownList",
    "insurance": "insuranceDropdownList",
    "mismatchInInsurance": "mismatchInInsuranceDropdownList",
    "additionalDetails": "additionalDetailsDropdownList",

    "bonnet": "bonnetDropdownList",
    "frontWindshield": "frontWindshieldDropdownList",
    "roof": "roofDropdownList",
    "frontBumper": "frontBumperDropdownList",
    "lhsHeadlamp": "lhsHeadlampDropdownList",
    "lhsFoglamp": "lhsFoglampDropdownList",
    "rhsHeadlamp": "rhsHeadlampDropdownList",
    "rhsFoglamp": "rhsFoglampDropdownList",
    "lhsFender": "lhsFenderDropdownList",
    "lhsOrvm": "lhsOrvmDropdownList",
    "lhsAPillar": "lhsAPillarDropdownList",
    "lhsBPillar": "lhsBPillarDropdownList",
    "lhsCPillar": "lhsCPillarDropdownList",
    "lhsFrontAlloy": "lhsFrontWheelDropdownList",
    "lhsFrontTyre": "lhsFrontTyreDropdownList",
    "lhsRearAlloy": "lhsRearWheelDropdownList",
    "lhsRearTyre": "lhsRearTyreDropdownList",
    "lhsFrontDoor": "lhsFrontDoorDropdownList",
    "lhsRearDoor": "lhsRearDoorDropdownList",
    "lhsRunningBorder": "lhsRunningBorderDropdownList",
    "lhsQuarterPanel": "lhsQuarterPanelDropdownList",
    "rearBumper": "rearBumperDropdownList",
    "lhsTailLamp": "lhsTailLampDropdownList",
    "rhsTailLamp": "rhsTailLampDropdownList",
    "rearWindshield": "rearWindshieldDropdownList",
    "bootDoor": "bootDoorDropdownList",
    "spareTyre": "spareTyreDropdownList",
    "bootFloor": "bootFloorDropdownList",
    "rhsRearAlloy": "rhsRearWheelDropdownList",
    "rhsRearTyre": "rhsRearTyreDropdownList",
    "rhsFrontAlloy": "rhsFrontWheelDropdownList",
    "rhsFrontTyre": "rhsFrontTyreDropdownList",
    "rhsQuarterPanel": "rhsQuarterPanelDropdownList",
    "rhsAPillar": "rhsAPillarDropdownList",
    "rhsBPillar": "rhsBPillarDropdownList",
    "rhsCPillar": "rhsCPillarDropdownList",
    "rhsRunningBorder": "rhsRunningBorderDropdownList",
    "rhsRearDoor": "rhsRearDoorDropdownList",
    "rhsFrontDoor": "rhsFrontDoorDropdownList",
    "rhsOrvm": "rhsOrvmDropdownList",
    "rhsFender": "rhsFenderDropdownList",
    "comments": "commentsOnExteriorDropdownList",

    "upperCrossMember": "upperCrossMemberDropdownList",
    "radiatorSupport": "radiatorSupportDropdownList",
    "headlightSupport": "headlightSupportDropdownList",
    "lowerCrossMember": "lowerCrossMemberDropdownList",
    "lhsApron": "lhsApronDropdownList",
    "rhsApron": "rhsApronDropdownList",
    "firewall": "firewallDropdownList",
    "cowlTop": "cowlTopDropdownList",
    "engine": "engineDropdownList",
    "battery": "batteryDropdownList",
    "coolant": "coolantDropdownList",
    "engineOilLevelDipstick": "engineOilLevelDipstickDropdownList",
    "engineOil": "engineOilDropdownList",
    "engineMount": "engineMountDropdownList",
    "enginePermisableBlowBy": "enginePermisableBlowByDropdownList",
    "exhaustSmoke": "exhaustSmokeDropdownList",
    "clutch": "clutchDropdownList",
    "gearShift": "gearShiftDropdownList",
    "commentsOnEngine": "commentsOnEngineDropdownList",
    "commentsOnEngineOil": "commentsOnEngineOilDropdownList",
    "commentsOnTowing": "commentsOnTowingDropdownList",
    "commentsOnTransmission": "commentsOnTransmissionDropdownList",
    "commentsOnRadiator": "commentsOnRadiatorDropdownList",
    "commentsOnOthers": "commentsOnOthersDropdownList",

    "steering": "steeringDropdownList",
    "brakes": "brakesDropdownList",
    "suspension": "suspensionDropdownList",

    "rearWiperWasher": "rearWiperWasherDropdownList",
    "rearDefogger": "rearDefoggerDropdownList",

    "reverseCamera": "reverseCameraDropdownList",
    "commentOnInterior": "commentOnInteriorDropdownList",
    "sunroof": "sunroofDropdownList",

    "musicSystem": "infotainmentSystemDropdownList",
    "stereo": "infotainmentSystemDropdownList",
  };

  static const String oldRearBootOpen = "rearWithBootDoorOpen";
  static const String newRearBootOpen = "rearWithBootDoorOpenImages";

  static const String oldLeather = "leatherSeats";
  static const String oldFabric = "fabricSeats";
  static const String newSeatsUph = "seatsUpholstery";

  static const String oldSteeringMounted = "steeringMountedAudioControl";
  static const String newSteeringMedia = "steeringMountedMediaControls";
  static const String newSteeringSystem = "steeringMountedSystemControls";

  static const String oldAcManual = "airConditioningManual";
  static const String oldAcClimate = "airConditioningClimateControl";
  static const String newAcType = "acTypeDropdownList";
  static const String newAcCooling = "acCoolingDropdownList";

  String _listToCommaString(List<String> list) {
    if (list.isEmpty) return "N/A";
    return list
        .where((item) => item.trim().isNotEmpty && item != "N/A")
        .join(", ");
  }

  List<String> _commaStringToList(String str) {
    if (str.isEmpty || str == "N/A") return [];
    return str
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static final Set<String> oldKeysWithComment = <String>{
    ...stringPair.keys,
    ...datePair.keys,
    ...intPair.keys,
    ...listPair.keys,
    ...stringToDropdownList.keys,
    oldRearBootOpen,
    oldLeather,
    oldFabric,
    oldSteeringMounted,
    oldAcManual,
    oldAcClimate,
    "registrationType",
  };

  static final Set<String> newKeysAll = <String>{
    ...stringPair.values,
    ...datePair.values,
    ...intPair.values,
    ...listPair.values,
    ...stringToDropdownList.values,
    newRearBootOpen,
    newSeatsUph,
    newSteeringMedia,
    newSteeringSystem,
    newAcType,
    newAcCooling,

    "lhsFenderImages",
    "batteryImages",
    "sunroofImages",
    "fuelLevel",
    "abs",
    "roadTaxValidity",
    "taxValidTill",
    "insuranceValidity",
    "appointmentId",
    "id",
    "timestamp",
    "fuelType",
    "cubicCapacity",
    "hypothecationDetails",
    "frontWindshieldImages",
    "roofImages",
    "rcCondition",
    "registrationNumber",
    "registrationDate",
    "toBeScrapped",
    "registrationState",
    "registeredRto",
    "ownerSerialNumber",
    "make",
    "model",
    "variant",
    "engineNumber",
    "chassisNumber",
    "registeredOwner",
    "registeredAddressAsPerRc",
    "duplicateKey",
    "rtoNoc",
    "rtoForm28",
    "partyPeshi",
    "lhsHeadlampImages",
    "lhsFoglampImages",
    "rhsHeadlampImages",
    "rhsFoglampImages",
    "lhsFrontTyreImages",
    "lhsRunningBorderImages",
    "lhsOrvmImages",
    "lhsAPillarImages",
    "lhsFrontDoorImages",
    "lhsBPillarImages",
    "lhsRearDoorImages",
    "lhsCPillarImages",
    "lhsRearTyreImages",
    "lhsTailLampImages",
    "rhsTailLampImages",
    "rearWindshieldImages",
    "spareTyreImages",
    "bootFloorImages",
    "noOfPowerWindows",
    "rhsRearTyreImages",
    "rhsCPillarImages",
    "rhsRearDoorImages",
    "rhsBPillarImages",
    "rhsFrontDoorImages",
    "rhsAPillarImages",
    "rhsRunningBorderImages",
    "rhsFrontTyreImages",
    "rhsOrvmImages",
    "rhsFenderImages",
    "noOfAirBags",
    "inbuiltSpeaker",
    "externalSpeaker",
    "commentsOnAc",
    "approvedBy",
    "approvalDate",
    "approvalTime",
    "approvalStatus",
    "contactNumber",
    "newArrivalMessage",
    "budgetCar",
    "status",
    "priceDiscovery",
    "priceDiscoveryBy",
    "latlong",
    "retailAssociate",
    "kmRangeLevel",
    "highestBidder",
    "v",

    "irvm",
    "driverAirbag",
    "coDriverAirbag",
    "coDriverSeatAirbag",
    "lhsCurtainAirbag",
    "lhsRearSideAirbag",
    "driverSeatAirbag",
    "rhsCurtainAirbag",
    "rhsRearSideAirbag",
    "driverSideKneeAirbag",
    "coDriverKneeSeatAirbag",
    "chassisEmbossmentImages",
    "chassisDetails",
    "vinPlateImages",
    "vinPlateDetails",
    "roadTaxImages",
    "seatingCapacity",
    "color",
    "numberOfCylinders",
    "norms",
    "hypothecatedTo",
    "insurer",
    "pucImages",
    "pucValidity",
    "pucNumber",
    "rcStatus",
    "blacklistStatus",
    "rtoNocImages",
    "rtoForm28Images",
    "frontWiperAndWasherDropdownList",
    "frontWiperAndWasherImages",
    "lhsRearFogLampDropdownList",
    "lhsRearFogLampImages",
    "rhsRearFogLampDropdownList",
    "rhsRearFogLampImages",
    "rearWiperAndWasherImages",
    "spareWheelDropdownList",
    "spareWheelImages",
    "cowlTopImages",
    "firewallImages",
    "lhsSideMemberDropdownList",
    "rhsSideMemberDropdownList",
    "transmissionTypeDropdownList",
    "driveTrainDropdownList",
    "commentsOnClusterMeterDropdownList",
    "dashboardDropdownList",
    "acImages",
    "reverseCameraImages",
    "driverSeatDropdownList",
    "coDriverSeatDropdownList",
    "frontCentreArmRestDropdownList",
    "rearSeatsDropdownList",
    "thirdRowSeatsDropdownList",
    "odometerReadingAfterTestDriveImages",
    "odometerReadingAfterTestDriveInKms",
    "yearAndMonthOfManufacture",
  };

  static const Set<String> neverShowKeys = {"__v", "latlong"};

  List<String> get allImageFieldKeys => <String>[
    "rcTokenImages",
    "roadTaxImages",
    "insuranceImages",
    "rtoNocImages",
    "rtoForm28Images",
    "duplicateKeyImages",
    "form26AndGdCopyIfRcIsLostImages",
    "pucImages",
    "chassisEmbossmentImages",
    "vinPlateImages",
    "odometerReadingAfterTestDriveImages",
    "engineVideo",
    "exhaustSmokeVideo",

    "lhsFenderImages",
    "batteryImages",
    "sunroofImages",
    "cowlTopImages",
    "firewallImages",
    "frontWiperAndWasherImages",
    "rearWiperAndWasherImages",
    "lhsRearFogLampImages",
    "rhsRearFogLampImages",
    "spareWheelImages",
    "acImages",
    "reverseCameraImages",

    ..._allExteriorImageKeys,
    ..._allEngineImageKeys,
    ..._allInteriorImageKeys,
  ];

  Set<String> computeOldUiKeysNoComment() {
    final keys = data.keys.toSet();
    final old = <String>{};
    for (final k in keys) {
      if (neverShowKeys.contains(k)) continue;
      if (newKeysAll.contains(k)) continue;
      if (oldKeysWithComment.contains(k)) continue;
      old.add(k);
    }
    return old;
  }

  final Map<String, TextEditingController> _tcs = {};
  final Set<String> _tcUpdating = <String>{};

  TextEditingController tc(String key) {
    if (_tcs.containsKey(key)) return _tcs[key]!;
    final ctrl = TextEditingController(text: getText(key));
    _tcs[key] = ctrl;

    ctrl.addListener(() {
      if (_tcUpdating.contains(key)) return;
      if (isLocked(key)) {
        _pushToController(key);
        return;
      }

      final v = ctrl.text;
      if (_intTextKeys.contains(key)) {
        final parsed = int.tryParse(v.trim());
        setInt(key, parsed ?? 0, silent: true);
      } else {
        setString(key, v, silent: true);
      }
      touch();
    });

    return ctrl;
  }

  void _pushToController(String key) {
    final ctrl = _tcs[key];
    if (ctrl == null) return;

    final want = _intTextKeys.contains(key)
        ? getInt(key).toString()
        : getString(key, def: "");

    if (ctrl.text == want) return;

    _tcUpdating.add(key);
    ctrl.text = want;
    _tcUpdating.remove(key);
  }

  static const Set<String> _intTextKeys = {
    "ownerSerialNumber",
    "cubicCapacity",
    "seatingCapacity",
    "numberOfCylinders",
    "noOfAirBags",
    "odometerReadingBeforeTestDrive",
    "odometerReadingInKms",
    "odometerReadingAfterTestDriveInKms",
    "priceDiscovery",
    "kmRangeLevel",
  };

  List<String> getLocalImages(String fieldKey) =>
      localPickedImages[fieldKey] ?? <String>[];

  // =====================================================
  // ✅ UPDATED: Auto-upload when images are selected
  // =====================================================

  Future<void> setLocalImages(String fieldKey, List<String> paths) async {
    // First save to local storage
    localPickedImages[fieldKey] = paths;

    // ✅ Save to local storage with appointment ID
    await saveLocalImagesToStorage(fieldKey, paths);

    final appt = getString("appointmentId", def: "").trim();
    if (appt.isNotEmpty && appt.toUpperCase() != "N/A") {
      await _autoSaveField(fieldKey, const []);
    }

    setList(fieldKey, const [], silent: true, force: true);
    touch();

    // ✅ NEW: Auto-upload images immediately after selection
    if (paths.isNotEmpty) {
      final List<String> newImages = [];

      // Check which images are new (not already uploaded)
      final currentUploadedUrls = getList(fieldKey);
      for (final path in paths) {
        // If it's a local path (not URL), it needs upload
        if (!path.startsWith('http://') && !path.startsWith('https://')) {
          newImages.add(path);
        }
      }

      // Upload only new images
      if (newImages.isNotEmpty) {
        // Wait a bit for UI to update
        await Future.delayed(const Duration(milliseconds: 300));

        // Upload the images
        final uploadedUrls = await _uploadImagesToCloudinary(
          appointmentId: appt,
          localPaths: newImages,
        );

        if (uploadedUrls.isNotEmpty) {
          // Combine existing uploaded URLs with new ones
          final existingUrls = getList(fieldKey);
          final allUrls = [...existingUrls, ...uploadedUrls];
          setList(fieldKey, allUrls, silent: true, force: true);

          ToastWidget.show(
            context: Get.context!,
            title: "Uploaded",
            subtitle: "Images uploaded successfully",
            type: ToastType.success,
          );
        }
      }
    }
  }

  bool isFieldUploading(String fieldKey) => uploadingFields.contains(fieldKey);
  bool isFieldUploaded(String fieldKey) => getList(fieldKey).isNotEmpty;

  Future<List<String>> uploadSelectedImagesForField(String fieldKey) async {
    final appt = getString("appointmentId", def: "").trim();
    if (appt.isEmpty || appt.toUpperCase() == "N/A") {
      _snackErr("appointmentId is missing. Please apply a lead first.");
      return <String>[];
    }

    final localPaths = getLocalImages(fieldKey);
    if (localPaths.isEmpty) {
      _snackErr("Please select image(s) for $fieldKey first");
      return <String>[];
    }

    if (isFieldUploading(fieldKey)) return <String>[];

    try {
      uploadingFields.add(fieldKey);
      touch();

      debugPrint("⬆️ UPLOAD START: $fieldKey | appt: $appt");

      // Filter out already uploaded URLs
      final pathsToUpload = localPaths
          .where(
            (path) =>
                !path.startsWith('http://') && !path.startsWith('https://'),
          )
          .toList();

      if (pathsToUpload.isEmpty) {
        // All images are already uploaded
        return getList(fieldKey);
      }

      final urls = await _uploadImagesToCloudinary(
        appointmentId: appt,
        localPaths: pathsToUpload,
      );

      debugPrint("✅ UPLOAD SUCCESS: $fieldKey | ${urls.length} URLs");

      // Combine with existing uploaded URLs
      final existingUrls = getList(fieldKey);
      final allUrls = [...existingUrls, ...urls];
      setList(fieldKey, allUrls, silent: true, force: true);

      ToastWidget.show(
        context: Get.context!,
        title: "Uploaded",
        subtitle: "Uploaded ${urls.length} image(s)",
        type: ToastType.success,
      );

      touch();
      return allUrls;
    } catch (e) {
      _snackErr("Upload failed: $e");
      debugPrint("❌ UPLOAD FAILED: $fieldKey | $e");
      return <String>[];
    } finally {
      uploadingFields.remove(fieldKey);
      touch();
    }
  }
  // =====================================================
  // ✅ NEW: Delete media from Cloudinary
  // =====================================================

  Future<bool> deleteMediaFromCloudinary({
    required String mediaUrl,
    required String fieldKey,
  }) async {
    try {
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) return false;

      final token = await _getBearerToken();
      if (token.isEmpty) {
        _snackErr("Token missing (prefs key: token)");
        return false;
      }

      final appt = getString("appointmentId", def: "").trim();
      if (appt.isEmpty || appt == "N/A") {
        _snackErr("Appointment ID missing");
        return false;
      }

      final response = await http.delete(
        Uri.parse(deleteCloudinaryMediaUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "appointmentId": appt,
          "fieldKey": fieldKey,
          "mediaUrl": mediaUrl,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint("✅ Media deleted from Cloudinary: $mediaUrl");
        return true;
      } else {
        debugPrint("❌ Failed to delete media: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Delete media error: $e");
      return false;
    }
  }

  Future<List<String>> _uploadImagesToCloudinary({
    required String appointmentId,
    required List<String> localPaths,
  }) async {
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) return <String>[];
    final uri = Uri.parse(uploadCarImagesUrl);
    final req = http.MultipartRequest('POST', uri);

    req.fields['appointmentId'] = appointmentId;

    final token = await _getBearerToken();
    if (token.isEmpty) {
      throw Exception("Token missing (prefs key: token)");
    }
    req.headers['Authorization'] = "Bearer $token";

    for (final p in localPaths) {
      if (p.trim().isEmpty) continue;
      if (!File(p).existsSync()) continue;
      req.files.add(await http.MultipartFile.fromPath('imagesList', p));
    }

    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception("HTTP ${streamed.statusCode}: $body");
    }
    print("HTTP error in image ${streamed.statusCode}: $body");
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid response");
    }

    final ok = decoded["success"] == true;
    if (!ok) {
      throw Exception(decoded["message"]?.toString() ?? "Upload failed");
    }

    final urlsRaw = decoded["cloudinaryUrls"];
    if (urlsRaw is! List) throw Exception("cloudinaryUrls missing");

    return urlsRaw
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  final RxInt dashboardTabIndex = 1.obs;
  static const List<String> dashboardTabLabels = [
    "Scheduled",
    "Canceled",
    "Re-Scheduled",
    "Running",
    "Inspected",
  ];

  static const List<String> _tabKeys = [
    "scheduled",
    "canceled",
    "re-scheduled",
    "running",
    "inspected",
  ];

  late final TextEditingController dashboardSearchCtrl;
  final RxString dashboardSearchQuery = ''.obs;

  void setDashboardTab(int i) {
    dashboardTabIndex.value = i;
    touch();
  }

  void clearDashboardSearch() {
    dashboardSearchCtrl.clear();
    dashboardSearchQuery.value = "";
    touch();
  }

  String _norm(String? v) => (v ?? '').trim().toLowerCase();

  String _normalizeInspectionStatus(String? raw) {
    var s = _norm(raw);
    if (s.isEmpty) return '';

    if (s.contains('pending')) return 'scheduled';

    if (s == 'sheduled') s = 'scheduled';
    if (s == 'resheduled') s = 're-scheduled';
    if (s == 'rescheduled') s = 're-scheduled';
    if (s == 're scheduled') s = 're-scheduled';
    if (s == 're_scheduled') s = 're-scheduled';
    if (s == 'cancelled') s = 'canceled';
    if (s.contains('cancel')) return 'canceled';
    if (s.contains('inspect')) return 'inspected';
    if (s.contains('running')) return 'running';
    if (s.contains('re') && s.contains('sched')) return 're-scheduled';
    if (s.contains('resched')) return 're-scheduled';
    if (s.contains('sched')) return 'scheduled';
    return s;
  }

  List<LeadsData> dashboardFilteredByTab(List<LeadsData> all) {
    final tab = dashboardTabIndex.value;
    if (tab < 0 || tab >= _tabKeys.length) return all;
    final want = _tabKeys[tab];

    return all.where((d) {
      final insp = _normalizeInspectionStatus(d.inspectionStatus);
      return insp == want;
    }).toList();
  }

  List<LeadsData> dashboardApplySearch(List<LeadsData> list) {
    final q = dashboardSearchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return list;

    bool match(LeadsData d) {
      final owner = (d.ownerName ?? '').toLowerCase();
      final phone = (d.customerContactNumber ?? '').toLowerCase();
      final appt = (d.appointmentId ?? '').toLowerCase();
      final id = (d.id ?? '').toLowerCase();

      final reg = (d.carRegistrationNumber ?? '').toLowerCase();
      final make = (d.make ?? '').toLowerCase();
      final model = (d.model ?? '').toLowerCase();
      final variant = (d.variant ?? '').toLowerCase();

      final address = (d.inspectionAddress ?? '').toLowerCase();
      final city = (d.city ?? '').toLowerCase();
      final insp = (d.inspectionStatus ?? '').toLowerCase();
      final status = (d.vehicleStatus ?? '').toLowerCase();

      return owner.contains(q) ||
          phone.contains(q) ||
          appt.contains(q) ||
          id.contains(q) ||
          reg.contains(q) ||
          make.contains(q) ||
          model.contains(q) ||
          variant.contains(q) ||
          address.contains(q) ||
          city.contains(q) ||
          insp.contains(q) ||
          status.contains(q);
    }

    return list.where(match).toList();
  }

  var isLoading = false.obs;
  final inspectionList = <LeadsData>[].obs;

  final String apiUrl =
      "https://otobix-app-backend-development.onrender.com/api/inspection/telecallings/get-list-by-inspection-engineer";

  static const String updateTelecallingUrl =
      "https://otobix-app-backend-development.onrender.com/api/inspection/telecallings/update";

  final RxString userName = "".obs;

  String get firstName {
    final v = userName.value.trim();
    if (v.isEmpty) return "User";
    return v.split(RegExp(r"\s+")).first;
  }

  Future<void> _loadUserName() async {
    try {
      final saved = await SharedPrefsHelper.getString("userName");
      userName.value = (saved ?? "").toString();
    } catch (_) {
      userName.value = "";
    }
  }

  @override
  void onInit() {
    super.onInit();

    _initializeSharedPreferences();

    dashboardTabIndex.value = 1;
    _loadUserName();

    dashboardSearchCtrl = TextEditingController();
    dashboardSearchCtrl.addListener(() {
      dashboardSearchQuery.value = dashboardSearchCtrl.text.trim();
      touch();
    });
    _loadAllDropdowns();
    getInspectionList();

    formKeys = List.generate(steps.length, (_) => GlobalKey<FormState>());

    _seedDefaults();

    // Load last appointment if exists
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final lastAppt = prefs.getString("last_appointment_id") ?? "";

      if (lastAppt.isNotEmpty && lastAppt != "N/A") {
        setString("appointmentId", lastAppt, silent: true, force: true);

        Future.delayed(const Duration(milliseconds: 1500), () {
          loadDataForAppointment(lastAppt);
        });
      }
    });
  }

  Future<void> _initializeSharedPreferences() async {
    try {
      if (!Get.isRegistered<SharedPreferences>()) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        Get.put<SharedPreferences>(prefs, permanent: true);
      }
    } catch (e) {
      debugPrint("❌ Failed to initialize SharedPreferences: $e");
    }
  }

  @override
  void onClose() {
    dashboardSearchCtrl.dispose();
    for (final c in _tcs.values) {
      c.dispose();
    }
    _tcs.clear();
    super.onClose();
  }

  void _seedDefaults() {
    setString("appointmentId", "N/A", silent: true);
    _currentAppointmentId = "";

    setString("ieName", "N/A", silent: true);
    setString("inspectionCity", "N/A", silent: true);

    setString("emailAddress", "N/A", silent: true);
    setString("city", "N/A", silent: true);

    setString("registrationType", "N/A", silent: true);
    setString("noClaimBonus", "N/A", silent: true);
    setString("electricals", "N/A", silent: true);
    setString("musicSystem", "N/A", silent: true);
    setString("stereo", "N/A", silent: true);
    setString("commentsOnElectricals", "N/A", silent: true);

    setString("rcCondition", "N/A", silent: true);
    setString("registrationNumber", "N/A", silent: true);
    setString("toBeScrapped", "N/A", silent: true);
    setString("registrationState", "N/A", silent: true);
    setString("registrationCity", "N/A", silent: true);
    setString("registeredRto", "N/A", silent: true);

    setString("make", "N/A", silent: true);
    setString("model", "N/A", silent: true);
    setString("variant", "N/A", silent: true);
    setString("engineNumber", "N/A", silent: true);
    setString("chassisNumber", "N/A", silent: true);

    setString("registeredOwner", "N/A", silent: true);
    setString("registeredAddressAsPerRc", "N/A", silent: true);

    setString("fuelType", "N/A", silent: true);
    setString("color", "N/A", silent: true);
    setString("norms", "N/A", silent: true);

    setString("hypothecationDetails", "N/A", silent: true);
    setString("hypothecatedTo", "N/A", silent: true);

    setString("roadTaxValidity", "N/A", silent: true);

    setString("policyNumber", "N/A", silent: true);
    setString("insurancePolicyNumber", "N/A", silent: true);

    setString("duplicateKey", "N/A", silent: true);
    setString("rtoNoc", "N/A", silent: true);
    setString("rtoForm28", "N/A", silent: true);
    setString("partyPeshi", "N/A", silent: true);

    setString("insurer", "N/A", silent: true);
    setString("pollutionCertificateNumber", "N/A", silent: true);

    setString("rcStatus", "N/A", silent: true);
    setString("blacklistStatus", "N/A", silent: true);

    setString("chassisDetails", "N/A", silent: true);
    setString("vinPlateDetails", "N/A", silent: true);

    setString("fuelLevel", "N/A", silent: true);
    setString("abs", "N/A", silent: true);
    setString("inbuiltSpeaker", "N/A", silent: true);
    setString("externalSpeaker", "N/A", silent: true);
    setString("noOfPowerWindows", "N/A", silent: true);

    setString("approvedBy", "", silent: true);
    setString("approvalStatus", "Pending", silent: true);
    setString("status", "Pending", silent: true);

    setString("budgetCar", "N/A", silent: true);
    setString("priceDiscoveryBy", "", silent: true);

    setString("latlong", "", silent: true);
    setString("retailAssociate", "", silent: true);
    setString("highestBidder", "N/A", silent: true);

    setString("contactNumber", "N/A", silent: true);

    setString("irvm", "N/A", silent: true);
    setString("seatsUpholstery", "N/A", silent: true);
    setString("driverAirbag", "N/A", silent: true);
    setString("coDriverAirbag", "N/A", silent: true);
    setString("coDriverSeatAirbag", "N/A", silent: true);
    setString("lhsCurtainAirbag", "N/A", silent: true);
    setString("lhsRearSideAirbag", "N/A", silent: true);
    setString("driverSeatAirbag", "N/A", silent: true);
    setString("rhsCurtainAirbag", "N/A", silent: true);
    setString("rhsRearSideAirbag", "N/A", silent: true);
    setString("driverSideKneeAirbag", "N/A", silent: true);
    setString("coDriverKneeSeatAirbag", "N/A", silent: true);
    setString("commentsOnAc", "N/A", silent: true);

    setString("engineVideo", "N/A", silent: true);
    setString("exhaustSmokeVideo", "N/A", silent: true);

    setInt("ownerSerialNumber", 0, silent: true);
    setInt("cubicCapacity", 0, silent: true);
    setInt("seatingCapacity", 0, silent: true);
    setInt("numberOfCylinders", 0, silent: true);
    setInt("noOfAirBags", 0, silent: true);
    setInt("odometerReadingBeforeTestDrive", 0, silent: true);
    setInt("odometerReadingInKms", 0, silent: true);
    setInt("odometerReadingAfterTestDriveInKms", 0, silent: true);
    setInt("priceDiscovery", 0, silent: true);
    setInt("kmRangeLevel", 0, silent: true);
    setInt("__v", 0, silent: true);

    setList("rcBookAvailabilityDropdownList", const [], silent: true);
    setList("mismatchInRcDropdownList", const [], silent: true);
    setList("insuranceDropdownList", const [], silent: true);
    setList("mismatchInInsuranceDropdownList", const [], silent: true);
    setList("additionalDetailsDropdownList", const [], silent: true);

    for (final k in allImageFieldKeys) {
      setList(k, const [], silent: true);
    }

    for (final k in _allExteriorDropdownKeys) {
      setList(k, const [], silent: true);
    }
    for (final k in _allExteriorImageKeys) {
      setList(k, const [], silent: true);
    }

    for (final k in _allEngineDropdownKeys) {
      setList(k, const [], silent: true);
    }
    for (final k in _allEngineImageKeys) {
      setList(k, const [], silent: true);
    }

    for (final k in _allInteriorDropdownKeys) {
      setList(k, const [], silent: true);
    }
    for (final k in _allInteriorImageKeys) {
      setList(k, const [], silent: true);
    }

    for (final k in _allMechanicalDropdownKeys) {
      setList(k, const [], silent: true);
    }

    setList("lhsSideMemberDropdownList", const [], silent: true);
    setList("rhsSideMemberDropdownList", const [], silent: true);
    setList("transmissionTypeDropdownList", const [], silent: true);
    setList("driveTrainDropdownList", const [], silent: true);
    setList("commentsOnClusterMeterDropdownList", const [], silent: true);
    setList("dashboardDropdownList", const [], silent: true);
    setList("driverSeatDropdownList", const [], silent: true);
    setList("coDriverSeatDropdownList", const [], silent: true);
    setList("frontCentreArmRestDropdownList", const [], silent: true);
    setList("rearSeatsDropdownList", const [], silent: true);
    setList("thirdRowSeatsDropdownList", const [], silent: true);
    setList("lhsRearFogLampDropdownList", const [], silent: true);
    setList("rhsRearFogLampDropdownList", const [], silent: true);
    setList("spareWheelDropdownList", const [], silent: true);
    setList("frontWiperAndWasherDropdownList", const [], silent: true);

    setString(newSeatsUph, "N/A", silent: true);
    setString(newSteeringMedia, "N/A", silent: true);
    setString(newSteeringSystem, "N/A", silent: true);
    setString(newAcType, "N/A", silent: true);
    setString(newAcCooling, "N/A", silent: true);
    setList(newRearBootOpen, const [], silent: true);

    localPickedVideos.clear();
    localPickedImages.clear();

    _ensureMirrors(silent: true);
  }

  // =====================================================
  // ✅ UPDATED: APPLY LEAD TO FORM
  // =====================================================
  void applyLeadToForm(LeadsData lead) {
    debugPrint("🔄 Applying lead data from: ${lead.appointmentId}");

    final appt = (lead.appointmentId ?? "").trim();
    if (appt.isEmpty || appt == "N/A") {
      ToastWidget.show(
        context: Get.context!,
        title: "Error",
        subtitle: "Invalid appointment ID",
        type: ToastType.error,
      );
      return;
    }

    // Clear current data first
    _seedDefaults();

    // Set appointment ID first
    setString("appointmentId", appt, silent: true, force: true);

    // Save to last appointment
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("last_appointment_id", appt);
    });

    // Load data for this appointment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDataForAppointment(appt);
    });

    // Set basic lead data
    _setBasicLeadData(lead);

    touch();
  }

  void _setBasicLeadData(LeadsData lead) {
    // City
    final city = (lead.city ?? "").trim();
    if (city.isNotEmpty) {
      setAndLockString("inspectionCity", city, silent: true);
      setAndLockString("city", city, silent: true);
    }

    // Contact Number
    final phone = (lead.customerContactNumber ?? "").trim();
    if (phone.isNotEmpty) {
      setAndLockString("contactNumber", phone, silent: true);
    }

    // Owner Name
    final owner = (lead.ownerName ?? "").trim();
    if (owner.isNotEmpty) {
      setAndLockString("registeredOwner", owner, silent: true);
    }

    // Email Address
    final email = (lead.emailAddress ?? "").trim();
    if (email.isNotEmpty) {
      setAndLockString("ieName", email, silent: true);
      setAndLockString("emailAddress", email, silent: true);
    }

    // Car Details
    final make = (lead.make ?? "").trim();
    if (make.isNotEmpty) {
      setAndLockString("make", make, silent: true);
    }

    final model = (lead.model ?? "").trim();
    if (model.isNotEmpty) {
      setAndLockString("model", model, silent: true);
    }

    final variant = (lead.variant ?? "").trim();
    if (variant.isNotEmpty) {
      setAndLockString("variant", variant, silent: true);
    }

    // Registration Number
    final regNo = (lead.carRegistrationNumber ?? "").trim();
    if (regNo.isNotEmpty) {
      setAndLockString("registrationNumber", regNo, silent: true);
    }

    // Address
    final address = (lead.inspectionAddress ?? "").trim();
    if (address.isNotEmpty) {
      setAndLockString("registeredAddressAsPerRc", address, silent: true);
    }

    // Odometer
    if (lead.odometerReadingInKms != null) {
      setAndLockInt(
        "odometerReadingBeforeTestDrive",
        lead.odometerReadingInKms!,
        silent: true,
      );
      setAndLockInt(
        "odometerReadingInKms",
        lead.odometerReadingInKms!,
        silent: true,
      );
    }

    // Year of Registration
    if (lead.yearOfRegistration != null) {
      try {
        setAndLockDate(
          "registrationDate",
          DateTime.parse(lead.yearOfRegistration!),
          silent: true,
        );
      } catch (e) {
        debugPrint("⚠️ Year parsing error: $e");
      }
    }

    // Update text controllers
    final controllersToUpdate = [
      "appointmentId",
      "inspectionCity",
      "city",
      "contactNumber",
      "registeredOwner",
      "ieName",
      "emailAddress",
      "make",
      "model",
      "variant",
      "registrationNumber",
      "registeredAddressAsPerRc",
      "odometerReadingBeforeTestDrive",
      "odometerReadingInKms",
      "registrationDate",
    ];

    for (final key in controllersToUpdate) {
      if (_tcs.containsKey(key)) {
        _pushToController(key);
      }
    }

    _ensureMirrors(silent: true);
    touch();
  }

  String getString(String key, {String def = "N/A"}) {
    final v = data[key];
    if (v == null) return def;
    final s = v.toString();
    return s.isEmpty ? def : s;
  }

  String getText(String key) {
    final s = getString(key, def: "");
    if (s.trim().toUpperCase() == "N/A") return "";
    return s;
  }

  int getInt(String key, {int def = 0}) {
    final v = data[key];
    if (v == null) return def;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? def;
  }

  DateTime? getDate(String key) {
    final v = data[key];
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  List<String> getList(String key) {
    final v = data[key];
    if (v == null) return <String>[];
    if (v is List) {
      return v
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    if (v is String && v.trim().isNotEmpty) return <String>[v.trim()];
    return <String>[];
  }

  void setString(
    String key,
    String value, {
    bool silent = false,
    bool force = false,
  }) {
    if (isLocked(key) && !force) return;

    _withSync(() {
      data[key] = value;
      _syncOnSetString(key, value);
    });
    _pushToController(key);

    _autoSaveField(key, value);

    if (!silent) touch();
  }

  void setInt(
    String key,
    int value, {
    bool silent = false,
    bool force = false,
  }) {
    if (isLocked(key) && !force) return;

    _withSync(() {
      data[key] = value;
      _syncOnSetInt(key, value);
    });
    _pushToController(key);

    _autoSaveField(key, value);

    if (!silent) touch();
  }

  void setDate(
    String key,
    DateTime? value, {
    bool silent = false,
    bool force = false,
  }) {
    if (isLocked(key) && !force) return;

    _withSync(() {
      data[key] = value;
      _syncOnSetDate(key, value);
    });

    _autoSaveField(key, value);

    if (!silent) touch();
  }

  void setList(
    String key,
    List<String> value, {
    bool silent = false,
    bool force = false,
  }) {
    if (isLocked(key) && !force) return;

    _withSync(() {
      data[key] = value;
      _syncOnSetList(key, value);
    });

    _autoSaveField(key, value);

    if (!silent) touch();
  }

  void setSingleAsList(String key, String? value, {bool silent = false}) {
    final v = (value ?? "").trim();
    setList(key, v.isEmpty ? <String>[] : <String>[v], silent: silent);
  }

  String getFirstFromList(String key) {
    final list = getList(key);
    return list.isEmpty ? "" : list.first;
  }

  bool _syncing = false;

  void _withSync(void Function() fn) {
    if (_syncing) return fn();
    _syncing = true;
    try {
      fn();
    } finally {
      _syncing = false;
    }
  }

  Map<String, String> get _newToOldString => {
    for (final e in stringPair.entries) e.value: e.key,
  };

  Map<String, String> get _newToOldDate => {
    for (final e in datePair.entries) e.value: e.key,
  };

  Map<String, String> get _newToOldInt => {
    for (final e in intPair.entries) e.value: e.key,
  };

  Map<String, String> get _newToOldList => {
    for (final e in listPair.entries) e.value: e.key,
  };

  Map<String, String> get _dropdownNewToOld => {
    for (final e in stringToDropdownList.entries) e.value: e.key,
  };

  void _syncOnSetString(String key, String value) {
    if (stringPair.containsKey(key)) {
      final newKey = stringPair[key]!;
      data[newKey] = value;
      _pushToController(newKey);
    } else if (_newToOldString.containsKey(key)) {
      final oldKey = _newToOldString[key]!;
      data[oldKey] = value;
      _pushToController(oldKey);
    }

    if (stringToDropdownList.containsKey(key)) {
      final newListKey = stringToDropdownList[key]!;
      final v = value.trim();
      data[newListKey] = (v.isEmpty || v.toUpperCase() == "N/A")
          ? <String>[]
          : <String>[v];
    }

    if (key == oldRearBootOpen) {
      final v = value.trim();
      data[newRearBootOpen] = (v.isEmpty || v.toUpperCase() == "N/A")
          ? <String>[]
          : <String>[v];
    }

    if (key == oldLeather || key == oldFabric) {
      final v = value.trim();
      if (v.isNotEmpty && v.toUpperCase() != "N/A") {
        data[newSeatsUph] = v;
        _pushToController(newSeatsUph);
      }
    }
    if (key == newSeatsUph) {
      data[oldLeather] = value;
      data[oldFabric] = value;
      _pushToController(oldLeather);
      _pushToController(oldFabric);
    }

    if (key == oldSteeringMounted) {
      data[newSteeringMedia] = value;
      data[newSteeringSystem] = value;
      _pushToController(newSteeringMedia);
      _pushToController(newSteeringSystem);
    }
    if (key == newSteeringMedia || key == newSteeringSystem) {
      data[oldSteeringMounted] = value;
      _pushToController(oldSteeringMounted);
    }

    if (key == oldAcManual) data[newAcType] = value;
    if (key == oldAcClimate) data[newAcCooling] = value;
    if (key == newAcType) data[oldAcManual] = value;
    if (key == newAcCooling) data[oldAcClimate] = value;

    _pushToController(oldAcManual);
    _pushToController(oldAcClimate);
    _pushToController(newAcType);
    _pushToController(newAcCooling);
  }

  void _syncOnSetDate(String key, DateTime? value) {
    if (datePair.containsKey(key)) {
      data[datePair[key]!] = value;
    } else if (_newToOldDate.containsKey(key)) {
      data[_newToOldDate[key]!] = value;
    }
  }

  void _syncOnSetInt(String key, int value) {
    if (intPair.containsKey(key)) {
      data[intPair[key]!] = value;
      _pushToController(intPair[key]!);
    } else if (_newToOldInt.containsKey(key)) {
      data[_newToOldInt[key]!] = value;
      _pushToController(_newToOldInt[key]!);
    }
  }

  void _syncOnSetList(String key, List<String> value) {
    if (listPair.containsKey(key)) {
      data[listPair[key]!] = value;
    } else if (_newToOldList.containsKey(key)) {
      data[_newToOldList[key]!] = value;
    }

    if (_dropdownNewToOld.containsKey(key)) {
      final oldKey = _dropdownNewToOld[key]!;
      final commaString = _listToCommaString(value);
      data[oldKey] = commaString;
      _pushToController(oldKey);
    }

    if (key == newRearBootOpen) {
      final commaString = _listToCommaString(value);
      data[oldRearBootOpen] = commaString;
      _pushToController(oldRearBootOpen);
    }

    if (key == "infotainmentSystemDropdownList") {
      final commaString = _listToCommaString(value);
      data["musicSystem"] = commaString;
      data["stereo"] = commaString;
      _pushToController("musicSystem");
      _pushToController("stereo");
    }
  }

  void _ensureMirrors({bool silent = false}) {
    _withSync(() {
      for (final e in stringPair.entries) {
        final oldKey = e.key;
        final newKey = e.value;
        final oldVal = getString(oldKey, def: "");
        final newVal = getString(newKey, def: "");

        if ((newVal.isEmpty || newVal == "N/A") &&
            oldVal.isNotEmpty &&
            oldVal != "N/A") {
          data[newKey] = oldVal;
          _pushToController(newKey);
        }
        if ((oldVal.isEmpty || oldVal == "N/A") &&
            newVal.isNotEmpty &&
            newVal != "N/A") {
          data[oldKey] = newVal;
          _pushToController(oldKey);
        }
      }

      for (final e in datePair.entries) {
        final oldKey = e.key;
        final newKey = e.value;
        final od = getDate(oldKey);
        final nd = getDate(newKey);
        if (nd == null && od != null) data[newKey] = od;
        if (od == null && nd != null) data[oldKey] = nd;
      }

      for (final e in intPair.entries) {
        final oldKey = e.key;
        final newKey = e.value;
        final oi = getInt(oldKey, def: -999999);
        final ni = getInt(newKey, def: -999999);
        if (ni == -999999 && oi != -999999) {
          data[newKey] = oi;
          _pushToController(newKey);
        }
        if (oi == -999999 && ni != -999999) {
          data[oldKey] = ni;
          _pushToController(oldKey);
        }
      }

      for (final e in listPair.entries) {
        final oldKey = e.key;
        final newKey = e.value;
        final ol = getList(oldKey);
        final nl = getList(newKey);
        if (nl.isEmpty && ol.isNotEmpty) data[newKey] = ol;
        if (ol.isEmpty && nl.isNotEmpty) data[oldKey] = nl;
      }

      for (final e in stringToDropdownList.entries) {
        final oldKey = e.key;
        final newKey = e.value;
        final oldVal = getString(oldKey, def: "");
        final nl = getList(newKey);

        if (nl.isEmpty && oldVal.isNotEmpty && oldVal.toUpperCase() != "N/A") {
          data[newKey] = <String>[oldVal];
        }
        if ((oldVal.isEmpty || oldVal.toUpperCase() == "N/A") &&
            nl.isNotEmpty) {
          final commaString = _listToCommaString(nl);
          data[oldKey] = commaString;
          _pushToController(oldKey);
        }
      }

      final bootStr = getString(oldRearBootOpen, def: "").trim();
      final bootList = getList(newRearBootOpen);
      if (bootList.isEmpty &&
          bootStr.isNotEmpty &&
          bootStr.toUpperCase() != "N/A") {
        data[newRearBootOpen] = <String>[bootStr];
      }
      if ((bootStr.isEmpty || bootStr.toUpperCase() == "N/A") &&
          bootList.isNotEmpty) {
        final commaString = _listToCommaString(bootList);
        data[oldRearBootOpen] = commaString;
        _pushToController(oldRearBootOpen);
      }

      final seats = getString(newSeatsUph, def: "").trim();
      final leather = getString(oldLeather, def: "").trim();
      final fabric = getString(oldFabric, def: "").trim();
      if ((seats.isEmpty || seats == "N/A")) {
        final pick = (leather.isNotEmpty && leather != "N/A")
            ? leather
            : (fabric.isNotEmpty && fabric != "N/A")
            ? fabric
            : "";
        if (pick.isNotEmpty) {
          data[newSeatsUph] = pick;
          _pushToController(newSeatsUph);
        }
      } else {
        data[oldLeather] = seats;
        data[oldFabric] = seats;
        _pushToController(oldLeather);
        _pushToController(oldFabric);
      }

      final oldSteer = getString(oldSteeringMounted, def: "");
      final media = getString(newSteeringMedia, def: "");
      final sys = getString(newSteeringSystem, def: "");
      if ((media.isEmpty || media == "N/A") &&
          oldSteer.isNotEmpty &&
          oldSteer != "N/A") {
        data[newSteeringMedia] = oldSteer;
        _pushToController(newSteeringMedia);
      }
      if ((sys.isEmpty || sys == "N/A") &&
          oldSteer.isNotEmpty &&
          oldSteer != "N/A") {
        data[newSteeringSystem] = oldSteer;
        _pushToController(newSteeringSystem);
      }
      if ((oldSteer.isEmpty || oldSteer == "N/A") &&
          (media.isNotEmpty && media != "N/A")) {
        data[oldSteeringMounted] = media;
        _pushToController(oldSteeringMounted);
      }

      final acType = getString(newAcType, def: "");
      final acCool = getString(newAcCooling, def: "");
      if ((acType.isEmpty || acType == "N/A")) {
        final v = getString(oldAcManual, def: "");
        if (v.isNotEmpty && v != "N/A") data[newAcType] = v;
      } else {
        data[oldAcManual] = acType;
        _pushToController(oldAcManual);
      }
      if ((acCool.isEmpty || acCool == "N/A")) {
        final v = getString(oldAcClimate, def: "");
        if (v.isNotEmpty && v != "N/A") data[newAcCooling] = v;
      } else {
        data[oldAcClimate] = acCool;
        _pushToController(oldAcClimate);
      }
    });

    if (!silent) touch();
  }

  void goPrev() {
    if (currentStep.value > 0) {
      currentStep.value--;
      touch();
    }
  }

  // Future<bool> goNextOrSubmit() async {
  //   final idx = currentStep.value;
  //   final isInteriorStep = idx == 7; // Interior Electronics Step
  //   final isReview = idx == steps.length - 1;

  //   // if (isReview) return false;

  //   // final fk = formKeys[idx];
  //   // final ok = fk.currentState?.validate() ?? true;
  //   // if (!ok) {
  //   //   ToastWidget.show(
  //   //     context: Get.context!,
  //   //     title: "Missing",
  //   //     subtitle: "Please complete required fields",
  //   //     type: ToastType.error,
  //   //   );
  //   //   return false;
  //   // }

  //   // ✅ MODIFICATION: When user reaches Interior step and clicks "Next", submit immediately
  //   if (isInteriorStep) {
  //     // Show loading state
  //     submitLoading.value = true;

  //     try {
  //       // Submit the data
  //       final submitted = await submit();

  //       if (submitted) {
  //         // On successful submit, go to Review step
  //         currentStep.value = steps.length - 1; // Review step
  //         ToastWidget.show(
  //           context: Get.context!,
  //           title: "Submitted Successfully",
  //           subtitle: "Inspection data has been submitted. Please review.",
  //           type: ToastType.success,
  //         );
  //         touch();
  //         return true;
  //       }
  //       return false;
  //     } catch (e) {
  //       ToastWidget.show(
  //         context: Get.context!,
  //         title: "Submission Failed",
  //         subtitle: e.toString(),
  //         type: ToastType.error,
  //       );
  //       return false;
  //     } finally {
  //       submitLoading.value = false;
  //     }
  //   }

  //   // Normal flow for other steps (not Interior)
  //   if (idx < steps.length - 2) {
  //     currentStep.value++;
  //     touch();
  //     return false;
  //   }

  //   // For TestDrive step (step 6) - proceed normally to Docs
  //   final submitted = await submit();
  //   if (submitted) {
  //     currentStep.value++;
  //     touch();
  //     return true;
  //   }

  //   return false;
  // }

  Future<bool> goNextOrSubmit({required String leadId}) async {
    print("=== NEXT/SUMIT CLICKED ===");
    print("Current step: ${currentStep.value}, Total steps: ${steps.length}");
    print("Form keys count: ${formKeys.length}");

    final idx = currentStep.value;
    final isTestDriveStep = idx == 6; // ✅ ONLY Test Drive is step index 6

    // For ALL steps EXCEPT Test Drive, just validate and go next
    if (!isTestDriveStep) {
      final fk = formKeys[idx];
      final ok = fk.currentState?.validate() ?? true;
      if (!ok) {
        ToastWidget.show(
          context: Get.context!,
          title: "Missing",
          subtitle: "Please complete required fields",
          type: ToastType.error,
        );
        return false;
      }

      // Go to next step
      if (idx < steps.length - 1) {
        currentStep.value++;
        touch();
      }
      return false;
    }

    if (isTestDriveStep) {
      submitLoading.value = true;

      try {
        final submitted = await submit(leadId: leadId);
        if (submitted) {
          Get.delete<CarInspectionStepperController>();
          Get.offAll(DashboardScreen());
          return true;
        }
        return false;
      } catch (e) {
        ToastWidget.show(
          context: Get.context!,
          title: "Submission Failed",
          subtitle: e.toString(),
          type: ToastType.error,
        );
        return false;
      } finally {
        submitLoading.value = false;
      }
    }

    return false;
  }

  Future<bool> submit({required String leadId}) async {
    try {
      submitLoading.value = true;

      _ensureMirrors(silent: true);

      printCompleteJson();

      final payload = _buildSubmitPayload();
      updateTelecallingInspected(
        telecallingId: leadId,
        inspectionDateTimeLocal: DateTime.now(),
        remarks: "This car is Inspected",
      );

      debugPrint("✅ SUBMIT PAYLOAD KEYS: ${payload.keys.length}");

      final submitted = await _submitToApi(payload);
      if (!submitted) {
        ToastWidget.show(
          context: Get.context!,
          title: "Submit Failed",
          subtitle: "Failed to submit data to server",
          type: ToastType.error,
        );
        return false;
      }

      final appt = getString("appointmentId", def: "").trim();
      if (appt.isNotEmpty && appt != "N/A") {
        await clearAllStorageForAppointment(appt);
        debugPrint("🧹 Local storage cleared for $appt");
      }

      ToastWidget.show(
        context: Get.context!,
        title: "Submitted",
        subtitle: "Inspection saved successfully.",
        type: ToastType.success,
      );

      return true;
    } catch (e) {
      ToastWidget.show(
        context: Get.context!,
        title: "Submit Failed",
        subtitle: e.toString(),
        type: ToastType.error,
      );
      return false;
    } finally {
      submitLoading.value = false;
    }
  }

  Future<bool> _submitToApi(Map<String, dynamic> payload) async {
    try {
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) return false;
      final token = await _getBearerToken();
      if (token.isEmpty) {
        _snackErr("Token missing (prefs key: token)");
        return false;
      }

      debugPrint("📤 SUBMITTING DATA TO API: ${payload.keys.length} keys");

      final response = await http.post(
        Uri.parse(submitCarInspectionUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );
      print(response.body);
      debugPrint("📡 API RESPONSE: ${response.statusCode} - ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint("✅ API SUBMIT SUCCESS");
        return true;
      } else {
        final error = _readErrorMessage(response);
        _snackErr("API Error: $error");
        return false;
      }
    } catch (e) {
      debugPrint("❌ API SUBMIT ERROR: $e");
      _snackErr("Submit failed: $e");
      return false;
    }
  }

  Map<String, dynamic> _buildSubmitPayload() {
    final out = <String, dynamic>{};
    data.forEach((k, v) {
      if (v is DateTime) {
        out[k] = v.toUtc().toIso8601String();
      } else if (v is List) {
        out[k] = v.map((e) => e.toString()).toList();
      } else if (k.contains('Video') || k.endsWith('Video')) {
        final videoUrl = getString(k, def: "");
        out[k] = videoUrl != "N/A" ? videoUrl : "";
      } else {
        out[k] = v;
      }
    });

    _ensureMirrors(silent: true);
    return out;
  }

  Future<void> fetchRcAdvancedAndFill() async {
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) return;

    final reg = getString("registrationNumber", def: "").trim();
    if (reg.isEmpty) {
      ToastWidget.show(
        context: Get.context!,
        title: "Missing",
        subtitle: "Please enter Registration Number first",
        type: ToastType.error,
      );
      return;
    }

    rcFetchLoading.value = true;

    try {
      final url = Uri.parse('https://api.attestr.com/api/v2/public/checkx/rc');

      // final body = {"reg": reg};

      const basicAuthToken =
          "Basic T1gwSU5zYU10U09MQmFwR0RjLjJmMzkyMjJmZWM3ODgwZjczZjVjYTBhNGZlN2E2OTM4OmIwYmM2MzZiNWU2NTJiNjU2OGIyNGZlOTE5Y2Q3MThkMjgwMWMyYmJkMzY2ZjQxZg==";

      final headers = <String, String>{
        "Content-Type": "application/json",
        "Authorization": basicAuthToken,
      };

      final res = await http.post(
        url,
        headers: headers,
        // body: jsonEncode(body),
      );

      // 🔴 HANDLE API ERRORS HERE
      if (res.statusCode < 200 || res.statusCode >= 300) {
        String apiMessage = "Something went wrong";

        try {
          final errorBody = jsonDecode(res.body);
          if (errorBody is Map && errorBody["message"] != null) {
            apiMessage = errorBody["message"].toString();
          }
        } catch (_) {}

        ToastWidget.show(
          context: Get.context!,
          title: "Error",
          subtitle: "Server Error in Attesterapi",
          type: ToastType.error,
        );

        return; // ⛔ Stop further execution
      }

      // ✅ SUCCESS RESPONSE
      final decodedAny = jsonDecode(res.body);

      if (decodedAny is! Map<String, dynamic>) {
        throw Exception("Invalid response: expected Map");
      }

      Map<String, dynamic> result;
      final r = decodedAny["result"];
      if (r is Map) {
        result = Map<String, dynamic>.from(r as Map);
      } else {
        result = decodedAny;
      }

      _applyPerfiosRcResultToData(result);
      _ensureMirrors(silent: true);

      await _saveApiDataToStorage();

      final affectedKeys = [
        "registrationNumber",
        "make",
        "model",
        "variant",
        "engineNumber",
        "chassisNumber",
        "registeredOwner",
        "registeredAddressAsPerRc",
        "registrationState",
        "registrationCity",
        "registeredRto",
        "fuelType",
        "policyNumber",
        "insurancePolicyNumber",
        "cubicCapacity",
        "seatingCapacity",
        "ownerSerialNumber",
        "color",
        "blacklistStatus",
        "insurer",
        "norms",
        "numberOfCylinders",
        "hypothecatedTo",
      ];

      for (final key in affectedKeys) {
        _pushToController(key);
      }

      touch();
    } catch (e) {
      ToastWidget.show(
        context: Get.context!,
        title: "Error",
        subtitle: "Unexpected error occurred",
        type: ToastType.error,
      );
    } finally {
      rcFetchLoading.value = false;
    }
  }

  Future<void> _saveApiDataToStorage() async {
    final appt = getString("appointmentId", def: "").trim();
    if (appt.isEmpty || appt == "N/A") {
      debugPrint("❌ No appointment ID for saving API data");
      return;
    }

    try {
      debugPrint("💾 Saving API data to storage for appointment: $appt");

      final apiFields = [
        "make",
        "model",
        "variant",
        "engineNumber",
        "chassisNumber",
        "registeredOwner",
        "registeredAddressAsPerRc",
        "registrationState",
        "registrationCity",
        "registeredRto",
        "fuelType",
        "policyNumber",
        "insurancePolicyNumber",
        "color",
        "norms",
        "insurer",
        "rcStatus",
        "pucNumber",
        "registrationDate",
        "fitnessValidity",
        "insuranceValidity",
        "taxValidTill",
        "yearAndMonthOfManufacture",
        "cubicCapacity",
        "seatingCapacity",
        "ownerSerialNumber",
        "numberOfCylinders",
        "blacklistStatus",
        "hypothecatedTo",
      ];

      for (final field in apiFields) {
        final value = data[field];
        if (value != null) {
          await _saveFieldToStorage(
            appointmentId: appt,
            fieldKey: field,
            value: value,
          );
          debugPrint("  💾 Saved: $field = $value");
        }
      }

      debugPrint("✅ All API data saved successfully to storage");
    } catch (e) {
      debugPrint("❌ Error saving API data to storage: $e");
    }
  }

  void _applyPerfiosRcResultToData(Map<String, dynamic> r) {
    debugPrint("🔑 ============ RC API RESPONSE DATA ============");
    debugPrint("🔑 Total keys in response: ${r.keys.length}");

    r.forEach((key, value) {
      if (value != null) {
        debugPrint("  📌 $key: $value (type: ${value.runtimeType})");
      }
    });

    debugPrint("🔑 ==============================================");

    // Registration Date
    final regDateRaw = r["registered"];
    final registrationDate =
        _parseApiDate(regDateRaw) ?? getDate("registrationDate");
    setAndLockDate("registrationDate", registrationDate, silent: true);

    // Fitness Validity
    final fitnessRaw = r["fitnessUpto"];
    final fitnessValidity =
        _parseApiDate(fitnessRaw) ?? getDate("fitnessValidity");
    setAndLockDate("fitnessValidity", fitnessValidity, silent: true);
    lockKey("fitnessTill");

    // Insurance Validity
    final insuranceRaw = r["insuranceUpto"];
    final insuranceValidity =
        _parseApiDate(insuranceRaw) ?? getDate("insuranceValidity");
    setAndLockDate("insuranceValidity", insuranceValidity, silent: true);

    // Tax Validity
    final taxRaw = r["taxPaidUpto"];
    final taxValidTill = _parseApiDate(taxRaw) ?? getDate("taxValidTill");
    setAndLockDate("taxValidTill", taxValidTill, silent: true);

    // Manufacture Year/Month
    final manufactureRaw = r["manufactured"];
    final yearMonthOfManufacture =
        _parseMonthYearSlash(manufactureRaw) ??
        getDate("yearAndMonthOfManufacture");
    setAndLockDate(
      "yearAndMonthOfManufacture",
      yearMonthOfManufacture,
      silent: true,
    );
    lockKey("yearMonthOfManufacture");

    // RC Status
    final rcStatus = (r["status"] ?? "").toString().trim();
    if (rcStatus.isNotEmpty) {
      setAndLockString("rcStatus", rcStatus, silent: true);
    }

    // PUC Number
    final pucNumber = (r["pollutionCertificateNumber"] ?? "").toString().trim();
    if (pucNumber.isNotEmpty) {
      setAndLockString("pucNumber", pucNumber, silent: true);
    }

    // PUC Validity
    final pucValidityRaw = r["pollutionCertificateUpto"];
    final pucValidity = _parseApiDate(pucValidityRaw);
    if (pucValidity != null) {
      setAndLockDate("pucValidity", pucValidity, silent: true);
    }

    // Chassis Number
    final ch = (r["chassisNumber"] ?? "").toString().trim();
    if (ch.isNotEmpty) {
      setAndLockString("chassisNumber", ch, silent: true);
    }

    // Engine Number
    final en = (r["engineNumber"] ?? "").toString().trim();
    if (en.isNotEmpty) {
      setAndLockString("engineNumber", en, silent: true);
    }

    // Fuel Type
    final fuel = (r["fuelType"] ?? "").toString().trim();
    if (fuel.isNotEmpty) {
      setAndLockString("fuelType", fuel, silent: true);
    }

    // Color
    final color = (r["colorType"] ?? "").toString().trim();
    if (color.isNotEmpty) {
      setAndLockString("color", color, silent: true);
    }

    // Norms
    final norms = (r["normsType"] ?? "").toString().trim();
    if (norms.isNotEmpty) {
      setAndLockString("norms", norms, silent: true);
    }

    // Insurer
    final insurer = (r["insuranceProvider"] ?? "").toString().trim();
    if (insurer.isNotEmpty) {
      setAndLockString("insurer", insurer, silent: true);
    }

    // RTO
    final rto = (r["rto"] ?? "").toString().trim();
    if (rto.isNotEmpty) {
      setAndLockString("registeredRto", rto, silent: true);
    }

    // Registered Owner
    final owner = (r["owner"] ?? "").toString().trim();
    if (owner.isNotEmpty) {
      setAndLockString("registeredOwner", owner, silent: true);
    }

    // Policy Number
    final pol = (r["insurancePolicyNumber"] ?? "").toString().trim();
    if (pol.isNotEmpty) {
      setAndLockString("policyNumber", pol, silent: true);
      setAndLockString("insurancePolicyNumber", pol, silent: true);
    }

    // Blacklist Status
    final bl = r["blacklistStatus"];
    final blText = (bl == null) ? "N/A" : bl.toString().trim();
    setAndLockString(
      "blacklistStatus",
      blText.isEmpty ? "N/A" : blText,
      silent: true,
    );

    // Owner Serial Number
    final ownerNumber = r["ownerNumber"];
    if (ownerNumber != null) {
      int ownerSerialValue = 0;

      if (ownerNumber is int) {
        ownerSerialValue = ownerNumber;
      } else if (ownerNumber is String) {
        String cleaned = ownerNumber.replaceAll(RegExp(r'[^0-9]'), '').trim();
        if (cleaned.isNotEmpty) {
          ownerSerialValue = int.tryParse(cleaned) ?? 0;
        }
      } else if (ownerNumber is double) {
        ownerSerialValue = ownerNumber.toInt();
      } else {
        try {
          ownerSerialValue = int.parse(ownerNumber.toString());
        } catch (e) {
          ownerSerialValue = 0;
        }
      }

      setInt("ownerSerialNumber", ownerSerialValue, silent: true, force: true);
      data["ownerSerialNumber"] = ownerSerialValue;

      if (_tcs.containsKey("ownerSerialNumber")) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pushToController("ownerSerialNumber");
        });
      }
    }

    // Hypothecated To
    String lender = "";

    if (r.containsKey("lender") && r["lender"] != null) {
      lender = r["lender"].toString().trim();
    } else if (r.containsKey("lenderName") && r["lenderName"] != null) {
      lender = r["lenderName"].toString().trim();
    } else if (r.containsKey("financier") && r["financier"] != null) {
      lender = r["financier"].toString().trim();
    } else if (r.containsKey("hypothecation") && r["hypothecation"] != null) {
      lender = r["hypothecation"].toString().trim();
    } else if (r.containsKey("hypothecatedTo") && r["hypothecatedTo"] != null) {
      lender = r["hypothecatedTo"].toString().trim();
    }

    if (lender.isNotEmpty) {
      setAndLockString("hypothecatedTo", lender, silent: true);
    } else {
      setAndLockString("hypothecatedTo", "N/A", silent: true);
    }

    // Cubic Capacity
    final ccRaw = r["cubicCapacity"];
    final currentCc = getInt("cubicCapacity");
    final parsedCc = _parseCc(ccRaw, fallback: currentCc);
    setAndLockInt("cubicCapacity", parsedCc, silent: true);

    // Number of Cylinders
    final cylindersRaw = r["cylinders"];
    final currentCylinders = getInt("numberOfCylinders");
    final parsedCylinders = _parseInt(cylindersRaw, fallback: currentCylinders);
    setAndLockInt("numberOfCylinders", parsedCylinders, silent: true);

    // Seating Capacity
    final seatingRaw = r["seatingCapacity"];
    final currentSeating = getInt("seatingCapacity");
    final parsedSeating = _parseInt(seatingRaw, fallback: currentSeating);
    setAndLockInt("seatingCapacity", parsedSeating, silent: true);

    _ensureMirrors(silent: true);
  }

  DateTime? _parseApiDate(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;

    try {
      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(s)) {
        final parts = s.split('-');
        final dd = int.parse(parts[0]);
        final mm = int.parse(parts[1]);
        final yy = int.parse(parts[2]);
        return DateTime(yy, mm, dd);
      }

      if (RegExp(r'^\d{2}-\d{4}$').hasMatch(s)) {
        final parts = s.split('-');
        final mm = int.parse(parts[0]);
        final yy = int.parse(parts[1]);
        return DateTime(yy, mm, 1);
      }

      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
        return DateTime.parse(s);
      }

      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(s)) {
        final parts = s.split('/');
        final dd = int.parse(parts[0]);
        final mm = int.parse(parts[1]);
        final yy = int.parse(parts[2]);
        return DateTime(yy, mm, dd);
      }

      if (RegExp(r'^\d{2}/\d{4}$').hasMatch(s)) {
        final parts = s.split('/');
        final mm = int.parse(parts[0]);
        final yy = int.parse(parts[1]);
        return DateTime(yy, mm, 1);
      }

      return DateTime.tryParse(s);
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseMonthYearSlash(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;

    try {
      if (RegExp(r'^\d{2}/\d{4}$').hasMatch(s)) {
        final parts = s.split('/');
        final mm = int.parse(parts[0]);
        final yy = int.parse(parts[1]);
        return DateTime(yy, mm, 1);
      }

      if (RegExp(r'^\d{2}-\d{4}$').hasMatch(s)) {
        final parts = s.split('-');
        final mm = int.parse(parts[0]);
        final yy = int.parse(parts[1]);
        return DateTime(yy, mm, 1);
      }

      if (RegExp(r'^\d{4}-\d{2}$').hasMatch(s)) {
        final parts = s.split('-');
        final yy = int.parse(parts[0]);
        final mm = int.parse(parts[1]);
        return DateTime(yy, mm, 1);
      }
    } catch (_) {}
    return null;
  }

  int _parseInt(dynamic v, {required int fallback}) {
    if (v == null) return fallback;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fallback;
  }

  int _parseCc(dynamic v, {required int fallback}) {
    if (v == null) return fallback;
    if (v is int) return v;
    final s = v.toString().trim();
    final d = double.tryParse(s);
    if (d == null) return int.tryParse(s) ?? fallback;
    return d.toInt();
  }

  Future<String> _getChangedById() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('id') ?? '').trim();
  }

  Future<String> _getBearerToken() async {
    final token = (await SharedPrefsHelper.getString("token") ?? "").trim();
    return token;
  }

  Future<bool> updateTelecallingRunning({
    required String telecallingId,
    required DateTime inspectionDateTimeLocal,
    required String remarks,
  }) async {
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) return false;
    final id = telecallingId.trim();
    final note = remarks.trim();

    if (id.isEmpty) {
      _snackErr("Lead id missing");
      return false;
    }
    if (note.isEmpty) {
      _snackErr("Remarks are required");
      return false;
    }

    final changedBy = await _getChangedById();
    if (changedBy.isEmpty) {
      _snackErr("User id missing in local storage (prefs key: id)");
      return false;
    }

    try {
      final url = Uri.parse(updateTelecallingUrl);

      final payload = <String, dynamic>{
        "telecallingId": id,
        "changedBy": changedBy,
        "source": "Inspection Engineer",
        "inspectionStatus": "Running",
        "inspectionDateTime": inspectionDateTimeLocal.toUtc().toIso8601String(),
        "remarks": note,
      };

      final token = await _getBearerToken();
      if (token.isEmpty) {
        _snackErr("Token missing (prefs key: token)");
        return false;
      }

      final res = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        await getInspectionList();
        return true;
      }

      _snackErr(_readErrorMessage(res));
      return false;
    } catch (e) {
      _snackErr("Exception: $e");
      return false;
    }
  }

  Future<bool> updateTelecallingInspected({
    required String telecallingId,
    required DateTime inspectionDateTimeLocal,
    required String remarks,
  }) async {
    final id = telecallingId.trim();
    final note = remarks.trim();

    if (id.isEmpty) {
      _snackErr("Lead id missing");
      return false;
    }
    if (note.isEmpty) {
      _snackErr("Remarks are required");
      return false;
    }

    final changedBy = await _getChangedById();
    if (changedBy.isEmpty) {
      _snackErr("User id missing in local storage (prefs key: id)");
      return false;
    }

    try {
      final url = Uri.parse(updateTelecallingUrl);

      final payload = <String, dynamic>{
        "telecallingId": id,
        "changedBy": changedBy,
        "source": "Inspection Engineer",
        "inspectionStatus": "Inspected",
        "inspectionDateTime": inspectionDateTimeLocal.toUtc().toIso8601String(),
        "remarks": note,
      };
      print("telecalling payload  $payload");
      final token = await _getBearerToken();
      if (token.isEmpty) {
        _snackErr("Token missing (prefs key: token)");
        return false;
      }

      final res = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },

        body: jsonEncode(payload),
      );
      print("telecalling response ${res.body}");

      if (res.statusCode >= 200 && res.statusCode < 300) {
        await getInspectionList();
        return true;
      }

      _snackErr(_readErrorMessage(res));
      print(res);
      return false;
    } catch (e) {
      _snackErr("Exception: $e");
      print("error in inspection telecall $e");
      return false;
    }
  }

  Future<bool> updateTelecallingReschedule({
    required String telecallingId,
    required DateTime inspectionDateTimeLocal,
    required String remarks,
  }) async {
    final id = telecallingId.trim();
    final note = remarks.trim();

    if (id.isEmpty) {
      _snackErr("Lead id missing");
      return false;
    }
    if (note.isEmpty) {
      _snackErr("Remarks are required");
      return false;
    }

    final changedBy = await _getChangedById();
    if (changedBy.isEmpty) {
      _snackErr("User id missing in local storage (prefs key: id)");
      return false;
    }

    try {
      final url = Uri.parse(updateTelecallingUrl);

      final payload = <String, dynamic>{
        "telecallingId": id,
        "changedBy": changedBy,
        "source": "Inspection Engineer",
        "inspectionStatus": "Re-Scheduled",
        "inspectionDateTime": inspectionDateTimeLocal.toUtc().toIso8601String(),
        "remarks": note,
      };

      final token = await _getBearerToken();
      if (token.isEmpty) {
        _snackErr("Token missing (prefs key: token)");
        return false;
      }

      final res = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode >= 200 || res.statusCode < 300) {
        await getInspectionList();
        return true;
      }

      _snackErr(_readErrorMessage(res));
      return false;
    } catch (e) {
      _snackErr("Exception: $e");
      return false;
    }
  }

  Future<bool> updateTelecallingCancel({
    required String telecallingId,
    required String remarks,
  }) async {
    final id = telecallingId.trim();
    final note = remarks.trim();

    if (id.isEmpty) {
      _snackErr("Lead id missing");
      return false;
    }
    if (note.isEmpty) {
      _snackErr("Remarks are required");
      return false;
    }

    final changedBy = await _getChangedById();
    if (changedBy.isEmpty) {
      _snackErr("User id missing in local storage (prefs key: id)");
      return false;
    }

    try {
      final url = Uri.parse(updateTelecallingUrl);

      final payload = <String, dynamic>{
        "telecallingId": id,
        "changedBy": changedBy,
        "source": "Inspection Engineer",
        "inspectionStatus": "Canceled",
        "remarks": note,
      };

      final token = await _getBearerToken();
      if (token.isEmpty) {
        _snackErr("Token missing (prefs key: token)");
        return false;
      }

      final res = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        await getInspectionList();
        return true;
      }

      _snackErr(_readErrorMessage(res));
      return false;
    } catch (e) {
      _snackErr("Exception: $e");
      return false;
    }
  }

  String _readErrorMessage(http.Response res) {
    String msg = "Failed (${res.statusCode})";
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map && decoded["message"] != null) {
        msg = decoded["message"].toString();
      } else {
        msg = res.body.toString();
      }
    } catch (_) {
      msg = res.body.toString();
    }
    return msg;
  }

  void _snackErr(String msg) {
    Get.showSnackbar(
      GetSnackBar(
        message: msg,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
      ),
    );
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

  Future<void> getInspectionList() async {
    try {
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) return;

      final phoneNumber = await SharedPrefsHelper.getString(
        SharedPrefsHelper.phoneNumberKey,
      );
      isLoading.value = true;

      final token = await _getBearerToken();
      if (token.isEmpty) {
        ToastWidget.show(
          context: Get.context!,
          title: "Error",
          subtitle: "Token missing (prefs key: token)",
          type: ToastType.error,
        );
        return;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"inspectionEngineerNumber": phoneNumber}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print(decoded);

        if (decoded is! Map<String, dynamic>) {
          throw Exception("Unexpected response shape: expected Map");
        }

        final rawList = decoded["data"];

        if (rawList is! List) {
          throw Exception("Unexpected data shape: expected List in 'data'");
        }

        final leads = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => LeadsData.fromJson(e))
            .toList();

        inspectionList
          ..clear()
          ..addAll(leads);

        touch();
      } else {
        ToastWidget.show(
          context: Get.context!,
          title: "Error",
          subtitle: "Failed to load data (${response.statusCode})",
          type: ToastType.error,
        );
      }
    } catch (e) {
      ToastWidget.show(
        context: Get.context!,
        title: "Exception",
        subtitle: e.toString(),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  static const List<String> _allExteriorDropdownKeys = [
    "bonnetDropdownList",
    "frontWindshieldDropdownList",
    "roofDropdownList",
    "frontBumperDropdownList",
    "lhsHeadlampDropdownList",
    "lhsFoglampDropdownList",
    "rhsHeadlampDropdownList",
    "rhsFoglampDropdownList",
    "lhsFenderDropdownList",
    "lhsOrvmDropdownList",
    "lhsAPillarDropdownList",
    "lhsBPillarDropdownList",
    "lhsCPillarDropdownList",
    "lhsFrontWheelDropdownList",
    "lhsFrontTyreDropdownList",
    "lhsRearWheelDropdownList",
    "lhsRearTyreDropdownList",
    "lhsFrontDoorDropdownList",
    "lhsRearDoorDropdownList",
    "lhsRunningBorderDropdownList",
    "lhsQuarterPanelDropdownList",
    "rearBumperDropdownList",
    "lhsTailLampDropdownList",
    "rhsTailLampDropdownList",
    "rearWindshieldDropdownList",
    "bootDoorDropdownList",
    "spareTyreDropdownList",
    "bootFloorDropdownList",
    "rhsRearWheelDropdownList",
    "rhsRearTyreDropdownList",
    "rhsFrontWheelDropdownList",
    "rhsFrontTyreDropdownList",
    "rhsQuarterPanelDropdownList",
    "rhsAPillarDropdownList",
    "rhsBPillarDropdownList",
    "rhsCPillarDropdownList",
    "rhsRunningBorderDropdownList",
    "rhsRearDoorDropdownList",
    "rhsFrontDoorDropdownList",
    "rhsOrvmDropdownList",
    "rhsFenderDropdownList",
    "lhsRearFogLampDropdownList",
    "rhsRearFogLampDropdownList",
    "rearWiperWasherDropdownList",
    "rearDefoggerDropdownList",
    "commentsOnExteriorDropdownList",
    "spareWheelDropdownList",
    "frontWiperAndWasherDropdownList",
  ];

  static const List<String> _allExteriorImageKeys = [
    "frontMainImages",
    "bonnetClosedImages",
    "bonnetOpenImages",
    "bonnetImages",
    "frontBumperLhs45DegreeImages",
    "frontBumperRhs45DegreeImages",
    "frontBumperImages",
    "frontWindshieldImages",
    "roofImages",
    "lhsHeadlampImages",
    "lhsFoglampImages",
    "rhsHeadlampImages",
    "rhsFoglampImages",
    "lhsFullViewImages",
    "lhsFenderImages",
    "lhsFrontWheelImages",
    "lhsFrontTyreImages",
    "lhsRunningBorderImages",
    "lhsOrvmImages",
    "lhsAPillarImages",
    "lhsFrontDoorImages",
    "lhsBPillarImages",
    "lhsRearDoorImages",
    "lhsCPillarImages",
    "lhsRearTyreImages",
    "lhsRearWheelImages",
    "lhsQuarterPanelWithRearDoorOpenImages",
    "lhsQuarterPanelImages",
    "rearMainImages",
    "rearWithBootDoorOpenImages",
    "rearBumperLhs45DegreeImages",
    "rearBumperRhs45DegreeImages",
    "rearBumperImages",
    "lhsTailLampImages",
    "rhsTailLampImages",
    "rearWindshieldImages",
    "lhsRearFogLampImages",
    "rhsRearFogLampImages",
    "spareTyreImages",
    "spareWheelImages",
    "bootFloorImages",
    "rhsFullViewImages",
    "rhsQuarterPanelWithRearDoorOpenImages",
    "rhsQuarterPanelImages",
    "rhsRearWheelImages",
    "rhsRearTyreImages",
    "rhsCPillarImages",
    "rhsRearDoorImages",
    "rhsBPillarImages",
    "rhsFrontDoorImages",
    "rhsAPillarImages",
    "rhsRunningBorderImages",
    "rhsFrontWheelImages",
    "rhsFrontTyreImages",
    "rhsOrvmImages",
    "rhsFenderImages",
    "frontWiperAndWasherImages",
    "rearWiperAndWasherImages",
    "reverseCameraImages",
  ];

  static const List<String> _allEngineDropdownKeys = [
    "upperCrossMemberDropdownList",
    "radiatorSupportDropdownList",
    "headlightSupportDropdownList",
    "lowerCrossMemberDropdownList",
    "lhsApronDropdownList",
    "rhsApronDropdownList",
    "firewallDropdownList",
    "cowlTopDropdownList",
    "engineDropdownList",
    "batteryDropdownList",
    "coolantDropdownList",
    "engineOilLevelDipstickDropdownList",
    "engineOilDropdownList",
    "engineMountDropdownList",
    "enginePermisableBlowByDropdownList",
    "exhaustSmokeDropdownList",
    "clutchDropdownList",
    "gearShiftDropdownList",
    "commentsOnEngineDropdownList",
    "commentsOnEngineOilDropdownList",
    "commentsOnTowingDropdownList",
    "commentsOnTransmissionDropdownList",
    "commentsOnRadiatorDropdownList",
    "commentsOnOthersDropdownList",
    "lhsSideMemberDropdownList",
    "rhsSideMemberDropdownList",
  ];

  static const List<String> _allEngineImageKeys = [
    "engineBayImages",
    "lhsApronImages",
    "rhsApronImages",
    "cowlTopImages",
    "firewallImages",
    "additionalEngineImages",
  ];

  static const List<String> _allInteriorDropdownKeys = [
    "infotainmentSystemDropdownList",
    "rhsFrontDoorFeaturesDropdownList",
    "lhsFrontDoorFeaturesDropdownList",
    "rhsRearDoorFeaturesDropdownList",
    "lhsRearDoorFeaturesDropdownList",
    "commentOnInteriorDropdownList",
    "sunroofDropdownList",
    "dashboardDropdownList",
    "reverseCameraDropdownList",
    "driverSeatDropdownList",
    "coDriverSeatDropdownList",
    "frontCentreArmRestDropdownList",
    "rearSeatsDropdownList",
    "thirdRowSeatsDropdownList",
  ];

  static const List<String> _allInteriorImageKeys = [
    "meterConsoleWithEngineOnImages",
    "airbagImages",
    "frontSeatsFromDriverSideImages",
    "rearSeatsFromRightSideImages",
    "dashboardImages",
    "acImages",
    "additionalInteriorImages",
  ];

  static const List<String> _allMechanicalDropdownKeys = [
    "steeringDropdownList",
    "brakesDropdownList",
    "suspensionDropdownList",
    "transmissionTypeDropdownList",
    "driveTrainDropdownList",
    "commentsOnClusterMeterDropdownList",
  ];

  // =====================================================
  // ✅ VIDEO SUPPORT
  // =====================================================
  final RxMap<String, String?> localPickedVideos = <String, String?>{}.obs;

  String? getLocalVideo(String fieldKey) => localPickedVideos[fieldKey];

  // Update setLocalVideo method
  Future<void> setLocalVideo(String fieldKey, String? videoPath) async {
    localPickedVideos[fieldKey] = videoPath;

    // ✅ Save to local storage with appointment ID
    await saveLocalVideoToStorage(fieldKey, videoPath);

    final appt = getString("appointmentId", def: "").trim();
    if (appt.isNotEmpty && appt.toUpperCase() != "N/A") {
      await _saveFieldToStorage(
        appointmentId: appt,
        fieldKey: "${fieldKey}__local",
        value: videoPath ?? "",
      );
    }

    touch();

    // ✅ NEW: Auto-upload video immediately after selection
    if (videoPath != null &&
        videoPath.isNotEmpty &&
        !videoPath.startsWith('http://') &&
        !videoPath.startsWith('https://')) {
      // Wait for UI to update
      await Future.delayed(const Duration(milliseconds: 500));
      await uploadVideoForField(fieldKey);
    }
  }

  // Add removeVideo method
  Future<void> removeVideo(String fieldKey) async {
    try {
      final currentVideo = getLocalVideo(fieldKey);
      final uploadedUrl = getString(fieldKey, def: "");

      // Delete from Cloudinary if uploaded
      if (uploadedUrl.isNotEmpty && uploadedUrl != "N/A") {
        final deleted = await deleteMediaFromCloudinary(
          mediaUrl: uploadedUrl,
          fieldKey: fieldKey,
        );
      }

      // Clear local and uploaded data
      localPickedVideos.remove(fieldKey);
      setString(fieldKey, "", silent: true, force: true);

      ToastWidget.show(
        context: Get.context!,
        title: "Removed",
        subtitle: "Video removed successfully",
        type: ToastType.success,
      );

      touch();
    } catch (e) {
      _snackErr("Error removing video: $e");
    }
  }

  bool isVideoUploaded(String fieldKey) {
    final v = getString(fieldKey, def: "").trim();

    if (v.isEmpty || v == "N/A") return false;

    return v.startsWith("http://") || v.startsWith("https://");
  }

  Future<Duration?> getVideoDuration(String videoPath) async {
    try {
      final controller = VideoPlayerController.file(File(videoPath));
      await controller.initialize();
      final duration = controller.value.duration;
      await controller.dispose();
      return duration;
    } catch (e) {
      debugPrint("❌ Duration check error: $e");
      return null;
    }
  }

  Future<String?> uploadVideoForField(String fieldKey) async {
    final appt = getString("appointmentId", def: "").trim();
    if (appt.isEmpty || appt.toUpperCase() == "N/A") {
      _snackErr("Appointment ID is missing. Please apply a lead first.");
      return null;
    }

    final localPath = getLocalVideo(fieldKey);
    if (localPath == null || localPath.isEmpty) {
      _snackErr("Please select a video for $fieldKey first");
      return null;
    }

    final duration = await getVideoDuration(localPath);
    if (duration != null && duration.inSeconds > 60) {
      _snackErr(
        "Video duration (${duration.inSeconds}s) exceeds 60 second limit. "
        "Please select a shorter video.",
      );
      return null;
    }

    if (isFieldUploading(fieldKey)) return null;

    try {
      uploadingFields.add(fieldKey);
      touch();

      debugPrint("⬆️ VIDEO UPLOAD START: $fieldKey | appt: $appt");

      final videoUrl = await _uploadVideoToCloudinary(
        appointmentId: appt,
        localVideoPath: localPath,
        fieldKey: fieldKey,
      );

      if (videoUrl != null && videoUrl.isNotEmpty) {
        debugPrint("✅ VIDEO UPLOAD SUCCESS: $fieldKey | URL: $videoUrl");

        setString(fieldKey, videoUrl, silent: true, force: true);

        await _autoSaveField(fieldKey, videoUrl);

        ToastWidget.show(
          context: Get.context!,
          title: "Uploaded",
          subtitle: "Video uploaded successfully",
          type: ToastType.success,
        );

        touch();
        return videoUrl;
      } else {
        _snackErr("Video upload failed: No URL returned");
        return null;
      }
    } catch (e) {
      _snackErr("Video upload failed: $e");
      debugPrint("❌ VIDEO UPLOAD FAILED: $fieldKey | $e");
      return null;
    } finally {
      uploadingFields.remove(fieldKey);
      touch();
    }
  }

  Future<String?> _uploadVideoToCloudinary({
    required String appointmentId,
    required String localVideoPath,
    required String fieldKey,
  }) async {
    try {
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) return null;
      final uri = Uri.parse(uploadCarVideoUrl);
      final req = http.MultipartRequest('POST', uri);

      req.fields['appointmentId'] = appointmentId;
      req.fields['fieldKey'] = fieldKey;

      final token = await _getBearerToken();
      if (token.isEmpty) {
        throw Exception("Token missing (prefs key: token)");
      }
      req.headers['Authorization'] = "Bearer $token";

      final videoFile = File(localVideoPath);
      if (!videoFile.existsSync()) {
        throw Exception("Video file not found: $localVideoPath");
      }

      req.files.add(await http.MultipartFile.fromPath('video', localVideoPath));

      final streamed = await req.send();
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        throw Exception("HTTP ${streamed.statusCode}: $body");
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid response");
      }

      final ok = decoded["success"] == true;
      if (!ok) {
        throw Exception(decoded["message"]?.toString() ?? "Upload failed");
      }

      final videoUrl = (decoded["optimizedUrl"] ?? decoded["originalUrl"] ?? "")
          .toString();

      if (videoUrl.isEmpty) {
        throw Exception(
          "No video URL returned (expected optimizedUrl/originalUrl)",
        );
      }

      return videoUrl;
    } catch (e) {
      debugPrint("❌ VIDEO UPLOAD ERROR: $e");
      rethrow;
    }
  }

  Future<void> pickVideoWithDurationCheck({
    required BuildContext context,
    required String fieldKey,
    required int maxDurationInSeconds,
  }) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        final fileSizeInMB = file.lengthSync() / (1024 * 1024);
        if (fileSizeInMB > 100) {
          _snackErr("Video file is too large (max 100MB)");
          return;
        }

        final duration = await getVideoDuration(pickedFile.path);
        if (duration != null && duration.inSeconds > maxDurationInSeconds) {
          _snackErr(
            "Video duration (${duration.inSeconds}s) exceeds "
            "maximum allowed ($maxDurationInSeconds seconds). "
            "Please select a shorter video.",
          );
          return;
        }

        setLocalVideo(fieldKey, pickedFile.path);

        ToastWidget.show(
          context: context,
          title: "Video Selected",
          subtitle: duration != null
              ? "Duration: ${duration.inSeconds}s (within limit)"
              : "Video selected",
          type: ToastType.success,
        );
      }
    } catch (e) {
      debugPrint("❌ Video pick error: $e");
      _snackErr("Error selecting video: $e");
    }
  }

  Future<void> recordVideoWithDurationLimit({
    required BuildContext context,
    required String fieldKey,
    required int maxDurationInSeconds,
  }) async {
    try {
      final picker = ImagePicker();
      final XFile? recordedFile = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(seconds: maxDurationInSeconds),
      );

      if (recordedFile != null) {
        final duration = await getVideoDuration(recordedFile.path);
        setLocalVideo(fieldKey, recordedFile.path);

        ToastWidget.show(
          context: context,
          title: "Video Recorded",
          subtitle: duration != null
              ? "Duration: ${duration.inSeconds}s"
              : "Video recorded",
          type: ToastType.success,
        );
      }
    } catch (e) {
      debugPrint("❌ Video record error: $e");
      _snackErr("Error recording video: $e");
    }
  }

  Future<Uint8List?> getVideoThumbnail(String videoPath) async {
    try {
      final file = File(videoPath);
      if (!file.existsSync()) return null;

      return null;
    } catch (e) {
      debugPrint("❌ THUMBNAIL ERROR: $e");
      return null;
    }
  }

  void clearVideoData(String fieldKey) {
    localPickedVideos.remove(fieldKey);
    setString(fieldKey, "", silent: true, force: true);
    touch();
  }
}
