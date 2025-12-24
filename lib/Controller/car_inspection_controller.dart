import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:otobix_inspection_app/models/car_model.dart';

class CarInspectionStepperController extends GetxController {
  final RxInt currentStep = 0.obs;

  // ✅ UI refresh tick: whenever carModel changes, call touch()
  final RxInt uiTick = 0.obs;
  void touch() => uiTick.value++;

  // ✅ NEW: loading state for RC fetch button
  final RxBool rcFetchLoading = false.obs;

  late final CarModel carModel;
  late final List<GlobalKey<FormState>> formKeys;

  final List<Map<String, dynamic>> steps = const [
    {'title': 'Registration &\nDocuments', 'icon': Icons.description},
    {'title': 'Basic\nInformation', 'icon': Icons.directions_car},
    {'title': 'Exterior\nFront & Sides', 'icon': Icons.directions_car_filled},
    {'title': 'Exterior\nRear', 'icon': Icons.car_repair},
    {'title': 'Engine &\nMechanical', 'icon': Icons.settings},
    {'title': 'Interior &\nElectronics', 'icon': Icons.event_seat},
    {'title': 'Final\nDetails', 'icon': Icons.fact_check},
    {'title': 'Review &\nSubmit', 'icon': Icons.check_circle},
  ];

  @override
  void onInit() {
    super.onInit();
    formKeys = List.generate(8, (_) => GlobalKey<FormState>());
    carModel = _createEmptyCarModel();
  }

  void goPrev() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void goNextOrSubmit() {
    if (currentStep.value >= steps.length - 1) {
      submit();
      return;
    }

    final isValid = validateCurrentStep();
    if (!isValid) return;

    currentStep.value++;
  }

  bool validateCurrentStep() {
    final idx = currentStep.value;
    if (idx < 0 || idx >= formKeys.length) return true;
    final key = formKeys[idx];
    return key.currentState?.validate() ?? true;
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
        "registrationNumber": "JH01BP5530",
        "consent": "Y",
        "partialEngine": "Y",
        "version": 3.1,
      };

      final headers = <String, String>{"x-auth-key": "0RurqWiFBAPCf8Na"};

      final res = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;

      final result = decoded["result"];
      if (result == null || result is! Map<String, dynamic>) {
        throw Exception("Invalid response: result missing");
      }

      _applyPerfiosRcResultToCarModel(result);

      // ✅ refresh UI
      touch();
      print(res.body);
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
      print("errror $e");
    } finally {
      rcFetchLoading.value = false;
    }
  }

  /// ✅ ONLY matched fields (CarModel names unchanged)
  void _applyPerfiosRcResultToCarModel(Map<String, dynamic> r) {
    // registrationNumber -> CarModel.registrationNumber
    final regNo = (r["registrationNumber"] ?? "").toString().trim();
    if (regNo.isNotEmpty) {
      carModel.registrationNumber = regNo;
    }

    // registrationDate (dd-MM-yyyy)
    carModel.registrationDate =
        _parseApiDate(r["registrationDate"]) ?? carModel.registrationDate;

    // fitnessUpto -> fitnessTill
    carModel.fitnessTill =
        _parseApiDate(r["fitnessUpto"]) ?? carModel.fitnessTill;

    // insuranceUpto -> insuranceValidity
    carModel.insuranceValidity =
        _parseApiDate(r["insuranceUpto"]) ?? carModel.insuranceValidity;

    // taxPaidUpto -> taxValidTill
    carModel.taxValidTill =
        _parseApiDate(r["taxPaidUpto"]) ?? carModel.taxValidTill;

    // manufacturedMonthYear (MM-yyyy) -> yearMonthOfManufacture
    carModel.yearMonthOfManufacture =
        _parseApiDate(r["manufacturedMonthYear"]) ??
        carModel.yearMonthOfManufacture;

    // chassisNumber, engineNumber
    final ch = (r["chassisNumber"] ?? "").toString().trim();
    if (ch.isNotEmpty) carModel.chassisNumber = ch;

    final en = (r["engineNumber"] ?? "").toString().trim();
    if (en.isNotEmpty) carModel.engineNumber = en;

    // ownerSerialNumber
    carModel.ownerSerialNumber = _parseInt(
      r["ownerSerialNumber"],
      fallback: carModel.ownerSerialNumber,
    );

    // cubicCapacity "2179.00" -> int
    carModel.cubicCapacity = _parseCc(
      r["cubicCapacity"],
      fallback: carModel.cubicCapacity,
    );

    // ownerName -> registeredOwner
    final owner = (r["ownerName"] ?? "").toString().trim();
    if (owner.isNotEmpty) carModel.registeredOwner = owner;

    // permanentAddress / presentAddress -> registeredAddressAsPerRc
    final permAddr = (r["permanentAddress"] ?? "").toString().trim();
    final presAddr = (r["presentAddress"] ?? "").toString().trim();
    if (permAddr.isNotEmpty) {
      carModel.registeredAddressAsPerRc = permAddr;
    } else if (presAddr.isNotEmpty) {
      carModel.registeredAddressAsPerRc = presAddr;
    }

    // registeredAt -> registeredRto
    final registeredAt = (r["registeredAt"] ?? "").toString().trim();
    if (registeredAt.isNotEmpty) {
      carModel.registeredRto = registeredAt;

      // Optional: registrationState from registeredAt (e.g. "RANCHI, Jharkhand")
      if (carModel.registrationState.trim().isEmpty) {
        final parts = registeredAt.split(',');
        if (parts.length >= 2) {
          final st = parts.last.trim();
          if (st.isNotEmpty) carModel.registrationState = st;
        }
      }

      // Optional: city from registeredAt
      if (carModel.city.trim().isEmpty) {
        final parts = registeredAt.split(',');
        final ct = parts.isNotEmpty ? parts.first.trim() : '';
        if (ct.isNotEmpty) carModel.city = ct;
      }
    }

    // fuelDescription -> fuelType
    final fuel = (r["fuelDescription"] ?? "").toString().trim();
    if (fuel.isNotEmpty) carModel.fuelType = fuel;

    // makerDescription -> make
    final maker = (r["makerDescription"] ?? "").toString().trim();
    if (maker.isNotEmpty) carModel.make = maker;

    // makerModel -> model + variant (simple)
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

    // insurancePolicyNumber -> insurancePolicyNumber
    final pol = (r["insurancePolicyNumber"] ?? "").toString().trim();
    if (pol.isNotEmpty) carModel.insurancePolicyNumber = pol;

    // insuranceCompany -> insurance dropdown value (Valid/Expired/Not Available)
    final insCompany = (r["insuranceCompany"] ?? "").toString().trim();
    if (insCompany.isNotEmpty) {
      final dt = carModel.insuranceValidity;
      if (dt == null) {
        carModel.insurance = "Valid";
      } else {
        carModel.insurance = dt.isAfter(DateTime.now()) ? "Valid" : "Expired";
      }
    }

    // financier -> hypothecationDetails
    final fin = (r["financier"] ?? "").toString().trim();
    if (fin.isNotEmpty) carModel.hypothecationDetails = fin;

    // rcMobileNo -> contactNumber (optional)
    final mobile = (r["rcMobileNo"] ?? "").toString().trim();
    if (mobile.isNotEmpty) carModel.contactNumber = mobile;
  }

  DateTime? _parseApiDate(dynamic v) {
    if (v == null) return null;

    final s = v.toString().trim();
    if (s.isEmpty) return null;

    try {
      if (RegExp(r'^\d{2}-\d{4}$').hasMatch(s)) {
        final dt = DateFormat('MM-yyyy').parseStrict(s);
        return DateTime(dt.year, dt.month, 1);
      }
    } catch (_) {}

    final patterns = <DateFormat>[
      DateFormat('dd-MM-yyyy'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('dd-MMM-yyyy'),
      DateFormat('dd MMM yyyy'),
      DateFormat('yyyy-MM-dd'),
    ];

    for (final f in patterns) {
      try {
        return f.parseStrict(s);
      } catch (_) {}
    }

    return null;
  }

  int _parseInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    final s = v.toString().trim();
    return int.tryParse(s) ?? fallback;
  }

  int _parseCc(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;

    final s = v.toString().trim();
    final d = double.tryParse(s);
    if (d != null) return d.toInt();

    return int.tryParse(s) ?? fallback;
  }

  CarModel _createEmptyCarModel() {
    return CarModel(
      id: '',
      timestamp: DateTime.now(),
      emailAddress: '',
      appointmentId: '',
      city: '',
      registrationType: '',
      rcBookAvailability: '',
      rcCondition: '',
      registrationNumber: '',
      registrationDate: null,
      fitnessTill: null,
      toBeScrapped: '',
      registrationState: '',
      registeredRto: '',
      ownerSerialNumber: 0,
      make: '',
      model: '',
      variant: '',
      engineNumber: '',
      chassisNumber: '',
      registeredOwner: '',
      registeredAddressAsPerRc: '',
      yearMonthOfManufacture: null,
      fuelType: '',
      cubicCapacity: 0,
      hypothecationDetails: '',
      mismatchInRc: '',
      roadTaxValidity: '',
      taxValidTill: null,
      insurance: '',
      insurancePolicyNumber: '',
      insuranceValidity: null,
      noClaimBonus: '',
      mismatchInInsurance: '',
      duplicateKey: '',
      rtoNoc: '',
      rtoForm28: '',
      partyPeshi: '',
      additionalDetails: '',
      rcTaxToken: [],
      insuranceCopy: [],
      bothKeys: [],
      form26GdCopyIfRcIsLost: [],
      bonnet: '',
      frontWindshield: '',
      roof: '',
      frontBumper: '',
      lhsHeadlamp: '',
      lhsFoglamp: '',
      rhsHeadlamp: '',
      rhsFoglamp: '',
      lhsFender: '',
      lhsOrvm: '',
      lhsAPillar: '',
      lhsBPillar: '',
      lhsCPillar: '',
      lhsFrontAlloy: '',
      lhsFrontTyre: '',
      lhsRearAlloy: '',
      lhsRearTyre: '',
      lhsFrontDoor: '',
      lhsRearDoor: '',
      lhsRunningBorder: '',
      lhsQuarterPanel: '',
      rearBumper: '',
      lhsTailLamp: '',
      rhsTailLamp: '',
      rearWindshield: '',
      bootDoor: '',
      spareTyre: '',
      bootFloor: '',
      rhsRearAlloy: '',
      rhsRearTyre: '',
      rhsFrontAlloy: '',
      rhsFrontTyre: '',
      rhsQuarterPanel: '',
      rhsAPillar: '',
      rhsBPillar: '',
      rhsCPillar: '',
      rhsRunningBorder: '',
      rhsRearDoor: '',
      rhsFrontDoor: '',
      rhsOrvm: '',
      rhsFender: '',
      comments: '',
      frontMain: [],
      bonnetImages: [],
      frontWindshieldImages: [],
      roofImages: [],
      frontBumperImages: [],
      lhsHeadlampImages: [],
      lhsFoglampImages: [],
      rhsHeadlampImages: [],
      rhsFoglampImages: [],
      lhsFront45Degree: [],
      lhsFenderImages: [],
      lhsFrontAlloyImages: [],
      lhsFrontTyreImages: [],
      lhsRunningBorderImages: [],
      lhsOrvmImages: [],
      lhsAPillarImages: [],
      lhsFrontDoorImages: [],
      lhsBPillarImages: [],
      lhsRearDoorImages: [],
      lhsCPillarImages: [],
      lhsRearTyreImages: [],
      lhsRearAlloyImages: [],
      lhsQuarterPanelImages: [],
      rearMain: [],
      rearWithBootDoorOpen: '',
      rearBumperImages: [],
      lhsTailLampImages: [],
      rhsTailLampImages: [],
      rearWindshieldImages: [],
      spareTyreImages: [],
      bootFloorImages: [],
      rhsRear45Degree: [],
      rhsQuarterPanelImages: [],
      rhsRearAlloyImages: [],
      rhsRearTyreImages: [],
      rhsCPillarImages: [],
      rhsRearDoorImages: [],
      rhsBPillarImages: [],
      rhsFrontDoorImages: [],
      rhsAPillarImages: [],
      rhsRunningBorderImages: [],
      rhsFrontAlloyImages: [],
      rhsFrontTyreImages: [],
      rhsOrvmImages: [],
      rhsFenderImages: [],
      upperCrossMember: '',
      radiatorSupport: '',
      headlightSupport: '',
      lowerCrossMember: '',
      lhsApron: '',
      rhsApron: '',
      firewall: '',
      cowlTop: '',
      engine: '',
      battery: '',
      coolant: '',
      engineOilLevelDipstick: '',
      engineOil: '',
      engineMount: '',
      enginePermisableBlowBy: '',
      exhaustSmoke: '',
      clutch: '',
      gearShift: '',
      commentsOnEngine: '',
      commentsOnEngineOil: '',
      commentsOnTowing: '',
      commentsOnTransmission: '',
      commentsOnRadiator: '',
      commentsOnOthers: '',
      engineBay: [],
      apronLhsRhs: [],
      batteryImages: [],
      additionalImages: [],
      engineSound: [],
      exhaustSmokeImages: [],
      steering: '',
      brakes: '',
      suspension: '',
      odometerReadingInKms: 0,
      fuelLevel: '',
      abs: '',
      electricals: '',
      rearWiperWasher: '',
      rearDefogger: '',
      musicSystem: '',
      stereo: '',
      inbuiltSpeaker: '',
      externalSpeaker: '',
      steeringMountedAudioControl: '',
      noOfPowerWindows: '',
      powerWindowConditionRhsFront: '',
      powerWindowConditionLhsFront: '',
      powerWindowConditionRhsRear: '',
      powerWindowConditionLhsRear: '',
      commentOnInterior: '',
      noOfAirBags: 0,
      airbagFeaturesDriverSide: '',
      airbagFeaturesCoDriverSide: '',
      airbagFeaturesLhsAPillarCurtain: '',
      airbagFeaturesLhsBPillarCurtain: '',
      airbagFeaturesLhsCPillarCurtain: '',
      airbagFeaturesRhsAPillarCurtain: '',
      airbagFeaturesRhsBPillarCurtain: '',
      airbagFeaturesRhsCPillarCurtain: '',
      sunroof: '',
      leatherSeats: '',
      fabricSeats: '',
      commentsOnElectricals: '',
      meterConsoleWithEngineOn: [],
      airbags: [],
      sunroofImages: [],
      frontSeatsFromDriverSideDoorOpen: [],
      rearSeatsFromRightSideDoorOpen: [],
      dashboardFromRearSeat: [],
      reverseCamera: '',
      additionalImages2: [],
      airConditioningManual: '',
      airConditioningClimateControl: '',
      commentsOnAc: '',
      approvedBy: '',
      approvalDate: null,
      approvalTime: null,
      approvalStatus: '',
      contactNumber: '',
      newArrivalMessage: null,
      budgetCar: '',
      status: '',
      priceDiscovery: 0,
      priceDiscoveryBy: '',
      latlong: '',
      retailAssociate: '',
      kmRangeLevel: 0,
      highestBidder: '',
      v: 0,
    );
  }
}
