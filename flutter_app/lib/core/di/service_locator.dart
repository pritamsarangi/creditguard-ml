import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/credit_risk/data/repositories/prediction_repository.dart';
import '../../services/token_storage.dart';
import '../auth/session_manager.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../../features/credit_risk/presentation/bloc/prediction_bloc.dart';
import '../../features/credit_risk/presentation/cubit/history_cubit.dart';
import '../../features/credit_risk/presentation/cubit/navigation_cubit.dart';

final GetIt sl = GetIt.instance;

abstract final class DioInstances {
  static const String public = 'publicDio';
  static const String authenticated = 'authenticatedDio';
}

Future<void> setupDependencies() async {
  // Centralized networking configuration.
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(),
  );

  sl.registerLazySingleton<Dio>(
    () => sl<ApiClient>().publicDio,
    instanceName: DioInstances.public,
  );

  sl.registerLazySingleton<Dio>(
    () => sl<ApiClient>().authenticatedDio,
    instanceName: DioInstances.authenticated,
  );

  // Public authentication repository.
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      sl<Dio>(instanceName: DioInstances.public),
    ),
  );

  sl.registerLazySingleton<TokenStorage>(
    () => TokenStorage.instance,
  );

  sl.registerLazySingleton<SessionManager>(
    () => SessionManager(
      authRepository: sl<AuthRepository>(),
      tokenStorage: sl<TokenStorage>(),
    ),
  );

  // Protected credit risk repository.
  sl.registerLazySingleton<PredictionRepository>(
    () => PredictionRepository(
      sl<Dio>(instanceName: DioInstances.authenticated),
    ),
  );

  // AuthBloc has its own lifecycle.
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: sl<AuthRepository>(),
      sessionManager: sl<SessionManager>(),
    ),
  );

  // JWT handling belongs only to authenticated Dio.
  sl<Dio>(instanceName: DioInstances.authenticated).interceptors.add(
        AuthInterceptor(
          dio: sl<Dio>(
            instanceName: DioInstances.authenticated,
          ),
          sessionManager: sl<SessionManager>(),
        ),
      );

  sl.registerFactory<PredictionBloc>(
    () => PredictionBloc(
      repository: sl<PredictionRepository>(),
    ),
  );

  sl.registerFactory<HistoryCubit>(
    () => HistoryCubit(
      repository: sl<PredictionRepository>(),
    ),
  );

  sl.registerFactory<NavigationCubit>(
    () => NavigationCubit(),
  );
}
