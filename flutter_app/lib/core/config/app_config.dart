import 'app_environment.dart';

abstract final class AppConfig {
  static const String _environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static AppEnvironment get environment =>
      _environment == 'prod' ? AppEnvironment.prod : AppEnvironment.dev;

  static bool get isProduction => environment == AppEnvironment.prod;

  static void validate() {
    if (_environment != 'dev' && _environment != 'prod') {
      throw StateError('Unsupported APP_ENV: $_environment');
    }

    final uri = Uri.tryParse(apiBaseUrl);

    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw StateError(
        'A valid API_BASE_URL must be configured.',
      );
    }

    if (isProduction && uri.scheme != 'https') {
      throw StateError(
        'Production API_BASE_URL must use HTTPS.',
      );
    }
  }
}
