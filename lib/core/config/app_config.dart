import 'package:kalbala_admin/core/config/app_environment.dart';

abstract final class AppConfig {
  static AppEnvironment _environment = AppEnvironment.dev;

  static AppEnvironment get environment => _environment;

  static void configure(AppEnvironment environment) {
    _environment = environment;
  }

  static bool get isProduction => _environment.isProduction;

  static bool get isDevelopment => _environment == AppEnvironment.dev;

  static bool get enableDebugLogging => !isProduction;

  static String get environmentLabel => _environment.label;
}
