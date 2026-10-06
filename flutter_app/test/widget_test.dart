import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:creditguard_flutter/main.dart';
import 'package:creditguard_flutter/controllers/home_controller.dart';

void main() {
  testWidgets('CreditGuard app renders', (tester) async {
    Get.put(HomeController());
    await tester.pumpWidget(const CreditGuardApp());
    expect(find.text('CreditGuard'), findsOneWidget);
    Get.delete<HomeController>();
  });
}
