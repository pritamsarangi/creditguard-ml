import 'package:flutter/material.dart';

import '../models/prediction_response.dart';

class RiskResultCard extends StatelessWidget {
  final PredictionResponse prediction;

  const RiskResultCard({
    super.key,
    required this.prediction,
  });

  Color _riskColor(BuildContext context) {
    switch (prediction.risk.level) {
      case 'high':
        return Theme.of(context).colorScheme.error;
      case 'medium':
        return Colors.orange.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  IconData _factorIcon(String status) {
    switch (status) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'positive':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _factorColor(
    BuildContext context,
    String status,
  ) {
    switch (status) {
      case 'warning':
        return Colors.orange.shade800;
      case 'positive':
        return Colors.green.shade700;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    size: 34,
                    color: color,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  prediction.risk.label,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${prediction.risk.percentage}%',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  'estimated default probability',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 9,
                    value: prediction.risk.estimatedProbability
                        .clamp(0.0, 1.0),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction.summary.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(prediction.summary.message),
              ],
            ),
          ),
        ),
        if (prediction.factors.isNotEmpty) ...[
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What may be influencing this assessment?',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'These are contextual signals from the information you entered.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  ...prediction.factors.map(
                    (factor) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _factorIcon(factor.status),
                            color: _factorColor(
                              context,
                              factor.status,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  factor.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(factor.message),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
