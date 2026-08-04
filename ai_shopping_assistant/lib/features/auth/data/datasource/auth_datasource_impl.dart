import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:habispace/core/constants/api_constant.dart';
import 'package:habispace/core/constants/dio_helper.dart';
import 'package:habispace/core/error/exceptions.dart';
import 'package:habispace/features/auth/data/datasource/auth_datasource.dart';
import 'package:habispace/features/auth/data/model/user_model.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool isInitialize = false;

  Future ensureInitialized() async {
    if (isInitialize) return;

    await _googleSignIn.initialize(serverClientId: '936772323750-bh2bdr1ilfaj9jr6vpvq6e7j0fgt9ids.apps.googleusercontent.com');
    isInitialize = true;
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioHelper.post(
        path: ApiConstant.login,
        data: {"email": email, "password": password},
      );

      _checkStatus(response, response.statusCode!);
      return UserModel.fromJson(response.data);
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

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw AuthException('Failed to get Google ID token.');
      }

      final response = await DioHelper.post(
        path: ApiConstant.loginWithGoogle,
        data: {"id_token": idToken},
      );
      _checkStatus(response, response.statusCode!);
      return UserModel.fromJson(response.data);
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
        data: {"email": email},
      );

      final statusCode = response.statusCode ?? 500;
      final message =
          response.data?['message'] as String? ??
          'If an account exists for that email, a reset link has been sent.';

      if (statusCode < 200 || statusCode >= 300) {
        throw ServerException(message);
      }

      return message;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed: ${e.toString()}');
    }
  }

  @override
  Future<String> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await DioHelper.post(
        path: ApiConstant.verifyOtp,
        data: {"email": email, "otp": otp},
      );
      _checkStatus(response, response.statusCode!);
      final message = response.data?['message'] as String? ?? 'OTP verified.';
      return message;
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
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
          "email": email,
          "otp": otp,
          "password": password,
          "password_confirmation": passwordConfirmation,
        },
      );
      _checkStatus(response, response.statusCode!);
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to reset password: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await DioHelper.post(
        path: ApiConstant.signup,
        data: {
          "name": name,
          "email": email,
          "password": password,
          "password_confirmation": passwordConfirmation,
        },
      );
      _checkStatus(response, response.statusCode!);
      return UserModel.fromJson(response.data);
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to sign up: ${e.toString()}');
    }
  }
}

void _checkStatus(Response response, int statusCode) {
  statusCode = response.statusCode ?? 500;

  if (statusCode == 422 || statusCode == 400) {
    final message = response.data?['message'] ?? 'Invalid or expired token';
    throw AuthException(message);
  }
  if (statusCode < 200 || statusCode >= 300) {
    throw ServerException('Server error: $statusCode');
  }
}
