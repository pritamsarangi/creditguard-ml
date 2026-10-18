// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prediction_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PredictionState {
  bool get isLoading;
  PredictionResponse? get prediction;
  String? get errorMessage;

  /// Create a copy of PredictionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PredictionStateCopyWith<PredictionState> get copyWith =>
      _$PredictionStateCopyWithImpl<PredictionState>(
          this as PredictionState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PredictionState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.prediction, prediction) ||
                other.prediction == prediction) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, prediction, errorMessage);

  @override
  String toString() {
    return 'PredictionState(isLoading: $isLoading, prediction: $prediction, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class $PredictionStateCopyWith<$Res> {
  factory $PredictionStateCopyWith(
          PredictionState value, $Res Function(PredictionState) _then) =
      _$PredictionStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading, PredictionResponse? prediction, String? errorMessage});
}

/// @nodoc
class _$PredictionStateCopyWithImpl<$Res>
    implements $PredictionStateCopyWith<$Res> {
  _$PredictionStateCopyWithImpl(this._self, this._then);

  final PredictionState _self;
  final $Res Function(PredictionState) _then;

  /// Create a copy of PredictionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? prediction = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      prediction: freezed == prediction
          ? _self.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as PredictionResponse?,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PredictionState].
extension PredictionStatePatterns on PredictionState {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PredictionState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PredictionState() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_PredictionState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PredictionState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PredictionState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PredictionState() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(bool isLoading, PredictionResponse? prediction,
            String? errorMessage)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PredictionState() when $default != null:
        return $default(_that.isLoading, _that.prediction, _that.errorMessage);
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
  TResult when<TResult extends Object?>(
    TResult Function(bool isLoading, PredictionResponse? prediction,
            String? errorMessage)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PredictionState():
        return $default(_that.isLoading, _that.prediction, _that.errorMessage);
      case _:
        throw StateError('Unexpected subclass');
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(bool isLoading, PredictionResponse? prediction,
            String? errorMessage)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PredictionState() when $default != null:
        return $default(_that.isLoading, _that.prediction, _that.errorMessage);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PredictionState implements PredictionState {
  const _PredictionState(
      {this.isLoading = false, this.prediction, this.errorMessage});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final PredictionResponse? prediction;
  @override
  final String? errorMessage;

  /// Create a copy of PredictionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PredictionStateCopyWith<_PredictionState> get copyWith =>
      __$PredictionStateCopyWithImpl<_PredictionState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PredictionState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.prediction, prediction) ||
                other.prediction == prediction) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, prediction, errorMessage);

  @override
  String toString() {
    return 'PredictionState(isLoading: $isLoading, prediction: $prediction, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class _$PredictionStateCopyWith<$Res>
    implements $PredictionStateCopyWith<$Res> {
  factory _$PredictionStateCopyWith(
          _PredictionState value, $Res Function(_PredictionState) _then) =
      __$PredictionStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading, PredictionResponse? prediction, String? errorMessage});
}

/// @nodoc
class __$PredictionStateCopyWithImpl<$Res>
    implements _$PredictionStateCopyWith<$Res> {
  __$PredictionStateCopyWithImpl(this._self, this._then);

  final _PredictionState _self;
  final $Res Function(_PredictionState) _then;

  /// Create a copy of PredictionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? prediction = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_PredictionState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      prediction: freezed == prediction
          ? _self.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as PredictionResponse?,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
