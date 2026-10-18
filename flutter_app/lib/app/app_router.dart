import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimensions.dart';
import '../core/constants/app_padding.dart';
import '../core/constants/app_spacing.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/credit_risk/presentation/bloc/prediction_bloc.dart';
import '../features/credit_risk/presentation/bloc/prediction_state.dart';
import '../screens/home_screen.dart';
import '../screens/risk_result_screen.dart';
import 'authenticated_scope.dart';

abstract final class AppRoutes {
  static const loading = '/loading';
  static const login = '/login';
  static const otp = '/otp';
  static const restoreError = '/restore-error';
  static const home = '/home';

  static const resultName = 'result';
  static const resultSegment = 'result';
  static const result = '$home/$resultSegment';
}

class AppRouter {
  AppRouter(AuthBloc authBloc) : _authRefresh = _AuthRouterRefresh(authBloc) {
    router = GoRouter(
      initialLocation: AppRoutes.loading,
      refreshListenable: _authRefresh,
      redirect: (context, state) {
        final auth = _authRefresh.state;
        final path = state.uri.path;

        switch (auth.stage) {
          case AuthStage.initializing:
            return path == AppRoutes.loading ? null : AppRoutes.loading;

          case AuthStage.login:
            return path == AppRoutes.login ? null : AppRoutes.login;

          case AuthStage.verifyOtp:
            return path == AppRoutes.otp ? null : AppRoutes.otp;

          case AuthStage.restoreError:
            return path == AppRoutes.restoreError
                ? null
                : AppRoutes.restoreError;

          case AuthStage.authenticated:
            final isProtectedRoute =
                path == AppRoutes.home || path == AppRoutes.result;

            return isProtectedRoute ? null : AppRoutes.home;
        }
      },
      routes: [
        GoRoute(
          path: AppRoutes.loading,
          builder: (context, state) => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.otp,
          builder: (context, state) => const OtpVerificationScreen(),
        ),
        GoRoute(
          path: AppRoutes.restoreError,
          builder: (context, state) => const _RestoreErrorScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return AuthenticatedScope(
              key: ValueKey<int>(_authRefresh.sessionGeneration),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: AppRoutes.resultSegment,
                  name: AppRoutes.resultName,
                  builder: (context, state) => const _ResultRoute(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  final _AuthRouterRefresh _authRefresh;
  late final GoRouter router;

  void dispose() {
    router.dispose();
    _authRefresh.dispose();
  }
}

class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(AuthBloc authBloc) : state = authBloc.state {
    _subscription = authBloc.stream.listen(_onAuthChanged);
  }

  late final StreamSubscription<AuthState> _subscription;

  AuthState state;
  int sessionGeneration = 0;

  void _onAuthChanged(AuthState next) {
    final previous = state;

    final enteredNewSession = next.stage == AuthStage.authenticated &&
        (previous.stage != AuthStage.authenticated ||
            previous.email != next.email);

    if (enteredNewSession) {
      sessionGeneration++;
    }

    state = next;

    if (previous.stage != next.stage || enteredNewSession) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

class _RestoreErrorScreen extends StatelessWidget {
  const _RestoreErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppPadding.screen,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.maxContentWidth,
              ),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_outlined),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Unable to restore your session',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        state.errorMessage ?? 'Please check your connection.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                const AuthEvent.sessionRestorationRequested(),
                              );
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRoute extends StatelessWidget {
  const _ResultRoute();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PredictionBloc, PredictionState>(
      builder: (context, state) {
        final prediction = state.prediction;

        if (prediction != null) {
          return RiskResultScreen(prediction: prediction);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Assessment Result'),
          ),
          body: Center(
            child: Padding(
              padding: AppPadding.screen,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No assessment is available in this session.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: const Text('Go to assessment'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
