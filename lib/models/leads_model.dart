class LeadsData {
  // Mongo meta
  String? id;
  int? v;

  // Appointment
  String? appointmentId;
  String? appointmentSource;

  // Vehicle / Owner (REQUIRED in schema)
  String? carRegistrationNumber;
  String? yearOfRegistration;
  String? ownerName;
  int? ownershipSerialNumber;

  String? make;
  String? model;
  String? variant;

  // Vehicle meta
  String? yearOfManufacture;
  String? vehicleStatus;

  // Customer
  String? customerContactNumber;
  String? emailAddress;
  String? city;
  String? zipCode;

  // Allocation / Status
  String? allocatedTo;
  String? inspectionStatus;
  String? approvalStatus;
  String? priority;

  // Business references
  String? ncdUcdName;
  String? repName;
  String? repContact;
  String? bankSource;
  String? referenceName;

  // Notes / inspection
  int? odometerReadingInKms;
  String? remarks;
  String? additionalNotes;

  // Media
  List<String> carImages;

  // Inspection
  String? inspectionAddress;
  String? inspectionEngineerNumber;
  String? inspectionDateTime;

  // Meta
  String? addedBy;
  String? createdBy;
  String? timeStamp;
  String? createdAt;
  String? updatedAt;

  // Logs

  LeadsData({
    this.id,
    this.v,
    this.appointmentId,
    this.appointmentSource,

    this.carRegistrationNumber,
    this.yearOfRegistration,
    this.ownerName,
    this.ownershipSerialNumber,

    this.make,
    this.model,
    this.variant,

    this.yearOfManufacture,
    this.vehicleStatus,

    this.customerContactNumber,
    this.emailAddress,
    this.city,
    this.zipCode,

    this.allocatedTo,
    this.inspectionStatus,
    this.approvalStatus,
    this.priority,

    this.ncdUcdName,
    this.repName,
    this.repContact,
    this.bankSource,
    this.referenceName,

    this.odometerReadingInKms,
    this.remarks,
    this.additionalNotes,

    this.carImages = const [],

    this.inspectionAddress,
    this.inspectionEngineerNumber,
    this.inspectionDateTime,

    this.addedBy,
    this.createdBy,
    this.timeStamp,
    this.createdAt,
    this.updatedAt,
  });

  factory LeadsData.fromJson(Map<String, dynamic> json) {
    return LeadsData(
      id: json['_id']?.toString(),
      v: json['__v'] as int?,

      appointmentId: json['appointmentId']?.toString(),
      appointmentSource: json['appointmentSource']?.toString(),

      carRegistrationNumber: json['carRegistrationNumber']?.toString(),
      yearOfRegistration: json['yearOfRegistration']?.toString(),
      ownerName: json['ownerName']?.toString(),
      ownershipSerialNumber: json['ownershipSerialNumber'] as int?,

      make: json['make']?.toString(),
      model: json['model']?.toString(),
      variant: json['variant']?.toString(),

      yearOfManufacture: json['yearOfManufacture']?.toString(),
      vehicleStatus: json['vehicleStatus']?.toString(),

      customerContactNumber: json['customerContactNumber']?.toString(),
      emailAddress: json['emailAddress']?.toString(),
      city: json['city']?.toString(),
      zipCode: json['zipCode']?.toString(),

      allocatedTo: json['allocatedTo']?.toString(),
      inspectionStatus: json['inspectionStatus']?.toString(),
      approvalStatus: json['approvalStatus']?.toString(),
      priority: json['priority']?.toString(),

      ncdUcdName: json['ncdUcdName']?.toString(),
      repName: json['repName']?.toString(),
      repContact: json['repContact']?.toString(),
      bankSource: json['bankSource']?.toString(),
      referenceName: json['referenceName']?.toString(),

      odometerReadingInKms: json['odometerReadingInKms'] as int?,
      remarks: json['remarks']?.toString(),
      additionalNotes: json['additionalNotes']?.toString(),

      carImages:
          (json['carImages'] as List?)?.map((e) => e.toString()).toList() ?? [],

      inspectionAddress: json['inspectionAddress']?.toString(),
      inspectionEngineerNumber: json['inspectionEngineerNumber']?.toString(),
      inspectionDateTime: json['inspectionDateTime']?.toString(),

      addedBy: json['addedBy']?.toString(),
      createdBy: json['createdBy']?.toString(),
      timeStamp: json['timeStamp']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}
