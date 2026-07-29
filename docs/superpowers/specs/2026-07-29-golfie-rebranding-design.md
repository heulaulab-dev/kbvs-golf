# Golfie Rebranding + DESIGN.md Token System

**Date:** 2026-07-29
**Status:** Approved
**Scope:** Surface + token system only (no new screens, no new components)

## Context

The app is currently `kbvs_golf` — a Flutter app for Jakarta golf tournament discovery using
a default Material 3 theme with `primarySwatch: Colors.green`. The design language has
been defined in `docs/DESIGN.md` ("Golfie — Style Reference") but not applied. The
intentional brand is **Golfie** — a warm, scrapbook-aesthetic, mobile-first golf companion.

This spec rebrands the app to Golfie and applies the DESIGN.md token system as a real
Flutter `ThemeData` so all existing screens inherit the new look without per-screen edits.

**Out of scope (v1):** new screens, reusable widget components (pill button, collage card),
dark mode, scrapbook/collage illustrations, font asset bundling, per-screen typography polish.

## Goals

1. The app's user-facing identity is **Golfie** everywhere a user sees it.
2. The DESIGN.md token palette (Canvas, Ink, Mint, Marigold, Periwinkle, etc.) is the
   source of truth, exposed through one Dart module.
3. Existing screens re-skin via `ThemeData` inheritance — no per-screen refactoring.
4. The Android package namespace and Dart package name are `golfie`/`com.golfie.app`.
5. All 106 existing tests still pass; the test-count marker stays accurate.

## Non-Goals

- No new screens, no new widgets, no new routes.
- No dark mode (DESIGN.md is light-only).
- No motion / animation work (no `AnimatedSwitcher`, no spring physics, no haptics).
- No font `.ttf` bundling — `google_fonts` runtime fetch is acceptable for v1.
- No Emil design polish beyond the design-engineering token module (Design-by-tokens IS the
  Emil-aligned exercise; animation/feedback work is v2).

## Approach: Token Module + ThemeData

A new `lib/core/theme/` module exposes the design tokens as Dart constants. A single
`GolfieTheme.light()` builder returns a `ThemeData` that wires those tokens into Material 3
slots (`ColorScheme`, `TextTheme`, `CardTheme`, `ElevatedButtonTheme`, `AppBarTheme`).
`main.dart` consumes this builder. Screens inherit via Flutter's normal theme cascade.

Rejected alternatives:
- **Inline theme in `main.dart`** (Option A) — magic numbers in one file, no abstraction.
- **`ColorScheme.fromSeed(Mint)`** (Option C) — Material conformance but loses the warm
  Canvas bg + Ink CTA that define Golfie. Pays complexity for a benefit we don't need
  (dark mode) until v2.

## Token Module Layout

### `lib/core/theme/golfie_colors.dart`

`GolfieColors` class with named constants. 1:1 mapping to DESIGN.md color tokens.

```dart
class GolfieColors {
  static const canvas = Color(0xFFFFF3E7);
  static const ink = Color(0xFF030302);
  static const white = Color(0xFFFFFFFF);
  static const linen = Color(0xFFF7F7F7);
  static const cloud = Color(0xFFEFEFEF);
  static const ash = Color(0xFFE1E1E1);
  static const stone = Color(0xFFBEBBBA);
  static const graphite = Color(0xFF41413F);
  static const mint = Color(0xFF9BD8A9);
  static const marigold = Color(0xFFFDE99B);
  static const periwinkle = Color(0xFFB8CAF5);
  static const sky = Color(0xFF9ED4EF);
  static const papaya = Color(0xFFFF4500);
  static const azure = Color(0xFF0087FF);

  static const skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF9ED4EF), Color(0xFFD1EEF9)],
  );
}
```

### `lib/core/theme/golfie_typography.dart`

`GolfieTypography.textTheme` returns a `TextTheme` built with `google_fonts`:
- Headline family (display, heading-lg, heading, heading-sm): `GoogleFonts.loraTextTheme`
  base, weight 400, applied sizes from DESIGN.md type scale.
- Body family (subheading, body, body-sm, caption): `GoogleFonts.interTextTheme` base,
  weights 400/500/700 mapped to scale.

Mapping table per token (size, line-height, letter-spacing) — drawn directly from
`docs/DESIGN.md` "Type Scale" section:

| Token         | Size | LH  | Tracking |
|---------------|------|-----|----------|
| caption       | 12px | 1.5 | 0.12px   |
| body-sm       | 14px | 1.5 | 0.14px   |
| body          | 16px | 1.5 | -0.24px  |
| subheading    | 24px | 1.4 | -0.72px  |
| heading-sm    | 36px | 1.2 | -0.72px  |
| heading       | 46px | 1.1 | -1.38px  |
| heading-lg    | 56px | 1.05| -2.24px  |
| display       | 66px | 1.1 | -2.64px  |

Fallback chain (DESIGN.md specifies): `Lora → ui-serif, Georgia, Cambria, 'Times New Roman', Times, serif`.
Same for `Inter → ui-sans-serif, system-ui, ...`. `google_fonts` handles this fallback when
runtime fetching is unavailable.

### `lib/core/theme/golfie_spacing.dart`

`GolfieSpacing` constants matching DESIGN.md spacing scale (4/8/12/16/20/24/32/40/48/60/80/120/180/188).

### `lib/core/theme/golfie_radii.dart`

`GolfieRadii` constants: md=4, lg=8, xl=14, 2xl=20, 3xl=24, 3xl-2=32 (named radii
cards=16-24, pills=9999, inputs=14, buttons=14).

### `lib/core/theme/golfie_shadows.dart`

`GolfieShadows` class with named static `BoxShadow` lists (xl, sm, md, md-2, subtle, md-3).
Values drawn directly from DESIGN.md "Shadows" + "Elevation" sections.

### `lib/core/theme/golfie_theme.dart`

`GolfieTheme.light()` returns a `ThemeData`:

```dart
ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: GolfieColors.canvas,
  colorScheme: const ColorScheme.light(
    primary: GolfieColors.ink,
    onPrimary: GolfieColors.white,
    secondary: GolfieColors.graphite,
    onSecondary: GolfieColors.white,
    surface: GolfieColors.white,
    onSurface: GolfieColors.ink,
    error: GolfieColors.papaya,
    onError: GolfieColors.white,
  ),
  textTheme: GolfieTypography.textTheme,
  cardTheme: CardThemeData(
    elevation: 0,
    color: GolfieColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(GolfieRadii.xl)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: GolfieColors.ink,
      foregroundColor: GolfieColors.white,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: -0.24,
      ),
    ),
  ),
  appBarTheme: const AppBarThemeData(
    backgroundColor: GolfieColors.canvas,
    foregroundColor: GolfieColors.ink,
    elevation: 0,
    centerTitle: false,
  ),
  dividerColor: GolfieColors.ash,
)
```

## File Changes

### New files
- `lib/core/theme/golfie_colors.dart`
- `lib/core/theme/golfie_typography.dart`
- `lib/core/theme/golfie_spacing.dart`
- `lib/core/theme/golfie_radii.dart`
- `lib/core/theme/golfie_shadows.dart`
- `lib/core/theme/golfie_theme.dart`

### Modified files
- `pubspec.yaml` — name `golfie`, description updated, add `google_fonts: ^6.2.1`.
- `lib/main.dart` — `runApp(const GolfieApp())`, import `GolfieTheme`, drop inline `ThemeData`.
- `lib/screens/home_screen.dart` — AppBar `'Golfie'`, footer `'Golfie v1.0'`.
- `android/app/build.gradle.kts` — `namespace = "com.golfie.app"`, `applicationId = "com.golfie.app"`.
- `android/app/src/main/AndroidManifest.xml` — `android:label="Golfie"`.
- `android/app/src/main/kotlin/com/kbvs/kbvs_golf/MainActivity.kt` → move to `kotlin/com/golfie/app/MainActivity.kt`, update `package` line.
- All `lib/**/*.dart` and `test/**/*.dart` — `package:kbvs_golf/` → `package:golfie/` (sed-able).
- `README.md`, `CHANGELOG.md` — title + headings.
- `prd/PRD_Stakeholder.md`, `prd/PRD_Engr.md` — "KBVS Golf = ..." → "Golfie = ...".

### Untouched
- `lib/berita/`, `lib/caddy/`, `lib/tournament/`, `lib/providers/`, `lib/services/`,
  `lib/utils/`, `lib/mocks/`, `lib/widgets/` — content unchanged. Theme inheritance re-skins them.
- `docs/DESIGN.md` — already Golfie. No change.
- `docs/UI_STACK.md`, `docs/RESEARCH.md` — reference. No change.
- `golfie-api/` sibling project — already named correctly.

## Behavior

- Existing screens pick up Golfie styling via `MaterialApp.theme` cascade. No widget tree edits.
- `google_fonts` fetches Inter/Lora on first run. If offline, falls back to system serif/sans
  (DESIGN.md-specified fallback chain). For dev/test environments that need offline-first,
  `.ttf` bundling is a v2 follow-up.
- `flutter test` runs after rename; expected mechanical breakages are import lines and text
  matchers like `find.text('KBVS Golf')`. Fix in place. Keep test-count marker honest.

## Emil Kowalski Design Skills (review lens)

This rebrand is limited to tokens + ThemeData, so Emil's relevance is bounded:

- **design-engineering** — the token module IS the exercise: one source of truth, consumed
  by `ThemeData`, never duplicated. ✓
- **apple-design-principles** — `ElevatedButton` style uses `StadiumBorder` (pill shape),
  matching DESIGN.md's "Primary Pill Button" guidance. No aggressive haptics wired (v2). ✓
- **animation-vocabulary** — no animations introduced. Default Material 3 transitions apply.
  Audit deferred to v2. ✓
- **picking-ui-libraries** — `google_fonts` chosen; alternatives (self-host `.ttf`, system
  default) considered and rejected, recorded in this spec. ✓
- **prototyping / finding-animation-opportunities / improving-animations / reviewing-animations** —
  not invoked (no animations in scope).

## Error Handling

No new error paths. Verification:
- `flutter analyze` — clean.
- `flutter test` — 106/106 pass (or count updated + marker reconciled).
- `flutter build apk --debug` — succeeds (proves Android package rename clean).
- `flutter run -d <device>` — manual smoke (Canvas bg, Ink text, Inter/Lora fonts visible).

## Risk Callouts

1. **Android package rename requires uninstall + reinstall** on every device that has the
   old `com.kbvs.kbvs_golf` installed. Plan check: no test fixtures reference the old
   namespace.
2. **Test-count drift** — if a widget test becomes obsolete post-rebrand (e.g., a finder
   matches twice), resolution = remove or split the test. Count stays accurate.
3. **`google_fonts` runtime fetch** — dev first-run needs network. Acceptable for v1.
4. **Existing screens with hardcoded colors** — likely none (most use defaults). If found
   during implementation, surface as v2 follow-up rather than scope-creep this spec.

## Implementation Phases (preview)

1. **Phase 1 — Token module** (~30 min): create `lib/core/theme/` files, `flutter analyze` clean.
2. **Phase 2 — Wire ThemeData** (~5 min): replace inline theme in `main.dart`, `flutter run` smoke.
3. **Phase 3 — Rename Dart package** (~15 min): `pubspec.yaml` + project-wide sed + `flutter pub get`.
4. **Phase 4 — Rename Android package** (~15 min): `build.gradle.kts` + Kotlin move + `flutter build apk`.
5. **Phase 5 — User-facing strings** (~5 min): home screen, manifest, pubspec desc, README, CHANGELOG, PRDs.
6. **Phase 6 — Test pass + marker reconciliation** (~15 min): `flutter test`, fix breakages, update marker.
7. **Phase 7 — Git hygiene** (~5 min): conventional commit, update memory.

Total estimate: ~90 min.
