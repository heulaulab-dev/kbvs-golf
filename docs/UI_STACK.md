# KBVS Golf – Flutter UI Library Stack Recommendation

**Scope:** Build a modern, Gen Z–friendly Flutter app focused on Jakarta golf tournaments. Based on the visual direction in `docs/backlog/VISUAL_DIRECTION.md` (design reference, not yet implemented).  
**Target Flutter version:** 3.x+ (Material 3 enabled)  

---

## 🏆 Final Stack Summary

| Category | Package | Version | Why (one-sentence pick) |
|----------|---------|---------|------------------------|
| Theming | **Material 3 (built-in)** | Flutter 3.x+ | Zero deps, built-in light/dark + dynamic color, token system matches Apple aesthetic |
| Cards | **Material 3 `Card`** | Flutter 3.x+ | Shape/elevation customizable → exactly 16px radius + subtle shadow |
| Buttons | **Material 3 buttons + `InkWell`** | Flutter 3.x+ | Native `Elevated/Outlined/TextButton`, wrap for scale-down press (~0.96) |
| Haptics | **Built-in `HapticFeedback`** | Flutter 3.x+ | No dependency; `.lightImpact()`, `.mediumImpact()` work on iOS/Android |
| Animations | **Core animation classes** | Flutter 3.x+ | `SpringSimulation`, `CurvedAnimation`, `AnimatedSwitcher`, `Hero` — all native |
| Lottie | **`lottie`** | `^3.2.0` | JSON animations (golf swing, ball-drop, badge burst); industry standard |
| Maps | **`google_maps_flutter`** | `^2.6.0` | Official Google plugin, stable course-location rendering |
| Pull-to-refresh | **`pull_to_refresh`** | `^2.0.0` | Easy custom `RefreshIndicator` wrapper with branded pull animation |
| Icons | **Material/Cupertino + `flutter_feather_icons`** | `^2.0.1+1` | Feather SVG icons are lightweight, single-stroke, fits Gen Z minimalism |
| Avatar stacks | **Custom `Stack` + `ClipOval`** | Flutter 3.x+ | Zero deps, overlapping avatars with count badge in ~5 lines |
| Navigation | **`go_router`** | `^12.0.0+` | Declarative, clean, integrates well with Material 3 bottom nav |

**Total new dependencies:** 4 (`lottie`, `google_maps_flutter`, `pull_to_refresh`, `flutter_feather_icons`) + `go_router` (already committed via earlier stack decision).

---

## 1. Theming / Design System

**Pick:** Use Material 3 built into Flutter. Enable it with:

```dart
ThemeData.useMaterial3 = true;
```

- Provides dynamic color theming, light/dark modes automatically paired, typography scales, spacing units — all zero-dependency.
- Customize tokens to match the `docs/backlog/VISUAL_DIRECTION.md` palette:

```dart
 ThemeData(
   useMaterial3: true,
   colorScheme: ColorScheme.fromSeed(
     seedColor: const Color(0xFF2D7A5C), // golf-green-600
     brightness: Brightness.light,
   ),
   darkColorScheme: ColorScheme.fromSeed(
     seedColor: const Color(0xFF2D7A5C),
     brightness: Brightness.dark,
   ),
   textTheme: GoogleFonts.interTextTheme(), // require google_fonts package
   cardTheme: CardTheme(
     elevation: 0,
     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
   ),
   scaffoldBackgroundColor: Colors.white,
 }
```

- When NOT to use: if you need a component-level copy-paste design system like React's Radix/shadcn for Flutter-specific component granularity (most of Material 3 already covers this).

**Optional addition for Inter font:** add `google_fonts: ^6.0.0` (self-host Inter via Google Fonts CDN bundle).

---

## 2. Card Components

**Pick:** Native `Card` with custom shape and elevation.

```dart
Card(
  elevation: 4, // produces 0–4px shadow spread → approx 0 4px 12px total
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: YourCardContent(),
  ),
)
```

- Works perfectly inside `ListView.builder`, `GridView`, or individual detail screens.
- For animated hover/focus states, wrap in `InkWell` or `GestureDetector` with `Transform.scale` on press.

---

## 3. Buttons

**Pick:** Material 3 button types, wrapped in `InkWell` for scale-down press state.

```dart
// Primary button with scale feedback
InkWell(
  onTap: () {},
  splashColor: Colors.transparent,
  radius: 40,
  child: Transform.scale(
    scale: _pressed ? 0.96 : 1.0,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF2D7A5C), // golf-green-600
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: const Text('Register'),
    ),
  ),
  onHighlightChanged: (v) => setState(() => _pressed = v),
)

// Secondary (outlined) button
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: const BorderSide(color: Color(0xFF2D7A5C), width: 1.5),
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.circular(12),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  ),
  child: const Text('View Details'),
  onPressed: () {},
)
```

---

## 4. Bottom Navigation (5 tabs)

**Pick:** Material 3 `NavigationBar` natively supports exactly 5 destinations. Add haptic feedback on selection:

```dart
NavigationBar(
  labelMode: NavigationBarLabelMode.label,
  destinations: const [
    NavigationDestination(
      icon: Icon(FeatherIcon.golf_ball),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(FeatherIcon.trophy),
      label: 'Tournaments',
    ),
    NavigationDestination(
      icon: Icon(FeatherIcon.map),
      label: 'Courses',
    ),
    NavigationDestination(
      icon: Icon(FeatherIcon.users),
      label: 'Players',
    ),
    NavigationDestination(
      icon: Icon(FeatherIcon.settings),
      label: 'More',
    ),
  ],
  onDestinationSelected: (index) {
    HapticFeedback.mediumImpact();
    // navigate per go_router logic
    _currentIndex = index;
  },
  currentIndex: _currentIndex,
  selectedIndex: 0,
)
```

---

## 5. Haptic Feedback

**Pick:** Built-in `HapticFeedback`. No extra dependency needed.

```dart
HapticFeedback.lightImpact();        // button taps, list selections
HapticFeedback.mediumImpact();      // nav selection, serious actions
HapticFeedback.successNotification(); // registration success, achievement
```

Works on both iOS and Android without extra setup.

---

## 6. Animations & Micro-interactions

**Pick:** Core Flutter animation classes + `lottie` for complex editorial assets.

### Spring physics (button press, card lift):

```dart
Tween<double>(begin: 1.0, end: 0.96).animate(
  CurvedAnimation(
    parent: _animationController,
    curve: SpringSimulation(
      const spring.Tension(0.8) & Frequency(0.8), // simplistic config
      0.0,
      1.0,
      0.5,
    ),
  ),
),
```

For production-quality springs, use `spring_dart` package or simply rely on `MaterialStateProperty` ripple which uses built-in physics.

### Page transitions with `AnimatedSwitcher`:

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 250),
  transitionBuilder: (child, anim) => FadeTransition(
    opacity: anim,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0.0),
        end: Offset.zero,
      ).animate(anim),
      child: child,
    ),
  ),
  child: KeyedSubtree(
    key: ValueKey<int>(currentIndex),
    child: routeBuilder(currentIndex),
  ),
)
```

### Complex motions (Lottie):

Use the `lottie` package for exported `.json` files from After Effects (golf swing, ball drop, badge unlock burst). Example:

```dart
Lottie.asset('assets/lotties/golf-swing.json', width: 200, height: 200, repeat: false, fit: BoxFit.contain)
```

Get free/paid golf-themed Lottie animations from LottieFiles.com or create simple ones with Lottie for Figma.

---

## 7. Lottie Support

**Package:** `lottie: ^3.2.0`

- Industry standard, loads any Adobe After Effects JSON export.
- Supports looping, progress control, nested composition playback.
- Minimal code, huge payoff for celebratory moments (tournament registered, badge unlocked).

**Asset structure tip:** Keep Lottie JSONs under `assets/lotties/` and reference in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/lotties/
```

**When NOT to use lottie:** If you need vectors that respond to user input procedurally (e.g., interactive charts, game-like physics-driven motion), then `rive` is better. For our case, editorial animations only → lottie wins.

---

## 8. Google Maps Integration

**Package:** `google_maps_flutter: ^2.6.0`

Official Google plugin, stable, handles map tiles, markers, polygons, camera positioning, permissions.

**Basic usage:**

```dart
GoogleMap(
  initialCameraPosition: const CameraPosition(
    target: LatLng(-6.2088, 106.8456), // example Jakarta coord
    zoom: 13,
  ),
  onMapCreated: (controller) => _mapController = controller,
  markers: {
    Marker(
      markerId: MarkerId('course_1'),
      position: const LatLng(-6.2088, 106.8456),
      infoWindow: InfoWindow(title: 'Emeralda Golf Club', snippet: 'Jakarta'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ),
  },
)
```

**Add to platform files:**
- Android: add `<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY"/>` in `AndroidManifest.xml`
- iOS: add `LSApplicationQueriesSchemes` for `maps-app` and `google-maps` if deep-linking, plus API key in `Info.plist`

---

## 9. Pull-to-Refresh with Branded Indicator

**Package:** `pull_to_refresh: ^2.0.0`

Wraps `RefreshIndicator` easily, allows custom builder for animated branded refresh UI (golf ball bounce, spring animation).

**Simple approach (native + override):**

```dart
RefreshIndicator(
  onRefresh: fetchTournamentsAsync,
  color: const Color(0xFFE85D2C), // competition-orange for branding
  backgroundColor: Colors.white,
  child: ListView.builder(...),
)
```

For a truly custom pull indicator (e.g., golf ball swinging as you pull down), wrap the whole thing in a custom `NotificationListener<ScrollNotification>` and build your own widget atop the native RefreshIndicator. That extra layer is where the `pull_to_refresh` package shines with its `RefreshController` and event hooks.

---

## 10. Iconography

**Pick:** Mix of Material Icons, Cupertinos, plus `flutter_feather_icons: ^2.0.1+1` for custom/sport-specific icons.

Why Feather? Single-stroke SVG, ~4KB total bundle, ultra clean line weight, designed for minimalist modern interfaces. Perfect for Gen Z aesthetic.

Usage:

```dart
Icon(FeatherIcon.golf_ball, size: 20, color: Colors.black87)
Icon(FeatherIcon.trophy, size: 20, color: Colors.black87)
Icon(FeatherIcon.map, size: 20, color: Colors.black87)
Icon(FeatherIcon.users, size: 20, color: Colors.black87)
Icon(FeatherIcon.settings, size: 20, color: Colors.black87)
Icon(FeatherIcon.flag, size: 16, color: Color(0xFFE85D2C)) // competition-orange accent
```

For golf-specific icons not available in Feather (club, ball-on-green, scorecard), create lightweight SVG exports and import via `flutter_svg` — but start with Feather and fill gaps only as needed.

---

## 11. Avatar Stacks (Player Counts in Tournament Cards)

**Pick:** Custom `Stack` with `ClipOval` + offset positioning. No third-party lib needed.

```dart
Stack(
  alignment: Alignment.centerRight,
  children: List.generate(3, (i) => Positioned(
        left: -i * 20, // overlap by 20px each
        child: ClipOval(
          child: Image.network(
            avatarUrls[i],
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
      )),
  child: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Color(0xFFE85D2C), // competition-orange bg
    ),
    width: 48,
    height: 48,
    alignment: Alignment.center,
    child: const Text(
      '+2',
      style: TextStyle(color: white, fontSize: 12, fontWeight: FontWeight.bold),
    ),
  ),
)
```

For more than 3 players, show "X more" in the count container. This pattern appears frequently in tournament cards from the visual spec.

---

## 12. Dependency Block (ready to paste into pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP client & auth
  dio: ^5.4.0
  oauth2: ^2.0.5
  flutter_secure_storage: ^9.0.0

  # Routing
  go_router: ^12.0.0

  # UI / Icons
  flutter_feather_icons: ^2.0.1
  google_fonts: ^6.0.0

  # Animation / Media
  lottie: ^3.2.0
  google_maps_flutter: ^2.6.0

  # UI utilities
  pull_to_refresh: ^2.0.0
  flutter_cache_manager: ^3.3.0 # optional: network image caching

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

Run `flutter pub get` after adding.

---

## 13. Tradeoffs Summary (why these picks over alternatives)

| Chosen | Why we picked it | Alternative considered | Rejection reason |
|--------|------------------|-----------------------|------------------|
| Material 3 theme | Zero deps, Apple-aligned, full dark mode | `FlexColorScheme` | Overkill, adds ~500KB binary for minimal gain |
| Native `Card` | Already customizable, same look | `shadcn-flutter` | Immature, requires manual component copying |
| `InkWell` + `Transform.scale` | Scale-down press without extra libs | `surf` or `material_design_components` | Too many variants we don't need |
| Built-in `HapticFeedback` | Works out of box | `flutter_haptic_feedback` | Extra dep for edge-case patterns we won't trigger |
| Core + `lottie` animations | Full physics control + asset support | `rive` | Rive needs interactive/vector-heavy scenarios we don't have |
| `lottie` | Mature, easy AE workflow | `flutter_lottie` | Fewer updates, lower download count |
| `google_maps_flutter` | Official, battle-tested | `mapbox_gl` | Mapbox key + plan unnecessary for basic location markers |
| `pull_to_refresh` | Easy wrapper, customizable builder | Custom `NotificationListener` | More code for same outcome; `pull_to_refresh` handles edge cases |
| `flutter_feather_icons` | Lightweight, crisp SVGs, matches aesthetic | `flutter_svg` + hand-drawn icons | Manage hundreds of SVGs manually would be painful |
| Custom avatar stack | Zero dependency, fully controlled | `avatar_group` | Adds dependency for a trivial `Stack` composition |

---

## 14. What We Deliberately Didn't Recommend

- **`shadcn-flutter`** — Inspired by React's shadcn/ui, still immature, requires manual component copying, no clear value over Material 3 for a golf-focused app.
- **`flex_color_scheme`** — Powerful theming library, but Material 3 provides color schemes, dark mode, typography without extra bloat. Add only if you discover specific theming gaps.
- **`flutter_haptic_feedback`** — Only needed for custom vibration sequences beyond light/medium impact. Our use cases (button taps, selections, success notifications) are covered by built-in `HapticFeedback`.
- **`rive` for complex animations** — Great for interactive/code-driven animated objects, but golf swing/ball-drop/badge-burst are best delivered as Lottie JSON from After Effects. Simpler workflow, smaller assets.
- **`auto_route` for navigation** — Project already committed to `go_router`; adding `auto_route` would duplicate routing logic, increase cognitive load, and complicate deep linking.
- **`cached_network_image` for avatars** — `Image.network` with default cache provider is sufficient for MVP. Introduce only if profiling shows memory/network pressure.
- **Liquid progress indicators, fancy sliders, parallax effects** — Not part of the visual spec. Keep stack focused on core requirements only.

---

## 15. Next Steps

1. Run `flutter create kbvs_golf` (or use existing project template)
2. Paste the dependency block above into `pubspec.yaml` and run `flutter pub get`
3. Create `lib/theme.dart` with Material 3 theme customization matching the `docs/backlog/VISUAL_DIRECTION.md` colors
4. Set up `go_router` routes matching the 5-tab bottom nav pattern
5. Prototype one tournament card using the recommended Card + Avatar + Button components
6. Implement a single Lottie animation (ball-drop or golf-swing) to verify the asset pipeline

That's the UI stack locked in, ready for implementation. Ship fast, iterate later.

---

*Last updated: 2026-07-28*  
*By: Hermes (Windah)*
