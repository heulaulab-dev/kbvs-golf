/// Supported app environments.
///
/// Selected at build time via `--dart-define=ENV=<name>`.
/// Each value maps to the corresponding `.env.<name>` asset file.
enum AppEnvironment {
  development,
  staging,
  production;

  /// Resolves the active environment from the `ENV` dart-define.
  ///
  /// Defaults to [development] when no define is passed — safe for local
  /// `flutter run` without flags, while production builds must pass
  /// `--dart-define=ENV=production` explicitly.
  static AppEnvironment fromName([String? name]) {
    return AppEnvironment.values.firstWhere(
      (env) => env.name == name,
      orElse: () => AppEnvironment.development,
    );
  }

  /// The `.env.<name>` asset file loaded by flutter_dotenv.
  String get envFile => '.env.$name';

  /// Human-readable label for debug UIs / crash reports.
  String get label => switch (this) {
        AppEnvironment.development => 'Development',
        AppEnvironment.staging => 'Staging',
        AppEnvironment.production => 'Production',
      };

  bool get isProduction => this == AppEnvironment.production;
}
