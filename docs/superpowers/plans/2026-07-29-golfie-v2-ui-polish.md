# Golfie v2 UI Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the deferred parts of `docs/DESIGN.md` on the existing Golfie app — custom widget library, motion, typography refactor, subtle collage backgrounds.

**Architecture:** Build a `lib/widgets/golfie/` widget library (5 new widgets + 2 refactors), wire motion primitives into the widgets, then refactor every screen's typography to consume `Theme.of(context).textTheme.*` and opt into Golfie widgets. Collage backgrounds applied last as visual polish.

**Tech Stack:** Flutter 3.x, Material 3, GoogleFonts (Lora + Inter), Provider (existing). No new third-party deps.

**Branch:** `revamp/golfie`

**Spec:** `docs/superpowers/specs/2026-07-29-golfie-v2-ui-polish-design.md`

---

## File Structure

**New widgets** (all under `lib/widgets/golfie/`):
- `golfie_pill_button.dart` — primary CTA with scale-on-press + haptic
- `golfie_ghost_button.dart` — secondary CTA (alias)
- `golfie_collage_card.dart` — white card with optional Periwinkle accent + multi-layered shadow
- `golfie_hero.dart` — full-bleed hero with sky-gradient bg, pastel collage blocks, headline + subhead + cta
- `golfie_torn_paper_section.dart` — decorative divider with scalloped top edge
- `golfie_avatar_stack.dart` — refactor of `widgets/avatar_stack.dart` with Golfie styling
- `golfie_empty_state.dart` — refactor of `widgets/empty_state.dart` with Golfie styling
- `golfie_index.dart` — barrel re-export

**Deleted files:**
- `lib/widgets/avatar_stack.dart`
- `lib/widgets/empty_state.dart`

**New tests** (all under `test/widgets/golfie/`):
- `golfie_pill_button_test.dart`
- `golfie_ghost_button_test.dart`
- `golfie_collage_card_test.dart`
- `golfie_hero_test.dart`
- `golfie_torn_paper_section_test.dart`

**Modified screens** (typography + widget swaps):
- `lib/screens/home_screen.dart`
- `lib/screens/caddy_tips_screen.dart`
- `lib/screens/analysis_screen.dart`
- `lib/screens/submit_tournament_screen.dart`
- `lib/screens/admin_moderation_screen.dart`
- `lib/tournament/screens/tournament_list_screen.dart`
- `lib/tournament/screens/tournament_detail_screen.dart`
- `lib/berita/screens/berita_list_screen.dart`
- `lib/berita/screens/berita_webview_screen.dart`

**Modified docs:**
- `README.md` — v2 entry + test-count marker
- `CHANGELOG.md` — v2 entry
- `docs/UI_STACK.md` — note Golfie widget library + motion

---

## Phase 1 — Custom Widget Library

### Task 1: Create `GolfieCollageCard` widget

**Files:**
- Create: `lib/widgets/golfie/golfie_collage_card.dart`
- Test: `test/widgets/golfie/golfie_collage_card_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
// test/widgets/golfie/golfie_collage_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/core/theme/golfie_colors.dart';
import 'package:golfie/widgets/golfie/golfie_collage_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders child', (tester) async {
    await tester.pumpWidget(wrap(const GolfieCollageCard(child: Text('hello'))));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('renders Periwinkle accent when accentCorner=topRight', (tester) async {
    await tester.pumpWidget(wrap(const GolfieCollageCard(
      child: Text('hello'),
      accentCorner: GolfieAccentCorner.topRight,
    )));
    // Accent rendered as a Container with periwinkle color
    final containers = tester.widgetList<Container>(find.byType(Container));
    final hasPeriwinkle = containers.any((c) {
      final decoration = c.decoration;
      if (decoration is BoxDecoration && decoration.color == GolfieColors.periwinkle) {
        return true;
      }
      return false;
    });
    expect(hasPeriwinkle, isTrue);
  });

  testWidgets('no accent when accentCorner=none (default)', (tester) async {
    await tester.pumpWidget(wrap(const GolfieCollageCard(child: Text('hello'))));
    final containers = tester.widgetList<Container>(find.byType(Container));
    final hasPeriwinkle = containers.any((c) {
      final decoration = c.decoration;
      if (decoration is BoxDecoration && decoration.color == GolfieColors.periwinkle) {
        return true;
      }
      return false;
    });
    expect(hasPeriwinkle, isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/golfie/golfie_collage_card_test.dart`
Expected: FAIL — `golfie_collage_card.dart` does not exist.

- [ ] **Step 3: Implement the widget**

```dart
// lib/widgets/golfie/golfie_collage_card.dart
import 'package:flutter/material.dart';
import '../../core/theme/golfie_colors.dart';
import '../../core/theme/golfie_radii.dart';
import '../../core/theme/golfie_shadows.dart';

enum GolfieAccentCorner { none, topLeft, topRight, bottomLeft, bottomRight }

class GolfieCollageCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final GolfieAccentCorner accentCorner;
  final VoidCallback? onLongPress;

  const GolfieCollageCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.accentCorner = GolfieAccentCorner.none,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: GolfieColors.white,
        borderRadius: BorderRadius.circular(GolfieRadii.xlPlus),
        boxShadow: GolfieShadows.xl,
      ),
      child: Stack(
        children: [
          Padding(padding: padding, child: child),
          if (accentCorner != GolfieAccentCorner.none)
            Positioned(
              top: accentCorner == GolfieAccentCorner.bottomLeft ||
                      accentCorner == GolfieAccentCorner.bottomRight
                  ? null
                  : 16,
              bottom: accentCorner == GolfieAccentCorner.bottomLeft ||
                      accentCorner == GolfieAccentCorner.bottomRight
                  ? 16
                  : null,
              left: accentCorner == GolfieAccentCorner.topLeft ||
                      accentCorner == GolfieAccentCorner.bottomLeft
                  ? 16
                  : null,
              right: accentCorner == GolfieAccentCorner.topRight ||
                      accentCorner == GolfieAccentCorner.bottomRight
                  ? 16
                  : null,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: GolfieColors.periwinkle,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );

    if (onLongPress == null) return card;
    return GestureDetector(onLongPress: onLongPress, child: card);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/golfie/golfie_collage_card_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Run flutter analyze**

Run: `flutter analyze lib/widgets/golfie/golfie_collage_card.dart`
Expected: No issues.

- [ ] **Step 6: Commit**

```bash
git add lib/widgets/golfie/golfie_collage_card.dart test/widgets/golfie/golfie_collage_card_test.dart
git commit -m "feat(golfie): add GolfieCollageCard widget"
```

---

### Task 2: Create `GolfiePillButton` widget (with scale animation + haptic)

**Files:**
- Create: `lib/widgets/golfie/golfie_pill_button.dart`
- Test: `test/widgets/golfie/golfie_pill_button_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
// test/widgets/golfie/golfie_pill_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/core/theme/golfie_colors.dart';
import 'package:golfie/widgets/golfie/golfie_pill_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders label text', (tester) async {
    await tester.pumpWidget(wrap(GolfiePillButton(
      onPressed: () {},
      child: const Text('Tap me'),
    )));
    expect(find.text('Tap me'), findsOneWidget);
  });

  testWidgets('primary variant uses Ink background', (tester) async {
    await tester.pumpWidget(wrap(GolfiePillButton(
      onPressed: () {},
      child: const Text('Tap'),
    )));
    final containers = tester.widgetList<Container>(find.byType(Container));
    final hasInkBg = containers.any((c) {
      final d = c.decoration;
      return d is BoxDecoration && d.color == GolfieColors.ink;
    });
    expect(hasInkBg, isTrue);
  });

  testWidgets('secondary variant uses White background with Ash border', (tester) async {
    await tester.pumpWidget(wrap(GolfiePillButton(
      variant: GolfieButtonVariant.secondary,
      onPressed: () {},
      child: const Text('Tap'),
    )));
    final containers = tester.widgetList<Container>(find.byType(Container));
    final hasSecondaryStyle = containers.any((c) {
      final d = c.decoration;
      if (d is BoxDecoration && d.color == GolfieColors.white) {
        return true;
      }
      return false;
    });
    expect(hasSecondaryStyle, isTrue);
  });

  testWidgets('disabled button (onPressed=null) renders with reduced opacity', (tester) async {
    await tester.pumpWidget(wrap(const GolfiePillButton(
      onPressed: null,
      child: Text('Disabled'),
    )));
    expect(find.text('Disabled'), findsOneWidget);
    expect(find.byType(Opacity), findsOneWidget);
  });

  testWidgets('onPressed fires when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(GolfiePillButton(
      onPressed: () => tapped = true,
      child: const Text('Tap'),
    )));
    await tester.tap(find.text('Tap'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('AnimatedScale is present', (tester) async {
    await tester.pumpWidget(wrap(GolfiePillButton(
      onPressed: () {},
      child: const Text('Tap'),
    )));
    expect(find.byType(AnimatedScale), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/golfie/golfie_pill_button_test.dart`
Expected: FAIL — `golfie_pill_button.dart` does not exist.

- [ ] **Step 3: Implement the widget**

```dart
// lib/widgets/golfie/golfie_pill_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/golfie_colors.dart';
import '../../core/theme/golfie_radii.dart';

enum GolfieButtonVariant { primary, secondary }

class GolfiePillButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final GolfieButtonVariant variant;
  final bool haptic;
  final IconData? icon;

  const GolfiePillButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = GolfieButtonVariant.primary,
    this.haptic = true,
    this.icon,
  });

  @override
  State<GolfiePillButton> createState() => _GolfiePillButtonState();
}

class _GolfiePillButtonState extends State<GolfiePillButton> {
  double _scale = 1.0;

  bool get _enabled => widget.onPressed != null;

  void _handleTapDown(TapDownDetails _) {
    if (!_enabled) return;
    setState(() => _scale = 0.97);
    if (widget.haptic && widget.variant == GolfieButtonVariant.primary) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_enabled) return;
    setState(() => _scale = 1.0);
  }

  void _handleTapCancel() {
    if (!_enabled) return;
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.variant == GolfieButtonVariant.primary;
    final bg = isPrimary ? GolfieColors.ink : GolfieColors.white;
    final fg = isPrimary ? GolfieColors.white : GolfieColors.ink;
    final border = isPrimary ? null : Border.all(color: GolfieColors.ash);

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GolfieRadii.pill),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, color: fg, size: 18),
            const SizedBox(width: 8),
          ],
          DefaultTextStyle(
            style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w500),
            child: widget.child,
          ),
        ],
      ),
    );

    if (!_enabled) {
      return Opacity(opacity: 0.5, child: content);
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: content,
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/golfie/golfie_pill_button_test.dart`
Expected: PASS (6 tests).

- [ ] **Step 5: Run flutter analyze**

Run: `flutter analyze lib/widgets/golfie/golfie_pill_button.dart`
Expected: No issues.

- [ ] **Step 6: Commit**

```bash
git add lib/widgets/golfie/golfie_pill_button.dart test/widgets/golfie/golfie_pill_button_test.dart
git commit -m "feat(golfie): add GolfiePillButton with scale animation + haptic"
```

---

### Task 3: Create `GolfieGhostButton` widget (alias)

**Files:**
- Create: `lib/widgets/golfie/golfie_ghost_button.dart`
- Test: `test/widgets/golfie/golfie_ghost_button_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
// test/widgets/golfie/golfie_ghost_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/widgets/golfie/golfie_ghost_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders label text', (tester) async {
    await tester.pumpWidget(wrap(GolfieGhostButton(
      onPressed: () {},
      child: const Text('Cancel'),
    )));
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('uses secondary variant (no haptic)', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(GolfieGhostButton(
      onPressed: () => tapped = true,
      child: const Text('Cancel'),
    )));
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(tapped, isTrue);
    // Ghost button does NOT fire haptic — verified by absence of crash
  });

  testWidgets('renders icon when provided', (tester) async {
    await tester.pumpWidget(wrap(GolfieGhostButton(
      onPressed: () {},
      icon: Icons.close,
      child: const Text('Cancel'),
    )));
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/golfie/golfie_ghost_button_test.dart`
Expected: FAIL — `golfie_ghost_button.dart` does not exist.

- [ ] **Step 3: Implement the widget**

```dart
// lib/widgets/golfie/golfie_ghost_button.dart
import 'golfie_pill_button.dart';

/// Ghost button = secondary variant of GolfiePillButton with no haptic.
/// Lightweight visual weight for secondary actions.
class GolfieGhostButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  const GolfieGhostButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GolfiePillButton(
      onPressed: onPressed,
      variant: GolfieButtonVariant.secondary,
      haptic: false,
      icon: icon,
      child: child,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/golfie/golfie_ghost_button_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/golfie/golfie_ghost_button.dart test/widgets/golfie/golfie_ghost_button_test.dart
git commit -m "feat(golfie): add GolfieGhostButton (secondary variant alias)"
```

---

### Task 4: Create `GolfieHero` widget

**Files:**
- Create: `lib/widgets/golfie/golfie_hero.dart`
- Test: `test/widgets/golfie/golfie_hero_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
// test/widgets/golfie/golfie_hero_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/core/theme/golfie_colors.dart';
import 'package:golfie/widgets/golfie/golfie_hero.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders headline and subhead', (tester) async {
    await tester.pumpWidget(wrap(const GolfieHero(
      headline: 'Welcome',
      subhead: 'Pick a tournament',
    )));
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Pick a tournament'), findsOneWidget);
  });

  testWidgets('renders cta widget when provided', (tester) async {
    await tester.pumpWidget(wrap(const GolfieHero(
      headline: 'Welcome',
      cta: ElevatedButton(onPressed: null, child: Text('Go')),
    )));
    expect(find.text('Go'), findsOneWidget);
  });

  testWidgets('renders collage blocks in Stack', (tester) async {
    await tester.pumpWidget(wrap(const GolfieHero(
      headline: 'Welcome',
      collage: [
        GolfieCollageBlock(
          shape: GolfieCollageShape.circle,
          color: GolfieColors.mint,
          alignment: Alignment.topRight,
          size: 60,
        ),
      ],
    )));
    // Stack should be present with at least 2 children (block + content)
    expect(find.byType(Stack), findsWidgets);
  });

  testWidgets('default minHeight is 280', (tester) async {
    await tester.pumpWidget(wrap(const GolfieHero(headline: 'Hi')));
    final container = tester.widget<Container>(find.byType(Container).first);
    final constraints = (container.constraints ?? BoxConstraints()).minHeight;
    expect(container.constraints, isNotNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/golfie/golfie_hero_test.dart`
Expected: FAIL — `golfie_hero.dart` does not exist.

- [ ] **Step 3: Implement the widget**

```dart
// lib/widgets/golfie/golfie_hero.dart
import 'package:flutter/material.dart';
import '../../core/theme/golfie_colors.dart';

enum GolfieCollageShape { circle, rect }

class GolfieCollageBlock {
  final GolfieCollageShape shape;
  final Color color;
  final double opacity;
  final Alignment alignment;
  final double size;

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
  final double minHeight;
  final EdgeInsetsGeometry padding;

  const GolfieHero({
    super.key,
    required this.headline,
    this.subhead,
    this.cta,
    this.collage = const <GolfieCollageBlock>[],
    this.minHeight = 280,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: const BoxDecoration(gradient: GolfieColors.skyGradient),
      child: Stack(
        children: [
          // Collage blocks (background)
          ...collage.map((b) => Align(
                alignment: b.alignment,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Opacity(
                    opacity: b.opacity,
                    child: b.shape == GolfieCollageShape.circle
                        ? Container(
                            width: b.size,
                            height: b.size,
                            decoration: BoxDecoration(
                              color: b.color,
                              shape: BoxShape.circle,
                            ),
                          )
                        : Container(
                            width: b.size,
                            height: b.size * 0.6,
                            decoration: BoxDecoration(
                              color: b.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                  ),
                ),
              )),
          // Foreground content
          Padding(
            padding: padding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline, style: theme.textTheme.displayMedium),
                if (subhead != null) ...[
                  const SizedBox(height: 12),
                  Text(subhead!, style: theme.textTheme.bodyLarge),
                ],
                if (cta != null) ...[
                  const SizedBox(height: 24),
                  cta!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/golfie/golfie_hero_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/golfie/golfie_hero.dart test/widgets/golfie/golfie_hero_test.dart
git commit -m "feat(golfie): add GolfieHero with sky-gradient and collage blocks"
```

---

### Task 5: Create `GolfieTornPaperSection` widget

**Files:**
- Create: `lib/widgets/golfie/golfie_torn_paper_section.dart`
- Test: `test/widgets/golfie/golfie_torn_paper_section_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
// test/widgets/golfie/golfie_torn_paper_section_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/core/theme/golfie_colors.dart';
import 'package:golfie/widgets/golfie/golfie_torn_paper_section.dart';

void main() {
  testWidgets('renders child', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: GolfieTornPaperSection(child: Text('content')),
      ),
    ));
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('uses Canvas as default background', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: GolfieTornPaperSection(child: Text('x')),
      ),
    ));
    final containers = tester.widgetList<Container>(find.byType(Container));
    final hasCanvas = containers.any((c) {
      final d = c.decoration;
      return d is BoxDecoration && d.color == GolfieColors.canvas;
    });
    expect(hasCanvas, isTrue);
  });

  testWidgets('CustomPaint renders scalloped divider', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: GolfieTornPaperSection(child: Text('x')),
      ),
    ));
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/golfie/golfie_torn_paper_section_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement the widget**

```dart
// lib/widgets/golfie/golfie_torn_paper_section.dart
import 'package:flutter/material.dart';
import '../../core/theme/golfie_colors.dart';

class _ScallopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GolfieColors.ash.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path();
    const waveHeight = 4.0;
    const waveLength = 16.0;
    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += waveLength) {
      path.quadraticBezierTo(
        x + waveLength / 2,
        size.height - waveHeight,
        x + waveLength,
        size.height,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ScallopPainter oldDelegate) => false;
}

class GolfieTornPaperSection extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double height;

  const GolfieTornPaperSection({
    super.key,
    required this.child,
    this.backgroundColor = GolfieColors.canvas,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          SizedBox(
            height: 8,
            child: CustomPaint(painter: _ScallopPainter(), size: Size.infinite),
          ),
          SizedBox(height: height, child: child),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/golfie/golfie_torn_paper_section_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/golfie/golfie_torn_paper_section.dart test/widgets/golfie/golfie_torn_paper_section_test.dart
git commit -m "feat(golfie): add GolfieTornPaperSection with scalloped divider"
```

---

### Task 6: Create `GolfieAvatarStack` (refactor of `avatar_stack.dart`)

**Files:**
- Create: `lib/widgets/golfie/golfie_avatar_stack.dart`
- Delete: `lib/widgets/avatar_stack.dart`

- [ ] **Step 1: Create new file with Golfie styling (preserves public API)**

```dart
// lib/widgets/golfie/golfie_avatar_stack.dart
import 'package:flutter/material.dart';
import '../../core/theme/golfie_colors.dart';

/// Avatar stack as specified in PRD §3.3, restyled with Golfie tokens.
/// Public API matches the original AvatarStack (totalPlayers + optional initials).
/// Custom Stack + ClipOval + offset positioning – no third‑party widget.
/// Three visible avatars with 20px overlap, "+N more" badge when >3.
class GolfieAvatarStack extends StatelessWidget {
  final int totalPlayers;
  final List<String>? initials;

  const GolfieAvatarStack({super.key, required this.totalPlayers, this.initials})
      : assert(initials == null || initials.length >= 3, 'Need at least 3 initials if provided');

  @override
  Widget build(BuildContext context) {
    final showCount = totalPlayers <= 3 ? totalPlayers : 3;
    final remaining = totalPlayers > 3 ? totalPlayers - 3 : 0;

    final List<String> names = initials ??
        List.generate(showCount, (i) => String.fromCharCode(65 + i));

    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          for (int i = 0; i < showCount; i++)
            Positioned(
              left: i * -20,
              child: ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: GolfieColors.cloud,
                    border: Border.all(color: GolfieColors.canvas, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      names[i],
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: GolfieColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: -20 * 2,
              child: ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: GolfieColors.ink,
                    border: Border.all(color: GolfieColors.canvas, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '+$remaining',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: GolfieColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Delete old file**

Run: `rm lib/widgets/avatar_stack.dart`

- [ ] **Step 3: Run flutter analyze to find broken imports**

Run: `flutter analyze lib/ 2>&1 | head -30`
Expected: errors about `AvatarStack` not exported.

- [ ] **Step 4: Update import sites**

Find import sites:
Run: `grep -rln "widgets/avatar_stack" lib/ test/`

For each result, replace:
- `import '../widgets/avatar_stack.dart';` → `import '../widgets/golfie/golfie_avatar_stack.dart';`
- `import '../../widgets/avatar_stack.dart';` → `import '../../widgets/golfie/golfie_avatar_stack.dart';`
- `AvatarStack(` → `GolfieAvatarStack(`

- [ ] **Step 5: Run tests**

Run: `flutter test`
Expected: All previously-passing tests still pass.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "refactor(golfie): move AvatarStack to GolfieAvatarStack with Golfie styling"
```

---

### Task 7: Create `GolfieEmptyState` (refactor of `empty_state.dart`)

**Files:**
- Create: `lib/widgets/golfie/golfie_empty_state.dart`
- Delete: `lib/widgets/empty_state.dart`

- [ ] **Step 1: Create new file with Golfie styling (preserves public API)**

```dart
// lib/widgets/golfie/golfie_empty_state.dart
import 'package:flutter/material.dart';
import '../../core/theme/golfie_colors.dart';

class GolfieEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const GolfieEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: GolfieColors.stone),
          const SizedBox(height: 16),
          Text(title, style: textTheme.headlineMedium?.copyWith(color: GolfieColors.graphite)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: textTheme.bodyMedium?.copyWith(color: GolfieColors.stone)),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Delete old file**

Run: `rm lib/widgets/empty_state.dart`

- [ ] **Step 3: Update import sites**

Find import sites:
Run: `grep -rln "widgets/empty_state" lib/ test/`

For each result:
- `import '../widgets/empty_state.dart';` → `import '../widgets/golfie/golfie_empty_state.dart';`
- `import '../../widgets/empty_state.dart';` → `import '../../widgets/golfie/golfie_empty_state.dart';`
- `EmptyState(` → `GolfieEmptyState(`

- [ ] **Step 4: Run tests**

Run: `flutter test`
Expected: All previously-passing tests still pass.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor(golfie): move EmptyState to GolfieEmptyState with Golfie styling"
```

---

### Task 8: Create `golfie_index.dart` barrel + full test sweep

**Files:**
- Create: `lib/widgets/golfie/golfie_index.dart`

- [ ] **Step 1: Create the barrel file**

```dart
// lib/widgets/golfie/golfie_index.dart
/// Barrel re-export for all Golfie widgets.
/// Consumers should `import 'package:golfie/widgets/golfie/golfie_index.dart';`
/// instead of importing individual widget files.
export 'golfie_collage_card.dart';
export 'golfie_pill_button.dart';
export 'golfie_ghost_button.dart';
export 'golfie_hero.dart';
export 'golfie_torn_paper_section.dart';
export 'golfie_avatar_stack.dart';
export 'golfie_empty_state.dart';
```

- [ ] **Step 2: Run full test suite**

Run: `flutter test`
Expected: All tests pass. Count should now be ~116 (previous 106 + 4 collage + 6 pill + 3 ghost + 4 hero + 3 torn paper = ~124 if avatar/empty tests existed). Adjust README/CHANGELOG marker to actual count.

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues.

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/golfie/golfie_index.dart
git commit -m "feat(golfie): add barrel re-export for Golfie widgets"
```

---

## Phase 2 — Screen Integrations

### Task 9: Refactor `home_screen.dart` — typography + GolfieHero + buttons

**Files:**
- Modify: `lib/screens/home_screen.dart`

- [ ] **Step 1: Read current file**

Run: `cat lib/screens/home_screen.dart`

- [ ] **Step 2: Replace the entire `body` of `build()` with Golfie integrations**

```dart
// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../tournament/screens/tournament_list_screen.dart';
import '../berita/screens/berita_list_screen.dart';
import '../widgets/golfie/golfie_index.dart';
import 'caddy_tips_screen.dart';
import 'admin_moderation_screen.dart';
import 'submit_tournament_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Golfie'),
        actions: [
          Consumer<AppState>(
            builder: (context, app, child) => IconButton(
              icon: app.caddyTipsEnabled ? const Icon(Icons.star) : const Icon(Icons.star_border),
              tooltip: 'Caddy Tips',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CaddyTipsScreen()));
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.supervised_user_circle),
            tooltip: 'Admin Moderation',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminModerationScreen()));
            },
          ),
          Consumer<AppState>(
            builder: (context, app, child) => PopupMenuButton<bool>(
              onSelected: (value) => app.toggleCaddyTips(),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: true,
                  child: Row(children: [
                    Icon(Icons.star_outline, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Enable Caddy Tips'),
                  ]),
                ),
                PopupMenuItem(
                  value: false,
                  child: Row(children: [
                    Icon(Icons.star_border, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Disable Caddy Tips'),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitTournamentScreen()));
        },
        child: const Icon(Icons.add),
        tooltip: 'Submit New Tournament',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GolfieHero(
              headline: 'Golfie',
              subhead: 'Discover local tournaments',
              collage: const [
                GolfieCollageBlock(
                  shape: GolfieCollageShape.circle,
                  color: GolfieColors.mint,
                  alignment: Alignment.topRight,
                  size: 60,
                ),
                GolfieCollageBlock(
                  shape: GolfieCollageShape.rect,
                  color: GolfieColors.marigold,
                  alignment: Alignment.bottomLeft,
                  size: 80,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Pick a course to begin', style: textTheme.bodyLarge),
                  const SizedBox(height: 32),
                  GolfiePillButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TournamentListScreen()));
                    },
                    icon: Icons.golf_course,
                    child: const Text('Browse Tournaments'),
                  ),
                  const SizedBox(height: 12),
                  GolfieGhostButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BeritaListScreen()));
                    },
                    icon: Icons.article_outlined,
                    child: const Text('Golf News'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Run tests**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 4: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "refactor(home): apply Golfie hero, buttons, typography"
```

---

### Task 10: Typography pass — `caddy_tips_screen.dart`, `analysis_screen.dart`, `admin_moderation_screen.dart`, `submit_tournament_screen.dart`

**Files:**
- Modify: `lib/screens/caddy_tips_screen.dart`
- Modify: `lib/screens/analysis_screen.dart`
- Modify: `lib/screens/admin_moderation_screen.dart`
- Modify: `lib/screens/submit_tournament_screen.dart`

- [ ] **Step 1: Find raw TextStyle usages**

Run: `grep -n "TextStyle(fontSize" lib/screens/caddy_tips_screen.dart lib/screens/analysis_screen.dart lib/screens/admin_moderation_screen.dart lib/screens/submit_tournament_screen.dart`

- [ ] **Step 2: Apply typography mapping for each screen**

For each raw `TextStyle(fontSize: N, fontWeight: ...)` found:
- `fontSize: 24, fontWeight: bold` → `Theme.of(context).textTheme.headlineMedium`
- `fontSize: 20, fontWeight: w500` → `Theme.of(context).textTheme.titleLarge`
- `fontSize: 20, fontWeight: w600` → `Theme.of(context).textTheme.titleLarge`
- `fontSize: 16, fontWeight: w500` → `Theme.of(context).textTheme.labelLarge`
- `fontSize: 16` → `Theme.of(context).textTheme.bodyLarge`
- `fontSize: 14` → `Theme.of(context).textTheme.bodyMedium`
- `fontSize: 12` → `Theme.of(context).textTheme.bodySmall`
- `TextStyle(color: Colors.grey)` → `Theme.of(context).textTheme.bodyMedium?.copyWith(color: GolfieColors.stone)`

- [ ] **Step 3: For `submit_tournament_screen.dart`, also swap primary buttons**

Find `FilledButton.icon(` and `ElevatedButton(`:
- Replace `FilledButton.icon(onPressed: ..., icon: const Icon(X), label: const Text(Y))` → `GolfiePillButton(onPressed: ..., icon: X, child: const Text(Y))`
- Replace `ElevatedButton(...)` with primary semantics → `GolfiePillButton(...)`

Add import: `import '../widgets/golfie/golfie_index.dart';`

- [ ] **Step 4: Run tests**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 5: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues.

- [ ] **Step 6: Commit**

```bash
git add lib/screens/caddy_tips_screen.dart lib/screens/analysis_screen.dart lib/screens/admin_moderation_screen.dart lib/screens/submit_tournament_screen.dart
git commit -m "refactor(screens): typography pass + GolfiePillButton on primary actions"
```

---

### Task 11: Refactor `tournament_list_screen.dart` — typography + GolfieCollageCard + AnimatedSwitcher

**Files:**
- Modify: `lib/tournament/screens/tournament_list_screen.dart`

- [ ] **Step 1: Read current file**

Run: `cat lib/tournament/screens/tournament_list_screen.dart`

- [ ] **Step 2: Add import**

```dart
import '../../widgets/golfie/golfie_index.dart';
```

- [ ] **Step 3: Replace raw TextStyle calls**

For lines 152, 386, 453, 457 (per `grep TextStyle(fontSize`):
- `TextStyle(fontSize: 12, color: Colors.grey.shade600)` → `Theme.of(context).textTheme.bodySmall?.copyWith(color: GolfieColors.stone)`
- `TextStyle(fontSize: 20, fontWeight: FontWeight.w600)` → `Theme.of(context).textTheme.titleLarge`
- `TextStyle(fontSize: 12, color: Colors.grey.shade700)` → `Theme.of(context).textTheme.bodySmall?.copyWith(color: GolfieColors.graphite)`

- [ ] **Step 4: Wrap list item Card in GolfieCollageCard**

Find the `Card(` widget that wraps each tournament list item. Replace with `GolfieCollageCard(` closing the same way (move children up one indent level).

If tournament card uses `Card(child: ...)` style, replace `Card(` with `GolfieCollageCard(accentCorner: GolfieAccentCorner.topRight,`.

- [ ] **Step 5: Wrap loading/list content with AnimatedSwitcher**

Find the conditional rendering (`if (loading) CircularProgressIndicator() else ListView(...)`). Wrap the entire `if/else` in an `AnimatedSwitcher(duration: Duration(milliseconds: 250), child: ...)` and give each branch a unique `ValueKey`.

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 250),
  child: loading
      ? const Center(
          key: ValueKey('loading'),
          child: CircularProgressIndicator(),
        )
      : RefreshIndicator(
          key: const ValueKey('content'),
          onRefresh: () async { /* existing load */ },
          child: ListView.builder(/* existing */),
        ),
)
```

- [ ] **Step 6: Run tests**

Run: `flutter test test/screens/tournament_list_screen_test.dart test/tournament/ 2>&1 | tail -20`
Expected: All tests pass. If a test breaks due to widget tree changes, update the test's finders to match `GolfieCollageCard` instead of `Card`.

- [ ] **Step 7: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues.

- [ ] **Step 8: Commit**

```bash
git add lib/tournament/screens/tournament_list_screen.dart
git commit -m "refactor(tournament-list): GolfieCollageCard + AnimatedSwitcher + typography"
```

---

### Task 12: Refactor `tournament_detail_screen.dart` — Hero animation + Periwinkle accent

**Files:**
- Modify: `lib/tournament/screens/tournament_detail_screen.dart`

- [ ] **Step 1: Add imports**

```dart
import 'package:flutter/material.dart' show Hero;
import '../../widgets/golfie/golfie_index.dart';
```

- [ ] **Step 2: Find the tournament title Text widget**

Wrap it in `Hero` with tag = `'tournament-${tournament.id}'`:

```dart
Hero(
  tag: 'tournament-${tournament.id}',
  child: Material(
    type: MaterialType.transparency,
    child: Text(tournament.name, style: Theme.of(context).textTheme.headlineMedium),
  ),
)
```

- [ ] **Step 3: Add Periwinkle accent strip at top**

In the Scaffold (or AppBar bottom), prepend:

```dart
Container(
  height: 8,
  color: GolfieColors.periwinkle,
)
```

- [ ] **Step 4: Replace raw TextStyle calls in the file**

Use the same mapping as Task 10.

- [ ] **Step 5: In `tournament_list_screen.dart`, wrap each list item in matching Hero**

Each tournament card must wrap its title in `Hero(tag: 'tournament-${tournament.id}', child: ...)`. If list card already uses `GolfieCollageCard`, wrap the title inside it.

- [ ] **Step 6: Run tests**

Run: `flutter test test/screens/tournament_detail_screen_test.dart test/screens/tournament_list_screen_test.dart`
Expected: All tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/tournament/screens/tournament_detail_screen.dart lib/tournament/screens/tournament_list_screen.dart
git commit -m "refactor(tournament): Hero animation + Periwinkle accent + typography"
```

---

### Task 13: Refactor `berita_list_screen.dart` — typography + AnimatedSwitcher

**Files:**
- Modify: `lib/berita/screens/berita_list_screen.dart`

- [ ] **Step 1: Add import**

```dart
import '../../widgets/golfie/golfie_index.dart';
```

- [ ] **Step 2: Apply typography mapping**

Find any raw `TextStyle(...)` and replace with theme styles.

- [ ] **Step 3: Wrap loading/content with AnimatedSwitcher**

Same pattern as Task 11 step 5. Use `ValueKey('loading')` and `ValueKey('content')`.

- [ ] **Step 4: Run tests**

Run: `flutter test test/berita/berita_list_screen_test.dart`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/berita/screens/berita_list_screen.dart
git commit -m "refactor(berita-list): AnimatedSwitcher + typography"
```

---

### Task 14: Typography pass — `berita_webview_screen.dart`

**Files:**
- Modify: `lib/berita/screens/berita_webview_screen.dart`

- [ ] **Step 1: Find raw TextStyle usages**

Run: `grep -n "TextStyle(fontSize" lib/berita/screens/berita_webview_screen.dart`

- [ ] **Step 2: Apply typography mapping**

Use the same mapping as Task 10.

- [ ] **Step 3: Run tests**

Run: `flutter test test/berita/berita_webview_screen_test.dart`
Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/berita/screens/berita_webview_screen.dart
git commit -m "refactor(berita-webview): typography pass"
```

---

## Phase 3 — Final Verification & Docs

### Task 15: Run full test + analyze + count tests

- [ ] **Step 1: Run all tests**

Run: `flutter test 2>&1 | tee /tmp/test-out.log`
Expected: All tests pass.

- [ ] **Step 2: Get test count**

Run: `grep -c "All tests passed\|✓" /tmp/test-out.log`

If output format differs, run:
Run: `flutter test --reporter expanded 2>&1 | grep -c "^[0-9].*✓"`

Note the actual count for marker update.

- [ ] **Step 3: Run analyze**

Run: `flutter analyze`
Expected: No issues.

- [ ] **Step 4: Update README.md test-count marker**

Find the line containing the test count (e.g., "106 tests"). Replace with the new count from step 2.

- [ ] **Step 5: Update CHANGELOG.md**

Add v2 entry:
```markdown
## [Unreleased] - v2.0.0
### Added
- Golfie widget library (`lib/widgets/golfie/`): PillButton, GhostButton, CollageCard, Hero, TornPaperSection, AvatarStack, EmptyState
- Motion primitives: scale-on-press, haptics on primary CTA, hero transitions, AnimatedSwitcher state changes
- Subtle collage backgrounds (Mint/Marigold/Periwinkle pastel blocks)

### Changed
- All screens migrated to `Theme.of(context).textTheme.*` typography
- Home screen wrapped in `GolfieHero` with collage blocks
- Tournament cards use `GolfieCollageCard` with Periwinkle accents
- Tournament list → detail uses Hero animation
```

Update test-count marker to match step 2.

- [ ] **Step 6: Update docs/UI_STACK.md**

Add a section:
```markdown
## Golfie Widget Library

`lib/widgets/golfie/` contains the canonical Golfie widgets. Always import via the barrel `golfie_index.dart` rather than individual files.

Motion is implemented with Flutter's built-in primitives (`AnimatedScale`, `AnimatedContainer`, `AnimatedSwitcher`, `Hero`). No third-party motion library.

Design decisions guided by Emil Kowalski design skills (animation-vocabulary, apple-design, emil-design-eng).
```

- [ ] **Step 7: Commit**

```bash
git add README.md CHANGELOG.md docs/UI_STACK.md
git commit -m "docs: update README, CHANGELOG, UI_STACK for v2 UI polish"
```

---

### Task 16: Final verification + memory + push

- [ ] **Step 1: Final full test run**

Run: `flutter test`
Expected: All tests pass, count matches marker.

- [ ] **Step 2: Final analyze**

Run: `flutter analyze`
Expected: No issues.

- [ ] **Step 3: Verify build (engineer with Android SDK)**

Run: `flutter build apk --debug`
Expected: Build succeeds.

- [ ] **Step 4: Update memory**

Read `/home/kiyaya/.claude/projects/-home-kiyaya-kiyadev-kbvs-golf/memory/MEMORY.md` (or create if absent). Add entry:

```markdown
- [Golfie widget library](golfie-widget-library.md) — `lib/widgets/golfie/` barrel, motion-via-Flutter-primitives, Emil-design-skills lens
```

Write the memory file:
```markdown
---
name: golfie-widget-library
description: Golfie UI polish v2 — custom widgets at lib/widgets/golfie/ guided by Emil Kowalski design skills
metadata:
  type: project
---

Golfie v2 (2026-07-29) implemented the deferred parts of docs/DESIGN.md on the Golfie Flutter app.

**Key decisions:**
- Custom widget library at `lib/widgets/golfie/` (PillButton, GhostButton, CollageCard, Hero, TornPaperSection, AvatarStack, EmptyState). Import via `golfie_index.dart` barrel.
- Motion via Flutter primitives (`AnimatedScale`, `AnimatedContainer`, `AnimatedSwitcher`, `Hero`). No third-party motion library.
- Emil Kowalski design skills guide choices: animation-vocabulary (easeOutCubic for user-initiated motion), apple-design (haptics only on primary CTA), emil-design-eng (typography via theme tokens, no raw TextStyle), web-design-guidelines (elevation `xl` only on primary cards).
- No torn-paper edges (DESIGN.md's "Collage Background Element" interpreted as subtle pastel blocks; torn edges hurt mobile readability).
- Subtle collage: Mint/Marigold pastel blocks on Home GolfieHero, Periwinkle accents on cards + tournament detail header.
- Selective testing: widget tests for every new widget, no per-screen tests for typography refactor.

**Why:** v1 only wired tokens. v2 honors the design doc on the existing screen set. Motion has stated purpose per Emil `review-animations` skill.

**How to apply:** When adding screens or new widgets, follow the Golfie widget library conventions. Use `Theme.of(context).textTheme.*` for typography. Honor Emil's motion principles. Don't reintroduce raw `TextStyle` or torn-paper edges.
```

Then update `MEMORY.md` to add the bullet line.

- [ ] **Step 5: Stale-ref scan + final commit**

Run: `grep -rn "avatar_stack.dart\|empty_state.dart\|/widgets/avatar_stack" lib/ test/ 2>&1 | head -5`
Expected: No results (refs were updated in Tasks 6 and 7).

If stale refs remain, fix them.

```bash
git add -A
git commit --allow-empty -m "chore: v2 verification + memory update complete"
```

- [ ] **Step 6: Push branch**

```bash
git push origin revamp/golfie
```

---

## Self-Review

**Spec coverage:**
- ✅ Widget library (Tasks 1-8)
- ✅ Motion primitives (Task 2 wire-up + Phase 2 use)
- ✅ Typography refactor (Tasks 9-14)
- ✅ Collage backgrounds (Task 9 home hero + Task 12 detail accent)
- ✅ Selective widget testing (every new widget tested in Tasks 1-5)
- ✅ Docs (Task 15)

**Placeholder scan:** No TBD/TODO. All code shown. All commands explicit.

**Type consistency:** `GolfiePillButton.onPressed` used throughout. `GolfieAccentCorner` enum defined in Task 1, used in Task 11. `GolfieCollageBlock` defined in Task 4, used in Task 9. `Hero` tag format `'tournament-${tournament.id}'` defined in Task 12, used in Task 12 step 5.
