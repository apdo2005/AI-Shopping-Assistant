/// Represents the fields returned by `PUT /profile/info`.
///
/// This intentionally does NOT extend [ProfileUserEntity] because the update
/// response does not include every field the GET /profile endpoint returns
/// (e.g. email_verified, phone_verified are absent). Keeping it separate
/// avoids silently overwriting fields we have no confirmed value for.
class ProfileUpdateResult {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? gender;
  final String? birthday;
  final String email;
  final String? phone;
  final String? countryCode;
  final List<String> preferredLanguages;
  final String? profileImageUrl;

  const ProfileUpdateResult({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.gender,
    required this.birthday,
    required this.email,
    required this.phone,
    required this.countryCode,
    required this.preferredLanguages,
    required this.profileImageUrl,
  });
}
