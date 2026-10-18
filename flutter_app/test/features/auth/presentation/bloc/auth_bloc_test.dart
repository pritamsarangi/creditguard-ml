import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:creditguard_flutter/core/auth/session_manager.dart';
import 'package:creditguard_flutter/core/network/api_exception.dart';
import 'package:creditguard_flutter/features/auth/data/models/auth_tokens.dart';
import 'package:creditguard_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:creditguard_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:creditguard_flutter/features/auth/presentation/bloc/auth_event.dart';
import 'package:creditguard_flutter/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionManager extends Mock implements SessionManager {}

void main() {
  late MockAuthRepository repository;
  late MockSessionManager sessionManager;

  setUp(() {
    repository = MockAuthRepository();
    sessionManager = MockSessionManager();
  });

  AuthBloc buildBloc() => AuthBloc(
        authRepository: repository,
        sessionManager: sessionManager,
      );

  const tokens = AuthTokens(
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
  );

  blocTest<AuthBloc, AuthState>(
    'successful OTP request opens the verification stage',
    build: () {
      when(() => repository.sendOtp(email: 'user@example.com'))
          .thenAnswer((_) async {});
      return buildBloc();
    },
    seed: () => const AuthState(stage: AuthStage.login),
    act: (bloc) => bloc.add(
      const AuthEvent.otpSendRequested(
        email: 'user@example.com',
      ),
    ),
    expect: () => [
      const AuthState(
        stage: AuthStage.login,
        operation: AuthOperation.sendingOtp,
      ),
      const AuthState(
        stage: AuthStage.verifyOtp,
        email: 'user@example.com',
      ),
    ],
    verify: (_) {
      verify(() => repository.sendOtp(email: 'user@example.com')).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'incorrect OTP stays on the verification screen',
    build: () {
      when(() => repository.verifyOtp(
            email: 'user@example.com',
            otp: '123456',
          )).thenThrow(
        const ApiException(
          message: 'Invalid verification code.',
          statusCode: 400,
        ),
      );
      return buildBloc();
    },
    seed: () => const AuthState(
      stage: AuthStage.verifyOtp,
      email: 'user@example.com',
    ),
    act: (bloc) => bloc.add(
      const AuthEvent.otpVerificationRequested(
        email: 'user@example.com',
        otp: '123456',
      ),
    ),
    expect: () => [
      const AuthState(
        stage: AuthStage.verifyOtp,
        email: 'user@example.com',
        operation: AuthOperation.verifyingOtp,
      ),
      const AuthState(
        stage: AuthStage.verifyOtp,
        email: 'user@example.com',
        errorMessage: 'Invalid verification code.',
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'valid OTP saves session and authenticates user',
    build: () {
      when(() => repository.verifyOtp(
            email: 'user@example.com',
            otp: '123456',
          )).thenAnswer((_) async => tokens);

      when(() => sessionManager.saveSession(tokens)).thenAnswer((_) async {});

      return buildBloc();
    },
    seed: () => const AuthState(
      stage: AuthStage.verifyOtp,
      email: 'user@example.com',
    ),
    act: (bloc) => bloc.add(
      const AuthEvent.otpVerificationRequested(
        email: 'user@example.com',
        otp: '123456',
      ),
    ),
    expect: () => [
      const AuthState(
        stage: AuthStage.verifyOtp,
        email: 'user@example.com',
        operation: AuthOperation.verifyingOtp,
      ),
      const AuthState(
        stage: AuthStage.authenticated,
        email: 'user@example.com',
      ),
    ],
    verify: (_) {
      verify(() => sessionManager.saveSession(tokens)).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'no saved session returns user to login',
    build: () {
      when(() => sessionManager.refreshSession())
          .thenAnswer((_) async => false);
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const AuthEvent.sessionRestorationRequested(),
    ),
    expect: () => [
      const AuthState(
        stage: AuthStage.initializing,
        operation: AuthOperation.restoringSession,
      ),
      const AuthState(stage: AuthStage.login),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'logout returns user to login',
    build: () {
      when(() => sessionManager.logout()).thenAnswer((_) async {});
      return buildBloc();
    },
    seed: () => const AuthState(
      stage: AuthStage.authenticated,
      email: 'user@example.com',
    ),
    act: (bloc) => bloc.add(
      const AuthEvent.logoutRequested(),
    ),
    expect: () => [
      const AuthState(
        stage: AuthStage.authenticated,
        email: 'user@example.com',
        operation: AuthOperation.loggingOut,
      ),
      const AuthState(stage: AuthStage.login),
    ],
    verify: (_) {
      verify(() => sessionManager.logout()).called(1);
    },
  );
}
