import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalbala_admin/app.dart';
import 'package:kalbala_admin/core/config/app_config.dart';
import 'package:kalbala_admin/core/config/app_environment.dart';
import 'package:kalbala_admin/core/config/env.dart';
import 'package:kalbala_admin/core/config/supabase_config.dart';
import 'package:kalbala_admin/core/logging/app_logger.dart';

Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.configure(environment);
  AppLogger.debug('Starting KalBala Admin (${AppConfig.environmentLabel})');

  await runZonedGuarded(() async {
    await Env.load(environment: environment);

    if (Env.isConfigured) {
      await SupabaseConfig.initialize();
    } else {
      AppLogger.warning('Supabase credentials not configured');
    }

    runApp(const ProviderScope(child: KalBalaAdminApp()));
  }, (error, stackTrace) {
    AppLogger.error(
      'Unhandled zone error',
      error: error,
      stackTrace: stackTrace,
    );
  });
}
