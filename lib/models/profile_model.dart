class ProfileResponseModel {
  final bool success;
  final String message;
  final ProfileModel? profile;

  ProfileResponseModel({
    required this.success,
    required this.message,
    required this.profile,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ProfileModel {
  final String role;
  final String name;
  final String email;
  final String phoneNumber;
  final String image;
  final String location;
  final List<String> addressList;

  ProfileModel({
    required this.role,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.image,
    required this.location,
    required this.addressList,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      role: (json['role'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      addressList: (json['addressList'] is List)
          ? List<String>.from(
              (json['addressList'] as List).map((e) => e.toString()),
            )
          : <String>[],
    );
  }
}
