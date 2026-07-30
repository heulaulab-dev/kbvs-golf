# Golfie Rebranding + DESIGN.md Token System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebrand the Flutter app from `kbvs_golf` to `Golfie` and apply the DESIGN.md token system as a real `ThemeData`, so every existing screen inherits the warm Canvas / Ink palette and Inter/Lora typography without per-screen edits.

**Architecture:** New `lib/core/theme/` module exposes color / typography / spacing / radius / shadow constants derived 1:1 from `docs/DESIGN.md`. A single `GolfieTheme.light()` builder wires those tokens into Material 3 `ThemeData`. `main.dart` consumes the builder; existing screens re-skin via theme inheritance. Dart package renames from `kbvs_golf` → `golfie`; Android namespace renames from `com.kbvs.kbvs_golf` → `com.golfie.app`.

**Tech Stack:** Flutter 3.44+, Material 3, `google_fonts: ^6.2.1` (Inter + Lora), Provider (unchanged), `tool/verify_test_count.sh` for test-marker drift detection.

**Spec:** `docs/superpowers/specs/2026-07-29-golfie-rebranding-design.md`

---

## File Structure

### New files
- `lib/core/theme/golfie_colors.dart` — color constants
- `lib/core/theme/golfie_typography.dart` — TextTheme via google_fonts
- `lib/core/theme/golfie_spacing.dart` — spacing scale
- `lib/core/theme/golfie_radii.dart` — border radius scale
- `lib/core/theme/golfie_shadows.dart` — BoxShadow definitions
- `lib/core/theme/golfie_theme.dart` — ThemeData builder wiring everything

### Modified files
- `pubspec.yaml` — rename + add google_fonts
- `lib/main.dart` — use GolfieTheme
- `lib/screens/home_screen.dart` — AppBar text + footer text
- `android/app/build.gradle.kts` — namespace + applicationId
- `android/app/src/main/AndroidManifest.xml` — `android:label`
- `android/app/src/main/kotlin/com/kbvs/kbvs_golf/MainActivity.kt` → MOVE to `kotlin/com/golfie/app/MainActivity.kt`, update `package`
- 16 dart files (`lib/**/*.dart` + `test/**/*.dart`) — sed `package:kbvs_golf/` → `package:golfie/`
- `README.md` — title + headings + test-count marker
- `CHANGELOG.md` — title + test-count marker
- `prd/PRD_Stakeholder.md` — "KBVS Golf = ..." → "Golfie = ..."
- `prd/PRD_Engr.md` — same

### Deleted files
- `test/widget_test.dart` — stale Flutter counter boilerplate (tests `MyApp`, which doesn't exist in this app)

### Untouched
- All other `lib/**` code, `docs/DESIGN.md`, `docs/UI_STACK.md`, `docs/RESEARCH.md`, `golfie-api/` sibling.

---

## Task 1: Create `golfie_colors.dart`

**Files:**
- Create: `lib/core/theme/golfie_colors.dart`

- [ ] **Step 1: Write `lib/core/theme/golfie_colors.dart`**

```dart
import 'package:flutter/material.dart';

/// Color tokens for the Golfie design system.
///
/// All values are sourced 1:1 from docs/DESIGN.md "Tokens — Colors".
/// Hex literals (no opacity) unless the token itself defines one.
class GolfieColors {
  const GolfieColors._();

  // Surfaces
  static const Color canvas = Color(0xFFFFF3E7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color linen = Color(0xFFF7F7F7);
  static const Color cloud = Color(0xFFEFEFEF);

  // Text + ink
  static const Color ink = Color(0xFF030302);
  static const Color stone = Color(0xFFBEBBBA);
  static const Color graphite = Color(0xFF41413F);

  // Lines + borders
  static const Color ash = Color(0xFFE1E1E1);

  // Brand pastels
  static const Color mint = Color(0xFF9BD8A9);
  static const Color marigold = Color(0xFFFDE99B);
  static const Color periwinkle = Color(0xFFB8CAF5);
  static const Color sky = Color(0xFF9ED4EF);

  // Accents
  static const Color papaya = Color(0xFFFF4500);
  static const Color azure = Color(0xFF0087FF);

  // Sky gradient used for hero textures (DESIGN.md "Tokens — Colors" → Sky)
  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFF9ED4EF), Color(0xFFD1EEF9)],
  );
}
```

- [ ] **Step 2: Verify `flutter analyze` is clean for this file**

Run: `flutter analyze lib/core/theme/golfie_colors.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/golfie_colors.dart
git commit -m "feat(theme): add GolfieColors token module"
```

---

## Task 2: Create `golfie_spacing.dart`

**Files:**
- Create: `lib/core/theme/golfie_spacing.dart`

- [ ] **Step 1: Write `lib/core/theme/golfie_spacing.dart`**

```dart
/// Spacing scale for the Golfie design system.
///
/// Base unit is 4px. Sourced 1:1 from docs/DESIGN.md "Tokens — Spacing & Shapes".
class GolfieSpacing {
  const GolfieSpacing._();

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s60 = 60;
  static const double s80 = 80;
  static const double s120 = 120;
  static const double s180 = 180;
  static const double s188 = 188;
}
```

- [ ] **Step 2: Verify analyze**

Run: `flutter analyze lib/core/theme/golfie_spacing.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/golfie_spacing.dart
git commit -m "feat(theme): add GolfieSpacing token module"
```

---

## Task 3: Create `golfie_radii.dart`

**Files:**
- Create: `lib/core/theme/golfie_radii.dart`

- [ ] **Step 1: Write `lib/core/theme/golfie_radii.dart`**

```dart
/// Border-radius scale for the Golfie design system.
///
/// Sourced 1:1 from docs/DESIGN.md "Tokens — Spacing & Shapes → Border Radius".
class GolfieRadii {
  const GolfieRadii._();

  static const double md = 4;
  static const double lg = 8;
  static const double xl = 14;
  static const double xlPlus = 16; // cards (lower bound)
  static const double xxl = 20;
  static const double xxxl = 24; // cards (upper bound)
  static const double xxxl2 = 32;
  static const double pill = 9999;
}
```

- [ ] **Step 2: Verify analyze**

Run: `flutter analyze lib/core/theme/golfie_radii.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/golfie_radii.dart
git commit -m "feat(theme): add GolfieRadii token module"
```

---

## Task 4: Create `golfie_shadows.dart`

**Files:**
- Create: `lib/core/theme/golfie_shadows.dart`

- [ ] **Step 1: Write `lib/core/theme/golfie_shadows.dart`**

```dart
import 'package:flutter/material.dart';

/// Box-shadow tokens for the Golfie design system.
///
/// Sourced 1:1 from docs/DESIGN.md "Tokens — Spacing & Shapes → Shadows".
class GolfieShadows {
  const GolfieShadows._();

  static const List<BoxShadow> xl = <BoxShadow>[
    BoxShadow(color: Color(0x02000000), offset: Offset(0, 50), blurRadius: 40, spreadRadius: 0),
    BoxShadow(color: Color(0x05000000), offset: Offset(0, 50), blurRadius: 40, spreadRadius: 0),
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 20), blurRadius: 40, spreadRadius: 0),
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 3), blurRadius: 10, spreadRadius: 0),
  ];

  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2),
  ];

  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 12), blurRadius: 12, spreadRadius: 2),
    BoxShadow(color: Color(0x10000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -1),
  ];

  static const List<BoxShadow> md2 = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 16, spreadRadius: 0),
  ];

  static const List<BoxShadow> subtle = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 3, spreadRadius: 0),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 2, spreadRadius: -1),
  ];

  static const List<BoxShadow> md3 = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 12, spreadRadius: 0),
  ];
}
```

- [ ] **Step 2: Verify analyze**

Run: `flutter analyze lib/core/theme/golfie_shadows.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/golfie_shadows.dart
git commit -m "feat(theme): add GolfieShadows token module"
```

---

## Task 5: Create `golfie_typography.dart`

**Files:**
- Create: `lib/core/theme/golfie_typography.dart`
- Modify: `pubspec.yaml` (add `google_fonts` dep)

- [ ] **Step 1: Add `google_fonts` to `pubspec.yaml`**

Open `pubspec.yaml`. Under `dependencies:` (after `cupertino_icons:`), add:

```yaml
  # Typography (Inter + Lora)
  google_fonts: ^6.2.1
```

Final `dependencies:` block looks like:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Core utilities
  intl: ^0.19.0
  shared_preferences: ^2.2.2
  url_launcher: ^6.2.0

  # State management
  provider: ^6.0.5

  # UI & widgets
  cupertino_icons: ^1.0.6
  webview_flutter: ^4.5.0

  # Typography (Inter + Lora)
  google_fonts: ^6.2.1

  # Network & API
  dio: ^5.4.0
```

- [ ] **Step 2: Run `flutter pub get`**

Run: `flutter pub get`
Expected: success, prints `Resolving dependencies...` then `Got dependencies!`. `google_fonts` resolves to a version >= 6.2.1 < 7.0.0.

- [ ] **Step 3: Write `lib/core/theme/golfie_typography.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for the Golfie design system.
///
/// Sourced 1:1 from docs/DESIGN.md "Tokens — Typography → Type Scale".
/// Serif (Lora) for headlines, sans (Inter) for UI/body.
class GolfieTypography {
  const GolfieTypography._();

  /// Sans family for all UI + body text.
  static TextTheme _sansTextTheme() {
    final TextTheme base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: GoogleFonts.lora().fontFamily,
        fontSize: 66,
        height: 1.1,
        letterSpacing: -2.64,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: GoogleFonts.lora().fontFamily,
        fontSize: 56,
        height: 1.05,
        letterSpacing: -2.24,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontFamily: GoogleFonts.lora().fontFamily,
        fontSize: 46,
        height: 1.1,
        letterSpacing: -1.38,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: GoogleFonts.lora().fontFamily,
        fontSize: 36,
        height: 1.2,
        letterSpacing: -0.72,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 24,
        height: 1.4,
        letterSpacing: -0.72,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        height: 1.4,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.24,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 18,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.5,
        letterSpacing: -0.24,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.5,
        letterSpacing: 0.14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.5,
        letterSpacing: 0.12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.24,
      ),
    );
  }

  static final TextTheme textTheme = _sansTextTheme();
}
```

- [ ] **Step 4: Verify analyze**

Run: `flutter analyze lib/core/theme/golfie_typography.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/core/theme/golfie_typography.dart
git commit -m "feat(theme): add GolfieTypography with Inter+Lora via google_fonts"
```

---

## Task 6: Create `golfie_theme.dart`

**Files:**
- Create: `lib/core/theme/golfie_theme.dart`

- [ ] **Step 1: Write `lib/core/theme/golfie_theme.dart`**

```dart
import 'package:flutter/material.dart';

import 'golfie_colors.dart';
import 'golfie_radii.dart';
import 'golfie_typography.dart';

/// Builds the Golfie ThemeData by wiring token modules into Material 3 slots.
///
/// Source of truth for "how does Golfie look" — every screen inherits from here.
class GolfieTheme {
  const GolfieTheme._();

  static ThemeData light() {
    return ThemeData(
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
          borderRadius: BorderRadius.circular(GolfieRadii.xl),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GolfieColors.ink,
          foregroundColor: GolfieColors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.24,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: GolfieColors.canvas,
        foregroundColor: GolfieColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: GolfieColors.ash,
    );
  }
}
```

- [ ] **Step 2: Verify analyze**

Run: `flutter analyze lib/core/theme/golfie_theme.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/golfie_theme.dart
git commit -m "feat(theme): add GolfieTheme.light() ThemeData builder"
```

---

## Task 7: Wire `GolfieTheme.light()` in `main.dart`

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Edit `lib/main.dart` — change app name, import theme, use it**

Replace the contents of `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'berita/providers/berita_provider.dart';
import 'berita/repositories/berita_repository.dart';
import 'berita/repositories/http_berita_repository.dart';
import 'berita/repositories/mock_berita_repository.dart';
import 'core/theme/golfie_theme.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'tournament/providers/changes_notifier_tournament_provider.dart';
import 'tournament/repositories/http_tournament_repository.dart';

void main() {
  runApp(const GolfieApp());
}

class GolfieApp extends StatelessWidget {
  const GolfieApp({super.key});

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
        title: 'Golfie',
        debugShowCheckedModeBanner: false,
        theme: GolfieTheme.light(),
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
    return MockBeritaRepository();
  }
}
```

Key changes vs original:
- `KbVsGolfApp` → `GolfieApp`
- `title: 'KBVS Golf'` → `title: 'Golfie'`
- Removed inline `ThemeData(useMaterial3: true, primarySwatch: Colors.green, fontFamily: null)`
- Added `theme: GolfieTheme.light()`
- Added import `core/theme/golfie_theme.dart`

- [ ] **Step 2: Verify analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat(theme): wire GolfieTheme.light() in main.dart"
```

---

## Task 8: Update user-facing strings in `home_screen.dart`

**Files:**
- Modify: `lib/screens/home_screen.dart:18` (AppBar title)
- Modify: `lib/screens/home_screen.dart:93` (footer text)

- [ ] **Step 1: Change AppBar title**

In `lib/screens/home_screen.dart`, find:

```dart
        title: const Text('KBVS Golf'),
```

Replace with:

```dart
        title: const Text('Golfie'),
```

- [ ] **Step 2: Change footer text**

In `lib/screens/home_screen.dart`, find:

```dart
              'KBVS Golf v1.0',
```

Replace with:

```dart
              'Golfie v1.0',
```

- [ ] **Step 3: Verify analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat(brand): rename user-facing strings to Golfie"
```

---

## Task 9: Rename Dart package `kbvs_golf` → `golfie`

**Files:**
- Modify: `pubspec.yaml` (line 1: `name:`)
- Modify: 16 dart files in `lib/` + `test/` (53 import lines)

- [ ] **Step 1: Update `pubspec.yaml` name**

Find line 1: `name: kbvs_golf`
Replace with: `name: golfie`

- [ ] **Step 2: Run project-wide sed for package imports**

Run:
```bash
grep -rl "package:kbvs_golf" lib test | xargs sed -i 's|package:kbvs_golf|package:golfie|g'
```

Expected: command exits 0, no output. Verify by running:
```bash
grep -rn "package:kbvs_golf" lib test
```
Expected: no matches.

- [ ] **Step 3: Run `flutter pub get`**

Run: `flutter pub get`
Expected: `Resolving dependencies...` then `Got dependencies!` (no version changes since no dep was added/removed).

- [ ] **Step 4: Verify analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml lib/ test/
git commit -m "feat(brand): rename Dart package kbvs_golf -> golfie"
```

---

## Task 10: Rename Android package `com.kbvs.kbvs_golf` → `com.golfie.app`

**Files:**
- Modify: `android/app/build.gradle.kts:8` (namespace)
- Modify: `android/app/build.gradle.kts:19` (applicationId)
- Modify: `android/app/src/main/AndroidManifest.xml:4` (`android:label`)
- Move: `android/app/src/main/kotlin/com/kbvs/kbvs_golf/MainActivity.kt` → `android/app/src/main/kotlin/com/golfie/app/MainActivity.kt`
- Modify: moved `MainActivity.kt:1` (`package` declaration)

- [ ] **Step 1: Update `android/app/build.gradle.kts`**

Find line 8: `    namespace = "com.kbvs.kbvs_golf"`
Replace with: `    namespace = "com.golfie.app"`

Find line 19: `        applicationId = "com.kbvs.kbvs_golf"`
Replace with: `        applicationId = "com.golfie.app"`

- [ ] **Step 2: Update `android/app/src/main/AndroidManifest.xml`**

Find line 4: `        android:label="kbvs_golf"`
Replace with: `        android:label="Golfie"`

- [ ] **Step 3: Move `MainActivity.kt` to new package path**

Run:
```bash
mkdir -p android/app/src/main/kotlin/com/golfie/app
git mv android/app/src/main/kotlin/com/kbvs/kbvs_golf/MainActivity.kt android/app/src/main/kotlin/com/golfie/app/MainActivity.kt
rmdir android/app/src/main/kotlin/com/kbvs/kbvs_golf android/app/src/main/kotlin/com/kbvs android/app/src/main/kotlin/com
```

Expected: directories moved cleanly. If `rmdir` complains about non-empty dirs, something else lives there — investigate before continuing.

- [ ] **Step 4: Update `package` declaration in moved file**

In `android/app/src/main/kotlin/com/golfie/app/MainActivity.kt`, find line 1: `package com.kbvs.kbvs_golf`
Replace with: `package com.golfie.app`

Final file content:

```kotlin
package com.golfie.app

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

- [ ] **Step 5: Verify no stale KBVS Android references**

Run:
```bash
grep -rn "kbvs" android/ || echo "OK: no kbvs references in android/"
```

Expected: `OK: no kbvs references in android/`

- [ ] **Step 6: Verify Android build**

Run: `cd android && ./gradlew :app:assembleDebug` then `cd ..`
Expected: BUILD SUCCESSFUL. (Note: first run after a package rename requires a clean — if it fails with R8/manifest merge errors, run `flutter clean` first then retry.)

If `flutter clean` is needed, run:
```bash
flutter clean
flutter pub get
flutter build apk --debug
```
Expected: `✓ Built build/app/outputs/flutter-apk/app-debug.apk`.

- [ ] **Step 7: Commit**

```bash
git add android/
git commit -m "feat(brand): rename Android package com.kbvs.kbvs_golf -> com.golfie.app"
```

---

## Task 11: Update `pubspec.yaml` description

**Files:**
- Modify: `pubspec.yaml:2` (description)

- [ ] **Step 1: Update description**

Find line 2:
```yaml
description: A Flutter golf companion app for KBVS — caddy tips, shot analysis, tournament tracking.
```
Replace with:
```yaml
description: A Flutter golf companion app for Golfie — Jakarta golf tournament discovery, caddy tips, shot analysis, news.
```

- [ ] **Step 2: Commit**

```bash
git add pubspec.yaml
git commit -m "docs(brand): update pubspec description to Golfie"
```

---

## Task 12: Delete stale `widget_test.dart`

**Files:**
- Delete: `test/widget_test.dart`

- [ ] **Step 1: Verify the file is stale boilerplate**

Read `test/widget_test.dart`. Confirm it imports `package:flutter/material.dart` and references `MyApp` / counter increment. This is the default Flutter starter test — our app's root widget is `GolfieApp` and there is no counter, so this test cannot pass post-rebrand and would fail. It does not exercise any Golfie code.

- [ ] **Step 2: Delete it**

Run: `git rm test/widget_test.dart`
Expected: `rm 'test/widget_test.dart'`

- [ ] **Step 3: Commit**

```bash
git commit -m "test: remove stale Flutter counter boilerplate widget_test.dart"
```

---

## Task 13: Update `README.md` branding + verify test-count marker

**Files:**
- Modify: `README.md` (line 1 title + several headings + test-count markers)

- [ ] **Step 1: Update top-level title**

Find line 1: `# KBVS Golf — Flutter Golf Companion App`
Replace with: `# Golfie — Jakarta Golf Tournament Companion`

- [ ] **Step 2: Update "Current State" section branding reference**

Find the bullet that begins `- **Golf News feed**`.
Confirm the surrounding paragraph still reads correctly. (No edit needed; this section was already Golfie-aligned.)

- [ ] **Step 3: Update test-count markers**

Find all `<!-- test-count: N -->` lines. After Task 12 deleted `widget_test.dart`, the test count drops by 1 (1 test inside it). New count = **105**.

Replace both `<!-- test-count: 106 -->` markers with `<!-- test-count: 105 -->`. (Markers exist on line 4 and line 14.)

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs(brand): rebrand README to Golfie + reconcile test-count marker (106 -> 105)"
```

---

## Task 14: Update `CHANGELOG.md` branding + test-count marker

**Files:**
- Modify: `CHANGELOG.md` (test-count markers if any)

- [ ] **Step 1: Check for KBVS references**

Run: `grep -n "KBVS\|kbvs_golf" CHANGELOG.md || echo "OK"`
Expected: `OK` (CHANGELOG entries reference features, not brand names — should be clean. If matches found, update them too.)

- [ ] **Step 2: Reconcile test-count markers**

Find all `<!-- test-count: N -->` lines. Replace `<!-- test-count: 106 -->` with `<!-- test-count: 105 -->`.

- [ ] **Step 3: Commit (only if changes were made)**

If changes were made:
```bash
git add CHANGELOG.md
git commit -m "docs(brand): reconcile CHANGELOG test-count marker (106 -> 105)"
```

If no changes:
Skip the commit; proceed.

---

## Task 15: Update PRD branding

**Files:**
- Modify: `prd/PRD_Stakeholder.md` (line 34, "KBVS Golf = ..." reference)
- Modify: `prd/PRD_Engr.md` (search for KBVS references)

- [ ] **Step 1: Update PRD_Stakeholder.md**

In `prd/PRD_Stakeholder.md`, find line 34:
```markdown
KBVS Golf = mobile-first, golf-specific, Jakarta-tuned.
```
Replace with:
```markdown
Golfie = mobile-first, golf-specific, Jakarta-tuned.
```

- [ ] **Step 2: Update PRD_Engr.md**

Run: `grep -n "KBVS\|kbvs_golf" prd/PRD_Engr.md`
For each match, replace `KBVS Golf` with `Golfie` (and `kbvs_golf` with `golfie` if found). Document each change in the commit message.

- [ ] **Step 3: Verify no stale KBVS refs in PRDs**

Run: `grep -rn "KBVS\|kbvs_golf" prd/ || echo "OK"`
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add prd/
git commit -m "docs(brand): rebrand PRD documents to Golfie"
```

---

## Task 16: Run full test suite + reconcile markers

**Files:**
- Modify (potentially): any test file that still has `KBVS Golf` text matchers
- Verify: `<!-- test-count: 105 -->` markers match `flutter test` output

- [ ] **Step 1: Run the test suite**

Run: `flutter test`
Expected: All tests pass. Count = 105.

If failures occur:
- Most likely: a test asserts a user-facing string. Search for it:
  ```bash
  grep -rn "KBVS Golf\|kbvs_golf" test/
  ```
  Replace each occurrence with the new Golfie equivalent.
- Less likely: a test imports `KbVsGolfApp` (post-rename `GolfieApp`). Search:
  ```bash
  grep -rn "KbVsGolfApp\|KbVsGolf" test/
  ```
  Replace with `GolfieApp` / `Golfie`.

Re-run `flutter test` until it passes.

- [ ] **Step 2: Run the test-count guard script**

Run: `bash tool/verify_test_count.sh`
Expected: passes (no output, exit code 0).

If the script reports a mismatch:
- The actual `flutter test` count differs from the marker. The marker is the source of truth (engineer updates it ONLY if test count legitimately changed).
- After Task 12 deletion + any test files removed in Step 1, count is **105**.
- If actual count differs from 105, investigate: which tests were added/removed, document the delta, update the marker to match.

- [ ] **Step 3: Final commit (if any test files were updated in Step 1)**

```bash
git add test/
git commit -m "test(brand): update test imports and matchers to Golfie"
```

---

## Task 17: Final verification + memory update

**Files:**
- Modify: `/home/kiyaya/.claude/projects/-home-kiyaya-kiyadev-kbvs-golf/memory/MEMORY.md` (index update)
- Create: `/home/kiyaya/.claude/projects/-home-kiyaya-kiyadev-kbvs-golf/memory/golfie-rebrand-decisions.md`

- [ ] **Step 1: Smoke-test the app builds and runs**

Run: `flutter build apk --debug`
Expected: success.

Optional manual smoke: `flutter run -d <device>` — confirm Canvas bg, Ink text, Inter/Lora fonts visible on Home screen. Tap into Tournament list — confirm inheritance.

- [ ] **Step 2: Verify no stale references remain**

Run:
```bash
grep -rn "kbvs_golf\|KBVS Golf\|KbVsGolf\|com.kbvs.kbvs_golf" lib/ test/ android/ pubspec.yaml README.md CHANGELOG.md prd/ docs/ 2>/dev/null | grep -v "node_modules" | grep -v ".git/" || echo "OK: no stale references"
```

Expected: `OK: no stale references`. If anything matches, fix it.

- [ ] **Step 3: Write memory file**

Create file `/home/kiyaya/.claude/projects/-home-kiyaya-kiyadev-kbvs-golf/memory/golfie-rebrand-decisions.md`:

```markdown
---
name: golfie-rebrand-decisions
description: Key rebrand decisions from 2026-07-29 — package name, Android namespace, font strategy, token module location
metadata:
  type: project
---

Rebrand from `kbvs_golf` to `Golfie` was completed 2026-07-29 (spec: docs/superpowers/specs/2026-07-29-golfie-rebranding-design.md).

- Dart package: `golfie`
- Android namespace + applicationId: `com.golfie.app`
- Fonts: `google_fonts` runtime fetch (Inter + Lora), system fallback if offline. `.ttf` bundling deferred to v2.
- Tokens live in `lib/core/theme/` (one module per token family) wired by `GolfieTheme.light()`.
- No new screens or reusable widgets in v1 — pure surface + token system rebrand.

**Why:** User asked for Golfie rebrand following docs/DESIGN.md. Chose token-module approach (Option B) over inline ThemeData (Option A) or Material seed (Option C) because tokens ARE the design system per DESIGN.md.

**How to apply:** When adding new screens, consume tokens via `Theme.of(context)` and theme extensions — don't hardcode colors/sizes. When extending the theme, add a new constant to the relevant token module rather than duplicating values.
```

- [ ] **Step 4: Update `MEMORY.md` index**

Append line to `/home/kiyaya/.claude/projects/-home-kiyaya-kiyadev-kbvs-golf/memory/MEMORY.md`:

```
- [Golfie rebrand decisions](golfie-rebrand-decisions.md) — package name, Android namespace, font + token-module choices
```

Note: this file lives outside the repo. Commit it doesn't apply (memory is harness-managed). Save and move on.

- [ ] **Step 5: Final commit (rebrand complete)**

Run:
```bash
git log --oneline -20
```
Confirm the commit history shows the full rebrand sequence.

Optional final commit message for the user-facing story (use `git commit --allow-empty` only if you want a marker commit summarizing the rebrand):

```bash
git commit --allow-empty -m "chore(brand): Golfie rebrand complete — token module + Dart/Android rename"
```

---

## Acceptance Criteria

- [ ] All 105 tests pass (`flutter test`).
- [ ] `tool/verify_test_count.sh` exits 0.
- [ ] `flutter analyze` is clean.
- [ ] `flutter build apk --debug` succeeds.
- [ ] No remaining `kbvs_golf` / `KBVS Golf` / `KbVsGolf` / `com.kbvs.kbvs_golf` references in `lib/`, `test/`, `android/`, `pubspec.yaml`, `README.md`, `CHANGELOG.md`, `prd/`, `docs/`.
- [ ] App boots with Canvas bg, Ink text, Inter/Lora typography visible on Home screen.
- [ ] Memory file updated.