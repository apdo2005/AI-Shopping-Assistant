import 'package:habispace/features/auth/data/model/user_model.dart';

abstract class AuthDatasource {
  Future<UserModel> signInWithEmail({required String email, required String password});
  Future<UserModel> signInWithGoogle();

  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<String> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });

  Future<String> verifyOtp({required String email, required String otp});
}
