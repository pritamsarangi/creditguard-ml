import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/prediction_response.dart';
import '../widgets/risk_result_card.dart';

class RiskResultScreen extends StatelessWidget {
  final PredictionResponse prediction;

  const RiskResultScreen({
    super.key,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Result'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          RiskResultCard(prediction: prediction),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      prediction.explanationNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            prediction.disclaimer,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: Get.back,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
