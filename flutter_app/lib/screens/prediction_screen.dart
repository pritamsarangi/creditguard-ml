import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/number_field.dart';
import '../widgets/section_card.dart';
import '../widgets/status_dropdown.dart';

class PredictionScreen extends GetView<HomeController> {
  const PredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (_) {
        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _IntroCard(controller: controller),
              const SizedBox(height: 14),

              Obx(() {
                if (controller.errorMessage.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              controller.errorMessage.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              SectionCard(
                title: 'Credit details',
                child: Column(
                  children: [
                    NumberField(
                      controller: controller.creditLimit,
                      label: 'Credit limit',
                      helperText: 'Your total available credit limit',
                      min: 1,
                    ),
                    const SizedBox(height: 14),
                    NumberField(
                      controller: controller.currentBill,
                      label: 'Current bill amount',
                      helperText: 'Most recent statement balance',
                      min: 0,
                    ),
                    const SizedBox(height: 14),
                    NumberField(
                      controller: controller.previousBill,
                      label: 'Previous bill amount',
                      helperText: 'Statement balance from the previous period',
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
                      controller: controller.latestPayment,
                      label: 'Latest payment amount',
                      helperText: 'Most recent amount paid',
                      min: 0,
                    ),
                    const SizedBox(height: 14),
                    NumberField(
                      controller: controller.previousPayment,
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
                      value: controller.recentPaymentStatus,
                      onChanged: (value) {
                        if (value == null) return;
                        controller.recentPaymentStatus = value;
                        controller.update();
                      },
                    ),
                    const SizedBox(height: 14),
                    StatusDropdown(
                      label: 'Previous status',
                      value: controller.previousPaymentStatus,
                      onChanged: (value) {
                        if (value == null) return;
                        controller.previousPaymentStatus = value;
                        controller.update();
                      },
                    ),
                  ],
                ),
              ),

              SectionCard(
                title: 'About you',
                child: NumberField(
                  controller: controller.age,
                  label: 'Age',
                  helperText: 'Age must be between 18 and 100',
                  decimal: false,
                  min: 18,
                  max: 100,
                ),
              ),

              const SizedBox(height: 2),

              Obx(
                () => SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.assessRisk,
                    icon: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.analytics_outlined),
                    label: Text(
                      controller.isLoading.value
                          ? 'Assessing risk...'
                          : 'Assess Default Risk',
                    ),
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
    );
  }
}

class _IntroCard extends StatelessWidget {
  final HomeController controller;

  const _IntroCard({
    required this.controller,
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
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Credit risk assessment',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
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
              onPressed: controller.loadDemo,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Load example values'),
            ),
          ],
        ),
      ),
    );
  }
}
