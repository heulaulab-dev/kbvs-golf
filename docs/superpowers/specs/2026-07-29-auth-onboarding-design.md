---
name: auth-onboarding-design
description: Authentication and onboarding system design for Golfie Flutter app using Supabase, Provider, and Golfie design system
metadata:
  type: project
  author: adaCODE 2.0 Pro
  date: 2026-07-29
  framework: Flutter
  state_management: Provider
  auth_provider: Supabase
  design_system: Golfie (docs/DESIGN.md)
---

# Auth + Onboarding Design Specification

Golfie — Jakarta golf tournament discovery and participation app. Mobile-first. This document specifies the authentication and onboarding subsystem.

## Executive Summary

Implement full authentication (signup, login, forgot password, reset password, session persistence, email verification verification) and onboarding flow (welcome → profile → skill level → preferences) following the Golfie design system from docs/DESIGN.md, using Supabase as auth provider, Provider for state management, and secure storage for token persistence. All UI conforms to Golfie tokens: warm canvas background #fff3e7, UntitledSerifFont for headlines, UntitledSansFont for UI, mint/marigold/periwinkle pastels, rounded corners, multi-layered shadows, pill buttons. Follow Emil Kowalski design engineering principles for invisible correctness, animation polish, and accessible motion.

## Architecture Overview

### Directory Structure

```
lib/
├── features/
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_provider.dart          # Supabase auth state as ChangeNotifier
│   │   ├── screens/
│   │   │   ├── splash_screen.dart            # Initial check: auth status → route
│   │   │   ├── login_screen.dart             # Email/password login
│   │   │   ├── signup_screen.dart            # New account creation
│   │   │   ├── forgot_password_screen.dart   # Send reset link
│   │   │   └── reset_password_screen.dart    # Set new password
│   │   └── widgets/
│   │       └── supabase_wrapper.dart         # Supabase client init + singleton
│   ├── onboarding/
│   │   ├── providers/
│   │   │   └── onboarding_provider.dart      # Step progression & data collection
│   │   └── screens/
│   │       ├── onboarding_welcome.dart       # Welcome CTA
│   │       ├── onboarding_profile.dart       # Name + avatar upload
│   │       ├��─ onboarding_skill.dart         # SkillLevel selection
│   │       └── onboarding_preferences.dart   # Location + toggles
│   │
├── providers/
│   └── app_state.dart                        # Existing unchanged app state
├── screens/
│   └── home_screen.dart                      # Existing, now reachable after auth/onboarding
└── main.dart                                 # Modified with MultiProvider inclusion
```

### Provider Integration (`main.dart`)

```dart
void main() {
  // Initialize Supabase client constants at compile time
  const supabaseUrl = String.fromEnvironment('SUPERABASE_URL', defaultValue: '');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  runApp(GolfieApp(supabaseUrl: supabaseUrl, anonKey: anonKey));
}

class GolfieApp extends StatelessWidget {
  final String supabaseUrl;
  final String anonKey;

  const GolfieApp({super.key, required this.supabaseUrl, required this.anonKey});

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
        Provider<BeritaRepository>(
          create: (_) => const _ResolveBeritaRepository()(),
        ),
        ChangeNotifierProxyProvider<BeritaRepository,
            ChangesNotifierBeritaProvider>(
          create: (ctx) => ChangesNotifierBeritaProvider(
            repository: ctx.read<BeritaRepository>(),
          ),
          update: (_, repo, prev) => prev ?? ChangesNotifierBeritaProvider(repository: repo),
        ),
        // NEW: Auth provider — wraps Supabase auth state
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            SupabaseClient(supabaseUrl, anonKey)
              ..init()
              ..setupStream(),
          ),
        ),
        // NEW: Onboarding provider — tracks step progress
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider()..loadSavedState(),
        ),
      ],
      child: MaterialApp(
        title: 'Golfie',
        debugShowCheckedModeBanner: false,
        theme: GolfieTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}
```

## Component Specifications

### Auth Provider (`features/auth/providers/auth_provider.dart`)

State model:

```dart
class AuthProvider with ChangeNotifier {
  final SupabaseClient _client;
  User? _user;
  bool _loading = true;
  bool _hasError = false;
  String? _errorMessages;

  bool get loading => _loading;
  User? get user => _user;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessages;

  AuthProvider(this._client);

  // Initialize on startup — load session from secure storage
  Future<void> init() async {
    try {
      final session = await _client.auth.getSession();
      _user = session?.user;
    } catch (e) {
      _user = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Listen to auth state stream for real-time updates
  void setupStream() {
    _client.auth.stateStream.listen((state) {
      _user = _client.auth.currentUser;
      _loading = false;
      _hasError = false;
      notifyListeners();
    });
  }

  // Sign up new user
  Future<void> signUp({required String email, required String password}) async {
    _loading = true; _hasError = false; notifyListeners();
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      _user = _client.auth.currentUser;
    } catch (e) {
      _hasError = true;
      _errorMessages = _handleSupabaseError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Login
  Future<void> signIn({required String email, required String password}) async {
    _loading = true; _hasError = false; notifyListeners();
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      _user = _client.auth.currentUser;
    } catch (e) {
      _hasError = true;
      _errorMessages = _handleSupabaseError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Logout + clear secure storage
  Future<void> signOut() async {
    await _client.auth.signOut();
    await SecureStorage.clear();
    _user = null;
    _loading = false;
    _hasError = false;
    notifyListeners();
  }

  // Password reset request
  Future<void> forgotPassword(String email) async {
    try {
      await _client.api.sendOtp(email: email);
    } catch (e) {
      _errorMessages = 'Could not send reset link. Try again.';
      _hasError = true;
      notifyListeners();
    }
  }

  // Reset password
  Future<void> resetPassword({required String email, required String newPassword}) async {
    _loading = true; notifyListeners();
    try {
      await _client.auth.updateUser(email: email, password: newPassword);
      _user = _client.auth.currentUser;
    } catch (e) {
      _hasError = true;
      _errorMessages = _handleSupabaseError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String _handleSupabaseError(dynamic e) {
    if (e is SupabaseAuthException) {
      switch (e.code) {
        case 'invalid_credentials':
          return 'Invalid email or password.';
        case 'email_exists':
          return 'Account with this email already exists.';
        case 'not_found':
          return 'No account with this email.';
        default:
          return e.message ?? 'Something went wrong.';
      }
    }
    return 'Network error. Please try again.';
  }
}
```

### Splash Screen (`features/auth/screens/splash_screen.dart`)

Purpose: Check auth status immediately on app launch, then route appropriately. No user interaction allowed.

UI composition:
- Background: `GolfieColors.canvas` (#fff3e7)
- Centered: `GolfieHero` component with subtle sky gradient texture
- Loading indicator beneath logo: fast-spinning circular indeterminate indicator (perceived performance principle)
- Typography: `GolfieTypography.display` or `heading-lg` — "Golfie" brand in UntitledSerifFont
- Shadow: multi-layered `--shadow-xl` under any floating card-like element

Logic:

```dart
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final onboard = context.watch<OnboardingProvider>();

    if (auth.loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(GolfieColors.graphite))),
      );
    }

    // Decision made here based on auth + onboarding state
    if (auth.user == null) {
      // No logged-in user → go to login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else if (!onboard.completed) {
      // Authenticated but onboarding incomplete → start onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingWelcomeScreen()),
      );
    } else {
      // Authenticated + onboarding done → go home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }

    // Keep screen visible during decision (briefly)
    return const SizedBox();
  }
}
```

Login Screen (`features/auth/screens/login_screen.dart`):

- Card container: white background, 24px radius, multi-layered shadow, 24px padding
- Headline: "Welcome back" — UntitledSerifFont 46px, Ink color, tracking -1.38px
- Subheading: "Sign in to your account" — UntitledSansFont 16px, Graphite color
- Email TextFormField: Ash border, 14px radius, Ink placeholder, validate email format on blur
- Password TextFormField: same as email, with reveal toggle icon revealing hidden text
- Forgot Password link: Graphite color, underline on hover (desktop), navigates to forgot screen
- Submit button: `GolfiePillButton` style — Ink background, White text, StadiumBorder, haptic feedback on press via `InkResponse` with scale 0.97 active transform
- Progress indication: small text at bottom "Don't have an account? Create one" linking to signup

Signup Screen: similar structure, headline "Create your Golfie account", confirm password field (optional UX choice), submit button labeled "Get Started" which routes to onboarding after successful registration.

Forgot Password Screen: single email input field, "Send Reset Link" pill button. On success show toast: "Check your inbox for reset instructions." Button to return to login.

Reset Password Screen: new password field, confirm password field, "Reset Password" button. On success auto-login and redirect to onboarding.

### Onboarding Provider (`features/onboarding/providers/onboarding_provider.dart`)

Tracks step progression, collects user data, persists to `shared_preferences`:

```dart
class OnboardingProvider with ChangeNotifier {
  int _currentStep = 0; // 0=welcome, 1=profile, 2=skill, 3=preferences, 4=complete
  bool _completed = false;
  String? _userName;
  SkillLevel? _skillLevel;
  String? _location;
  bool _showNearby = true;
  bool _emailNotifications = true;

  int get currentStep => _currentStep;
  bool get completed => _completed;
  String? get userName => _userName;
  SkillLevel? get skillLevel => _skillLevel;
  String? get location => _location;

  OnboardingProvider() {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final store = SharedPrefs.instance;
    _currentStep = store.getInt('onboarding_step') ?? 0;
    _userName = store.getString('onboarding_name');
    _skillLevel = SkillLevel.values.byName(store.getString('onboarding_skill') ?? 'beginner');
    _location = store.getString('onboarding_location');
    _showNearby = store.getBool('on_nearby') ?? true;
    _emailNotifications = store.getBool('on_email_notifs') ?? true;
    _completed = store.getBool('onboarding_completed') ?? false;
  }

  void _saveToPrefs() {
    final store = SharedPrefs.instance;
    store.setInt('onboarding_step', _currentStep);
    if (_userName != null) store.setString('onboarding_name', _userName!);
    if (_skillLevel != null) store.setString('onboarding_skill', _skillLevel!.name);
    if (_location != null) store.setString('onboarding_location', _location!);
    store.setBool('on_nearby', _showNearby);
    store.setBool('on_email_notifs', _emailNotifications);
    store.setBool('onboarding_completed', _completed);
    notifyListeners();
  }

  void nextStep() {
    if (!_completed && _currentStep < 3) {
      _currentStep++;
      _saveToPrefs();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _saveToPrefs();
    }
  }

  void setProfileInfo({required String name, required SkillLevel level}) {
    _userName = name;
    _skillLevel = level;
    nextStep();
  }

  void setLocation(String loc) {
    _location = loc;
    nextStep();
  }

  void setPreferences({required bool nearby, required bool emails}) {
    _showNearby = nearby;
    _emailNotifications = emails;
    // Proceed to completion after preferences
    completeOnboarding();
  }

  void completeOnboarding() {
    if (!_completed) {
      _completed = true;
      _saveToPrefs();
      // Notify auth provider to update user metadata if needed later
      notifyListeners();
    }
  }

  void reset() {
    _currentStep = 0;
    _userName = null;
    _skillLevel = null;
    _location = null;
    _completed = false;
    _saveToPrefs();
  }
}
```

### Onboarding Screens

All onboarding screens follow Golfie design: canvas background, centered card with shadow, progressive header showing step number (e.g., "Step 2 of 4"), horizontal progress indicator at bottom with mint-styled completed dots, Ink headings, UntitlesSans body text, pill buttons with ink fill.

#### Onboarding Welcome (`features/onboarding/screens/onboarding_welcome.dart`)

- Hero section: `GolfieHero` with mint pastel collage shape overlay subtle background decoration
- Headline: "Play like a pro" — UntitledSerifFont 56px, Ink, tracking -2.24px
- Body: "Discover and join local golf tournaments in Jakarta. Share your journey. Get started?" — UntitledSansFont 16px, Stone color, paragraph spacing
- CTA Button: `GolfiePillButton` "Get Started" → `onboardingProvider.nextStep()` → navigate to profile
- Bottom progress indicator: dot pattern, first dot filled, rest gray (Ash or Stone)
- Motion: slide-in from right on enter (viaPageRoute animation), staggered appearance of hero elements by 30ms each

#### Onboarding Profile (`features/onboarding/screens/onboarding_profile.dart`)

- Input field: "Your name" — Textcontroller, minimum 2 chars, enabled submit only when valid
- Avatar upload: `GolfieAvatarStack` circular component showing default placeholder initially, tapping opens image picker (gallery/camera), selects saved URL or binary
- Next Button: pill style, disabled until name entered (at least 2 chars), enables once condition met
- Motion: form fields fade in with staggered delays (0ms, 30ms, 60m); button scales 0.97 on active ink ripple effect
- Error handling: if name too short, shake animation + inline error message below field

#### Onboarding Skill (`features/onboarding/screens/onboarding_skill.dart`)

- Header: "What's your skill level?" — UntitledSansFont 24px, subheading weight, tracking -0.72px
- Selection grid: 3-column layout (mobile) or row (tablet) with selectable cards
  - Each card: icon (🏂 ⛳ 🥇), label ("Beginner", "Intermediate", "Advanced"), mint accent border when selected
  - Selected state: mint stroke background (#9bd8a9 at 10% opacity), border color mint
- Next Button: disabled until selection made, enables instantly on tap
- Data: stores selected `SkillLevel` enum value matching existing `tournament/models/skill_level.dart`
- Animation: cards pop in with scale(0.95) → 1.0 over 200ms ease-out on entry, staggered per item

#### Onboarding Preferences (`features/onboarding/screens/onboarding_preferences.dart`)

- Location search: TextField with autocomplete suggestions (debounced 300ms), magnifying glass icon leading, chip-style selected location tag above field
- Toggle switches:
  - "Show me nearby tournaments" — switch, default true, uses Golfie-styled toggle (mint accent when on)
  - "Email notifications for new tournaments" — switch, default true
- Finish Button: `GolfiePillButton` "Finish Setup" — triggers `onboardingProvider.completeOnboarding()`, routes to HomeScreen on completion
- Progress indicator: all 4 dots filled, last one mint green

### Progress Indicator Widget (`features/onboarding/widgets/progress_indicator.dart`)

Horizontal stepper at bottom of every onboarding screen:

```dart
class ProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const ProgressIndicator({super.key, required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          final bool isCompleted = index < currentStep;
          final bool isCurrent = index == currentStep;
          Color dotColor;
          if (isCurrent) dotColor = GolfieColors.ink;
          else if (isCompleted) dotColor = GolfieColors.mint;
          else dotColor = GolfieColors.ash;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 12, height: 12,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
```

Styled with minimal spacing, no distracting borders — subtle visual rhythm only.

## Navigation Flow Details

### Route Configuration (`main.dart`)

```dart
MaterialApp(
  // ...
  initialRoute: '/splash',
  routes: {
    '/splash': (__) => const SplashScreen(),
    '/login': (__) => const LoginScreen(),
    '/signup': (__) => const SignupScreen(),
    '/forgot': (__) => const ForgotPasswordScreen(),
    '/reset': (__) => const ResetPasswordScreen(),
    '/onboarding/welcome': (__) => const OnboardingWelcomeScreen(),
    '/onboarding/profile': (__) => const OnboardingProfileScreen(),
    '/onboarding/skill': (__) => const OnboardingSkillScreen(),
    '/onboarding/preferences': (__) => const OnboardingPreferencesScreen(),
    '/home': (__) => const HomeScreen(),
  },
  // Page builders for consistent transition animations
  pageBuilder: (context, animation, description, child) {
    // Respects reduced motion per Emil principle
    if (MediaQuery.of(context).reduceMotion != ReduceMotion.none) {
      return FadeTransition(opacity: animation, child: child!);
    }
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: child!,
      ),
    );
  },
)
```

### State Propagation Rules

1. **Splash Screen** reads `AuthProvider.loading` and `AuthProvider.user` — no business logic, just routing decision
2. **Auth screens** consume `AuthProvider` directly via `context.watch` or `Consumer` — call methods on button press, listen to loading/error states for UI feedback
3. **Onboarding screens** consume `OnboardingProvider` — read current step, collect data, call `nextStep()` / `setProfileInfo()` / etc.
4. **HomeScreen** remains unchanged — after auth/onboarding complete, user arrives at existing home screen (which may need an AuthGuard wrapper for future protected routes)
5. **Provider tree**: Both `AuthProvider` and `OnboardingProvider` are `ChangeNotifierProvider` siblings at root level — they don't depend on each other directly but may share data (e.g., onboarding could notify auth to update Supabase user metadata on completion)

## Error Handling & Edge Cases (Invisible Correctness)

### Auth Errors

| Error Type | Detection | Recovery Path | UI Pattern |
|------------|-----------|---------------|------------|
| Network loss | try/catch around all API calls | Snackbar retry hint; auto-retry on connection restore (Flutter connectivity package listener) | Non-blocking toast at bottom |
| Invalid credentials | Supabase error code `invalid_credentials` | Show generic message; allow re-entry | Inline field-specific error on blur |
| Email exists | `email_exists` error | Redirect to login with suggestion | Toast informing user of existing account |
| Session expired | Auth stream emits `logout` event | Clear storage, redirect to login, optional toast "Session expired" | Silent redirect with subtle toast |
| Unverified email | Check `user.emailVerified` after sign-in | Show verification reminder screen with resend option | CTA button "Resend verification email" |

### Onboarding Edge Cases

- **Mid-flow exit**: App killed while onboarding — SharedPreferences already persisted on each step change; resume picks up at last saved step
- **Back navigation**: Users can tap back button or use `previousStep()` to revisit prior screens; form data retained in provider (no re-entry needed)
- **Data cancellation**: Avatar upload aborted — keep previous selection or use default; name cleared if backtailed without save — partial state preserved for resumption
- **Concurrent modifications**: If multiple rapid `nextStep()` calls happen, throttling via simple flag prevents out-of-bounds step increments; `notifyListeners()` called once per batch commit
- **Race condition between auth and onboarding**: Splash screen checks both providers sequentially; if auth resolves slower than expected, splash stays in loading state until both queries complete

### Accessibility & Motion Respect

```dart
// In route pageBuilder and wherever transitions are used
bool shouldAnimate = MediaQuery.of(context).reduceMotion == ReduceMotion.none;

if (!shouldAnimate) {
  // Use FadeTransition or no animation at all
  return FadeTransition(opacity: Tween<double>.begin(0).end(1).animate(controller), child: child);
}
// Otherwise use SlideTransition with standard duration (~250ms)
```

All focusable elements support keyboard traversal (Tab order logical left-to-right, top-to-bottom), semantic labels for screen readers contrast ratios meet WCAG AA standards (Ink on Canvas: ~12:1, Graphite on Canvas: ~7:1).

## Testing Strategy

### Test File Organization

Matches production structure:

```
test/features/auth/
  providers/auth_provider_test.dart     # Unit tests
  screens/login_smoke_test.dart         # Widget test
  signup_interactive_test.dart          # Manual integration-style
test/features/onboarding/
  providers/onboarding_provider_test.dart
  screens/*.dart
test/integration/auth_onboarding_flow_test.dart
```

### Critical Test Scenarios

**Unit Tests:**
- `AuthProvider.init()` loads session correctly from mocked secure storage
- `AuthProvider.signUp()` calls underlying client with correct params
- `AuthProvider.signIn()` handles both success and error cases
- `OnboardingProvider.nextStep()` increments step, maxes at 3, persists to shared prefs
- `OnboardingProvider.loadSavedState()` restores values from mock prefs

**Widget Tests:**
- LoginScreen renders without exception
- Email field accepts input, validates on blur
- Submit button disabled until both fields valid
- Tap on forgot navigates to ForgotPasswordScreen
- OnboardingProfileScreen shows avatar picker widget, saves name on next
- OnboardingSkillScreen displays three selectable cards, tracks selection

**Integration Test (full flow):**
1. Launch app → splash screen appears briefly
2. Navigate to login screen (auto-route from splash)
3. Enter credentials → tap login → spinner shows → success → onboarding welcome appears
4. Tap "Get Started" → progress to profile step
5. Enter name "Alex", select beginner skill → advance
6. Choose skill level Advanced → proceed
7. Set location "Senayan", enable nearby + email notifications → finish
8. Verify route changes to HomeScreen
9. Verify onboarding provider marks completed = true
10. Restart app → splash skips to HomeScreen directly (no onboarding shown)

### CI Pipeline

Every PR executes:

```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test --coverage test/features/           # unit + widget
flutter integration_test test/integration/       # against emulator snapshot
```

Coverage target: 80%+ for `features/auth/` and `features/onboarding/` directory files.

## Dependencies & Package Additions

Add to `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.0.0       # Auth client + session management
  flutter_secure_storage: ^9.0.0 # Persistent token storage
  shared_preferences: ^2.2.0     # Onboarding step persistence
  image_picker: ^1.0.0           # Avatar upload
  connectivity_plus: ^5.0.0      # Network availability detection
  fluttertoast: ^8.2.4           # Snack/toast notifications
  pin_code_text_field: ^3.1.0    # Optional: for email OTP if added later

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4                # Mocking for tests
  mocktail: ^1.0.0               # Alternative mocking style
  shared_preferences_mocked: ^3.0.0 # Mock for shared prefs in unit tests
  provider_test: ^3.0.0          # Provider widget testing helpers
```

## Implementation Roadmap (High-Level)

1. **Setup**: Add dependencies, configure Supabase project, add env vars to build arguments
2. **Core infrastructure**: Create `features/auth/widgets/supabase_wrapper.dart`, initialize client in `main.dart`
3. **AuthProvider**: Implement state management, session loading, auth method wrappers
4. **Splash screen**: Auth check + routing logic
5. **Auth screens**: Login, signup, forgot, reset — implement following Golfie design tokens
6. **OnboardingProvider**: Step tracking, persistence logic, data model
7. **Onboarding screens**: Welcome, profile, skill, preferences — build progressively
8. **Progress indicator**: Shared widget across onboarding steps
9. **Testing**: Write unit tests for providers, widget tests for screens, integration test for full flow
10. **Polish**: Review against Golfie DESIGN.md checklist, ensure motion accessibility, verify all edge cases handled
11. **Review**: Code review, merge, deploy to test devices

## Design Self-Review Checklist

- [ ] All sections clear, no TBD placeholders
- [ ] Architecture matches existing project patterns (berita/, tournament/)
- [ ] Components specified with exact DESIGN.md token references (colors, fonts, radii)
- [ ] Data flow explicit, provider relationships clear
- [ ] Error handling comprehensive, security considerations noted
- [ ] Testing strategy mirrors production structure, covers critical paths
- [ ] Emil Kowalski principles incorporated (transitions over keyframes, under-300ms motion, scale on active, reduced motion respect)
- [ ] No contradictions between sections
- [ ] Scope focused on auth + onboarding only, not full app redesign

Design validated and ready for implementation planning.