import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/di/service_locator.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import 'app_router.dart';

class CreditGuardApp extends StatefulWidget {
  const CreditGuardApp({super.key});

  @override
  State<CreditGuardApp> createState() => _CreditGuardAppState();
}

class _CreditGuardAppState extends State<CreditGuardApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();

    _authBloc = sl<AuthBloc>();
    _appRouter = AppRouter(_authBloc);

    _authBloc.add(
      const AuthEvent.sessionRestorationRequested(),
    );
  }

  @override
  void dispose() {
    _appRouter.dispose();
    unawaited(_authBloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'CreditGuard',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: _appRouter.router,
          );
        },
      ),
    );
  }
}
