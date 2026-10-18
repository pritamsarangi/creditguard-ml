import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/session_manager.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
    required SessionManager sessionManager,
  })  : _authRepository = authRepository,
        _sessionManager = sessionManager,
        super(const AuthState()) {
    on<SessionRestorationRequested>(_onRestoreSession);
    on<OtpSendRequested>(_onSendOtp);
    on<OtpResendRequested>(_onResendOtp);
    on<OtpVerificationRequested>(_onVerifyOtp);
    on<LogoutRequested>(_onLogout);
    on<BackToLoginRequested>((event, emit) {
      if (_busy || state.stage != AuthStage.verifyOtp) return;

      emit(const AuthState(stage: AuthStage.login));
    });
  }

  final AuthRepository _authRepository;
  final SessionManager _sessionManager;

  bool _busy = false;

  Future<void> _onRestoreSession(
    SessionRestorationRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_busy) return;
    _busy = true;

    emit(state.copyWith(
      stage: AuthStage.initializing,
      operation: AuthOperation.restoringSession,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      final restored = await _sessionManager.refreshSession();

      if (!restored) {
        emit(const AuthState(stage: AuthStage.login));
        return;
      }

      final token = await _sessionManager.getAccessToken();

      if (token == null || token.isEmpty) {
        emit(const AuthState(stage: AuthStage.login));
        return;
      }

      final email = await _authRepository.getCurrentUserEmail(
        accessToken: token,
      );

      emit(AuthState(
        stage: AuthStage.authenticated,
        email: email,
      ));
    } catch (error) {
      emit(AuthState(
        stage: AuthStage.restoreError,
        errorMessage: _message(error),
      ));
    } finally {
      _busy = false;
    }
  }

  Future<void> _onSendOtp(
    OtpSendRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_busy || state.stage != AuthStage.login) return;
    _busy = true;

    final email = event.email.trim().toLowerCase();

    emit(state.copyWith(
      operation: AuthOperation.sendingOtp,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      if (!_isValidEmail(email)) {
        throw const ApiException(
          message: 'Enter a valid email address.',
        );
      }

      await _authRepository.sendOtp(email: email);

      emit(AuthState(
        stage: AuthStage.verifyOtp,
        email: email,
      ));
    } catch (error) {
      emit(AuthState(
        stage: AuthStage.login,
        email: email,
        errorMessage: _message(error),
      ));
    } finally {
      _busy = false;
    }
  }

  Future<void> _onResendOtp(
    OtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_busy || state.stage != AuthStage.verifyOtp) return;
    _busy = true;

    final email = state.email;

    emit(state.copyWith(
      operation: AuthOperation.resendingOtp,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      await _authRepository.sendOtp(email: email);

      emit(state.copyWith(
        operation: AuthOperation.idle,
        successMessage: 'A new verification code has been requested.',
      ));
    } catch (error) {
      emit(state.copyWith(
        operation: AuthOperation.idle,
        errorMessage: _message(error),
      ));
    } finally {
      _busy = false;
    }
  }

  Future<void> _onVerifyOtp(
    OtpVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_busy || state.stage != AuthStage.verifyOtp) return;
    _busy = true;

    final email = state.email;
    final otp = event.otp.trim();

    emit(state.copyWith(
      operation: AuthOperation.verifyingOtp,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
        throw const ApiException(
          message: 'Enter a valid six-digit verification code.',
        );
      }

      final tokens = await _authRepository.verifyOtp(
        email: email,
        otp: otp,
      );

      await _sessionManager.saveSession(tokens);

      emit(AuthState(
        stage: AuthStage.authenticated,
        email: email,
      ));
    } catch (error) {
      emit(AuthState(
        stage: AuthStage.verifyOtp,
        email: email,
        errorMessage: _message(error),
      ));
    } finally {
      _busy = false;
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_busy || state.stage != AuthStage.authenticated) return;
    _busy = true;

    emit(state.copyWith(
      operation: AuthOperation.loggingOut,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      await _sessionManager.logout();
    } catch (_) {
      // SessionManager clears local tokens even if remote logout fails.
    } finally {
      _busy = false;
      emit(const AuthState(stage: AuthStage.login));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  String _message(Object error) {
    if (error is ApiException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
