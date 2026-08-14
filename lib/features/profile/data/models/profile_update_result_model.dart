import '../../domain/entities/profile_update_result.dart';

class ProfileUpdateResultModel extends ProfileUpdateResult {
  const ProfileUpdateResultModel({
    required super.id,
    required super.username,
    required super.firstName,
    required super.lastName,
    required super.fullName,
    required super.gender,
    required super.birthday,
    required super.email,
    required super.phone,
    required super.countryCode,
    required super.preferredLanguages,
    required super.profileImageUrl,
  });

  factory ProfileUpdateResultModel.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResultModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username']?.toString() ?? '',
      firstName: _nullableString(json['firstname']),
      lastName: _nullableString(json['lastname']),
      fullName: _nullableString(json['full_name']),
      gender: _nullableString(json['gender']),
      birthday: _nullableString(json['birthday']),
      email: json['email']?.toString() ?? '',
      phone: _nullableString(json['phone']),
      countryCode: _nullableString(json['country_code']),
      preferredLanguages: (json['preferred_languages'] is List
              ? json['preferred_languages'] as List
              : const [])
          .map((language) => language.toString())
          .toList(),
      profileImageUrl: _nullableString(json['profile_image_url']),
    );
  }
}

String? _nullableString(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
