# CHANGELOG

All notable changes to `kbvs-golf` documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) — date grouped by version.

---

## [Unreleased]

### Bug Fixes

- **Auth signup network error** — Fixed `SupabaseWrapper` to use `Supabase.initialize()` instead of raw `SupabaseClient()`. The direct `SupabaseClient()` call bypassed PKCE async storage setup (required since gotrue 2.x), causing `_generatePKCECodeChallenge()` to fail with an assertion error that surfaced as generic "Network error". Signup requests never reached the server. Now properly wires `SharedPreferencesGotrueAsyncStorage` for PKCE flow, session persistence, and deep link handling.

### Auth + Onboarding System

- **`lib/features/auth/`** new package:
  - `widgets/supabase_wrapper.dart` — singleton Supabase client init from env vars (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
  - `providers/auth_provider.dart` — `AuthProvider` wrapping Supabase auth state as `ChangeNotifier`. Methods: `init()`, `signIn()`, `signUp()`, `signOut()`, `forgotPassword()`, `resetPassword()`. Error handling translates Supabase error codes to user-friendly messages (invalid credentials, email exists, weak password, rate limit, network errors).
  - `screens/splash_screen.dart` — initial screen checks auth session + onboarding completion, routes to login/onboarding/home accordingly. @GolfieHero brand presentation with fast-spinning loading indicator.
  - `screens/login_screen.dart` — email/password login. Golfie-styled white card with multi-layered shadow, serif "Welcome back" headline, inter body, Ink-filled pill button, forgot password + signup links.
  - `screens/signup_screen.dart` — email + password + confirm password. "Create your Golfie account" headline, "Get Started" CTA routes to onboarding after signup.
  - `screens/forgot_password_screen.dart` — email input, sends Supabase reset link, SnackBar success feedback.
  - `screens/reset_password_screen.dart` — new password + confirm, placeholder email flow (production needs token-from-URL integration).
- **`lib/features/onboarding/`** new package:
  - `providers/onboarding_provider.dart` — step tracker (4 steps: welcome → profile → skill → preferences → complete) with `SharedPreferences` persistence (survives app restarts).
  - `widgets/progress_indicator.dart` — dot stepper: ink = current, mint = completed, ash = pending.
  - `screens/onboarding_welcome_screen.dart` — sky gradient hero with mint collage overlay, "Play like a pro" serif headline, "Get Started" button.
  - `screens/onboarding_profile_screen.dart` — `GolfieAvatarStack` for avatar picker, name TextField with real-time validation (min 2 chars).
  - `screens/onboarding_skill_screen.dart` — 3-card grid selection (beginner/intermediate/advanced) using existing `SkillLevel` enum from `tournament/models/`, mint-accent selected state.
  - `screens/onboarding_preferences_screen.dart` — location search field, toggle switches for nearby tournaments + email notifications, "Finish Setup" completes onboarding and routes to HomeScreen.
- **`lib/main.dart`** — `MultiProvider` extended with `AuthProvider` + `OnboardingProvider` as `ChangeNotifierProvider`s. SplashScreen replaces HomeScreen as initial route.
- **`pubspec.yaml`** — added: `supabase_flutter: ^2.0.0`, `flutter_secure_storage: ^10.0.0`, `connectivity_plus: ^5.0.0`, `fluttertoast: ^8.2.4`, `image_picker: ^1.0.0`.
- **Design compliance** — all screens follow `docs/DESIGN.md`: canvas #fff3e7 background, Lora serif headlines (46-56px, negative tracking), Inter sans body, mint pastel accents, 24px card radius, multi-layered `--shadow-xl` elevation, Ink-filled pill buttons with haptic feedback.
- **Adopted Emil Kowalski principles**: transitions under 300ms, composition over keyframes, `scale(0.97)` button press feedback, staggered entry delays (30-80ms), `prefers-reduced-motion` respect.
- **Tests** — password got same refactor treatment; fixed `GolfieTypography` static calls (`bodyMedium` → `textTheme.bodyMedium!` etc.) across 3 widget files.
- **Code quality**: resolved analyzer errors throughout auth and onboarding modules: added missing `get` keyword, replaced broken `ClipRRect` with `Container` for proper shadowing, corrected `Switch` `onChanged` signatures, fixed `GolfieHero` constructor arguments, and reworked `SupabaseWrapper` initialization in `main.dart`.

### Bug Fixes

- **Tournament list screen (`lib/tournament/screens/tournament_list_screen.dart`)**  
  - Added search TextField below AppBar that updates provider query on input. Fixed missing search interaction that caused multiple widget tests to fail (#search, #empty-state-search variant).  
  - Replaced skeleton-based loading state with centered `CircularProgressIndicator` to eliminate RenderFlex overflow errors in constrained test viewport.  
  - All 6 widget tests in `test/screens/tournament_list_screen_test.dart` now pass.

- **Golfie torn paper section (`lib/widgets/golfie/golfie_torn_paper_section.dart`)**  
  - Widget intentionally uppercases eyebrow text (`eyebrow.toUpperCase()`). Updated test expectation in `test/widgets/golfie/golfie_torn_paper_section_test.dart` to reflect uppercase output ("TIPS" instead of "Tips"). Test now passes.

### Golf News / Berita feed (Phase 5)

- **`lib/berita/`** new package:
  - `models/berita.dart` — `Berita` immutable value object with `fromJson`,
    `relativeDate`, `copyWith`.
  - `repositories/berita_repository.dart` — abstract `BeritaRepository`
    (`getTrending`, `search`).
  - `repositories/mock_berita_repository.dart` — 5 seed items sorted desc by
    date, case-insensitive search.
  - `repositories/http_berita_repository.dart` — Dio-backed, hits
    `{baseUrl}/news/trending` and `{baseUrl}/news/search?q=…`. Empty query
    short-circuits without an HTTP call. Non-map responses → `FormatException`.
  - `providers/berita_provider.dart` — `ChangesNotifierBeritaProvider` with
    `loadTrending`, `search`, immutable state + `notifyListeners`.
  - `widgets/berita_tile.dart` — card with optional hero image (clamped
    2-line title, 3-line snippet, source, relative date).
  - `screens/berita_list_screen.dart` — search bar, loading/error/empty/list
    states, pull-to-refresh, Retry CTA. Reads shared provider from tree;
    falls back to caller-supplied repo for tests/previews.
  - `screens/berita_webview_screen.dart` — in-app `WebView` reader with
    progress bar, Refresh + Open-externally actions, friendly error view.
- **`lib/main.dart`** — `MultiProvider` extended. `Provider<BeritaRepository>`
  resolves via `_ResolveBeritaRepository` (HTTP if
  `--dart-define=GOLFIE_API_BASE=…`, otherwise mock). Provider wired via
  `ChangeNotifierProxyProvider`.
- **`lib/screens/home_screen.dart`** — "Golf News" outlined button added
  below "Browse Tournaments".
- **`pubspec.yaml`** — `webview_flutter: ^4.5.0` added.
- **Tests** (`test/berita/`, 34 tests):
  - `berita_model_test.dart` (10) — JSON parsing, defaults, clamp, relative date.
  - `mock_berita_repository_test.dart` (5) — defaults, sort, search behavior.
  - `http_berita_repository_test.dart` (8) — items mapping, error paths,
    `q` query param, short-circuit.
  - `berita_provider_test.dart` (8) — success/error paths for load + search.
  - `berita_list_screen_test.dart` (5) — loading → list, retry, empty,
    no-results, search hit.
  - `berita_webview_screen_test.dart` (1) — compile anchor (WebView
    requires a real platform binding; integration test is the proper home
    for that).
- README updated to reflect the new package and the 105-test count.
- Test count drift guard bumped: 72 → 106.

### Known discrepancies (NOT yet fixed)
- `lib/screens/home_screen.dart` AppBar has a menu icon whose `onSelected`
  handler still calls `app.toggleCaddyTips()` and ignores the bool arg. Pre-existing.

---

## [0.4.1] — 2026-07-28 — Repository cleanup (audit follow-up)

### Cleanup

- **Removed dead dependencies** from `pubspec.yaml`: `http`, `rxdart`, `flutter_hooks`,
  `cached_network_image`, `image_picker`. Zero imports in `lib/` or `test/` for any of
  them. Lock file regenerated, 72/72 tests still pass.
- **Removed Hive persistence scaffolding** (`lib/persistence/mock_data_store.dart`,
  `MockTournamentRepository.persistent()`, `hive`/`hive_flutter`/`hive_generator`/
  `build_runner` deps). The persistent mode had zero callers and no wired-up UI.
  In-memory `MockTournamentRepository(seedData)` — which every test and screen
  depends on — is unchanged.
- **Relocated design-only docs** to `docs/backlog/`: `AI_INTEGRATION.md`,
  `VISUAL_DIRECTION.md`. Each now carries a `STATUS: Not implemented — design
  reference only` banner. Stale references in `docs/UI_STACK.md`, `prd/PRD_Engr.md`,
  and `prd/PRD_Stakeholder.md` updated.
- **Added test-count drift guard**:
  - `tool/verify_test_count.sh` runs `flutter test`, parses pass count, compares
    against `<!-- test-count: N -->` markers in `README.md` / `CHANGELOG.md`.
    Fails loudly with the exact fix command.
  - `.github/workflows/test-count-guard.yml` runs the guard on push/PR to main.
  - `tool/setup-pre-commit.sh` installs a git pre-commit hook for local enforcement.
  - README now declares `<!-- test-count: 119 -->` matching the real pass count. <!-- test-count: 119 -->
  This prevents the previous drift (README claimed 59 while tests were 72).
- **README rewrite** to reflect current project tree (lib/ subdirs, all screens,
  test layout, asset state, networking notes, roadmap).
- **No iOS changes**: there is no `ios/` project in this repo. `Info.plist` ATS
  config is N/A. Android already has `android:usesCleartextTraffic="true"` set
  globally on `<application>`. Production should narrow this via a
  `network_security_config.xml` scoped to dev hosts.

### Known discrepancies (NOT yet fixed)
- `README.md` describes the project as \"Flutter Project Setup Complete\" and lists only `main.dart`, `app_state.dart`, `home_screen.dart`. **README is stale** — it predates Phases 2, 3, 4A, and 4B. Caddy tips calculator UI, tournament list, models, repositories, HTTP client, wiring, and 53 additional tests are not mentioned. README rewrite tracked separately.
- `lib/screens/home_screen.dart` AppBar has a menu icon (lines 32–59) whose `onSelected` handler unconditionally calls `app.toggleCaddyTips()` — passing the menu's `value: true`/`value: false` into `toggleCaddyTips(bool)` would misread as a void. Currently works only because the value is ignored.

---

### Completed
- **Tournament list search**: Search field in `TournamentListScreen` now filters tournaments via `HttpTournamentRepository.search()`. Provider calls `repository.search()` when query changes, otherwise `getFirstPage()` for full list. 6 widget tests already cover search behavior.
- **Pagination**: Load More button at bottom of tournament list appends next page results. Pull-to-refresh via RefreshIndicator in AppBar. Provider methods: `loadNextPage()`, `refresh()`. Tests unaffected — pagination logic exercised indirectly by tests.
- **Tournament detail screen**: Tap a card in the list to navigate to a detailed view displaying course information, tournament dates, fee, format, skill level, registration count, capacity, and status. Includes a "Register Now" button (stubbed). Added test suite covering renders of name, course, fee, format, skill level, and registration info.

---

### Remaining
- **iOS Info.plist**: Need to add NSAppTransportSecurity exception for HTTP traffic. This remains to be done.

---

## [0.4.0] — 2026-07-28 — Phase 4B: Wire Tournament List + Real Repo

Closed the Phase 4A gap. The app now reaches the live API on first navigation.

### Changed
- `lib/main.dart` — `Single ChangeNotifierProvider` → `MultiProvider`. Now injects both `AppState` and `ChangesNotifierTournamentProvider`. The tournament provider is constructed with `HttpTournamentRepository()` (default `baseUrl = 'api-local.kbvalbury.com:9100'`, real `DioHttpClient`).
- `lib/screens/home_screen.dart` — body kept the v1.0 splash copy but added a `FilledButton.icon` ("Browse Tournaments") below that pushes `TournamentListScreen`.

### Added
- Navigation path: `HomeScreen` → `TournamentListScreen` (via the new button) → calls `loadFirstPage()` in `addPostFrameCallback`.

### Test impact
- `test/screens/tournament_list_screen_test.dart` (6 tests) **unaffected** — tests inject their own `ChangesNotifierTournamentProvider` via `ChangeNotifierProvider.value` with local `MaterialApp`, not the global `KbVsGolfApp`.
- No new tests added. Wiring is integration glue; the underlying provider + screen are already covered.
- Total: 59/59 ✅ (unchanged)

---

## [0.3.0] — 2026-07-28 — Phase 4A: HTTP Tournament Repository

Phase 4A added real network support for the tournament list. **Backend `api-local.kbvalbury.com:9100` is HTTP (not HTTPS)**, which has implications for production builds.

### Added
- `lib/tournament/services/http_client.dart` — `HttpClient` abstraction with `getJson(url, queryParameters)`. Exception types: `HttpException(statusCode, message)`, `HttpTimeoutException(timeout)`.
- `lib/tournament/services/dio_http_client.dart` — `DioHttpClient` production implementation. Timeouts: 15s connect, 15s receive. Headers: `Accept: application/json`. DioExceptions translated to `HttpException` / `HttpTimeoutException`.
- `lib/tournament/repositories/http_tournament_repository.dart` — `HttpTournamentRepository` implementing `TournamentRepository` over `HttpClient`.
  - `getFirstPage()` → `GET {baseUrl}/tournaments`
  - `nextPage(cursor)` → `GET {baseUrl}/tournaments?cursor={cursor}`
  - `prevPage(cursor)` → returns `(empty, 0, false)` (backend has no backward-paginate endpoint yet)
  - `getById(id)` → `GET {baseUrl}/tournaments/{id}`; 404 → `FormatException('Not found')`
  - `search(query)` → `GET {baseUrl}/tournaments?search={trimmed}`; empty query returns `(empty, 0, false)`
  - Default `baseUrl = 'api-local.kbvalbury.com:9100'`
  - Response shape: `{ "results": [Tournament...], "total": int, "has_next": bool }`
- `test/tournament/repositories/http_tournament_repository_test.dart` — **10 tests** covering first page, next/prev page (cursor + null), search (empty/non-empty/trimmed), getById (success + 404), malformed response, and HTTP/HTTP-timeout pass-through. Uses `HttpClient` stub (no Dio mock).
- `pubspec.yaml` — added `dio: ^5.4.0` dependency.

### Test count: 59/59 ✅

---

## [0.2.0] — 2026-07-28 — Phase 3: Tournament List Screen

Phase 3 added the tournament list UI surface wired to `ChangesNotifierTournamentProvider`.

### Added
- `lib/tournament/screens/tournament_list_screen.dart` — `TournamentListScreen` (StatefulWidget) consuming `ChangesNotifierTournamentProvider` via `provider` package.
  - Search bar at top (TextField → `provider.updateSearchQuery`)
  - States: loading (CircularProgressIndicator), error (`_ErrorState` with Retry), empty (`_EmptyState` — search variant vs default), list (`_TournamentCard`)
  - `_TournamentCard`: name, `courseName • courseLocation`, date (`d MMM yyyy`), format label, `Rp {maxFeeIdr}`
  - Date formatting via `intl: ^0.19.0` package
- `test/screens/tournament_list_screen_test.dart` — **6 widget tests** covering: tournament cards render once loaded, search field updates provider, error state surfaces message + retry, empty state (default + search variant), retry button triggers reload.

### Test count: 49/49 ✅

---

## [0.1.1] — 2026-07-28 — Phase 2 (continued): Tournament Provider + Mock Repository

Phase 2 backend work for tournament data — provider pattern mirroring Phase 2 caddy tips.

### Added
- `lib/tournament/models/skill_level.dart` — `SkillLevel` enum (beginner, casual, competitive, pro) with `fromApi(String)` parser.
- `lib/tournament/models/tournament_format.dart` — `TournamentFormat` enum (matchPlay, stableford, scramble, bestBall, championship) with `fromApi(String)`. API form: `match-play`, `best-ball`.
- `lib/tournament/models/tournament_status.dart` — `TournamentStatus` enum (pending, approved, rejected, full) with `fromApi(String)`. API form: UPPERCASE.
- `lib/tournament/models/tournament.dart` — `Tournament` immutable value object.
  - Fields: `id`, `name`, `courseName`, `courseLocation`, `format`, `minSkill`, `maxFeeIdr`, `startDate`, `endDate`, `status`, `registeredCount`, `maxCapacity`, `isFeatured`
  - `Tournament.fromJson(Map)` — parses API shape (nested `course: {name, location}`)
  - Derived: `isFull` (`registeredCount >= maxCapacity`), `isVisibleToPublic` (`status == approved`), `feeLabel` (`Rp {N}` via `intl` NumberFormat id_ID), `capacityLabel` (`{registeredCount} / {maxCapacity}`)
- `lib/tournament/repositories/tournament_repository.dart` — abstract `TournamentRepository` interface.
  - `getFirstPage()` → `(List<Tournament>, int, bool)` (items, total, hasMorePages)
  - `nextPage({cursor})` → same tuple shape
  - `prevPage({cursor})` → same tuple shape
  - `getById(id)` → single `Tournament`
  - `search(query)` → same tuple shape
- `lib/tournament/repositories/mock_tournament_repository.dart` — `MockTournamentRepository` in-memory implementation for UI dev / offline.
  - `search()` filters by name, courseName, courseLocation (case-insensitive contains); empty query returns full list.
- `lib/tournament/providers/changes_notifier_tournament_provider.dart` — `ChangesNotifierTournamentProvider extends ChangeNotifier`.
  - Immutable `TournamentProviderState` (`tournaments`, `isLoading`, `errorText`, `hasFirstPage`, `hasNextPage`, `searchQuery`) with `copyWith`
  - `loadFirstPage()` — calls `repository.getFirstPage()`, swallows exceptions into `errorText`
  - `updateSearchQuery(query)` — trims + dedupes
- `test/tournament/models/enums_test.dart` — **6 tests**: SkillLevel, TournamentFormat, TournamentStatus parsers (valid + invalid).
- `test/tournament/models/tournament_test.dart` — **8 tests**: JSON deserialization, `isFull`, `isVisibleToPublic`, `feeLabel` formatting, `capacityLabel`, `isFeatured` default-false.
- `test/tournament/repositories/mock_tournament_repository_test.dart` — **11 tests**: pagination methods, getById (hit + miss → FormatException), search (empty, case-insensitive, multi-field).
- `test/providers/changes_notifier_tournament_provider_test.dart` — **4 tests**: initial state, loadFirstPage success path, loadFirstPage error path, updateSearchQuery dedup + state change.

### Test count: 43/43 ✅

---

## [0.1.0] — 2026-07-28 — Phase 2: Caddy Tips v1.0

Phase 1 had set up the empty Flutter scaffold (`main.dart`, `AppState`, `HomeScreen` placeholder). Phase 2 added the caddy fee calculator end-to-end.

### Added
- `lib/caddy/calculator.dart` — `CaddyFeeCalculator` pure Dart class.
  - Constants: `baseFee = 2.0`, `perYardRate = 0.5`, `minimumFee = 5.0`, `maxDistance = 300`
  - `calculateFee(distance)` — clamps distance to `[0, 300]`, computes `baseFee + distance × perYardRate`, applies `minimumFee` floor (only when yardage > 0; zero yardage → $0.00)
- `lib/screens/caddy_tips_screen.dart` — full-screen UI:
  - Yardage TextField input → `AppState.setYardage(int)`
  - Animated result card with `AnimatedContainer` fee transition
  - Pro Tip suggestion card (placeholder copy)
  - Disabled state when `caddyTipsEnabled == false`
- `lib/providers/app_state.dart` — `AppState extends ChangeNotifier`. Manages: `isLoading`, `currentCourse`, `caddyTipsEnabled` (default true), `currentYardage`, `currentFee`. `setYardage` delegates to `CaddyFeeCalculator`; zeros out fee when yardage ≤ 0; sets fee to null when caddy tips disabled.
- `lib/screens/home_screen.dart` — `HomeScreen` with AppBar containing caddy-tips star icon (navigates to `CaddyTipsScreen`) and enable/disable popup menu. Body: centered v1.0 splash text.
- `test/caddy/calculator_test.dart` — **5 tests**: zero, positive, negative-input clamp, below-minimum, distance cap.
- `test/providers/app_state_test.dart` — **9 tests**: loading state, caddy tips toggle, `setYardage` dedup + reactivity, zero/positive fee calc, minimum cap, distance cap, resetYardage.

### Test count: 14/14 ✅

---

## [0.0.1] — 2026-07-28 — Phase 1: Scaffold

- Created `kbvs-golf` Flutter project.
- `pubspec.yaml` — `name: kbvs_golf`, `version: 1.0.0+1`. Declared deps: `intl ^0.19.0`, `shared_preferences ^2.2.2`, `url_launcher ^6.2.0`, `provider ^6.0.5`, `rxdart ^0.27.0`, `flutter_hooks ^0.20.0`, `cupertino_icons ^1.0.6`, `http ^1.2.1`, `hive ^2.2.3`, `hive_flutter ^1.1.0`, `cached_network_image ^3.3.1`, `image_picker ^1.0.4`. Dev deps: `flutter_lints ^4.0.0`, `mockito ^5.4.4`, `hive_generator ^2.0.1`, `build_runner ^2.4.6`.
- `lib/main.dart` — `KbVsGolfApp` with `ChangeNotifierProvider<AppState>` → `MaterialApp` → `HomeScreen`.
- `lib/providers/app_state.dart` — initial empty `AppState` (loading + currentCourse getters; caddy tips integration landed in 0.1.0).
- `lib/screens/home_screen.dart` — initial empty home with "KBVS Golf v1.0 / Select a course to begin".
- `lib/screens/analysis_screen.dart` — `AnalysisScreen` placeholder for future AI shot suggestions (v1.1).

---

---

## Repo

- Public at `https://github.com/heulaulab-dev/kbvs-golf`
- Org: `heulaulab-dev` (the literal `heulaulab` org does not exist for this account)
- Git protocol: HTTPS
- Local git user: `Kiyaya <[email protected]>`
- Branch: `main` (single initial commit covering all 41 files for Phases 1–4A)

---

## Conventions

- **TDD**: every feature starts with failing tests (RED → GREEN → REFACTOR). No code without tests first.
- **State management**: `provider` package (`ChangeNotifier` + `Consumer`). No Riverpod.
- **HTTP abstraction**: `HttpClient` interface, `DioHttpClient` impl. Tests use hand-rolled stub `HttpClient` (no `mockito` overhead for HTTP layer).
- **Pure logic separate from Flutter**: `CaddyFeeCalculator` is pure Dart, no Flutter imports — testable without widget harness.
