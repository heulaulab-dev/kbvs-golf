# Auth UI Polish Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix auth screens so sign-in is complete: add "Sign up" + "Forgot password" entry points from login, add card shadows and Golfie typography tokens, add password visibility toggles, and polish splash with brand mark.

**Architecture:** Pure UI-layer changes on top of existing `AuthProvider` (Supabase) and `OnboardingProvider`. Navigation stays with `Navigator.push` (no go_router in app yet). Extract a shared `AuthScaffold`-style card wrapper? No — YAGNI. Small shared widget only for password field since it's used 4× (login, signup, reset ×2). Everything else stays per-screen.

**Tech Stack:** Flutter, Provider, Google Fonts (Inter/Lora), existing Golfie design tokens (`GolfieColors`, `GolfieTypography`, `GolfieRadii`, `GolfieShadows`, `GolfiePillButton`).

**Working branch:** `fix/auth-ui-polish` (already created).

---

## Context for the implementing engineer

You know nothing about this codebase. Read these first:

- `docs/DESIGN.md` — design tokens (colors, type scale, radii, shadows). The app is Golfie: warm canvas `#fff3e7` background, Ink `#030302` headlines in serif (Lora substitute), Inter for UI, pill buttons, multi-layered shadows, mint/marigold/periwinkle pastels.
- `lib/core/theme/golfie_colors.dart`, `golfie_typography.dart`, `golfie_radii.dart`, `golfie_shadows.dart`, `golfie_theme.dart` — Dart mirrors of the tokens.
- `lib/widgets/golfie/golfie_pill_button.dart` — pill button with scale-down press + haptic.
- `lib/features/auth/providers/auth_provider.dart` — auth state (signIn/signUp/forgotPassword/resetPassword, `loading`, `hasError`, `errorMessage`).
- `lib/features/auth/screens/login_screen.dart`, `signup_screen.dart`, `forgot_password_screen.dart`, `reset_password_screen.dart`, `splash_screen.dart` — the screens to fix.
- `lib/features/onboarding/providers/onboarding_provider.dart` — `completed` flag drives post-login routing.

Current problems (audit result):
1. **Login has no link to signup** — signup screen unreachable, product requirement.
2. **Login has no "Forgot password?" link** — recovery flow unreachable.
3. **Cards lack the DESIGN.md multi-layer shadow** (`GolfieShadows.xl`).
4. **Raw `GoogleFonts.lora()`/`GoogleFonts.inter()` calls bypass the token system** — should use `GolfieTypography.textTheme.*` slots.
5. **No password visibility toggle** on any password field.
6. **Signup has no link back to login.**
7. **Splash is a bare spinner** — no brand moment.

Flutter 3.44+, Dart ≥3.5. Test runner: `flutter test`. Analyze: `flutter analyze`.

Note: `GolfiePillButton` exists but its `backgroundColor` default is papaya and it uses `Row(mainAxisSize: min)` — NOT suitable as the full-width primary submit button. Do NOT refactor it here. Use `ElevatedButton` with the existing per-screen style for submits (matches `GolfieTheme.light()`'s `elevatedButtonTheme`), or set `minimumSize` on GolfiePillButton if it must stretch — keep it simple: `ElevatedButton` stays.

---

### Task 1: Shared password field with visibility toggle

**Files:**
- Create: `lib/features/auth/widgets/auth_password_field.dart`
- Test: `test/features/auth/widgets/auth_password_field_test.dart`

**Step 1: Write the failing test**

Create `test/features/auth/widgets/auth_password_field_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/features/auth/widgets/auth_password_field.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('hides text by default', (tester) async {
    final controller = TextEditingController(text: 'secret123');
    addTearDown(controller.dispose);
    await tester.pumpWidget(wrap(AuthPasswordField(controller: controller)));
    expect(find.text('secret123'), findsNothing); // obscured
  });

  testWidgets('toggle reveals then hides text', (tester) async {
    final controller = TextEditingController(text: 'secret123');
    addTearDown(controller.dispose);
    await tester.pumpWidget(wrap(AuthPasswordField(controller: controller)));
    // Reveal
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(find.text('secret123'), findsOneWidget);
    // Hide again
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(find.text('secret123'), findsNothing);
  });

  testWidgets('shows hint text', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(wrap(AuthPasswordField(
      controller: controller,
      hintText: 'Password',
    )));
    expect(find.text('Password'), findsOneWidget);
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/widgets/auth_password_field_test.dart`
Expected: FAIL — compile error, `AuthPasswordField` not defined.

**Step 3: Write minimal implementation**

Create `lib/features/auth/widgets/auth_password_field.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';

/// Password input with an inline visibility toggle.
///
/// Shared by login, signup, and reset-password screens so the field
/// styling and toggle behavior stay consistent. Exposes [validator]
/// for [Form] integration.
class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    this.hintText = 'Password',
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(GolfieRadii.xl),
      borderSide: BorderSide(color: GolfieColors.ash),
    );
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hintText,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GolfieRadii.xl),
          borderSide: BorderSide(color: GolfieColors.ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GolfieRadii.xl),
          borderSide: const BorderSide(color: Color(0xFFDD6B6B)),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: GolfieColors.stone,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() => _obscure = !_obscure);
          },
        ),
      ),
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/widgets/auth_password_field_test.dart`
Expected: PASS (3 tests).

**Step 5: Commit**

```bash
git add lib/features/auth/widgets/auth_password_field.dart test/features/auth/widgets/auth_password_field_test.dart
git commit -m "feat(auth): add shared password field with visibility toggle"
```

---

### Task 2: Login screen — signup + forgot links, shadow, tokens, toggle

**Files:**
- Modify: `lib/features/auth/screens/login_screen.dart` (full rewrite of `_buildCard`)
- Test: `test/features/auth/login_screen_test.dart` (new)

**Step 1: Write the failing test**

Create `test/features/auth/login_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:golfie/features/auth/providers/auth_provider.dart';
import 'package:golfie/features/auth/screens/login_screen.dart';
import 'package:golfie/features/auth/screens/signup_screen.dart';
import 'package:golfie/features/auth/screens/forgot_password_screen.dart';
import 'package:golfie/features/onboarding/providers/onboarding_provider.dart';

// AuthProvider requires a SupabaseClient. Main passes real one; for widget
// tests we need a fake. AuthProvider has no interface — the simplest fake is
// AuthProvider.demo(), which has _client == null and demoMode == true.
// All auth actions become no-ops with an error message in demo mode, which
// is fine for rendering + navigation tests.

class _FakeOnboardingProvider extends OnboardingProvider {
  @override
  bool get completed => true;
}

void main() {
  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider.demo(),
          ),
          ChangeNotifierProvider<OnboardingProvider>(
            create: (_) => _FakeOnboardingProvider(),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders heading and email field', (tester) async {
    await pumpLogin(tester);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('shows sign up link and navigates to signup', (tester) async {
    await pumpLogin(tester);
    await tester.tap(find.text('Create one'));
    await tester.pumpAndSettle();
    expect(find.byType(SignupScreen), findsOneWidget);
  });

  testWidgets('shows forgot password link and navigates to forgot', (tester) async {
    await pumpLogin(tester);
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  });

  testWidgets('toggles password visibility', (tester) async {
    await pumpLogin(tester);
    await tester.enterText(
      find.byType(TextField).at(1),
      'hunter22',
    );
    expect(find.text('hunter22'), findsNothing);
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(find.text('hunter22'), findsOneWidget);
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/login_screen_test.dart`
Expected: FAIL — `find.text('Create one')` and `find.text('Forgot password?')` find nothing; visibility toggle missing.

**Step 3: Rewrite the login card**

Replace `_buildCard` internals in `lib/features/auth/screens/login_screen.dart`:

- Imports: add `golfie_shadows.dart`, `golfie_typography.dart`, `../widgets/auth_password_field.dart`, `signup_screen.dart`, `forgot_password_screen.dart`. Remove `google_fonts` import (tokens replace it).
- Card: wrap the `Container` in `DecoratedBox` with `boxShadow: GolfieShadows.xl`, or add `decoration` on the Container — keep the existing `ClipRRect` for the radius.
- Heading: `Text('Welcome back', style: GolfieTypography.textTheme.displaySmall!.copyWith(color: GolfieColors.ink))`.
- Subheading: `GolfieTypography.textTheme.bodyLarge!.copyWith(color: GolfieColors.graphite)`.
- Email field: keep `TextFormField` but style via the same border helper (copy the border triple from Task 1). Simpler: keep as-is, only replace hint text color usage if present.
- Password field: replace with `AuthPasswordField(controller: _passwordController, textInputAction: TextInputAction.done, validator: ...)`.
- Under password, add right-aligned `TextButton`:
  ```dart
  Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
      ),
      child: const Text('Forgot password?'),
    ),
  )
  ```
- Submit: keep `ElevatedButton` + loading spinner (matches theme).
- Bottom: add after the button:
  ```dart
  const SizedBox(height: 16),
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Don't have an account? ",
        style: GolfieTypography.textTheme.bodyMedium!.copyWith(color: GolfieColors.graphite),
      ),
      GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SignupScreen()),
        ),
        child: Text(
          'Create one',
          style: GolfieTypography.textTheme.bodyMedium!.copyWith(
            color: GolfieColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  )
  ```

Full new file content is in `docs/plans/2026-08-02-auth-ui-polish.md` appendix A (or write it directly — the structure above plus the existing form logic; keep the `Consumer<AuthProvider>` wrapper, the post-login navigation block referencing `OnboardingProvider` and `HomeScreen`, and the `dispose` method unchanged).

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/login_screen_test.dart`
Expected: PASS (4 tests).

**Step 5: Commit**

```bash
git add lib/features/auth/screens/login_screen.dart test/features/auth/login_screen_test.dart
git commit -m "feat(auth): add signup and forgot links to login, token styling, shadow, password toggle"
```

---

### Task 3: Signup screen — link back to login, toggle, tokens

**Files:**
- Modify: `lib/features/auth/screens/signup_screen.dart`
- Test: `test/features/auth/signup_screen_test.dart` (new)

**Step 1: Write the failing test**

Create `test/features/auth/signup_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:golfie/features/auth/providers/auth_provider.dart';
import 'package:golfie/features/auth/screens/signup_screen.dart';
import 'package:golfie/features/auth/screens/login_screen.dart';

void main() {
  Future<void> pumpSignup(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider.demo(),
          ),
        ],
        child: const MaterialApp(home: SignupScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders heading', (tester) async {
    await pumpSignup(tester);
    expect(find.text('Create your Golfie account'), findsOneWidget);
  });

  testWidgets('shows sign in link and navigates to login', (tester) async {
    await pumpSignup(tester);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('password fields toggle visibility', (tester) async {
    await pumpSignup(tester);
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(3)); // email + password + confirm
    await tester.enterText(fields.at(1), 'abc123');
    await tester.tap(find.byIcon(Icons.visibility_off).first);
    await tester.pump();
    expect(find.text('abc123'), findsOneWidget);
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/signup_screen_test.dart`
Expected: FAIL — no "Sign in" text, no visibility icons.

**Step 3: Rewrite the signup card**

Same pattern as Task 2 on `lib/features/auth/screens/signup_screen.dart`:

- Heading → `GolfieTypography.textTheme.displaySmall!.copyWith(color: GolfieColors.ink)`.
- Subheading → `bodyLarge` graphite.
- Password + confirm fields → `AuthPasswordField`.
- Card → add `GolfieShadows.xl`.
- Add bottom row: `"Already have an account? "` + `'Sign in'` tap target → `Navigator.pushReplacement(... LoginScreen())` (replacement, since signup is typically reached via push — replacement avoids stacking).
- Keep the existing submit logic (validation, `auth.signUp`, snackbars, push to login). Keep `dispose`.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/signup_screen_test.dart`
Expected: PASS (3 tests).

**Step 5: Commit**

```bash
git add lib/features/auth/screens/signup_screen.dart test/features/auth/signup_screen_test.dart
git commit -m "feat(auth): add sign-in link, password toggles, token styling to signup"
```

---

### Task 4: Forgot password screen — tokens + shadow

**Files:**
- Modify: `lib/features/auth/screens/forgot_password_screen.dart`
- Test: `test/features/auth/forgot_password_screen_test.dart` (new)

**Step 1: Write the failing test**

Create `test/features/auth/forgot_password_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:golfie/features/auth/providers/auth_provider.dart';
import 'package:golfie/features/auth/screens/forgot_password_screen.dart';

void main() {
  testWidgets('renders email field and send button', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider.demo(),
          ),
        ],
        child: const MaterialApp(home: ForgotPasswordScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Enter email to receive reset link'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Send Link'), findsOneWidget);
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/forgot_password_screen_test.dart`
Expected: FAIL — compile error? No — `ForgotPasswordScreen` exists and renders. The test will PASS already because the screen renders. That's fine: this test is a smoke test. To make it meaningful, first fix the heading wording (below), then the test asserts the NEW heading.

Heading fix (part of this task): "Reset your password" → "Forgot your password?" — user is not logged in; "your" implies ownership. Update the test to assert `'Forgot your password?'`.

**Step 3: Modify the screen**

In `lib/features/auth/screens/forgot_password_screen.dart`:
- Heading → `GolfieTypography.textTheme.displaySmall!.copyWith(color: GolfieColors.ink)` with text `'Forgot your password?'`.
- Subheading → `bodyLarge` graphite.
- Card → `GolfieShadows.xl`.
- Remove `google_fonts` import if now unused.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/forgot_password_screen_test.dart`
Expected: PASS (asserts new heading).

**Step 5: Commit**

```bash
git add lib/features/auth/screens/forgot_password_screen.dart test/features/auth/forgot_password_screen_test.dart
git commit -m "feat(auth): token styling and shadow on forgot password, fix heading wording"
```

---

### Task 5: Reset password screen — tokens + shadow

**Files:**
- Modify: `lib/features/auth/screens/reset_password_screen.dart`
- Test: `test/features/auth/reset_password_screen_test.dart` (new)

**Step 1: Write the failing test**

Create `test/features/auth/reset_password_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:golfie/features/auth/providers/auth_provider.dart';
import 'package:golfie/features/auth/screens/reset_password_screen.dart';

void main() {
  testWidgets('renders expired-link state when no token', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider.demo(),
          ),
        ],
        child: const MaterialApp(home: ResetPasswordScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.text('Go Back'), findsOneWidget);
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/reset_password_screen_test.dart`
Expected: PASS already (renders). Same pattern as Task 4 — the test pins current behavior so refactor is safe.

**Step 3: Modify the screen**

In `lib/features/auth/screens/reset_password_screen.dart`:
- Both branches (expired-link state and the form): heading → `GolfieTypography.textTheme.displaySmall!.copyWith(color: GolfieColors.ink)`; body → tokens; card → `GolfieShadows.xl`.
- Password + confirm fields → `AuthPasswordField` (the `_token == null` branch has no fields; only the form branch).
- Keep the deep-link TODO comments and submit logic as-is (out of scope).

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/reset_password_screen_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/auth/screens/reset_password_screen.dart test/features/auth/reset_password_screen_test.dart
git commit -m "feat(auth): token styling and shadow on reset password"
```

---

### Task 6: Splash screen — brand moment

**Files:**
- Modify: `lib/features/auth/screens/splash_screen.dart`
- Test: `test/features/auth/splash_screen_test.dart` (new)

**Step 1: Write the failing test**

Create `test/features/auth/splash_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:golfie/features/auth/providers/auth_provider.dart';
import 'package:golfie/features/auth/screens/splash_screen.dart';
import 'package:golfie/features/onboarding/providers/onboarding_provider.dart';
import 'package:golfie/widgets/golfie/golfie_hero.dart';

void main() {
  testWidgets('shows brand hero and loading indicator', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider.demo(),
          ),
          ChangeNotifierProvider<OnboardingProvider>(
            create: (_) => OnboardingProvider(),
          ),
        ],
        child: const MaterialApp(home: SplashScreen()),
      ),
    );
    await tester.pump();
    expect(find.byType(GolfieHero), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

Note: `SplashScreen._checkAuthAndOnboarding()` runs on init and will navigate away after ~1s. The test pumps once — before the delayed navigation fires — so the brand surface is visible. `AuthProvider.demo()` has `loading == false` and `user == null`, so it routes to `LoginScreen` after the delay; `tester.pump()` (single frame) happens before that. Do NOT use `pumpAndSettle` here (it would settle into the login route).

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/splash_screen_test.dart`
Expected: FAIL — `GolfieHero` not found (currently a bare spinner).

**Step 3: Modify the screen**

In `lib/features/auth/screens/splash_screen.dart`:
- Add imports: `../../../widgets/golfie/golfie_index.dart`.
- Replace the `build` body's `Center(child: CircularProgressIndicator(...))` with:

```dart
body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      GolfieHero(
        title: 'Golfie',
        subtitle: 'Jakarta golf tournaments',
      ),
      const SizedBox(height: 32),
      const CircularProgressIndicator(color: GolfieColors.mint),
    ],
  ),
)
```

Wait — check `GolfieHero` (`lib/widgets/golfie/golfie_hero.dart`): it renders `GolfieCollageCard` with a `title` styled `displaySmall` and `subtitle` `bodyMedium`. The audit noted splash lacks branding; `GolfieHero` with title 'Golfie' gives the brand moment with zero new styling code. Keep it.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/splash_screen_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/auth/screens/splash_screen.dart test/features/auth/splash_screen_test.dart
git commit -m "feat(auth): brand hero on splash screen"
```

---

### Task 7: Full verification + merge prep

**Step 1: Run analyzer**

Run: `flutter analyze`
Expected: No issues (or only pre-existing infos in untouched files).

**Step 2: Run full test suite**

Run: `flutter test`
Expected: All tests pass, including the 4 new test files.

**Step 3: Manual smoke check (optional but recommended)**

Run: `flutter run` (needs `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` from `.env.development`, or run in demo mode)
Check: login shows links, signup reachable, forgot reachable, toggles work, splash shows brand.

**Step 4: Commit any stragglers**

```bash
git status
git add -A
git commit -m "chore(auth): verification pass"
```
(Only if there are uncommitted changes.)

**Step 5: Hand off for review/merge**

Branch `fix/auth-ui-polish` is ready. Push and open a PR, or review locally. Do NOT merge to `main` without a review.

---

## Out of scope (deliberate)

- go_router migration — app uses `Navigator`; keep it.
- `GolfiePillButton` refactor — its `Row(mainAxisSize: min)` + papaya default makes it wrong for full-width submits; don't touch it in this branch.
- Deep-link token extraction for reset password — pre-existing TODO, untouched.
- Signup → onboarding routing — signup currently pushes to login after verification-email snackbar (Supabase email confirmation flow). Out of scope.
- Dark mode, localization.
