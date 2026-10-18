import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/prediction_repository.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({
    required PredictionRepository repository,
  })  : _repository = repository,
        super(const HistoryState());

  final PredictionRepository _repository;

  int _requestVersion = 0;

  Future<void> loadHistory() async {
    if (isClosed || state.isLoading) return;

    final version = ++_requestVersion;

    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
    ));

    try {
      final items = await _repository.getHistory();

      if (isClosed || version != _requestVersion) return;

      emit(state.copyWith(
        isLoading: false,
        items: items,
      ));
    } catch (error) {
      if (isClosed || version != _requestVersion) return;

      emit(state.copyWith(
        isLoading: false,
        errorMessage: error is ApiException
            ? error.message
            : 'Unable to load prediction history.',
      ));
    }
  }

  void clear() {
    _requestVersion++;

    if (isClosed) return;

    emit(const HistoryState());
  }
}
