import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/prediction_repository.dart';
import 'prediction_event.dart';
import 'prediction_state.dart';

class PredictionBloc extends Bloc<PredictionEvent, PredictionState> {
  PredictionBloc({
    required PredictionRepository repository,
  })  : _repository = repository,
        super(const PredictionState()) {
    on<PredictionSubmitted>(_onSubmitted);
    on<PredictionCleared>(_onCleared);
  }

  final PredictionRepository _repository;

  int _requestVersion = 0;

  Future<void> _onSubmitted(
    PredictionSubmitted event,
    Emitter<PredictionState> emit,
  ) async {
    if (isClosed || state.isLoading) return;

    final version = ++_requestVersion;

    emit(state.copyWith(
      isLoading: true,
      prediction: null,
      errorMessage: null,
    ));

    try {
      final result = await _repository.predict(event.input);

      if (isClosed || emit.isDone || version != _requestVersion) return;

      emit(state.copyWith(
        isLoading: false,
        prediction: result,
      ));
    } catch (error) {
      if (isClosed || emit.isDone || version != _requestVersion) return;

      emit(state.copyWith(
        isLoading: false,
        errorMessage: error is ApiException
            ? error.message
            : 'Unable to assess credit risk. Please try again.',
      ));
    }
  }

  void _onCleared(
    PredictionCleared event,
    Emitter<PredictionState> emit,
  ) {
    _requestVersion++;
    emit(const PredictionState());
  }
}
