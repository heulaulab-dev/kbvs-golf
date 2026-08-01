# Post-Build Audit & Prod-Readiness Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate all deprecated API usage, critical lint warnings, and upgrade key packages so the app is Flutter SDK upgrade-safe and lint-clean.

**Architecture:** Three focused workstreams — (1) deprecated widget APIs in `submit_tournament_screen.dart` (Radio/DropdownButtonFormField), (2) async-context misuse in auth screens (build-context-across-async-gaps), (3) package upgrades + residual lint cleanup. Each task is self-contained and testable.

**Tech Stack:** Flutter 3.44.8, Dart 3.x, `google_fonts: ^6.2.1` → `^8.2.1`, `intl: ^0.19.0` → `^0.20.3`, `flutter_lints: ^4.0.0` → `^6.0.0`, `mockito: ^5.4.4` → `^5.8.0`, Flutter's built-in `RadioGroup` widget (widgets layer), `dart fix --apply` for auto-fixes.

---

## File Map

| File | Action | What changes |
|---|---|---|
| `lib/screens/submit_tournament_screen.dart` | Modify | Replace deprecated `Radio(groupValue/onChange)` with `RadioGroup(groupValue/onChanged)`, `DropdownButtonFormField(value:)` → `(initialValue:)`, drop dead `return '';` |
| `lib/features/auth/screens/forgot_password_screen.dart` | Modify | Guard async gap usages of `context` with fresh `mounted` checks |
| `lib/features/auth/screens/login_screen.dart` | Modify | Guard async gap usages of `context` with fresh `mounted` checks |
| `pubspec.yaml` | Modify | Bump `google_fonts`, `intl`, `flutter_lints`, `mockito` version constraints |
| `pubspec.lock` | Update | Via `flutter pub get` |
| `analysis_options.yaml` | **No change** | Keep current config; upgrades surface new lints handled per-task |
| `lib/screens/home_screen.dart` | Modify | Remove unused `textTheme` local variable |
| `lib/berita/screens/berita_list_screen.dart` | Modify | Remove unused `textTheme` local variable (line 74) |
| `lib/berita/screens/berita_webview_screen.dart` | Modify | Remove unused import `../../widgets/golfie/golfie_index.dart` |
| `lib/screens/caddy_tips_screen.dart` | Modify | Remove unused imports `../core/theme/golfie_typography.dart` and `../widgets/golfie/golfie_index.dart` |
| `lib/tournament/screens/tournament_detail_screen.dart` | Modify | Remove unused imports `dart:async`, `../models/skill_level.dart`, `../models/tournament_status.dart` |
| `lib/tournament/repositories/mock_tournament_repository.dart` | Modify | Remove unnecessary cast on line 41 |
| `lib/tournament/repositories/http_tournament_repository.dart` | Modify | Apply `prefer_const_constructors` on line 65 |
| `lib/features/auth/providers/auth_provider.dart` | Modify | Apply `prefer_conditional_assignment` on line 198 |
| `lib/screens/home_screen.dart` | Modify | Reorder `child` argument last (`sort_child_properties_last`) |

---

## Task 1: Fix deprecated Radio API in SubmitTournamentScreen

**Files:**
- Modify: `lib/screens/submit_tournament_screen.dart`

- [ ] **Step 1: Inspect current Radio block**

Open `lib/screens/submit_tournament_screen.dart` at lines 199–219. Current code uses deprecated `Radio(groupValue: ..., onChanged: ...)` pattern.

- [ ] **Step 2: Replace Radio group with RadioGroup widget**

Replace the entire `Column` block (lines 199–219) with this:

```dart
// Min Skill Level
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text('Min Skill Level:', style: TextStyle(fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    RadioGroup<SkillLevel>(
      groupValue: _minSkill,
      onChanged: (v) => setState(() => _minSkill = v),
      child: Wrap(
        spacing: 16,
        children: SkillLevel.values.map((level) {
          final label = switch (level) {
            SkillLevel.beginner => 'Beginner',
            SkillLevel.casual => 'Casual',
            SkillLevel.competitive => 'Competitive',
            SkillLevel.pro => 'Pro',
          };
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<SkillLevel>(value: level, onChanged: (_) => setState(() => _minSkill = level)),
              Text(label),
            ],
          );
        }).toList(),
      ),
    ),
  ],
),
```

Note: `Radio(value: ..., onChanged: ...)` without `groupValue` is still valid — the `RadioGroup` ancestor manages grouping. Using `Switch` expression keeps it tight.

- [ ] **Step 3: Fix deprecated DropdownButtonFormField(value:) → initialValue:**

In `_buildDropdownList<T>` (around line 128), change:

```dart
      value: selectedValue,
```
to:
```dart
      initialValue: selectedValue,
```

- [ ] **Step 4: Remove dead code return**

Delete line 194: `return '';` (the exhaustive switch on enum already covers all cases).

- [ ] **Step 5: Verify no deprecation warnings remain in this file**

Run:
```
flutter analyze lib/screens/submit_tournament_screen.dart 2>&1
```
Expected: no errors, no `deprecated_member_use` warnings.

- [ ] **Step 6: Commit**

```bash
git add lib/screens/submit_tournament_screen.dart
git commit -m "fix(ui): replace deprecated Radio/groupValue and DropdownButtonFormField(value:) with RadioGroup and initialValue"
```

---

## Task 2: Fix async-context misuse in auth screens

**Files:**
- Modify: `lib/features/auth/screens/forgot_password_screen.dart`
- Modify: `lib/features/auth/screens/login_screen.dart`

### 2a. forgot_password_screen.dart

- [ ] **Step 1: Replace the Future.delayed close with mounted-safe version**

Current (line 84-86):
```dart
                          Future.delayed(const Duration(seconds: 3), () {
                            if (mounted) Navigator.pop(context);
                          });
```
This captures `context` from the outer builder closure — after 3 s it may be stale. Replace with:
```dart
                          final _ctx = context;
                          Future.delayed(const Duration(seconds: 3), () {
                            if (_ctx.mounted) Navigator.pop(_ctx);
                          });
```

- [ ] **Step 2: Guard the other async-context usages (lines 81, 85, 88)**

Current pattern uses `if (!auth.hasError && mounted)` then `ScaffoldMessenger.of(context)`. The `mounted` check is on the State but `context` is the builder context. Fix by caching the context:

At the start of the `onPressed` lambda (line 77), capture:
```dart
onPressed: auth.loading ? null : () async {
  final ctx = context;
```

Then replace every `ScaffoldMessenger.of(context)` inside the lambda with `ScaffoldMessenger.of(ctx)`, and every `Navigator.pop(context)` with `Navigator.pop(ctx)`. Also replace `if (mounted)` guards with `if (ctx.mounted)`.

The full fixed `onPressed` body becomes:

```dart
onPressed: auth.loading ? null : () async {
  final ctx = context;
  if (_formKey.currentState!.validate()) {
    await auth.forgotPassword(_emailController.text.trim());
    if (!auth.hasError && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Reset link sent to your email'), backgroundColor: GolfieColors.mint),
      );
      final ctx2 = ctx;
      Future.delayed(const Duration(seconds: 3), () {
        if (ctx2.mounted) Navigator.pop(ctx2);
      });
    } else if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Could not send link'), backgroundColor: GolfieColors.marigold),
      );
    }
  }
},
```

- [ ] **Step 3: Verify**

```
flutter analyze lib/features/auth/screens/forgot_password_screen.dart 2>&1
```
Expected: no `use_build_context_synchronously` warnings.

### 2b. login_screen.dart

- [ ] **Step 4: Apply same pattern to login_screen.dart**

In `onPressed` (line 98), capture `final ctx = context;` and use `ctx` everywhere inside the async lambda. Replace the block starting at line 98–111 with:

```dart
onPressed: auth.loading ? null : () async {
  final ctx = context;
  if (_formKey.currentState!.validate()) {
    await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!auth.hasError && auth.isAuthenticated && ctx.mounted) {
      Navigator.pushReplacementNamed(ctx, '/home');
    } else if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Login failed'), backgroundColor: GolfieColors.marigold),
      );
    }
  }
},
```

- [ ] **Step 5: Verify**

```
flutter analyze lib/features/auth/screens/login_screen.dart 2>&1
```
Expected: no `use_build_context_synchronously` warnings.

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/screens/forgot_password_screen.dart lib/features/auth/screens/login_screen.dart
git commit -m "fix(auth): guard BuildContext across async gaps with captured .mounted checks"
```

---

## Task 3: Upgrade packages

**Files:**
- Modify: `pubspec.yaml`
- Run: `flutter pub get`

- [ ] **Step 1: Update version constraints**

In `pubspec.yaml`, replace these lines:

```yaml
  intl: ^0.19.0
```
→
```yaml
  intl: ^0.20.3
```

```yaml
  google_fonts: ^6.2.1
```
→
```yaml
  google_fonts: ^8.2.1
```

```yaml
  flutter_lints: ^4.0.0
```
→
```yaml
  flutter_lints: ^6.0.0
```

```yaml
  mockito: ^5.4.4
```
→
```yaml
  mockito: ^5.8.0
```

- [ ] **Step 2: Fetch updated dependencies**

```
flutter pub get 2>&1 | tail -5
```
Expected: packages resolved, no errors.

- [ ] **Step 3: Verify app still compiles**

```
flutter analyze 2>&1 | grep -E 'error|Error'
```
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore(deps): upgrade intl 0.19→0.20, google_fonts 6→8, flutter_lints 4→6, mockito 5.4→5.8"
```

---

## Task 4: Remove unused local variables & imports

**Files:**
- Modify: `lib/screens/home_screen.dart` (remove unused `textTheme` variable, line 17)
- Modify: `lib/berita/screens/berita_list_screen.dart` (remove unused `textTheme` variable, line 74)
- Modify: `lib/berita/screens/berita_webview_screen.dart` (remove unused import `../../widgets/golfie/golfie_index.dart`, line 6)
- Modify: `lib/screens/caddy_tips_screen.dart` (remove unused imports lines 6-7)
- Modify: `lib/tournament/screens/tournament_detail_screen.dart` (remove unused imports lines 4, 6, 8)

- [ ] **Step 1: home_screen.dart**

Remove line 17 (`final textTheme = Theme.of(context).textTheme;`) — it's not used anywhere in the file.

- [ ] **Step 2: berita_list_screen.dart**

Remove line 74 (`final textTheme = Theme.of(context).textTheme;`) — it's not used anywhere in the file.

- [ ] **Step 3: berita_webview_screen.dart**

Remove line 6: `import '../../widgets/golfie/golfie_index.dart';`

- [ ] **Step 4: caddy_tips_screen.dart**

Remove lines 6-7:
```dart
import '../core/theme/golfie_typography.dart';
import '../widgets/golfie/golfie_index.dart';
```

- [ ] **Step 5: tournament_detail_screen.dart**

Remove lines 4, 6, 8:
```dart
import 'dart:async';
import '../models/skill_level.dart';
import '../models/tournament_status.dart';
```
(verify these are indeed unused — grep confirms zero usages of `Timer`, `skill_level`, `tournament_status` symbols in the file.)

- [ ] **Step 6: Verify**

```
flutter analyze lib/screens/home_screen.dart lib/berita/screens/berita_list_screen.dart lib/berita/screens/berita_webview_screen.dart lib/screens/caddy_tips_screen.dart lib/tournament/screens/tournament_detail_screen.dart 2>&1
```
Expected: no `unused_local_variable` or `unused_import` warnings in these files.

- [ ] **Step 7: Commit**

```bash
git add lib/screens/home_screen.dart lib/berita/screens/berita_list_screen.dart lib/berita/screens/berita_webview_screen.dart lib/screens/caddy_tips_screen.dart lib/tournament/screens/tournament_detail_screen.dart
git commit -m "chore(lint): remove unused local variables and unused imports across 5 files"
```

---

## Task 5: Apply remaining auto-fixable lints

**Files:**
- Modify: `lib/tournament/repositories/mock_tournament_repository.dart` (unnecessary cast, line 41)
- Modify: `lib/tournament/repositories/http_tournament_repository.dart` (prefer_const, line 65)
- Modify: `lib/features/auth/providers/auth_provider.dart` (prefer_conditional_assignment, line 198)
- Modify: `lib/screens/home_screen.dart` (sort_child_properties_last, line 67)
- Plus any remaining `prefer_const_constructors` across auth screens

- [ ] **Step 1: Run dart fix for auto-fixable issues**

```
dart fix --apply 2>&1 | tail -20
```
This applies all `prefer_const_constructors`, `prefer_conditional_assignment`, `unnecessary_cast`, `sort_child_properties_last` automatically.

- [ ] **Step 2: Verify clean analyze**

```
flutter analyze 2>&1 | grep -E 'error|warning'
```
Expected: zero errors and zero warnings. Only `info` messages may remain (style nits).

- [ ] **Step 3: Review any dart fix output for regressions**

Check `lib/tournament/repositories/http_tournament_repository.dart` around line 65 — ensure `const` addition didn't change behavior. Check `auth_provider.dart` line 198 — `??=` should be semantically identical to the `if` block.

- [ ] **Step 4: Final full analyze**

```
flutter analyze 2>&1
```
Expected output (tail):
```
No issues found!
```
(or: only `info` severity messages, no `warning` or `error`)

- [ ] **Step 5: Run debug build to confirm no regressions**

```
flutter run -d emulator-5554 --debug 2>&1
```
Expected: app launches cleanly on emulator, no crash on splash/login/home screens.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "chore(lint): apply auto-fixes for const, conditional assignment, casts, child order + verify clean analyze"
```

---

## Self-Review Checklist (author internal)

1. **Spec coverage:** All deprecated APIs (Task 1), all async-context warnings (Task 2), all package bumps (Task 3), all unused vars/imports (Task 4), all remaining lints (Task 5). ✅
2. **Placeholder scan:** Every step has concrete code or commands. No TBDs. ✅
3. **Type consistency:** `RadioGroup<T>` and `Radio<T>` types match throughout. `DropdownButtonFormField(initialValue: T?)` matches generic. Auth context variables named `ctx`/`ctx2` consistently. ✅
4. **Edge cases:** `RadioGroup` needs `SkillLevel` enum to be non-nullable type parameter — already true. `initialValue` on `DropdownButtonFormField` accepts null — already handled. `ctx.mounted` guards cover all async gaps. ✅
5. **Package compat:** `google_fonts: 8.x` requires Flutter ≥3.38 — app is on 3.44.8. ✅. `intl: 0.20` stable, no API break. `flutter_lints: 6` compatible. `mockito: 5.8` compatible. ✅

---

## Execution Handoff

Plan complete. Two execution options:

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
