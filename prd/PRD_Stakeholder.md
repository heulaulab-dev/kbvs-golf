# KBVS Golf — Product Requirements Document (Stakeholder / Pitch)

Jakarta golf tournament app. Mobile-first. Discovery + participation for the local golf community. No marketplace. No tee-time booking. Pure focus on local tournaments.

---

## What it is

Mobile app buat pemain golf Jakarta: cari turnamen, daftar pertandingan, temui golfer di area. Bukan marketplace. Bukan booking platform. Focus: discovery + participation untuk komunitas golf lokal.

---

## The problem

Turnamen golf Jakarta informasinya nyebar:

- Facebook page tiap club (Emeralda, Royale, Menteng, Ryu...)
- WhatsApp group untuk registration
- PDF scorecard di website klub
- Instagram announcement

Nggak ada satu tempat yang bisa bilang: *"turnamen apa aja yang buka minggu ini, berapa biayanya, di mana lokasinya, cocok buat skill level berapa."*

Reclub ada tapi:

- Multi-sport generic, bukan golf-specific
- UX bagus tapi nggak ada Jakarta context (currency IDR, course list Jakarta, bahasa campur Indo-English)
- Pemain golf Jakarta butuh sesuatu yang ngerti local context

---

## The solution

KBVS Golf = mobile-first, golf-specific, Jakarta-tuned.

**Core MVP features:**

1. **Browse turnamen lokal** — filter by date, location (Jakarta area), fee, skill level
2. **Register langsung dari app** — one-tap tournament registration with confirmation toast
3. **Course directory** — Google Maps embed, course info (par, length, facilities) di Jakarta
4. **Player profile** — username, skill level, handicap (optional), tournament history
5. **Leaderboard per turnamen** — rank, scores, trophy icons top 3
6. **Tournament submission form** — submit → admin moderates → approve/reject
7. **Admin moderation** — internal flag in app for power users to approve/reject submissions

**AI features — scoped and opt-in.** Described in detail below. Point is friction reduction where the cost of a wrong answer is low. Not for critical paths.

---

## Why now

1. **Market gap**: Reclub multi-sport, nggak ada golf specialist. Niche open, Jakarta golf scene growing fast.
2. **Local data**: Indonesian golf clubs punya digital presence kecil, tournament info ada di mana-mana → easy differentiation dengan clean UI + curated experience.
3. **Cost efficient**: MVP bisa dibangun tanpa spend any AI cost, validate traction, scale kemudian.

---

## Target users

**Primary:** Gen Z / young millennial golfers di Jakarta (age 18–35)

- Handicap range: 10–36, main 1–3x per month
- Smartphone user, active on Instagram/FB
- Main casual/amateur, bukan pro circuit
- Suka clean UX, value info yang curated

**Secondary:** Weekend warrior golfers (30–45 yo) yang cari info turnamen tanpa stalking 5 WhatsApp group.

---

## Differentiation (Visual Identity)

| Aspect | Reclub | KBVS Golf |
|--------|--------|-----------|
| Sport focus | Generic multi-sport | Golf-coded specialist |
| Visual identity | Blue/purple generic | Golf-green (`#2D7A5C`) + gold (`#D4A53A`) |
| Hero imagery | Athlete photos | Course landscapes + action shots |
| Tone | Broad community | Aspirational, skill-progression focused |
| Currency | Global/USD | IDR-native (Rp) |
| Audience | All sports enthusiasts | Jakarta golfers specifically |

**Visual spec:** Clean, sporty, different. Borrow Reclub's UX quality + Apple design discipline (clarity, deference, depth as baseline). Golf-green primary, competition-orange accent, achievement-gold for leaderboard. Inter font. Cards with 16px radius, subtle shadows, spring micro-interactions.

**Design framework:** Kowalski's `pick-ui-library` — don't hand-roll when the platform gives you something. Use Material 3, `flutter_feather_icons` (single-stroke, fits Gen Z minimalism), `pull_to_refresh`, only one animation library (`lottie`). If a needed icon isn't there, draw once and commit.

---

## Roadmap

### Milestone 1 — MVP (~5 weeks)

- Flutter mobile app, Material 3 theme golf-green-600 (`#2D7A5C`), Inter font
- 5-tab bottom nav: Home | Tournaments | Courses | Players | More
- Auth: email/password + optional Google sign-in
- Tournament listing + detail + filter + register flow
- Course directory with Google Maps integration
- Leaderboard per tournament
- Player profile + tournament history
- Tournament submission form → admin moderation queue (PENDING → APPROVED/REJECTED)
- Node.js backend, PostgreSQL, JWT auth
- **AI features:** opt-in description assist, caddy tips, bio suggestions — all with static fallback if AI fails or user disables

### Milestone 2 — Polish & grow

- Push notifications (FCM) for tournament reminders
- Player social features: friends, comments on tournaments
- Trust score for tournament submitters
- Admin moderation dashboard (in-app)

### Milestone 3 — Scale beyond Jakarta

- Partner club CSV feeds (3–5 clubs)
- Expand to Surabaya, Bandung
- Premium tier (advanced stats, analytics) — monetization

### Milestone 4 — Backend migration

- Node.js → Go for performance + cost efficiency
- Refactor business logic layer for porting

---

## Tech stack

**Frontend (Flutter):** Material 3, Inter font, golf-green palette, `go_router` navigation, `riverpod` state, `dio` HTTP client, `flutter_secure_storage` JWT, `google_maps_flutter` maps, `lottie` animations, `pull_to_refresh`, `flutter_feather_icons`.

**Backend (Node.js → Go later):** Express + Prisma + PostgreSQL, Redis cache (tournament list), JWT auth (HS256, 7-day expiry), rate limiting, Docker + PM2.

**Why these:**

- Flutter → single codebase iOS/Android, fast iteration
- Node.js → quick MVP hire, smooth Go port later
- Material 3 → zero dependency, built-in dark mode, Apple aesthetic
- PostgreSQL → reliable, relational data fits model

---

## Cost projection

| Phase | Monthly Cost | Notes |
|-------|-------------|-------|
| MVP (M1) | ~$50 | Backend hosting, Cloud PostgreSQL free tier, Maps API ($200 free/mo credit) |
| M2 | ~$100 | Increased hosting + FCM push notification credits |
| M3 | ~$300 | Higher usage, possible premium feature server costs |

Zero AI cost in MVP. Anthropic API calls NOT budgeted until M3+ if justified by traction. All AI endpoints have fallbacks that require zero API calls.

---

## Risks & honest caveats

1. **Data cold-start:** No tournament data until clubs submit. Need to onboard 3–5 clubs manually before launch. Plan: partner outreach in parallel with development.
2. **Content moderation at MVP:** In-app queue, admin reviews manually. Bottleneck if volume picks up. Mitigation: manual admin tool first, rule-based filters (disposable email blocklist, profanity regex) in M2, AI in M3 only if justified by volume.
3. **Reclub risk:** They could launch golf module anytime. But Jakarta community depth is moat, not features — Reclub can't match local network effects easily.
4. **Map API costs:** Google Maps has quota limits. Set billing alerts at $50/$200 thresholds. Cache geocoding results 30 days.
5. **No tournament data:** Must build UGC pipeline from scratch. Slow burn, but sustainable once club partnerships start.

---

## Success metrics (MVP)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Activation | 40% complete onboarding | Onboarding completion screen |
| Registration conversion | 30% register ≥1 tournament within week 1 | Firebase Analytics |
| Daily active / monthly | 20%+ DAU/MAU | Monthly cohort analysis |
| D7 retention | 25%+ | Mixpanel / Google Analytics |
| Submission volume | 50+ tournaments in first 60 days | DB count |
| Approval rate | 80%+ submissions approved | Admin dashboard count |
| AI opt-in rate | 50%+ after 7 days | Auth/feature toggle stats |
| Crash rate | <0.5% sessions | Firebase Crashlytics |

AI opt-in rate is our earliest signal about whether AI features are helping or hurting. Low opt-in means we iterate or remove them — no question.

---

## Decision points (product owner needs to confirm)

✅ **Locked decisions:**

- Flutter mobile only (no web)
- Node.js backend, plan to migrate to Go later
- Jakarta-only geographic scope
- Manual admin moderation path (M1 → M2 → rule-based → M3 AI)
- All AI features opt-in with non-AI fallback

⏳ **Open (need input):**

- Launch date target? Week 5 or extend to Week 6–7 for polish?
- Partner club list who to onboard before launch?
- Premium tier pricing hypothesis when needed later?
- Budget approval for FCM push notifications (M2)?

---

## AI features deep dive — what, why, how

AI is in scope for MVP. Not as a checkbox feature. It's there to lower friction where the risk of error is low and the gain in completion rate matters. Every AI call has a static fallback that works identically. No AI endpoint can break the UX.

### 1. Tournament description assist

**Problem:** Users copy-paste long WhatsApp forwards into the submission form. Too much text, disorganized.

**Solution:** Paste → AI generates 3 clean variant summaries → user picks one or edits manually → submits.

**UI:** "✨ Help me write this" button in submission form description field. Opens modal sheet. Paste → variants appear. Pick + edit + submit.

**Fallback if AI fails:** Just show empty textarea, button disappears silently. Nothing breaks.

**Consent:** This uses AI only if the user explicitly clicks the button. No background processing.

### 2. Caddy tips

**Problem:** New golfers don't know which holes to watch out for. Generic advice doesn't help.

**Solution:** On tournament detail page, under the Rules tab, collapsible card shows 2–3 short tips based on weather + course conditions ("wind left-to-right on hole 7 today," "putt slope north on green 3").

**UI:** Collapsible card below the rules. Refresh icon regenerates tips (triggers new AI call). "Use static fallback" option for users who want deterministic behavior.

**Fallback:** Static template tips cached in the app — e.g., "Check pin position on hole 7 today," "Adjust for wind direction." Always available.

**Frequency:** Max one refresh per day per tournament to avoid repeated identical output.

### 3. Bio suggestions for player profiles

**Problem:** Many users leave their bio blank because they don't know how to phrase it.

**Solution:** Profile screen has "✨ suggest bio" button → modal presents 3 options based on user's skill level + recent tournament participation → user picks one or edits → saves.

**Fallback:** No suggestions shown if the user hasn't played any tournaments yet. Shows "Write your bio" placeholder instead.

**Opt-in per-user:** Setting in profile toggle — "Use AI bio suggestions." User turns it off, button disappears forever.

### Search ranking enhancement

**Problem:** When users search tournaments, the default sort (by date up soon) might surface things they're not qualified for.

**Solution:** When a query term is present, the backend re-ranks results slightly toward tournaments matching the user's skill level and past attendance patterns.

**This is invisible:** The user sees better-ordered results without realizing AI happened. No visible switch needed.

**Fallback:** Default date-based sort if the AI ranking step fails or the user is using public/shared view without profile access.

All four AI features share the same pattern: user-initiated (search ranking is the only exception, embedded), explicit consent where appropriate, always degrades gracefully to a working alternative.

---

## How Emil Kowalski's design skills shaped this spec

Kowalski's skills repo (`github.com/emilkowalski/skills`) directly informed the visual direction and component picks:

- `/prototype` skill → onboarding flow design: six progressive disclosure steps, one decision per screen, no walls of text
- `/pick-ui-library` skill → component libraries: use Material 3, don't roll custom themes; pick `flutter_feather_icons` over icon packs that need constant updates; only two animation libs (`lottie` + `flutter_spring` via Material 3 defaults)
- `/improve-animations` skill → motion principles: purposeful (communicate state), fast (200–300ms), never decorative loops on static content. Respect reduced motion setting.
- `/animation-vocabulary` skill → specific Lottie asset specifications: swing + ball drop for pull-to-refresh, ball-in-hole for registration success — concrete, not "nice animation"
- `/apple-design` skill → color palette, typography hierarchy, component sizing aligned with iOS guidelines while adapting to golf context
- `/review-animations` skill → landing page/interaction review: animate only state changes, not presentation. Motion must serve function.
- `/find-animation-opportunities` skill → identifying where motion adds value: pull-to-refresh, leaderboard refresh, button press haptics, avatar stack collapse — all documented in §3.4 motion table

The section on AI features mirrors Kowalski's principle "Agents don't have great taste" — the AI assists but humans make the final choice. We're not automating judgment, we're reducing effort. That's the design intention, encoded in the spec.

---

## References

- `docs/VISUAL_DIRECTION.md` — color palette, typography, components, motion, imagery (source of truth)
- `docs/UI_STACK.md` — Flutter packages, card/button specs, Lottie implementation details
- `docs/RESEARCH.md` — Jakarta market, Reclub analysis, golf data landscape
- `prd/PRD_Engr.md` — detailed technical implementation spec
- emilkowalski/skills (GitHub) — animation vocabulary, component picks, prototype workflow, animation improvement checklist