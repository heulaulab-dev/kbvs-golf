# Golfie — Research

> Scope: Jakarta-focused golf club app. Flutter frontend, basic auth + OAuth2, competition data discovery, competitor analysis (reclub.co/id).

---

## 1. Reclub Analysis (https://reclub.co/id)

### Tech Stack
- **Frontend:** Nuxt.js (Vue), Inter font, SPA
- **Backend:** Node/Express API at `api.reclub.co`
- **Inferred GraphQL** (from `<link rel="preconnect" href="https://api.reclub.co">` in HTML)

### Public API Discovery — NONE
All standard endpoint probes returned 404:
- `api.reclub.co/v1/competitions` → 404
- `api.reclub.co/api/competitions` → 404
- `api.reclub.co/api/graphql` → 404
- `api.reclub.co/api-docs/swagger` → 404

The backend is private. No developer documentation published. No mobile SDK exposed.

### Content Model
Reclub is **user-generated content**, not data aggregation:
- Users (club admins, players) create tournaments via in-app forms
- Admin moderation gate
- Published to app feed
- No external data sources, no scraping

**Implication for us:** We can't replicate Reclub by copying their data. We need our own content pipeline.

---

## 2. Jakarta Golf Competition Data Sources

### Public APIs Found — NONE
Checked:
| Source | Status |
|--------|--------|
| www.figoolf.or.id | Federation site, no public API |
| golf.co.id | Static site, no API |
| jakartagolf.asia | Inaccessible |
| Google Places API | Returns golf courses metadata (name, location, contact), NOT competitions |
| Reclub public endpoints | All 404 |

### Where Jakarta Golf Competition Data Actually Lives
- **Facebook Pages** of golf courses (Ryu Golf, Menteng Country Club, etc.)
- **WhatsApp groups** for tournament registration
- **PDF scorecards** scattered across club websites
- **Event photos** on Instagram

### Viable Data Strategies

| Approach | Effort | Reliability | Notes |
|----------|--------|-------------|-------|
| In-app submission form (admin moderated) | Low | High | PRIMARY — same model as Reclub |
| CSV upload from partner clubs | Medium | High | SECONDARY — start with 3-5 clubs |
| Scrape FB/IG via Graph API | Medium-High | Low | Fragile, ToS risk, avoid |
| FIGOLF partnership | High | Very High | LONG TERM — talk to them directly |

### Recommendation
**Build our own content pipeline.** No public API exists to leverage. Start with user-submitted tournaments moderated by admin. Grow via club partnerships for direct CSV feeds.

---

## 4. Search Engine + OpenGraph Approach ("Berita Turnamen")

### Concept
Don't scrape competition schedules (they're not public/structured). Instead:
1. **User searches** for tournament-related queries in the app: "tournament golf Jakarta", "turnamen golf akhir pekan", "Emeralda open 2026", etc.
2. **Backend hits search engine API** (Google Custom Search, Bing Web Search, or DuckDuckGo) for those queries
3. **Fetch OpenGraph metadata** for each result URL (`og:title`, `og:description`, `og:image`)
4. **Render as link cards** in a dedicated "Berita Turnamen" tab — title, snippet, thumbnail, source domain, date
5. **User taps card** → opens original article in in-app webview (or external browser)

This is **not** an in-app tournament calendar. It's a **discoverability layer** — the user gets a curated feed of news/articles/announcements about Jakarta golf tournaments, not the tournament registration flow itself.

### Why This Works
- **No ToS friction** for search engines (Google CSE has free tier, Bing has free tier) — we're using their public APIs, not scraping them.
- **Low technical risk** — search APIs are stable, OpenGraph is a public spec, both are well-documented.
- **Real Jakarta context** — when a tournament gets press coverage (media partner posts, club announcements, federation updates), it appears in search results and surfaces in the app.
- **Covers gaps** our manual pipeline misses — news articles about upcoming tournaments, registration deadlines, press releases.

### Search API Options

| Provider | Free Tier | Pricing | Quality for ID | Notes |
|----------|-----------|---------|----------------|-------|
| **Google Custom Search** | 100 queries/day | $5/1k queries after | Best | Indonesian language well-supported; CSE setup requires creating a search engine ID |
| **Bing Web Search** | 1000 queries/month | $3/1k queries after | Good | Free tier is generous for MVP; Indonesian results adequate |
| **DuckDuckGo (via scraping proxy)** | Unlimited | Free | Inconsistent | No official API; needs proxy rotation; unreliable |
| **Brave Search API** | 1000 queries/month | $5/1k after | Good | Privacy-focused, indie-friendly pricing |
| **SerpAPI / Serper.dev** | 50–100 queries | ~$1.50/1k after | Best (real Google SERP) | Aggregator, fast setup, costs add up |

**Recommendation:** Start with **Google Custom Search** (best quality, easiest integration). Migrate to Brave or Serper.dev if quota gets exhausted.

### OpenGraph Extraction

For each result URL, fetch and parse HTML for these tags:

```html
<meta property="og:title" content="Emeralda Open 2026 Dimulai Mei" />
<meta property="og:description" content="Turnamen golf tahunan Emeralda..." />
<meta property="og:image" content="https://emeralda.com/og-image.jpg" />
<meta property="og:url" content="https://emeralda.com/news/emeralda-open-2026" />
<meta property="og:site_name" content="Emeralda Golf" />
<meta property="article:published_time" content="2026-05-01" />
```

Fallback chain when OG tags missing:
1. Try `og:*` tags
2. Try Twitter Card tags (`twitter:title`, `twitter:description`, `twitter:image`)
3. Try `<title>` and `<meta name="description">` as last resort
4. Try first `<img>` in body as fallback thumbnail (lowest quality fallback)

**Implementation library (Node.js):** `open-graph-scraper` (npm) — battle-tested, handles fallbacks.
**Implementation library (Python):** `opengraph` (pip) — same purpose.

### Architecture Pattern

```
Flutter App
  ↓
  GET /api/news/search?q=tournament+golf+jakarta
  ↓
Backend API (Node.js/FastAPI)
  ↓ (cache hit? → return cached results)
  ↓ (miss)
  ↓
Google Custom Search API → 10 result URLs + snippets
  ↓
For each URL (parallel, max 5 concurrent):
  ↓
  Fetch HTML → parse og:* tags → cache OG data
  ↓
Aggregate results, return JSON to Flutter
  ↓
Render as link cards in "Berita Turnamen" tab
```

**Caching strategy:**
- Cache search results: 24h TTL (queries rarely change)
- Cache OG metadata: 7 days TTL (OG rarely changes; refresh if 410/404)
- Cache invalidation: manual only — when admins flag stale results

### Backend Endpoint Contract

```json
GET /api/news/search?q=tournament+golf+jakarta&limit=10
Authorization: Bearer <jwt>

Response 200:
{
  "results": [
    {
      "id": "uuid-or-hash",
      "title": "Emeralda Open 2026 Dimulai Bulan Mei",
      "description": "Turnamen golf tahunan Emeralda akan dimulai...",
      "image_url": "https://emeralda.com/og-image.jpg",
      "source_url": "https://emeralda.com/news/emeralda-open-2026",
      "source_domain": "emeralda.com",
      "source_name": "Emeralda Golf Club",
      "published_at": "2026-05-01T08:00:00Z",
      "fetched_at": "2026-07-28T10:15:00Z",
      "query": "tournament golf jakarta"
    }
  ],
  "total": 47,
  "cached": false
}
```

### Frontend UI Spec (Berita Turnamen Tab)

- **Section header:** "Berita Turnamen" with subtitle "Curated articles about Jakarta golf tournaments"
- **Search bar:** Persistent at top, autocomplete disabled (each search is a discrete query)
- **Result cards:** Vertical scroll, image-on-top layout, 16px radius, 12px shadow
- **Card content:**
  - Image (16:9 ratio, lazy-loaded with skeleton)
  - Title (heading-sm, 2-line max with ellipsis)
  - Description (body-md, 3-line max, gray-500)
  - Footer row: source domain (left) + published date (right)
- **Tap action:** Open `source_url` in in-app webview (`webview_flutter` package)
- **Empty state:** "No articles found. Try different keywords like 'turnamen golf' or specific club names."

### Cost Estimate at MVP

- **Google CSE free tier:** 100 queries/day = ~3,000/month. At MVP (200 users/day, 30% search = 60 queries/day), free tier covers us.
- **After free tier:** $5/1k queries × 5k queries/month = $25/month ≈ Rp 400,000.
- **Compute:** OG fetching ~500ms average per URL × 10 results = 5s sequential, 1s parallel (5 concurrent). Negligible cost on backend.
- **Storage:** OG cache ≈ 2KB per URL × 10k URLs = 20MB. Trivial.

### Recommended Stack (Backend)

```json
// Node.js (or equivalent in FastAPI for Python)
"googleapis": "^126.0.0",         // Google Custom Search API client
"open-graph-scraper": "^6.5.0",   // OG tag extraction with fallbacks
"node-fetch": "^2.7.0",           // HTML fetching
"cheerio": "^1.0.0-rc.12",        // HTML parsing (if manual extraction needed)
"express-rate-limit": "^7.1.0",   // Rate limit /api/news/search per user
"redis": "^4.6.7"                 // OG + search results cache
```

### Flutter Client Dependencies

```yaml
# For in-app webview (when user taps a result)
webview_flutter: ^4.7.0

# For image lazy-loading with skeleton (already in stack)
cached_network_image: ^3.3.0
```

### Limitations & Honest Caveats

- **Not a structured tournament calendar.** This won't have registration links, fees, dates — it's a news feed. Users still need to tap through to the source.
- **Coverage depends on press coverage.** Tournaments that get no media coverage won't appear. Most small/local Jakarta tournaments won't have articles.
- **OG images sometimes broken/missing.** Always have image fallback (gray placeholder card).
- **Search engine bias.** Results are ranked by Google's algorithm, not by relevance to Jakarta golfers. May surface SEO-spam sites.
- **Some sites block scrapers.** If a domain returns 403/blocked HTML, skip it silently and show other results.

### Roadmap: Phase 2 Enhancement

Once MVP is live with this search-based discovery layer:
- **Add admin-flagged "trusted sources"** whitelist (Emeralda, Royale Jakarta Golf Club, FIGOLF site) so their articles always show in result rankings.
- **AI-powered re-ranking** of results using Claude Haiku — score relevance of each result to actual tournament content (filter out clickbait).
- **Push notifications** when new search results match user's bookmarked queries.

### Why NOT to Scraping Without APIs

Direct web scraping (using Puppeteer, Playwright, or scrapy against arbitrary Jakarta golf sites) is **not recommended** because:
- Fragile — DOM changes break scrapers within weeks
- ToS risk — most sites forbid scraping in their terms
- IP bans — get blocked fast at scale
- Legal exposure — Indonesian UU ITE implications unclear
- Maintenance cost — high ongoing engineering burden for low payoff

Stick with search engine APIs + OG extraction. Clean, legal, maintainable.

---

## 3. Flutter Auth Patterns

### Basic Auth
Use `dio` + `AuthInterceptor`. Encode credentials, inject header on each request.

### OAuth2 (pub.dev/packages/oauth2 v2.0.5)
Supports:
- Authorization Code Grant (recommended for mobile with PKCE)
- Client Credentials Grant
- Resource Owner Password Grant

### Recommended Stack
```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP & Auth
  dio: ^5.4.0
  oauth2: ^2.0.5
  flutter_secure_storage: ^9.0.0

  # Social Login (optional)
  google_sign_in: ^6.1.4
```

### Architecture Pattern
1. PKCE Authorization Code Grant for OAuth
2. Token storage in `flutter_secure_storage` (encrypted)
3. `dio` interceptor auto-injects `Authorization: Bearer ***`
4. Refresh token interceptor handles expiry silently
5. Basic auth only for internal admin endpoints (separate from user OAuth)

---

## 4. Recommended MVP Architecture (Jakarta-focused)

### Frontend (Flutter)
| Layer | Choice | Reason |
|-------|--------|--------|
| Navigation | `go_router` | Modern, declarative |
| State | `riverpod` | Simpler than Bloc for MVP |
| HTTP | `dio` | Built-in interceptors |
| Secure storage | `flutter_secure_storage` | Encrypted, cross-platform |
| Maps | `google_maps_flutter` | Course locations |

### Backend (build our own)
- Node.js/Express or FastAPI (Python) + PostgreSQL
- JWT-based auth (basic auth endpoint → returns JWT for session)
- OAuth2 via Supabase Auth or Auth0 (or roll your own)
- Admin portal for tournament/course management

### Data Strategy (Phase 1)
1. Tournament submission form (app side) → DB → admin approve → publish
2. Weekly CSV export/import from partner club secretaries
3. No scraping — start user-generated, grow partner network

### Timeline Estimate
MVP (Jakarta-only, 3-5 clubs): ~2-3 weeks full-stack dev.

---

## 5. References
- Reclub site: https://reclub.co/id
- Reclub backend: https://api.reclub.co (private, no public endpoints)
- oauth2 Dart package: https://pub.dev/packages/oauth2
- google_maps_flutter: https://pub.dev/packages/google_maps_flutter
- flutter_secure_storage: https://pub.dev/packages/flutter_secure_storage

---

*Last updated: 2026-07-28*
*Research by: Hermes (Windah)*