import 'package:dartz/dartz.dart';
import 'package:habispace/core/error/failures.dart';
import 'package:habispace/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String name,
   required String email,
   required String password,
   required String passwordConfirmation,

  });
  Future<Either<Failure, String>> forgotPassword({required String email});

  Future<Either<Failure, String>> verifyOtp({required String email, required String otp});
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });
}
