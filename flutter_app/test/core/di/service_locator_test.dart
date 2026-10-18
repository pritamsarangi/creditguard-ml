import 'package:flutter_test/flutter_test.dart';

import 'package:creditguard_flutter/core/di/service_locator.dart';
import 'package:creditguard_flutter/features/credit_risk/data/repositories/prediction_repository.dart';

void main() {
  test('PredictionRepository is registered in GetIt', () async {
    await setupDependencies();

    expect(
      sl.isRegistered<PredictionRepository>(),
      isTrue,
    );

    expect(
      sl<PredictionRepository>(),
      isA<PredictionRepository>(),
    );

    await sl.reset();
  });
}