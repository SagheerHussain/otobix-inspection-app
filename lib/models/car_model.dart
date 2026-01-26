// CarModel with Dropdown Type Comments
// This model contains both old fields (for backward compatibility) and new fields
// Old fields are kept to avoid breaking changes with existing app
// New fields ending with "DropdownList" are the updated versions

class CarModel {
  // ============================================================================
  // OLD FIELDS - Kept for backward compatibility
  // ============================================================================

  final String emailAddress; // renamed to ieName - MANDATORY (AUTO FETCH)
  final String city; // renamed to inspectionCity - SINGLE SELECT - MANDATORY ENTRY
  final String registrationType; // removed - DELETED
  final String
  rcBookAvailability; // changed to rcBookAvailabilityDropdownList - MULTIPLE - MANDATORY ENTRY

  final DateTime? fitnessTill; // renamed to fitnessValidity - AUTO FETCH

  final DateTime?
  yearMonthOfManufacture; // renamed to yearAndMonthOfManufacture - AUTO FETCH

  final String
  mismatchInRc; // changed to mismatchInRcDropdownList - MULTIPLE - MANDATORY ENTRY

  final String
  insurance; // changed to insuranceDropdownList - SINGLE - MANDATORY ENTRY
  final String insurancePolicyNumber; // renamed to policyNumber - AUTO FETCH
  final String noClaimBonus; // removed - DELETED
  final String
  mismatchInInsurance; // changed to mismatchInInsuranceDropdownList - MANDATORY ENTRY IF "INSURANCE" IS "THIRD PARTY || COMPREHENSIVE || ZERO DEPRECIATION"

  final String
  additionalDetails; // changed to additionalDetailsDropdownList - MULTIPLE - OPTIONAL ENTRY
  final List<String> rcTaxToken; // renamed to rcTokenImages - MANDATORY IMAGE
  final List<String>
  insuranceCopy; // renamed to insuranceImages - MANDATORY IMAGE
  final List<String>
  bothKeys; // renamed to duplicateKeyImages - MANDATORY ENTRY IF "DUPLICATE KEY" IS MARKED "AVAILABLE"
  final List<String>
  form26GdCopyIfRcIsLost; // renamed to form26AndGdCopyIfRcIsLostImages - MANDATORY IMAGE
  final String
  bonnet; // changed to bonnetDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  frontWindshield; // changed to frontWindshieldDropdownList - MULTIPLE - MANDATORY ENTRY
  final String roof; // changed to roofDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  frontBumper; // changed to frontBumperDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsHeadlamp; // changed to lhsHeadlampDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsFoglamp; // changed to lhsFoglampDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsHeadlamp; // changed to rhsHeadlampDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsFoglamp; // changed to rhsFoglampDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsFender; // changed to lhsFenderDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsOrvm; // changed to lhsOrvmDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsAPillar; // changed to lhsAPillarDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsBPillar; // changed to lhsBPillarDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsCPillar; // changed to lhsCPillarDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsFrontAlloy; // renamed to lhsFrontWheelDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsFrontTyre; // changed to lhsFrontTyreDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsRearAlloy; // renamed to lhsRearWheelDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsRearTyre; // changed to lhsRearTyreDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsFrontDoor; // changed to lhsFrontDoorDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsRearDoor; // changed to lhsRearDoorDropdownList - Note: Excel shows "LHS Rront Door" as MULTIPLE - MANDATORY ENTRY
  final String
  lhsRunningBorder; // changed to lhsRunningBorderDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsQuarterPanel; // changed to lhsQuarterPanelDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rearBumper; // changed to rearBumperDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsTailLamp; // changed to lhsTailLampDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsTailLamp; // changed to rhsTailLampDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rearWindshield; // changed to rearWindshieldDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  bootDoor; // changed to bootDoorDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  spareTyre; // changed to spareTyreDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  bootFloor; // changed to bootFloorDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsRearAlloy; // renamed to rhsRearWheelDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsRearTyre; // changed to rhsRearTyreDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsFrontAlloy; // renamed to rhsFrontWheelDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsFrontTyre; // changed to rhsFrontTyreDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsQuarterPanel; // changed to rhsQuarterPanelDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsAPillar; // changed to rhsAPillarDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsBPillar; // changed to rhsBPillarDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsCPillar; // changed to rhsCPillarDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsRunningBorder; // changed to rhsRunningBorderDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsRearDoor; // changed to rhsRearDoorDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsFrontDoor; // changed to rhsFrontDoorDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsOrvm; // changed to rhsOrvmDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsFender; // changed to rhsFenderDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  comments; // renamed to commentsOnExteriorDropdownList - MULTIPLE - OPTIONAL ENTRY
  final List<String> frontMain; // changed to frontMainImages - MANDATORY IMAGE
  final List<String>
  bonnetImages; // divided into bonnetClosedImages, bonnetOpenImages and bonnetImages - MANDATORY IMAGE

  final List<String>
  frontBumperImages; // divided into frontBumperLhs45DegreeImages, frontBumperRhs45DegreeImages and frontBumperImages - MANDATORY IMAGE

  final List<String>
  lhsFront45Degree; // renamed to lhsFullViewImages - MANDATORY IMAGE
  final List<String>
  lhsFrontAlloyImages; // renamed to lhsFrontWheelImages - MANDATORY IMAGE

  final List<String>
  lhsRearAlloyImages; // renamed to lhsRearWheelImages - MANDATORY IMAGE
  final List<String>
  lhsQuarterPanelImages; // divided into lhsQuarterPanelWithRearDoorOpenImages and lhsQuarterPanelImages - MANDATORY IMAGE
  final List<String> rearMain; // renamed to rearMainImages - MANDATORY IMAGE
  final String
  rearWithBootDoorOpen; // renamed to rearWithBootDoorOpenImages - MANDATORY IMAGE
  final List<String>
  rearBumperImages; // divided into rearBumperLhs45DegreeImages, rearBumperRhs45DegreeImages and rearBumperImages - MANDATORY IMAGE

  final List<String>
  rhsRear45Degree; // renamed to rhsFullViewImages - MANDATORY IMAGE
  final List<String>
  rhsQuarterPanelImages; // divided into rhsQuarterPanelWithRearDoorOpenImages and rhsQuarterPanelImages - MANDATORY IMAGE
  final List<String>
  rhsRearAlloyImages; // renamed to rhsRearWheelImages - MANDATORY IMAGE

  final List<String>
  rhsFrontAlloyImages; // renamed to rhsFrontWheelImages - MANDATORY IMAGE
  final String
  upperCrossMember; // changed to upperCrossMemberDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  radiatorSupport; // changed to radiatorSupportDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  headlightSupport; // changed to headlightSupportDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lowerCrossMember; // changed to lowerCrossMemberDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  lhsApron; // changed to lhsApronDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rhsApron; // changed to rhsApronDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  firewall; // changed to firewallDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  cowlTop; // changed to cowlTopDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  engine; // changed to engineDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  battery; // changed to batteryDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  coolant; // changed to coolantDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  engineOilLevelDipstick; // changed to engineOilLevelDipstickDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  engineOil; // changed to engineOilDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  engineMount; // changed to engineMountDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  enginePermisableBlowBy; // changed to enginePermisableBlowByDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  exhaustSmoke; // changed to exhaustSmokeDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  clutch; // changed to clutchDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  gearShift; // changed to gearShiftDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  commentsOnEngine; // changed to commentsOnEngineDropdownList - MULTIPLE - OPTIONAL ENTRY
  final String
  commentsOnEngineOil; // changed to commentsOnEngineOilDropdownList - MULTIPLE - OPTIONAL ENTRY
  final String
  commentsOnTowing; // changed to commentsOnTowingDropdownList - MULTIPLE - OPTIONAL ENTRY
  final String
  commentsOnTransmission; // changed to commentsOnTransmissionDropdownList - MULTIPLE - OPTIONAL ENTRY
  final String
  commentsOnRadiator; // changed to commentsOnRadiatorDropdownList - MULTIPLE - OPTIONAL ENTRY
  final String
  commentsOnOthers; // changed to commentsOnOthersDropdownList - MULTIPLE - OPTIONAL ENTRY
  final List<String> engineBay; // renamed to engineBayImages - MANDATORY IMAGE
  final List<String>
  apronLhsRhs; // removed apronLhsRhs and divided into lhsApronImages and rhsApronImages - MANDATORY IMAGE
  final List<String>
  additionalImages; // renamed to additionalEngineImages - OPTIONAL IMAGE
  final List<String> engineSound; // renamed to engineVideo - MANDATORY VIDEO
  final List<String>
  exhaustSmokeImages; // renamed to exhaustSmokeVideo - MANDATORY VIDEO
  final String steering; // changed to steeringDropdownList - MANDATORY ENTRY
  final String brakes; // changed to brakesDropdownList - MANDATORY ENTRY
  final String
  suspension; // changed to suspensionDropdownList - MANDATORY ENTRY
  final int
  odometerReadingInKms; // renamed to odometerReadingBeforeTestDrive - MANDATORY ENTRY

  final String electricals; // removed - DELETED
  final String
  rearWiperWasher; // changed to rearWiperWasherDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  rearDefogger; // changed to rearDefoggerDropdownList - MULTIPLE - MANDATORY ENTRY
  final String
  musicSystem; // removed and merged into infotainmentSystemDropdownList - MANDATORY ENTRY
  final String
  stereo; // removed and merged into infotainmentSystemDropdownList - MANDATORY ENTRY

  final String
  steeringMountedAudioControl; // removed and divided into steeringMountedMediaControls and steeringMountedSystemControls - SINGLE - MANDATORY ENTRY
  final String
  powerWindowConditionRhsFront; // renamed to rhsFrontDoorFeaturesDropdownList - MANDATORY ENTRY
  final String
  powerWindowConditionLhsFront; // renamed to lhsFrontDoorFeaturesDropdownList - MANDATORY ENTRY
  final String
  powerWindowConditionRhsRear; // renamed to rhsRearDoorFeaturesDropdownList - MANDATORY ENTRY
  final String
  powerWindowConditionLhsRear; // renamed to lhsRearDoorFeaturesDropdownList - MANDATORY ENTRY
  final String
  commentOnInterior; // changed to commentOnInteriorDropdownList - OPTIONAL ENTRY
  final String
  airbagFeaturesDriverSide; // renamed to driverAirbag - SINGLE - OPTIONAL ENTRY
  final String
  airbagFeaturesCoDriverSide; // renamed to coDriverAirbag - SINGLE - OPTIONAL ENTRY
  final String
  airbagFeaturesLhsAPillarCurtain; // renamed to coDriverSeatAirbag - SINGLE - OPTIONAL ENTRY
  final String
  airbagFeaturesLhsBPillarCurtain; // renamed to lhsCurtainAirbag - SINGLE - OPTIONAL ENTRY
  final String
  airbagFeaturesLhsCPillarCurtain; // renamed to lhsRearSideAirbag - SINGLE - OPTIONAL ENTRY
  final String
  airbagFeaturesRhsAPillarCurtain; // renamed to driverSeatAirbag - SINGLE - OPTIONAL ENTRY
  final String
  airbagFeaturesRhsBPillarCurtain; // renamed to rhsCurtainAirbag - SINGLE - OPTIONAL ENTRY
  final String
  airbagFeaturesRhsCPillarCurtain; // renamed to rhsRearSideAirbag - SINGLE - OPTIONAL ENTRY
  final String sunroof; // changed to sunroofDropdownList - MANDATORY ENTRY
  final String
  leatherSeats; // removed and merged to seatsUpholstery - MANDATORY ENTRY
  final String
  fabricSeats; // removed and merged to seatsUpholstery - MANDATORY ENTRY
  final String commentsOnElectricals; // removed - DELETED
  final List<String>
  meterConsoleWithEngineOn; // renamed to meterConsoleWithEngineOnImages - MANDATORY IMAGE
  final List<String>
  airbags; // renamed to airbagImages - MANDATORY IMAGE - IF "NUMBER OF POWER WINDOW IS "1 AND ABOVE"
  final List<String>
  frontSeatsFromDriverSideDoorOpen; // renamed to frontSeatsFromDriverSideImages - MANDATORY IMAGE
  final List<String>
  rearSeatsFromRightSideDoorOpen; // renamed to rearSeatsFromRightSideImages - MANDATORY IMAGE
  final List<String>
  dashboardFromRearSeat; // renamed to dashboardImages - MANDATORY IMAGE
  final String
  reverseCamera; // changed to reverseCameraDropdownList - MANDATORY ENTRY
  final List<String>
  additionalImages2; // renamed to additionalInteriorImages - OPTIONAL IMAGE
  final String
  airConditioningManual; // renamed to acTypeDropdownList - MANDATORY ENTRY
  final String
  airConditioningClimateControl; // renamed to acCoolingDropdownList - MANDATORY ENTRY

  // new named and new feilds
  final List<String> lhsFenderImages; // MANDATORY IMAGE
  final List<String> batteryImages; // MANDATORY IMAGE

  final List<String> sunroofImages; // MANDATORY IMAGE

  final String fuelLevel; // single select dropdown - SINGLE - MANDATORY ENTRY
  final String abs; // single select dropdown - SINGLE - MANDATORY ENTRY
  final String
  roadTaxValidity; // single select dropdown - SINGLE - MANDATORY ENTRY
  final DateTime?
  taxValidTill; // AUTO FETCH - TO SHOW ONLY IF "LIMITED PERIOD" IS SELECTED IN ROAD TAX VALIDITY
  final DateTime? insuranceValidity; // AUTO FETCH
  final String appointmentId; // AUTO GENERATED

  final String id; // AUTO
  final DateTime? timestamp; // AUTO

  final String fuelType; // SINGLE SELECT DROPDOWN - AUTO FETCH
  final int cubicCapacity; // AUTO FETCH
  final String hypothecationDetails; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String> frontWindshieldImages; // MANDATORY IMAGE
  final List<String> roofImages; // MANDATORY IMAGE
  final String
  rcCondition; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY IF RC AVAILABILITY IS MARKED "ORIGINAL/DUPLICATE"
  final String registrationNumber; // MANDATORY ENTRY
  final DateTime? registrationDate; // AUTO FETCH
  final String toBeScrapped; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final String registrationState; // AUTO FETCH
  final String registeredRto; // AUTO FETCH
  final int ownerSerialNumber; // AUTO FETCH
  final String make; // SINGLE SELECT DROPDOWN - AUTO FETCH
  final String model; // SINGLE SELECT DROPDOWN - AUTO FETCH
  final String variant; // SINGLE SELECT DROPDOWN - AUTO FETCH
  final String engineNumber; // AUTO FETCH
  final String chassisNumber; // AUTO FETCH
  final String registeredOwner; // AUTO FETCH
  final String registeredAddressAsPerRc; // AUTO FETCH
  final String duplicateKey; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final String rtoNoc; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final String
  rtoForm28; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY IF "RTO NOC" IS MENTIONED ANYTHING EXCEPT "NOT APPLICABLE"
  final String partyPeshi; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String> lhsHeadlampImages; // MANDATORY IMAGE
  final List<String> lhsFoglampImages; // MANDATORY IMAGE
  final List<String> rhsHeadlampImages; // MANDATORY IMAGE
  final List<String> rhsFoglampImages; // MANDATORY IMAGE
  final List<String> lhsFrontTyreImages; // MANDATORY IMAGE
  final List<String> lhsRunningBorderImages; // MANDATORY IMAGE
  final List<String> lhsOrvmImages; // MANDATORY IMAGE
  final List<String> lhsAPillarImages; // MANDATORY IMAGE
  final List<String> lhsFrontDoorImages; // MANDATORY IMAGE
  final List<String> lhsBPillarImages; // MANDATORY IMAGE
  final List<String> lhsRearDoorImages; // MANDATORY IMAGE
  final List<String> lhsCPillarImages; // MANDATORY IMAGE
  final List<String> lhsRearTyreImages; // MANDATORY IMAGE
  final List<String> lhsTailLampImages; // MANDATORY IMAGE
  final List<String> rhsTailLampImages; // MANDATORY IMAGE
  final List<String> rearWindshieldImages; // MANDATORY IMAGE
  final List<String> spareTyreImages; // MANDATORY IMAGE
  final List<String> bootFloorImages; // MANDATORY IMAGE
  final String noOfPowerWindows; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String> rhsRearTyreImages; // MANDATORY IMAGE
  final List<String> rhsCPillarImages; // MANDATORY IMAGE
  final List<String> rhsRearDoorImages; // MANDATORY IMAGE
  final List<String> rhsBPillarImages; // MANDATORY IMAGE
  final List<String> rhsFrontDoorImages; // MANDATORY IMAGE
  final List<String> rhsAPillarImages; // MANDATORY IMAGE
  final List<String> rhsRunningBorderImages; // MANDATORY IMAGE
  final List<String> rhsFrontTyreImages; // MANDATORY IMAGE
  final List<String> rhsOrvmImages; // MANDATORY IMAGE
  final List<String> rhsFenderImages; // MANDATORY IMAGE
  final int noOfAirBags; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final String inbuiltSpeaker; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final String externalSpeaker; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final String commentsOnAc; // SINGLE SELECT DROPDOWN - OPTIONAL ENTRY
  final String approvedBy; // AUTO
  final DateTime? approvalDate; // AUTO
  final DateTime? approvalTime; // AUTO
  final String approvalStatus; // AUTO
  final String contactNumber; // AUTO
  final DateTime? newArrivalMessage; // AUTO
  final String budgetCar; // AUTO
  final String status; // AUTO
  final int priceDiscovery; // AUTO
  final String priceDiscoveryBy; // AUTO
  final String latlong; // AUTO
  final String retailAssociate; // AUTO
  final int kmRangeLevel; // AUTO
  final String highestBidder; // AUTO
  final int v; // AUTO
  final String ieName; // AUTO FETCH
  final String
  inspectionCity; // SINGLE SELECT DROPDOWN - SINGLE - MANDATORY ENTRY

  // RC Book Section
  final List<String>
  rcBookAvailabilityDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final DateTime? fitnessValidity; // AUTO FETCH
  final DateTime? yearAndMonthOfManufacture; // AUTO FETCH
  final List<String>
  mismatchInRcDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  insuranceDropdownList; // SINGLE SELECT DROPDOWN (Note: Insurance field is SINGLE in Excel) - MANDATORY ENTRY
  final String policyNumber; // AUTO FETCH
  final List<String>
  mismatchInInsuranceDropdownList; // MULTIPLE SELECT DROPDOWN (Note: Not found in Excel, keeping as MULTIPLE based on naming) - MANDATORY ENTRY IF "INSURANCE" IS "THIRD PARTY || COMPREHENSIVE || ZERO DEPRECIATION"
  final List<String>
  additionalDetailsDropdownList; // MULTIPLE SELECT DROPDOWN - OPTIONAL ENTRY

  // Images
  final List<String> rcTokenImages; // MANDATORY IMAGE
  final List<String> insuranceImages; // MANDATORY IMAGE
  final List<String>
  duplicateKeyImages; // MANDATORY ENTRY IF "DUPLICATE KEY" IS MARKED "AVAILABLE"
  final List<String> form26AndGdCopyIfRcIsLostImages; // MANDATORY IMAGE

  // Exterior Body Parts - All MULTIPLE SELECT DROPDOWNS
  final List<String>
  bonnetDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  frontWindshieldDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  roofDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  frontBumperDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsHeadlampDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsFoglampDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsHeadlampDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsFoglampDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsFenderDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsOrvmDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsAPillarDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsBPillarDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsCPillarDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsFrontWheelDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsFrontTyreDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsRearWheelDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsRearTyreDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsFrontDoorDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsRearDoorDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsRunningBorderDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsQuarterPanelDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rearBumperDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsTailLampDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsTailLampDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rearWindshieldDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  bootDoorDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  spareTyreDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  bootFloorDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsRearWheelDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsRearTyreDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsFrontWheelDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsFrontTyreDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsQuarterPanelDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsAPillarDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsBPillarDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsCPillarDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsRunningBorderDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsRearDoorDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsFrontDoorDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsOrvmDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsFenderDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  commentsOnExteriorDropdownList; // MULTIPLE SELECT DROPDOWN - OPTIONAL ENTRY

  // Exterior Images
  final List<String> frontMainImages; // MANDATORY IMAGE
  final List<String> bonnetClosedImages; // MANDATORY IMAGE
  final List<String> bonnetOpenImages; // MANDATORY IMAGE
  final List<String> frontBumperLhs45DegreeImages; // MANDATORY IMAGE
  final List<String> frontBumperRhs45DegreeImages; // MANDATORY IMAGE
  final List<String> lhsFullViewImages; // MANDATORY IMAGE
  final List<String> lhsFrontWheelImages; // MANDATORY IMAGE
  final List<String> lhsRearWheelImages; // MANDATORY IMAGE
  final List<String> lhsQuarterPanelWithRearDoorOpenImages; // MANDATORY IMAGE
  final List<String> rearMainImages; // MANDATORY IMAGE
  final List<String> rearWithBootDoorOpenImages; // MANDATORY IMAGE
  final List<String> rearBumperLhs45DegreeImages; // MANDATORY IMAGE
  final List<String> rearBumperRhs45DegreeImages; // MANDATORY IMAGE
  final List<String> rhsFullViewImages; // MANDATORY IMAGE
  final List<String> rhsQuarterPanelWithRearDoorOpenImages; // MANDATORY IMAGE
  final List<String> rhsRearWheelImages; // MANDATORY IMAGE
  final List<String> rhsFrontWheelImages; // MANDATORY IMAGE

  // Engine Bay Components - All MULTIPLE SELECT DROPDOWNS
  final List<String>
  upperCrossMemberDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  radiatorSupportDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  headlightSupportDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lowerCrossMemberDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsApronDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsApronDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  firewallDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  cowlTopDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  engineDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  batteryDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  coolantDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  engineOilLevelDipstickDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  engineOilDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  engineMountDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  enginePermisableBlowByDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  exhaustSmokeDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  clutchDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  gearShiftDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  commentsOnEngineDropdownList; // MULTIPLE SELECT DROPDOWN - OPTIONAL ENTRY
  final List<String>
  commentsOnEngineOilDropdownList; // MULTIPLE SELECT DROPDOWN - OPTIONAL ENTRY
  final List<String>
  commentsOnTowingDropdownList; // MULTIPLE SELECT DROPDOWN - OPTIONAL ENTRY
  final List<String>
  commentsOnTransmissionDropdownList; // MULTIPLE SELECT DROPDOWN - OPTIONAL ENTRY
  final List<String>
  commentsOnRadiatorDropdownList; // MULTIPLE SELECT DROPDOWN - OPTIONAL ENTRY
  final List<String>
  commentsOnOthersDropdownList; // MULTIPLE SELECT DROPDOWN - OPTIONAL ENTRY

  // Engine Images
  final List<String> engineBayImages; // MANDATORY IMAGE
  final List<String> lhsApronImages; // MANDATORY IMAGE
  final List<String> rhsApronImages; // MANDATORY IMAGE
  final List<String> additionalEngineImages; // OPTIONAL IMAGE
  final List<String> engineVideo; // MANDATORY VIDEO
  final List<String> exhaustSmokeVideo; // MANDATORY VIDEO

  // Test Drive & Features
  final List<String>
  steeringDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  brakesDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  suspensionDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final int
  odometerReadingBeforeTestDrive; // SINGLE SELECT DROPDOWN (Note: Integer field, dropdown in Excel) - MANDATORY ENTRY
  final List<String>
  rearWiperWasherDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rearDefoggerDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  infotainmentSystemDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final String
  steeringMountedMediaControls; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final String
  steeringMountedSystemControls; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsFrontDoorFeaturesDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsFrontDoorFeaturesDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsRearDoorFeaturesDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  lhsRearDoorFeaturesDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  commentOnInteriorDropdownList; // SINGLE SELECT DROPDOWN - OPTIONAL ENTRY

  // Airbags - All SINGLE SELECT DROPDOWNS
  final String driverAirbag; // SINGLE SELECT DROPDOWN - OPTIONAL ENTRY
  final String coDriverAirbag; // SINGLE SELECT DROPDOWN - OPTIONAL ENTRY
  final String coDriverSeatAirbag; // SINGLE SELECT DROPDOWN - OPTIONAL ENTRY
  final String lhsCurtainAirbag; // SINGLE SELECT DROPDOWN - OPTIONAL ENTRY
  final String lhsRearSideAirbag; // SINGLE SELECT DROPDOWN - OPTIONAL ENTRY
  final String driverSeatAirbag; // SINGLE SELECT DROPDOWN - OPTIONAL ENTRY
  final String rhsCurtainAirbag; // SINGLE SELECT DROPDOWN - OPTIONAL ENTRY
  final String rhsRearSideAirbag; // SINGLE SELECT DROPDOWN - OPTIONAL ENTRY
  final List<String>
  sunroofDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final String seatsUpholstery; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY

  // Interior Images
  final List<String> meterConsoleWithEngineOnImages; // MANDATORY IMAGE
  final List<String>
  airbagImages; // MANDATORY IMAGE - IF "NUMBER OF POWER WINDOW IS "1 AND ABOVE"
  final List<String> frontSeatsFromDriverSideImages; // MANDATORY IMAGE
  final List<String> rearSeatsFromRightSideImages; // MANDATORY IMAGE
  final List<String> dashboardImages; // MANDATORY IMAGE
  final List<String>
  reverseCameraDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String> additionalInteriorImages; // OPTIONAL IMAGE

  // AC & Climate
  final String acTypeDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final String
  acCoolingDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY

  // Fresh Fields - Vehicle Details
  final List<String> chassisEmbossmentImages; // MANDATORY IMAGE
  final String
  chassisDetails; // MULTIPLE SELECT DROPDOWN - AUTO FETCH - MANDATORY ENTRY
  final List<String> vinPlateImages; // MANDATORY IMAGE
  final String
  vinPlateDetails; // SINGLE SELECT DROPDOWN - AUTO FETCH - MANDATORY ENTRY
  final List<String> roadTaxImages; // MANDATORY IMAGE
  final int seatingCapacity; // AUTO FETCH
  final String color; // AUTO FETCH
  final int numberOfCylinders; // AUTO FETCH
  final String norms; // AUTO FETCH
  final String hypothecatedTo; // AUTO FETCH
  final String insurer; // AUTO FETCH
  final List<String> pucImages; // MANDATORY IMAGE - AUTO FETCH
  final DateTime? pucValidity; // AUTO FETCH
  final String pucNumber; // AUTO FETCH
  final String rcStatus; // AUTO FETCH
  final String blacklistStatus; // AUTO FETCH
  final List<String>
  rtoNocImages; // MANDATORY IMAGE - IF "RTO NOC" IS MARKED "ISSUED" OR "EXPIRED"
  final List<String>
  rtoForm28Images; // MANDATORY IMAGE - IF "RTO FORM 28" IS MARKED "ISSUED" OR "EXPIRED"

  // Additional Features
  final List<String>
  frontWiperAndWasherDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY IMAGE
  final List<String> frontWiperAndWasherImages; // MANDATORY IMAGE
  final List<String>
  lhsRearFogLampDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY IMAGE
  final List<String> lhsRearFogLampImages; // MANDATORY IMAGE
  final List<String>
  rhsRearFogLampDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY IMAGE
  final List<String> rhsRearFogLampImages; // MANDATORY IMAGE
  final List<String> rearWiperAndWasherImages; // MANDATORY IMAGE
  final List<String>
  spareWheelDropdownList; // MULTIPLE SELECT DROPDOWN - MANDATORY IMAGE
  final List<String> spareWheelImages; // MANDATORY IMAGE
  final List<String> cowlTopImages; // MANDATORY IMAGE
  final List<String> firewallImages; // MANDATORY IMAGE
  final List<String>
  lhsSideMemberDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rhsSideMemberDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  transmissionTypeDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  driveTrainDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  commentsOnClusterMeterDropdownList; // SINGLE SELECT DROPDOWN - OPTIONAL ENTRY
  final String irvm; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  dashboardDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String> acImages; // MANDATORY IMAGE
  final List<String> reverseCameraImages; // MANDATORY IMAGE
  final String driverSideKneeAirbag; // SINGLE SELECT DROPDOWN - OPTIONAL ENTRY
  final String
  coDriverKneeSeatAirbag; // SINGLE SELECT DROPDOWN - OPTIONAL ENTRY
  final List<String>
  driverSeatDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  coDriverSeatDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  frontCentreArmRestDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  rearSeatsDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String>
  thirdRowSeatsDropdownList; // SINGLE SELECT DROPDOWN - MANDATORY ENTRY
  final List<String> odometerReadingAfterTestDriveImages; // MANDATORY IMAGE
  final int odometerReadingAfterTestDriveInKms; // MANDATORY ENTRY

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
    required this.ieName,
    required this.inspectionCity,
    required this.rcBookAvailabilityDropdownList,
    required this.fitnessValidity,
    required this.yearAndMonthOfManufacture,
    required this.mismatchInRcDropdownList,
    required this.insuranceDropdownList,
    required this.policyNumber,
    required this.mismatchInInsuranceDropdownList,
    required this.additionalDetailsDropdownList,
    required this.rcTokenImages,
    required this.insuranceImages,
    required this.duplicateKeyImages,
    required this.form26AndGdCopyIfRcIsLostImages,
    required this.bonnetDropdownList,
    required this.frontWindshieldDropdownList,
    required this.roofDropdownList,
    required this.frontBumperDropdownList,
    required this.lhsHeadlampDropdownList,
    required this.lhsFoglampDropdownList,
    required this.rhsHeadlampDropdownList,
    required this.rhsFoglampDropdownList,
    required this.lhsFenderDropdownList,
    required this.lhsOrvmDropdownList,
    required this.lhsAPillarDropdownList,
    required this.lhsBPillarDropdownList,
    required this.lhsCPillarDropdownList,
    required this.lhsFrontWheelDropdownList,
    required this.lhsFrontTyreDropdownList,
    required this.lhsRearWheelDropdownList,
    required this.lhsRearTyreDropdownList,
    required this.lhsFrontDoorDropdownList,
    required this.lhsRearDoorDropdownList,
    required this.lhsRunningBorderDropdownList,
    required this.lhsQuarterPanelDropdownList,
    required this.rearBumperDropdownList,
    required this.lhsTailLampDropdownList,
    required this.rhsTailLampDropdownList,
    required this.rearWindshieldDropdownList,
    required this.bootDoorDropdownList,
    required this.spareTyreDropdownList,
    required this.bootFloorDropdownList,
    required this.rhsRearWheelDropdownList,
    required this.rhsRearTyreDropdownList,
    required this.rhsFrontWheelDropdownList,
    required this.rhsFrontTyreDropdownList,
    required this.rhsQuarterPanelDropdownList,
    required this.rhsAPillarDropdownList,
    required this.rhsBPillarDropdownList,
    required this.rhsCPillarDropdownList,
    required this.rhsRunningBorderDropdownList,
    required this.rhsRearDoorDropdownList,
    required this.rhsFrontDoorDropdownList,
    required this.rhsOrvmDropdownList,
    required this.rhsFenderDropdownList,
    required this.commentsOnExteriorDropdownList,
    required this.frontMainImages,
    required this.bonnetClosedImages,
    required this.bonnetOpenImages,
    required this.frontBumperLhs45DegreeImages,
    required this.frontBumperRhs45DegreeImages,
    required this.lhsFullViewImages,
    required this.lhsFrontWheelImages,
    required this.lhsRearWheelImages,
    required this.lhsQuarterPanelWithRearDoorOpenImages,
    required this.rearMainImages,
    required this.rearWithBootDoorOpenImages,
    required this.rearBumperLhs45DegreeImages,
    required this.rearBumperRhs45DegreeImages,
    required this.rhsFullViewImages,
    required this.rhsQuarterPanelWithRearDoorOpenImages,
    required this.rhsRearWheelImages,
    required this.rhsFrontWheelImages,
    required this.upperCrossMemberDropdownList,
    required this.radiatorSupportDropdownList,
    required this.headlightSupportDropdownList,
    required this.lowerCrossMemberDropdownList,
    required this.lhsApronDropdownList,
    required this.rhsApronDropdownList,
    required this.firewallDropdownList,
    required this.cowlTopDropdownList,
    required this.engineDropdownList,
    required this.batteryDropdownList,
    required this.coolantDropdownList,
    required this.engineOilLevelDipstickDropdownList,
    required this.engineOilDropdownList,
    required this.engineMountDropdownList,
    required this.enginePermisableBlowByDropdownList,
    required this.exhaustSmokeDropdownList,
    required this.clutchDropdownList,
    required this.gearShiftDropdownList,
    required this.commentsOnEngineDropdownList,
    required this.commentsOnEngineOilDropdownList,
    required this.commentsOnTowingDropdownList,
    required this.commentsOnTransmissionDropdownList,
    required this.commentsOnRadiatorDropdownList,
    required this.commentsOnOthersDropdownList,
    required this.engineBayImages,
    required this.lhsApronImages,
    required this.rhsApronImages,
    required this.additionalEngineImages,
    required this.engineVideo,
    required this.exhaustSmokeVideo,
    required this.steeringDropdownList,
    required this.brakesDropdownList,
    required this.suspensionDropdownList,
    required this.odometerReadingBeforeTestDrive,
    required this.rearWiperWasherDropdownList,
    required this.rearDefoggerDropdownList,
    required this.infotainmentSystemDropdownList,
    required this.steeringMountedMediaControls,
    required this.steeringMountedSystemControls,
    required this.rhsFrontDoorFeaturesDropdownList,
    required this.lhsFrontDoorFeaturesDropdownList,
    required this.rhsRearDoorFeaturesDropdownList,
    required this.lhsRearDoorFeaturesDropdownList,
    required this.commentOnInteriorDropdownList,
    required this.driverAirbag,
    required this.coDriverAirbag,
    required this.coDriverSeatAirbag,
    required this.lhsCurtainAirbag,
    required this.lhsRearSideAirbag,
    required this.driverSeatAirbag,
    required this.rhsCurtainAirbag,
    required this.rhsRearSideAirbag,
    required this.sunroofDropdownList,
    required this.seatsUpholstery,
    required this.meterConsoleWithEngineOnImages,
    required this.airbagImages,
    required this.frontSeatsFromDriverSideImages,
    required this.rearSeatsFromRightSideImages,
    required this.dashboardImages,
    required this.reverseCameraDropdownList,
    required this.additionalInteriorImages,
    required this.acTypeDropdownList,
    required this.acCoolingDropdownList,
    required this.chassisEmbossmentImages,
    required this.chassisDetails,
    required this.vinPlateImages,
    required this.vinPlateDetails,
    required this.roadTaxImages,
    required this.seatingCapacity,
    required this.color,
    required this.numberOfCylinders,
    required this.norms,
    required this.hypothecatedTo,
    required this.insurer,
    required this.pucImages,
    required this.pucValidity,
    required this.pucNumber,
    required this.rcStatus,
    required this.blacklistStatus,
    required this.rtoNocImages,
    required this.rtoForm28Images,
    required this.frontWiperAndWasherDropdownList,
    required this.frontWiperAndWasherImages,
    required this.lhsRearFogLampDropdownList,
    required this.lhsRearFogLampImages,
    required this.rhsRearFogLampDropdownList,
    required this.rhsRearFogLampImages,
    required this.rearWiperAndWasherImages,
    required this.spareWheelDropdownList,
    required this.spareWheelImages,
    required this.cowlTopImages,
    required this.firewallImages,
    required this.lhsSideMemberDropdownList,
    required this.rhsSideMemberDropdownList,
    required this.transmissionTypeDropdownList,
    required this.driveTrainDropdownList,
    required this.commentsOnClusterMeterDropdownList,
    required this.irvm,
    required this.dashboardDropdownList,
    required this.acImages,
    required this.reverseCameraImages,
    required this.driverSideKneeAirbag,
    required this.coDriverKneeSeatAirbag,
    required this.driverSeatDropdownList,
    required this.coDriverSeatDropdownList,
    required this.frontCentreArmRestDropdownList,
    required this.rearSeatsDropdownList,
    required this.thirdRowSeatsDropdownList,
    required this.odometerReadingAfterTestDriveImages,
    required this.odometerReadingAfterTestDriveInKms,
  });

  factory CarModel.fromJson({
    required Map<String, dynamic> json,
    required String documentId,
  }) {
    return CarModel(
      id: documentId,
      timestamp: parseMongoDbDate(json["timestamp"]),
      emailAddress: json["emailAddress"] ?? 'N/A',
      appointmentId: json["appointmentId"] ?? 'N/A',
      city: json["city"] ?? 'N/A',
      registrationType: json["registrationType"] ?? 'N/A',
      rcBookAvailability: json["rcBookAvailability"] ?? 'N/A',
      rcCondition: json["rcCondition"] ?? 'N/A',
      registrationNumber: json["registrationNumber"] ?? 'N/A',
      registrationDate: parseMongoDbDate(json["registrationDate"]),
      fitnessTill: parseMongoDbDate(json["fitnessTill"]),
      toBeScrapped: json["toBeScrapped"] ?? 'N/A',
      registrationState: json["registrationState"] ?? 'N/A',
      registeredRto: json["registeredRto"] ?? 'N/A',
      ownerSerialNumber: json["ownerSerialNumber"] ?? 0,
      make: json["make"] ?? 'N/A',
      model: json["model"] ?? 'N/A',
      variant: json["variant"] ?? 'N/A',
      engineNumber: json["engineNumber"] ?? 'N/A',
      chassisNumber: json["chassisNumber"] ?? 'N/A',
      registeredOwner: json["registeredOwner"] ?? 'N/A',
      registeredAddressAsPerRc: json["registeredAddressAsPerRc"] ?? 'N/A',
      yearMonthOfManufacture: parseMongoDbDate(json["yearMonthOfManufacture"]),
      fuelType: json["fuelType"] ?? 'N/A',
      cubicCapacity: json["cubicCapacity"] ?? 0,
      hypothecationDetails: json["hypothecationDetails"] ?? 'N/A',
      mismatchInRc: json["mismatchInRc"] ?? 'N/A',
      roadTaxValidity: json["roadTaxValidity"] ?? 'N/A',
      taxValidTill: parseMongoDbDate(json["taxValidTill"]),
      insurance: json["insurance"] ?? 'N/A',
      insurancePolicyNumber: json["insurancePolicyNumber"] ?? 'N/A',
      insuranceValidity: parseMongoDbDate(json["insuranceValidity"]),
      noClaimBonus: json["noClaimBonus"] ?? 'N/A',
      mismatchInInsurance: json["mismatchInInsurance"] ?? 'N/A',
      duplicateKey: json["duplicateKey"] ?? 'N/A',
      rtoNoc: json["rtoNoc"] ?? 'N/A',
      rtoForm28: json["rtoForm28"] ?? 'N/A',
      partyPeshi: json["partyPeshi"] ?? 'N/A',
      additionalDetails: json["additionalDetails"] ?? 'N/A',
      rcTaxToken: parseStringList(json["rcTaxToken"]),
      insuranceCopy: parseStringList(json["insuranceCopy"]),
      bothKeys: parseStringList(json["bothKeys"]),
      form26GdCopyIfRcIsLost: parseStringList(json["form26GdCopyIfRcIsLost"]),
      bonnet: json["bonnet"] ?? 'N/A',
      frontWindshield: json["frontWindshield"] ?? 'N/A',
      roof: json["roof"] ?? 'N/A',
      frontBumper: json["frontBumper"] ?? 'N/A',
      lhsHeadlamp: json["lhsHeadlamp"] ?? 'N/A',
      lhsFoglamp: json["lhsFoglamp"] ?? 'N/A',
      rhsHeadlamp: json["rhsHeadlamp"] ?? 'N/A',
      rhsFoglamp: json["rhsFoglamp"] ?? 'N/A',
      lhsFender: json["lhsFender"] ?? 'N/A',
      lhsOrvm: json["lhsOrvm"] ?? 'N/A',
      lhsAPillar: json["lhsAPillar"] ?? 'N/A',
      lhsBPillar: json["lhsBPillar"] ?? 'N/A',
      lhsCPillar: json["lhsCPillar"] ?? 'N/A',
      lhsFrontAlloy: json["lhsFrontAlloy"] ?? 'N/A',
      lhsFrontTyre: json["lhsFrontTyre"] ?? 'N/A',
      lhsRearAlloy: json["lhsRearAlloy"] ?? 'N/A',
      lhsRearTyre: json["lhsRearTyre"] ?? 'N/A',
      lhsFrontDoor: json["lhsFrontDoor"] ?? 'N/A',
      lhsRearDoor: json["lhsRearDoor"] ?? 'N/A',
      lhsRunningBorder: json["lhsRunningBorder"] ?? 'N/A',
      lhsQuarterPanel: json["lhsQuarterPanel"] ?? 'N/A',
      rearBumper: json["rearBumper"] ?? 'N/A',
      lhsTailLamp: json["lhsTailLamp"] ?? 'N/A',
      rhsTailLamp: json["rhsTailLamp"] ?? 'N/A',
      rearWindshield: json["rearWindshield"] ?? 'N/A',
      bootDoor: json["bootDoor"] ?? 'N/A',
      spareTyre: json["spareTyre"] ?? 'N/A',
      bootFloor: json["bootFloor"] ?? 'N/A',
      rhsRearAlloy: json["rhsRearAlloy"] ?? 'N/A',
      rhsRearTyre: json["rhsRearTyre"] ?? 'N/A',
      rhsFrontAlloy: json["rhsFrontAlloy"] ?? 'N/A',
      rhsFrontTyre: json["rhsFrontTyre"] ?? 'N/A',
      rhsQuarterPanel: json["rhsQuarterPanel"] ?? 'N/A',
      rhsAPillar: json["rhsAPillar"] ?? 'N/A',
      rhsBPillar: json["rhsBPillar"] ?? 'N/A',
      rhsCPillar: json["rhsCPillar"] ?? 'N/A',
      rhsRunningBorder: json["rhsRunningBorder"] ?? 'N/A',
      rhsRearDoor: json["rhsRearDoor"] ?? 'N/A',
      rhsFrontDoor: json["rhsFrontDoor"] ?? 'N/A',
      rhsOrvm: json["rhsOrvm"] ?? 'N/A',
      rhsFender: json["rhsFender"] ?? 'N/A',
      comments: json["comments"] ?? 'N/A',
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
      rearWithBootDoorOpen: json["rearWithBootDoorOpen"] ?? 'N/A',
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
      upperCrossMember: json["upperCrossMember"] ?? 'N/A',
      radiatorSupport: json["radiatorSupport"] ?? 'N/A',
      headlightSupport: json["headlightSupport"] ?? 'N/A',
      lowerCrossMember: json["lowerCrossMember"] ?? 'N/A',
      lhsApron: json["lhsApron"] ?? 'N/A',
      rhsApron: json["rhsApron"] ?? 'N/A',
      firewall: json["firewall"] ?? 'N/A',
      cowlTop: json["cowlTop"] ?? 'N/A',
      engine: json["engine"] ?? 'N/A',
      battery: json["battery"] ?? 'N/A',
      coolant: json["coolant"] ?? 'N/A',
      engineOilLevelDipstick: json["engineOilLevelDipstick"] ?? 'N/A',
      engineOil: json["engineOil"] ?? 'N/A',
      engineMount: json["engineMount"] ?? 'N/A',
      enginePermisableBlowBy: json["enginePermisableBlowBy"] ?? 'N/A',
      exhaustSmoke: json["exhaustSmoke"] ?? 'N/A',
      clutch: json["clutch"] ?? 'N/A',
      gearShift: json["gearShift"] ?? 'N/A',
      commentsOnEngine: json["commentsOnEngine"] ?? 'N/A',
      commentsOnEngineOil: json["commentsOnEngineOil"] ?? 'N/A',
      commentsOnTowing: json["commentsOnTowing"] ?? 'N/A',
      commentsOnTransmission: json["commentsOnTransmission"] ?? 'N/A',
      commentsOnRadiator: json["commentsOnRadiator"] ?? 'N/A',
      commentsOnOthers: json["commentsOnOthers"] ?? 'N/A',
      engineBay: parseStringList(json["engineBay"]),
      apronLhsRhs: parseStringList(json["apronLhsRhs"]),
      batteryImages: parseStringList(json["batteryImages"]),
      additionalImages: parseStringList(json["additionalImages"]),
      engineSound: parseStringList(json["engineSound"]),
      exhaustSmokeImages: parseStringList(json["exhaustSmokeImages"]),
      steering: json["steering"] ?? 'N/A',
      brakes: json["brakes"] ?? 'N/A',
      suspension: json["suspension"] ?? 'N/A',
      odometerReadingInKms: json["odometerReadingInKms"] ?? 0,
      fuelLevel: json["fuelLevel"] ?? 'N/A',
      abs: json["abs"] ?? 'N/A',
      electricals: json["electricals"] ?? 'N/A',
      rearWiperWasher: json["rearWiperWasher"] ?? 'N/A',
      rearDefogger: json["rearDefogger"] ?? 'N/A',
      musicSystem: json["musicSystem"] ?? 'N/A',
      stereo: json["stereo"] ?? 'N/A',
      inbuiltSpeaker: json["inbuiltSpeaker"] ?? 'N/A',
      externalSpeaker: json["externalSpeaker"] ?? 'N/A',
      steeringMountedAudioControl: json["steeringMountedAudioControl"] ?? 'N/A',
      noOfPowerWindows: json["noOfPowerWindows"] ?? 'N/A',
      powerWindowConditionRhsFront:
          json["powerWindowConditionRhsFront"] ?? 'N/A',
      powerWindowConditionLhsFront:
          json["powerWindowConditionLhsFront"] ?? 'N/A',
      powerWindowConditionRhsRear: json["powerWindowConditionRhsRear"] ?? 'N/A',
      powerWindowConditionLhsRear: json["powerWindowConditionLhsRear"] ?? 'N/A',
      commentOnInterior: json["commentOnInterior"] ?? 'N/A',
      noOfAirBags: json["noOfAirBags"] ?? 0,
      airbagFeaturesDriverSide: json["airbagFeaturesDriverSide"] ?? 'N/A',
      airbagFeaturesCoDriverSide: json["airbagFeaturesCoDriverSide"] ?? 'N/A',
      airbagFeaturesLhsAPillarCurtain:
          json["airbagFeaturesLhsAPillarCurtain"] ?? 'N/A',
      airbagFeaturesLhsBPillarCurtain:
          json["airbagFeaturesLhsBPillarCurtain"] ?? 'N/A',
      airbagFeaturesLhsCPillarCurtain:
          json["airbagFeaturesLhsCPillarCurtain"] ?? 'N/A',
      airbagFeaturesRhsAPillarCurtain:
          json["airbagFeaturesRhsAPillarCurtain"] ?? 'N/A',
      airbagFeaturesRhsBPillarCurtain:
          json["airbagFeaturesRhsBPillarCurtain"] ?? 'N/A',
      airbagFeaturesRhsCPillarCurtain:
          json["airbagFeaturesRhsCPillarCurtain"] ?? 'N/A',
      sunroof: json["sunroof"] ?? 'N/A',
      leatherSeats: json["leatherSeats"] ?? 'N/A',
      fabricSeats: json["fabricSeats"] ?? 'N/A',
      commentsOnElectricals: json["commentsOnElectricals"] ?? 'N/A',
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
      reverseCamera: json["reverseCamera"] ?? 'N/A',
      additionalImages2: parseStringList(json["additionalImages2"]),
      airConditioningManual: json["airConditioningManual"] ?? 'N/A',
      airConditioningClimateControl:
          json["airConditioningClimateControl"] ?? 'N/A',
      commentsOnAc: json["commentsOnAC"] ?? 'N/A',
      approvedBy: json["approvedBy"] ?? 'N/A',
      approvalDate: parseMongoDbDate(json["approvalDate"]),
      approvalTime: parseMongoDbDate(json["approvalTime"]),
      approvalStatus: json["approvalStatus"] ?? 'N/A',
      contactNumber: json["contactNumber"] ?? 'N/A',
      newArrivalMessage: parseMongoDbDate(json["newArrivalMessage"]),
      budgetCar: json["budgetCar"] ?? 'N/A',
      status: json["status"] ?? 'N/A',
      priceDiscovery: json["priceDiscovery"] ?? 0,
      priceDiscoveryBy: json["priceDiscoveryBy"] ?? 'N/A',
      latlong: json["latlong"] ?? 'N/A',
      retailAssociate: json["retailAssociate"] ?? 'N/A',
      kmRangeLevel: json["kmRangeLevel"] ?? 0,
      highestBidder: json["highestBidder"] ?? 'N/A',
      v: json["__v"] ?? 0,

      // ✅ New fields all (nullable)
      ieName: json["ieName"] ?? 'N/A',
      inspectionCity: json["inspectionCity"] ?? 'N/A',
      rcBookAvailabilityDropdownList: parseStringList(
        json["rcBookAvailabilityDropdownList"],
      ),
      fitnessValidity: parseMongoDbDate(json["fitnessValidity"]),
      yearAndMonthOfManufacture: parseMongoDbDate(
        json["yearAndMonthOfManufacture"],
      ),
      mismatchInRcDropdownList: parseStringList(
        json["mismatchInRcDropdownList"],
      ),
      insuranceDropdownList: parseStringList(json["insuranceDropdownList"]),
      policyNumber: json["policyNumber"] ?? 'N/A',
      mismatchInInsuranceDropdownList: parseStringList(
        json["mismatchInInsuranceDropdownList"],
      ),
      additionalDetailsDropdownList: parseStringList(
        json["additionalDetailsDropdownList"],
      ),
      rcTokenImages: parseStringList(json["rcTokenImages"]),
      insuranceImages: parseStringList(json["insuranceImages"]),
      duplicateKeyImages: parseStringList(json["duplicateKeyImages"]),
      form26AndGdCopyIfRcIsLostImages: parseStringList(
        json["form26AndGdCopyIfRcIsLostImages"],
      ),
      bonnetDropdownList: parseStringList(json["bonnetDropdownList"]),
      frontWindshieldDropdownList: parseStringList(
        json["frontWindshieldDropdownList"],
      ),
      roofDropdownList: parseStringList(json["roofDropdownList"]),
      frontBumperDropdownList: parseStringList(json["frontBumperDropdownList"]),
      lhsHeadlampDropdownList: parseStringList(json["lhsHeadlampDropdownList"]),
      lhsFoglampDropdownList: parseStringList(json["lhsFoglampDropdownList"]),
      rhsHeadlampDropdownList: parseStringList(json["rhsHeadlampDropdownList"]),
      rhsFoglampDropdownList: parseStringList(json["rhsFoglampDropdownList"]),
      lhsFenderDropdownList: parseStringList(json["lhsFenderDropdownList"]),
      lhsOrvmDropdownList: parseStringList(json["lhsOrvmDropdownList"]),
      lhsAPillarDropdownList: parseStringList(json["lhsAPillarDropdownList"]),
      lhsBPillarDropdownList: parseStringList(json["lhsBPillarDropdownList"]),
      lhsCPillarDropdownList: parseStringList(json["lhsCPillarDropdownList"]),
      lhsFrontWheelDropdownList: parseStringList(
        json["lhsFrontWheelDropdownList"],
      ),
      lhsFrontTyreDropdownList: parseStringList(
        json["lhsFrontTyreDropdownList"],
      ),
      lhsRearWheelDropdownList: parseStringList(
        json["lhsRearWheelDropdownList"],
      ),
      lhsRearTyreDropdownList: parseStringList(json["lhsRearTyreDropdownList"]),
      lhsFrontDoorDropdownList: parseStringList(
        json["lhsFrontDoorDropdownList"],
      ),
      lhsRearDoorDropdownList: parseStringList(json["lhsRearDoorDropdownList"]),
      lhsRunningBorderDropdownList: parseStringList(
        json["lhsRunningBorderDropdownList"],
      ),
      lhsQuarterPanelDropdownList: parseStringList(
        json["lhsQuarterPanelDropdownList"],
      ),
      rearBumperDropdownList: parseStringList(json["rearBumperDropdownList"]),
      lhsTailLampDropdownList: parseStringList(json["lhsTailLampDropdownList"]),
      rhsTailLampDropdownList: parseStringList(json["rhsTailLampDropdownList"]),
      rearWindshieldDropdownList: parseStringList(
        json["rearWindshieldDropdownList"],
      ),
      bootDoorDropdownList: parseStringList(json["bootDoorDropdownList"]),
      spareTyreDropdownList: parseStringList(json["spareTyreDropdownList"]),
      bootFloorDropdownList: parseStringList(json["bootFloorDropdownList"]),
      rhsRearWheelDropdownList: parseStringList(
        json["rhsRearWheelDropdownList"],
      ),
      rhsRearTyreDropdownList: parseStringList(json["rhsRearTyreDropdownList"]),
      rhsFrontWheelDropdownList: parseStringList(
        json["rhsFrontWheelDropdownList"],
      ),
      rhsFrontTyreDropdownList: parseStringList(
        json["rhsFrontTyreDropdownList"],
      ),
      rhsQuarterPanelDropdownList: parseStringList(
        json["rhsQuarterPanelDropdownList"],
      ),
      rhsAPillarDropdownList: parseStringList(json["rhsAPillarDropdownList"]),
      rhsBPillarDropdownList: parseStringList(json["rhsBPillarDropdownList"]),
      rhsCPillarDropdownList: parseStringList(json["rhsCPillarDropdownList"]),
      rhsRunningBorderDropdownList: parseStringList(
        json["rhsRunningBorderDropdownList"],
      ),
      rhsRearDoorDropdownList: parseStringList(json["rhsRearDoorDropdownList"]),
      rhsFrontDoorDropdownList: parseStringList(
        json["rhsFrontDoorDropdownList"],
      ),
      rhsOrvmDropdownList: parseStringList(json["rhsOrvmDropdownList"]),
      rhsFenderDropdownList: parseStringList(json["rhsFenderDropdownList"]),
      commentsOnExteriorDropdownList: parseStringList(
        json["commentsOnExteriorDropdownList"],
      ),
      frontMainImages: parseStringList(json["frontMainImages"]),
      bonnetClosedImages: parseStringList(json["bonnetClosedImages"]),
      bonnetOpenImages: parseStringList(json["bonnetOpenImages"]),
      frontBumperLhs45DegreeImages: parseStringList(
        json["frontBumperLhs45DegreeImages"],
      ),
      frontBumperRhs45DegreeImages: parseStringList(
        json["frontBumperRhs45DegreeImages"],
      ),
      lhsFullViewImages: parseStringList(json["lhsFullViewImages"]),
      lhsFrontWheelImages: parseStringList(json["lhsFrontWheelImages"]),
      lhsRearWheelImages: parseStringList(json["lhsRearWheelImages"]),
      lhsQuarterPanelWithRearDoorOpenImages: parseStringList(
        json["lhsQuarterPanelWithRearDoorOpenImages"],
      ),
      rearMainImages: parseStringList(json["rearMainImages"]),
      rearWithBootDoorOpenImages: parseStringList(
        json["rearWithBootDoorOpenImages"],
      ),
      rearBumperLhs45DegreeImages: parseStringList(
        json["rearBumperLhs45DegreeImages"],
      ),
      rearBumperRhs45DegreeImages: parseStringList(
        json["rearBumperRhs45DegreeImages"],
      ),
      rhsFullViewImages: parseStringList(json["rhsFullViewImages"]),
      rhsQuarterPanelWithRearDoorOpenImages: parseStringList(
        json["rhsQuarterPanelWithRearDoorOpenImages"],
      ),
      rhsRearWheelImages: parseStringList(json["rhsRearWheelImages"]),
      rhsFrontWheelImages: parseStringList(json["rhsFrontWheelImages"]),
      upperCrossMemberDropdownList: parseStringList(
        json["upperCrossMemberDropdownList"],
      ),
      radiatorSupportDropdownList: parseStringList(
        json["radiatorSupportDropdownList"],
      ),
      headlightSupportDropdownList: parseStringList(
        json["headlightSupportDropdownList"],
      ),
      lowerCrossMemberDropdownList: parseStringList(
        json["lowerCrossMemberDropdownList"],
      ),
      lhsApronDropdownList: parseStringList(json["lhsApronDropdownList"]),
      rhsApronDropdownList: parseStringList(json["rhsApronDropdownList"]),
      firewallDropdownList: parseStringList(json["firewallDropdownList"]),
      cowlTopDropdownList: parseStringList(json["cowlTopDropdownList"]),
      engineDropdownList: parseStringList(json["engineDropdownList"]),
      batteryDropdownList: parseStringList(json["batteryDropdownList"]),
      coolantDropdownList: parseStringList(json["coolantDropdownList"]),
      engineOilLevelDipstickDropdownList: parseStringList(
        json["engineOilLevelDipstickDropdownList"],
      ),
      engineOilDropdownList: parseStringList(json["engineOilDropdownList"]),
      engineMountDropdownList: parseStringList(json["engineMountDropdownList"]),
      enginePermisableBlowByDropdownList: parseStringList(
        json["enginePermisableBlowByDropdownList"],
      ),
      exhaustSmokeDropdownList: parseStringList(
        json["exhaustSmokeDropdownList"],
      ),
      clutchDropdownList: parseStringList(json["clutchDropdownList"]),
      gearShiftDropdownList: parseStringList(json["gearShiftDropdownList"]),
      commentsOnEngineDropdownList: parseStringList(
        json["commentsOnEngineDropdownList"],
      ),
      commentsOnEngineOilDropdownList: parseStringList(
        json["commentsOnEngineOilDropdownList"],
      ),
      commentsOnTowingDropdownList: parseStringList(
        json["commentsOnTowingDropdownList"],
      ),
      commentsOnTransmissionDropdownList: parseStringList(
        json["commentsOnTransmissionDropdownList"],
      ),
      commentsOnRadiatorDropdownList: parseStringList(
        json["commentsOnRadiatorDropdownList"],
      ),
      commentsOnOthersDropdownList: parseStringList(
        json["commentsOnOthersDropdownList"],
      ),
      engineBayImages: parseStringList(json["engineBayImages"]),
      lhsApronImages: parseStringList(json["lhsApronImages"]),
      rhsApronImages: parseStringList(json["rhsApronImages"]),
      additionalEngineImages: parseStringList(json["additionalEngineImages"]),
      engineVideo: parseStringList(json["engineVideo"]),
      exhaustSmokeVideo: parseStringList(json["exhaustSmokeVideo"]),
      steeringDropdownList: parseStringList(json["steeringDropdownList"]),
      brakesDropdownList: parseStringList(json["brakesDropdownList"]),
      suspensionDropdownList: parseStringList(json["suspensionDropdownList"]),
      odometerReadingBeforeTestDrive:
          json["odometerReadingBeforeTestDrive"] ?? 0,
      rearWiperWasherDropdownList: parseStringList(
        json["rearWiperWasherDropdownList"],
      ),
      rearDefoggerDropdownList: parseStringList(
        json["rearDefoggerDropdownList"],
      ),
      infotainmentSystemDropdownList: parseStringList(
        json["infotainmentSystemDropdownList"],
      ),
      steeringMountedMediaControls:
          json["steeringMountedMediaControls"] ?? 'N/A',
      steeringMountedSystemControls:
          json["steeringMountedSystemControls"] ?? 'N/A',
      rhsFrontDoorFeaturesDropdownList: parseStringList(
        json["rhsFrontDoorFeaturesDropdownList"],
      ),
      lhsFrontDoorFeaturesDropdownList: parseStringList(
        json["lhsFrontDoorFeaturesDropdownList"],
      ),
      rhsRearDoorFeaturesDropdownList: parseStringList(
        json["rhsRearDoorFeaturesDropdownList"],
      ),
      lhsRearDoorFeaturesDropdownList: parseStringList(
        json["lhsRearDoorFeaturesDropdownList"],
      ),
      commentOnInteriorDropdownList: parseStringList(
        json["commentOnInteriorDropdownList"],
      ),
      driverAirbag: json["driverAirbag"] ?? 'N/A',
      coDriverAirbag: json["coDriverAirbag"] ?? 'N/A',
      coDriverSeatAirbag: json["coDriverSeatAirbag"] ?? 'N/A',
      lhsCurtainAirbag: json["lhsCurtainAirbag"] ?? 'N/A',
      lhsRearSideAirbag: json["lhsRearSideAirbag"] ?? 'N/A',
      driverSeatAirbag: json["driverSeatAirbag"] ?? 'N/A',
      rhsCurtainAirbag: json["rhsCurtainAirbag"] ?? 'N/A',
      rhsRearSideAirbag: json["rhsRearSideAirbag"] ?? 'N/A',
      sunroofDropdownList: parseStringList(json["sunroofDropdownList"]),
      seatsUpholstery: json["seatsUpholstery"] ?? 'N/A',
      meterConsoleWithEngineOnImages: parseStringList(
        json["meterConsoleWithEngineOnImages"],
      ),
      airbagImages: parseStringList(json["airbagImages"]),
      frontSeatsFromDriverSideImages: parseStringList(
        json["frontSeatsFromDriverSideImages"],
      ),
      rearSeatsFromRightSideImages: parseStringList(
        json["rearSeatsFromRightSideImages"],
      ),
      dashboardImages: parseStringList(json["dashboardImages"]),
      reverseCameraDropdownList: parseStringList(
        json["reverseCameraDropdownList"],
      ),
      additionalInteriorImages: parseStringList(
        json["additionalInteriorImages"],
      ),
      acTypeDropdownList: json["acTypeDropdownList"] ?? 'N/A',
      acCoolingDropdownList: json["acCoolingDropdownList"] ?? 'N/A',
      chassisEmbossmentImages: parseStringList(json["chassisEmbossmentImages"]),
      chassisDetails: json["chassisDetails"] ?? 'N/A',
      vinPlateImages: parseStringList(json["vinPlateImages"]),
      vinPlateDetails: json["vinPlateDetails"] ?? 'N/A',
      roadTaxImages: parseStringList(json["roadTaxImages"]),
      seatingCapacity: json["seatingCapacity"] ?? 0,
      color: json["color"] ?? 'N/A',
      numberOfCylinders: json["numberOfCylinders"] ?? 0,
      norms: json["norms"] ?? 'N/A',
      hypothecatedTo: json["hypothecatedTo"] ?? 'N/A',
      insurer: json["insurer"] ?? 'N/A',
      pucImages: parseStringList(json["pucImages"]),
      pucValidity: parseMongoDbDate(json["pucValidity"]),
      pucNumber: json["pucNumber"] ?? 'N/A',
      rcStatus: json["rcStatus"] ?? 'N/A',
      blacklistStatus: json["blacklistStatus"] ?? 'N/A',
      rtoNocImages: parseStringList(json["rtoNocImages"]),
      rtoForm28Images: parseStringList(json["rtoForm28Images"]),
      frontWiperAndWasherDropdownList: parseStringList(
        json["frontWiperAndWasherDropdownList"],
      ),
      frontWiperAndWasherImages: parseStringList(
        json["frontWiperAndWasherImages"],
      ),
      lhsRearFogLampDropdownList: parseStringList(
        json["lhsRearFogLampDropdownList"],
      ),
      lhsRearFogLampImages: parseStringList(json["lhsRearFogLampImages"]),
      rhsRearFogLampDropdownList: parseStringList(
        json["rhsRearFogLampDropdownList"],
      ),
      rhsRearFogLampImages: parseStringList(json["rhsRearFogLampImages"]),
      rearWiperAndWasherImages: parseStringList(
        json["rearWiperAndWasherImages"],
      ),
      spareWheelDropdownList: parseStringList(json["spareWheelDropdownList"]),
      spareWheelImages: parseStringList(json["spareWheelImages"]),
      cowlTopImages: parseStringList(json["cowlTopImages"]),
      firewallImages: parseStringList(json["firewallImages"]),
      lhsSideMemberDropdownList: parseStringList(
        json["lhsSideMemberDropdownList"],
      ),
      rhsSideMemberDropdownList: parseStringList(
        json["rhsSideMemberDropdownList"],
      ),
      transmissionTypeDropdownList: parseStringList(
        json["transmissionTypeDropdownList"],
      ),
      driveTrainDropdownList: parseStringList(json["driveTrainDropdownList"]),
      commentsOnClusterMeterDropdownList: parseStringList(
        json["commentsOnClusterMeterDropdownList"],
      ),
      irvm: json["irvm"] ?? 'N/A',
      dashboardDropdownList: parseStringList(json["dashboardDropdownList"]),
      acImages: parseStringList(json["acImages"]),
      reverseCameraImages: parseStringList(json["reverseCameraImages"]),
      driverSideKneeAirbag: json["driverSideKneeAirbag"] ?? 'N/A',
      coDriverKneeSeatAirbag: json["coDriverKneeSeatAirbag"] ?? 'N/A',
      driverSeatDropdownList: parseStringList(json["driverSeatDropdownList"]),
      coDriverSeatDropdownList: parseStringList(
        json["coDriverSeatDropdownList"],
      ),
      frontCentreArmRestDropdownList: parseStringList(
        json["frontCentreArmRestDropdownList"],
      ),
      rearSeatsDropdownList: parseStringList(json["rearSeatsDropdownList"]),
      thirdRowSeatsDropdownList: parseStringList(
        json["thirdRowSeatsDropdownList"],
      ),
      odometerReadingAfterTestDriveImages: parseStringList(
        json["odometerReadingAfterTestDriveImages"],
      ),
      odometerReadingAfterTestDriveInKms:
          json["odometerReadingAfterTestDriveInKms"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    // "_id": id?.toJson(),
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
    "rcTaxToken": rcTaxToken.map((x) => x).toList(),
    "insuranceCopy": insuranceCopy.map((x) => x).toList(),
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
    "frontMain": frontMain.map((x) => x).toList(),
    "bonnetImages": bonnetImages.map((x) => x).toList(),
    "frontWindshieldImages": frontWindshieldImages,
    "roofImages": roofImages,
    "frontBumperImages": frontBumperImages.map((x) => x).toList(),
    "lhsHeadlampImages": lhsHeadlampImages,
    "lhsFoglampImages": lhsFoglampImages,
    "rhsHeadlampImages": rhsHeadlampImages,
    "rhsFoglampImages": rhsFoglampImages,
    "lhsFront45Degree": lhsFront45Degree.map((x) => x).toList(),
    "lhsFenderImages": lhsFenderImages.map((x) => x).toList(),
    "lhsFrontAlloyImages": lhsFrontAlloyImages,
    "lhsFrontTyreImages": lhsFrontTyreImages.map((x) => x).toList(),
    "lhsRunningBorderImages": lhsRunningBorderImages.map((x) => x).toList(),
    "lhsOrvmImages": lhsOrvmImages,
    "lhsAPillarImages": lhsAPillarImages,
    "lhsFrontDoorImages": lhsFrontDoorImages.map((x) => x).toList(),
    "lhsBPillarImages": lhsBPillarImages,
    "lhsRearDoorImages": lhsRearDoorImages.map((x) => x).toList(),
    "lhsCPillarImages": lhsCPillarImages,
    "lhsRearTyreImages": lhsRearTyreImages.map((x) => x).toList(),
    "lhsRearAlloyImages": lhsRearAlloyImages,
    "lhsQuarterPanelImages": lhsQuarterPanelImages.map((x) => x).toList(),
    "rearMain": rearMain.map((x) => x).toList(),
    "rearWithBootDoorOpen": rearWithBootDoorOpen,
    "rearBumperImages": rearBumperImages.map((x) => x).toList(),
    "lhsTailLampImages": lhsTailLampImages,
    "rhsTailLampImages": rhsTailLampImages,
    "rearWindshieldImages": rearWindshieldImages,
    "spareTyreImages": spareTyreImages.map((x) => x).toList(),
    "bootFloorImages": bootFloorImages.map((x) => x).toList(),
    "rhsRear45Degree": rhsRear45Degree.map((x) => x).toList(),
    "rhsQuarterPanelImages": rhsQuarterPanelImages.map((x) => x).toList(),
    "rhsRearAlloyImages": rhsRearAlloyImages,
    "rhsRearTyreImages": rhsRearTyreImages,
    "rhsCPillarImages": rhsCPillarImages,
    "rhsRearDoorImages": rhsRearDoorImages.map((x) => x).toList(),
    "rhsBPillarImages": rhsBPillarImages,
    "rhsFrontDoorImages": rhsFrontDoorImages.map((x) => x).toList(),
    "rhsAPillarImages": rhsAPillarImages,
    "rhsRunningBorderImages": rhsRunningBorderImages.map((x) => x).toList(),
    "rhsFrontAlloyImages": rhsFrontAlloyImages,
    "rhsFrontTyreImages": rhsFrontTyreImages.map((x) => x).toList(),
    "rhsOrvmImages": rhsOrvmImages,
    "rhsFenderImages": rhsFenderImages.map((x) => x).toList(),
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
    "engineBay": engineBay.map((x) => x).toList(),
    "apronLhsRhs": apronLhsRhs.map((x) => x).toList(),
    "batteryImages": batteryImages.map((x) => x).toList(),
    "additionalImages": additionalImages,
    "engineSound": engineSound.map((x) => x).toList(),
    "exhaustSmokeImages": exhaustSmokeImages.map((x) => x).toList(),
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
    "meterConsoleWithEngineOn": meterConsoleWithEngineOn.map((x) => x).toList(),
    "airbags": airbags.map((x) => x).toList(),
    "sunroofImages": sunroofImages,
    "frontSeatsFromDriverSideDoorOpen": frontSeatsFromDriverSideDoorOpen
        .map((x) => x)
        .toList(),
    "rearSeatsFromRightSideDoorOpen": rearSeatsFromRightSideDoorOpen
        .map((x) => x)
        .toList(),
    "dashboardFromRearSeat": dashboardFromRearSeat.map((x) => x).toList(),
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

    // ✅ New fields all (nullable-safe)
    "ieName": ieName,
    "inspectionCity": inspectionCity,
    "rcBookAvailabilityDropdownList": rcBookAvailabilityDropdownList
        .map((x) => x)
        .toList(),
    "fitnessValidity": fitnessValidity,
    "yearAndMonthOfManufacture": yearAndMonthOfManufacture,
    "mismatchInRcDropdownList": mismatchInRcDropdownList.map((x) => x).toList(),
    "insuranceDropdownList": insuranceDropdownList.map((x) => x).toList(),
    "policyNumber": policyNumber,
    "mismatchInInsuranceDropdownList": mismatchInInsuranceDropdownList
        .map((x) => x)
        .toList(),
    "additionalDetailsDropdownList": additionalDetailsDropdownList
        .map((x) => x)
        .toList(),
    "rcTokenImages": rcTokenImages.map((x) => x).toList(),
    "insuranceImages": insuranceImages.map((x) => x).toList(),
    "duplicateKeyImages": duplicateKeyImages.map((x) => x).toList(),
    "form26AndGdCopyIfRcIsLostImages": form26AndGdCopyIfRcIsLostImages
        .map((x) => x)
        .toList(),
    "bonnetDropdownList": bonnetDropdownList.map((x) => x).toList(),
    "frontWindshieldDropdownList": frontWindshieldDropdownList
        .map((x) => x)
        .toList(),
    "roofDropdownList": roofDropdownList.map((x) => x).toList(),
    "frontBumperDropdownList": frontBumperDropdownList.map((x) => x).toList(),
    "lhsHeadlampDropdownList": lhsHeadlampDropdownList.map((x) => x).toList(),
    "lhsFoglampDropdownList": lhsFoglampDropdownList.map((x) => x).toList(),
    "rhsHeadlampDropdownList": rhsHeadlampDropdownList.map((x) => x).toList(),
    "rhsFoglampDropdownList": rhsFoglampDropdownList.map((x) => x).toList(),
    "lhsFenderDropdownList": lhsFenderDropdownList.map((x) => x).toList(),
    "lhsOrvmDropdownList": lhsOrvmDropdownList.map((x) => x).toList(),
    "lhsAPillarDropdownList": lhsAPillarDropdownList.map((x) => x).toList(),
    "lhsBPillarDropdownList": lhsBPillarDropdownList.map((x) => x).toList(),
    "lhsCPillarDropdownList": lhsCPillarDropdownList.map((x) => x).toList(),
    "lhsFrontWheelDropdownList": lhsFrontWheelDropdownList
        .map((x) => x)
        .toList(),
    "lhsFrontTyreDropdownList": lhsFrontTyreDropdownList.map((x) => x).toList(),
    "lhsRearWheelDropdownList": lhsRearWheelDropdownList.map((x) => x).toList(),
    "lhsRearTyreDropdownList": lhsRearTyreDropdownList.map((x) => x).toList(),
    "lhsFrontDoorDropdownList": lhsFrontDoorDropdownList.map((x) => x).toList(),
    "lhsRearDoorDropdownList": lhsRearDoorDropdownList.map((x) => x).toList(),
    "lhsRunningBorderDropdownList": lhsRunningBorderDropdownList
        .map((x) => x)
        .toList(),
    "lhsQuarterPanelDropdownList": lhsQuarterPanelDropdownList
        .map((x) => x)
        .toList(),
    "rearBumperDropdownList": rearBumperDropdownList.map((x) => x).toList(),
    "lhsTailLampDropdownList": lhsTailLampDropdownList.map((x) => x).toList(),
    "rhsTailLampDropdownList": rhsTailLampDropdownList.map((x) => x).toList(),
    "rearWindshieldDropdownList": rearWindshieldDropdownList
        .map((x) => x)
        .toList(),
    "bootDoorDropdownList": bootDoorDropdownList.map((x) => x).toList(),
    "spareTyreDropdownList": spareTyreDropdownList.map((x) => x).toList(),
    "bootFloorDropdownList": bootFloorDropdownList.map((x) => x).toList(),
    "rhsRearWheelDropdownList": rhsRearWheelDropdownList.map((x) => x).toList(),
    "rhsRearTyreDropdownList": rhsRearTyreDropdownList.map((x) => x).toList(),
    "rhsFrontWheelDropdownList": rhsFrontWheelDropdownList
        .map((x) => x)
        .toList(),
    "rhsFrontTyreDropdownList": rhsFrontTyreDropdownList.map((x) => x).toList(),
    "rhsQuarterPanelDropdownList": rhsQuarterPanelDropdownList
        .map((x) => x)
        .toList(),
    "rhsAPillarDropdownList": rhsAPillarDropdownList.map((x) => x).toList(),
    "rhsBPillarDropdownList": rhsBPillarDropdownList.map((x) => x).toList(),
    "rhsCPillarDropdownList": rhsCPillarDropdownList.map((x) => x).toList(),
    "rhsRunningBorderDropdownList": rhsRunningBorderDropdownList
        .map((x) => x)
        .toList(),
    "rhsRearDoorDropdownList": rhsRearDoorDropdownList.map((x) => x).toList(),
    "rhsFrontDoorDropdownList": rhsFrontDoorDropdownList.map((x) => x).toList(),
    "rhsOrvmDropdownList": rhsOrvmDropdownList.map((x) => x).toList(),
    "rhsFenderDropdownList": rhsFenderDropdownList.map((x) => x).toList(),
    "commentsOnExteriorDropdownList": commentsOnExteriorDropdownList
        .map((x) => x)
        .toList(),
    "frontMainImages": frontMainImages.map((x) => x).toList(),
    "bonnetClosedImages": bonnetClosedImages.map((x) => x).toList(),
    "bonnetOpenImages": bonnetOpenImages.map((x) => x).toList(),
    "frontBumperLhs45DegreeImages": frontBumperLhs45DegreeImages
        .map((x) => x)
        .toList(),
    "frontBumperRhs45DegreeImages": frontBumperRhs45DegreeImages
        .map((x) => x)
        .toList(),
    "lhsFullViewImages": lhsFullViewImages.map((x) => x).toList(),
    "lhsFrontWheelImages": lhsFrontWheelImages.map((x) => x).toList(),
    "lhsRearWheelImages": lhsRearWheelImages.map((x) => x).toList(),
    "lhsQuarterPanelWithRearDoorOpenImages":
        lhsQuarterPanelWithRearDoorOpenImages.map((x) => x).toList(),
    "rearMainImages": rearMainImages.map((x) => x).toList(),
    "rearWithBootDoorOpenImages": rearWithBootDoorOpenImages
        .map((x) => x)
        .toList(),
    "rearBumperLhs45DegreeImages": rearBumperLhs45DegreeImages
        .map((x) => x)
        .toList(),
    "rearBumperRhs45DegreeImages": rearBumperRhs45DegreeImages
        .map((x) => x)
        .toList(),
    "rhsFullViewImages": rhsFullViewImages.map((x) => x).toList(),
    "rhsQuarterPanelWithRearDoorOpenImages":
        rhsQuarterPanelWithRearDoorOpenImages.map((x) => x).toList(),
    "rhsRearWheelImages": rhsRearWheelImages.map((x) => x).toList(),
    "rhsFrontWheelImages": rhsFrontWheelImages.map((x) => x).toList(),
    "upperCrossMemberDropdownList": upperCrossMemberDropdownList
        .map((x) => x)
        .toList(),
    "radiatorSupportDropdownList": radiatorSupportDropdownList
        .map((x) => x)
        .toList(),
    "headlightSupportDropdownList": headlightSupportDropdownList
        .map((x) => x)
        .toList(),
    "lowerCrossMemberDropdownList": lowerCrossMemberDropdownList
        .map((x) => x)
        .toList(),
    "lhsApronDropdownList": lhsApronDropdownList.map((x) => x).toList(),
    "rhsApronDropdownList": rhsApronDropdownList.map((x) => x).toList(),
    "firewallDropdownList": firewallDropdownList.map((x) => x).toList(),
    "cowlTopDropdownList": cowlTopDropdownList.map((x) => x).toList(),
    "engineDropdownList": engineDropdownList.map((x) => x).toList(),
    "batteryDropdownList": batteryDropdownList.map((x) => x).toList(),
    "coolantDropdownList": coolantDropdownList.map((x) => x).toList(),
    "engineOilLevelDipstickDropdownList": engineOilLevelDipstickDropdownList
        .map((x) => x)
        .toList(),
    "engineOilDropdownList": engineOilDropdownList.map((x) => x).toList(),
    "engineMountDropdownList": engineMountDropdownList.map((x) => x).toList(),
    "enginePermisableBlowByDropdownList": enginePermisableBlowByDropdownList
        .map((x) => x)
        .toList(),
    "exhaustSmokeDropdownList": exhaustSmokeDropdownList.map((x) => x).toList(),
    "clutchDropdownList": clutchDropdownList.map((x) => x).toList(),
    "gearShiftDropdownList": gearShiftDropdownList.map((x) => x).toList(),
    "commentsOnEngineDropdownList": commentsOnEngineDropdownList
        .map((x) => x)
        .toList(),
    "commentsOnEngineOilDropdownList": commentsOnEngineOilDropdownList
        .map((x) => x)
        .toList(),
    "commentsOnTowingDropdownList": commentsOnTowingDropdownList
        .map((x) => x)
        .toList(),
    "commentsOnTransmissionDropdownList": commentsOnTransmissionDropdownList
        .map((x) => x)
        .toList(),
    "commentsOnRadiatorDropdownList": commentsOnRadiatorDropdownList
        .map((x) => x)
        .toList(),
    "commentsOnOthersDropdownList": commentsOnOthersDropdownList
        .map((x) => x)
        .toList(),
    "engineBayImages": engineBayImages.map((x) => x).toList(),
    "lhsApronImages": lhsApronImages.map((x) => x).toList(),
    "rhsApronImages": rhsApronImages.map((x) => x).toList(),
    "additionalEngineImages": additionalEngineImages.map((x) => x).toList(),
    "engineVideo": engineVideo.map((x) => x).toList(),
    "exhaustSmokeVideo": exhaustSmokeVideo.map((x) => x).toList(),
    "steeringDropdownList": steeringDropdownList.map((x) => x).toList(),
    "brakesDropdownList": brakesDropdownList.map((x) => x).toList(),
    "suspensionDropdownList": suspensionDropdownList.map((x) => x).toList(),
    "odometerReadingBeforeTestDrive": odometerReadingBeforeTestDrive,
    "rearWiperWasherDropdownList": rearWiperWasherDropdownList
        .map((x) => x)
        .toList(),
    "rearDefoggerDropdownList": rearDefoggerDropdownList.map((x) => x).toList(),
    "infotainmentSystemDropdownList": infotainmentSystemDropdownList
        .map((x) => x)
        .toList(),
    "steeringMountedMediaControls": steeringMountedMediaControls,
    "steeringMountedSystemControls": steeringMountedSystemControls,
    "rhsFrontDoorFeaturesDropdownList": rhsFrontDoorFeaturesDropdownList
        .map((x) => x)
        .toList(),
    "lhsFrontDoorFeaturesDropdownList": lhsFrontDoorFeaturesDropdownList
        .map((x) => x)
        .toList(),
    "rhsRearDoorFeaturesDropdownList": rhsRearDoorFeaturesDropdownList
        .map((x) => x)
        .toList(),
    "lhsRearDoorFeaturesDropdownList": lhsRearDoorFeaturesDropdownList
        .map((x) => x)
        .toList(),
    "commentOnInteriorDropdownList": commentOnInteriorDropdownList
        .map((x) => x)
        .toList(),
    "driverAirbag": driverAirbag,
    "coDriverAirbag": coDriverAirbag,
    "coDriverSeatAirbag": coDriverSeatAirbag,
    "lhsCurtainAirbag": lhsCurtainAirbag,
    "lhsRearSideAirbag": lhsRearSideAirbag,
    "driverSeatAirbag": driverSeatAirbag,
    "rhsCurtainAirbag": rhsCurtainAirbag,
    "rhsRearSideAirbag": rhsRearSideAirbag,
    "sunroofDropdownList": sunroofDropdownList.map((x) => x).toList(),
    "seatsUpholstery": seatsUpholstery,
    "meterConsoleWithEngineOnImages": meterConsoleWithEngineOnImages
        .map((x) => x)
        .toList(),
    "airbagImages": airbagImages.map((x) => x).toList(),
    "frontSeatsFromDriverSideImages": frontSeatsFromDriverSideImages
        .map((x) => x)
        .toList(),
    "rearSeatsFromRightSideImages": rearSeatsFromRightSideImages
        .map((x) => x)
        .toList(),
    "dashboardImages": dashboardImages.map((x) => x).toList(),
    "reverseCameraDropdownList": reverseCameraDropdownList
        .map((x) => x)
        .toList(),
    "additionalInteriorImages": additionalInteriorImages.map((x) => x).toList(),
    "acTypeDropdownList": acTypeDropdownList,
    "acCoolingDropdownList": acCoolingDropdownList,
    "chassisEmbossmentImages": chassisEmbossmentImages.map((x) => x).toList(),
    "chassisDetails": chassisDetails,
    "vinPlateImages": vinPlateImages.map((x) => x).toList(),
    "vinPlateDetails": vinPlateDetails,
    "roadTaxImages": roadTaxImages.map((x) => x).toList(),
    "seatingCapacity": seatingCapacity,
    "color": color,
    "numberOfCylinders": numberOfCylinders,
    "norms": norms,
    "hypothecatedTo": hypothecatedTo,
    "insurer": insurer,
    "pucImages": pucImages.map((x) => x).toList(),
    "pucValidity": pucValidity,
    "pucNumber": pucNumber,
    "rcStatus": rcStatus,
    "blacklistStatus": blacklistStatus,
    "rtoNocImages": rtoNocImages.map((x) => x).toList(),
    "rtoForm28Images": rtoForm28Images.map((x) => x).toList(),
    "frontWiperAndWasherDropdownList": frontWiperAndWasherDropdownList
        .map((x) => x)
        .toList(),
    "frontWiperAndWasherImages": frontWiperAndWasherImages
        .map((x) => x)
        .toList(),
    "lhsRearFogLampDropdownList": lhsRearFogLampDropdownList
        .map((x) => x)
        .toList(),
    "lhsRearFogLampImages": lhsRearFogLampImages.map((x) => x).toList(),
    "rhsRearFogLampDropdownList": rhsRearFogLampDropdownList
        .map((x) => x)
        .toList(),
    "rhsRearFogLampImages": rhsRearFogLampImages.map((x) => x).toList(),
    "rearWiperAndWasherImages": rearWiperAndWasherImages.map((x) => x).toList(),
    "spareWheelDropdownList": spareWheelDropdownList.map((x) => x).toList(),
    "spareWheelImages": spareWheelImages.map((x) => x).toList(),
    "cowlTopImages": cowlTopImages.map((x) => x).toList(),
    "firewallImages": firewallImages.map((x) => x).toList(),
    "lhsSideMemberDropdownList": lhsSideMemberDropdownList
        .map((x) => x)
        .toList(),
    "rhsSideMemberDropdownList": rhsSideMemberDropdownList
        .map((x) => x)
        .toList(),
    "transmissionTypeDropdownList": transmissionTypeDropdownList
        .map((x) => x)
        .toList(),
    "driveTrainDropdownList": driveTrainDropdownList.map((x) => x).toList(),
    "commentsOnClusterMeterDropdownList": commentsOnClusterMeterDropdownList
        .map((x) => x)
        .toList(),
    "irvm": irvm,
    "dashboardDropdownList": dashboardDropdownList.map((x) => x).toList(),
    "acImages": acImages.map((x) => x).toList(),
    "reverseCameraImages": reverseCameraImages.map((x) => x).toList(),
    "driverSideKneeAirbag": driverSideKneeAirbag,
    "coDriverKneeSeatAirbag": coDriverKneeSeatAirbag,
    "driverSeatDropdownList": driverSeatDropdownList.map((x) => x).toList(),
    "coDriverSeatDropdownList": coDriverSeatDropdownList.map((x) => x).toList(),
    "frontCentreArmRestDropdownList": frontCentreArmRestDropdownList
        .map((x) => x)
        .toList(),
    "rearSeatsDropdownList": rearSeatsDropdownList.map((x) => x).toList(),
    "thirdRowSeatsDropdownList": thirdRowSeatsDropdownList
        .map((x) => x)
        .toList(),
    "odometerReadingAfterTestDriveImages": odometerReadingAfterTestDriveImages
        .map((x) => x)
        .toList(),
    "odometerReadingAfterTestDriveInKms": odometerReadingAfterTestDriveInKms,
  };
}

DateTime? parseMongoDbDate(dynamic v) {
  try {
    if (v == null) return null;

    // 1) ISO string: "2025-08-11T10:50:00.000Z" or "+00:00" or no offset
    if (v is String) {
      // numeric string? treat as epoch ms
      final maybeNum = int.tryParse(v);
      if (maybeNum != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          maybeNum,
          isUtc: true,
        ).toLocal();
      }

      final dt = DateTime.parse(
        v,
      ); // Dart sets isUtc=true if Z or +/-offset present
      return dt.isUtc ? dt.toLocal() : dt; // normalize to local
    }

    // 2) Epoch milliseconds (int)
    if (v is int) {
      return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true).toLocal();
    }

    // 3) Extended JSON: {"$date": "..."} or {"$date": 1723363800000} or {"$date":{"$numberLong":"..."}}
    if (v is Map) {
      final raw = v[r'$date'];
      if (raw == null) return null;

      if (raw is String) {
        // could be ISO or numeric string
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
  } catch (e) {
    // optional: debugPrint('parseMongoDbDate error: $e  (value: $v)');
  }
  return null;
}

// DateTime? parseMongoDbDate(dynamic dateJson) {
//   try {
//     if (dateJson == null) return null;

//     if (dateJson is String) {
//       return DateTime.tryParse(dateJson);
//     }

//     if (dateJson is Map<String, dynamic> && dateJson['\$date'] is String) {
//       return DateTime.tryParse(dateJson['\$date']);
//     }

//     if (dateJson is Map<String, dynamic> &&
//         dateJson['\$date'] is Map<String, dynamic>) {
//       final millisStr = dateJson['\$date']['\$numberLong'];
//       final millis = int.tryParse(millisStr ?? '');
//       return millis != null
//           ? DateTime.fromMillisecondsSinceEpoch(millis)
//           : null;
//     }
//   } catch (e) {
//     print('parseMongoDbDate error: $e');
//   }

//   return null;
// }

List<String> parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value.map((e) => e.toString()).toList();
  //   if (value is String) return [value];
  if (value is String && value.trim().isNotEmpty) return [value];
  return [];
}
