import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

enum AuthStage {
  initializing,
  login,
  verifyOtp,
  authenticated,
  restoreError,
}

enum AuthOperation {
  idle,
  sendingOtp,
  verifyingOtp,
  resendingOtp,
  restoringSession,
  loggingOut,
}

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStage.initializing) AuthStage stage,
    @Default(AuthOperation.idle) AuthOperation operation,
    @Default('') String email,
    String? errorMessage,
    String? successMessage,
  }) = _AuthState;
}
