# Berita List Feature — Design Spec

**Date:** 2026-07-29
**Status:** Approved (pending PRD amendment)
**Author:** Claude Opus 4.8

## Goal

Add a "Berita" (Indonesian golf news) tab to the KBVS Golf app. Users see a curated
trending list on tab open, can search, and tap into an in-app webview for the full
article. Backend aggregates news via Google Custom Search Engine (CSE) with a
hardcoded seed fallback for development.

## Preconditions

1. **PRD amendment required before implementation.** `prd/PRD_Engr.md` line 34
   currently lists "Berita Turnamen" as out of MVP scope. Move it into MVP and
   reflect the new tab count (5 → 6) in the nav spec.
2. **Design skill rule.** Before any UI work (component shape, layout, motion,
   typography, color, interaction), load the Emil Kowalski design skills from
   https://github.com/emilkowalski/skills via the Skill tool. Apply guidance
   before writing screen code. This applies to the Flutter screens AND the
   backend seed data shape (which mirrors the UI).
3. **Env vars required for production CSE.** `GOOGLE_CSE_KEY` and `GOOGLE_CSE_CX`
   must be set in `golfie-api/.env` for non-mock mode. Without them, the
   `USE_MOCK` flag forces seed fallback.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Flutter app (kbvs-golf)                                     │
├─────────────────────────────────────────────────────────────┤
│  UI:     lib/berita/screens/berita_list_screen.dart          │
│          lib/berita/screens/berita_webview_screen.dart       │
│  State:  lib/berita/providers/berita_provider.dart           │
│  Repo:   lib/berita/repositories/berita_repository.dart      │
│          lib/berita/repositories/http_berita_repository.dart │
│          lib/berita/repositories/mock_berita_repository.dart│
│  Model:  lib/berita/models/berita.dart                       │
│  Net:    reuses lib/tournament/services/dio_http_client.dart │
│  Nav:    lib/main.dart — 6th tab added                       │
│  Tests:  test/berita/ (model, repo, provider, screen)       │
└─────────────────────────────────────────────────────────────┘
                            │ HTTP GET /news/search?q=...&...
                            │           /news/trending?limit=...
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  golfie-api (Node/Express, mounted at /news/*)                │
├─────────────────────────────────────────────────────────────┤
│  src/index.ts          ← bootstraps Express                  │
│  src/routes/news.ts    ← GET /search, GET /trending           │
│  src/services/google_cse.ts  ← Google CSE client              │
│  src/services/og_scraper.ts  ← OpenGraph metadata extractor   │
│  src/services/cache.ts       ← In-memory TTL cache            │
│  src/data/seed.ts      ← Hardcoded fallback list              │
│  src/types.ts          ← BeritaItem type (mirror Flutter)    │
│  tests/                ← Jest unit tests for routes          │
└─────────────────────────────────────────────────────────────┘
```

The Flutter `lib/berita/` folder structure mirrors `lib/tournament/` to keep the
codebase consistent.

## Domain model

`lib/berita/models/berita.dart`:

```dart
class Berita {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String sourceUrl;
  final String sourceName;
  final DateTime publishedAt;
  final String category;
  final List<String> tags;

  const Berita({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.sourceUrl,
    required this.sourceName,
    required this.publishedAt,
    this.category = '',
    this.tags = const [],
  });

  factory Berita.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

`category` and `tags` come from Google CSE `pagemap.metatags.article:section`
and `article:tag` when available; otherwise empty. The seed list has static
values.

## API contract

| Endpoint | Parameters | Returns |
|---|---|---|
| `GET /news/trending` | `?limit=20&category= (optional)` | `{ results: Berita[], total: int, has_next: bool }` |
| `GET /news/search` | `?q=...&limit=20&cursor= (optional)` | `{ results: Berita[], total: int, has_next: bool }` |

`has_next` is always false in v1 (no pagination yet). Cursor is stubbed for
forward compat.

Mount point: `api-local.kbvalbury.com:9100/news/*`. The existing tournament
backend will register the golfie-api router under `/news`.

## UI flow

1. **Tab open** → `BeritaListScreen` mounted → `provider.loadTrending()`.
2. **Loading** → skeleton cards (3 placeholders).
3. **Empty** → "Belum ada berita" (Bahasa Indonesia — app is in Bahasa).
4. **Error** → standard error card with retry button (mirrors
   `tournament_list_screen`).
5. **User types in search bar** → debounced 400ms → `provider.search(query)`.
6. **Cards** → image (cached_network_image), title, summary 2-line clamp,
   source name + relative date, category chip. Tap → `BeritaWebviewScreen`.
7. **Webview** → full-screen, AppBar with back button + sourceName title,
   share button (url_launcher).

**Visual direction:** All screens must apply the Emil Kowalski design skills
before implementation. Specifically:
- `design-taste-frontend` — overall taste/altitude.
- `apple-design` — base conventions (motion, typography, hierarchy).
- `animation-vocabulary` — for the card press state and webview transition.
- `find-animation-opportunities` — once the static layout lands, identify what
  should move.

## Backend behavior

**`/news/trending` with `USE_MOCK=true`:**
- Returns hardcoded `seed.ts` list (10 items, Indonesian golf news topics).

**`/news/trending` with `USE_MOCK=false`:**
- Calls Google CSE with query `"golf turnamen Indonesia"`.
- For each result, runs OG scraper to extract image/snippet.
- Caches in memory with 24h TTL (in-process Map; no Redis in v1).

**`/news/search` with `USE_MOCK=true`:**
- Filters seed list by `q` (case-insensitive match on title/summary).

**`/news/search` with `USE_MOCK=false`:**
- Calls Google CSE with the user's query.

Both endpoints share an internal `fetchBerita(query, limit)` that picks CSE vs
seed based on the env flag.

**Cache TTL:** 24h for search results, 7d for OG metadata. In-memory only.
Restart loses cache — acceptable for v1.

## State management

`lib/berita/providers/berita_provider.dart` follows the same `ChangeNotifier`
pattern as `lib/tournament/providers/changes_notifier_tournament_provider.dart`:

```dart
class BeritaProvider extends ChangeNotifier {
  final BeritaRepository _repository;
  List<Berita> _items = [];
  String _searchQuery = '';
  String? _errorText;
  bool _isLoading = false;
  // ...
}
```

Wire into `main.dart` `MultiProvider` alongside the existing providers.

## Navigation

Add a 6th tab to `lib/main.dart` bottom nav: Home | Tournaments | **Berita** |
Courses | Players | More. The PRD nav spec needs updating to reflect the new
count.

## Testing

**Flutter tests** (mirroring tournament test layout):

- `test/berita/models/berita_test.dart` — JSON parsing, equality, default
  sort, tag normalization.
- `test/berita/repositories/mock_berita_repository_test.dart` — seed
  consistency, search filter, category filter.
- `test/berita/repositories/http_berita_repository_test.dart` — same shape as
  `http_tournament_repository_test.dart`: stubbed `HttpClient`, verifies
  URLs/params built correctly.
- `test/berita/providers/berita_provider_test.dart` — load trending, search,
  error states (mirrors `changes_notifier_tournament_provider_test.dart`).
- `test/berita/screens/berita_list_screen_test.dart` — renders cards, empty
  state, search debounce, error retry, tap → webview.
- `test/berita/screens/berita_webview_screen_test.dart` — renders, back button,
  share button.

**Backend tests:**

- `golfie-api/tests/seed.test.ts` — seed list shape.
- `golfie-api/tests/routes.test.ts` — `/news/trending` and `/news/search` with
  `USE_MOCK=true`, via supertest.
- `golfie-api/tests/google_cse.test.ts` — CSE integration mocked (skipped
  unless `GOOGLE_CSE_KEY` set).

**Test count contract:** README marker must be bumped from 72 → new total after
tests land. The `tool/verify_test_count.sh` guard will catch mismatches.

## Dependencies to add

**Flutter (`pubspec.yaml`):**

- `webview_flutter: ^4.5.0` — for in-app browser

**Backend (`golfie-api/package.json`):**

- `express` — HTTP server
- `cors` — CORS middleware
- `dotenv` — env var loading
- `axios` — Google CSE HTTP calls
- `open-graph-scraper` — OG metadata extraction
- `typescript`, `ts-node`, `@types/node`, `@types/express`, `@types/cors` (dev)
- `jest`, `ts-jest`, `@types/jest`, `supertest`, `@types/supertest` (dev)

## Out of scope (v1)

- Pagination beyond single page (no `has_next` truthy yet).
- Bookmarks / save-for-later.
- Push notifications for new berita.
- AI summarization (already deferred to M3+ in PRD).
- Redis caching (in-memory only).
- Editor-side content authoring (consumers of Google CSE, not producers).
- iOS-specific webview config (no iOS project yet).

## Implementation order

1. **PRD amendment**: move berita from "Out (MVP)" to "In (MVP)" in
   `prd/PRD_Engr.md`; update nav spec from 5 to 6 tabs.
2. **Backend scaffold**: `golfie-api/` with `package.json`, `tsconfig.json`,
   basic Express server, `src/index.ts`, env loading.
3. **Backend data**: `src/types.ts`, `src/data/seed.ts` (10 items).
4. **Backend routes**: `src/routes/news.ts` with `/trending` and `/search`
   using `USE_MOCK` flag.
5. **Backend CSE**: `src/services/google_cse.ts` with axios + OG scraper.
6. **Backend cache**: `src/services/cache.ts` in-memory TTL.
7. **Backend tests**: `golfie-api/tests/`.
8. **Flutter model**: `lib/berita/models/berita.dart`.
9. **Flutter repos**: `berita_repository.dart` (abstract), `http_berita_repository.dart`,
   `mock_berita_repository.dart`.
10. **Flutter provider**: `berita_provider.dart` (ChangeNotifier).
11. **UI design pass**: load Emil Kowalski skills, design screens per
    guidance, then build.
12. **Flutter screens**: `berita_list_screen.dart`, `berita_webview_screen.dart`.
13. **Flutter tests**: `test/berita/`.
14. **Wire nav**: update `lib/main.dart` with 6th tab.
15. **README + CHANGELOG**: update tree, bump test-count marker, add changelog
    entry.
16. **Verify**: run `bash tool/verify_test_count.sh`; commit; push.

## Risks

- **Google CSE quota/cost.** Each search call costs ~$5 per 1000 queries.
  Hardcoded seed fallback via `USE_MOCK=true` prevents accidental production
  spend during development.
- **OG scraper flakiness.** External sites change markup. Wrap in try/catch
  and fall back to CSE snippet only.
- **No iOS webview config.** Out of scope per audit item 1 (no `ios/` project
  exists). Note for future: `ios/Runner/Info.plist` will need ATS exception
  for the article source domains when iOS is added.
- **Stale seed list.** `src/data/seed.ts` will rot. Add a TODO to revisit
  every quarter.