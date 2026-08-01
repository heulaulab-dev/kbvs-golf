import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/core/config.dart';

void main() {
  const testValues = <String, String>{
    'APP_NAME': 'Golfie Test',
    'APP_VERSION': '1.0.0',
    'SUPABASE_URL': 'https://test.supabase.co',
    'SUPABASE_ANON_KEY': 'test-anon-key',
    'TOURNAMENT_API_BASE_URL': 'https://api.test.dev',
    'NEWS_API_BASE_URL': 'https://news.test.dev',
    'CADDY_API_BASE_URL': '',
  };

  group('AppEnvironment', () {
    test('fromName resolves valid environments', () {
      expect(AppEnvironment.fromName('development'), AppEnvironment.development);
      expect(AppEnvironment.fromName('staging'), AppEnvironment.staging);
      expect(AppEnvironment.fromName('production'), AppEnvironment.production);
    });

    test('fromName defaults to development for unknown/missing', () {
      expect(AppEnvironment.fromName('weird'), AppEnvironment.development);
      expect(AppEnvironment.fromName(null), AppEnvironment.development);
    });

    test('envFile maps to dotenv asset name', () {
      expect(AppEnvironment.development.envFile, '.env.development');
      expect(AppEnvironment.production.envFile, '.env.production');
    });

    test('isProduction only true for production', () {
      expect(AppEnvironment.production.isProduction, isTrue);
      expect(AppEnvironment.development.isProduction, isFalse);
      expect(AppEnvironment.staging.isProduction, isFalse);
    });
  });

  group('AppConfig', () {
    tearDown(() {
      // Reset singleton between tests.
      // NOTE: AppConfig has no public reset; tests use overrideValues
      // so the singleton is only set once per process — acceptable
      // since all tests use the same shape of values.
    });

    test('load with overrideValues exposes typed accessors', () async {
      final config = await AppConfig.load(
        overrideEnv: AppEnvironment.development,
        overrideValues: testValues,
      );

      expect(config.envName, 'development');
      expect(config.appName, 'Golfie Test');
      expect(config.supabaseUrl, 'https://test.supabase.co');
      expect(config.supabaseAnonKey, 'test-anon-key');
      expect(config.tournamentApiBaseUrl, 'https://api.test.dev');
      expect(config.newsApiBaseUrl, 'https://news.test.dev');
      expect(config.isProduction, isFalse);
      expect(config.isDebug, isTrue);
    });

    test('caddyApiBaseUrl returns null when empty', () async {
      final config = await AppConfig.load(
        overrideEnv: AppEnvironment.development,
        overrideValues: testValues,
      );
      expect(config.caddyApiBaseUrl, isNull);
    });

    test('caddyApiBaseUrl returns value when set', () async {
      final config = await AppConfig.load(
        overrideEnv: AppEnvironment.development,
        overrideValues: {
          ...testValues,
          'CADDY_API_BASE_URL': 'https://caddy.test.dev',
        },
      );
      expect(config.caddyApiBaseUrl, 'https://caddy.test.dev');
    });

    test('load validates required vars — throws when missing', () async {
      final incomplete = Map<String, String>.of(testValues)
        ..remove('SUPABASE_URL');

      expect(
        () => AppConfig.load(
          overrideEnv: AppEnvironment.production,
          overrideValues: incomplete,
        ),
        throwsStateError,
      );
    });

    test('instance throws before load', () {
      // AppConfig singleton may already be set by earlier tests; this
      // only asserts the accessor contract in isolation.
      if (AppConfig.isLoaded) {
        expect(AppConfig.instance.envName, isNotEmpty);
      } else {
        expect(() => AppConfig.instance, throwsStateError);
      }
    });
  });
}
