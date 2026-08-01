import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_environment.dart';

/// Single source of truth for all environment-dependent configuration.
///
/// Loaded once at app startup via [AppConfig.load], then read-only.
/// All app code MUST read config through this class — never call
/// `dotenv.env[...]` directly. This keeps config:
///   * typed (no stringly-typed lookups scattered across the app)
///   * validated (missing required vars fail fast at startup)
///   * testable (deterministic values, no platform-channel surprises)
class AppConfig {
  AppConfig._(this.env, this._map);

  /// Active environment, resolved from `--dart-define=ENV=`.
  final AppEnvironment env;

  /// Raw key-value map loaded from the `.env.<env>` asset.
  final Map<String, String> _map;

  static AppConfig? _instance;

  /// Current config. Throws if [load] has not completed.
  static AppConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError(
        'AppConfig not loaded. Call AppConfig.load() in main() before runApp().',
      );
    }
    return config;
  }

  static bool get isLoaded => _instance != null;

  // ── Loading ─────────────────────────────────────────────────────────

  /// Loads the env asset for the current environment and validates
  /// required variables. Must be called in `main()` before `runApp()`.
  static Future<AppConfig> load({
    AppEnvironment? overrideEnv,
    Map<String, String>? overrideValues,
  }) async {
    final env = overrideEnv ?? AppEnvironment.fromName(_envDefine);

    Map<String, String> values;
    if (overrideValues != null) {
      // Test path — allow injecting values without touching assets.
      values = Map.of(overrideValues);
    } else {
      values = await _loadDotEnv(env);
    }

    final config = AppConfig._(env, values);
    config._validate();
    _instance = config;
    return config;
  }

  static Future<Map<String, String>> _loadDotEnv(AppEnvironment env) async {
    // flutter_dotenv 6.x: load the asset file, then extract env map.
    await dotenv.load(fileName: env.envFile);
    return Map<String, String>.from(dotenv.env);
  }

  /// Compile-time `ENV` dart-define, e.g. `development`, `staging`,
  /// `production`. Empty when not set.
  static const String _envDefine = String.fromEnvironment('ENV');

  // ── Required-variable validation ────────────────────────────────────

  /// Variables that MUST exist in every environment. App refuses to
  /// boot when any of these are missing or empty.
  static const Set<String> _requiredKeys = {
    'APP_NAME',
    'APP_VERSION',
    'SUPABASE_URL',
    'SUPABASE_ANON_KEY',
    'TOURNAMENT_API_BASE_URL',
    'NEWS_API_BASE_URL',
  };

  void _validate() {
    final missing = <String>[
      for (final key in _requiredKeys)
        if (!_hasValue(key)) key,
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'AppConfig: missing required env variables in ${env.envFile}: '
        '${missing.join(', ')}. Check the file exists and is complete.',
      );
    }
  }

  bool _hasValue(String key) {
    final value = _map[key];
    return value != null && value.trim().isNotEmpty;
  }

  // ── Typed accessors ─────────────────────────────────────────────────

  /// The active environment name, e.g. `development`.
  String get envName => env.name;

  bool get isDebug => !env.isProduction;

  /// Whether the environment is production (affects analytics, logging).
  bool get isProduction => env.isProduction;

  String get appName => _string('APP_NAME');

  String get appVersion => _string('APP_VERSION');

  /// Supabase project URL.
  String get supabaseUrl => _string('SUPABASE_URL');

  /// Supabase anon key (publishable, safe for clients).
  String get supabaseAnonKey => _string('SUPABASE_ANON_KEY');

  /// Tournament API base URL.
  String get tournamentApiBaseUrl => _string('TOURNAMENT_API_BASE_URL');

  /// News (Golfie API) base URL.
  String get newsApiBaseUrl => _string('NEWS_API_BASE_URL');

  /// Caddy fee calculator API base URL (may be empty).
  String? get caddyApiBaseUrl {
    final value = _map['CADDY_API_BASE_URL'];
    return (value == null || value.trim().isEmpty) ? null : value.trim();
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  String _string(String key) {
    final value = _map[key];
    if (value == null || value.trim().isEmpty) {
      throw StateError('AppConfig: "$key" is not set for env ${env.name}.');
    }
    return value.trim();
  }

  @override
  String toString() => 'AppConfig(env: ${env.name}, keys: ${_map.keys.length})';
}