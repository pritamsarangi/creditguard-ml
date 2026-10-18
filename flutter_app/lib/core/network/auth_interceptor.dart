import 'package:dio/dio.dart';

import '../auth/session_manager.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required SessionManager sessionManager,
  })  : _dio = dio,
        _sessionManager = sessionManager;

  final Dio _dio;
  final SessionManager _sessionManager;

  static const String _retryKey = 'auth_retry_attempted';
  static const String _sessionKey = 'auth_session_version';

  bool _isCurrentSession(RequestOptions request) {
    return request.extra[_sessionKey] == _sessionManager.sessionVersion;
  }

  bool _canContinue(RequestOptions request) {
    return _isCurrentSession(request) &&
        request.cancelToken?.isCancelled != true;
  }

  DioException _cancelled(RequestOptions request) {
    return DioException(
      requestOptions: request,
      type: DioExceptionType.cancel,
      message:
          'Request cancelled because its session changed or it was cancelled.',
    );
  }

  Map<String, dynamic> _authorizedHeaders(
    Map<String, dynamic> headers,
    String token,
  ) {
    return {
      for (final entry in headers.entries)
        if (entry.key.toLowerCase() != 'authorization') entry.key: entry.value,
      'Authorization': 'Bearer $token',
    };
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Retries retain the session that owned the original request.
    options.extra.putIfAbsent(
      _sessionKey,
      () => _sessionManager.sessionVersion,
    );

    if (!_canContinue(options)) {
      handler.reject(_cancelled(options));
      return;
    }

    try {
      final token = await _sessionManager.getAccessToken();

      if (!_canContinue(options)) {
        handler.reject(_cancelled(options));
        return;
      }

      if (token == null || token.isEmpty) {
        handler.reject(
          DioException(
            requestOptions: options,
            message: 'No active authentication credentials.',
          ),
        );
        return;
      }

      options.headers = _authorizedHeaders(options.headers, token);

      handler.next(options);
    } catch (_) {
      handler.reject(
        _canContinue(options)
            ? DioException(
                requestOptions: options,
                message: 'Unable to read authentication credentials.',
              )
            : _cancelled(options),
      );
    }
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!_canContinue(response.requestOptions)) {
      handler.reject(_cancelled(response.requestOptions));
      return;
    }

    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;

    if (!_canContinue(request)) {
      handler.next(_cancelled(request));
      return;
    }

    if (err.type == DioExceptionType.cancel ||
        err.response?.statusCode != 401 ||
        request.extra[_retryKey] == true) {
      handler.next(err);
      return;
    }

    try {
      final currentToken = await _sessionManager.getAccessToken();

      if (!_canContinue(request)) {
        handler.next(_cancelled(request));
        return;
      }

      final requestAuthorization = request.headers['Authorization'];
      final currentAuthorization =
          currentToken == null ? null : 'Bearer $currentToken';

      final alreadyRefreshed = currentToken != null &&
          currentToken.isNotEmpty &&
          requestAuthorization != currentAuthorization;

      // A different token is usable only within the same session.
      if (!alreadyRefreshed) {
        final refreshed = await _sessionManager.refreshSession();

        if (!_canContinue(request)) {
          handler.next(_cancelled(request));
          return;
        }

        if (!refreshed) {
          handler.next(err);
          return;
        }
      }

      final token = await _sessionManager.getAccessToken();

      if (!_canContinue(request)) {
        handler.next(_cancelled(request));
        return;
      }

      if (token == null || token.isEmpty) {
        handler.next(err);
        return;
      }

      final retryOptions = request.copyWith(
        headers: _authorizedHeaders(request.headers, token),
        extra: {
          ...request.extra,
          _retryKey: true,
        },
      );

      final response = await _dio.fetch<dynamic>(retryOptions);

      // Check again after the retried request completes.
      if (!_canContinue(request)) {
        handler.next(_cancelled(request));
        return;
      }

      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(
        _canContinue(request) ? retryError : _cancelled(request),
      );
    } catch (_) {
      handler.next(
        _canContinue(request) ? err : _cancelled(request),
      );
    }
  }
}
