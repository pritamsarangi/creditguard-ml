// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prediction_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PredictionEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is PredictionEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PredictionEvent()';
  }
}

/// @nodoc
class $PredictionEventCopyWith<$Res> {
  $PredictionEventCopyWith(
      PredictionEvent _, $Res Function(PredictionEvent) __);
}

/// Adds pattern-matching-related methods to [PredictionEvent].
extension PredictionEventPatterns on PredictionEvent {
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
    TResult Function(PredictionSubmitted value)? submitted,
    TResult Function(PredictionCleared value)? cleared,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PredictionSubmitted() when submitted != null:
        return submitted(_that);
      case PredictionCleared() when cleared != null:
        return cleared(_that);
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
    required TResult Function(PredictionSubmitted value) submitted,
    required TResult Function(PredictionCleared value) cleared,
  }) {
    final _that = this;
    switch (_that) {
      case PredictionSubmitted():
        return submitted(_that);
      case PredictionCleared():
        return cleared(_that);
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
    TResult? Function(PredictionSubmitted value)? submitted,
    TResult? Function(PredictionCleared value)? cleared,
  }) {
    final _that = this;
    switch (_that) {
      case PredictionSubmitted() when submitted != null:
        return submitted(_that);
      case PredictionCleared() when cleared != null:
        return cleared(_that);
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
    TResult Function(CreditInput input)? submitted,
    TResult Function()? cleared,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PredictionSubmitted() when submitted != null:
        return submitted(_that.input);
      case PredictionCleared() when cleared != null:
        return cleared();
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
    required TResult Function(CreditInput input) submitted,
    required TResult Function() cleared,
  }) {
    final _that = this;
    switch (_that) {
      case PredictionSubmitted():
        return submitted(_that.input);
      case PredictionCleared():
        return cleared();
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
    TResult? Function(CreditInput input)? submitted,
    TResult? Function()? cleared,
  }) {
    final _that = this;
    switch (_that) {
      case PredictionSubmitted() when submitted != null:
        return submitted(_that.input);
      case PredictionCleared() when cleared != null:
        return cleared();
      case _:
        return null;
    }
  }
}

/// @nodoc

class PredictionSubmitted implements PredictionEvent {
  const PredictionSubmitted({required this.input});

  final CreditInput input;

  /// Create a copy of PredictionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PredictionSubmittedCopyWith<PredictionSubmitted> get copyWith =>
      _$PredictionSubmittedCopyWithImpl<PredictionSubmitted>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PredictionSubmitted &&
            (identical(other.input, input) || other.input == input));
  }

  @override
  int get hashCode => Object.hash(runtimeType, input);

  @override
  String toString() {
    return 'PredictionEvent.submitted(input: $input)';
  }
}

/// @nodoc
abstract mixin class $PredictionSubmittedCopyWith<$Res>
    implements $PredictionEventCopyWith<$Res> {
  factory $PredictionSubmittedCopyWith(
          PredictionSubmitted value, $Res Function(PredictionSubmitted) _then) =
      _$PredictionSubmittedCopyWithImpl;
  @useResult
  $Res call({CreditInput input});
}

/// @nodoc
class _$PredictionSubmittedCopyWithImpl<$Res>
    implements $PredictionSubmittedCopyWith<$Res> {
  _$PredictionSubmittedCopyWithImpl(this._self, this._then);

  final PredictionSubmitted _self;
  final $Res Function(PredictionSubmitted) _then;

  /// Create a copy of PredictionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? input = null,
  }) {
    return _then(PredictionSubmitted(
      input: null == input
          ? _self.input
          : input // ignore: cast_nullable_to_non_nullable
              as CreditInput,
    ));
  }
}

/// @nodoc

class PredictionCleared implements PredictionEvent {
  const PredictionCleared();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is PredictionCleared);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PredictionEvent.cleared()';
  }
}

// dart format on
