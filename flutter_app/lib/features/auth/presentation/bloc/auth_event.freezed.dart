// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AuthEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent()';
  }
}

/// @nodoc
class $AuthEventCopyWith<$Res> {
  $AuthEventCopyWith(AuthEvent _, $Res Function(AuthEvent) __);
}

/// Adds pattern-matching-related methods to [AuthEvent].
extension AuthEventPatterns on AuthEvent {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SessionRestorationRequested value)?
        sessionRestorationRequested,
    TResult Function(OtpSendRequested value)? otpSendRequested,
    TResult Function(OtpVerificationRequested value)? otpVerificationRequested,
    TResult Function(OtpResendRequested value)? otpResendRequested,
    TResult Function(LogoutRequested value)? logoutRequested,
    TResult Function(BackToLoginRequested value)? backToLoginRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SessionRestorationRequested()
          when sessionRestorationRequested != null:
        return sessionRestorationRequested(_that);
      case OtpSendRequested() when otpSendRequested != null:
        return otpSendRequested(_that);
      case OtpVerificationRequested() when otpVerificationRequested != null:
        return otpVerificationRequested(_that);
      case OtpResendRequested() when otpResendRequested != null:
        return otpResendRequested(_that);
      case LogoutRequested() when logoutRequested != null:
        return logoutRequested(_that);
      case BackToLoginRequested() when backToLoginRequested != null:
        return backToLoginRequested(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SessionRestorationRequested value)
        sessionRestorationRequested,
    required TResult Function(OtpSendRequested value) otpSendRequested,
    required TResult Function(OtpVerificationRequested value)
        otpVerificationRequested,
    required TResult Function(OtpResendRequested value) otpResendRequested,
    required TResult Function(LogoutRequested value) logoutRequested,
    required TResult Function(BackToLoginRequested value) backToLoginRequested,
  }) {
    final _that = this;
    switch (_that) {
      case SessionRestorationRequested():
        return sessionRestorationRequested(_that);
      case OtpSendRequested():
        return otpSendRequested(_that);
      case OtpVerificationRequested():
        return otpVerificationRequested(_that);
      case OtpResendRequested():
        return otpResendRequested(_that);
      case LogoutRequested():
        return logoutRequested(_that);
      case BackToLoginRequested():
        return backToLoginRequested(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SessionRestorationRequested value)?
        sessionRestorationRequested,
    TResult? Function(OtpSendRequested value)? otpSendRequested,
    TResult? Function(OtpVerificationRequested value)? otpVerificationRequested,
    TResult? Function(OtpResendRequested value)? otpResendRequested,
    TResult? Function(LogoutRequested value)? logoutRequested,
    TResult? Function(BackToLoginRequested value)? backToLoginRequested,
  }) {
    final _that = this;
    switch (_that) {
      case SessionRestorationRequested()
          when sessionRestorationRequested != null:
        return sessionRestorationRequested(_that);
      case OtpSendRequested() when otpSendRequested != null:
        return otpSendRequested(_that);
      case OtpVerificationRequested() when otpVerificationRequested != null:
        return otpVerificationRequested(_that);
      case OtpResendRequested() when otpResendRequested != null:
        return otpResendRequested(_that);
      case LogoutRequested() when logoutRequested != null:
        return logoutRequested(_that);
      case BackToLoginRequested() when backToLoginRequested != null:
        return backToLoginRequested(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionRestorationRequested,
    TResult Function(String email)? otpSendRequested,
    TResult Function(String email, String otp)? otpVerificationRequested,
    TResult Function(String email)? otpResendRequested,
    TResult Function()? logoutRequested,
    TResult Function()? backToLoginRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SessionRestorationRequested()
          when sessionRestorationRequested != null:
        return sessionRestorationRequested();
      case OtpSendRequested() when otpSendRequested != null:
        return otpSendRequested(_that.email);
      case OtpVerificationRequested() when otpVerificationRequested != null:
        return otpVerificationRequested(_that.email, _that.otp);
      case OtpResendRequested() when otpResendRequested != null:
        return otpResendRequested(_that.email);
      case LogoutRequested() when logoutRequested != null:
        return logoutRequested();
      case BackToLoginRequested() when backToLoginRequested != null:
        return backToLoginRequested();
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionRestorationRequested,
    required TResult Function(String email) otpSendRequested,
    required TResult Function(String email, String otp)
        otpVerificationRequested,
    required TResult Function(String email) otpResendRequested,
    required TResult Function() logoutRequested,
    required TResult Function() backToLoginRequested,
  }) {
    final _that = this;
    switch (_that) {
      case SessionRestorationRequested():
        return sessionRestorationRequested();
      case OtpSendRequested():
        return otpSendRequested(_that.email);
      case OtpVerificationRequested():
        return otpVerificationRequested(_that.email, _that.otp);
      case OtpResendRequested():
        return otpResendRequested(_that.email);
      case LogoutRequested():
        return logoutRequested();
      case BackToLoginRequested():
        return backToLoginRequested();
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionRestorationRequested,
    TResult? Function(String email)? otpSendRequested,
    TResult? Function(String email, String otp)? otpVerificationRequested,
    TResult? Function(String email)? otpResendRequested,
    TResult? Function()? logoutRequested,
    TResult? Function()? backToLoginRequested,
  }) {
    final _that = this;
    switch (_that) {
      case SessionRestorationRequested()
          when sessionRestorationRequested != null:
        return sessionRestorationRequested();
      case OtpSendRequested() when otpSendRequested != null:
        return otpSendRequested(_that.email);
      case OtpVerificationRequested() when otpVerificationRequested != null:
        return otpVerificationRequested(_that.email, _that.otp);
      case OtpResendRequested() when otpResendRequested != null:
        return otpResendRequested(_that.email);
      case LogoutRequested() when logoutRequested != null:
        return logoutRequested();
      case BackToLoginRequested() when backToLoginRequested != null:
        return backToLoginRequested();
      case _:
        return null;
    }
  }
}

/// @nodoc

class SessionRestorationRequested implements AuthEvent {
  const SessionRestorationRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionRestorationRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.sessionRestorationRequested()';
  }
}

/// @nodoc

class OtpSendRequested implements AuthEvent {
  const OtpSendRequested({required this.email});

  final String email;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OtpSendRequestedCopyWith<OtpSendRequested> get copyWith =>
      _$OtpSendRequestedCopyWithImpl<OtpSendRequested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OtpSendRequested &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email);

  @override
  String toString() {
    return 'AuthEvent.otpSendRequested(email: $email)';
  }
}

/// @nodoc
abstract mixin class $OtpSendRequestedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory $OtpSendRequestedCopyWith(
          OtpSendRequested value, $Res Function(OtpSendRequested) _then) =
      _$OtpSendRequestedCopyWithImpl;
  @useResult
  $Res call({String email});
}

/// @nodoc
class _$OtpSendRequestedCopyWithImpl<$Res>
    implements $OtpSendRequestedCopyWith<$Res> {
  _$OtpSendRequestedCopyWithImpl(this._self, this._then);

  final OtpSendRequested _self;
  final $Res Function(OtpSendRequested) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
  }) {
    return _then(OtpSendRequested(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class OtpVerificationRequested implements AuthEvent {
  const OtpVerificationRequested({required this.email, required this.otp});

  final String email;
  final String otp;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OtpVerificationRequestedCopyWith<OtpVerificationRequested> get copyWith =>
      _$OtpVerificationRequestedCopyWithImpl<OtpVerificationRequested>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OtpVerificationRequested &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.otp, otp) || other.otp == otp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, otp);

  @override
  String toString() {
    return 'AuthEvent.otpVerificationRequested(email: $email, otp: $otp)';
  }
}

/// @nodoc
abstract mixin class $OtpVerificationRequestedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory $OtpVerificationRequestedCopyWith(OtpVerificationRequested value,
          $Res Function(OtpVerificationRequested) _then) =
      _$OtpVerificationRequestedCopyWithImpl;
  @useResult
  $Res call({String email, String otp});
}

/// @nodoc
class _$OtpVerificationRequestedCopyWithImpl<$Res>
    implements $OtpVerificationRequestedCopyWith<$Res> {
  _$OtpVerificationRequestedCopyWithImpl(this._self, this._then);

  final OtpVerificationRequested _self;
  final $Res Function(OtpVerificationRequested) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
    Object? otp = null,
  }) {
    return _then(OtpVerificationRequested(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      otp: null == otp
          ? _self.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class OtpResendRequested implements AuthEvent {
  const OtpResendRequested({required this.email});

  final String email;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OtpResendRequestedCopyWith<OtpResendRequested> get copyWith =>
      _$OtpResendRequestedCopyWithImpl<OtpResendRequested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OtpResendRequested &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email);

  @override
  String toString() {
    return 'AuthEvent.otpResendRequested(email: $email)';
  }
}

/// @nodoc
abstract mixin class $OtpResendRequestedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory $OtpResendRequestedCopyWith(
          OtpResendRequested value, $Res Function(OtpResendRequested) _then) =
      _$OtpResendRequestedCopyWithImpl;
  @useResult
  $Res call({String email});
}

/// @nodoc
class _$OtpResendRequestedCopyWithImpl<$Res>
    implements $OtpResendRequestedCopyWith<$Res> {
  _$OtpResendRequestedCopyWithImpl(this._self, this._then);

  final OtpResendRequested _self;
  final $Res Function(OtpResendRequested) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
  }) {
    return _then(OtpResendRequested(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class LogoutRequested implements AuthEvent {
  const LogoutRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is LogoutRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.logoutRequested()';
  }
}

/// @nodoc

class BackToLoginRequested implements AuthEvent {
  const BackToLoginRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is BackToLoginRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.backToLoginRequested()';
  }
}

// dart format on
