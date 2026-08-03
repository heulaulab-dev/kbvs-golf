# Profile & Settings — Design Spec

**Date:** 2026-08-03
**Branch:** `feature/profile-settings`
**Status:** Approved

## Problem

Golfie has no way for users to view or edit their profile, manage preferences, or log out. HomeScreen has no profile access. AuthProvider.signOut() exists but no UI calls it.

## Goals

1. Bottom navigation with 4 tabs: Home, News, Tournaments, Profile.
2. Combined Profile + Settings screen showing account info, preferences, about, logout.
3. Edit profile screen for name/skill/location.
4. Logout with confirmation dialog → clears session → SplashScreen.

## Architecture

### New files

```
lib/features/profile/
├── screens/
│   ├── profile_screen.dart          # Main combined screen
│   └── edit_profile_screen.dart     # Edit name/skill/location
```

No new provider — reuses `AuthProvider` + `OnboardingProvider` (existing ChangeNotifiers, already registered in main.dart).

### HomeScreen restructure

Current HomeScreen is a single screen with AppBar actions (caddy tips, admin, popup menu) and FAB. Restructure to:

```
Scaffold(
  body: IndexedStack(index: _tabIndex, children: [
    HomeTab(),          // existing HomeScreen body content
    BeritaListScreen(), // News tab (existing berita screen)
    TournamentListScreen(), // Tournaments tab (existing)
    ProfileScreen(),    // new
  ]),
  bottomNavigationBar: NavigationBar(
    destinations: [
      Home, News (berita), Tournaments, Profile
    ],
  ),
)
```

- HomeScreen becomes a StatefulWidget holding `_tabIndex`.
- The existing AppBar actions (caddy tips, admin, popup) stay on the Home tab only. Other tabs get their own simple AppBars.
- IndexedStack preserves each tab's state across switches.

### ProfileScreen layout

```
┌────────────────────────────┐
│  Avatar circle (initials)   │
│  Name (onboarding.userName  │
│    or email prefix)         │
│  Email (auth.user.email)    │
├────────────────────────────┤
│  ACCOUNT                    │
│  Edit profile          ›    │  → EditProfileScreen
├────────────────────────────┤
│  PREFERENCES                │
│  Nearby tournaments    [on] │  ← OnboardingProvider.showNearby
│  Email notifications   [on] │  ← OnboardingProvider.emailNotifications
├────────────────────────────┤
│  ABOUT                      │
│  App version        1.0.0   │  ← AppConfig.instance.appVersion
├────────────────────────────┤
│  Log out (red text)         │  → confirm dialog → signOut → Splash
└────────────────────────────┘
```

### Behavior

| Action | Behavior |
|--------|----------|
| Toggle nearby | Write `OnboardingProvider.setPreferences` equivalent — update `_showNearby`, persist via SharedPreferences. Note: current `setLocationAndPreferences` exists; toggles update prefs without finishing onboarding. |
| Toggle email | Same as above. |
| Edit profile | Push EditProfileScreen. On save: `setProfileInfo(name, level)` + `setLocationAndPreferences(location)` — updates provider, persists. |
| Log out | Confirmation dialog (Cancel / Log out). On confirm: `AuthProvider.signOut()` → `pushAndRemoveUntil(SplashScreen)`. |
| Email display | `AuthProvider.user?.email` — read-only. |

### EditProfileScreen layout

- Name field (min 2 chars, live validation — same pattern as onboarding profile screen)
- Skill level grid (reuse pattern from OnboardingSkillScreen — 4 cards, mint selected)
- Location field (optional)
- Save button (ink pill, disabled until name valid)
- On save: update provider, pop back to ProfileScreen

### Data flow

- Reads: `AuthProvider.user` (email), `OnboardingProvider` (userName, skillLevel, location, showNearby, emailNotifications)
- Writes: `OnboardingProvider` methods — `setProfileInfo`, `setSkillLevel`, `setLocationAndPreferences`
- No new backend. All local/onboarding data.

### Design system

- Canvas bg (#fff3e7), white cards (24px radius, 4-layer tinted shadow per GolfieShadows.xl)
- Ink (#030302) primary text, graphite secondary, stone tertiary
- Mint accent for toggles/selection, red for logout
- Pill buttons (ink bg, white text), full-width
- Matches existing auth/onboarding screens

## Verification

1. `flutter analyze` clean.
2. App runs: bottom nav shows 4 tabs, switching preserves state.
3. Profile shows correct name/email from auth + onboarding.
4. Toggle persists across app restart.
5. Edit profile saves + reflects on ProfileScreen.
6. Logout → confirm → session cleared → SplashScreen → LoginScreen.

## Out of scope

- Profile photo upload (avatar is initials placeholder).
- Change password / email.
- Delete account.
- Server-side profile persistence (profile data is onboarding-local for now).
- Dark mode.

## User action required

None — all local. Supabase user data (email) read-only from session.
