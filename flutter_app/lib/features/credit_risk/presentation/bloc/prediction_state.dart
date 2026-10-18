import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../models/prediction_response.dart';

part 'prediction_state.freezed.dart';

@freezed
abstract class PredictionState with _$PredictionState {
  const factory PredictionState({
    @Default(false) bool isLoading,
    PredictionResponse? prediction,
    String? errorMessage,
  }) = _PredictionState;
}
