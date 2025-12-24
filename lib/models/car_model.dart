class CarModel {
  String id;
  DateTime? timestamp;

  String emailAddress;
  String appointmentId;
  String city;

  String registrationType;
  String rcBookAvailability;
  String rcCondition;

  String registrationNumber;
  DateTime? registrationDate;
  DateTime? fitnessTill;

  String toBeScrapped;

  String registrationState;
  String registeredRto;
  int ownerSerialNumber;

  String make;
  String model;
  String variant;

  String engineNumber;
  String chassisNumber;

  String registeredOwner;
  String registeredAddressAsPerRc;

  DateTime? yearMonthOfManufacture;
  String fuelType;
  int cubicCapacity;

  String hypothecationDetails;
  String mismatchInRc;

  String roadTaxValidity;
  DateTime? taxValidTill;

  String insurance;
  String insurancePolicyNumber;
  DateTime? insuranceValidity;

  String noClaimBonus;
  String mismatchInInsurance;

  String duplicateKey;

  String rtoNoc;
  String rtoForm28;
  String partyPeshi;

  String additionalDetails;

  List<String> rcTaxToken;
  List<String> insuranceCopy;
  List<String> bothKeys;
  List<String> form26GdCopyIfRcIsLost;

  // Exterior (strings)
  String bonnet;
  String frontWindshield;
  String roof;
  String frontBumper;

  String lhsHeadlamp;
  String lhsFoglamp;
  String rhsHeadlamp;
  String rhsFoglamp;

  String lhsFender;
  String lhsOrvm;

  String lhsAPillar;
  String lhsBPillar;
  String lhsCPillar;

  String lhsFrontAlloy;
  String lhsFrontTyre;

  String lhsRearAlloy;
  String lhsRearTyre;

  String lhsFrontDoor;
  String lhsRearDoor;
  String lhsRunningBorder;
  String lhsQuarterPanel;

  String rearBumper;
  String lhsTailLamp;
  String rhsTailLamp;
  String rearWindshield;

  String bootDoor;
  String spareTyre;
  String bootFloor;

  String rhsRearAlloy;
  String rhsRearTyre;

  String rhsFrontAlloy;
  String rhsFrontTyre;

  String rhsQuarterPanel;

  String rhsAPillar;
  String rhsBPillar;
  String rhsCPillar;

  String rhsRunningBorder;

  String rhsRearDoor;
  String rhsFrontDoor;

  String rhsOrvm;
  String rhsFender;

  String comments;

  // Images (lists)
  List<String> frontMain;

  List<String> bonnetImages;
  List<String> frontWindshieldImages;
  List<String> roofImages;
  List<String> frontBumperImages;

  List<String> lhsHeadlampImages;
  List<String> lhsFoglampImages;
  List<String> rhsHeadlampImages;
  List<String> rhsFoglampImages;

  List<String> lhsFront45Degree;
  List<String> lhsFenderImages;
  List<String> lhsFrontAlloyImages;
  List<String> lhsFrontTyreImages;
  List<String> lhsRunningBorderImages;
  List<String> lhsOrvmImages;
  List<String> lhsAPillarImages;
  List<String> lhsFrontDoorImages;
  List<String> lhsBPillarImages;
  List<String> lhsRearDoorImages;
  List<String> lhsCPillarImages;
  List<String> lhsRearTyreImages;
  List<String> lhsRearAlloyImages;
  List<String> lhsQuarterPanelImages;

  List<String> rearMain;
  String rearWithBootDoorOpen;

  List<String> rearBumperImages;
  List<String> lhsTailLampImages;
  List<String> rhsTailLampImages;
  List<String> rearWindshieldImages;

  List<String> spareTyreImages;
  List<String> bootFloorImages;

  List<String> rhsRear45Degree;
  List<String> rhsQuarterPanelImages;
  List<String> rhsRearAlloyImages;
  List<String> rhsRearTyreImages;
  List<String> rhsCPillarImages;
  List<String> rhsRearDoorImages;
  List<String> rhsBPillarImages;
  List<String> rhsFrontDoorImages;
  List<String> rhsAPillarImages;
  List<String> rhsRunningBorderImages;
  List<String> rhsFrontAlloyImages;
  List<String> rhsFrontTyreImages;
  List<String> rhsOrvmImages;
  List<String> rhsFenderImages;

  // Engine bay structure
  String upperCrossMember;
  String radiatorSupport;
  String headlightSupport;
  String lowerCrossMember;

  String lhsApron;
  String rhsApron;

  String firewall;
  String cowlTop;

  // Engine / mech
  String engine;
  String battery;
  String coolant;

  String engineOilLevelDipstick;
  String engineOil;

  String engineMount;
  String enginePermisableBlowBy;

  String exhaustSmoke;

  String clutch;
  String gearShift;

  String commentsOnEngine;
  String commentsOnEngineOil;
  String commentsOnTowing;
  String commentsOnTransmission;
  String commentsOnRadiator;
  String commentsOnOthers;

  List<String> engineBay;
  List<String> apronLhsRhs;
  List<String> batteryImages;
  List<String> additionalImages;
  List<String> engineSound;
  List<String> exhaustSmokeImages;

  // Test drive / performance
  String steering;
  String brakes;
  String suspension;

  int odometerReadingInKms;
  String fuelLevel;

  String abs;
  String electricals;

  String rearWiperWasher;
  String rearDefogger;

  // Interior / infotainment
  String musicSystem;
  String stereo;
  String inbuiltSpeaker;
  String externalSpeaker;

  String steeringMountedAudioControl;

  String noOfPowerWindows;
  String powerWindowConditionRhsFront;
  String powerWindowConditionLhsFront;
  String powerWindowConditionRhsRear;
  String powerWindowConditionLhsRear;

  String commentOnInterior;

  int noOfAirBags;
  String airbagFeaturesDriverSide;
  String airbagFeaturesCoDriverSide;
  String airbagFeaturesLhsAPillarCurtain;
  String airbagFeaturesLhsBPillarCurtain;
  String airbagFeaturesLhsCPillarCurtain;
  String airbagFeaturesRhsAPillarCurtain;
  String airbagFeaturesRhsBPillarCurtain;
  String airbagFeaturesRhsCPillarCurtain;

  String sunroof;
  String leatherSeats;
  String fabricSeats;

  String commentsOnElectricals;

  List<String> meterConsoleWithEngineOn;
  List<String> airbags;
  List<String> sunroofImages;

  List<String> frontSeatsFromDriverSideDoorOpen;
  List<String> rearSeatsFromRightSideDoorOpen;
  List<String> dashboardFromRearSeat;

  String reverseCamera;

  List<String> additionalImages2;

  String airConditioningManual;
  String airConditioningClimateControl;
  String commentsOnAc;

  // Approval
  String approvedBy;
  DateTime? approvalDate;
  DateTime? approvalTime;
  String approvalStatus;

  String contactNumber;

  DateTime? newArrivalMessage;
  String budgetCar;
  String status;

  int priceDiscovery;
  String priceDiscoveryBy;

  String latlong;
  String retailAssociate;

  int kmRangeLevel;
  String highestBidder;

  int v;

  // ✅ New fields (nullable)

  // --- RC / Vehicle meta ---
  String? inspectionEngineerName;
  List<String>? chassisEmbossmentImages;
  List<String>? vinPlateImages;
  String? color;

  int? seatingCapacityAutoFetched;
  int? seatingCapacityMandatory;

  int? numberOfCylinders;
  String? bodyType;
  String? norms;
  String? vehicleCategory;

  int? wheelBase; // mm
  int? grossVehicleWeight; // kg
  int? unladenWeight; // kg

  String? roadTaxType;
  String? hypothecatorName;

  List<String>? pollutionCertificateImages;
  DateTime? pollutionCertificateValidity;
  String? pollutionCertificatePolicyNumber;

  String? registrationCertificateStatus;
  String? blacklistStatus;

  // --- Wipers / Views / Lamps ---
  String? frontWiperWasher;
  List<String>? frontWiperWasherImages;

  List<String>? lhsFullView;
  List<String>? rhsFullView;

  String? lhsRearFogLamp;
  List<String>? lhsRearFogLampImages;

  String? rhsRearFogLamp;
  List<String>? rhsRearFogLampImages;

  List<String>? rearWiperWasherImages;

  List<String>? cowlTopImages;
  List<String>? firewallImages;

  String? lhsSideMember;
  String? rhsSideMember;

  // --- Interior / Cluster / Controls ---
  String? commentsOnClusterMeter;

  String? irvm;
  String? dashboard;

  String? steeringMountedSystemControls;

  // --- AC ---
  List<String>? acImages;
  String? acCooling;

  // --- Airbags / Seats ---
  String? driverSideKneeAirbag;
  String? coDriverKneeAirbag;

  String? rhsRearSideAirbags;
  String? lhsRearSideAirbags;

  String? driverSeat;
  String? coDriverSeat;

  String? frontCentreArmRest;
  String? thirdRowSeats;

  // --- Transmission / Test drive ---
  String? transmissionType;
  String? driveTrain;

  List<String>? testDriveOdometerReadingImages;
  int? testDriveOdometerReadingInKms;

  CarModel({
    required this.id,
    required this.timestamp,
    required this.emailAddress,
    required this.appointmentId,
    required this.city,
    required this.registrationType,
    required this.rcBookAvailability,
    required this.rcCondition,
    required this.registrationNumber,
    required this.registrationDate,
    required this.fitnessTill,
    required this.toBeScrapped,
    required this.registrationState,
    required this.registeredRto,
    required this.ownerSerialNumber,
    required this.make,
    required this.model,
    required this.variant,
    required this.engineNumber,
    required this.chassisNumber,
    required this.registeredOwner,
    required this.registeredAddressAsPerRc,
    required this.yearMonthOfManufacture,
    required this.fuelType,
    required this.cubicCapacity,
    required this.hypothecationDetails,
    required this.mismatchInRc,
    required this.roadTaxValidity,
    required this.taxValidTill,
    required this.insurance,
    required this.insurancePolicyNumber,
    required this.insuranceValidity,
    required this.noClaimBonus,
    required this.mismatchInInsurance,
    required this.duplicateKey,
    required this.rtoNoc,
    required this.rtoForm28,
    required this.partyPeshi,
    required this.additionalDetails,
    required this.rcTaxToken,
    required this.insuranceCopy,
    required this.bothKeys,
    required this.form26GdCopyIfRcIsLost,
    required this.bonnet,
    required this.frontWindshield,
    required this.roof,
    required this.frontBumper,
    required this.lhsHeadlamp,
    required this.lhsFoglamp,
    required this.rhsHeadlamp,
    required this.rhsFoglamp,
    required this.lhsFender,
    required this.lhsOrvm,
    required this.lhsAPillar,
    required this.lhsBPillar,
    required this.lhsCPillar,
    required this.lhsFrontAlloy,
    required this.lhsFrontTyre,
    required this.lhsRearAlloy,
    required this.lhsRearTyre,
    required this.lhsFrontDoor,
    required this.lhsRearDoor,
    required this.lhsRunningBorder,
    required this.lhsQuarterPanel,
    required this.rearBumper,
    required this.lhsTailLamp,
    required this.rhsTailLamp,
    required this.rearWindshield,
    required this.bootDoor,
    required this.spareTyre,
    required this.bootFloor,
    required this.rhsRearAlloy,
    required this.rhsRearTyre,
    required this.rhsFrontAlloy,
    required this.rhsFrontTyre,
    required this.rhsQuarterPanel,
    required this.rhsAPillar,
    required this.rhsBPillar,
    required this.rhsCPillar,
    required this.rhsRunningBorder,
    required this.rhsRearDoor,
    required this.rhsFrontDoor,
    required this.rhsOrvm,
    required this.rhsFender,
    required this.comments,
    required this.frontMain,
    required this.bonnetImages,
    required this.frontWindshieldImages,
    required this.roofImages,
    required this.frontBumperImages,
    required this.lhsHeadlampImages,
    required this.lhsFoglampImages,
    required this.rhsHeadlampImages,
    required this.rhsFoglampImages,
    required this.lhsFront45Degree,
    required this.lhsFenderImages,
    required this.lhsFrontAlloyImages,
    required this.lhsFrontTyreImages,
    required this.lhsRunningBorderImages,
    required this.lhsOrvmImages,
    required this.lhsAPillarImages,
    required this.lhsFrontDoorImages,
    required this.lhsBPillarImages,
    required this.lhsRearDoorImages,
    required this.lhsCPillarImages,
    required this.lhsRearTyreImages,
    required this.lhsRearAlloyImages,
    required this.lhsQuarterPanelImages,
    required this.rearMain,
    required this.rearWithBootDoorOpen,
    required this.rearBumperImages,
    required this.lhsTailLampImages,
    required this.rhsTailLampImages,
    required this.rearWindshieldImages,
    required this.spareTyreImages,
    required this.bootFloorImages,
    required this.rhsRear45Degree,
    required this.rhsQuarterPanelImages,
    required this.rhsRearAlloyImages,
    required this.rhsRearTyreImages,
    required this.rhsCPillarImages,
    required this.rhsRearDoorImages,
    required this.rhsBPillarImages,
    required this.rhsFrontDoorImages,
    required this.rhsAPillarImages,
    required this.rhsRunningBorderImages,
    required this.rhsFrontAlloyImages,
    required this.rhsFrontTyreImages,
    required this.rhsOrvmImages,
    required this.rhsFenderImages,
    required this.upperCrossMember,
    required this.radiatorSupport,
    required this.headlightSupport,
    required this.lowerCrossMember,
    required this.lhsApron,
    required this.rhsApron,
    required this.firewall,
    required this.cowlTop,
    required this.engine,
    required this.battery,
    required this.coolant,
    required this.engineOilLevelDipstick,
    required this.engineOil,
    required this.engineMount,
    required this.enginePermisableBlowBy,
    required this.exhaustSmoke,
    required this.clutch,
    required this.gearShift,
    required this.commentsOnEngine,
    required this.commentsOnEngineOil,
    required this.commentsOnTowing,
    required this.commentsOnTransmission,
    required this.commentsOnRadiator,
    required this.commentsOnOthers,
    required this.engineBay,
    required this.apronLhsRhs,
    required this.batteryImages,
    required this.additionalImages,
    required this.engineSound,
    required this.exhaustSmokeImages,
    required this.steering,
    required this.brakes,
    required this.suspension,
    required this.odometerReadingInKms,
    required this.fuelLevel,
    required this.abs,
    required this.electricals,
    required this.rearWiperWasher,
    required this.rearDefogger,
    required this.musicSystem,
    required this.stereo,
    required this.inbuiltSpeaker,
    required this.externalSpeaker,
    required this.steeringMountedAudioControl,
    required this.noOfPowerWindows,
    required this.powerWindowConditionRhsFront,
    required this.powerWindowConditionLhsFront,
    required this.powerWindowConditionRhsRear,
    required this.powerWindowConditionLhsRear,
    required this.commentOnInterior,
    required this.noOfAirBags,
    required this.airbagFeaturesDriverSide,
    required this.airbagFeaturesCoDriverSide,
    required this.airbagFeaturesLhsAPillarCurtain,
    required this.airbagFeaturesLhsBPillarCurtain,
    required this.airbagFeaturesLhsCPillarCurtain,
    required this.airbagFeaturesRhsAPillarCurtain,
    required this.airbagFeaturesRhsBPillarCurtain,
    required this.airbagFeaturesRhsCPillarCurtain,
    required this.sunroof,
    required this.leatherSeats,
    required this.fabricSeats,
    required this.commentsOnElectricals,
    required this.meterConsoleWithEngineOn,
    required this.airbags,
    required this.sunroofImages,
    required this.frontSeatsFromDriverSideDoorOpen,
    required this.rearSeatsFromRightSideDoorOpen,
    required this.dashboardFromRearSeat,
    required this.reverseCamera,
    required this.additionalImages2,
    required this.airConditioningManual,
    required this.airConditioningClimateControl,
    required this.commentsOnAc,
    required this.approvedBy,
    required this.approvalDate,
    required this.approvalTime,
    required this.approvalStatus,
    required this.contactNumber,
    required this.newArrivalMessage,
    required this.budgetCar,
    required this.status,
    required this.priceDiscovery,
    required this.priceDiscoveryBy,
    required this.latlong,
    required this.retailAssociate,
    required this.kmRangeLevel,
    required this.highestBidder,
    required this.v,

    // nullable
    this.inspectionEngineerName,
    this.chassisEmbossmentImages,
    this.vinPlateImages,
    this.color,
    this.seatingCapacityAutoFetched,
    this.seatingCapacityMandatory,
    this.numberOfCylinders,
    this.bodyType,
    this.norms,
    this.vehicleCategory,
    this.wheelBase,
    this.grossVehicleWeight,
    this.unladenWeight,
    this.roadTaxType,
    this.hypothecatorName,
    this.pollutionCertificateImages,
    this.pollutionCertificateValidity,
    this.pollutionCertificatePolicyNumber,
    this.registrationCertificateStatus,
    this.blacklistStatus,
    this.frontWiperWasher,
    this.frontWiperWasherImages,
    this.lhsFullView,
    this.rhsFullView,
    this.lhsRearFogLamp,
    this.lhsRearFogLampImages,
    this.rhsRearFogLamp,
    this.rhsRearFogLampImages,
    this.rearWiperWasherImages,
    this.cowlTopImages,
    this.firewallImages,
    this.lhsSideMember,
    this.rhsSideMember,
    this.commentsOnClusterMeter,
    this.irvm,
    this.dashboard,
    this.steeringMountedSystemControls,
    this.acImages,
    this.acCooling,
    this.driverSideKneeAirbag,
    this.coDriverKneeAirbag,
    this.rhsRearSideAirbags,
    this.lhsRearSideAirbags,
    this.driverSeat,
    this.coDriverSeat,
    this.frontCentreArmRest,
    this.thirdRowSeats,
    this.transmissionType,
    this.driveTrain,
    this.testDriveOdometerReadingImages,
    this.testDriveOdometerReadingInKms,
  });

  factory CarModel.fromJson({
    required Map<String, dynamic> json,
    required String documentId,
  }) {
    return CarModel(
      id: documentId,
      timestamp: parseMongoDbDate(json["timestamp"]),

      emailAddress: _s(json["emailAddress"], def: 'N/A'),
      appointmentId: _s(json["appointmentId"], def: 'N/A'),
      city: _s(json["city"], def: 'N/A'),

      registrationType: _s(json["registrationType"], def: 'N/A'),
      rcBookAvailability: _s(json["rcBookAvailability"], def: 'N/A'),
      rcCondition: _s(json["rcCondition"], def: 'N/A'),

      registrationNumber: _s(json["registrationNumber"], def: 'N/A'),
      registrationDate: parseMongoDbDate(json["registrationDate"]),
      fitnessTill: parseMongoDbDate(json["fitnessTill"]),

      toBeScrapped: _s(json["toBeScrapped"], def: 'N/A'),

      registrationState: _s(json["registrationState"], def: 'N/A'),
      registeredRto: _s(json["registeredRto"], def: 'N/A'),
      ownerSerialNumber: _i(json["ownerSerialNumber"], def: 0),

      make: _s(json["make"], def: 'N/A'),
      model: _s(json["model"], def: 'N/A'),
      variant: _s(json["variant"], def: 'N/A'),

      engineNumber: _s(json["engineNumber"], def: 'N/A'),
      chassisNumber: _s(json["chassisNumber"], def: 'N/A'),

      registeredOwner: _s(json["registeredOwner"], def: 'N/A'),
      registeredAddressAsPerRc: _s(
        json["registeredAddressAsPerRc"],
        def: 'N/A',
      ),

      yearMonthOfManufacture: parseMongoDbDate(json["yearMonthOfManufacture"]),
      fuelType: _s(json["fuelType"], def: 'N/A'),
      cubicCapacity: _i(json["cubicCapacity"], def: 0),

      hypothecationDetails: _s(json["hypothecationDetails"], def: 'N/A'),
      mismatchInRc: _s(json["mismatchInRc"], def: 'N/A'),

      roadTaxValidity: _s(json["roadTaxValidity"], def: 'N/A'),
      taxValidTill: parseMongoDbDate(json["taxValidTill"]),

      insurance: _s(json["insurance"], def: 'N/A'),
      insurancePolicyNumber: _s(json["insurancePolicyNumber"], def: 'N/A'),
      insuranceValidity: parseMongoDbDate(json["insuranceValidity"]),

      noClaimBonus: _s(json["noClaimBonus"], def: 'N/A'),
      mismatchInInsurance: _s(json["mismatchInInsurance"], def: 'N/A'),

      duplicateKey: _s(json["duplicateKey"], def: 'N/A'),

      rtoNoc: _s(json["rtoNoc"], def: 'N/A'),
      rtoForm28: _s(json["rtoForm28"], def: 'N/A'),
      partyPeshi: _s(json["partyPeshi"], def: 'N/A'),

      additionalDetails: _s(json["additionalDetails"], def: 'N/A'),

      rcTaxToken: parseStringList(json["rcTaxToken"]),
      insuranceCopy: parseStringList(json["insuranceCopy"]),
      bothKeys: parseStringList(json["bothKeys"]),
      form26GdCopyIfRcIsLost: parseStringList(json["form26GdCopyIfRcIsLost"]),

      bonnet: _s(json["bonnet"], def: 'N/A'),
      frontWindshield: _s(json["frontWindshield"], def: 'N/A'),
      roof: _s(json["roof"], def: 'N/A'),
      frontBumper: _s(json["frontBumper"], def: 'N/A'),

      lhsHeadlamp: _s(json["lhsHeadlamp"], def: 'N/A'),
      lhsFoglamp: _s(json["lhsFoglamp"], def: 'N/A'),
      rhsHeadlamp: _s(json["rhsHeadlamp"], def: 'N/A'),
      rhsFoglamp: _s(json["rhsFoglamp"], def: 'N/A'),

      lhsFender: _s(json["lhsFender"], def: 'N/A'),
      lhsOrvm: _s(json["lhsOrvm"], def: 'N/A'),
      lhsAPillar: _s(json["lhsAPillar"], def: 'N/A'),
      lhsBPillar: _s(json["lhsBPillar"], def: 'N/A'),
      lhsCPillar: _s(json["lhsCPillar"], def: 'N/A'),

      lhsFrontAlloy: _s(json["lhsFrontAlloy"], def: 'N/A'),
      lhsFrontTyre: _s(json["lhsFrontTyre"], def: 'N/A'),
      lhsRearAlloy: _s(json["lhsRearAlloy"], def: 'N/A'),
      lhsRearTyre: _s(json["lhsRearTyre"], def: 'N/A'),

      lhsFrontDoor: _s(json["lhsFrontDoor"], def: 'N/A'),
      lhsRearDoor: _s(json["lhsRearDoor"], def: 'N/A'),
      lhsRunningBorder: _s(json["lhsRunningBorder"], def: 'N/A'),
      lhsQuarterPanel: _s(json["lhsQuarterPanel"], def: 'N/A'),

      rearBumper: _s(json["rearBumper"], def: 'N/A'),
      lhsTailLamp: _s(json["lhsTailLamp"], def: 'N/A'),
      rhsTailLamp: _s(json["rhsTailLamp"], def: 'N/A'),
      rearWindshield: _s(json["rearWindshield"], def: 'N/A'),

      bootDoor: _s(json["bootDoor"], def: 'N/A'),
      spareTyre: _s(json["spareTyre"], def: 'N/A'),
      bootFloor: _s(json["bootFloor"], def: 'N/A'),

      rhsRearAlloy: _s(json["rhsRearAlloy"], def: 'N/A'),
      rhsRearTyre: _s(json["rhsRearTyre"], def: 'N/A'),
      rhsFrontAlloy: _s(json["rhsFrontAlloy"], def: 'N/A'),
      rhsFrontTyre: _s(json["rhsFrontTyre"], def: 'N/A'),

      rhsQuarterPanel: _s(json["rhsQuarterPanel"], def: 'N/A'),

      rhsAPillar: _s(json["rhsAPillar"], def: 'N/A'),
      rhsBPillar: _s(json["rhsBPillar"], def: 'N/A'),
      rhsCPillar: _s(json["rhsCPillar"], def: 'N/A'),

      rhsRunningBorder: _s(json["rhsRunningBorder"], def: 'N/A'),

      rhsRearDoor: _s(json["rhsRearDoor"], def: 'N/A'),
      rhsFrontDoor: _s(json["rhsFrontDoor"], def: 'N/A'),

      rhsOrvm: _s(json["rhsOrvm"], def: 'N/A'),
      rhsFender: _s(json["rhsFender"], def: 'N/A'),

      comments: _s(json["comments"], def: 'N/A'),

      frontMain: parseStringList(json["frontMain"]),
      bonnetImages: parseStringList(json["bonnetImages"]),
      frontWindshieldImages: parseStringList(json["frontWindshieldImages"]),
      roofImages: parseStringList(json["roofImages"]),
      frontBumperImages: parseStringList(json["frontBumperImages"]),

      lhsHeadlampImages: parseStringList(json["lhsHeadlampImages"]),
      lhsFoglampImages: parseStringList(json["lhsFoglampImages"]),
      rhsHeadlampImages: parseStringList(json["rhsHeadlampImages"]),
      rhsFoglampImages: parseStringList(json["rhsFoglampImages"]),

      lhsFront45Degree: parseStringList(json["lhsFront45Degree"]),
      lhsFenderImages: parseStringList(json["lhsFenderImages"]),
      lhsFrontAlloyImages: parseStringList(json["lhsFrontAlloyImages"]),
      lhsFrontTyreImages: parseStringList(json["lhsFrontTyreImages"]),
      lhsRunningBorderImages: parseStringList(json["lhsRunningBorderImages"]),
      lhsOrvmImages: parseStringList(json["lhsOrvmImages"]),
      lhsAPillarImages: parseStringList(json["lhsAPillarImages"]),
      lhsFrontDoorImages: parseStringList(json["lhsFrontDoorImages"]),
      lhsBPillarImages: parseStringList(json["lhsBPillarImages"]),
      lhsRearDoorImages: parseStringList(json["lhsRearDoorImages"]),
      lhsCPillarImages: parseStringList(json["lhsCPillarImages"]),
      lhsRearTyreImages: parseStringList(json["lhsRearTyreImages"]),
      lhsRearAlloyImages: parseStringList(json["lhsRearAlloyImages"]),
      lhsQuarterPanelImages: parseStringList(json["lhsQuarterPanelImages"]),

      rearMain: parseStringList(json["rearMain"]),
      rearWithBootDoorOpen: _s(json["rearWithBootDoorOpen"], def: 'N/A'),
      rearBumperImages: parseStringList(json["rearBumperImages"]),
      lhsTailLampImages: parseStringList(json["lhsTailLampImages"]),
      rhsTailLampImages: parseStringList(json["rhsTailLampImages"]),
      rearWindshieldImages: parseStringList(json["rearWindshieldImages"]),
      spareTyreImages: parseStringList(json["spareTyreImages"]),
      bootFloorImages: parseStringList(json["bootFloorImages"]),

      rhsRear45Degree: parseStringList(json["rhsRear45Degree"]),
      rhsQuarterPanelImages: parseStringList(json["rhsQuarterPanelImages"]),
      rhsRearAlloyImages: parseStringList(json["rhsRearAlloyImages"]),
      rhsRearTyreImages: parseStringList(json["rhsRearTyreImages"]),
      rhsCPillarImages: parseStringList(json["rhsCPillarImages"]),
      rhsRearDoorImages: parseStringList(json["rhsRearDoorImages"]),
      rhsBPillarImages: parseStringList(json["rhsBPillarImages"]),
      rhsFrontDoorImages: parseStringList(json["rhsFrontDoorImages"]),
      rhsAPillarImages: parseStringList(json["rhsAPillarImages"]),
      rhsRunningBorderImages: parseStringList(json["rhsRunningBorderImages"]),
      rhsFrontAlloyImages: parseStringList(json["rhsFrontAlloyImages"]),
      rhsFrontTyreImages: parseStringList(json["rhsFrontTyreImages"]),
      rhsOrvmImages: parseStringList(json["rhsOrvmImages"]),
      rhsFenderImages: parseStringList(json["rhsFenderImages"]),

      upperCrossMember: _s(json["upperCrossMember"], def: 'N/A'),
      radiatorSupport: _s(json["radiatorSupport"], def: 'N/A'),
      headlightSupport: _s(json["headlightSupport"], def: 'N/A'),
      lowerCrossMember: _s(json["lowerCrossMember"], def: 'N/A'),
      lhsApron: _s(json["lhsApron"], def: 'N/A'),
      rhsApron: _s(json["rhsApron"], def: 'N/A'),
      firewall: _s(json["firewall"], def: 'N/A'),
      cowlTop: _s(json["cowlTop"], def: 'N/A'),

      engine: _s(json["engine"], def: 'N/A'),
      battery: _s(json["battery"], def: 'N/A'),
      coolant: _s(json["coolant"], def: 'N/A'),
      engineOilLevelDipstick: _s(json["engineOilLevelDipstick"], def: 'N/A'),
      engineOil: _s(json["engineOil"], def: 'N/A'),
      engineMount: _s(json["engineMount"], def: 'N/A'),
      enginePermisableBlowBy: _s(json["enginePermisableBlowBy"], def: 'N/A'),
      exhaustSmoke: _s(json["exhaustSmoke"], def: 'N/A'),
      clutch: _s(json["clutch"], def: 'N/A'),
      gearShift: _s(json["gearShift"], def: 'N/A'),

      commentsOnEngine: _s(json["commentsOnEngine"], def: 'N/A'),
      commentsOnEngineOil: _s(json["commentsOnEngineOil"], def: 'N/A'),
      commentsOnTowing: _s(json["commentsOnTowing"], def: 'N/A'),
      commentsOnTransmission: _s(json["commentsOnTransmission"], def: 'N/A'),
      commentsOnRadiator: _s(json["commentsOnRadiator"], def: 'N/A'),
      commentsOnOthers: _s(json["commentsOnOthers"], def: 'N/A'),

      engineBay: parseStringList(json["engineBay"]),
      apronLhsRhs: parseStringList(json["apronLhsRhs"]),
      batteryImages: parseStringList(json["batteryImages"]),
      additionalImages: parseStringList(json["additionalImages"]),
      engineSound: parseStringList(json["engineSound"]),
      exhaustSmokeImages: parseStringList(json["exhaustSmokeImages"]),

      steering: _s(json["steering"], def: 'N/A'),
      brakes: _s(json["brakes"], def: 'N/A'),
      suspension: _s(json["suspension"], def: 'N/A'),
      odometerReadingInKms: _i(json["odometerReadingInKms"], def: 0),
      fuelLevel: _s(json["fuelLevel"], def: 'N/A'),

      abs: _s(json["abs"], def: 'N/A'),
      electricals: _s(json["electricals"], def: 'N/A'),
      rearWiperWasher: _s(json["rearWiperWasher"], def: 'N/A'),
      rearDefogger: _s(json["rearDefogger"], def: 'N/A'),

      musicSystem: _s(json["musicSystem"], def: 'N/A'),
      stereo: _s(json["stereo"], def: 'N/A'),
      inbuiltSpeaker: _s(json["inbuiltSpeaker"], def: 'N/A'),
      externalSpeaker: _s(json["externalSpeaker"], def: 'N/A'),

      steeringMountedAudioControl: _s(
        json["steeringMountedAudioControl"],
        def: 'N/A',
      ),

      noOfPowerWindows: _s(json["noOfPowerWindows"], def: 'N/A'),
      powerWindowConditionRhsFront: _s(
        json["powerWindowConditionRhsFront"],
        def: 'N/A',
      ),
      powerWindowConditionLhsFront: _s(
        json["powerWindowConditionLhsFront"],
        def: 'N/A',
      ),
      powerWindowConditionRhsRear: _s(
        json["powerWindowConditionRhsRear"],
        def: 'N/A',
      ),
      powerWindowConditionLhsRear: _s(
        json["powerWindowConditionLhsRear"],
        def: 'N/A',
      ),

      commentOnInterior: _s(json["commentOnInterior"], def: 'N/A'),

      noOfAirBags: _i(json["noOfAirBags"], def: 0),
      airbagFeaturesDriverSide: _s(
        json["airbagFeaturesDriverSide"],
        def: 'N/A',
      ),
      airbagFeaturesCoDriverSide: _s(
        json["airbagFeaturesCoDriverSide"],
        def: 'N/A',
      ),
      airbagFeaturesLhsAPillarCurtain: _s(
        json["airbagFeaturesLhsAPillarCurtain"],
        def: 'N/A',
      ),
      airbagFeaturesLhsBPillarCurtain: _s(
        json["airbagFeaturesLhsBPillarCurtain"],
        def: 'N/A',
      ),
      airbagFeaturesLhsCPillarCurtain: _s(
        json["airbagFeaturesLhsCPillarCurtain"],
        def: 'N/A',
      ),
      airbagFeaturesRhsAPillarCurtain: _s(
        json["airbagFeaturesRhsAPillarCurtain"],
        def: 'N/A',
      ),
      airbagFeaturesRhsBPillarCurtain: _s(
        json["airbagFeaturesRhsBPillarCurtain"],
        def: 'N/A',
      ),
      airbagFeaturesRhsCPillarCurtain: _s(
        json["airbagFeaturesRhsCPillarCurtain"],
        def: 'N/A',
      ),

      sunroof: _s(json["sunroof"], def: 'N/A'),
      leatherSeats: _s(json["leatherSeats"], def: 'N/A'),
      fabricSeats: _s(json["fabricSeats"], def: 'N/A'),

      commentsOnElectricals: _s(json["commentsOnElectricals"], def: 'N/A'),

      meterConsoleWithEngineOn: parseStringList(
        json["meterConsoleWithEngineOn"],
      ),
      airbags: parseStringList(json["airbags"]),
      sunroofImages: parseStringList(json["sunroofImages"]),

      frontSeatsFromDriverSideDoorOpen: parseStringList(
        json["frontSeatsFromDriverSideDoorOpen"],
      ),
      rearSeatsFromRightSideDoorOpen: parseStringList(
        json["rearSeatsFromRightSideDoorOpen"],
      ),
      dashboardFromRearSeat: parseStringList(json["dashboardFromRearSeat"]),

      reverseCamera: _s(json["reverseCamera"], def: 'N/A'),
      additionalImages2: parseStringList(json["additionalImages2"]),

      airConditioningManual: _s(json["airConditioningManual"], def: 'N/A'),
      airConditioningClimateControl: _s(
        json["airConditioningClimateControl"],
        def: 'N/A',
      ),
      commentsOnAc: _s(json["commentsOnAC"], def: 'N/A'),

      approvedBy: _s(json["approvedBy"], def: 'N/A'),
      approvalDate: parseMongoDbDate(json["approvalDate"]),
      approvalTime: parseMongoDbDate(json["approvalTime"]),
      approvalStatus: _s(json["approvalStatus"], def: 'N/A'),

      contactNumber: _s(json["contactNumber"], def: 'N/A'),
      newArrivalMessage: parseMongoDbDate(json["newArrivalMessage"]),

      budgetCar: _s(json["budgetCar"], def: 'N/A'),
      status: _s(json["status"], def: 'N/A'),

      priceDiscovery: _i(json["priceDiscovery"], def: 0),
      priceDiscoveryBy: _s(json["priceDiscoveryBy"], def: 'N/A'),

      latlong: _s(json["latlong"], def: 'N/A'),
      retailAssociate: _s(json["retailAssociate"], def: 'N/A'),

      kmRangeLevel: _i(json["kmRangeLevel"], def: 0),
      highestBidder: _s(json["highestBidder"], def: 'N/A'),

      v: _i(json["__v"], def: 0),

      // ✅ Nullable new fields (keep null if absent)
      inspectionEngineerName: json.containsKey("inspectionEngineerName")
          ? _s(json["inspectionEngineerName"], def: null)
          : null,

      chassisEmbossmentImages: json.containsKey("chassisEmbossmentImages")
          ? parseStringListNullable(json["chassisEmbossmentImages"])
          : null,

      vinPlateImages: json.containsKey("vinPlateImages")
          ? parseStringListNullable(json["vinPlateImages"])
          : null,

      color: json.containsKey("color") ? _s(json["color"], def: null) : null,

      seatingCapacityAutoFetched: json.containsKey("seatingCapacityAutoFetched")
          ? _iN(json["seatingCapacityAutoFetched"])
          : null,
      seatingCapacityMandatory: json.containsKey("seatingCapacityMandatory")
          ? _iN(json["seatingCapacityMandatory"])
          : null,

      numberOfCylinders: json.containsKey("numberOfCylinders")
          ? _iN(json["numberOfCylinders"])
          : null,

      bodyType: json.containsKey("bodyType")
          ? _s(json["bodyType"], def: null)
          : null,
      norms: json.containsKey("norms") ? _s(json["norms"], def: null) : null,
      vehicleCategory: json.containsKey("vehicleCategory")
          ? _s(json["vehicleCategory"], def: null)
          : null,

      wheelBase: json.containsKey("wheelBase") ? _iN(json["wheelBase"]) : null,
      grossVehicleWeight: json.containsKey("grossVehicleWeight")
          ? _iN(json["grossVehicleWeight"])
          : null,
      unladenWeight: json.containsKey("unladenWeight")
          ? _iN(json["unladenWeight"])
          : null,

      roadTaxType: json.containsKey("roadTaxType")
          ? _s(json["roadTaxType"], def: null)
          : null,
      hypothecatorName: json.containsKey("hypothecatorName")
          ? _s(json["hypothecatorName"], def: null)
          : null,

      pollutionCertificateImages: json.containsKey("pollutionCertificateImages")
          ? parseStringListNullable(json["pollutionCertificateImages"])
          : null,
      pollutionCertificateValidity:
          json.containsKey("pollutionCertificateValidity")
          ? parseMongoDbDate(json["pollutionCertificateValidity"])
          : null,
      pollutionCertificatePolicyNumber:
          json.containsKey("pollutionCertificatePolicyNumber")
          ? _s(json["pollutionCertificatePolicyNumber"], def: null)
          : null,

      registrationCertificateStatus:
          json.containsKey("registrationCertificateStatus")
          ? _s(json["registrationCertificateStatus"], def: null)
          : null,
      blacklistStatus: json.containsKey("blacklistStatus")
          ? _s(json["blacklistStatus"], def: null)
          : null,

      frontWiperWasher: json.containsKey("frontWiperWasher")
          ? _s(json["frontWiperWasher"], def: null)
          : null,
      frontWiperWasherImages: json.containsKey("frontWiperWasherImages")
          ? parseStringListNullable(json["frontWiperWasherImages"])
          : null,

      lhsFullView: json.containsKey("lhsFullView")
          ? parseStringListNullable(json["lhsFullView"])
          : null,
      rhsFullView: json.containsKey("rhsFullView")
          ? parseStringListNullable(json["rhsFullView"])
          : null,

      lhsRearFogLamp: json.containsKey("lhsRearFogLamp")
          ? _s(json["lhsRearFogLamp"], def: null)
          : null,
      lhsRearFogLampImages: json.containsKey("lhsRearFogLampImages")
          ? parseStringListNullable(json["lhsRearFogLampImages"])
          : null,

      rhsRearFogLamp: json.containsKey("rhsRearFogLamp")
          ? _s(json["rhsRearFogLamp"], def: null)
          : null,
      rhsRearFogLampImages: json.containsKey("rhsRearFogLampImages")
          ? parseStringListNullable(json["rhsRearFogLampImages"])
          : null,

      rearWiperWasherImages: json.containsKey("rearWiperWasherImages")
          ? parseStringListNullable(json["rearWiperWasherImages"])
          : null,

      cowlTopImages: json.containsKey("cowlTopImages")
          ? parseStringListNullable(json["cowlTopImages"])
          : null,
      firewallImages: json.containsKey("firewallImages")
          ? parseStringListNullable(json["firewallImages"])
          : null,

      lhsSideMember: json.containsKey("lhsSideMember")
          ? _s(json["lhsSideMember"], def: null)
          : null,
      rhsSideMember: json.containsKey("rhsSideMember")
          ? _s(json["rhsSideMember"], def: null)
          : null,

      commentsOnClusterMeter: json.containsKey("commentsOnClusterMeter")
          ? _s(json["commentsOnClusterMeter"], def: null)
          : null,

      irvm: json.containsKey("irvm") ? _s(json["irvm"], def: null) : null,
      dashboard: json.containsKey("dashboard")
          ? _s(json["dashboard"], def: null)
          : null,

      steeringMountedSystemControls:
          json.containsKey("steeringMountedSystemControls")
          ? _s(json["steeringMountedSystemControls"], def: null)
          : null,

      acImages: json.containsKey("acImages")
          ? parseStringListNullable(json["acImages"])
          : null,
      acCooling: json.containsKey("acCooling")
          ? _s(json["acCooling"], def: null)
          : null,

      driverSideKneeAirbag: json.containsKey("driverSideKneeAirbag")
          ? _s(json["driverSideKneeAirbag"], def: null)
          : null,
      coDriverKneeAirbag: json.containsKey("coDriverKneeAirbag")
          ? _s(json["coDriverKneeAirbag"], def: null)
          : null,

      rhsRearSideAirbags: json.containsKey("rhsRearSideAirbags")
          ? _s(json["rhsRearSideAirbags"], def: null)
          : null,
      lhsRearSideAirbags: json.containsKey("lhsRearSideAirbags")
          ? _s(json["lhsRearSideAirbags"], def: null)
          : null,

      driverSeat: json.containsKey("driverSeat")
          ? _s(json["driverSeat"], def: null)
          : null,
      coDriverSeat: json.containsKey("coDriverSeat")
          ? _s(json["coDriverSeat"], def: null)
          : null,

      frontCentreArmRest: json.containsKey("frontCentreArmRest")
          ? _s(json["frontCentreArmRest"], def: null)
          : null,
      thirdRowSeats: json.containsKey("thirdRowSeats")
          ? _s(json["thirdRowSeats"], def: null)
          : null,

      transmissionType: json.containsKey("transmissionType")
          ? _s(json["transmissionType"], def: null)
          : null,
      driveTrain: json.containsKey("driveTrain")
          ? _s(json["driveTrain"], def: null)
          : null,

      testDriveOdometerReadingImages:
          json.containsKey("testDriveOdometerReadingImages")
          ? parseStringListNullable(json["testDriveOdometerReadingImages"])
          : null,
      testDriveOdometerReadingInKms:
          json.containsKey("testDriveOdometerReadingInKms")
          ? _iN(json["testDriveOdometerReadingInKms"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "timestamp": timestamp,
    "emailAddress": emailAddress,
    "appointmentId": appointmentId,
    "city": city,
    "registrationType": registrationType,
    "rcBookAvailability": rcBookAvailability,
    "rcCondition": rcCondition,
    "registrationNumber": registrationNumber,
    "registrationDate": registrationDate,
    "fitnessTill": fitnessTill,
    "toBeScrapped": toBeScrapped,
    "registrationState": registrationState,
    "registeredRto": registeredRto,
    "ownerSerialNumber": ownerSerialNumber,
    "make": make,
    "model": model,
    "variant": variant,
    "engineNumber": engineNumber,
    "chassisNumber": chassisNumber,
    "registeredOwner": registeredOwner,
    "registeredAddressAsPerRc": registeredAddressAsPerRc,
    "yearMonthOfManufacture": yearMonthOfManufacture,
    "fuelType": fuelType,
    "cubicCapacity": cubicCapacity,
    "hypothecationDetails": hypothecationDetails,
    "mismatchInRc": mismatchInRc,
    "roadTaxValidity": roadTaxValidity,
    "taxValidTill": taxValidTill,
    "insurance": insurance,
    "insurancePolicyNumber": insurancePolicyNumber,
    "insuranceValidity": insuranceValidity,
    "noClaimBonus": noClaimBonus,
    "mismatchInInsurance": mismatchInInsurance,
    "duplicateKey": duplicateKey,
    "rtoNoc": rtoNoc,
    "rtoForm28": rtoForm28,
    "partyPeshi": partyPeshi,
    "additionalDetails": additionalDetails,
    "rcTaxToken": rcTaxToken,
    "insuranceCopy": insuranceCopy,
    "bothKeys": bothKeys,
    "form26GdCopyIfRcIsLost": form26GdCopyIfRcIsLost,

    "bonnet": bonnet,
    "frontWindshield": frontWindshield,
    "roof": roof,
    "frontBumper": frontBumper,
    "lhsHeadlamp": lhsHeadlamp,
    "lhsFoglamp": lhsFoglamp,
    "rhsHeadlamp": rhsHeadlamp,
    "rhsFoglamp": rhsFoglamp,
    "lhsFender": lhsFender,
    "lhsOrvm": lhsOrvm,
    "lhsAPillar": lhsAPillar,
    "lhsBPillar": lhsBPillar,
    "lhsCPillar": lhsCPillar,
    "lhsFrontAlloy": lhsFrontAlloy,
    "lhsFrontTyre": lhsFrontTyre,
    "lhsRearAlloy": lhsRearAlloy,
    "lhsRearTyre": lhsRearTyre,
    "lhsFrontDoor": lhsFrontDoor,
    "lhsRearDoor": lhsRearDoor,
    "lhsRunningBorder": lhsRunningBorder,
    "lhsQuarterPanel": lhsQuarterPanel,
    "rearBumper": rearBumper,
    "lhsTailLamp": lhsTailLamp,
    "rhsTailLamp": rhsTailLamp,
    "rearWindshield": rearWindshield,
    "bootDoor": bootDoor,
    "spareTyre": spareTyre,
    "bootFloor": bootFloor,
    "rhsRearAlloy": rhsRearAlloy,
    "rhsRearTyre": rhsRearTyre,
    "rhsFrontAlloy": rhsFrontAlloy,
    "rhsFrontTyre": rhsFrontTyre,
    "rhsQuarterPanel": rhsQuarterPanel,
    "rhsAPillar": rhsAPillar,
    "rhsBPillar": rhsBPillar,
    "rhsCPillar": rhsCPillar,
    "rhsRunningBorder": rhsRunningBorder,
    "rhsRearDoor": rhsRearDoor,
    "rhsFrontDoor": rhsFrontDoor,
    "rhsOrvm": rhsOrvm,
    "rhsFender": rhsFender,
    "comments": comments,

    "frontMain": frontMain,
    "bonnetImages": bonnetImages,
    "frontWindshieldImages": frontWindshieldImages,
    "roofImages": roofImages,
    "frontBumperImages": frontBumperImages,
    "lhsHeadlampImages": lhsHeadlampImages,
    "lhsFoglampImages": lhsFoglampImages,
    "rhsHeadlampImages": rhsHeadlampImages,
    "rhsFoglampImages": rhsFoglampImages,
    "lhsFront45Degree": lhsFront45Degree,
    "lhsFenderImages": lhsFenderImages,
    "lhsFrontAlloyImages": lhsFrontAlloyImages,
    "lhsFrontTyreImages": lhsFrontTyreImages,
    "lhsRunningBorderImages": lhsRunningBorderImages,
    "lhsOrvmImages": lhsOrvmImages,
    "lhsAPillarImages": lhsAPillarImages,
    "lhsFrontDoorImages": lhsFrontDoorImages,
    "lhsBPillarImages": lhsBPillarImages,
    "lhsRearDoorImages": lhsRearDoorImages,
    "lhsCPillarImages": lhsCPillarImages,
    "lhsRearTyreImages": lhsRearTyreImages,
    "lhsRearAlloyImages": lhsRearAlloyImages,
    "lhsQuarterPanelImages": lhsQuarterPanelImages,
    "rearMain": rearMain,
    "rearWithBootDoorOpen": rearWithBootDoorOpen,
    "rearBumperImages": rearBumperImages,
    "lhsTailLampImages": lhsTailLampImages,
    "rhsTailLampImages": rhsTailLampImages,
    "rearWindshieldImages": rearWindshieldImages,
    "spareTyreImages": spareTyreImages,
    "bootFloorImages": bootFloorImages,
    "rhsRear45Degree": rhsRear45Degree,
    "rhsQuarterPanelImages": rhsQuarterPanelImages,
    "rhsRearAlloyImages": rhsRearAlloyImages,
    "rhsRearTyreImages": rhsRearTyreImages,
    "rhsCPillarImages": rhsCPillarImages,
    "rhsRearDoorImages": rhsRearDoorImages,
    "rhsBPillarImages": rhsBPillarImages,
    "rhsFrontDoorImages": rhsFrontDoorImages,
    "rhsAPillarImages": rhsAPillarImages,
    "rhsRunningBorderImages": rhsRunningBorderImages,
    "rhsFrontAlloyImages": rhsFrontAlloyImages,
    "rhsFrontTyreImages": rhsFrontTyreImages,
    "rhsOrvmImages": rhsOrvmImages,
    "rhsFenderImages": rhsFenderImages,

    "upperCrossMember": upperCrossMember,
    "radiatorSupport": radiatorSupport,
    "headlightSupport": headlightSupport,
    "lowerCrossMember": lowerCrossMember,
    "lhsApron": lhsApron,
    "rhsApron": rhsApron,
    "firewall": firewall,
    "cowlTop": cowlTop,

    "engine": engine,
    "battery": battery,
    "coolant": coolant,
    "engineOilLevelDipstick": engineOilLevelDipstick,
    "engineOil": engineOil,
    "engineMount": engineMount,
    "enginePermisableBlowBy": enginePermisableBlowBy,
    "exhaustSmoke": exhaustSmoke,
    "clutch": clutch,
    "gearShift": gearShift,
    "commentsOnEngine": commentsOnEngine,
    "commentsOnEngineOil": commentsOnEngineOil,
    "commentsOnTowing": commentsOnTowing,
    "commentsOnTransmission": commentsOnTransmission,
    "commentsOnRadiator": commentsOnRadiator,
    "commentsOnOthers": commentsOnOthers,

    "engineBay": engineBay,
    "apronLhsRhs": apronLhsRhs,
    "batteryImages": batteryImages,
    "additionalImages": additionalImages,
    "engineSound": engineSound,
    "exhaustSmokeImages": exhaustSmokeImages,

    "steering": steering,
    "brakes": brakes,
    "suspension": suspension,
    "odometerReadingInKms": odometerReadingInKms,
    "fuelLevel": fuelLevel,
    "abs": abs,
    "electricals": electricals,
    "rearWiperWasher": rearWiperWasher,
    "rearDefogger": rearDefogger,
    "musicSystem": musicSystem,
    "stereo": stereo,
    "inbuiltSpeaker": inbuiltSpeaker,
    "externalSpeaker": externalSpeaker,
    "steeringMountedAudioControl": steeringMountedAudioControl,
    "noOfPowerWindows": noOfPowerWindows,
    "powerWindowConditionRhsFront": powerWindowConditionRhsFront,
    "powerWindowConditionLhsFront": powerWindowConditionLhsFront,
    "powerWindowConditionRhsRear": powerWindowConditionRhsRear,
    "powerWindowConditionLhsRear": powerWindowConditionLhsRear,
    "commentOnInterior": commentOnInterior,
    "noOfAirBags": noOfAirBags,
    "airbagFeaturesDriverSide": airbagFeaturesDriverSide,
    "airbagFeaturesCoDriverSide": airbagFeaturesCoDriverSide,
    "airbagFeaturesLhsAPillarCurtain": airbagFeaturesLhsAPillarCurtain,
    "airbagFeaturesLhsBPillarCurtain": airbagFeaturesLhsBPillarCurtain,
    "airbagFeaturesLhsCPillarCurtain": airbagFeaturesLhsCPillarCurtain,
    "airbagFeaturesRhsAPillarCurtain": airbagFeaturesRhsAPillarCurtain,
    "airbagFeaturesRhsBPillarCurtain": airbagFeaturesRhsBPillarCurtain,
    "airbagFeaturesRhsCPillarCurtain": airbagFeaturesRhsCPillarCurtain,
    "sunroof": sunroof,
    "leatherSeats": leatherSeats,
    "fabricSeats": fabricSeats,
    "commentsOnElectricals": commentsOnElectricals,
    "meterConsoleWithEngineOn": meterConsoleWithEngineOn,
    "airbags": airbags,
    "sunroofImages": sunroofImages,
    "frontSeatsFromDriverSideDoorOpen": frontSeatsFromDriverSideDoorOpen,
    "rearSeatsFromRightSideDoorOpen": rearSeatsFromRightSideDoorOpen,
    "dashboardFromRearSeat": dashboardFromRearSeat,
    "reverseCamera": reverseCamera,
    "additionalImages2": additionalImages2,
    "airConditioningManual": airConditioningManual,
    "airConditioningClimateControl": airConditioningClimateControl,
    "commentsOnAC": commentsOnAc,
    "approvedBy": approvedBy,
    "approvalDate": approvalDate,
    "approvalTime": approvalTime,
    "approvalStatus": approvalStatus,
    "contactNumber": contactNumber,
    "newArrivalMessage": newArrivalMessage,
    "budgetCar": budgetCar,
    "status": status,
    "priceDiscovery": priceDiscovery,
    "priceDiscoveryBy": priceDiscoveryBy,
    "latlong": latlong,
    "retailAssociate": retailAssociate,
    "kmRangeLevel": kmRangeLevel,
    "highestBidder": highestBidder,
    "__v": v,

    // ✅ nullable new fields
    "inspectionEngineerName": inspectionEngineerName,
    "chassisEmbossmentImages": chassisEmbossmentImages,
    "vinPlateImages": vinPlateImages,
    "color": color,
    "seatingCapacityAutoFetched": seatingCapacityAutoFetched,
    "seatingCapacityMandatory": seatingCapacityMandatory,
    "numberOfCylinders": numberOfCylinders,
    "bodyType": bodyType,
    "norms": norms,
    "vehicleCategory": vehicleCategory,
    "wheelBase": wheelBase,
    "grossVehicleWeight": grossVehicleWeight,
    "unladenWeight": unladenWeight,
    "roadTaxType": roadTaxType,
    "hypothecatorName": hypothecatorName,
    "pollutionCertificateImages": pollutionCertificateImages,
    "pollutionCertificateValidity": pollutionCertificateValidity,
    "pollutionCertificatePolicyNumber": pollutionCertificatePolicyNumber,
    "registrationCertificateStatus": registrationCertificateStatus,
    "blacklistStatus": blacklistStatus,
    "frontWiperWasher": frontWiperWasher,
    "frontWiperWasherImages": frontWiperWasherImages,
    "lhsFullView": lhsFullView,
    "rhsFullView": rhsFullView,
    "lhsRearFogLamp": lhsRearFogLamp,
    "lhsRearFogLampImages": lhsRearFogLampImages,
    "rhsRearFogLamp": rhsRearFogLamp,
    "rhsRearFogLampImages": rhsRearFogLampImages,
    "rearWiperWasherImages": rearWiperWasherImages,
    "cowlTopImages": cowlTopImages,
    "firewallImages": firewallImages,
    "lhsSideMember": lhsSideMember,
    "rhsSideMember": rhsSideMember,
    "commentsOnClusterMeter": commentsOnClusterMeter,
    "irvm": irvm,
    "dashboard": dashboard,
    "steeringMountedSystemControls": steeringMountedSystemControls,
    "acImages": acImages,
    "acCooling": acCooling,
    "driverSideKneeAirbag": driverSideKneeAirbag,
    "coDriverKneeAirbag": coDriverKneeAirbag,
    "rhsRearSideAirbags": rhsRearSideAirbags,
    "lhsRearSideAirbags": lhsRearSideAirbags,
    "driverSeat": driverSeat,
    "coDriverSeat": coDriverSeat,
    "frontCentreArmRest": frontCentreArmRest,
    "thirdRowSeats": thirdRowSeats,
    "transmissionType": transmissionType,
    "driveTrain": driveTrain,
    "testDriveOdometerReadingImages": testDriveOdometerReadingImages,
    "testDriveOdometerReadingInKms": testDriveOdometerReadingInKms,
  };
}

/// ---------- Helpers (same file) ----------

DateTime? parseMongoDbDate(dynamic v) {
  try {
    if (v == null) return null;

    if (v is String) {
      final maybeNum = int.tryParse(v);
      if (maybeNum != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          maybeNum,
          isUtc: true,
        ).toLocal();
      }
      final dt = DateTime.parse(v);
      return dt.isUtc ? dt.toLocal() : dt;
    }

    if (v is int) {
      return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true).toLocal();
    }

    if (v is Map) {
      final raw = v[r'$date'];
      if (raw == null) return null;

      if (raw is String) {
        final maybeNum = int.tryParse(raw);
        if (maybeNum != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            maybeNum,
            isUtc: true,
          ).toLocal();
        }
        final dt = DateTime.parse(raw);
        return dt.isUtc ? dt.toLocal() : dt;
      }

      if (raw is int) {
        return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true).toLocal();
      }

      if (raw is Map && raw[r'$numberLong'] != null) {
        final ms = int.tryParse(raw[r'$numberLong'].toString());
        if (ms != null) {
          return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
        }
      }
    }
  } catch (_) {}
  return null;
}

List<String> parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value.map((e) => e.toString()).toList();
  if (value is String && value.trim().isNotEmpty) return [value];
  return [];
}

List<String>? parseStringListNullable(dynamic value) {
  if (value == null) return null;
  final list = parseStringList(value);
  return list.isEmpty ? [] : list;
}

String _s(dynamic v, {String? def = 'N/A'}) {
  if (v == null) return def ?? '';
  final s = v.toString();
  if (s.trim().isEmpty) return def ?? '';
  return s;
}

int _i(dynamic v, {int def = 0}) {
  if (v == null) return def;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? def;
}

int? _iN(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}
