import 'package:ai_shopping_assistant/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:dartz/dartz.dart';

import 'package:ai_shopping_assistant/core/error/exceptions.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/profile_update_result.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile_usecase.dart';


class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, ProfileEntity>> getProfile() async {
    try {
      return Right(await remoteDataSource.getProfile());
    } on AppException catch (error) {
      return Left(error.message);
    } catch (_) {
      return const Left('Unable to load your profile. Please try again.');
    }
  }

  @override
  Future<Either<String, String>> uploadProfileImage(String filePath) async {
    try {
      return Right(await remoteDataSource.uploadProfileImage(filePath));
    } on AppException catch (error) {
      return Left(error.message);
    } catch (_) {
      return const Left('Unable to upload the profile image. Please try again.');
    }
  }

  @override
  Future<Either<String, ProfileUpdateResult>> updateProfileInfo(
    UpdateProfileParams params,
  ) async {
    try {
      return Right(await remoteDataSource.updateProfileInfo(params));
    } on AppException catch (error) {
      return Left(error.message);
    } catch (_) {
      return const Left('Unable to update your profile. Please try again.');
    }
  }
}
