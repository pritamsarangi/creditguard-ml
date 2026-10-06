import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/credit_input.dart';
import '../models/history_item.dart';
import '../models/prediction_response.dart';

class ApiClient {
  final String baseUrl;
  final http.Client client;

  ApiClient({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://10.0.2.2:8000',
            ),
        client = client ?? http.Client();

  Uri _uri(
    String path, [
    Map<String, String>? query,
  ]) {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    return Uri.parse('$normalized$path').replace(
      queryParameters: query,
    );
  }

  Future<PredictionResponse> predict(
    CreditInput input,
  ) async {
    final response = await client.post(
      _uri('/api/v1/predictions'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception(_extractError(response.body));
    }

    return PredictionResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<HistoryItem>> getHistory() async {
    final response = await client.get(
      _uri(
        '/api/v1/predictions',
        {'limit': '20'},
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body));
    }

    final list = jsonDecode(response.body) as List<dynamic>;

    return list
        .map(
          (item) => HistoryItem.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  String _extractError(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];

        if (detail is String) {
          return detail;
        }

        if (detail is List && detail.isNotEmpty) {
          final messages = detail.map((item) {
            if (item is! Map) {
              return item.toString();
            }

            final location = item['loc'];
            final message = item['msg']?.toString() ?? 'Invalid value';

            String field = 'Field';
            if (location is List && location.isNotEmpty) {
              field = location.last.toString().replaceAll('_', ' ');
              field = field
                  .split(' ')
                  .map(
                    (word) => word.isEmpty
                        ? word
                        : '${word[0].toUpperCase()}${word.substring(1)}',
                  )
                  .join(' ');
            }

            return '$field: $message';
          }).join('\n');

          return messages;
        }
      }

      return 'Request failed';
    } catch (_) {
      return 'Request failed';
    }
  }
}
