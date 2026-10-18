import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'init.dart';

Future<void> main() async {
  await initializeApp();

  runApp(const CreditGuardApp());
}
