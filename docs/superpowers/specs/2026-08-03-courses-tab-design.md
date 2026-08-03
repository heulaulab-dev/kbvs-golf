# Courses/Map Tab — Design Spec

**Date:** 2026-08-03
**Branch:** `feature/profile-settings` (continuing) → will merge as part of it or separate
**Status:** Approved

## Problem

No way to browse golf courses in the app. Tournaments carry courseName/courseLocation but there's no course directory. UI_STACK.md planned a "Courses" tab with map integration.

## Goals

1. 5th bottom nav tab "Courses" (Home/News/Tournaments/Courses/Profile).
2. Course directory with area filter chips.
3. Course detail screen with stats + static mock map placeholder.
4. Mock data (real Jakarta course names, mock coordinates) — API not ready.

## Architecture

### New files

```
lib/courses/
├── models/course.dart                 # Course model
├── repositories/mock_course_repository.dart  # 8 mock courses
├── providers/courses_provider.dart    # ChangeNotifier, filter logic
└── screens/
    ├── courses_screen.dart            # Directory list + filter chips
    └── course_detail_screen.dart      # Detail + map placeholder
```

### Course model

```dart
class Course {
  final String id;
  final String name;
  final String location;      // "Jl. Pondok Indah, Jakarta Selatan"
  final String area;          // "South Jakarta" (filter key)
  final int holes;            // 18
  final int par;              // 72
  final int greenFeeIdr;      // for Rp formatting
  final double latitude;      // mock coord
  final double longitude;
  final bool isFeatured;
}
```

### Mock repository — 8 real Jakarta courses

| Name | Area | Holes | Par | Green fee (mock) |
|------|------|-------|-----|------------------|
| Pondok Indah Golf Club | South | 18 | 72 | 750000 |
| Senayan Golf (Jakarta GC) | Central | 18 | 72 | 650000 |
| Emeralda Golf Club | South | 27 | 108 | 900000 |
| Damai Indah Golf | North | 18 | 72 | 700000 |
| Cengkareng Golf Club | West | 18 | 72 | 500000 |
| Jagorawi Golf & CC | East | 18 | 72 | 800000 |
| Rancamaya Golf | South | 18 | 72 | 850000 |
| Riverside Golf Club | East | 18 | 72 | 600000 |

Coordinates: approximate real lat/lng for each (e.g., Pondok Indah ~ -6.27, 106.78).

### CoursesProvider

```dart
class CoursesProvider extends ChangeNotifier {
  final CourseRepository repository;
  List<Course> _courses = [];
  String _areaFilter = 'All';
  bool _loading = true;

  List<Course> get filteredCourses => _areaFilter == 'All'
      ? _courses
      : _courses.where((c) => c.area == _areaFilter).toList();

  Future<void> load() async { ... }
  void setAreaFilter(String area) { ... }
}
```

### CoursesScreen

- AppBar "Courses" (canvas bg, ink title)
- Area filter chips: All, South Jakarta, West Jakarta, North Jakarta, Central Jakarta, East Jakarta — horizontal scroll, mint selected
- List of course cards: name, location · holes, green fee (Rp format via NumberFormat id_ID), par, FEATURED badge (marigold)
- Tap → CourseDetailScreen

### CourseDetailScreen

- Header: name, area
- Stats row: 18 holes | Par 72 | Rp 750.000 (three white stat boxes)
- **Map placeholder:** sky-gradient container with location pin icon + coordinates text + "Map coming soon" — no google_maps_flutter dep yet
- "Tournaments here": count from `ChangesNotifierTournamentProvider` filtered by courseName == course.name
- Back button

### HomeScreen change

5th tab added to IndexedStack + NavigationBar:

```dart
NavigationDestination(
  icon: Icon(Icons.map_outlined),
  selectedIcon: Icon(Icons.map),
  label: 'Courses',
),
```

### Data flow

- `CoursesProvider.load()` → `MockCourseRepository.getCourses()` (returns after 300ms simulated delay)
- Registered in main.dart MultiProvider
- Filter client-side

### Design system

- Canvas bg (#fff3e7), white cards (16px radius, ash border, subtle shadow)
- Ink text, graphite secondary, stone tertiary
- Mint selected chip, marigold FEATURED badge
- Matches existing screens

## Verification

1. `flutter analyze` clean.
2. App runs: 5 tabs, Courses shows 8 mock courses.
3. Area filter works client-side.
4. Course detail: stats, map placeholder, tournament count.
5. Tab state preserved (IndexedStack).

## Out of scope

- Real Google Maps (`google_maps_flutter`) — deferred until API/keys ready
- Real course API — mock only
- Course booking/tee time — not in product scope per RESEARCH.md
- Photos — text-only cards for now

## User action required

None.
