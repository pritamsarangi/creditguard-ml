import 'package:flutter/widgets.dart';

import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.validate();

  await setupDependencies();
}
