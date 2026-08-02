import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'core/config.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/widgets/supabase_wrapper.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'core/theme/golfie_theme.dart';
import 'providers/app_state.dart';
import 'tournament/providers/changes_notifier_tournament_provider.dart';
import 'tournament/repositories/http_tournament_repository.dart';
import 'berita/providers/berita_provider.dart';
import 'berita/repositories/berita_repository.dart';
import 'berita/repositories/http_berita_repository.dart';
import 'berita/repositories/mock_berita_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment config BEFORE runApp.
  // Validates required vars — app refuses to boot with missing config.
  final config = await AppConfig.load();
  debugPrint('⚙ Golfie running in ${config.envName} (${config.appName})');

  // Initialize Supabase with config values.
  await SupabaseWrapper.init(
    baseUrl: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
  );

  runApp(const GolfieApp());
}

class GolfieApp extends StatelessWidget {
  const GolfieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Existing app state
        ChangeNotifierProvider(create: (_) => AppState()),

        // Tournament provider — base URL from AppConfig
        ChangeNotifierProvider(
          create: (_) => ChangesNotifierTournamentProvider(
            repository: HttpTournamentRepository(
              baseUrl: AppConfig.instance.tournamentApiBaseUrl,
            ),
          ),
        ),

        // Berita repository with env-based resolution
        Provider<BeritaRepository>(
          create: (_) => _ResolveBeritaRepository()(),
        ),
        ChangeNotifierProxyProvider<BeritaRepository,
            ChangesNotifierBeritaProvider>(
          create: (ctx) => ChangesNotifierBeritaProvider(
            repository: ctx.read<BeritaRepository>(),
          ),
          update: (_, repo, prev) =>
              prev ?? ChangesNotifierBeritaProvider(repository: repo),
        ),

        // Auth provider — wraps Supabase auth state
        ChangeNotifierProvider(
          create: (_) {
            // Ensure Supabase client is initialized before creating AuthProvider.
            if (!SupabaseWrapper.initialized) {
              if (kDebugMode) {
                debugPrint('⚠ Supabase not initialized — running without auth (demo mode).');
                return AuthProvider.demo();
              }
              throw Exception('Supabase not initialized. Check environment variables.');
            }
            return AuthProvider(SupabaseWrapper.client)
              ..init(); // Loads session immediately
          },
        ),

        // Onboarding provider — tracks step progression
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Golfie',
        debugShowCheckedModeBanner: false,
        theme: GolfieTheme.light(),
        // New splash screen replaces HomeScreen as initial route
        home: const SplashScreen(),
      ),
    );
  }
}

/// Picks the right repo: HTTP if a base URL is configured, otherwise mock.
///
/// Centralizing the choice here means the rest of the tree can blindly
/// `context.read<BeritaRepository>()` without knowing about env vars.
class _ResolveBeritaRepository {
  const _ResolveBeritaRepository();

  BeritaRepository call() {
    final base = AppConfig.instance.newsApiBaseUrl;
    if (base.isNotEmpty) {
      return HttpBeritaRepository(baseUrl: base);
    }
    return MockBeritaRepository();
  }
}