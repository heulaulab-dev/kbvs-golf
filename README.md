# KBVS Golf — Flutter Golf Companion App

**Status:** Full application with caddy tips calculator, shot analysis, and tournament tracking. Ready for Android/iOS web development.

## Current State

✅ Flutter 3.44.8 (stable) installed at `/home/kiyaya/tools/flutter`  
✅ Tournament list UI + real HTTP repository (HTTP backend at `api-local.kbvalbury.com:9100`)  
✅ Caddy Tips calculator with yardage → fee computation (ECI/SCI caps applied)  
✅ Shot analysis placeholder screen (AI integration pending)  
✅ All providers wired via MultiProvider in `main.dart`  
✅ 59/59 tests passing across all layers  

## Project Structure

```
kbvs-golf/
├── pubspec.yaml              # Dependencies, app metadata
├── lib/
│   ├── main.dart             # Entry point — MultiProvider + MaterialApp
│   ├── caddy/                # Caddy tips logic
│   │   └── calculator.dart   # ECI/SCI-based fee calculator with min/max caps
│   ├── providers/            # Application state
│   │   └── app_state.dart    # AppState (caddy tips flag, yardage, fee, course)
│   ├── screens/
│   │   ├── home_screen.dart  # Home route — caddy tips toggle + tournaments nav
│   │   ├── caddy_tips_screen.dart
│   │   ├── analysis_screen.dart        # Placeholder for AI shot analysis
│   │   └── tournament_list_screen.dart # Tournament list with search
│   ├── tournament/           # Tournament subsystem
│   │   ├── models/
│   │   │   ├── tournament.dart
│   │   │   ├── skill_level.dart
│   │   │   ├── tournament_format.dart
│   │   │   └── tournament_status.dart
│   │   ├── providers/
│   │   │   └── changes_notifier_tournament_provider.state + ChangeNotifier
│   │   └── repositories/
│   │       ├── tournament_repository.dart (abstract)
│   │       ├── http_tournament_repository.dart (real API client)
│   │       └── mock_tournament_repository.dart (tests/local dev)
│   └── services/
│       ├── http_client.dart (abstract HttpClient interface)
│       └── dio_http_client.dart (Dio implementation)
└── test/                     # 59 total tests — coverage mirrors lib structure
```

## Design Framework

Emil Kowalski design skill is loaded (`~/.hermes/skills/emil-kowalski-design-skills/`): 8 modules covering animation vocabulary, apple design principles, emil design engineering, finding animation opportunities, improving animations, picking UI libraries, prototyping, and reviewing animations. Used throughout KBVS Golf PRD visual direction.

## Notes on Networking

- `HttpTournamentRepository` uses Dio with default baseUrl `api-local.kbvalbury.com:9100` (**HTTP only**). 
- On Android API 28+ or iOS, you must enable cleartext traffic or switch to HTTPS. For local dev this is fine; production needs proper TLS or Android manifest exception (`android:usesCleartextTraffic="true"` / NSAppTransportSecurity).

## Next Steps (Roadmap)

Implement remaining Phase 5+ features from PRD:
- Tournament detail view with registration flow
- AI-powered shot analysis (integrate with cloud vision/AI service)
- User authentication & profile persistence (Hive/SQLite)
- Offline-first capability with sync queue
- Push notifications for upcoming tournaments

## Running

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
flutter pub get
flutter run # or flutter run -d <device>
flutter test # 59/59 pass
</file>
