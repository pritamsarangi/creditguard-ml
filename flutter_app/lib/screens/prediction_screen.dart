import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/credit_risk/presentation/bloc/prediction_bloc.dart';
import '../features/credit_risk/presentation/bloc/prediction_event.dart';
import '../features/credit_risk/presentation/bloc/prediction_state.dart';
import '../features/credit_risk/presentation/cubit/history_cubit.dart';
import '../models/credit_input.dart';
import '../widgets/number_field.dart';
import '../widgets/section_card.dart';
import '../widgets/status_dropdown.dart';
import 'package:go_router/go_router.dart';

import '../app/app_router.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _creditLimit = TextEditingController(text: '120000');
  final _age = TextEditingController(text: '32');
  final _currentBill = TextEditingController(text: '90000');
  final _previousBill = TextEditingController(text: '85000');
  final _latestPayment = TextEditingController(text: '5000');
  final _previousPayment = TextEditingController(text: '5000');

  int _recentPaymentStatus = 0;
  int _previousPaymentStatus = 0;

  @override
  void dispose() {
    for (final controller in [
      _creditLimit,
      _age,
      _currentBill,
      _previousBill,
      _latestPayment,
      _previousPayment,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadDemo() {
    if (context.read<PredictionBloc>().state.isLoading) return;

    final demo = CreditInput.demo();

    _creditLimit.text = demo.creditLimit.toStringAsFixed(0);
    _age.text = demo.age.toString();
    _currentBill.text = demo.currentBillAmount.toStringAsFixed(0);
    _previousBill.text = demo.previousBillAmount.toStringAsFixed(0);
    _latestPayment.text = demo.latestPaymentAmount.toStringAsFixed(0);
    _previousPayment.text = demo.previousPaymentAmount.toStringAsFixed(0);

    setState(() {
      _recentPaymentStatus = demo.recentPaymentStatus;
      _previousPaymentStatus = demo.previousPaymentStatus;
    });

    context.read<PredictionBloc>().add(
          const PredictionEvent.cleared(),
        );
  }

  void _submit() {
    final bloc = context.read<PredictionBloc>();
    if (bloc.state.isLoading) return;

    FocusManager.instance.primaryFocus?.unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final input = CreditInput(
      creditLimit: double.parse(_creditLimit.text.trim()),
      age: int.parse(_age.text.trim()),
      recentPaymentStatus: _recentPaymentStatus,
      previousPaymentStatus: _previousPaymentStatus,
      currentBillAmount: double.parse(_currentBill.text.trim()),
      previousBillAmount: double.parse(_previousBill.text.trim()),
      latestPaymentAmount: double.parse(_latestPayment.text.trim()),
      previousPaymentAmount: double.parse(_previousPayment.text.trim()),
    );

    bloc.add(PredictionEvent.submitted(input: input));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PredictionBloc, PredictionState>(
      listenWhen: (previous, current) =>
          previous.isLoading &&
          !current.isLoading &&
          current.prediction != null,
      listener: (context, state) {
        if (state.prediction == null) return;

        unawaited(context.read<HistoryCubit>().loadHistory());

        unawaited(
          context.pushNamed<void>(AppRoutes.resultName),
        );
      },
      child: BlocBuilder<PredictionBloc, PredictionState>(
        builder: (context, state) {
          final errorMessage = state.errorMessage;
          final colorScheme = Theme.of(context).colorScheme;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _IntroCard(
                  onLoadDemo: state.isLoading ? null : _loadDemo,
                ),
                const SizedBox(height: 14),
                if (errorMessage != null && errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Card(
                      color: colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: TextStyle(
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                SectionCard(
                  title: 'Credit details',
                  child: Column(
                    children: [
                      NumberField(
                        controller: _creditLimit,
                        label: 'Credit limit',
                        helperText: 'Your total available credit limit',
                        min: 1,
                      ),
                      const SizedBox(height: 14),
                      NumberField(
                        controller: _currentBill,
                        label: 'Current bill amount',
                        helperText: 'Most recent statement balance',
                        min: 0,
                      ),
                      const SizedBox(height: 14),
                      NumberField(
                        controller: _previousBill,
                        label: 'Previous bill amount',
                        helperText:
                            'Statement balance from the previous period',
                        min: 0,
                      ),
                    ],
                  ),
                ),
                SectionCard(
                  title: 'Recent payments',
                  child: Column(
                    children: [
                      NumberField(
                        controller: _latestPayment,
                        label: 'Latest payment amount',
                        helperText: 'Most recent amount paid',
                        min: 0,
                      ),
                      const SizedBox(height: 14),
                      NumberField(
                        controller: _previousPayment,
                        label: 'Previous payment amount',
                        helperText: 'Amount paid in the previous period',
                        min: 0,
                      ),
                    ],
                  ),
                ),
                SectionCard(
                  title: 'Repayment status',
                  child: Column(
                    children: [
                      StatusDropdown(
                        label: 'Most recent status',
                        value: _recentPaymentStatus,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _recentPaymentStatus = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      StatusDropdown(
                        label: 'Previous status',
                        value: _previousPaymentStatus,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _previousPaymentStatus = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SectionCard(
                  title: 'About you',
                  child: NumberField(
                    controller: _age,
                    label: 'Age',
                    helperText: 'Age must be between 18 and 100',
                    decimal: false,
                    min: 18,
                    max: 100,
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: state.isLoading ? null : _submit,
                    icon: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.analytics_outlined),
                    label: Text(
                      state.isLoading
                          ? 'Assessing risk...'
                          : 'Assess Default Risk',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Educational estimate only. CreditGuard does not make lending or credit decisions.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final VoidCallback? onLoadDemo;

  const _IntroCard({
    required this.onLoadDemo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Credit risk assessment',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Enter a few recent credit and repayment details. '
              'The model will estimate payment-default risk and explain '
              'the result in plain language.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onLoadDemo,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Load example values'),
            ),
          ],
        ),
      ),
    );
  }
}
