import 'package:flutter/foundation.dart';

import '../../features/auth/data/models/auth_tokens.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../services/token_storage.dart';
import '../network/api_exception.dart';

class SessionManager {
  SessionManager({
    required AuthRepository authRepository,
    required TokenStorage tokenStorage,
  })  : _authRepository = authRepository,
        _tokenStorage = tokenStorage;

  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  AuthTokens? _webTokens;

  Future<bool>? _refreshFuture;
  Future<void> _storageQueue = Future<void>.value();

  int _sessionVersion = 0;
  bool _credentialsBlocked = false;

  int get sessionVersion => _sessionVersion;

  Future<T> _withStorageLock<T>(
    Future<T> Function() action,
  ) {
    final result = _storageQueue.then((_) => action());

    // Keep the queue usable after a failed operation.
    // The caller still receives the original failure.
    _storageQueue = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );

    return result;
  }

  Future<String?> _readStoredAccessToken() async {
    if (kIsWeb) return _webTokens?.accessToken;

    return _tokenStorage.getAccessToken();
  }

  Future<String?> _readStoredRefreshToken() async {
    if (kIsWeb) return _webTokens?.refreshToken;

    return _tokenStorage.getRefreshToken();
  }

  Future<void> _clearStoredTokens() async {
    if (kIsWeb) {
      _webTokens = null;
      return;
    }

    await _tokenStorage.clearTokens();
  }

  Future<void> _writeStoredTokens(AuthTokens tokens) async {
    if (kIsWeb) {
      _webTokens = tokens;
      return;
    }

    try {
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
    } catch (_) {
      // Best-effort cleanup if one of the two writes failed.
      // Credentials remain blocked if persistence fails.
      try {
        await _tokenStorage.clearTokens();
      } catch (_) {
        // Preserve the original write failure.
      }

      rethrow;
    }
  }

  Future<void> saveSession(AuthTokens tokens) {
    final version = ++_sessionVersion;

    _credentialsBlocked = true;
    _refreshFuture = null;

    return _withStorageLock(() async {
      if (version != _sessionVersion) {
        throw StateError('Session changed during sign-in.');
      }

      await _writeStoredTokens(tokens);

      if (version != _sessionVersion) {
        throw StateError('Session changed during sign-in.');
      }

      _credentialsBlocked = false;
    });
  }

  Future<String?> getAccessToken() {
    final version = _sessionVersion;

    if (_credentialsBlocked) {
      return Future<String?>.value(null);
    }

    return _withStorageLock(() async {
      if (_credentialsBlocked || version != _sessionVersion) {
        return null;
      }

      final token = await _readStoredAccessToken();

      if (_credentialsBlocked || version != _sessionVersion) {
        return null;
      }

      return token;
    });
  }

  Future<String?> getRefreshToken() {
    final version = _sessionVersion;

    if (_credentialsBlocked) {
      return Future<String?>.value(null);
    }

    return _withStorageLock(() async {
      if (_credentialsBlocked || version != _sessionVersion) {
        return null;
      }

      final token = await _readStoredRefreshToken();

      if (_credentialsBlocked || version != _sessionVersion) {
        return null;
      }

      return token;
    });
  }

  Future<bool> refreshSession() {
    if (_credentialsBlocked) {
      return Future<bool>.value(false);
    }

    final pending = _refreshFuture;
    if (pending != null) return pending;

    final version = _sessionVersion;

    late final Future<bool> operation;

    operation = _performRefresh(version).whenComplete(() {
      // An old refresh must not clear a newer refresh operation.
      if (identical(_refreshFuture, operation)) {
        _refreshFuture = null;
      }
    });

    _refreshFuture = operation;
    return operation;
  }

  Future<bool> _performRefresh(int version) async {
    final refreshToken = await getRefreshToken();

    if (_credentialsBlocked ||
        version != _sessionVersion ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return false;
    }

    try {
      final tokens = await _authRepository.refreshToken(
        refreshToken: refreshToken,
      );

      if (_credentialsBlocked || version != _sessionVersion) {
        return false;
      }

      return await _withStorageLock(() async {
        if (_credentialsBlocked || version != _sessionVersion) {
          return false;
        }

        _credentialsBlocked = true;

        await _writeStoredTokens(tokens);

        if (version != _sessionVersion) {
          return false;
        }

        _credentialsBlocked = false;
        return true;
      });
    } on ApiException catch (error) {
      if (version != _sessionVersion) {
        return false;
      }

      if (error.statusCode == 401) {
        await clearSession();
        return false;
      }

      rethrow;
    }
  }

  Future<void> clearSession() {
    _sessionVersion++;
    _credentialsBlocked = true;
    _refreshFuture = null;

    return _withStorageLock(_clearStoredTokens);
  }

  Future<void> logout() {
    // Invalidate pending refresh work before any asynchronous operation.
    _sessionVersion++;
    _credentialsBlocked = true;
    _refreshFuture = null;

    return _performLogout();
  }

  Future<void> _performLogout() async {
    final refreshToken = await _withStorageLock(() async {
      try {
        return await _readStoredRefreshToken();
      } finally {
        // Local cleanup happens before the network request.
        await _clearStoredTokens();
      }
    });

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _authRepository.logout(
        refreshToken: refreshToken,
      );
    }
  }
}