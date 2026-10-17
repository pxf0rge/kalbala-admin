import 'package:kalbala_admin/bootstrap.dart';
import 'package:kalbala_admin/core/config/app_environment.dart';

Future<void> main() {
  const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  return bootstrap(AppEnvironment.fromString(appEnv));
}
