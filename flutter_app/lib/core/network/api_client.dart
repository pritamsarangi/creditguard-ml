import 'package:dio/dio.dart';

import '../config/app_config.dart';

class ApiClient {
  ApiClient()
      : publicDio = _createDio(),
        authenticatedDio = _createDio();

  final Dio publicDio;
  final Dio authenticatedDio;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}
