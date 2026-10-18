import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:creditguard_flutter/core/auth/session_manager.dart';
import 'package:creditguard_flutter/core/network/auth_interceptor.dart';

class MockSessionManager extends Mock implements SessionManager {}

class TestAdapter implements HttpClientAdapter {
  TestAdapter(this.respond);

  final Future<ResponseBody> Function(RequestOptions options) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(int status) {
  return ResponseBody.fromString(
    '{}',
    status,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

void main() {
  late MockSessionManager session;
  late Dio dio;

  late int version;
  late String token;

  setUp(() {
    version = 1;
    token = 'test-old-access';

    session = MockSessionManager();

    when(() => session.sessionVersion).thenAnswer((_) => version);
    when(() => session.getAccessToken()).thenAnswer((_) async => token);
    when(() => session.refreshSession()).thenAnswer((_) async => false);

    dio = Dio(
      BaseOptions(baseUrl: 'https://example.test'),
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        sessionManager: session,
      ),
    );
  });

  tearDown(() {
    dio.close(force: true);
  });

  for (final status in [200, 401]) {
    test('rejects old-session HTTP $status without retrying', () async {
      final started = Completer<void>();
      final response = Completer<ResponseBody>();
      var requests = 0;

      dio.httpClientAdapter = TestAdapter((options) {
        requests++;
        started.complete();
        return response.future;
      });

      final request = dio.get<dynamic>('/protected');

      final expectation = expectLater(
        request,
        throwsA(
          isA<DioException>().having(
            (error) => error.type,
            'type',
            DioExceptionType.cancel,
          ),
        ),
      );

      await started.future;

      version++;
      token = 'test-new-account-access';

      response.complete(jsonResponse(status));

      await expectation;

      expect(requests, 1);
      verifyNever(() => session.refreshSession());
    });
  }

  test('session change during token lookup prevents sending', () async {
    final started = Completer<void>();
    final tokenResponse = Completer<String?>();
    var requests = 0;

    when(() => session.getAccessToken()).thenAnswer((_) {
      started.complete();
      return tokenResponse.future;
    });

    dio.httpClientAdapter = TestAdapter((options) async {
      requests++;
      return jsonResponse(200);
    });

    final request = dio.get<dynamic>('/protected');

    final expectation = expectLater(
      request,
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );

    await started.future;

    version++;
    tokenResponse.complete('test-new-account-access');

    await expectation;

    expect(requests, 0);
  });

  test('session change during refresh prevents retry', () async {
    final refreshStarted = Completer<void>();
    final refreshResponse = Completer<bool>();
    var requests = 0;

    when(() => session.refreshSession()).thenAnswer((_) {
      refreshStarted.complete();
      return refreshResponse.future;
    });

    dio.httpClientAdapter = TestAdapter((options) async {
      requests++;
      return jsonResponse(401);
    });

    final request = dio.get<dynamic>('/protected');

    final expectation = expectLater(
      request,
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );

    await refreshStarted.future;

    version++;
    token = 'test-new-account-access';
    refreshResponse.complete(true);

    await expectation;

    expect(requests, 1);
  });

  test('refreshes and retries within the same session', () async {
    var requests = 0;
    final authorizationHeaders = <Object?>[];

    when(() => session.refreshSession()).thenAnswer((_) async {
      token = 'test-refreshed-access';
      return true;
    });

    dio.httpClientAdapter = TestAdapter((options) async {
      requests++;
      authorizationHeaders.add(options.headers['Authorization']);
      return jsonResponse(requests == 1 ? 401 : 200);
    });

    final response = await dio.get<dynamic>('/protected');

    expect(response.statusCode, 200);
    expect(requests, 2);
    expect(
      authorizationHeaders,
      [
        'Bearer test-old-access',
        'Bearer test-refreshed-access',
      ],
    );

    verify(() => session.refreshSession()).called(1);
  });

  test('does not retry a second 401', () async {
    var requests = 0;

    when(() => session.refreshSession()).thenAnswer((_) async {
      token = 'test-refreshed-access';
      return true;
    });

    dio.httpClientAdapter = TestAdapter((options) async {
      requests++;
      return jsonResponse(401);
    });

    await expectLater(
      dio.get<dynamic>('/protected'),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status code',
          401,
        ),
      ),
    );

    expect(requests, 2);
    verify(() => session.refreshSession()).called(1);
  });
}
