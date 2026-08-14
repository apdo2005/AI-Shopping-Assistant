import 'package:ai_shopping_assistant/features/profile/domain/entities/profile_update_result.dart';
import 'package:dartz/dartz.dart';

import '../entities/profile_entity.dart';

import '../usecases/update_profile_usecase.dart';

abstract class ProfileRepository {
  Future<Either<String, ProfileEntity>> getProfile();
  Future<Either<String, String>> uploadProfileImage(String filePath);
  Future<Either<String, ProfileUpdateResult>> updateProfileInfo(
    UpdateProfileParams params,
  );
}
