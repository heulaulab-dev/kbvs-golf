import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'berita/providers/berita_provider.dart';
import 'berita/repositories/berita_repository.dart';
import 'berita/repositories/http_berita_repository.dart';
import 'berita/repositories/mock_berita_repository.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'tournament/providers/changes_notifier_tournament_provider.dart';
import 'tournament/repositories/http_tournament_repository.dart';

void main() {
  runApp(const KbVsGolfApp());
}

class KbVsGolfApp extends StatelessWidget {
  const KbVsGolfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(
          create: (_) => ChangesNotifierTournamentProvider(
            repository: HttpTournamentRepository(),
          ),
        ),
        // Single shared repository — providers fan out from it.
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
      ],
      child: MaterialApp(
        title: 'KBVS Golf',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.green,
          fontFamily: null, // system default
        ),
        home: const HomeScreen(),
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
    return const MockBeritaRepository();
  }
}
