import 'package:dartz/dartz.dart';

import '../repositories/profile_repository.dart';

class UploadProfileImageUseCase {
  final ProfileRepository repository;

  UploadProfileImageUseCase(this.repository);

  Future<Either<String, String>> execute(String filePath) =>
      repository.uploadProfileImage(filePath);
}
