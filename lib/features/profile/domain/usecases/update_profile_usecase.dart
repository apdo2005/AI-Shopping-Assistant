import 'package:dartz/dartz.dart';

import '../entities/profile_update_result.dart';
import '../repositories/profile_repository.dart';

/// Request params for `PUT /profile/info`.
///
/// Only fields confirmed in the Postman collection are included:
/// username, firstname, lastname, email, phone, country_code,
/// preferred_languages[0]. Gender and birthday are intentionally excluded.
class UpdateProfileParams {
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String countryCode;
  final String? preferredLanguage;

  const UpdateProfileParams({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.countryCode,
    this.preferredLanguage,
  });
}

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<String, ProfileUpdateResult>> execute(
    UpdateProfileParams params,
  ) =>
      repository.updateProfileInfo(params);
}
