import 'package:flutter_test/flutter_test.dart';
import 'package:creditguard_flutter/core/constants/api_endpoints.dart';

void main() {
  test('API endpoints use versioned routes', () {
    expect(
      ApiEndpoints.predictions,
      '/api/v1/predictions',
    );

    expect(
      ApiEndpoints.sendOtp,
      '/api/v1/auth/send-otp',
    );
  });
}