import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../models/history_item.dart';

part 'history_state.freezed.dart';

@freezed
abstract class HistoryState with _$HistoryState {
  const factory HistoryState({
    @Default(false) bool isLoading,
    @Default(<HistoryItem>[]) List<HistoryItem> items,
    String? errorMessage,
  }) = _HistoryState;
}
