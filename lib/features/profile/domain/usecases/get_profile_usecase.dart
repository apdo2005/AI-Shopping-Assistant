import 'package:ai_shopping_assistant/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

import '../entities/profile_entity.dart';


class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<String, ProfileEntity>> execute() => repository.getProfile();
}
