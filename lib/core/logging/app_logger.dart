import 'package:flutter/foundation.dart';
import 'package:kalbala_admin/core/config/app_config.dart';

abstract final class AppLogger {
  static void debug(String message) {
    if (AppConfig.enableDebugLogging) {
      debugPrint(message);
    }
  }

  static void warning(String message) {
    if (AppConfig.enableDebugLogging) {
      debugPrint('WARNING: $message');
    }
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (AppConfig.enableDebugLogging) {
      debugPrint('ERROR: $message${error != null ? ' ($error)' : ''}');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}
