import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/service_locator.dart';
import '../features/credit_risk/presentation/bloc/prediction_bloc.dart';
import '../features/credit_risk/presentation/cubit/history_cubit.dart';
import '../features/credit_risk/presentation/cubit/navigation_cubit.dart';

class AuthenticatedScope extends StatelessWidget {
  const AuthenticatedScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PredictionBloc>(
          create: (_) => sl<PredictionBloc>(),
        ),
        BlocProvider<HistoryCubit>(
          create: (_) => sl<HistoryCubit>(),
        ),
        BlocProvider<NavigationCubit>(
          create: (_) => sl<NavigationCubit>(),
        ),
      ],
      child: child,
    );
  }
}
