# KBVS Golf — Engineering PRD

Jakarta golf tournament app. Flutter mobile, Node.js backend, PostgreSQL. MVP locks discovery + registration flows with manual admin moderation. AI features live in §4.12 and §8 — present, scoped, not the centerpiece.

---

## 1. Stack

**Frontend:** Flutter 3.x+ with Material 3. Inter font via `google_fonts`. State via Riverpod. Routes via `go_router`. HTTP via `dio` with auth interceptor. JWT in `flutter_secure_storage`. Maps via `google_maps_flutter`. Icons via `flutter_feather_icons` (single-stroke, fits Gen Z minimalism). Animations via `lottie` for celebration moments only — never for state changes that should snap.

**Backend:** Node.js 20+ on Express. Prisma ORM. PostgreSQL 15+ (Supabase or self-hosted). Redis for tournament list cache, 5-min TTL. JWT HS256, 7-day expiry, refresh token in client storage. `express-rate-limit` at 100 req/min/IP on public endpoints. PM2 behind Nginx. Docker for containerization.

Controllers stay thin. Business logic lives in services. We port to Go in M4 — keep the transport layer separable.

---

## 2. Scope

### In (MVP)

- Auth: email/password, optional Google OAuth2
- Tournament submission → admin moderation queue (`PENDING` → `APPROVED`/`REJECTED`)
- Tournament listing: filter by date, location, skill, fee, format
- Tournament detail: course, date, format, registered players, fee, tabs (Details / Players / Rules)
- One-tap register / unregister
- Course directory with Google Maps embed
- Player profile: username, skill, handicap, tournament history
- Per-tournament leaderboard with top-3 trophies
- 5-tab bottom nav: Home | Tournaments | Courses | Players | More

### Out (MVP)

- Push notifications via FCM — poll client-side first
- "Berita Turnamen" tab (news aggregator with Google CSE + OG extraction)
- Admin web dashboard — in-app admin role + Prisma Studio for now
- CSV import from partner clubs
- Tournament discussion / chat
- Web platform

### AI features — scope and intent

AI exists in MVP. Used sparingly, behind explicit user consent, and never on the critical path. The point isn't to show off AI — it's to lower friction where the cost of a wrong answer is low.

Where AI shows up:

- **Tournament description assist** — paste a long WhatsApp forward, get a clean summary for the submission form. User reviews before submit. No auto-submit.
- **Caddy tip generation** — for a given course + weather, surface 2–3 short tips ("wind left-to-right on hole 7 today"). Static rule-based fallback if no AI.
- **Search ranking** — when user searches tournaments, AI re-ranks results based on their skill level + recent activity. Local fallback (basic filter sort) if AI disabled.
- **Onboarding photo caption suggestions** — optional. User taps "suggest bio" → 3 options. Pick one, edit, save.

Where AI is *not* in scope:

- Handicap estimation (regulatory + accuracy liability)
- Player matching / partner finding (privacy + consent complexity)
- Automated moderation (manual admin handles it; volume doesn't justify AI cost yet)
- AI chat support
- News summarization (deferred to M3+ if needed)

Hard rule: every AI call has a **non-AI fallback that works identically**. If the AI endpoint is down or the user opts out, the feature degrades to that fallback. AI is a UX enhancement, never a dependency.

---

## 3. Visual Design System

This is the spec. Don't freelance. Emil Kowalski's framing from his skills repo drives the structure: animations communicate state, components earn their place, libraries are picked not hand-rolled. Apple's WWDC principles (clarity, deference, depth) are the baseline — Gen Z golf context bends them toward warmth and motion, not away from them.

### 3.1 Color tokens

Primary brand is golf green. Accent is orange for urgency. Gold for achievement. Red for errors. Dark mode is its own thing — not a flip.

| Token | Hex | Where it goes |
|-------|-----|---------------|
| `golf-green-600` | `#2D7A5C` | Primary brand, filled CTAs, active nav |
| `golf-green-400` | `#4FA37E` | Hover, secondary highlights |
| `golf-green-100` | `#E8F4ED` | Selected rows, "you're in" success state bg |
| `competition-orange` | `#E85D2C` | Tournament urgency, live badges, deadlines |
| `achievement-gold` | `#D4A53A` | Badges, top-3 leaderboard, achievement unlock |
| `error-red` | `#D32F2F` | Errors, "tournament full", withdrawals |
| `white` | `#FFFFFF` | Light mode background |
| `gray-50` | `#F9FAFB` | Card backgrounds |
| `gray-100` | `#F3F4F6` | Dividers, disabled bg |
| `gray-500` | `#6B7280` | Secondary text, metadata |
| `gray-900` | `#111827` | Primary text |
| `black` | `#000000` | Reserved for dark mode accents only |

Dark mode (its own palette, not a hex-invert):

- `dark-bg`: `#0A0F0D`
- `dark-surface`: `#1A2520`
- `dark-text`: `#F0F4F1`

Don't auto-swap to dark mode tokens — write a separate theme. Material 3 `ColorScheme.fromSeed` is fine for v1 but expect custom overrides within two sprints.

### 3.2 Typography

Inter as the workhorse. SF Pro on iOS where the system already has it (saves ~200KB). JetBrains Mono only for scorecards and stats — body text is sans-serif always.

| Token | Size | Weight | Use |
|-------|------|--------|-----|
| `display-xl` | 40px | 800 | Hero, splash |
| `display-lg` | 32px | 800 | Page titles |
| `heading-md` | 24px | 700 | Section headers |
| `heading-sm` | 20px | 700 | Card titles |
| `body-lg` | 16px | 500 | Primary body |
| `body-md` | 14px | 400 | Default body |
| `body-sm` | 12px | 400 | Captions, metadata |
| `caption` | 11px | 600 | Labels, badges |

Line height: 1.4 for body, 1.2 for display. Letter-spacing: -0.01em on display sizes only. Don't overthink type.

### 3.3 Components

**Cards (Tournament / Course):**

- Radius: 16px
- Shadow: `0 4px 12px rgba(0,0,0,0.06)`
- White bg, optional gradient header image
- Press state: scale to 0.98, spring physics, 300ms

**Buttons:**

| Variant | Spec |
|---------|------|
| Primary | Filled golf-green-600, white text, 12px radius, scale 0.96 on press + `HapticFeedback.lightImpact()` |
| Secondary | Outlined, golf-green-600 border, transparent bg |
| Ghost | Text only, golf-green-600 |
| Disabled | gray-100 bg, gray-500 text |

**Competition badges (circular):**

| Badge | Look |
|-------|------|
| Amateur | Green border, white bg |
| Pro | Gold border, black bg |
| Live | Orange pulsing border + "LIVE" text |
| Handicap | Blue accent |
| Scramble | Purple accent |

**Leaderboard rows:**

- Avatar (40px circle) + name + score, no extra padding
- Top 3: gold / silver / bronze trophy prefix icon
- Sticky header with tournament name (display-sm variant of `heading-sm`)
- Pull-to-refresh: golf club swing → ball drop (Lottie, 800ms total)

**Avatar stacks (registered players):**

- Custom `Stack` + `ClipOval` + offset positioning — no third-party stack widget
- 3 visible avatars with 20px overlap
- "+N more" badge for overflow (gray-100 bg, gray-900 text, 11px caption)

### 3.4 Motion

Three rules from Kowalski's `7 Practical Animation Tips`: purposeful (communicates state), fast (200–300ms), and never decorative loops on static content.

| Action | Motion |
|--------|--------|
| Pull-to-refresh | Lottie: golf club swing → ball drops in (800ms) |
| Tournament registration success | Lottie: ball roll into hole + tiny particle burst |
| Score update | `AnimatedSwitcher` flip on the score number |
| Achievement unlock | Lottie: badge scales from 0 + particles |
| Page transition | Slide + fade, 250ms `ease-out` |
| Button press | Scale 0.96 + `HapticFeedback.lightImpact()` |
| List item appears | Stagger 30ms per row, max 6 rows animated |
| Modal open | Spring physics, dampening 0.7, stiffness 300 |

If it doesn't communicate state change — no animation. Static content sits still. Respect `prefers-reduced-motion`: swap all Lottie and springs for fades ≤150ms.

### 3.5 Iconography

- System icons: SF Symbols (iOS) / Material Icons (Android), filled variant for selected nav, outline for unselected
- Custom golf set: flag, hole, club, ball, cart, scorecard — outlined, 2px stroke, rounded line caps
- Library: `flutter_feather_icons`. Don't introduce another icon pack. If a needed icon isn't there, draw it once and commit it.

### 3.6 Imagery

The Reclub visual test: would this photo look at home on a stock sports site? If yes, don't use it.

Use:

- Real Jakarta courses: Emeralda, Royale Jakarta, Menteng CC, Ryu, Damai Indah. Ask clubs for permission; don't scrape.
- Action shots: swing mid-motion, ball flight, putt celebration. Grainy > polished.
- Local players. Diverse. Not all the same age, same outfit, same ethnicity.
- Course landscapes: early morning, golden hour. Aspirational but feels like a Tuesday morning, not a magazine cover.

Don't use:

- Stock "golfers smiling at camera"
- Generic sports imagery that could be tennis or baseball
- Magazine-style polish (Gen Z will scroll past it)
- Crowded courses — show the spacious premium feel

If we don't have real photos for a course by launch, show a tasteful gray-50 placeholder with the course name in display-lg. Don't fake it with stock.

### 3.7 Layout patterns

**Home (Tab 1):**

1. Hero card (top, ~60% of viewport height when no scroll) — featured live tournament or upcoming within 7 days
2. Quick actions row: Find Course, My Handicap, Friends Playing — three equal-width chips, gray-50 bg
3. Upcoming tournaments list: vertical scroll, cards, infinite pagination
4. Bottom nav: 5 tabs, fixed

**Tournament detail:**

- Hero image (course photo, lazy-loaded with skeleton shimmer)
- Tournament name (`display-lg`)
- Date, location, format, fee (`body-md`, gray-500)
- Registered players avatar stack with "+N more"
- CTA: "Register" (primary) or "You're In" success state (golf-green-100 bg, gray-900 text)
- Tabs: Details | Players | Rules — underline indicator, slide animation between

**Course detail:**

- Google Maps embed, marker at course, polyline not needed
- Course info: par, length (yards), facilities list with bullet icons
- Upcoming tournaments at this course (inline list with mini "View" CTA)
- Reviews section — placeholder card in MVP, real implementation in M2

**Leaderboard:**

- Sticky tournament header (compact: name + date only)
- Row: rank | avatar | name | round1 / round2 / total
- Top 3: trophy icon prefix (gold/silver/bronze)
- Pull-to-refresh with golf club swing

**Profile:**

- Avatar (camera/gallery picker via `image_picker`)
- Username (editable, 12-char max)
- Skill level (dropdown)
- Handicap (optional integer)
- Tournament history: list with status badge (CONFIRMED = golf-green-100, WITHDRAWN = gray-100)

### 3.8 Onboarding flow

Six steps. One decision per screen. Progress indicator (5 dots at top, current one filled).

1. **Welcome** — full-screen hero, brand promise in two lines, "Let's go" CTA
2. **Location** — pick Jakarta area (tap on map, no text input)
3. **Skill level** — slider: Beginner / Casual / Competitive / Pro
4. **Handicap** — optional, "Skip" right there
5. **Profile photo + username** — camera/gallery picker, 12-char username with availability check
6. **First tournament** — pre-selected based on skill + location, "Join this one?" CTA with "Show me another"

No walls of text. No legal upfront (inline later, dismissible). No email gate before showing value.

### 3.9 Accessibility

WCAG 2.1 AA. Not aspirational, baseline.

- Contrast: all text against its background ≥ 4.5:1 (gray-500 on white passes; gray-100 on white doesn't — don't pair them)
- Dynamic type / font scaling — test at 200% scale, layout must hold
- VoiceOver / TalkBack labels on all interactive elements
- Color is never the only signal — Live tournament = orange icon + "LIVE" text + pulsing animation
- Reduce motion: respect system setting, swap springs for fades
- Tap targets ≥ 44×44 pt

### 3.10 Design-to-code

- Figma is source of truth for tokens and component specs
- Export design tokens as JSON, generate Flutter `ColorScheme` / `TextTheme` via `flutter_gen`
- Inter font self-hosted via `google_fonts` package
- Lottie JSONs from LottieFiles (open license only) or custom-built in After Effects if budget allows
- App icon: custom, green flag silhouette on white circle — get this right, it's the only thing users see on their home screen

### 3.11 Component library picks (per `pick-ui-library` skill)

Use these, don't hand-roll:

- **Toasts/snackbars:** `fluttertoast` or `oktoast` — both ship single-file, no theme wrestling
- **Pull-to-refresh:** `pull_to_refresh` — Material's built-in is fine too, this is just easier to skin
- **Bottom sheets:** `modal_bottom_sheet` — animation control matters here
- **Icons:** `flutter_feather_icons` only. If we need an icon it doesn't have, draw once, commit, move on.

Don't install abandoned packages because they showed up first in a search. If a library hasn't been updated in 18+ months, skip it.

### 3.12 AI features — UX embedding

Where the AI calls in §2 actually live in the UI:

| Feature | Trigger | UI surface | Fallback |
|---------|---------|-----------|----------|
| Tournament description assist | User taps "✨ Help me write this" in submission form | Modal sheet: paste long text → AI returns 3 variants → user picks/edits | Manual entry only — AI button is opt-in |
| Caddy tips | Tournament detail page, below the rule tabs | Collapsible card with 2–3 short tips + "refresh" icon | Static template tips ("check pin position on hole 7") |
| Search re-ranking | User searches tournaments with skill/activity in profile | Invisible — just better ordered results | Default filter sort (date asc) |
| Bio suggestions | Profile screen, "✨ suggest bio" button | Modal: 3 options, pick + edit | Empty bio, user types manually |

Every AI surface has a visible icon + label. No ambiguity about what's AI and what's not. If the user wants to disable AI features, there's a single toggle in settings ("Use AI suggestions") that turns off all four.

---

## 4. Data models

### User
```
id              UUID PK
username        VARCHAR(12) UNIQUE NOT NULL
email           VARCHAR UNIQUE NOT NULL
password_hash   VARCHAR NOT NULL
skill_level     ENUM('beginner','casual','competitive','pro')
handicap        INT NULL
role            ENUM('user','admin') DEFAULT 'user'
avatar_url      VARCHAR NULL
ai_opt_in       BOOLEAN DEFAULT true
created_at      TIMESTAMP DEFAULT NOW()
updated_at      TIMESTAMP DEFAULT NOW()
```

### Tournament
```
id              UUID PK
name            VARCHAR(100) NOT NULL
description     TEXT
course_id       UUID FK → Course
format          ENUM('match-play','stableford','scramble','best-ball','championship')
min_skill       ENUM('beginner','casual','competitive','pro')
max_fee_idr     INT
start_date      TIMESTAMP NOT NULL
end_date        TIMESTAMP NOT NULL
status          ENUM('PENDING','APPROVED','REJECTED','FULL') DEFAULT 'PENDING'
max_capacity    INT DEFAULT 20
is_featured     BOOLEAN DEFAULT false
created_by      UUID FK → User
created_at      TIMESTAMP DEFAULT NOW()
updated_at      TIMESTAMP DEFAULT NOW()
```

### Course
```
id              UUID PK
name            VARCHAR NOT NULL
location        VARCHAR (Jakarta area)
latitude        FLOAT
longitude       FLOAT
par             INT
length_yards    INT
facility_notes  TEXT
image_url       VARCHAR
```

### Registration
```
id              UUID PK
tournament_id   UUID FK → Tournament
user_id         UUID FK → User
registered_at   TIMESTAMP DEFAULT NOW()
status          ENUM('CONFIRMED','WITHDRAWN') DEFAULT 'CONFIRMED'
UNIQUE(tournament_id, user_id)
```

### LeaderboardEntry
```
id              UUID PK
tournament_id   UUID FK → Tournament
user_id         UUID FK → User
round1_score    INT NULL
round2_score    INT NULL
total_score     INT NULL
rank            INT NULL
updated_at      TIMESTAMP DEFAULT NOW()
UNIQUE(tournament_id, user_id)
```

---

## 5. API contracts

### `POST /api/auth/register`
**Body:** `{ email, password, username, skill_level }`
**Response 201:** `{ token, user }`
**Errors:** 409 (email/username taken), 400 (validation)

### `POST /api/auth/login`
**Body:** `{ email, password }`
**Response 200:** `{ token, user }`
**Errors:** 401 (invalid creds)

### `GET /api/tournaments`
**Query:** `location?, date_from?, date_to?, min_skill?, max_fee?, format?, limit=20, offset=0`
**Response 200:**
```json
{
  "results": [{
    "id": "uuid",
    "name": "Emeralda Scramble Open",
    "course": { "name": "Emeralda Golf Club", "location": "South Jakarta" },
    "format": "scramble",
    "min_skill": "beginner",
    "max_fee_idr": 250000,
    "start_date": "2026-08-15T08:00:00Z",
    "end_date": "2026-08-15T17:00:00Z",
    "status": "APPROVED",
    "registered_count": 12,
    "max_capacity": 20,
    "is_featured": false
  }],
  "total": 47,
  "has_next": true
}
```
Filter: only `APPROVED` records for non-admin. Search re-ranking (AI) kicks in when `?q=` is present.

### `GET /api/tournaments/:id`
**Response 200:** Full tournament + registered players (max 50 with pagination). Includes caddy_tips if available.

### `POST /api/tournaments`
**Header:** `Authorization: Bearer ***`
**Body:** `{ name, description, course_id, format, min_skill, max_fee_idr, start_date, end_date, max_capacity? }`
**Response 201:** Tournament with `status: "PENDING"`. Admin approval required for public visibility.

### `PATCH /api/tournaments/:id` (admin only)
**Body:** `{ status: "APPROVED" | "REJECTED" }`

### `POST /api/tournaments/:id/registrations`
**Header:** `Authorization: Bearer ***`
**Response 201:** Registration record. 409 if already registered, 410 if tournament full.

### `DELETE /api/tournaments/:id/registrations/:userId`
**Response 204**

### `GET /api/courses`
**Query:** `location?`
**Response 200:** `{ results: [...], total }`

### `GET /api/courses/:id`
**Response 200:** Course + upcoming tournaments (next 30 days).

### `GET /api/leaderboard/:tournamentId`
**Response 200:** `{ entries: [{ rank, user: {username, avatar_url}, scores: { round1, round2, total } }] }`

### `GET /api/users/:id`
**Response 200:** Public profile + tournament history.

### `PATCH /api/users/:id`
**Header:** `Authorization: Bearer ***`
**Body:** `{ username?, skill_level?, handicap?, avatar_url?, ai_opt_in? }`

### AI endpoints

All AI endpoints are best-effort. If they fail or user has `ai_opt_in: false`, return the static fallback in the same response shape.

### `POST /api/ai/summarize-description`
**Body:** `{ raw_text: string }`
**Response 200:** `{ variants: ["...", "...", "..."] }`

### `GET /api/ai/caddy-tips/:tournamentId`
**Response 200:** `{ tips: ["...", "...", "..."], source: "ai" | "static" }`

### `GET /api/ai/bio-suggestions`
**Query:** `context=user_profile_snapshot`
**Response 200:** `{ variants: ["...", "...", "..."] }`

---

## 6. Frontend screens

### 6.1 Home (Tab 1)
- Hero card: featured live tournament (admin pins via `is_featured: true`)
- Quick actions row: Find Course, My Handicap, Friends Playing
- Upcoming tournaments list (infinite scroll, 20 per page)

### 6.2 Tournaments (Tab 2)
- Filter bar: location dropdown, date range, skill chips, fee slider
- Search input with debounce (400ms) — calls `GET /api/tournaments?q=` with AI re-ranking
- Card list, same spec as Home

### 6.3 Tournament Detail
- Hero image (course photo, lazy-loaded skeleton)
- Tournament name (`display-lg`)
- Date, location, format, fee (`body-md`, gray-500)
- Registered players avatar stack with "+N more"
- Tabs: Details | Players | Rules
- CTA: "Register" (primary, golf-green-600) or "You're In" (success state, golf-green-100 bg)
- Caddy tips card below tabs — collapsible, refresh icon visible

### 6.4 Courses (Tab 3)
- Search bar + Jakarta area filter chips
- Card list: course image, name, location, par, length
- Tap → Course Detail (Google Maps + tournament list)

### 6.5 Players (Tab 4)
- Search by username
- Player list: avatar, username, skill badge
- Tap → Player Profile (public)

### 6.6 More (Tab 5)
- Profile entry, About, Help, AI settings toggle, Logout

### 6.7 Profile
- Avatar (camera/gallery via `image_picker`)
- Username (editable, 12-char max)
- Skill level (dropdown)
- Handicap (optional integer)
- "Suggest bio" button (AI, opt-in) — modal with 3 variants
- Tournament history: list with status badge

### 6.8 Tournament submission form
- Name (text, max 100 chars)
- Description (textarea, max 500 chars)
- "✨ Help me write this" button — opens AI modal, paste long text → 3 variants
- Course selector (searchable dropdown + map picker)
- Format (dropdown)
- Min skill level (radio)
- Max fee (numeric with "Rp" prefix)
- Date/time pickers
- Max capacity (numeric, default 20)
- Submit → toast: "Submitted for approval. Admin will review shortly."

### 6.9 Admin moderation
- List of `PENDING` tournaments
- Per item: preview card + "Approve" (golf-green-600) + "Reject" (error-red outlined) buttons
- Filters: date, submitter

---

## 7. Validation

**Client-side, before API call:**

- Name: 1–100 chars
- Description: max 500 chars
- Fee: positive integer
- Dates: start_date > now, end_date > start_date
- Max capacity: positive integer, max 200

**Server-side, mirrors client + adds:**

- Email: RFC 5322
- Username: alphanumeric + underscore, 3–12 chars
- Password: min 8 chars, at least 1 number

No profanity filter in MVP. Admin moderation catches it manually. If volume justifies cost, rule-based regex filter in M2 before AI moderation in M3.

---

## 8. Error handling

| Scenario | UX |
|----------|-----|
| API unreachable | Toast: "Server unavailable. Check connection." + retry button |
| Auth expired (401) | Auto-redirect to login, preserve return path |
| Tournament full | Toast: "Tournament is full. Try another one." |
| Registration conflict (409) | Toast: "You're already registered." + show "You're In" state |
| Form validation | Inline red text under invalid field |
| Network timeout (15s) | Loading spinner + cancel button |
| AI endpoint fails | Silent fallback to static content, no user-facing error |

---

## 9. Success metrics

| Metric | Target |
|--------|--------|
| Activation | 40% complete onboarding |
| Conversion | 30% register for ≥1 tournament in week 1 |
| DAU/MAU | 20%+ |
| D7 retention | 25%+ |
| Submissions | 50+ tournaments in first 60 days |
| Approval rate | 80%+ submissions approved |
| AI opt-in rate | 50%+ of users keep AI features enabled after 7 days |
| Crash rate | <0.5% sessions |

AI opt-in matters — if users turn it off en masse, that's signal that the AI features aren't earning their place. We pull them before M3.

---

## 10. Risks & mitigations

| Risk | Mitigation |
|------|-----------|
| Admin moderation bottleneck | In-app admin role + Prisma Studio for bulk ops |
| Spam submissions | Manual in MVP, regex + disposable-email blocklist in M2 |
| Cold start content | Onboard 3–5 partner clubs manually before launch, seed 20–30 tournaments |
| Map API cost overrun | Billing alerts at $50/$200, cache geocoding 30 days in Redis |
| Tournament data accuracy | Admin verification on approval, in-app "report" button |
| AI endpoint downtime | All AI features have static fallback in same response shape |
| AI cost overrun | Per-user rate limit on AI calls, monthly budget cap with alerting |

---

## 11. Sprint plan

5 weeks. Tight but doable.

| Week | Frontend | Backend |
|------|----------|---------|
| 1 | Flutter setup, Material 3 theme, `go_router` skeleton, Riverpod stubs | Express + Prisma + Postgres setup, `/api/auth/*` |
| 2 | Auth screens, onboarding 6-step, JWT storage | `/api/tournaments` CRUD + admin moderation flow |
| 3 | Tournament list + detail + filter + registration | Course + registration + leaderboard endpoints |
| 4 | Course list + detail with Maps, leaderboard, profile | AI endpoints + static fallback logic |
| 5 | Submission form, admin moderation screen, polish | Testing, app store metadata |

**Launch target:** End of week 5. If week 3 slips, de-scope admin moderation screen before delaying launch — manual moderation via Prisma Studio is fine for first 100 submissions.

---

## 12. Tech decisions

- **Material 3 over custom theme** — zero deps, built-in light/dark, aligns with Apple's aesthetic baseline. Kowalski's `pick-ui-library` rule: don't hand-roll when the platform gives it to you.
- **go_router over auto_route** — declarative, cleaner with Material 3 bottom nav.
- **Riverpod over Bloc** — less boilerplate for MVP scope.
- **Express over Fastify** — team familiarity, ecosystem maturity. We port to Go in M4 anyway.
- **Prisma over raw pg** — type safety, migrations are sane.
- **PostgreSQL over MongoDB** — relational data (tournament ↔ registration ↔ user) needs joins.
- **Redis for cache only** — tournament list cache, 5-min TTL. Never primary store.
- **AI as opt-in enhancement, not dependency** — every AI endpoint has a static fallback. If Anthropic goes down or the user toggles AI off, nothing breaks.

---

## References

- `docs/backlog/VISUAL_DIRECTION.md` — color, typography, components, motion (source of truth; design reference only, not implemented in v1)
- `docs/UI_STACK.md` — Flutter library list and patterns
- `docs/RESEARCH.md` — Jakarta market + Reclub analysis
- `prd/PRD_Stakeholder.md` — pitch version of this PRD
- emilkowalski/skills (GitHub) — animation vocabulary, component picks, prototype workflow