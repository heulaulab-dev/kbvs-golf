# Google OAuth Sign-In — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add working Google OAuth sign-in to the Golfie Flutter app via Supabase browser-redirect flow.

**Architecture:** Single `signInWithGoogle()` method on AuthProvider calls Supabase's `signInWithOAuth(OAuthProvider.google)` with redirect to `https://golfie.heulaulab.xyz/callback`. Login/signup screens replace dummy three-button social row with a single Google pill button (ink style, SVG logo). Apple and Facebook buttons removed. Existing `onAuthStateChange` listener + SplashScreen routing already handle post-login session routing.

**Tech Stack:** Flutter, supabase_flutter, svg package (already in pubspec via flutter_svg), flutter_test.

---

### Task 1: Add `signInWithGoogle()` to AuthProvider

**Files:**
- Modify: `lib/features/auth/providers/auth_provider.dart:104-108` (after `signIn` method)

- [ ] **Step 1: Read current AuthProvider to confirm method boundary**

```bash
grep -n "Future<void> signIn" lib/features/auth/providers/auth_provider.dart
# expect: ~line 106
```

- [ ] **Step 2: Add `signInWithGoogle()` method**

Insert after the `signIn()` method (after its closing `}`):

```dart
  /// Signs in with Google via Supabase OAuth (browser redirect).
  ///
  /// Launches external browser. Session arrives via deep link redirect
  /// and is handled automatically by the auth state change listener.
  Future<void> signInWithGoogle() async {
    final client = _client;
    if (client == null) return _demoAction();
    _resetErrorState();
    _loading = true;
    notifyListeners();

    try {
      final launched = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://golfie.heulaulab.xyz/callback',
      );

      if (!launched) {
        _hasError = true;
        _errorMessage = 'Could not open Google sign-in. Please try again.';
      }
    } catch (e) {
      _handleSupabaseError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
```

- [ ] **Step 3: Verify no import needed**

`OAuthProvider` comes from `supabase_flutter/supabase.dart` (already imported at line 1). No new imports needed.

- [ ] **Step 4: Run analyzer**

Run: `flutter analyze lib/features/auth/providers/auth_provider.dart`
Expected: No issues (only the existing unused_import warning from `golfie_shadows.dart` in other files).

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/providers/auth_provider.dart
git commit -m "feat(auth): add signInWithGoogle() to AuthProvider

Browser redirect flow via Supabase OAuth, redirects to
golfie.heulaulab.xyz/callback. Shows error if browser fails to launch."
```

---

### Task 2: Add Google SVG asset + register in pubspec

**Files:**
- Create: `assets/images/google-logo.svg`
- Modify: `pubspec.yaml:50-54` (assets section)

- [ ] **Step 1: Create Google SVG asset**

Download official Google "G" logo SVG (4-color, on transparent background) and save to `assets/images/google-logo.svg`. Use the standard 24x24 SVG from https://developers.google.com/identity/images/branding-guidelines or embed the SVG content directly:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
  <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 01-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" fill="#4285F4"/>
  <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
  <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
  <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
</svg>
```

- [ ] **Step 2: Register in pubspec.yaml**

Add to the assets list in `pubspec.yaml` (after the existing `golfie-icon-only.svg` line):

```yaml
  assets:
    - assets/images/golfie-icon.jpg
    - assets/images/golfie-icon-only.svg
    - assets/images/google-logo.svg
    - assets/fonts/
    - assets/data/
    - .env.development
    - .env.staging
    - .env.production
```

- [ ] **Step 3: Run analyzer**

Run: `flutter pub get && flutter analyze lib/`
Expected: no new issues.

- [ ] **Step 4: Commit**

```bash
git add assets/images/google-logo.svg pubspec.yaml
git commit -m "feat(assets): add Google logo SVG, register in pubspec"
```

---

### Task 3: Replace dummy social row in LoginScreen with Google pill

**Files:**
- Modify: `lib/features/auth/screens/login_screen.dart:317-359` (`_buildSocialRow` and `_socialButton` methods)

- [ ] **Step 1: Read current `_buildSocialRow` and `_socialButton` boundaries**

```bash
grep -n "_buildSocialRow\|_socialButton\|import.*Icons" lib/features/auth/screens/login_screen.dart
# expect: _buildSocialRow ~line 317, _socialButton ~line 345
```

- [ ] **Step 2: Add SvgPicture import at top of file**

Add after `import 'package:flutter_svg/flutter_svg.dart';` (already present in login_screen.dart — verify):

```dart
import 'package:flutter_svg/flutter_svg.dart';
```

This import is already present (login_screen imports it for the logo). No change needed — confirm with:

```bash
grep "flutter_svg" lib/features/auth/screens/login_screen.dart
```

- [ ] **Step 3: Replace `_buildSocialRow` and `_socialButton` methods**

Remove both methods and replace with a single `GoogleSignInButton`:

```dart
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GolfieRadii.pill),
          ),
          side: const BorderSide(color: GolfieColors.ash),
          backgroundColor: GolfieColors.white,
        ),
        onPressed: auth.loading
            ? null
            : () async {
                debugPrint('🔴 [AUTH] Google sign-in tapped');
                await auth.signInWithGoogle();
                if (!auth.hasError && auth.isAuthenticated && context.mounted) {
                  final onboard = context.read<OnboardingProvider>();
                  if (onboard.completed) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OnboardingWelcomeScreen(),
                      ),
                    );
                  }
                } else if (auth.hasError && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(auth.errorMessage ?? 'Google sign-in failed'),
                      backgroundColor: GolfieColors.ink,
                    ),
                  );
                }
              },
        child: auth.loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: GolfieColors.ink,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/google-logo.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: GolfieColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
```

Add the required import for OnboardingProvider (verify already present):

```bash
grep "OnboardingProvider" lib/features/auth/screens/login_screen.dart
# if missing, add:
# import '../../../features/onboarding/providers/onboarding_provider.dart';
# import '../../../features/onboarding/screens/onboarding_welcome_screen.dart';
# import '../../../screens/home_screen.dart';
```

- [ ] **Step 4: Replace call site in `build()`**

Find the call to `_buildSocialRow()` and replace with `_buildGoogleButton()`:

```bash
grep -n "_buildSocialRow\|_buildGoogleButton" lib/features/auth/screens/login_screen.dart
```

Replace `_buildSocialRow()` call with `_buildGoogleButton()`.

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze lib/features/auth/screens/login_screen.dart`
Expected: no errors. (Warnings for unused imports OK — those are pre-existing.)

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/screens/login_screen.dart
git commit -m "feat(auth): replace dummy social buttons with Google pill button

Single full-width outlined pill, Google SVG logo + 'Continue with Google'.
Handles loading/error/onboarding routing. Apple/Facebook removed."
```

---

### Task 4: Same replacement in SignupScreen

**Files:**
- Modify: `lib/features/auth/screens/signup_screen.dart:317-359` (same method pattern)

- [ ] **Step 1: Read current `_buildSocialRow` / `_socialButton` in signup_screen**

```bash
grep -n "_buildSocialRow\|_socialButton" lib/features/auth/screens/signup_screen.dart
```

- [ ] **Step 2: Add required imports (verify existing)**

```bash
grep -n "flutter_svg\|OnboardingProvider\|OnboardingWelcome\|HomeScreen" lib/features/auth/screens/signup_screen.dart
```

Ensure these are present:
```dart
import 'package:flutter_svg/flutter_svg.dart';
import '../../../features/onboarding/providers/onboarding_provider.dart';
import '../../../features/onboarding/screens/onboarding_welcome_screen.dart';
import '../../../screens/home_screen.dart';
```

- [ ] **Step 3: Replace `_buildSocialRow` and `_socialButton` with `_buildGoogleButton()`**

Same implementation as Task 3 (copy the `_buildGoogleButton()` method verbatim — exact same code, same `auth` reference via Consumer).

- [ ] **Step 4: Replace call site in build()**

Replace `_buildSocialRow()` call with `_buildGoogleButton()`.

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze lib/features/auth/screens/signup_screen.dart`
Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/screens/signup_screen.dart
git commit -m "feat(auth): add Google pill button to signup screen

Same Google sign-in button as login. Apple/Facebook removed."
```

---

### Task 5: Verify Supabase Google provider status (manual checkpoint)

**Files:** None (dashboard action)

- [ ] **Step 1: Check Supabase settings via MCP**

The Supabase MCP tool can query the auth settings endpoint. Run a check after Google is enabled in the dashboard:

```bash
ANON_KEY="<from .env.development>"
curl -s "https://rvlvnvukmbwkpooilkcq.supabase.co/auth/v1/settings" \
  -H "apikey: $ANON_KEY" | python3 -c "import json,sys; d=json.load(sys.stdin); print('google:', d['external']['google'])"
```

Expected output when enabled: `google: True`

If `google: False` → Google provider is not yet configured in Supabase Dashboard → ask user to complete dashboard setup first before proceeding to Task 6.

- [ ] **Step 2: Commit checkpoint (optional, only if dashboard setup is done)**

No code change — this is a manual verification gate.

---

### Task 6: Final full-app analyze + test run

**Files:** All modified files (no new changes)

- [ ] **Step 1: Run full analyzer**

Run: `flutter analyze`
Expected: 0 errors. Same pre-existing warnings only.

- [ ] **Step 2: Verify login_screen_test still passes (if applicable)**

Run: `flutter test test/features/auth/login_screen_test.dart --no-pub`
Expected: tests pass. If the test references old `_socialButton`/`Icons.g_mobiledata` → the test needs updating.

- [ ] **Step 3: Push branch**

```bash
git push -u origin feature/google-oauth
```

- [ ] **Step 4: Summary**

Google OAuth is now wired. To test end-to-end:
1. Enable Google in Supabase Dashboard (Task 5).
2. `flutter run --dart-define=ENV=development`.
3. Tap "Continue with Google" → browser opens → pick account → redirect back → session → onboarding or home.
