# KBVS Golf — Visual Direction

> Inspired by Reclub's clean UX + Apple design principles, optimized for Gen Z golf players in Jakarta.

---

## Core Philosophy

**Clean. Sporty. Different.**

We borrow Reclub's UX quality (clear hierarchy, generous whitespace, minimal cognitive load) and Apple's design discipline (consistency, accessibility, motion with purpose). But we **differentiate** — Reclub is generic sport. We're **golf-specific**.

---

## 1. Color Palette

### Primary
| Token | Hex | Usage |
|-------|-----|-------|
| `golf-green-600` | `#2D7A5C` | Primary brand, CTAs, active states |
| `golf-green-400` | `#4FA37E` | Hover states, highlights |
| `golf-green-100` | `#E8F4ED` | Subtle backgrounds, selected rows |

### Accent
| Token | Hex | Usage |
|-------|-----|-------|
| `competition-orange` | `#E85D2C` | Tournament urgency, live badges, deadlines |
| `achievement-gold` | `#D4A53A` | Badges, achievements, top-3 leaderboard positions |
| `error-red` | `#D32F2F` | Errors, withdrawals, "tournament full" |

### Neutrals
| Token | Hex | Usage |
|-------|-----|-------|
| `white` | `#FFFFFF` | Background (light mode) |
| `gray-50` | `#F9FAFB` | Card backgrounds |
| `gray-100` | `#F3F4F6` | Dividers, borders |
| `gray-500` | `#6B7280` | Secondary text |
| `gray-900` | `#111827` | Primary text |
| `black` | `#000000` | Background (dark mode) |

### Dark Mode
- `dark-bg`: `#0A0F0D` (near-black with green tint)
- `dark-surface`: `#1A2520`
- `dark-text`: `#F0F4F1`

---

## 2. Typography

### Font Stack
- **Primary:** Inter (sans-serif, modern, readable)
- **Display:** SF Pro (Apple platforms) / Inter (Android/Web)
- **Mono:** JetBrains Mono (for scorecards, stats)

### Scale (Gen Z-friendly, punchy)
| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `display-xl` | 40px | 800 | Hero sections, splash |
| `display-lg` | 32px | 800 | Page titles |
| `heading-md` | 24px | 700 | Section headers |
| `heading-sm` | 20px | 700 | Card titles |
| `body-lg` | 16px | 500 | Primary body text |
| `body-md` | 14px | 400 | Default body |
| `body-sm` | 12px | 400 | Captions, metadata |
| `caption` | 11px | 600 | Labels, badges |

---

## 3. Component Library

### Cards (Competition / Course)
- Rounded corners: `16px`
- Subtle shadow: `0 4px 12px rgba(0,0,0,0.06)`
- White background, optional gradient header image
- Tap state: scale `0.98` + spring animation

### Buttons
- **Primary:** Filled golf-green, white text, 12px rounded
- **Secondary:** Outlined, golf-green border, transparent bg
- **Ghost:** Text-only, golf-green color
- **Disabled:** Gray-100 bg, gray-500 text
- Tap feedback: scale `0.96` + haptic (light)

### Competition Badges
Circular badges with distinct visual identity per tournament type:
- 🏆 `Amateur` — Green border, white bg
- ⭐ `Pro` — Gold border, black bg
- 🔥 `Live` — Orange pulsing border
- 🎯 `Handicap` — Blue accent
- 🏌️ `Scramble` — Purple accent

### Leaderboard Rows
- Avatar (40px circle) + name + score
- Top 3: gold/silver/bronze trophy icon
- Sticky header with tournament name
- Pull-to-refresh with golf club animation

---

## 4. Iconography

- **System icons:** SF Symbols (iOS) / Material Icons (Android) — let the OS handle consistency
- **Custom icons:** Outlined style, 2px stroke, rounded line caps
- **Golf-specific:** Flag, hole, club, ball, cart, scorecard — designed custom, not generic

---

## 5. Motion & Microinteractions

### Principles
- **Purposeful, not decorative.** Every animation communicates state change.
- **Fast.** 200-300ms for most transitions. No slow, "cinematic" loads.
- **Spring physics** for natural feel (e.g., `flutter_spring` or custom `SpringSimulation`)

### Key Interactions
| Action | Motion |
|--------|--------|
| Pull-to-refresh | Golf club swing → ball drops in |
| Tournament registration | Ball roll into hole animation |
| Score update | Number flip animation |
| Achievement unlock | Badge scales from 0 + particle burst |
| Page transition | Slide + fade, 250ms ease-out |
| Button press | Scale 0.96 + haptic light impact |

---

## 6. Layout Patterns

### Home Feed (Gen Z-optimized)
1. **Hero card** (top, 60% screen): Featured live tournament, big imagery
2. **Quick actions row:** Book tee time, find course, my handicap, friends playing
3. **Upcoming tournaments list:** Vertical scroll, card-based, infinite
4. **Bottom nav:** Home / Discover / Play / Leaderboard / Profile

### Tournament Detail
- Hero image (course photography)
- Tournament name (display-lg)
- Date, location, format (body-md)
- Registered players (avatar stack, "+12 more")
- CTA: "Register" (primary) or "You're in" (success state)
- Tabs: Details / Players / Rules / Discussion

### Course Detail
- Map preview (Google Maps embed)
- Course info: par, length, facilities
- Upcoming tournaments at this course
- Reviews/ratings (Gen Z likes social proof)

---

## 7. Imagery Guidelines

### DO
- **Real Jakarta courses** (Emeralda, Royale Jakarta Golf Club, etc.)
- **Action shots:** swing mid-motion, ball flight, putt celebration
- **Local players:** diverse, authentic Jakarta golf community
- **Course landscapes:** early morning, golden hour — aspirational but attainable

### DON'T
- Stock photos of "golfers smiling at camera"
- Generic sports imagery that could be any sport
- Overly polished, magazine-style shots — Gen Z prefers authentic
- Crowded courses — show spacious, premium feel

---

## 8. Onboarding Flow (Gen Z Pattern)

Progressive disclosure, one decision per screen:

1. **Welcome** — Full-screen hero, brand promise, "Let's go" CTA
2. **Location** — "Pick your home course area" (Jakarta map, tap to select)
3. **Skill level** — Slider: Beginner / Casual / Competitive / Pro
4. **Handicap** — Optional, skip-able
5. **Profile photo + username** — Camera/gallery picker, 12-char username
6. **First tournament** — Pre-selected based on skill + location, "Join this one?" CTA

No walls of text. No long legal disclaimers upfront. Inline them later.

---

## 9. Accessibility

- WCAG 2.1 AA minimum contrast for all text
- Dynamic type support (iOS) / font scaling (Android)
- VoiceOver / TalkBack labels on all interactive elements
- Color is never the only signal (e.g., tournament live = orange icon + "LIVE" text + pulsing animation)
- Reduce motion option respects system settings

---

## 10. What Makes Us Different from Reclub

| Aspect | Reclub | KBVS Golf |
|--------|--------|-----------|
| Sport focus | Multi-sport (generic) | Golf-specific (specialist) |
| Visual identity | Blue/purple, generic sport | Green/gold, golf-coded |
| Hero content | Athlete photography | Course landscapes + action shots |
| Tone | Broad, community-driven | Aspirational, skill-progression |
| Audience | All sports enthusiasts | Jakarta golfers specifically |

---

## 11. Design Tools & Workflow

- **Figma** — Primary design tool, build design system there first
- **Lottie** — Micro-interactions (free golf-themed animations on LottieFiles)
- **Inter font** — Self-host via Google Fonts CDN
- **App icon** — Custom, green flag silhouette on white circle
- **Design tokens** — Export from Figma as JSON, import to Flutter via `flutter_gen`

---

## 12. Implementation Notes (Flutter)

```dart
// Theme stub
final lightTheme = ThemeData(
  primaryColor: Color(0xFF2D7A5C),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF2D7A5C),
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.interTextTheme(),
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  // ... etc
);
```

**Avoid:** Hardcoded colors anywhere outside theme files. Use `Theme.of(context).colorScheme.primary` etc.

---

*Last updated: 2026-07-28*
*Designed by: Hermes (Windah)*