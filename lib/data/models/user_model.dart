class UserModel {
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? countryCode;
  final String? country;
  final String? profileImage;
  final String? dob;
  final String? gender;
  final String? status;
  final List<String> roles;
  final List<dynamic> riderBankInformation;

  UserModel({
    this.name,
    this.email,
    this.phoneNumber,
    this.countryCode,
    this.country,
    this.profileImage,
    this.dob,
    this.gender,
    this.status,
    required this.roles,
    required this.riderBankInformation,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      countryCode: json['country_code'],
      country: json['country'],
      profileImage: json['profile_image'],
      dob: json['dob'],
      gender: json['gender'],
      status: json['status'],
      roles: json['role'] != null ? List<String>.from(json['role']) : [],
      riderBankInformation: json['rider_bank_information'] ?? [],
    );
  }
}
