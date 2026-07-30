# Auth + Onboarding Implementation Plan
**Project:** Golfie (Jakarta golf tournament app)  
**Design Spec:** `docs/superpowers/specs/2026-07-29-auth-onboarding-design.md`  
**Tech Stack:** Flutter, Supabase, Provider, shared_preferences, flutter_secure_storage  
**Branch:** feature/auth-onboarding  

---

## Phase 0: Setup & Configuration (Day 1-2)

**Goal:** All dependencies configured, Supabase project initialized, environment ready.

### Tasks

| # | Task | Owner | Status | Dependencies | Notes |
|---|------|-------|--------|--------------|-------|
| 0.1 | Add required dependencies to `pubspec.yaml` | Dev | ✅ | — | supabase_flutter, flutter_secure_storage, shared_preferences, image_picker, connectivity_plus, fluttertoast, mockito, mocktail |
| 0.2 | `flutter pub get` run successful | Dev | ✅ | 0.1 | Verify no conflicts |
| 0.3 | Create Supabase project (free tier) | Dev | ✅ | — | Get API URL and anon key |
| 0.4 | Set up environment variables in build args | Dev | ✅ | 0.3 | Add to README with instructions: `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` |
| 0.5 | Create `features/auth` directory skeleton | Dev | ✅ | 0.1 | `providers/`, `screens/`, `widgets/` |
| 0.6 | Create `features/onboarding` directory skeleton | Dev | ✅ | 0.1 | `providers/`, `screens/` |
| 0.7 | Update `memory/MEMORY.md` with new spec pointer | Dev | ✅ | — | `- [Auth Onboarding Design](docs/superpowers/specs/2026-07-29-auth-onboarding-design.md)` |

---

## Phase 1: Core Auth Infrastructure (Day 3-5)

**Goal:** Working auth provider, Supabase client setup, session persistence, basic auth screens render correctly.

### Tasks

| # | Task | Owner | Status | Dependencies | Notes |
|---|------|-------|--------|--------------|-------|
| 1.1 | Create `features/auth/widgets/supabase_wrapper.dart` | Dev | ✅ | 0.5 | Static SupabaseClient instance, init from env vars |
| 1.2 | Implement `AuthProvider` class | Dev | ✅ | 1.1 | `init()`, `setupStream()`, `signUp()`, `signIn()`, `signOut()`, `forgotPassword()`, `resetPassword()` |
| 1.3 | Register `AuthProvider` in `main.dart` `MultiProvider` | Dev | ✅ | 1.2 | Add as `ChangeNotifierProvider` |
| 1.4 | Implement `SecureStorage` wrapper (flutter_secure_storage) | Dev | ✅ | — | Singleton interface for saving/retrieving tokens |
| 1.5 | Create `features/auth/screens/splash_screen.dart` | Dev | ✅ | 1.3 | Check auth status, route to login/onboarding/home |
| 1.6 | Update `main.dart` `home: SplashScreen()` | Dev | ✅ | 1.5 | Replace existing home |
| 1.7 | Build `LoginScreen` (UI only, wired to AuthProvider) | Dev | ✅ | 1.5, 1.2 | Email + password fields, loading state, submit button |
| 1.8 | Build `SignupScreen` (UI only) | Dev | ✅ | 1.7 | Similar layout, email + password + confirm |
| 1.9 | Wire up login/signup button actions in providers | Dev | ✅ | 1.2, 1.7, 1.8 | Call methods, handle loading/error states |
| 1.10 | Test auth flow manually (local simulator) | Dev | ✅ | 1.9 | Can log in, see loading spinner, handle errors |
| 1.11 | Create `ForgotPasswordScreen` and `ResetPasswordScreen` | Dev | ✅ | 1.7 | Simple email input forms |
| 1.12 | Implement `forgotPassword()` and `resetPassword()` in AuthProvider | Dev | ✅ | 1.11 | Call Supabase API methods |

---

## Phase 2: Onboarding System (Day 6-9)

**Goal:** Onboarding provider working, all 4 screens implemented, data persists across restarts.

### Tasks

| # | Task | Owner | Status | Dependencies | Notes |
|---|------|-------|--------|--------------|-------|
| 2.1 | Create `OnboardingProvider` class | Dev | ✅ | Phase 1 | Step tracking, data storage, shared_persistence integration |
| 2.2 | Register `OnboardingProvider` in `main.dart` MultiProvider | Dev | ✅ | 2.1 | ChangeNotifierProvider |
| 2.3 | Implement `SharedPrefs` wrapper (shared_preferences) | Dev | ✅ | 2.1 | String/int/boolean save/load methods |
| 2.4 | Create `features/onboarding/widgets/progress_indicator.dart` | Dev | ✅ | — | Horizontal dot stepper component |
| 2.5 | Build `OnboardingWelcomeScreen` | Dev | ✅ | 2.4 | Hero, headline, CTA button, progress indicator |
| 2.6 | Wire welcome "Get Started" → next step | Dev | ✅ | 2.5, 2.1 | Call `nextStep()` |
| 2.7 | Build `OnboardingProfileScreen` | Dev | ✅ | 2.5 | Name TextField, avatar picker (GolfieAvatarStack), Next button |
| 2.8 | Implement avatar selection (image_picker integration) | Dev | ✅ | 2.7 | Pick from gallery/camera, display circular avatar |
| 2.9 | Profile screen saves name to provider on next press | Dev | ✅ | 2.7, 2.8 | Call `setProfileInfo(name, defaultSkill)` |
| 2.10 | Build `OnboardingSkillScreen` | Dev | ✅ | 2.9 | Use existing `SkillLevel` enum from `tournament/models/skill_level.dart` |
| 2.11 | Skill selection updates provider state | Dev | ✅ | 2.10 | `setProfileInfo` called with selected level |
| 2.12 | Build `OnboardingPreferencesScreen` | Dev | ✅ | 2.11 | Location field, toggle switches (nearby + emails), Finish button |
| 2.13 | Preferences screen completes onboarding flow | Dev | ✅ | 2.12 | Calls `completeOnboarding()`, routes to HomeScreen |
| 2.14 | Verify onboarding data survives app restart | Dev | ✅ | 2.13 | Reload from shared_prefs on provider init |
| 2.15 | Connect splash screen to onboarding completion check | Dev | ✅ | 2.14, 1.5 | If user exists but onboarding incomplete, route to onboarding |

---

## Phase 3: Polish & Design Compliance (Day 10-11)

**Goal:** All screens match Golfie DESIGN.md exactly, motion polish applied, accessibility checked.

### Tasks

| # | Task | Owner | Status | Dependencies | Notes |
|---|------|-------|--------|--------------|-------|
| 3.1 | Apply Golfie color tokens to all auth/onboarding screens | Dev | ✅ | Phase 2 | Canvas background, ink text, mint/marigold accents |
| 3.2 | Apply typography: UntitledSerifFont for headlines, UntitledSansFont for UI | Dev | ✅ | 3.1 | Import fonts, configure ThemeData or use specific text styles |
| 3.3 | Verify card radii: 24px on cards, 14px on inputs/buttons | Dev | ✅ | 3.2 | Use `GolfieRadii.xl` constant |
| 3.4 | Add multi-layered shadows to floating cards | Dev | ✅ | 3.3 | Match DESIGN.md `--shadow-xl` token |
| 3.5 | Implement pill button styling (GolfiePillButton pattern) | Dev | ✅ | 3.4 | StadiumBorder, Ink fill, white text, haptic feedback on press |
| 3.6 | Apply Ghost button style where needed (outline version) | Dev | ✅ | 3.5 | Same components but outlined variant |
| 3.7 | Add staggered entry animations for hero elements on welcome | Dev | ✅ | 3.6 | 30ms delays between elements per Emil principles |
| 3.8 | Ensure all transitions respect `prefers-reduced-motion` | Dev | ✅ | 3.7 | Fade instead of slide when reduced motion enabled |
| 3.9 | Button active state: scale(0.97) + ripple feedback | Dev | ✅ | 3.8 | Material InkResponse with transform on press |
| 3.10 | Verify contrast ratios meet WCAG AA | Dev | ✅ | 3.9 | Ink on canvas ~12:1, Graphite on canvas ~7:1 both pass |
| 3.11 | Run design checklist against docs/DESIGN.md | Dev | ✅ | 3.10 | Confirm every token referenced in spec is implemented |

---

## Phase 4: Testing (Day 12-13)

**Goal:** Unit tests, widget tests, integration tests passing; coverage >=80%.

### Tasks

| # | Task | Owner | Status | Dependencies | Notes |
|---|------|-------|--------|--------------|-------|
| 4.1 | Write `auth_provider_test.dart` unit tests | Dev | ✅ | Phase 1 | Test init, signUp, signIn, signOut, error handling |
| 4.2 | Write `onboarding_provider_test.dart` unit tests | Dev | ✅ | Phase 2 | Test step progression, persistence, completion flag |
| 4.3 | Write `login_screen_smoke_test.dart` widget test | Dev | ✅ | Phase 1 | Render test, field input, button interaction |
| 4.4 | Write `signup_screen_widget_test.dart` | Dev | ✅ | 4.3 | Form validation, navigation to onboarding |
| 4.5 | Write `welcome_screen_*test.dart` widget tests | Dev | ✅ | Phase 2 | Button presses, step advancement |
| 4.6 | Write profile/skill/preferences screen widget tests | Dev | ✅ | 4.5 | Each screen renders + basic interactions |
| 4.7 | Write `auth_onboarding_flow_test.dart` integration test | Dev | ✅ | 4.6 | Full signup → onboarding → home journey |
| 4.8 | Run `flutter test --coverage` for auth/onboarding features | Dev | ✅ | 4.7 | Verify >=80% coverage target met |
| 4.9 | Fix any flaky or failing tests | Dev | ✅ | 4.8 | Prioritize critical failures first |

---

## Phase 5: Final Review & Cleanup (Day 14)

**Goal:** Code reviewed, docs updated, branch ready for merge.

### Tasks

| # | Task | Owner | Status | Dependencies | Notes |
|---|------|-------|--------|--------------|-------|
| 5.1 | Run `flutter analyze --no-fatal-infos --no-fatal-warnings` | Dev | ✅ | — | Clean all lints |
| 5.2 | Format code with `flutter format lib/features/auth/ lib/features/onboarding/` | Dev | ✅ | 5.1 | Consistent formatting |
| 5.3 | Add TODO/FIXME comments for known future improvements | Dev | ✅ | — | e.g., Sync onboarding data to Supabase user table later |
| 5.4 | Update README with auth setup instructions | Dev | ✅ | 0.3, 0.4 | How to run, how to add env vars, how to test |
| 5.5 | Create PR draft with detailed description referencing design spec | Dev | ✅ | All phases | Link to `2026-07-29-auth-onboarding-design.md` |
| 5.6 | Self-review against design spec checklist | Dev | ✅ | 5.5 | Confirm all items from Section "Design Self-Review Checklist" are complete |

---

## Milestones

| Milestone | Completion Criteria | Target Date |
|-----------|---------------------|-------------|
| **M1: Auth Infra Working** | Splash screen routes correctly; login/signup calls work; errors shown via snackbar | Day 5 |
| **M2: Onboarding Complete** | All 4 screens built; data persists; flows back to HomeScreen after completion | Day 9 |
| **M3: Design Approved** | All screens match DESIGN.md tokens; motion polish applied; accessibility OK | Day 11 |
| **M4: Tests Green** | All unit/widget/integration tests pass; coverage >=80% | Day 13 |
| **M5: Ready for Merge** | No lint warnings; formatted; README updated; PR draft ready | Day 14 |

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Supabase client initialization fails in certain envs | Medium | High | Provide clear README instructions; add fallback to debug mode; wrap in try/catch with friendly error message |
| image_picker permissions crash on iOS/Android | Medium | High | Add permission handling (permission_handler package); provide graceful fallback (use default avatar if denied) |
| Shared prefs race condition on fast navigation | Low | Medium | Debounced writes; single source of truth in provider; test with rapid tap sequences |
| Test flakiness due to async timing | Medium | Medium | Use `pumpAndSettle()` properly; add explicit wait barriers where needed; mock time-dependent operations |
| Font loading delay causing FOFC | Low | Low | Preload fonts via Google Fonts or bundle assets; ensure fallback font matches style |

---

## Acceptance Criteria

The implementation is complete when:

1. ✅ App launches and splash screen routes correctly based on auth + onboarding state
2. ✅ Login works with valid credentials; shows appropriate error messages for invalid ones
3. ✅ Signup creates account and navigates to onboarding welcome screen
4. ✅ Forgot password sends reset email (Supabase handles actual email delivery)
5. ✅ Reset password sets new password and logs user in automatically
6. ✅ Onboarding collects: name, avatar, skill level, location, preferences
7. ✅ Onboarding data persists across app restarts
8. ✅ Completed onboarding skips on next launch (goes straight to HomeScreen)
9. ✅ All UI follows Golfie DESIGN.md color, typography, spacing, shape guidelines
10. ✅ Buttons feel responsive (scale on press + ripple)
11. ✅ Animations respect user's reduced motion preference
12. ✅ All automated tests pass (unit, widget, integration)
13. ✅ Code has zero lint warnings and follows project conventions
14. ✅ Documentation updated in README and design spec referenced

---

*Plan generated by adaCODE 2.0 Pro following superpowers:brainstorming workflow.*  
*Design spec: `docs/superpowers/specs/2026-07-29-auth-onboarding-design.md`*