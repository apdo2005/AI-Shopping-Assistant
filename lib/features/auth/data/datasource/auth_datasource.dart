import '../model/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String username,
    required String location,
    required String password,
    required String passwordConfirmation,
  });
  Future<String> forgotPassword({required String email});
  Future<String> verifyOtp({required String email, required String otp});
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });
}
