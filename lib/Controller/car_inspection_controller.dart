// lib/Controller/car_inspection_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:otobix_inspection_app/models/car_model.dart';

class CarInspectionStepperController extends GetxController {
  final RxInt currentStep = 0.obs;

  final RxInt uiTick = 0.obs;
  void touch() => uiTick.value++;

  final RxBool rcFetchLoading = false.obs;

  late final CarModel carModel;
  late final List<GlobalKey<FormState>> formKeys;
  final makes = <String>[
    'Maruti',
    'Hyundai',
    'Tata',
    'Mahindra',
    'Honda',
    'Toyota',
    'Ford',
    'Jeep',
    'Renault',
    'Nissan',
  ];

  final models = <String>[
    'Cherokee',
    'Compass',
    'Grand Cherokee',
    'Kaiser',
    'Meridian',
    'Willys',
    'Wrangler',
  ];

  final variants = <String>['Limite 4x4', 'Limited Plus 4x4', 'Limited 4x4 S'];

  final List<Map<String, dynamic>> steps = const [
    {'title': 'Registration &\nDocuments', 'icon': Icons.description},
    {'title': 'Basic\nInformation', 'icon': Icons.directions_car},
    {'title': 'Exterior\nFront & Sides', 'icon': Icons.directions_car_filled},
    {'title': 'Exterior\nRear', 'icon': Icons.car_repair},
    {'title': 'Engine &\nMechanical', 'icon': Icons.settings},
    {'title': 'Interior &\nElectronics', 'icon': Icons.event_seat},
    {'title': 'Mechanical &\nTest Drive', 'icon': Icons.drive_eta},
    {'title': 'Final\nDetails', 'icon': Icons.fact_check},
    {'title': 'Review &\nSubmit', 'icon': Icons.check_circle},
  ];

  @override
  void onInit() {
    super.onInit();
    formKeys = List.generate(9, (_) => GlobalKey<FormState>());
    carModel = CarModel();
  }

  void goPrev() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void goNextOrSubmit() {
    if (currentStep.value >= steps.length - 1) {
      submit();
      return;
    }
    final ok = validateCurrentStep();
    if (!ok) return;
    currentStep.value++;
  }

  bool validateCurrentStep() {
    final idx = currentStep.value;
    if (idx < 0 || idx >= formKeys.length) return true;
    return formKeys[idx].currentState?.validate() ?? true;
  }

  void submit() {
    debugPrint('Form submitted: ${carModel.toJson()}');

    Get.snackbar(
      'Success',
      'Car inspection submitted successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }

  Future<void> fetchRcAdvancedAndFill() async {
    final reg = carModel.registrationNumber.trim();
    if (reg.isEmpty) {
      Get.snackbar(
        'Missing',
        'Please enter Registration Number first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    rcFetchLoading.value = true;
    try {
      final url = Uri.parse(
        'https://uat-hub.perfios.com/api/kyc/v3/rc-advanced',
      );

      final body = {
        "registrationNumber": "MH04CY4545",
        "consent": "Y",
        "partialEngine": "Y",
        "version": 3.1,
      };

      final headers = <String, String>{
        "x-auth-key": "0RurqWiFBAPCf8Na",
        "Content-Type": "application/json",
      };

      final res = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      print(res.body);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final result = decoded["result"];
      if (result == null || result is! Map<String, dynamic>) {
        throw Exception("Invalid response: result missing");
      }

      _applyPerfiosRcResultToCarModel(result);

      touch();
      Get.snackbar(
        'Success',
        'RC data fetched & filled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
      );
      print(e);
    } finally {
      rcFetchLoading.value = false;
    }
  }

  void _applyPerfiosRcResultToCarModel(Map<String, dynamic> r) {
    final regNo = (r["registrationNumber"] ?? "").toString().trim();
    if (regNo.isNotEmpty) carModel.registrationNumber = regNo;

    carModel.registrationDate =
        _parseApiDate(r["registrationDate"]) ?? carModel.registrationDate;
    carModel.fitnessTill =
        _parseApiDate(r["fitnessUpto"]) ?? carModel.fitnessTill;
    carModel.insuranceValidity =
        _parseApiDate(r["insuranceUpto"]) ?? carModel.insuranceValidity;
    carModel.taxValidTill =
        _parseApiDate(r["taxPaidUpto"]) ?? carModel.taxValidTill;

    carModel.yearMonthOfManufacture =
        _parseApiDate(r["manufacturedMonthYear"]) ??
        carModel.yearMonthOfManufacture;

    final ch = (r["chassisNumber"] ?? "").toString().trim();
    if (ch.isNotEmpty) carModel.chassisNumber = ch;

    final en = (r["engineNumber"] ?? "").toString().trim();
    if (en.isNotEmpty) carModel.engineNumber = en;

    carModel.ownerSerialNumber = _parseInt(
      r["ownerSerialNumber"],
      fallback: carModel.ownerSerialNumber,
    );

    carModel.cubicCapacity = _parseCc(
      r["cubicCapacity"],
      fallback: carModel.cubicCapacity,
    );

    // ✅ NEW: Seating Capacity from API
    carModel.seatingCapacity = _parseInt(
      r["seatingCapacity"],
      fallback: carModel.seatingCapacity,
    );

    // ✅ NEW: Color from API
    final color = (r["color"] ?? "").toString().trim();
    if (color.isNotEmpty) carModel.color = color;

    final owner = (r["ownerName"] ?? "").toString().trim();
    if (owner.isNotEmpty) carModel.registeredOwner = owner;

    final permAddr = (r["permanentAddress"] ?? "").toString().trim();
    final presAddr = (r["presentAddress"] ?? "").toString().trim();
    if (permAddr.isNotEmpty)
      carModel.registeredAddressAsPerRc = permAddr;
    else if (presAddr.isNotEmpty)
      carModel.registeredAddressAsPerRc = presAddr;

    final registeredAt = (r["registeredAt"] ?? "").toString().trim();
    if (registeredAt.isNotEmpty) {
      carModel.registeredRto = registeredAt;

      if (carModel.registrationState.trim().isEmpty) {
        final parts = registeredAt.split(',');
        if (parts.length >= 2) carModel.registrationState = parts.last.trim();
      }
      if (carModel.registrationCity.trim().isEmpty) {
        final parts = registeredAt.split(',');
        if (parts.isNotEmpty) carModel.registrationCity = parts.first.trim();
      }
    }

    final fuel = (r["fuelDescription"] ?? "").toString().trim();
    if (fuel.isNotEmpty) carModel.fuelType = fuel;

    final maker = (r["makerDescription"] ?? "").toString().trim();
    if (maker.isNotEmpty) carModel.make = maker;

    final makerModel = (r["makerModel"] ?? "").toString().trim();
    if (makerModel.isNotEmpty) {
      final parts = makerModel.split(RegExp(r'\s+'));
      if (parts.length == 1) {
        carModel.model = makerModel;
      } else {
        carModel.model = parts.first;
        carModel.variant = parts.sublist(1).join(' ');
      }
    }

    final pol = (r["insurancePolicyNumber"] ?? "").toString().trim();
    if (pol.isNotEmpty) carModel.insurancePolicyNumber = pol;
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

      return DateTime.tryParse(s);
    } catch (_) {
      return null;
    }
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
}
