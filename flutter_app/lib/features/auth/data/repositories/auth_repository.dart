import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../models/auth_tokens.dart';
import 'package:json_annotation/json_annotation.dart';

class AuthRepository {
  const AuthRepository(this._dio);

  final Dio _dio;

  Future<String> getCurrentUserEmail({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.currentUser,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final email = response.data?['email'];

      if (email is! String || email.isEmpty) {
        throw const ApiException(
          message: 'Invalid user response.',
        );
      }

      return email;
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<void> sendOtp({
    required String email,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.sendOtp,
        data: {
          'email': email.trim().toLowerCase(),
        },
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<AuthTokens> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.verifyOtp,
        data: {
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
        },
      );

      return AuthTokens.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw _mapError(error);
    } on TypeError {
      throw const ApiException(
        message: 'Invalid authentication response.',
      );
    } on FormatException {
      throw const ApiException(
        message: 'Invalid authentication response.',
      );
    } on CheckedFromJsonException {
      throw const ApiException(
        message: 'Invalid authentication response.',
      );
    }
  }

  Future<AuthTokens> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {
          'refresh_token': refreshToken,
        },
      );

      return AuthTokens.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw _mapError(error);
    } on TypeError {
      throw const ApiException(
        message: 'Invalid session response.',
      );
    } on FormatException {
      throw const ApiException(
        message: 'Invalid session response.',
      );
    } on CheckedFromJsonException {
      throw const ApiException(
        message: 'Invalid session response.',
      );
    }
  }

  Future<void> logout({
    required String refreshToken,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.logout,
        data: {
          'refresh_token': refreshToken,
        },
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  ApiException _mapError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String? serverMessage;

    if (data is Map) {
      final detail = data['detail'];

      if (detail is String) {
        serverMessage = detail;
      }
    }

    if (statusCode == 429) {
      return ApiException(
        message: serverMessage ?? 'Too many requests. Please try again later.',
        statusCode: statusCode,
      );
    }

    if (statusCode == 400 || statusCode == 401) {
      return ApiException(
        message: serverMessage ?? 'Authentication failed.',
        statusCode: statusCode,
      );
    }

    if (statusCode == 422) {
      return ApiException(
        message: 'Please check the information entered.',
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return ApiException(
        message: 'Service temporarily unavailable.',
        statusCode: statusCode,
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const ApiException(
        message: 'Unable to connect. Check your connection.',
      );
    }

    return ApiException(
      message: 'Request failed. Please try again.',
      statusCode: statusCode,
    );
  }
}
