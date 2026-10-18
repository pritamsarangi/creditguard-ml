import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  void changeTab(int index) {
    if (index < 0 || index > 1) return;

    emit(index);
  }

  void reset() => emit(0);
}
