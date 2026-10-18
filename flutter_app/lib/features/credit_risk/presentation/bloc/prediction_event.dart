import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../models/credit_input.dart';

part 'prediction_event.freezed.dart';

@freezed
sealed class PredictionEvent with _$PredictionEvent {
  const factory PredictionEvent.submitted({
    required CreditInput input,
  }) = PredictionSubmitted;

  const factory PredictionEvent.cleared() = PredictionCleared;
}
