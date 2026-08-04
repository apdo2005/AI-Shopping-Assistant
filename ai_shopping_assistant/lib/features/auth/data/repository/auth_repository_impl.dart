import 'package:dartz/dartz.dart';
import 'package:habispace/core/constants/secure_storage.dart';
import 'package:habispace/core/error/exceptions.dart';
import 'package:habispace/core/error/failures.dart';
import 'package:habispace/features/auth/data/datasource/auth_datasource.dart';
import 'package:habispace/features/auth/domain/entities/user_entity.dart';
import 'package:habispace/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _authDatasource;

  AuthRepositoryImpl({required AuthDatasource authDatasource})
    : _authDatasource = authDatasource;

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authDatasource.signInWithEmail(
        email: email,
        password: password,
      );

      if (user.token != null) {
        final secureStorage = SecureStorage();
        await secureStorage.setString(SecureKeys.token, user.token!);
        await AuthStorage().init();
      }

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final user = await _authDatasource.signUpWithEmail(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (user.token != null) {
        final secureStorage = SecureStorage();
        await secureStorage.setString(SecureKeys.token, user.token!);
        await AuthStorage().init();
      }
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword({required String email}) async {
    try {
      final message = await _authDatasource.forgotPassword(email: email);
      return Right(message);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final message = await _authDatasource.verifyOtp(email: email, otp: otp);
      return Right(message);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String otp,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _authDatasource.resetPassword(
        otp: otp,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await _authDatasource.signInWithGoogle();
      if (user.token != null) {
        await SecureStorage().setString(SecureKeys.token, user.token!);
        await AuthStorage().init();
      }
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
