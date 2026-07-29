# KBVS Golf — Flutter Golf Companion App

**Status:** Flutter app for caddy tips, shot analysis, and tournament tracking.
Target: Android (no iOS project yet). <!-- test-count: 72 -->

## Current State

- Flutter 3.44.8 (stable) installed at `/home/kiyaya/tools/flutter`
- Caddy Tips calculator with yardage → fee computation (ECI/SCI caps applied)
- Tournament list UI + real HTTP repository (HTTP backend at `api-local.kbvalbury.com:9100`)
- Shot analysis placeholder screen (AI integration pending — see `docs/backlog/AI_INTEGRATION.md`)
- All providers wired via `MultiProvider` in `main.dart`
- 72/72 tests passing across all layers <!-- test-count: 72 -->

## Project Structure

```
kbvs-golf/
├── pubspec.yaml
├── lib/
│   ├── main.dart                                  # Entry point — MultiProvider + MaterialApp
│   ├── caddy/
│   │   └── calculator.dart                        # ECI/SCI-based fee calculator with min/max caps
│   ├── providers/
│   │   └── app_state.dart                         # AppState (caddy tips flag, yardage, fee, course)
│   ├── screens/
│   │   ├── home_screen.dart                       # Home route — caddy tips toggle + tournaments nav
│   │   ├── caddy_tips_screen.dart                 # Caddy tips screen — yardage input + fee output
│   │   ├── analysis_screen.dart                   # Placeholder for AI shot analysis
│   │   ├── submit_tournament_screen.dart          # Tournament submission flow
│   │   └── admin_moderation_screen.dart           # Moderation UI for submitted tournaments
│   ├── tournament/
│   │   ├── models/
│   │   │   ├── tournament.dart
│   │   │   ├── skill_level.dart
│   │   │   ├── tournament_format.dart
│   │   │   └── tournament_status.dart
│   │   ├── providers/
│   │   │   └── changes_notifier_tournament_provider.dart  # State + ChangeNotifier
│   │   ├── repositories/
│   │   │   ├── tournament_repository.dart         # Abstract
│   │   │   ├── http_tournament_repository.dart    # Real API client (Dio)
│   │   │   └── mock_tournament_repository.dart    # In-memory, used by tests/local dev
│   │   ├── screens/
│   │   │   ├── tournament_list_screen.dart        # Tournament list with search + retry
│   │   │   └── tournament_detail_screen.dart      # Tournament detail + registration
│   │   └── services/
│   │       ├── http_client.dart                   # Abstract HttpClient interface
│   │       └── dio_http_client.dart               # Dio implementation
│   └── widgets/
│       ├── avatar_stack.dart
│       └── empty_state.dart
└── test/                                          # 72 total tests — coverage mirrors lib structure
    ├── caddy/calculator_test.dart
    ├── providers/
    │   ├── app_state_test.dart
    │   └── changes_notifier_tournament_provider_test.dart
    ├── screens/
    │   ├── tournament_detail_screen_test.dart
    │   └── tournament_list_screen_test.dart
    └── tournament/
        ├── models/
        │   ├── enums_test.dart
        │   └── tournament_test.dart
        └── repositories/
            ├── http_tournament_repository_test.dart
            └── mock_tournament_repository_test.dart
```

## Design Framework

Emil Kowalski design skill is loaded (`~/.hermes/skills/emil-kowalski-design-skills/`):
8 modules covering animation vocabulary, apple design principles, emil design engineering,
finding animation opportunities, improving animations, picking UI libraries, prototyping,
and reviewing animations. Reference design in `docs/backlog/VISUAL_DIRECTION.md` (design
reference only, not implemented in v1).

## Notes on Networking

- `HttpTournamentRepository` uses Dio with default baseUrl `api-local.kbvalbury.com:9100`
  (**HTTP only**).
- Android manifest enables cleartext (`android:usesCleartextTraffic="true"` on the
  `<application>` tag in `android/app/src/main/AndroidManifest.xml`).
- No iOS project exists yet; adding one will require an `NSAppTransportSecurity` exception
  or migration to HTTPS.
- Production should use TLS. Current cleartext config is dev-only.

## Design References (Not Implemented in v1)

These docs live in `docs/backlog/` and describe deferred features. They are reference only:

- `docs/backlog/AI_INTEGRATION.md` — AI scoring/moderation architecture
- `docs/backlog/VISUAL_DIRECTION.md` — color palette, typography, components, motion

## Next Steps (Roadmap)

Implement remaining Phase 5+ features from PRD:

- Tournament detail view with registration flow (UI scaffolded; flow pending)
- AI-powered shot analysis (integrate with cloud vision/AI service)
- User authentication & profile persistence (deferred — no Hive/SQLite in v1)
- Offline-first capability with sync queue
- Push notifications for upcoming tournaments

## Running

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
flutter pub get
flutter run # or flutter run -d <device>
flutter test # 72/72 pass
```

## Test Count Drift Guard

This repo enforces a test-count contract between code and docs. If `flutter test` reports a
different pass count than the `<!-- test-count: N -->` marker in this file (or `CHANGELOG.md`),
CI will fail and the pre-commit hook will block the commit.

- CI: `.github/workflows/test-count-guard.yml`
- Hook installer: `bash tool/setup-pre-commit.sh`
- Script: `tool/verify_test_count.sh`