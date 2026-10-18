import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:creditguard_flutter/core/auth/session_manager.dart';
import 'package:creditguard_flutter/core/network/api_exception.dart';
import 'package:creditguard_flutter/features/auth/data/models/auth_tokens.dart';
import 'package:creditguard_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:creditguard_flutter/services/token_storage.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthRepository repository;
  late MockTokenStorage storage;
  late SessionManager manager;

  String? storedAccess;
  String? storedRefresh;

  const oldTokens = AuthTokens(
    accessToken: 'test-old-access',
    refreshToken: 'test-old-refresh',
  );

  const rotatedTokens = AuthTokens(
    accessToken: 'test-rotated-access',
    refreshToken: 'test-rotated-refresh',
  );

  const newUserTokens = AuthTokens(
    accessToken: 'test-new-user-access',
    refreshToken: 'test-new-user-refresh',
  );

  setUp(() {
    repository = MockAuthRepository();
    storage = MockTokenStorage();

    storedAccess = null;
    storedRefresh = null;

    when(() => storage.getAccessToken()).thenAnswer(
      (_) async => storedAccess,
    );

    when(() => storage.getRefreshToken()).thenAnswer(
      (_) async => storedRefresh,
    );

    when(
      () => storage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((invocation) async {
      storedAccess =
          invocation.namedArguments[#accessToken] as String;
      storedRefresh =
          invocation.namedArguments[#refreshToken] as String;
    });

    when(() => storage.clearTokens()).thenAnswer((_) async {
      storedAccess = null;
      storedRefresh = null;
    });

    when(
      () => repository.logout(
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});

    manager = SessionManager(
      authRepository: repository,
      tokenStorage: storage,
    );
  });

  test('simultaneous callers share one refresh request', () async {
    await manager.saveSession(oldTokens);

    final started = Completer<void>();
    final response = Completer<AuthTokens>();

    when(
      () => repository.refreshToken(
        refreshToken: oldTokens.refreshToken,
      ),
    ).thenAnswer((_) {
      started.complete();
      return response.future;
    });

    final first = manager.refreshSession();
    final second = manager.refreshSession();

    await started.future;

    response.complete(rotatedTokens);

    expect(await Future.wait([first, second]), [true, true]);
    expect(
      await manager.getAccessToken(),
      rotatedTokens.accessToken,
    );

    verify(
      () => repository.refreshToken(
        refreshToken: oldTokens.refreshToken,
      ),
    ).called(1);
  });

  test('refresh completing after logout cannot restore tokens', () async {
    await manager.saveSession(oldTokens);

    final started = Completer<void>();
    final response = Completer<AuthTokens>();

    when(
      () => repository.refreshToken(
        refreshToken: oldTokens.refreshToken,
      ),
    ).thenAnswer((_) {
      started.complete();
      return response.future;
    });

    final refresh = manager.refreshSession();
    await started.future;

    await manager.logout();

    response.complete(rotatedTokens);

    expect(await refresh, isFalse);
    expect(await manager.getAccessToken(), isNull);
    expect(await manager.getRefreshToken(), isNull);
    expect(storedAccess, isNull);
    expect(storedRefresh, isNull);
  });

  test('old refresh success cannot overwrite a new login', () async {
    await manager.saveSession(oldTokens);

    final started = Completer<void>();
    final response = Completer<AuthTokens>();

    when(
      () => repository.refreshToken(
        refreshToken: oldTokens.refreshToken,
      ),
    ).thenAnswer((_) {
      started.complete();
      return response.future;
    });

    final refresh = manager.refreshSession();
    await started.future;

    await manager.saveSession(newUserTokens);

    response.complete(rotatedTokens);

    expect(await refresh, isFalse);
    expect(
      await manager.getAccessToken(),
      newUserTokens.accessToken,
    );
    expect(storedRefresh, newUserTokens.refreshToken);
  });

  test('old refresh rejection cannot clear a new login', () async {
    await manager.saveSession(oldTokens);

    final started = Completer<void>();
    final response = Completer<AuthTokens>();

    when(
      () => repository.refreshToken(
        refreshToken: oldTokens.refreshToken,
      ),
    ).thenAnswer((_) {
      started.complete();
      return response.future;
    });

    final refresh = manager.refreshSession();
    await started.future;

    await manager.saveSession(newUserTokens);

    response.completeError(
      const ApiException(
        message: 'Refresh token rejected.',
        statusCode: 401,
      ),
    );

    expect(await refresh, isFalse);
    expect(
      await manager.getAccessToken(),
      newUserTokens.accessToken,
    );
    expect(storedRefresh, newUserTokens.refreshToken);
  });

  test('logout failure still leaves local credentials cleared', () async {
    await manager.saveSession(oldTokens);

    when(
      () => repository.logout(
        refreshToken: oldTokens.refreshToken,
      ),
    ).thenThrow(
      const ApiException(
        message: 'Unable to connect.',
      ),
    );

    await expectLater(
      manager.logout(),
      throwsA(isA<ApiException>()),
    );

    expect(await manager.getAccessToken(), isNull);
    expect(await manager.getRefreshToken(), isNull);
    expect(storedAccess, isNull);
    expect(storedRefresh, isNull);
  });
}