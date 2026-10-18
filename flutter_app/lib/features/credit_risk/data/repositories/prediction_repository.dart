import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../models/credit_input.dart';
import '../../../../models/history_item.dart';
import '../../../../models/prediction_response.dart';

class PredictionRepository {
  const PredictionRepository(this._dio);

  final Dio _dio;

  Future<PredictionResponse> predict(CreditInput input) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.predictions,
        data: input.toJson(),
      );

      return PredictionResponse.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<List<HistoryItem>> getHistory() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiEndpoints.predictions,
        queryParameters: {'limit': 20},
      );

      return (response.data ?? [])
          .map(
            (item) => HistoryItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  ApiException _mapError(DioException error) {
    final status = error.response?.statusCode;

    if (status == 401) {
      return const ApiException(
        message: 'Your session has expired. Please sign in again.',
        statusCode: 401,
      );
    }

    if (status == 422) {
      return const ApiException(
        message: 'Please check your assessment inputs.',
        statusCode: 422,
      );
    }

    if (status != null && status >= 500) {
      return ApiException(
        message: 'Server temporarily unavailable.',
        statusCode: status,
      );
    }

    return const ApiException(
      message: 'Unable to complete the request.',
    );
  }
}
