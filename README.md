# KBVS Golf — Flutter Project Setup Complete

**Status:** Flutter SDK installed, project structure created, ready for Android/iOS toolchain installation.

## Current State

✅ Flutter 3.44.8 (stable) installed at `/home/kiyaya/tools/flutter`  
✅ Project skeleton at `/home/kiyaya/kiyadev/kbvs-golf/`  
✅ `pubspec.yaml` with all declared dependencies  
✅ Dart core files: `lib/main.dart`, `lib/providers/app_state.dart`, `lib/screens/home_screen.dart`  
✅ Emil Kowalski design skill loaded (`emil-kowalski-design-skills`)  

## Missing Toolchains

The following are NOT installed yet (required for mobile builds):

| Tool | Purpose | How to install |
|------|---------|----------------|
| Android SDK + JDK | Build & run on Android devices | `flutter doctor --android-licenses` after installing Android Studio or command-line tools |
| Xcode | iOS/macOS builds | On macOS only — not available on WSL |
| Chrome | Web development | `sudo apt install chrome-browser` (optional if targeting web) |
| clang / cmake / ninja | Linux desktop builds | `sudo apt install build-essential cmake ninja-build libgtk-3-dev` |

## Next Steps When Ready for Development

1. **Install Android tools** (choose one):

   Option A — Android Studio (full IDE):  
   ```bash
   # Install Android Studio, then in Studio:
   # Tools → SDK Manager → Install "Android SDK Command-line Tools"
   # Accept all licenses with: flutter doctor --android-licenses
   ```

   Option B — Lightweight command-line tools only:  
   ```bash
   sudo apt install android-sdk
   sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   export ANDROID_HOME=$HOME/android/cmd-tools/latest
   flutter config --android-sdk $HOME/android/cmd-tools/latest
   flutter doctor --android-licenses
   ```

2. **Run Flutter doctor to verify**:
   ```bash
   export PATH="$PATH:/home/kiyaya/tools/flutter/bin"
   flutter doctor --verbose
   ```

3. **Get dependencies & run**:
   ```bash
   cd /home/kiyaya/kiyadev/kbvs-golf
   flutter pub get
   flutter run # or flutter run -d <device>
   ```

## Project Structure

```
kbvs-golf/
├── pubspec.yaml          # Dependencies, app metadata
├── lib/
│   ├── main.dart         # Entry point
│   ├── providers/        # State (AppState, etc.)
│   │   └── app_state.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── analysis_screen.dart   # AI caddy tips placeholder
│   ├── core/             # Constants, enums, themes (empty — expand as needed)
│   ├── services/         # API, local DB, analytics (empty)
│   ├── widgets/          # Reusable UI components (empty)
│   ├── models/           # Data models (empty)
│   └── utils/            # Helper functions (empty)
└── android/              # Android platform config (minimal)
```

## Design Framework

Emil Kowalski design skill is loaded:
- Location: `~/.hermes/skills/emil-kowalski-design-skills/`
- Contains: All 8 modules (animation-vocabulary, apple-design, emil-design-eng, find-animation-opportunities, improve-animations, pick-ui-library, prototype, review-animations)
- Used in: KBVS Golf PRD visual direction (§9), mapping Apple baseline + animation principles

Voice target: terse, opinionated, concrete — no throat-clearing, no hedging, no empty buzzwords. See `PRD_Stakeholder.md` for reference style.
