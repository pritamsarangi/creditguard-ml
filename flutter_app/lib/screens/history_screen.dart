import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/credit_risk/presentation/cubit/history_cubit.dart';
import '../features/credit_risk/presentation/cubit/history_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HistoryCubit, HistoryState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          current.errorMessage != previous.errorMessage &&
          current.items.isNotEmpty,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(message)),
          );
      },
      builder: (context, state) {
        final historyCubit = context.read<HistoryCubit>();

        if (state.isLoading && state.items.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.items.isEmpty) {
          final errorMessage = state.errorMessage;

          return RefreshIndicator(
            onRefresh: historyCubit.loadHistory,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 180),
                Text(
                  errorMessage ?? 'No predictions yet.',
                  textAlign: TextAlign.center,
                ),
                if (errorMessage != null)
                  Center(
                    child: TextButton.icon(
                      onPressed: historyCubit.loadHistory,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (state.isLoading) const LinearProgressIndicator(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: historyCubit.loadHistory,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = state.items[index];

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            '${(item.defaultProbability * 100).round()}',
                          ),
                        ),
                        title: Text(
                          '${item.riskBand.toUpperCase()} risk',
                        ),
                        subtitle: Text(
                          '${item.createdAt.toLocal()} • ${item.modelName}',
                        ),
                        trailing: Icon(
                          item.predictedDefault == 1
                              ? Icons.warning_amber
                              : Icons.check_circle_outline,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
