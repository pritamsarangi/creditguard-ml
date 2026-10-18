abstract final class ApiEndpoints {
  static const String health = '/api/v1/health';
  static const String modelInfo = '/api/v1/model/info';

  static const String sendOtp = '/api/v1/auth/send-otp';
  static const String verifyOtp = '/api/v1/auth/verify-otp';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String currentUser = '/api/v1/auth/me';

  static const String predictions = '/api/v1/predictions';
}
