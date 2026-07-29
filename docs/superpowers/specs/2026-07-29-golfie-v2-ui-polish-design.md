# Golfie v2 — Full DESIGN.md Implementation

**Date:** 2026-07-29
**Status:** Approved
**Branch:** `revamp/golfie`
**Depends on:** v1 rebrand (commits through `3403774`)

## Context

The Golfie rebrand (v1) wired the DESIGN.md token system into `MaterialApp.theme` via `GolfieTheme.light()`. Every existing screen now inherits Canvas/Ink/Inter-Lora automatically. But v1 explicitly deferred:

- Custom widget library (pill button, collage card, hero, torn-paper section)
- Motion (press feedback, haptics, hero transitions, list state changes)
- Per-screen typography refactor (raw `TextStyle(...)` calls ignored the new theme)
- Collage backgrounds (subtle pastel blocks)

This spec implements all of the above to fully realize DESIGN.md on the existing screen set.

## Goals

1. A reusable Golfie widget library at `lib/widgets/golfie/` consumed by all screens.
2. Motion that rewards user input without being theatrical (Emil animation-vocabulary).
3. Every screen uses `Theme.of(context).textTheme.*` — no raw `TextStyle` for typography.
4. Subtle collage accents (pastel blocks, Periwinkle corners) — no torn-paper edges (mobile readability).
5. Selective widget testing — every new widget tested, screen typography refactor relies on existing tests.
6. 106 → ~116 tests; test-count marker stays accurate.

## Non-Goals

- No new screens, no new routes
- No dark mode (DESIGN.md is light-only)
- No Lottie animations (no assets exist)
- No `.ttf` font self-hosting (google_fonts runtime fetch is acceptable)
- No torn-paper edges anywhere (DESIGN.md "Collage Background Element" interpreted as subtle pastel blocks)
- No new business logic, no API changes

## Approach

Build the widget library + motion primitives first, then per-screen integration. Typography refactor runs in parallel with screen integrations because both touch the same files. Collage backgrounds layered last (visual polish).

Emil Kowalski skills applied as the review lens:
- `animation-vocabulary` — motion choices (durations, easings, what to animate)
- `apple-design` — interaction feedback (haptics only on primary)
- `emil-design-eng` — typography spacing + tracking
- `web-design-guidelines` — elevation matches content importance
- `review-animations` — every animation has a purpose

## Component Specs

### `GolfiePillButton`

```dart
enum GolfieButtonVariant { primary, secondary }

class GolfiePillButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;                    // typically Text or Row(icon, label)
  final GolfieButtonVariant variant;     // default primary
  final bool haptic;                     // default true (primary only); ignored on secondary
  final IconData? icon;                  // optional leading icon
}

class _GolfiePillButtonState extends State<GolfiePillButton> {
  double _scale = 1.0;

  // onTapDown: setState(_scale = 0.97); if (widget.haptic && widget.variant == primary)
  //            HapticFeedback.lightImpact();
  // onTapUp / onTapCancel: setState(_scale = 1.0)
  // AnimatedScale wraps child, duration: 100ms, curve: Curves.easeOutCubic
}

// primary: Ink bg, White text, StadiumBorder, padding EdgeInsets.symmetric(h: 24, v: 16)
// secondary: White bg, Ink text, Ash border, padding same
```

### `GolfieGhostButton`

Same shape as `GolfiePillButton` but always secondary semantics. No haptic. Lighter visual weight.

(Implementation: `GolfieGhostButton` is a thin alias that calls `GolfiePillButton(variant: secondary, haptic: false)`.)

### `GolfieCollageCard`

```dart
enum GolfieAccentCorner { topLeft, topRight, bottomLeft, bottomRight, none }

class GolfieCollageCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;          // default EdgeInsets.all(24)
  final GolfieAccentCorner accentCorner;    // default none
  final VoidCallback? onLongPress;           // optional
  final Clip clipBehavior;                  // default Clip.antiAlias
}

class _PeriwinkleAccent extends StatelessWidget {
  // 24x24 circle or rect, 12% opacity GolfieColors.periwinkle
  // positioned in the chosen corner with 16px inset
}

// Default shadow: GolfieShadows.xl (the multi-layered one from DESIGN.md Elevation)
// onLongPress → AnimatedContainer shadow md → xl, 200ms easeInOutCubic
```

### `GolfieHero`

```dart
class GolfieCollageBlock {
  final GolfieCollageShape shape;       // circle | rect
  final Color color;                    // any GolfieColors.* (caller responsible for choosing)
  final double opacity;                 // 0.0–1.0, expected ≤ 0.15
  final Alignment alignment;            // where to anchor
  final double size;                    // diameter (circle) or width×height handled in widget
  const GolfieCollageBlock({
    required this.shape,
    required this.color,
    required this.alignment,
    required this.size,
    this.opacity = 0.12,
  });
}

class GolfieHero extends StatelessWidget {
  final String headline;
  final String? subhead;
  final Widget? cta;
  final List<GolfieCollageBlock> collage;
  final double minHeight;                // default 280
  final EdgeInsetsGeometry padding;      // default EdgeInsets.symmetric(h: 24, v: 48)

  // Background: GolfieColors.skyGradient (full-bleed)
  // Stack: [collage blocks positioned absolutely] → [content centered]
  // headline uses Theme.of(context).textTheme.displayMedium (Lora, 56px)
  // subhead uses bodyLarge
  // cta slot for GolfiePillButton
}
```

### `GolfieTornPaperSection`

```dart
class GolfieTornPaperSection extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;      // default GolfieColors.canvas
  final double height;              // default 32

  // Renders child with backgroundColor, plus a CustomPaint at the top edge
  // that draws a subtle scalloped line (torn-paper hint) using Ash color
  // at 30% opacity, 1.5px stroke. NO actual torn edges — just a divider hint.
}
```

### `GolfieAvatarStack` (refactor of `lib/widgets/avatar_stack.dart`)

Move file to `lib/widgets/golfie/golfie_avatar_stack.dart`. Public API unchanged:
```dart
GolfieAvatarStack({
  required List<String> imageUrls,
  double avatarSize = 32,
  int maxVisible = 3,
})
```

Internal changes:
- Avatar border: `Colors.white` → `GolfieColors.canvas` (matches Scaffold bg)
- `+N` count badge: `Colors.grey` bg + White text → `GolfieColors.ink` bg + `GolfieColors.white` text
- Avatar size constant stays the same

### `GolfieEmptyState` (refactor of `lib/widgets/empty_state.dart`)

Move file to `lib/widgets/golfie/golfie_empty_state.dart`. Public API:
```dart
GolfieEmptyState({
  required String title,
  String? message,
  Widget? action,
  IconData? icon,
  bool showCollageAccent = false,    // default false
})
```

Internal changes:
- `title` uses `Theme.of(context).textTheme.headlineMedium` (Lora, 24px)
- `message` uses `bodyMedium` with `GolfieColors.graphite` color
- `action` slot accepts `GolfiePillButton` (or any widget)
- When `showCollageAccent`, render a small Periwinkle circle (16px, 12% opacity) in top-right

## Motion Choreography

| Trigger | Animation | Duration | Easing | Emil rationale |
|---|---|---|---|---|
| `GolfiePillButton` press | scale 1.0 → 0.97 | 100ms | easeOutCubic | "reward the tap instantly" |
| `GolfieCollageCard` long-press | shadow md → xl | 200ms | easeInOutCubic | "elevation matches content lift" |
| Tournament list loading → content | fade + 8px slide-up | 250ms | easeOutCubic | acknowledge state change |
| Berita list loading → content | fade + 8px slide-up | 250ms | easeOutCubic | same |
| Tournament list → detail | Flutter `Hero` flight | 300ms (Material default) | Material default | continuity |
| Search query cleared | fade content | 200ms | easeOutCubic | mirror reset pattern |

Motion is implemented with Flutter's built-in `AnimatedScale`, `AnimatedContainer`, `AnimatedSwitcher`, `Hero` widgets. No third-party motion library.

## Typography Mapping

| Existing raw pattern | Theme replacement |
|---|---|
| `TextStyle(fontSize: 24, fontWeight: FontWeight.bold)` | `Theme.of(context).textTheme.headlineMedium` |
| `TextStyle(fontSize: 20, fontWeight: FontWeight.w500)` | `Theme.of(context).textTheme.titleLarge` |
| `TextStyle(fontSize: 16, fontWeight: FontWeight.w500)` | `Theme.of(context).textTheme.labelLarge` |
| `TextStyle(fontSize: 16)` | `Theme.of(context).textTheme.bodyLarge` |
| `TextStyle(fontSize: 14)` | `Theme.of(context).textTheme.bodyMedium` |
| `TextStyle(fontSize: 12)` | `Theme.of(context).textTheme.bodySmall` |
| `TextStyle(color: Colors.grey)` (subdued text) | `bodyMedium.copyWith(color: GolfieColors.stone)` |
| Home hero headline | `Theme.of(context).textTheme.displayMedium` (56px Lora) |

## Collage Backgrounds

Only on:
- **Home screen** via `GolfieHero` — Mint circle top-right (60px, 12% opacity), Marigold rect bottom-left (80×40px, 10% opacity)
- **Tournament detail header** — Periwinkle 8px accent strip at top of screen
- **Empty states** (when `showCollageAccent: true`) — Periwinkle corner circle

No torn-paper edges anywhere. Subtle pastel blocks honor the "Collage Background Element" guidance without harming content readability on mobile.

## File Changes

### New files
- `lib/widgets/golfie/golfie_pill_button.dart`
- `lib/widgets/golfie/golfie_ghost_button.dart` (alias)
- `lib/widgets/golfie/golfie_collage_card.dart`
- `lib/widgets/golfie/golfie_hero.dart`
- `lib/widgets/golfie/golfie_torn_paper_section.dart`
- `lib/widgets/golfie/golfie_index.dart` (barrel)
- `test/widgets/golfie/golfie_pill_button_test.dart`
- `test/widgets/golfie/golfie_ghost_button_test.dart`
- `test/widgets/golfie/golfie_collage_card_test.dart`
- `test/widgets/golfie/golfie_hero_test.dart`
- `test/widgets/golfie/golfie_torn_paper_section_test.dart`

### Moved + refactored
- `lib/widgets/avatar_stack.dart` → `lib/widgets/golfie/golfie_avatar_stack.dart` (Golfie restyle)
- `lib/widgets/empty_state.dart` → `lib/widgets/golfie/golfie_empty_state.dart` (Golfie restyle)
- `test/widgets/avatar_stack_test.dart` (if exists) → moved to `test/widgets/golfie/`
- `test/widgets/empty_state_test.dart` (if exists) → moved to `test/widgets/golfie/`
- All imports of `package:golfie/widgets/avatar_stack.dart` and `package:golfie/widgets/empty_state.dart` updated to new paths

### Modified screens (typography refactor + widget swaps)
- `lib/screens/home_screen.dart` — wrap body in `GolfieHero`, swap `FilledButton.icon` → `GolfiePillButton.icon`, swap `OutlinedButton.icon` → `GolfieGhostButton.icon`, full typography pass
- `lib/screens/caddy_tips_screen.dart` — typography pass
- `lib/screens/analysis_screen.dart` — typography pass
- `lib/screens/submit_tournament_screen.dart` — typography pass + primary buttons → `GolfiePillButton`
- `lib/screens/admin_moderation_screen.dart` — typography pass
- `lib/tournament/screens/tournament_list_screen.dart` — typography pass + `AnimatedSwitcher` on loading state + `GolfieCollageCard` wrap
- `lib/tournament/screens/tournament_detail_screen.dart` — typography pass + `Hero` tag (tournament id) + Periwinkle header accent
- `lib/berita/screens/berita_list_screen.dart` — typography pass + `AnimatedSwitcher`
- `lib/berita/screens/berita_webview_screen.dart` — typography pass on AppBar

### Modified docs
- `README.md` — Current State v2 entry + test-count marker (106 → ~116)
- `CHANGELOG.md` — v2 entry + marker reconciliation
- `docs/UI_STACK.md` — note Golfie widget library exists; motion + Emil skills applied

### Untouched
- All models, repositories, providers, services, utils, mocks
- `lib/core/theme/*` (token module is solid)
- `lib/main.dart` (already wired)
- `prd/`, `docs/DESIGN.md`, `docs/RESEARCH.md`, `docs/backlog/*`

## Behavior

Existing screens pick up Golfie widgets explicitly (not by inheritance) — that's the difference from v1. Each screen opt-in uses `GolfiePillButton` / `GolfieCollageCard` / `GolfieHero` directly. Typography refactor reads `Theme.of(context).textTheme.*` instead of hardcoded `TextStyle(...)`.

Motion is implemented in widget state (`StatefulWidget` for buttons, `StatefulWidget` for card animation). `AnimatedSwitcher` requires the screen's existing loading state machinery — no new state management.

## Emil Design Skills — Review Lens

This is where the v1 deferred work lands. Skills applied:

- **`animation-vocabulary`** — chose easeOutCubic for user-initiated motion (perceived as "responsive"). Reserved easeInOutCubic for state-change animations (perceived as "settling").
- **`apple-design`** — haptics only on primary CTA (matches iOS convention). No haptics on ghost/secondary buttons.
- **`emil-design-eng`** — typography uses theme tokens (one source of truth). Tracking values come from DESIGN.md, not arbitrary -0.5px adjustments.
- **`web-design-guidelines`** — elevation `xl` only on primary cards (the "tournament" card, the "article" card). List items get `md`. Avoids shadow soup.
- **`review-animations`** �� every animation listed in the choreography table above has a stated rationale. No animation is decorative.
- **`find-animation-opportunities`** — deferred. v2 doesn't add new interactions, so no new opportunities to find. Apply in v3 if we add new gestures.

Skills NOT invoked: `prototype`, `design-taste-frontend`, `react-doctor`, `rest-api-design`, `caveman-*`, `setup-matt-pocock-skills`, `migrate-to-shoehorn`, `improve-codebase-architecture`, `grill-me`, `qa`, `tdd`, `testing-strategy`, `scaffold-exercises`, `write-a-skill`, `web-design-guidelines` (applied selectively), `vercel-*` (Flutter project, no Vercel involvement).

## Error Handling

No new error paths. Verification:
- `flutter analyze` — clean
- `flutter test` — ~116 pass (drift guard matches marker)
- `flutter build apk --debug` — engineer verifies on machine with Android SDK
- Manual smoke on `flutter run` — hero looks like Golfie, cards lift on long-press, button scales on press, primary CTA triggers haptic

## Risk Callouts

1. **Moving `avatar_stack.dart` + `empty_state.dart`** breaks every existing import. Plan tracks every import site. Risk is mechanical (sed-able) but touches many files.
2. **Typography refactor cascades** — `TextStyle` references inside composed widgets still pick up `Theme.of(context).textTheme` correctly, but a screen that constructs `Text` with raw `TextStyle` will look wrong if the refactor is incomplete. Mitigate by running widget tests after each screen.
3. **Hero tag uniqueness** — Flutter `Hero` requires unique tags within a route. Plan uses tournament id. If a screen builds two `Hero`s with the same tag (e.g., in a list and a header), the animation breaks. Mitigate with deterministic tag = `'tournament-${tournament.id}'`.
4. **`google_fonts` runtime fetch** — still v1 risk. Same mitigation deferred.
5. **Test-count drift** — if widget tests are simpler than expected, count lands at 112-115 instead of 116. Marker reconciles to actual after implementation.
6. **`StatefulWidget` for buttons adds complexity** — buttons that don't fire onPressed shouldn't animate. Implementation: `GestureDetector` (or `InkWell`) only wraps when `widget.onPressed != null`. When `onPressed == null`, render `Opacity(opacity: 0.5, child: child)` and skip animation entirely. Disabled GolfiePillButton stays a single `StatelessWidget` branch.


## Implementation Phases (preview)

1. **Phase 1 — Widget library** (~2.5 hrs): 5 new widgets + 2 refactors + widget tests + `flutter analyze`
2. **Phase 2 — Motion primitives** (~1 hr): scale/haptic/lift animations wired; `AnimatedSwitcher` helper
3. **Phase 3 — Typography refactor** (~1.5 hrs): every screen, run widget tests after each
4. **Phase 4 — Screen integrations** (~2 hrs): Home/TournamentList/TournamentDetail/BeritaList/Submit integrations + Hero
5. **Phase 5 — Collage backgrounds** (~1 hr): GolfieHero on Home, Periwinkle accents, empty-state accents
6. **Phase 6 — Docs + commit** (~30 min): README + CHANGELOG + UI_STACK updates
7. **Phase 7 — Memory + verification** (~15 min): memory file update, stale-ref scan, final commit

Total: ~8.5 hours.