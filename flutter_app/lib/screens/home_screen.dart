import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/credit_risk/presentation/cubit/history_cubit.dart';
import '../features/credit_risk/presentation/cubit/navigation_cubit.dart';
import 'history_screen.dart';
import 'prediction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentTab) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              currentTab == 0 ? 'CreditGuard' : 'Prediction History',
            ),
            actions: [
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout_outlined),
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEvent.logoutRequested(),
                      );
                },
              ),
            ],
          ),
          body: IndexedStack(
            index: currentTab,
            children: const [
              PredictionScreen(),
              HistoryScreen(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentTab,
            onDestinationSelected: (index) {
              context.read<NavigationCubit>().changeTab(index);

              if (index == 1) {
                context.read<HistoryCubit>().loadHistory();
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.assessment_outlined),
                selectedIcon: Icon(Icons.assessment),
                label: 'Assess',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'History',
              ),
            ],
          ),
        );
      },
    );
  }
}
