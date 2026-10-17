/// Deployment environment for the admin app.
enum AppEnvironment {
  dev,
  staging,
  prod;

  static AppEnvironment fromString(String value) {
    return switch (value.toLowerCase()) {
      'production' || 'prod' => AppEnvironment.prod,
      'staging' || 'stage' => AppEnvironment.staging,
      _ => AppEnvironment.dev,
    };
  }

  String get envFileName => switch (this) {
        AppEnvironment.prod => '.env.prod',
        AppEnvironment.staging => '.env.staging',
        AppEnvironment.dev => '.env.dev',
      };

  String get label => switch (this) {
        AppEnvironment.prod => 'Production',
        AppEnvironment.staging => 'Staging',
        AppEnvironment.dev => 'Development',
      };

  bool get isProduction => this == AppEnvironment.prod;
}
