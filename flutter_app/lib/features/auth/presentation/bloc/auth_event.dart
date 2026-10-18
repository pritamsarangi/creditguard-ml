import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.sessionRestorationRequested() =
      SessionRestorationRequested;

  const factory AuthEvent.otpSendRequested({
    required String email,
  }) = OtpSendRequested;

  const factory AuthEvent.otpVerificationRequested({
    required String email,
    required String otp,
  }) = OtpVerificationRequested;

  const factory AuthEvent.otpResendRequested({
    required String email,
  }) = OtpResendRequested;

  const factory AuthEvent.logoutRequested() = LogoutRequested;

  const factory AuthEvent.backToLoginRequested() = BackToLoginRequested;
}
