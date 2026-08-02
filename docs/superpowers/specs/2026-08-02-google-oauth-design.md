# Google OAuth Sign-In — Design Spec

**Date:** 2026-08-02
**Branch:** `feature/google-oauth`
**Status:** Approved

## Problem

Login and signup screens have dummy social buttons (Google, Apple, Facebook) that only log "tapped" to console. Google OAuth needs to work end-to-end. Apple/Facebook stay hidden.

## Goals

1. Google sign-in works via Supabase OAuth (browser redirect flow).
2. Post-login routing matches existing email flow: onboarding incomplete → OnboardingWelcomeScreen, complete → HomeScreen.
3. Google pill button styled to match the app's ink-button language (matching landing page buttons).
4. Apple and Facebook buttons removed (not disabled — hidden).

## Architecture

### Supabase (external config, done in dashboard)

- Google Cloud Console: OAuth Client ID (Web application) + Client Secret.
- Supabase Dashboard → Authentication → Providers → Google:
  - Enable provider, paste Client ID + Client Secret.
  - Copy the **Callback URL** shown there (used in Google Cloud Console authorized redirect URI).
- `external.google` flips to `true` (verifiable via `GET /auth/v1/settings`).

### Flutter app

**`AuthProvider` (`lib/features/auth/providers/auth_provider.dart`)**

Add:

```dart
Future<void> signInWithGoogle() async {
  final client = _client;
  if (client == null) return _demoAction();
  _resetErrorState();
  _loading = true;
  notifyListeners();

  try {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'https://golfie.heulaulab.xyz/callback',
    );
    // Session arrives via auth state change listener after redirect-back.
  } catch (e) {
    _handleSupabaseError(e);
  } finally {
    _loading = false;
    notifyListeners();
  }
}
```

Notes:
- `signInWithOAuth` on Android launches external browser (supabase_flutter forces `externalApplication` for Google on Android).
- The redirect back into the app happens via App Links: `https://golfie.heulaulab.xyz/callback` → assetlinks.json verified → opens Golfie → supabase_flutter deeplink handler calls `getSessionFromUrl` → session stored → `onAuthStateChange` fires `signedIn`.
- Existing `init()` listener in AuthProvider picks up the session; SplashScreen routing logic already handles onboarding-vs-home.

**Login + Signup screens**

- Replace `_buildSocialRow()`:
  - Single Google pill button (full-width, pill radius, ink styling consistent with primary CTAs but white/outlined to stay secondary).
  - Uses real Google logo SVG asset (add `assets/images/google-logo.svg`).
  - Loading state: disabled + spinner while `auth.loading`.
- Remove Apple and Facebook buttons entirely.

**New asset:** `assets/images/google-logo.svg` (official Google "G" mark, multi-color). Register in `pubspec.yaml` assets section.

### Error handling

- Reuse `_handleSupabaseError` (network errors, rate limits).
- OAuth cancellation (user closes browser without picking account) → Supabase returns no session, no error → flow just ends, user stays on login screen. No error toast needed.
- `signInWithOAuth` returns `bool` (whether URL launched) — if `false`, show "Could not open Google sign-in".

## Verification

1. `GET /auth/v1/settings` → `external.google: true` (via MCP after dashboard setup).
2. App: tap Google pill → browser opens → pick account → redirect back → session → routing per onboarding status.
3. `flutter analyze` clean.

## Out of scope

- Apple, Facebook providers.
- Native Google Sign-In SDK (Firebase).
- Web support specifics.
- Release keystore assetlinks rotation (existing App Links already serve both debug and release once release SHA added).

## User action required (external)

- Google Cloud Console OAuth client creation (Client ID + Secret).
- Supabase Dashboard Google provider config.
