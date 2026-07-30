import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/widgets/supabase_wrapper.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'core/theme/golfie_theme.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'tournament/providers/changes_notifier_tournament_provider.dart';
import 'tournament/repositories/http_tournament_repository.dart';
import 'berita/providers/berita_provider.dart';
import 'berita/repositories/berita_repository.dart';
import 'berita/repositories/http_berita_repository.dart';
import 'berita/repositories/mock_berita_repository.dart';

// Read Supabase config from environment variables at compile time
final _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '',
);
final _anonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '',
);

void main() {
  // Initialize Supabase with environment variables BEFORE runApp
  // This ensures the client is ready when providers request it
  if (_supabaseUrl.isNotEmpty && _anonKey.isNotEmpty) {
    // Initialize SupabaseWrapper with env values
    SupabaseWrapper.init(
      baseUrl: _supabaseUrl,
      anonKey: _anonKey,
    );
  } else {
    // Fallback for development without env vars — print warning
    if (kDebugMode) {
      print('⚠ SUPABASE_URL and SUPABASE_ANON_KEY not set in environment.');
      print('Run with: dart run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...');
    }
  }

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

        // Tournament provider (unchanged)
        ChangeNotifierProvider(
          create: (_) => ChangesNotifierTournamentProvider(
            repository: HttpTournamentRepository(),
          ),
        ),

        // Berita repository with env-based resolution
        Provider<BeritaRepository>(
          create: (_) => const _ResolveBeritaRepository()(),
        ),
        ChangeNotifierProxyProvider<BeritaRepository,
            ChangesNotifierBeritaProvider>(
          create: (ctx) => ChangesNotifierBeritaProvider(
            repository: ctx.read<BeritaRepository>(),
          ),
          update: (_, repo, prev) =>
              prev ?? ChangesNotifierBeritaProvider(repository: repo),
        ),

        // NEW: Auth provider — wraps Supabase auth state
        ChangeNotifierProvider(
          create: (_) {
            // Ensure Supabase client is initialized before creating AuthProvider
            if (!SupabaseWrapper.initialized) {
              throw Exception('Supabase not initialized. Check environment variables.');
            }
            return AuthProvider(SupabaseWrapper.client)
              ..init(); // Loads session immediately
          },
        ),

        // NEW: Onboarding provider — tracks step progression
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
    // const String.fromEnvironment is the only way to read compile-time
    // config without pulling in dart:mirrors or a JSON file.
    const base = String.fromEnvironment(
      'GOLFIE_API_BASE',
      defaultValue: '',
    );
    if (base.isNotEmpty) {
      return HttpBeritaRepository(baseUrl: base);
    }
    return MockBeritaRepository();
  }
}