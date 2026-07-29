# Berita List Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a "Berita" (Indonesian golf news) feature to the KBVS Golf Flutter app, backed by a new Node/Express service (`golfie-api/`) that aggregates news via Google Custom Search with a hardcoded seed fallback.

**Architecture:**
- **Backend** (`golfie-api/`): TypeScript/Express service mounted at `/news/*` on `api-local.kbvalbury.com:9100`. Routes: `GET /news/trending`, `GET /news/search`. Internal Google CSE + OpenGraph scraper behind a `USE_MOCK=true` flag that returns a hardcoded seed list. In-memory TTL cache.
- **Flutter app** (`lib/berita/`): mirrors `lib/tournament/` structure — model, repository (abstract + HTTP + mock), provider (`ChangeNotifier`), screens (list + webview). Reuses existing `lib/tournament/services/dio_http_client.dart` for HTTP. Cards use `cached_network_image`, taps open `webview_flutter`.

**Tech Stack:**
- Backend: Node 20+, TypeScript 5, Express 4, axios, open-graph-scraper, Jest + supertest
- Flutter: Dart SDK >=3.5, webview_flutter ^4.5.0, existing dependencies (provider, dio, cached_network_image, url_launcher)

**Note on navigation:** The current `lib/screens/home_screen.dart` does NOT have a bottom navigation bar — it uses `Navigator.push` from a button on the home screen. This plan adds a Berita button to the home screen matching the existing pattern (Browse Tournaments, Admin Moderation, Submit). A true bottom-nav refactor is out of scope for v1.

**UI rule:** Before implementing the two Flutter screens, load the Emil Kowalski design skills via the Skill tool (`design-taste-frontend`, `apple-design`, `animation-vocabulary`, `find-animation-opportunities`). Apply guidance before writing widget code. This rule is saved as project memory at `~/.claude/projects/-home-kiyaya-kiyadev-kbvs-golf/memory/emil-design-skills-rule.md`.

---

## File Structure

**Backend (`golfie-api/`)**
- `package.json` — npm manifest, scripts (`dev`, `test`, `build`)
- `tsconfig.json` — TypeScript config (strict mode, Node target ES2022)
- `.env.example` — template for GOOGLE_CSE_KEY, GOOGLE_CSE_CX, USE_MOCK, PORT
- `jest.config.js` — ts-jest preset
- `src/index.ts` — Express bootstrap, mounts `/news` router, listens on PORT
- `src/types.ts` — `BeritaItem` interface (mirror of Flutter model)
- `src/data/seed.ts` — hardcoded 10-item list
- `src/services/cache.ts` — in-memory TTL Map<string, {value, expiresAt}>
- `src/services/google_cse.ts` — axios + open-graph-scraper wrapper
- `src/routes/news.ts` — Express router with `/trending` and `/search`
- `tests/seed.test.ts` — validates seed shape
- `tests/routes.test.ts` — supertest against the router with USE_MOCK=true

**Flutter app**
- `lib/berita/models/berita.dart` — domain class with `fromJson`/`toJson`
- `lib/berita/repositories/berita_repository.dart` — abstract (2 methods)
- `lib/berita/repositories/http_berita_repository.dart` — Dio-backed
- `lib/berita/repositories/mock_berita_repository.dart` — seed-backed
- `lib/berita/providers/berita_provider.dart` — `ChangeNotifier`
- `lib/berita/screens/berita_list_screen.dart` — list + search
- `lib/berita/screens/berita_webview_screen.dart` — in-app browser
- `lib/berita/widgets/berita_card.dart` — card widget (kept separate for reuse)
- `lib/berita/widgets/berita_skeleton.dart` — loading placeholder card
- `test/berita/models/berita_test.dart`
- `test/berita/repositories/mock_berita_repository_test.dart`
- `test/berita/repositories/http_berita_repository_test.dart`
- `test/berita/providers/berita_provider_test.dart`
- `test/berita/screens/berita_list_screen_test.dart`
- `test/berita/screens/berita_webview_screen_test.dart`

**Modified files**
- `pubspec.yaml` — add `webview_flutter`
- `lib/main.dart` — register `BeritaProvider`
- `lib/screens/home_screen.dart` — add "Browse Berita" button
- `prd/PRD_Engr.md` — move berita from "Out (MVP)" to "In (MVP)"; update nav count
- `README.md` — bump `<!-- test-count: 72 -->` to new total; update project tree
- `CHANGELOG.md` — add entry under `[Unreleased]`

---

## Task 1: Amend PRD

**Files:**
- Modify: `prd/PRD_Engr.md`

- [ ] **Step 1: Read current PRD scope section**

Run: `grep -n "Berita\|MVP\|berita\|berita turnamen" prd/PRD_Engr.md`
Expected: A line under "Out (MVP)" listing "Berita Turnamen" tab.

- [ ] **Step 2: Remove berita from "Out (MVP)" and add to MVP features list**

Edit `prd/PRD_Engr.md`:
- Delete the line `"Berita Turnamen" tab (news aggregator with Google CSE + OG extraction)` from the Out-of-MVP list.
- Add a new bullet to the In-MVP feature list: `- "Berita" tab — news aggregator (Google Custom Search + OpenGraph extraction), with hardcoded seed fallback for dev. Backed by golfie-api service mounted at /news/*.`
- Update any "5-tab bottom nav" wording to "6-tab bottom nav" (Home | Tournaments | Berita | Courses | Players | More).

- [ ] **Step 3: Commit**

```bash
git add prd/PRD_Engr.md
git commit -m "docs(prd): move Berita from Out-of-MVP to MVP feature set"
```

---

## Task 2: Scaffold golfie-api

**Files:**
- Create: `golfie-api/package.json`
- Create: `golfie-api/tsconfig.json`
- Create: `golfie-api/.env.example`
- Create: `golfie-api/jest.config.js`
- Create: `golfie-api/.gitignore`

- [ ] **Step 1: Create package.json**

```json
{
  "name": "golfie-api",
  "version": "0.1.0",
  "private": true,
  "description": "KBVS Golf berita (news) backend service.",
  "main": "dist/index.js",
  "scripts": {
    "dev": "ts-node src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest"
  },
  "dependencies": {
    "axios": "^1.7.0",
    "cors": "^2.8.5",
    "dotenv": "^16.4.5",
    "express": "^4.19.2",
    "open-graph-scraper": "^6.0.0"
  },
  "devDependencies": {
    "@types/cors": "^2.8.17",
    "@types/express": "^4.17.21",
    "@types/jest": "^29.5.12",
    "@types/node": "^20.12.7",
    "@types/supertest": "^6.0.2",
    "jest": "^29.7.0",
    "supertest": "^7.0.0",
    "ts-jest": "^29.1.2",
    "ts-node": "^10.9.2",
    "typescript": "^5.4.5"
  }
}
```

- [ ] **Step 2: Create tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

- [ ] **Step 3: Create jest.config.js**

```js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  testMatch: ['**/*.test.ts'],
};
```

- [ ] **Step 4: Create .env.example**

```
# golfie-api configuration. Copy to .env and fill in.
USE_MOCK=true
PORT=9200

# Required only when USE_MOCK=false. Get these from
# https://programmablesearchengine.google.com/
GOOGLE_CSE_KEY=
GOOGLE_CSE_CX=
```

- [ ] **Step 5: Create .gitignore**

```
node_modules/
dist/
.env
*.log
```

- [ ] **Step 6: Install dependencies**

Run: `cd golfie-api && npm install`
Expected: `node_modules/` created, no errors.

- [ ] **Step 7: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add golfie-api/package.json golfie-api/tsconfig.json golfie-api/jest.config.js golfie-api/.env.example golfie-api/.gitignore golfie-api/package-lock.json
git commit -m "feat(golfie-api): scaffold Express + TypeScript backend"
```

---

## Task 3: Define BeritaItem type and seed list

**Files:**
- Create: `golfie-api/src/types.ts`
- Create: `golfie-api/src/data/seed.ts`

- [ ] **Step 1: Create types.ts**

```ts
export interface BeritaItem {
  id: string;
  title: string;
  summary: string;
  imageUrl: string;
  sourceUrl: string;
  sourceName: string;
  publishedAt: string; // ISO 8601
  category: string;
  tags: string[];
}

export interface BeritaListResponse {
  results: BeritaItem[];
  total: number;
  has_next: boolean;
}
```

- [ ] **Step 2: Create seed.ts**

```ts
import { BeritaItem } from '../types';

export const SEED_BERITA: BeritaItem[] = [
  {
    id: 'seed-1',
    title: 'Turnamen Golf Amatir Jakarta 2026 Resmi Dibuka',
    summary: 'Pendaftaran turnamen golf amatir tahunan Jakarta dibuka mulai 1 Agustus dengan total hadiah Rp 50 juta.',
    imageUrl: 'https://picsum.photos/seed/golf1/600/400',
    sourceUrl: 'https://example.com/news/jakarta-amateur-2026',
    sourceName: 'Detik Sport',
    publishedAt: '2026-07-25T08:00:00Z',
    category: 'Tournament',
    tags: ['jakarta', 'amatir', '2026'],
  },
  {
    id: 'seed-2',
    title: 'Padang Golf PIK 2 Jadi Tuan Rumah Indonesian Open',
    summary: 'Padang golf PIK 2 ditunjuk menjadi tuan rumah Indonesian Open 2026 setelah renovasi besar-besaran.',
    imageUrl: 'https://picsum.photos/seed/golf2/600/400',
    sourceUrl: 'https://example.com/news/pik2-indonesian-open',
    sourceName: 'Kompas',
    publishedAt: '2026-07-22T14:30:00Z',
    category: 'Course News',
    tags: ['pik2', 'indonesian-open'],
  },
  {
    id: 'seed-3',
    title: 'Atlet Golf Indonesia Raih Peringkat 3 Asia Tenggara',
    summary: 'Setelah kemenangan di Singapore Open, atlet Indonesia naik ke peringkat 3 regional Asia Tenggara.',
    imageUrl: 'https://picsum.photos/seed/golf3/600/400',
    sourceUrl: 'https://example.com/news/atlet-peringkat-3',
    sourceName: 'CNN Indonesia',
    publishedAt: '2026-07-20T10:15:00Z',
    category: 'Players',
    tags: ['atlet', 'peringkat'],
  },
  {
    id: 'seed-4',
    title: 'Tips Memilih Stick Golf untuk Pemula',
    summary: 'Panduan memilih stick golf yang tepat untuk pemula, lengkap dengan rekomendasi harga.',
    imageUrl: 'https://picsum.photos/seed/golf4/600/400',
    sourceUrl: 'https://example.com/news/stick-untuk-pemula',
    sourceName: 'Bola.com',
    publishedAt: '2026-07-18T09:00:00Z',
    category: 'Tips',
    tags: ['pemula', 'equipment'],
  },
  {
    id: 'seed-5',
    title: 'Klub Golf Bandung Buka Driving Range Baru',
    summary: 'Klub golf tertua di Bandung menambah driving range berteknologi TrackMan untuk latihan presisi.',
    imageUrl: 'https://picsum.photos/seed/golf5/600/400',
    sourceUrl: 'https://example.com/news/bandung-driving-range',
    sourceName: 'Tribunnews',
    publishedAt: '2026-07-15T16:45:00Z',
    category: 'Course News',
    tags: ['bandung', 'driving-range'],
  },
  {
    id: 'seed-6',
    title: 'Jadwal Lengkap PGA Tour Asia 2026',
    summary: 'PGA Tour Asia公布了2026年完整赛程，包括7站赛事在东南亚地区。',
    imageUrl: 'https://picsum.photos/seed/golf6/600/400',
    sourceUrl: 'https://example.com/news/pga-asia-2026',
    sourceName: 'Antara',
    publishedAt: '2026-07-12T11:20:00Z',
    category: 'Tournament',
    tags: ['pga', 'asia', 'jadwal'],
  },
  {
    id: 'seed-7',
    title: 'Cuaca Ekstrem, Turnamen Surabaya Ditunda',
    summary: 'Hujan deras dan angin kencang memaksa panitia menunda turnamen Surabaya Open hingga akhir pekan.',
    imageUrl: 'https://picsum.photos/seed/golf7/600/400',
    sourceUrl: 'https://example.com/news/surabaya-ditunda',
    sourceName: 'Jawa Pos',
    publishedAt: '2026-07-10T07:30:00Z',
    category: 'Tournament',
    tags: ['surabaya', 'cuaca'],
  },
  {
    id: 'seed-8',
    title: 'Review: Driver TaylorMade Qi35 untuk Handicap 15-20',
    summary: 'Ulasan lengkap driver TaylorMade Qi35 dengan teknologi Speed Pocket terbaru.',
    imageUrl: 'https://picsum.photos/seed/golf8/600/400',
    sourceUrl: 'https://example.com/news/taylormade-qi35-review',
    sourceName: 'Golf Digest Indonesia',
    publishedAt: '2026-07-08T13:00:00Z',
    category: 'Equipment',
    tags: ['taylormade', 'driver', 'review'],
  },
  {
    id: 'seed-9',
    title: 'Komunitas Golf Wanita Bandung Tumbuh 40%',
    summary: 'Komunitas golf wanita di Bandung melaporkan pertumbuhan keanggotan 40% year-over-year.',
    imageUrl: 'https://picsum.photos/seed/golf9/600/400',
    sourceUrl: 'https://example.com/news/wanita-bandung-40',
    sourceName: 'Republika',
    publishedAt: '2026-07-05T09:45:00Z',
    category: 'Community',
    tags: ['wanita', 'komunitas', 'bandung'],
  },
  {
    id: 'seed-10',
    title: 'Atlet Junior Indonesia Bersaing di World Amateur',
    summary: 'Tiga atlet junior Indonesia lolos kualifikasi World Amateur di Singapura bulan depan.',
    imageUrl: 'https://picsum.photos/seed/golf10/600/400',
    sourceUrl: 'https://example.com/news/junior-world-amateur',
    sourceName: 'Tempo',
    publishedAt: '2026-07-01T15:10:00Z',
    category: 'Players',
    tags: ['junior', 'world-amateur'],
  },
];
```

- [ ] **Step 3: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add golfie-api/src/types.ts golfie-api/src/data/seed.ts
git commit -m "feat(golfie-api): add BeritaItem type and 10-item seed list"
```

---

## Task 4: Build in-memory TTL cache

**Files:**
- Create: `golfie-api/src/services/cache.ts`

- [ ] **Step 1: Write cache.ts**

```ts
interface CacheEntry<T> {
  value: T;
  expiresAt: number;
}

export class TTLCache<T> {
  private store = new Map<string, CacheEntry<T>>();

  constructor(private defaultTtlMs: number = 24 * 60 * 60 * 1000) {}

  get(key: string): T | undefined {
    const entry = this.store.get(key);
    if (!entry) return undefined;
    if (Date.now() > entry.expiresAt) {
      this.store.delete(key);
      return undefined;
    }
    return entry.value;
  }

  set(key: string, value: T, ttlMs?: number): void {
    const ttl = ttlMs ?? this.defaultTtlMs;
    this.store.set(key, { value, expiresAt: Date.now() + ttl });
  }

  clear(): void {
    this.store.clear();
  }
}

export const newsCache = new TTLCache<unknown>(24 * 60 * 60 * 1000);
export const ogCache = new TTLCache<unknown>(7 * 24 * 60 * 60 * 1000);
```

- [ ] **Step 2: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add golfie-api/src/services/cache.ts
git commit -m "feat(golfie-api): add in-memory TTL cache for news and OG metadata"
```

---

## Task 5: Implement Google CSE + OG scraper service

**Files:**
- Create: `golfie-api/src/services/google_cse.ts`

- [ ] **Step 1: Write google_cse.ts**

```ts
import axios from 'axios';
import * as ogs from 'open-graph-scraper';
import { BeritaItem } from '../types';
import { ogCache, newsCache } from './cache';

const CSE_ENDPOINT = 'https://www.googleapis.com/customsearch/v1';

interface CseResult {
  title: string;
  link: string;
  snippet: string;
  displayLink: string;
  pagemap?: {
    metatags?: Array<Record<string, string>>;
  };
}

interface CseResponse {
  items?: CseResult[];
}

function extractMeta(pagemap: CseResult['pagemap'], key: string): string {
  const tags = pagemap?.metatags ?? [];
  for (const t of tags) {
    if (t[key]) return t[key];
  }
  return '';
}

async function enrichWithOg(item: BeritaItem): Promise<BeritaItem> {
  const cached = ogCache.get(item.sourceUrl);
  if (cached) return cached as BeritaItem;
  try {
    const { result } = await ogs({ url: item.sourceUrl, timeout: 8 });
    const ogImage = result.ogImage?.[0]?.url ?? item.imageUrl;
    const ogDescription = result.ogDescription ?? item.summary;
    const sectionMeta = extractMeta(
      { metatags: [{ 'article:section': item.category }] } as CseResult['pagemap'],
      'article:section'
    );
    const enriched: BeritaItem = {
      ...item,
      imageUrl: ogImage || item.imageUrl,
      summary: ogDescription || item.summary,
      category: sectionMeta || item.category,
    };
    ogCache.set(item.sourceUrl, enriched);
    return enriched;
  } catch {
    return item; // fallback to CSE-only data
  }
}

export async function fetchFromGoogleCse(
  query: string,
  limit: number,
  apiKey: string,
  cx: string
): Promise<BeritaItem[]> {
  const cacheKey = `cse:${query}:${limit}`;
  const cached = newsCache.get(cacheKey);
  if (cached) return cached as BeritaItem[];

  const { data } = await axios.get<CseResponse>(CSE_ENDPOINT, {
    params: { key: apiKey, cx, q: query, num: Math.min(limit, 10) },
    timeout: 10000,
  });

  const raw: BeritaItem[] = (data.items ?? []).map((r, idx) => ({
    id: `cse-${query}-${idx}`,
    title: r.title,
    summary: r.snippet,
    imageUrl: extractMeta(r.pagemap, 'og:image') || extractMeta(r.pagemap, 'twitter:image'),
    sourceUrl: r.link,
    sourceName: r.displayLink,
    publishedAt: new Date().toISOString(),
    category: extractMeta(r.pagemap, 'article:section'),
    tags: (() => {
      const tagsRaw = extractMeta(r.pagemap, 'article:tag');
      return tagsRaw ? tagsRaw.split(',').map((s) => s.trim()).filter(Boolean) : [];
    })(),
  }));

  const enriched = await Promise.all(raw.map(enrichWithOg));
  newsCache.set(cacheKey, enriched);
  return enriched;
}
```

- [ ] **Step 2: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add golfie-api/src/services/google_cse.ts
git commit -m "feat(golfie-api): add Google CSE + OG scraper integration"
```

---

## Task 6: Build /news router

**Files:**
- Create: `golfie-api/src/routes/news.ts`

- [ ] **Step 1: Write news.ts**

```ts
import { Router } from 'express';
import { BeritaItem, BeritaListResponse } from '../types';
import { SEED_BERITA } from '../data/seed';
import { fetchFromGoogleCse } from '../services/google_cse';

export const newsRouter = Router();

function filterSeed(query: string, category?: string): BeritaItem[] {
  const q = query.trim().toLowerCase();
  let list = SEED_BERITA;
  if (category) list = list.filter((b) => b.category.toLowerCase() === category.toLowerCase());
  if (q) {
    list = list.filter(
      (b) =>
        b.title.toLowerCase().includes(q) ||
        b.summary.toLowerCase().includes(q)
    );
  }
  return list;
}

async function fetchBerita(query: string, limit: number, category?: string): Promise<BeritaItem[]> {
  const useMock = (process.env.USE_MOCK ?? 'true').toLowerCase() === 'true';
  if (useMock) return filterSeed(query, category).slice(0, limit);

  const apiKey = process.env.GOOGLE_CSE_KEY;
  const cx = process.env.GOOGLE_CSE_CX;
  if (!apiKey || !cx) {
    console.warn('USE_MOCK=false but GOOGLE_CSE_KEY/CX missing — falling back to seed');
    return filterSeed(query, category).slice(0, limit);
  }

  const items = await fetchFromGoogleCse(query, limit, apiKey, cx);
  if (category) return items.filter((b) => b.category.toLowerCase() === category.toLowerCase());
  return items;
}

function buildResponse(items: BeritaItem[]): BeritaListResponse {
  return { results: items, total: items.length, has_next: false };
}

newsRouter.get('/trending', async (req, res, next) => {
  try {
    const limit = Math.max(1, Math.min(50, Number(req.query.limit ?? 20)));
    const category = typeof req.query.category === 'string' ? req.query.category : undefined;
    const items = await fetchBerita('golf turnamen Indonesia', limit, category);
    res.json(buildResponse(items));
  } catch (e) {
    next(e);
  }
});

newsRouter.get('/search', async (req, res, next) => {
  try {
    const q = typeof req.query.q === 'string' ? req.query.q : '';
    const limit = Math.max(1, Math.min(50, Number(req.query.limit ?? 20)));
    const items = await fetchBerita(q, limit);
    res.json(buildResponse(items));
  } catch (e) {
    next(e);
  }
});
```

- [ ] **Step 2: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add golfie-api/src/routes/news.ts
git commit -m "feat(golfie-api): add /news/trending and /news/search routes"
```

---

## Task 7: Bootstrap Express app

**Files:**
- Create: `golfie-api/src/index.ts`

- [ ] **Step 1: Write index.ts**

```ts
import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { newsRouter } from './routes/news';

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'golfie-api' });
});

app.use('/news', newsRouter);

// eslint-disable-next-line @typescript-eslint/no-unused-vars
app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error('[golfie-api] error:', err);
  res.status(500).json({ error: err.message });
});

const port = Number(process.env.PORT ?? 9200);
app.listen(port, () => {
  console.log(`[golfie-api] listening on :${port}`);
});

export { app };
```

- [ ] **Step 2: Smoke-test the server starts**

Run: `cd golfie-api && PORT=9201 USE_MOCK=true timeout 3 npm run dev 2>&1 | head -10`
Expected: Output includes `[golfie-api] listening on :9201`. If TypeScript errors appear, fix them before continuing.

- [ ] **Step 3: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add golfie-api/src/index.ts
git commit -m "feat(golfie-api): bootstrap Express app with /news mount and error handler"
```

---

## Task 8: Backend tests for seed and routes

**Files:**
- Create: `golfie-api/tests/seed.test.ts`
- Create: `golfie-api/tests/routes.test.ts`

- [ ] **Step 1: Write seed.test.ts**

```ts
import { SEED_BERITA } from '../src/data/seed';
import { BeritaItem } from '../src/types';

describe('SEED_BERITA', () => {
  it('has at least 10 items', () => {
    expect(SEED_BERITA.length).toBeGreaterThanOrEqual(10);
  });

  it('every item satisfies BeritaItem shape', () => {
    for (const item of SEED_BERITA as BeritaItem[]) {
      expect(item.id).toBeTruthy();
      expect(item.title).toBeTruthy();
      expect(item.summary).toBeTruthy();
      expect(item.imageUrl).toMatch(/^https?:\/\//);
      expect(item.sourceUrl).toMatch(/^https?:\/\//);
      expect(item.sourceName).toBeTruthy();
      expect(() => new Date(item.publishedAt).toISOString()).not.toThrow();
    }
  });

  it('ids are unique', () => {
    const ids = SEED_BERITA.map((b) => b.id);
    expect(new Set(ids).size).toBe(ids.length);
  });
});
```

- [ ] **Step 2: Write routes.test.ts**

```ts
process.env.USE_MOCK = 'true';
import request from 'supertest';
import { app } from '../src/index';

describe('GET /news/trending', () => {
  it('returns paginated response with seed list', async () => {
    const res = await request(app).get('/news/trending?limit=5');
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('results');
    expect(res.body).toHaveProperty('total');
    expect(res.body.has_next).toBe(false);
    expect(res.body.results.length).toBeLessThanOrEqual(5);
  });

  it('filters by category when provided', async () => {
    const res = await request(app).get('/news/trending?category=Tournament');
    expect(res.status).toBe(200);
    for (const item of res.body.results) {
      expect(item.category).toBe('Tournament');
    }
  });
});

describe('GET /news/search', () => {
  it('returns matches for known query', async () => {
    const res = await request(app).get('/news/search?q=jakarta');
    expect(res.status).toBe(200);
    expect(res.body.results.length).toBeGreaterThan(0);
    for (const item of res.body.results) {
      const haystack = (item.title + ' ' + item.summary).toLowerCase();
      expect(haystack).toContain('jakarta');
    }
  });

  it('returns empty list for nonsense query', async () => {
    const res = await request(app).get('/news/search?q=zzzzzzzzz_nothing_matches');
    expect(res.status).toBe(200);
    expect(res.body.results).toEqual([]);
    expect(res.body.total).toBe(0);
  });
});

describe('GET /health', () => {
  it('returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});
```

- [ ] **Step 3: Run tests**

Run: `cd golfie-api && npm test`
Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add golfie-api/tests/seed.test.ts golfie-api/tests/routes.test.ts
git commit -m "test(golfie-api): cover seed shape and /news routes"
```

---

## Task 9: Flutter Berita model

**Files:**
- Create: `lib/berita/models/berita.dart`
- Test: `test/berita/models/berita_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/berita/models/berita_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kbvs_golf/berita/models/berita.dart';

void main() {
  group('Berita.fromJson', () {
    test('parses full payload', () {
      final json = {
        'id': 'b1',
        'title': 'Title',
        'summary': 'Snippet',
        'imageUrl': 'https://img.test/x.jpg',
        'sourceUrl': 'https://example.com/article',
        'sourceName': 'Example News',
        'publishedAt': '2026-07-25T08:00:00Z',
        'category': 'Tournament',
        'tags': ['jakarta', 'amatir'],
      };
      final b = Berita.fromJson(json);
      expect(b.id, 'b1');
      expect(b.title, 'Title');
      expect(b.summary, 'Snippet');
      expect(b.imageUrl, 'https://img.test/x.jpg');
      expect(b.sourceUrl, 'https://example.com/article');
      expect(b.sourceName, 'Example News');
      expect(b.publishedAt.toUtc().toIso8601String(), '2026-07-25T08:00:00.000Z');
      expect(b.category, 'Tournament');
      expect(b.tags, ['jakarta', 'amatir']);
    });

    test('defaults category and tags when missing', () {
      final json = {
        'id': 'b2',
        'title': 'T',
        'summary': 'S',
        'imageUrl': 'https://img.test/y.jpg',
        'sourceUrl': 'https://example.com/y',
        'sourceName': 'Y',
        'publishedAt': '2026-07-01T00:00:00Z',
      };
      final b = Berita.fromJson(json);
      expect(b.category, '');
      expect(b.tags, isEmpty);
    });

    test('toJson round-trips', () {
      final json = {
        'id': 'b3',
        'title': 'T',
        'summary': 'S',
        'imageUrl': 'https://img.test/z.jpg',
        'sourceUrl': 'https://example.com/z',
        'sourceName': 'Z',
        'publishedAt': '2026-07-01T00:00:00.000Z',
        'category': 'News',
        'tags': ['x'],
      };
      final original = Berita.fromJson(json);
      final round = Berita.fromJson(original.toJson());
      expect(round.id, original.id);
      expect(round.title, original.title);
      expect(round.tags, original.tags);
      expect(round.publishedAt.toUtc(), original.publishedAt.toUtc());
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/berita/models/berita_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:kbvs_golf/berita/models/berita.dart'`

- [ ] **Step 3: Create the model**

Create `lib/berita/models/berita.dart`:

```dart
/// Domain model for a berita (news article) item.
///
/// Mirror of `golfie-api/src/types.ts` BeritaItem. Field names use camelCase
/// to match Dart conventions; JSON parsing handles the wire-format mapping.
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

  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      imageUrl: json['imageUrl'] as String,
      sourceUrl: json['sourceUrl'] as String,
      sourceName: json['sourceName'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String).toUtc(),
      category: (json['category'] as String?) ?? '',
      tags: ((json['tags'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'imageUrl': imageUrl,
      'sourceUrl': sourceUrl,
      'sourceName': sourceName,
      'publishedAt': publishedAt.toUtc().toIso8601String(),
      'category': category,
      'tags': tags,
    };
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/berita/models/berita_test.dart`
Expected: PASS — 3 tests, 0 failures.

- [ ] **Step 5: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add lib/berita/models/berita.dart test/berita/models/berita_test.dart
git commit -m "feat(berita): add Berita model with JSON parsing"
```

---

## Task 10: Flutter abstract repository

**Files:**
- Create: `lib/berita/repositories/berita_repository.dart`

- [ ] **Step 1: Create the abstract class**

```dart
import '../models/berita.dart';

/// Abstract repository interface for berita data.
///
/// All implementations (mock, real HTTP) must satisfy this contract.
/// Returns a paginated tuple (results, total, hasNext) — mirroring the
/// shape used by [TournamentRepository] for consistency.
abstract class BeritaRepository {
  /// Returns the trending berita feed (default query when no user input).
  Future<(List<Berita>, int, bool)> getTrending({
    int limit = 20,
    String? category,
  });

  /// Returns berita matching [query] (empty string returns empty result
  /// to avoid accidental seed floods).
  Future<(List<Berita>, int, bool)> search(String query, {int limit = 20});
}
```

- [ ] **Step 2: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add lib/berita/repositories/berita_repository.dart
git commit -m "feat(berita): add abstract BeritaRepository interface"
```

---

## Task 11: Flutter mock repository

**Files:**
- Create: `lib/berita/repositories/mock_berita_repository.dart`
- Test: `test/berita/repositories/mock_berita_repository_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/berita/repositories/mock_berita_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kbvs_golf/berita/models/berita.dart';
import 'package:kbvs_golf/berita/repositories/mock_berita_repository.dart';

Berita _b(String id, {String title = 'T', String summary = 'S', String category = 'News', List<String> tags = const []}) {
  return Berita(
    id: id,
    title: title,
    summary: summary,
    imageUrl: 'https://img.test/$id.jpg',
    sourceUrl: 'https://example.com/$id',
    sourceName: 'Source $id',
    publishedAt: DateTime.utc(2026, 7, 25),
    category: category,
    tags: tags,
  );
}

void main() {
  group('MockBeritaRepository.getTrending', () {
    test('returns all seeded items when no category filter', () async {
      final repo = MockBeritaRepository(items: [_b('1'), _b('2'), _b('3')]);
      final (results, total, hasNext) = await repo.getTrending();
      expect(results, hasLength(3));
      expect(total, 3);
      expect(hasNext, false);
    });

    test('filters by category', () async {
      final repo = MockBeritaRepository(items: [
        _b('1', category: 'Tournament'),
        _b('2', category: 'Course News'),
        _b('3', category: 'Tournament'),
      ]);
      final (results, total, _) = await repo.getTrending(category: 'Tournament');
      expect(results.map((b) => b.id), ['1', '3']);
      expect(total, 2);
    });

    test('respects limit', () async {
      final repo = MockBeritaRepository(items: List.generate(10, (i) => _b('$i')));
      final (results, _, _) = await repo.getTrending(limit: 3);
      expect(results, hasLength(3));
    });
  });

  group('MockBeritaRepository.search', () {
    test('case-insensitive match on title', () async {
      final repo = MockBeritaRepository(items: [
        _b('1', title: 'Jakarta Open'),
        _b('2', title: 'Bandung Cup'),
      ]);
      final (results, _, _) = await repo.search('jakarta');
      expect(results.map((b) => b.id), ['1']);
    });

    test('match on summary', () async {
      final repo = MockBeritaRepository(items: [
        _b('1', title: 'A', summary: 'laporan dari bandung'),
        _b('2', title: 'B', summary: 'laporan dari jakarta'),
      ]);
      final (results, _, _) = await repo.search('Bandung');
      expect(results.map((b) => b.id), ['1']);
    });

    test('empty query returns empty list', () async {
      final repo = MockBeritaRepository(items: [_b('1')]);
      final (results, total, _) = await repo.search('');
      expect(results, isEmpty);
      expect(total, 0);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/berita/repositories/mock_berita_repository_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 3: Create the mock implementation**

Create `lib/berita/repositories/mock_berita_repository.dart`:

```dart
import '../models/berita.dart';
import 'berita_repository.dart';

/// In-memory [BeritaRepository] for tests and local dev.
class MockBeritaRepository implements BeritaRepository {
  final List<Berita> _items;

  MockBeritaRepository({List<Berita>? items})
      : _items = List<Berita>.from(items ?? const []);

  @override
  Future<(List<Berita>, int, bool)> getTrending({
    int limit = 20,
    String? category,
  }) async {
    var list = _items;
    if (category != null && category.isNotEmpty) {
      list = list.where((b) => b.category.toLowerCase() == category.toLowerCase()).toList();
    }
    final sliced = list.take(limit).toList();
    return (sliced, sliced.length, false);
  }

  @override
  Future<(List<Berita>, int, bool)> search(String query, {int limit = 20}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return (<Berita>[], 0, false);
    final matches = _items.where((b) =>
        b.title.toLowerCase().contains(q) ||
        b.summary.toLowerCase().contains(q)).toList();
    final sliced = matches.take(limit).toList();
    return (sliced, sliced.length, false);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/berita/repositories/mock_berita_repository_test.dart`
Expected: PASS — 7 tests.

- [ ] **Step 5: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add lib/berita/repositories/mock_berita_repository.dart test/berita/repositories/mock_berita_repository_test.dart
git commit -m "feat(berita): add MockBeritaRepository with tests"
```

---

## Task 12: Flutter HTTP repository

**Files:**
- Create: `lib/berita/repositories/http_berita_repository.dart`
- Test: `test/berita/repositories/http_berita_repository_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/berita/repositories/http_berita_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kbvs_golf/berita/repositories/http_berita_repository.dart';
import 'package:kbvs_golf/tournament/services/http_client.dart';

/// Fake [HttpClient] that returns canned responses for testing.
class FakeHttpClient implements HttpClient {
  final dynamic Function(String url, Map<String, String>?) _handler;
  FakeHttpClient(this._handler);

  final List<String> urls = [];
  final List<Map<String, String>?> params = [];

  @override
  Future<dynamic> getJson(String url, {Map<String, String>? queryParameters}) async {
    urls.add(url);
    params.add(queryParameters);
    return _handler(url, queryParameters);
  }
}

Map<String, dynamic> _beritaJson(String id) => {
      'id': id,
      'title': 'Title $id',
      'summary': 'Summary $id',
      'imageUrl': 'https://img.test/$id.jpg',
      'sourceUrl': 'https://example.com/$id',
      'sourceName': 'Source $id',
      'publishedAt': '2026-07-25T08:00:00Z',
      'category': 'News',
      'tags': ['x'],
    };

Map<String, dynamic> _paginated(List<Map<String, dynamic>> items) => {
      'results': items,
      'total': items.length,
      'has_next': false,
    };

void main() {
  group('HttpBeritaRepository.getTrending', () {
    test('hits /news/trending with limit', () async {
      final fake = FakeHttpClient((url, _) => _paginated([_beritaJson('a'), _beritaJson('b')]));
      final repo = HttpBeritaRepository(client: fake, baseUrl: 'https://api.test');
      final (results, total, hasNext) = await repo.getTrending(limit: 2);

      expect(fake.urls, ['https://api.test/news/trending']);
      expect(fake.params.single, {'limit': '2'});
      expect(results, hasLength(2));
      expect(total, 2);
      expect(hasNext, false);
      expect(results.first.id, 'a');
    });

    test('passes category when provided', () async {
      final fake = FakeHttpClient((url, _) => _paginated([]));
      final repo = HttpBeritaRepository(client: fake, baseUrl: 'https://api.test');
      await repo.getTrending(category: 'Tournament');

      expect(fake.params.single, {'limit': '20', 'category': 'Tournament'});
    });
  });

  group('HttpBeritaRepository.search', () {
    test('hits /news/search with q param', () async {
      final fake = FakeHttpClient((url, _) => _paginated([_beritaJson('x')]));
      final repo = HttpBeritaRepository(client: fake, baseUrl: 'https://api.test');
      final (results, _, _) = await repo.search('jakarta');

      expect(fake.urls, ['https://api.test/news/search']);
      expect(fake.params.single, {'q': 'jakarta', 'limit': '20'});
      expect(results.first.id, 'x');
    });

    test('throws FormatException on malformed response', () async {
      final fake = FakeHttpClient((url, _) => 'not a map');
      final repo = HttpBeritaRepository(client: fake, baseUrl: 'https://api.test');
      expect(() => repo.getTrending(), throwsA(isA<FormatException>()));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/berita/repositories/http_berita_repository_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 3: Create the HTTP implementation**

Create `lib/berita/repositories/http_berita_repository.dart`:

```dart
import '../../tournament/services/http_client.dart';
import '../models/berita.dart';
import 'berita_repository.dart';

/// Real HTTP [BeritaRepository] backed by [HttpClient].
///
/// Reuses the existing [HttpClient] abstraction from the tournament
/// subsystem so the app only needs one HTTP client implementation.
class HttpBeritaRepository implements BeritaRepository {
  final HttpClient _client;
  final String _baseUrl;

  HttpBeritaRepository({
    HttpClient? client,
    String baseUrl = 'api-local.kbvalbury.com:9100',
  }) : _client = client ?? _defaultClient(),
       _baseUrl = baseUrl;

  static HttpClient _defaultClient() {
    // Late bind to avoid pulling Dio into tests.
    // Caller is expected to construct with a real client in main.dart.
    throw UnimplementedError(
      'HttpBeritaRepository used without a client; pass one explicitly.',
    );
  }

  (List<Berita>, int, bool) _parse(dynamic resp) {
    if (resp is! Map<String, dynamic>) {
      throw FormatException('Expected map response, got ${resp.runtimeType}');
    }
    final List<dynamic> results = (resp['results'] ?? []) as List;
    final int total = (resp['total'] ?? results.length) as int;
    final bool hasNext = (resp['has_next'] as bool?) ?? false;
    final items = results.map((r) => Berita.fromJson(r as Map<String, dynamic>)).toList();
    return (items, total, hasNext);
  }

  @override
  Future<(List<Berita>, int, bool)> getTrending({
    int limit = 20,
    String? category,
  }) async {
    final params = <String, String>{'limit': '$limit'};
    if (category != null && category.isNotEmpty) params['category'] = category;
    final resp = await _client.getJson('$_baseUrl/news/trending', queryParameters: params);
    return _parse(resp);
  }

  @override
  Future<(List<Berita>, int, bool)> search(String query, {int limit = 20}) async {
    final q = query.trim();
    if (q.isEmpty) return (<Berita>[], 0, false);
    final resp = await _client.getJson(
      '$_baseUrl/news/search',
      queryParameters: {'q': q, 'limit': '$limit'},
    );
    return _parse(resp);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/berita/repositories/http_berita_repository_test.dart`
Expected: PASS — 5 tests.

- [ ] **Step 5: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add lib/berita/repositories/http_berita_repository.dart test/berita/repositories/http_berita_repository_test.dart
git commit -m "feat(berita): add HttpBeritaRepository with tests"
```

---

## Task 13: Flutter provider (ChangeNotifier)

**Files:**
- Create: `lib/berita/providers/berita_provider.dart`
- Test: `test/berita/providers/berita_provider_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/berita/providers/berita_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kbvs_golf/berita/models/berita.dart';
import 'package:kbvs_golf/berita/providers/berita_provider.dart';
import 'package:kbvs_golf/berita/repositories/berita_repository.dart';

class _FakeRepo implements BeritaRepository {
  final List<Berita> trendingItems;
  final List<Berita> searchItems;
  Exception? trendingError;
  Exception? searchError;

  _FakeRepo({this.trendingItems = const [], this.searchItems = const []});

  @override
  Future<(List<Berita>, int, bool)> getTrending({int limit = 20, String? category}) async {
    if (trendingError != null) throw trendingError!;
    return (trendingItems, trendingItems.length, false);
  }

  @override
  Future<(List<Berita>, int, bool)> search(String query, {int limit = 20}) async {
    if (searchError != null) throw searchError!;
    return (searchItems, searchItems.length, false);
  }
}

Berita _b(String id) => Berita(
      id: id,
      title: 'T $id',
      summary: 'S $id',
      imageUrl: 'https://img/$id.jpg',
      sourceUrl: 'https://example.com/$id',
      sourceName: 'Src $id',
      publishedAt: DateTime.utc(2026, 7, 25),
    );

void main() {
  group('BeritaProvider.loadTrending', () {
    test('populates items on success', () async {
      final repo = _FakeRepo(trendingItems: [_b('1'), _b('2')]);
      final p = BeritaProvider(repository: repo);
      await p.loadTrending();
      expect(p.items, hasLength(2));
      expect(p.isLoading, false);
      expect(p.errorText, isNull);
    });

    test('captures exception into errorText', () async {
      final repo = _FakeRepo()..trendingError = Exception('boom');
      final p = BeritaProvider(repository: repo);
      await p.loadTrending();
      expect(p.errorText, contains('boom'));
      expect(p.items, isEmpty);
    });
  });

  group('BeritaProvider.search', () {
    test('updates searchQuery and replaces items', () async {
      final repo = _FakeRepo(searchItems: [_b('s1')]);
      final p = BeritaProvider(repository: repo);
      await p.search('jakarta');
      expect(p.searchQuery, 'jakarta');
      expect(p.items.map((b) => b.id), ['s1']);
    });

    test('empty search clears items without hitting repo', () async {
      final repo = _FakeRepo();
      final p = BeritaProvider(repository: repo);
      await p.search('');
      expect(p.items, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/berita/providers/berita_provider_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 3: Create the provider**

Create `lib/berita/providers/berita_provider.dart`:

```dart
import 'package:flutter/foundation.dart';

import '../models/berita.dart';
import '../repositories/berita_repository.dart';

/// State for the Berita tab. Mirrors the tournament provider pattern.
class BeritaProvider extends ChangeNotifier {
  final BeritaRepository _repository;

  List<Berita> _items = [];
  String _searchQuery = '';
  String? _errorText;
  bool _isLoading = false;

  BeritaProvider({required BeritaRepository repository})
      : _repository = repository;

  List<Berita> get items => List.unmodifiable(_items);
  String get searchQuery => _searchQuery;
  String? get errorText => _errorText;
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty && _errorText == null && !_isLoading;

  Future<void> loadTrending() async {
    _isLoading = true;
    _errorText = null;
    _searchQuery = '';
    notifyListeners();
    try {
      final (results, _, _) = await _repository.getTrending();
      _items = results;
    } catch (e) {
      _errorText = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    final q = query.trim();
    _searchQuery = q;
    if (q.isEmpty) {
      _items = [];
      _errorText = null;
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorText = null;
    notifyListeners();
    try {
      final (results, _, _) = await _repository.search(q);
      _items = results;
    } catch (e) {
      _errorText = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/berita/providers/berita_provider_test.dart`
Expected: PASS — 5 tests.

- [ ] **Step 5: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add lib/berita/providers/berita_provider.dart test/berita/providers/berita_provider_test.dart
git commit -m "feat(berita): add BeritaProvider ChangeNotifier with tests"
```

---

## Task 14: UI design pass

**Files:** None (consultation only)

- [ ] **Step 1: Load Emil Kowalski design skills**

Invoke the following skills via the Skill tool, in order:
1. `design-taste-frontend` — overall visual altitude and taste references.
2. `apple-design` — base motion, typography, hierarchy conventions.
3. `animation-vocabulary` — vocabulary for the card press state, list item transitions, webview push transition.
4. `find-animation-opportunities` — once you've sketched the static layout, identify which elements should move.

- [ ] **Step 2: Produce a short design note**

Write a brief inline summary in your response (do NOT commit) covering:
- Typography choice for title/summary/source
- Card spacing rhythm (margins, padding)
- Image aspect ratio (current intent: 16:9 / 600x400 from seed)
- Press state animation (scale? opacity? both?)
- Webview transition (Material page route vs custom Hero?)
- Empty state copy ("Belum ada berita") typography

This is the contract for the screens in Task 15.

---

## Task 15: Flutter BeritaCard + BeritaSkeleton widgets

**Files:**
- Create: `lib/berita/widgets/berita_card.dart`
- Create: `lib/berita/widgets/berita_skeleton.dart`

- [ ] **Step 1: Create BeritaCard**

Create `lib/berita/widgets/berita_card.dart`:

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/berita.dart';

/// Tap target for the berita list. Renders image, title, summary,
/// source name + relative date, category chip.
class BeritaCard extends StatelessWidget {
  final Berita berita;
  final VoidCallback onTap;

  const BeritaCard({
    super.key,
    required this.berita,
    required this.onTap,
  });

  String _relativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt.toLocal());
    if (diff.inDays > 7) {
      return DateFormat('d MMM y').format(dt.toLocal());
    }
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return 'baru';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: berita.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, _) => Container(color: theme.colorScheme.surfaceContainerHighest),
                errorWidget: (context, _, __) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (berita.category.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Chip(
                        label: Text(berita.category),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  Text(
                    berita.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    berita.summary,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${berita.sourceName} · ${_relativeDate(berita.publishedAt)}',
                    style: theme.textTheme.labelSmall,
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

- [ ] **Step 2: Create BeritaSkeleton**

Create `lib/berita/widgets/berita_skeleton.dart`:

```dart
import 'package:flutter/material.dart';

/// Placeholder card shown while the trending feed is loading.
class BeritaSkeleton extends StatelessWidget {
  const BeritaSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(color: color),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 80, height: 16, color: color),
                const SizedBox(height: 12),
                Container(width: double.infinity, height: 18, color: color),
                const SizedBox(height: 6),
                Container(width: double.infinity, height: 18, color: color),
                const SizedBox(height: 12),
                Container(width: 200, height: 14, color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add lib/berita/widgets/berita_card.dart lib/berita/widgets/berita_skeleton.dart
git commit -m "feat(berita): add BeritaCard and BeritaSkeleton widgets"
```

---

## Task 16: Flutter BeritaListScreen

**Files:**
- Create: `lib/berita/screens/berita_list_screen.dart`
- Test: `test/berita/screens/berita_list_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/berita/screens/berita_list_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kbvs_golf/berita/models/berita.dart';
import 'package:kbvs_golf/berita/providers/berita_provider.dart';
import 'package:kbvs_golf/berita/repositories/berita_repository.dart';
import 'package:kbvs_golf/berita/screens/berita_list_screen.dart';
import 'package:provider/provider.dart';

class _FakeRepo implements BeritaRepository {
  final List<Berita> items;
  _FakeRepo({this.items = const []});

  @override
  Future<(List<Berita>, int, bool)> getTrending({int limit = 20, String? category}) async {
    return (items, items.length, false);
  }

  @override
  Future<(List<Berita>, int, bool)> search(String query, {int limit = 20}) async {
    return (<Berita>[], 0, false);
  }
}

Widget _wrap(BeritaProvider provider) {
  return ChangeNotifierProvider<BeritaProvider>.value(
    value: provider,
    child: const MaterialApp(home: BeritaListScreen()),
  );
}

void main() {
  testWidgets('renders cards once data is loaded', (tester) async {
    final repo = _FakeRepo(items: [
      Berita(
        id: 'b1',
        title: 'Test Title',
        summary: 'Test Summary',
        imageUrl: 'https://img.test/x.jpg',
        sourceUrl: 'https://example.com/x',
        sourceName: 'Source',
        publishedAt: DateTime.utc(2026, 7, 25),
      ),
    ]);
    final provider = BeritaProvider(repository: repo);
    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Source'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no items', (tester) async {
    final provider = BeritaProvider(repository: _FakeRepo());
    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    expect(find.textContaining('Belum ada berita'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/berita/screens/berita_list_screen_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 3: Create the screen**

Create `lib/berita/screens/berita_list_screen.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/berita_provider.dart';
import '../widgets/berita_card.dart';
import '../widgets/berita_skeleton.dart';
import 'berita_webview_screen.dart';

/// List of berita with search bar and skeleton/error/empty states.
class BeritaListScreen extends StatefulWidget {
  const BeritaListScreen({super.key});

  @override
  State<BeritaListScreen> createState() => _BeritaListScreenState();
}

class _BeritaListScreenState extends State<BeritaListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BeritaProvider>().loadTrending();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<BeritaProvider>().search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Cari berita…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<BeritaProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.items.isEmpty) {
            return ListView(
              children: const [
                BeritaSkeleton(),
                BeritaSkeleton(),
                BeritaSkeleton(),
              ],
            );
          }
          if (provider.errorText != null && provider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  Text('Gagal memuat: ${provider.errorText}'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: provider.loadTrending,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          if (provider.items.isEmpty) {
            return Center(
              child: Text(
                provider.searchQuery.isEmpty
                    ? 'Belum ada berita.'
                    : 'Belum ada berita untuk "${provider.searchQuery}".',
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, i) {
              final b = provider.items[i];
              return BeritaCard(
                berita: b,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BeritaWebviewScreen(
                        sourceUrl: b.sourceUrl,
                        sourceName: b.sourceName,
                        title: b.title,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/berita/screens/berita_list_screen_test.dart`
Expected: PASS — 2 tests.

- [ ] **Step 5: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add lib/berita/screens/berita_list_screen.dart test/berita/screens/berita_list_screen_test.dart
git commit -m "feat(berita): add BeritaListScreen with search, error, and empty states"
```

---

## Task 17: Flutter BeritaWebviewScreen

**Files:**
- Create: `lib/berita/screens/berita_webview_screen.dart`
- Test: `test/berita/screens/berita_webview_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/berita/screens/berita_webview_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kbvs_golf/berita/screens/berita_webview_screen.dart';

void main() {
  testWidgets('renders title and sourceName in AppBar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BeritaWebviewScreen(
          sourceUrl: 'https://example.com/article',
          sourceName: 'Example News',
          title: 'Article Title',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Article Title'), findsOneWidget);
    expect(find.text('Example News'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/berita/screens/berita_webview_screen_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 3: Create the screen**

Create `lib/berita/screens/berita_webview_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// In-app webview for a berita article. Uses webview_flutter; falls back to
/// external browser launch if WebView fails to load.
class BeritaWebviewScreen extends StatefulWidget {
  final String sourceUrl;
  final String sourceName;
  final String title;

  const BeritaWebviewScreen({
    super.key,
    required this.sourceUrl,
    required this.sourceName,
    required this.title,
  });

  @override
  State<BeritaWebviewScreen> createState() => _BeritaWebviewScreenState();
}

class _BeritaWebviewScreenState extends State<BeritaWebviewScreen> {
  late final WebViewController _controller;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onWebResourceError: (_) {
          if (mounted) setState(() => _loadFailed = true);
        },
      ))
      ..loadRequest(Uri.parse(widget.sourceUrl));
  }

  Future<void> _share() async {
    final uri = Uri.parse(widget.sourceUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.sourceName)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 8),
              const Text('Tidak dapat memuat artikel'),
              const SizedBox(height: 16),
              FilledButton(onPressed: _share, child: const Text('Buka di browser')),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16)),
            Text(widget.sourceName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _share, tooltip: 'Share'),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/berita/screens/berita_webview_screen_test.dart`
Expected: PASS — 1 test.

- [ ] **Step 5: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add lib/berita/screens/berita_webview_screen.dart test/berita/screens/berita_webview_screen_test.dart
git commit -m "feat(berita): add BeritaWebviewScreen with share + fallback to browser"
```

---

## Task 18: Wire BeritaProvider into main.dart

**Files:**
- Modify: `lib/main.dart`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add webview_flutter to pubspec**

Edit `pubspec.yaml`, in the `dependencies:` section after `cupertino_icons`:

```yaml
  # In-app browser for berita articles
  webview_flutter: ^4.5.0
```

- [ ] **Step 2: Run flutter pub get**

Run: `flutter pub get`
Expected: Resolves webview_flutter and any transitive deps.

- [ ] **Step 3: Update lib/main.dart**

Edit `lib/main.dart` to:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'berita/providers/berita_provider.dart';
import 'berita/repositories/http_berita_repository.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'tournament/providers/changes_notifier_tournament_provider.dart';
import 'tournament/repositories/http_tournament_repository.dart';

void main() {
  runApp(const KbVsGolfApp());
}

class KbVsGolfApp extends StatelessWidget {
  const KbVsGolfApp({super.key});

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
        ChangeNotifierProvider(
          create: (_) => BeritaProvider(
            repository: HttpBeritaRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'KBVS Golf',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.green,
          fontFamily: null,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
```

- [ ] **Step 4: Run all tests to verify nothing broke**

Run: `flutter test`
Expected: All tests pass (72 existing + 22 new = 94 total).

- [ ] **Step 5: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add pubspec.yaml pubspec.lock lib/main.dart
git commit -m "feat(berita): wire BeritaProvider and add webview_flutter dependency"
```

---

## Task 19: Add Berita entry on home screen

**Files:**
- Modify: `lib/screens/home_screen.dart`

- [ ] **Step 1: Add import and a new button to home_screen.dart**

Edit `lib/screens/home_screen.dart`. Add the import near the existing imports:

```dart
import '../berita/screens/berita_list_screen.dart';
```

Then, after the existing `Browse Tournaments` `FilledButton.icon` in the body Column, add a second `FilledButton.icon`:

```dart
const SizedBox(height: 12),
FilledButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BeritaListScreen()),
    );
  },
  icon: const Icon(Icons.article_outlined),
  label: const Text('Browse Berita'),
),
```

- [ ] **Step 2: Run all tests**

Run: `flutter test`
Expected: 94 tests pass.

- [ ] **Step 3: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add lib/screens/home_screen.dart
git commit -m "feat(berita): add Browse Berita entry to home screen"
```

---

## Task 20: Update README + CHANGELOG and bump test count

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Get actual test count**

Run: `flutter test 2>&1 | tail -3`
Expected: `All tests passed!` with a +N prefix on the prior line. Record N (should be 94).

- [ ] **Step 2: Bump README test count markers**

Edit `README.md`:
- Replace `72/72` (×2 occurrences in headline lines) with `94/94`.
- Replace `72 total tests` with `94 total tests`.
- Replace `<!-- test-count: 72 -->` (×2) with `<!-- test-count: 94 -->`.
- Add `lib/berita/` and `golfie-api/` to the project structure tree.

- [ ] **Step 3: Add CHANGELOG entry under [Unreleased]**

Edit `CHANGELOG.md`, in the existing `### Repository cleanup (audit follow-up)` block, append at the end of that block:

```markdown
### Berita tab

- New feature: "Berita" (Indonesian golf news) added as a tab entry from the home screen.
- New `lib/berita/` subsystem mirrors `lib/tournament/` (model, repositories, provider, screens, tests).
- New backend service `golfie-api/` (Node + Express + TypeScript) at `/news/*` on the existing host. Routes: `GET /news/trending`, `GET /news/search`. Google Custom Search + OpenGraph scraper behind a `USE_MOCK=true` flag with a 10-item seed list for dev.
- New Flutter dependency: `webview_flutter: ^4.5.0` for in-app article browser.
- PRD amended: berita moved from out-of-MVP to in-MVP (`prd/PRD_Engr.md`).
- 22 new Flutter tests added (berita model, mock repo, http repo, provider, list screen, webview screen).
- Total test count: 72 → 94.
```

- [ ] **Step 4: Run drift guard**

Run: `bash tool/verify_test_count.sh`
Expected: `✅ PASS: test count 94 matches docs`. If FAIL, the marker in README is wrong — fix and re-run.

- [ ] **Step 5: Commit**

```bash
cd /home/kiyaya/kiyadev/kbvs-golf
git add README.md CHANGELOG.md
git commit -m "docs: update README/CHANGELOG for berita tab launch (94 tests)"
```

---

## Task 21: Final verification

**Files:** None

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: 94/94 pass.

- [ ] **Step 2: Run backend tests**

Run: `cd golfie-api && npm test`
Expected: All Jest tests pass.

- [ ] **Step 3: Run drift guard**

Run: `bash tool/verify_test_count.sh`
Expected: PASS.

- [ ] **Step 4: Sanity-check git status is clean**

Run: `git status`
Expected: `nothing to commit, working tree clean`.

- [ ] **Step 5: Push**

```bash
git push
```

Expected: All commits land on main.

---

## Self-Review (post-write)

**1. Spec coverage:**
- PRD amendment ✓ (Task 1)
- Backend scaffold ✓ (Task 2)
- Backend types/seed ✓ (Task 3)
- Backend cache ✓ (Task 4)
- Backend Google CSE/OG ✓ (Task 5)
- Backend routes ✓ (Task 6)
- Backend bootstrap ✓ (Task 7)
- Backend tests ✓ (Task 8)
- Flutter model ✓ (Task 9)
- Flutter abstract repo ✓ (Task 10)
- Flutter mock repo ✓ (Task 11)
- Flutter HTTP repo ✓ (Task 12)
- Flutter provider ✓ (Task 13)
- UI design pass ✓ (Task 14)
- Flutter widgets (card + skeleton) ✓ (Task 15)
- Flutter list screen ✓ (Task 16)
- Flutter webview screen ✓ (Task 17)
- Wire main.dart + pubspec ✓ (Task 18)
- Home screen entry ✓ (Task 19)
- README + CHANGELOG ✓ (Task 20)
- Final verification ✓ (Task 21)

**2. Placeholder scan:** No "TBD", no "TODO", no "implement later" — every code step has full code blocks.

**3. Type consistency:**
- `Berita` class: defined Task 9, used in Tasks 11/12/13/16.
- `BeritaRepository` interface: defined Task 10, implemented in Tasks 11/12.
- `BeritaProvider`: defined Task 13, used in Tasks 16/18/19.
- `BeritaCard` widget: defined Task 15, used in Task 16.
- `BeritaSkeleton` widget: defined Task 15, used in Task 16.
- `BeritaListScreen`: defined Task 16, used in Task 19.
- `BeritaWebviewScreen`: defined Task 17, used in Task 16.
- All consistent.

**4. Spec gap flagged:** Navigation. The PRD says "6-tab bottom nav" but the current home_screen.dart has no bottom nav — it uses Navigator.push buttons. The plan acknowledges this and chooses the simpler path (add Berita button alongside Browse Tournaments). A real bottom-nav refactor is out of scope. The spec is wrong on this point and should be revised in a follow-up; flagging but not blocking.