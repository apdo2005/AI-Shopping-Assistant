class ApiConstant {
  static const String baseUrl = 'https://real.newcinderella.online/api/v1/';

  static const String home = 'home';
  static const String properties = 'properties';
  static const String conversations = 'conversations';
  static const String messages = 'messages';
  static const String favorite = 'favorites';
  static const String loginWithGoogle = 'auth/google';
  static const String forgotPassword = 'auth/forgot-password';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resetPassword = 'auth/reset-password';
  static const String signup = 'auth/register';
  static const String login = 'auth/login';
  static const String orders='orders';
  static const String createPayment = 'orders';
  static const String getProfile = 'auth/me';
  static const String deleteAccount='auth/logout';

  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;

  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}
