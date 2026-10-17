import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kalbala_admin/core/config/app_config.dart';
import 'package:kalbala_admin/core/config/app_environment.dart';

/// Priority: `--dart-define` > environment-specific dotenv file > `.env`.
abstract final class Env {
  static bool _loaded = false;
  static String? _loadedFile;

  static AppEnvironment get environment => AppConfig.environment;

  static Future<void> load({AppEnvironment? environment}) async {
    if (_loaded) return;

    final resolvedEnvironment = environment ??
        AppEnvironment.fromString(
          const String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
        );
    AppConfig.configure(resolvedEnvironment);

    final candidates = <String>[
      if (resolvedEnvironment != AppEnvironment.dev) resolvedEnvironment.envFileName,
      '.env',
    ];

    for (final fileName in candidates) {
      try {
        await dotenv.load(fileName: fileName);
        _loadedFile = fileName;
        break;
      } on Object {
        // Try the next candidate.
      }
    }

    _loaded = true;
  }

  static String? get loadedFileName => _loadedFile;

  static String get supabaseUrl =>
      _read('SUPABASE_URL', const String.fromEnvironment('SUPABASE_URL'));

  static String get supabaseAnonKey => _read(
        'SUPABASE_ANON_KEY',
        const String.fromEnvironment('SUPABASE_ANON_KEY'),
      );

  static String get devLoginKey => _read(
        'DEV_LOGIN_KEY',
        const String.fromEnvironment('DEV_LOGIN_KEY'),
      );

  static String get devOtpCode {
    final code = _read(
      'DEV_OTP_CODE',
      const String.fromEnvironment('DEV_OTP_CODE', defaultValue: '123456'),
    );
    return code.isEmpty ? '123456' : code;
  }

  static bool get devLoginEnabled =>
      !AppConfig.isProduction && devLoginKey.isNotEmpty;

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String _read(String key, String fallback) {
    final fromDotenv = dotenv.maybeGet(key);
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    return fallback;
  }
}
