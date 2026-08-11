import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:ai_shopping_assistant/core/constants/api_constant.dart';
import 'package:ai_shopping_assistant/core/constants/dio_helper.dart';
import 'package:ai_shopping_assistant/core/constants/secure_storage.dart';
import 'package:ai_shopping_assistant/core/error/exceptions.dart';
import 'package:ai_shopping_assistant/features/auth/data/datasource/auth_datasource.dart';
import 'package:ai_shopping_assistant/features/auth/data/model/user_model.dart';

class AuthDatasourceImpl implements AuthRemoteDataSource {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool isInitialized = false;
  Future<void> ensureInitialized() async {
    if (isInitialized) return;

    await _googleSignIn.initialize(
      serverClientId:
          '936772323750-bh2bdr1ilfaj9jr6vpvq6e7j0fgt9ids.apps.googleusercontent.com',
    );

    isInitialized = true;
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String username,
    required String location,
    required String password,
    required String passwordConfirmation,
  }) async {
    fb_auth.UserCredential? credential;

    try {
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);
      final response = await DioHelper.post(
        path: ApiConstant.signup,
        data: {
          "username": name.trim().replaceAll(' ', '_').toLowerCase(),
          "name": name,
          "email": email,
          "location": location,
          "password": password,
          "password_confirmation": passwordConfirmation,
          "agree_terms": true,
        },
      );

      _checkStatus(response);

      final user = UserModel.fromJson(response.data);

      if (user.token != null && user.token!.isNotEmpty) {
        await SecureStorage().setString(SecureKeys.token, user.token!);
      }

      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      await credential?.user?.delete();
      throw AuthException(e.message ?? 'Firebase authentication failed');
    } on DioException catch (e) {
      await credential?.user?.delete();
      throw AuthException(_extractApiErrorMessage(e));
    } on AuthException {
      await credential?.user?.delete();
      rethrow;
    } on ServerException {
      await credential?.user?.delete();
      rethrow;
    } catch (e) {
      await credential?.user?.delete();
      throw ServerException('Failed to create account: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final response = await DioHelper.post(
        path: ApiConstant.login,
        data: {"login": email, "password": password},
      );

      _checkStatus(response);
      final user = UserModel.fromJson(response.data);
      if (user.token != null && user.token!.isNotEmpty) {
        await SecureStorage().setString(SecureKeys.token, user.token!);
      }

      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed');
    } on DioException catch (e) {
      throw AuthException(_extractApiErrorMessage(e));
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      await ensureInitialized();

      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw AuthException('Failed to get Google token');
      }

      final credential = fb_auth.GoogleAuthProvider.credential(
        idToken: idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);

      final response = await DioHelper.post(
        path: ApiConstant.loginWithGoogle,
        data: {"id_token": idToken},
      );

      _checkStatus(response);

      final user = UserModel.fromJson(response.data);

      if (user.token != null && user.token!.isNotEmpty) {
        await SecureStorage().setString(SecureKeys.token, user.token!);
      }

      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google authentication failed');
    } on DioException catch (e) {
      throw AuthException(_extractApiErrorMessage(e));
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await DioHelper.post(
        path: ApiConstant.forgotPassword,
        data: {"identifier": email},
      );

      _checkStatus(response);

      return response.data['message'] ?? 'Password reset sent';
    } on DioException catch (e) {
      throw AuthException(_extractApiErrorMessage(e));
    } catch (e) {
      throw ServerException('Failed to send reset password: ${e.toString()}');
    }
  }

  @override
  Future<String> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await DioHelper.post(
        path: ApiConstant.verifyOtp,
        data: {"identifier": email, "otp": otp},
      );

      _checkStatus(response);

      return response.data['message'] ?? 'OTP verified';
    } on DioException catch (e) {
      throw AuthException(_extractApiErrorMessage(e));
    } catch (e) {
      throw ServerException('Failed to verify OTP: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await DioHelper.post(
        path: ApiConstant.resetPassword,
        data: {
          "identifier": email,
          "otp": otp,
          "password": password,
          "password_confirmation": passwordConfirmation,
        },
      );

      _checkStatus(response);
    } on DioException catch (e) {
      throw AuthException(_extractApiErrorMessage(e));
    } catch (e) {
      throw ServerException('Failed to reset password: ${e.toString()}');
    }
  }
}

void _checkStatus(Response response) {
  final statusCode = response.statusCode ?? 500;

  if (statusCode == 400 || statusCode == 422) {
    throw AuthException(response.data?['message'] ?? 'Invalid credentials');
  }

  if (statusCode < 200 || statusCode >= 300) {
    throw ServerException('Server error $statusCode');
  }
}

String _extractApiErrorMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map) {
    if (data.containsKey('errors') && data['errors'] is Map) {
      final errorsMap = data['errors'] as Map;
      if (errorsMap.isNotEmpty) {
        final firstKey = errorsMap.keys.first;
        final firstErrorList = errorsMap[firstKey];
        if (firstErrorList is List && firstErrorList.isNotEmpty) {
          return firstErrorList.first.toString();
        }
      }
    }
    if (data.containsKey('message')) {
      return data['message'].toString();
    }
  }
  return e.message ?? 'An unexpected network error occurred';
}
