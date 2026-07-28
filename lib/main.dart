import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'tournament/providers/changes_notifier_tournament_provider.dart';
import 'tournament/repositories/http_tournament_repository.dart';

void main() {
  const runApp(const KbVsGolfApp());
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
      ],
      child: MaterialApp(
        title: 'KBVS Golf',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.green,
          fontFamily: null, // system default
          errorTheme: ErrorThemeData(
            color: Colors.red.shade700,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}