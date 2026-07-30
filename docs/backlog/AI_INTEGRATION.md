<!-- STATUS: Not implemented — design reference only. -->

# Golfie — AI Integration Architecture

**Project:** kbvs-golf (Flutter + Node.js/FastAPI backend)  
**Scope:** Jakarta-focused golf tournament app with AI-driven features for scoring, moderation, and smart bookmark/search.

---

## 1. Scoring/Recommendation Engine

### What it does
- **Handicap estimation:** Uses player's recent scores + course difficulty to suggest a playing handicap (for tournament eligibility). Output: integer, plus/minus indication.
- **Course recommendations:** Given user's location, skill level, budget (IDR), date/time → return top 3 courses with available slots and short descriptions.
- **Tournament partner matching:** "Find players similar to me near this course" or "match me with someone at my level." Returns anonymized player IDs, not personal contact info.

**When to use it:** Only on the backend after user opts in (with privacy consent). Never show raw model output — surface only clean, human-friendly text.

### Model choice
- **Model:** Claude Opus 4.8 (anthropic/claude-opus-4-8) via Anthropic API
- **Why:** For accurate numeric reasoning (handicap calculation) and nuanced contextual judgment (course match quality). Haiku would be faster but less reliable for calculations costing more than a few extra dollars per month.
- **Cost:** ~$0.015 / 1K input tokens, ~$0.075 / 1K output tokens (~Rp 235,000 – Rp 1.2 million per 1K requests depending on context)
- **Latency:** 800–1500ms average, including prompt assembly

### Architecture pattern
```
Flutter App → Backend API (Node.js/FastAPI) → Anthropic API → Response → Back to Flutter
                ^                          ^
          (cache)                    (prompt assembly + guardrails)
```

- Cache results by user ID + query key (e.g., `recs:{userId}:{location}:{date}`) for up to 24h to reduce latency and cost.
- Do NOT send raw user PII to the model. Send only: skill_level, recent_scores[5], location, budget_range, date_window. Mask email/phone.

### Prompt template (Claude)
You are an expert golf handicapper and course recommender. Work with Indonesian golf context and prices in IDR. Output strict JSON ONLY, no preamble, no markdown code blocks, no extra text.

{
  "handicap": integer|null,
  "recommendations": [
    {
      "course_name": string,
      "distance_km": float,
      "approx_fee_idr": integer,
      "availability_notes": string,
      "reason_for_match": string
    }
  ],
  "partner_matches": [] if none else [{"player_id": string, "skill_range": "beginner/casual/competitive/pro", "avg_handicap": number, "shared_courses": [string]}]
}

If insufficient data for handicap, return null for handicap field only. Always include currency symbol "IDR" in approximate fee field.

If user has fewer than 3 recent scores, explain that handicap cannot be accurately estimated and recommend practicing first with minimal output.

Guardrails to enforce before sending to model:
1. Trim any user-supplied text beyond 500 characters
2. Sanitize course names — reject anything containing PII (emails, phone numbers, names)
3. If budget_range is empty, default to "Rp 200k–Rp 500k" (Jakarta public course typical range)
4. Return error JSON {"error": insufficient_data} with explanation if required fields missing

### Failure modes & fallbacks
| Scenario | Fallback |
|----------|----------|
| Anthropic API timeout / rate limit | Serve cached result if <24h old; otherwise show generic "recommendations coming soon" message with placeholder loading state |
| Handicap calculation returns null | Show "Insufficient score history to estimate handicap. Play 3+ rounds first" with encouragement UI, don't block feature access |
| Course recs return out-of-price-range entries | Re-run with stricter price filter (±20% of user's stated range) |
| No partner matches found | Show empty state: "No matches yet. Try widening your skill range or exploring new tournaments" — don't expose user's exact skill publicly |

### What NOT to do
- ❌ Don't show model confidence scores or probabilities to users ("90% chance you're casual"). Present final answer as fact.
- ❌ Don't store raw API responses with PII. Delete after 30 minutes if logged for debugging.
- ❌ Don't make handicap calculation deterministic across different model versions — always recompute on each request, never cache the exact numeric output longer than needed.
- ❌ Don't use free-tier/open-source models (Llama 3, etc.) for handicapping — they'll hallucinate integers and produce garbage results you can't fix.

---

## 2. Content Moderation

### What it does
Auto-scan user-submitted tournament submissions (name, description, location, format) for:
- Spam / fake listings (over-promising, impossible details, suspicious links)
- Profanity / offensive language (Indonesian slang included: ngakak, nyokap, etc.)
- Suspicious patterns (email domains that look throwaway, mass-submit behavior from same IP)

Return one of three flags: `approve`, `review_pending`, `reject_with_reason`.

**When to use it:** On every tournament POST to the backend before making it public. Review_pending goes to admin queue for human approval. Reject deletes immediately with no public trace.

### Model choice
- **Model:** Claude Sonnet 3.5 (anthropic/claude-sonnet-3-5)
- **Why:** Balanced speed + accuracy. Good at detecting subtle spam patterns in Indonesian/English mix, better at cultural nuance than GPT-4o at lower cost. Not as expensive as Opus for high-volume moderate work.
- **Cost:** ~$0.003 / 1K input tokens, ~$0.015 / 1K output tokens (~Rp 47,000 – Rp 235,000 per 1K submissions)
- **Latency:** 300–600ms

### Architecture pattern
```
Flutter App → Backend API (moderation endpoint) → Anthropic API → Flag decision → Store in DB
                     ↑                                                  ↓
            (sanitized text)                              (admin review queue if needed)
```

- Sanitize submission before moderation: strip HTML tags, normalize unicode, truncate to max 2000 characters per field.
- Run moderation in parallel with other validation (field length, required checks) so total submission time doesn't increase.

### Prompt template (Claude)
You are a content moderator for an Indonesian sports community platform. Evaluate user-submitted golf tournament listings for spam, profanity, and misleading information. Return strict JSON ONLY.

Input data includes: name, description, location, format, submitter_email_domain, submitter_ip_similarity_score, word_count, presence_of_links.

Output:
{
  "decision": "approve"|"review_pending"|"reject",
  "reason": string explaining why (max 100 words, plain Indonesian or English),
  "flags": ["spam", "profanity", "misleading", "suspicious_sender", "empty_content"] (empty if none)
}

Scan for these specific Indonesian vulgar terms with cultural nuance: ngakak, nyokap, sial, bangsat, colek, bodoh, tolol, plus any obscene slurs toward regional groups or athletes. Do not flag casual sports commentary like "game gila" or "layanan mantap" unless paired with spammy intent.

If submitter_email_domain ends with @temp-mail, @mailinator, @yopmail, or similar disposable services, add suspicious_sender flag even if text content looks okay.

If word_count < 10 and no meaningful description, add empty_content flag and recommend reject.

If presence_of_links > 0 and those links lead to betting sites or unregistered domain redirects, add spam flag and recommend reject.

If decision is "review_pending", reason must include clear instructions for what an admin should verify manually.

Guardrails to enforce:
1. Truncate all input strings to 2000 chars before sending to model (no exception)
2. Remove any URLs from description before sending (model shouldn't see actual links to avoid bias or accidental click-through during testing)
3. Set max output tokens to 150 to prevent verbose, unstructured responses
4. Log the full moderation decision tuple (timestamp, submission_hash, decision, flags) but NEVER log raw input text with user PII

### Failure modes & fallbacks
| Scenario | Fallback |
|----------|----------|
| Anthropic moderation API flaps/retries twice with different verdicts | Take majority vote; if tie, default to review_pending (human review safer than auto-reject) |
| Moderation endpoint times out (>1s) | Default to review_pending — hold the submission until human approves, don't auto-publish |
| User submits repeatedly while pending | Deduplicate by email domain + fingerprint; warn admin about potential flood attack |
| Profanity detection misses slang common in Jakarta youth golf scene (e.g., "gaul" used pejoratively) | Maintain a local regex filter bank for known local slang + submit to model as "additional context" prompt field |

### What NOT to do
- ❌ Don't rely solely on AI moderation for everything — humans must review every "pending" submission before publishing. This is not a replace-anymode system.
- ❌ Don't send the actual email address or phone number of the submitter to the model. Send only the email domain (e.g., "@gmail.com") and a hash of their IP.
- ❌ Don't expose moderation decisions to users (don't say "your post was flagged"). If a rejection happens, give them a generic template: "This listing didn't meet our guidelines. Feel free to resubmit after reviewing the rules."
- ❌ Don't use a cheaper model for this task. The tradeoff between slight cost increase and false-negative spam is too dangerous for community trust.

---

## 3. Bookmark/Search AI — Legit Tournament Discovery

### What it does
Users discover legit tournaments through human curation or filtered lists. When they find something worthwhile, they **bookmark** it (the bookmark = "I've validated this is legit"). Later, they query their own natural language over those bookmarks:

"My bookmarked beginner tournaments in South Jakarta this weekend"  
"My saved courses under Rp 300k entry fee"  
"Show me the scrambles I liked earlier this month"

The AI understands intent, filters against the user's saved bookmarks, and returns ranked results with contextual explanations (**why** it matched each item). The bookmark is the trusted signal — this is **not** searching external listings, just the user's curated set.

**When to use it:** On the "/Bookmarks" tab when the user switches from basic list view to "Search bookmarks" mode (toggle button). Fall back to keyword search if they switch back to basic mode.

### Model choice
- **Model:** Claude Haiku (anthropic/claude-haiku-3-5)
- **Why:** Perfect balance of speed and understanding for search paraphrasing tasks. Much cheaper than Sonnet/Opus (<Rp 120,000 per 1K queries vs. >Rp 600,000), fast enough for UI (under 400ms). Handles Indonesian-English mixed queries well.
- **Cost:** ~$0.00075 / 1K input tokens, ~$0.00375 / 1K output tokens (~Rp 12,000 – Rp 60,000 per 1K queries)
- **Latency:** 200–400ms

### Architecture pattern
```
Flutter App → Backend API (/search/bookmarks) → Anthropic API → Query translation + ranking → Database fetch → Results to Flutter
       ^                           ^                         ^              ^
  free-text query          (user's saved IDs + filters)     (intent parsing)   (relevance scoring)
```

- Step 1: Backend sends the user's bookmark metadata (course, date, fee, skill_level, description, timestamp) and their raw query to the model.
- Step 2: Model outputs a refined filter predicate list AND optional explanation text for each top-3 match.
- Step 3: Backend applies predicates to the actual database (NOT trusting the model to return filtered data itself — security critical).
- Step 4: Model returns ranked explanation sentences ("Your query mentioned 'beginners' and this tournament lists beginner-friendly scramble format...").

### Prompt template (Claude)
You are a search assistant for golf tournament bookmarks. Given user's free-text query and a list of their saved tournaments with metadata, convert the query into precise filter criteria AND rank the most relevant matches with brief explanatory sentences.

User query: "[insert user query]"

Saved tournaments (max 50):
[{id, name, course, date, min_skill: "beginner/casual/competitive/pro", max_fee_idr: number, location, description, created_at}, ...]

Output strict JSON ONLY:
{
  "filters": {
    "min_skill": null|"beginner"|"casual"|"competitive"|"pro",
    "max_fee": number|null, // if fee mentioned in query
    "locations": [], // array of Jakarta area names if specified
    "date_range": {"from": null|ISO_string, "to": null|ISO_string} // if dates mentioned
  },
  "ranked_results": [
    {
      "tournament_id": string,
      "relevance_score": 0.0-1.0,
      "explanation": string explaining why this match fits the query (1 sentence max)
    }
  ],
  "fallback_note": null|String // if query is ambiguous, explain what assumptions were made
}

Convert natural language to concrete values:
- "weekend", "this weekend", "Saturday/Sunday" → next Saturday/Sunday (within 7 days from current date)
- "beginner", "casual", "low handicap", "for newbies", "first-timer" → min_skill: beginner or casual
- "under Rp 300k", "affordable", "cheap", "budget-friendly" → max_fee: value parsed from query
- "Menteng", "South Jakarta", "Emeralda", "Ryu Golf" → location match partial
- "scramble", "stableford", "best ball", "championship", "match-play" → check if description contains that format
- Ignore vague terms like "good", "nice", "popular" without concrete meaning.

If no concrete filters can be extracted, return null for all filter fields and sort by relevance_score descending based purely on description/query semantic similarity.

Guardrails to enforce:
1. Truncate tournament metadata list to max 30 entries if overflow (prioritize recency + fee proximity)
2. Never ask the model to return the actual tournament records — only filter predicates and rankings. Backend runs the real DB query.
3. Set max_output_tokens to 200 to keep response tight and fast.
4. Log the query + resulting filters for analytics (anonymize user_id in logs), but NEVER log full tournament descriptions with PII.

### Failure modes & fallbacks
| Scenario | Fallback |
|----------|----------|
| Model returns null or empty filters | Fall back to simple keyword search across tournament names/descriptions (PostgreSQL ILIKE), show a note "Showing basic search because your query was unclear" |
| Relevance score extremely low (<0.3) for all items | Show empty state: "Couldn't find matches. Try simpler keywords or broaden your filters" |
| Ambiguous date ("next week") → model can't resolve | Assume user means next calendar week (Monday–Sunday), clarify in fallback_note, show tentative results |
| User has 0 bookmarks | Return empty state with CTAs: "Save a tournament first so you can search it later" |

### What NOT to do
- ❌ Don't use the model to directly query the database. It will hallucinate WHERE clauses, return wrong IDs, and potentially leak data. The model only produces predicates; backend executes the real query.
- ❌ Don't show the model's internal thinking or probability scores to the user. Just surface the results with the single-line explanation from the `explanation` field.
- ❌ Don't run this feature before the user actually has at least 3 bookmarks. The ranking algorithm needs a minimum set to be useful. Until then, disable the AI search tab and show a plain filter grid instead.
- ❌ Don't charge users for using this. It's a core UX benefit, not a premium feature. Even if you later monetize, keep it free for now to build usage data.

---

## Dependency Summary

### Flutter client-side (pubspec.yaml)
For the AI-powered UI components that display loading states, explanations, and handle API communication:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP (already listed in previous UI stack)
  dio: ^5.4.0

  # Animation for AI processing feedback
  lottie: ^3.2.0

  # State management for AI loading/error states
  flutter_riverpod: ^2.4.0

  # Toast/notification for failed AI calls
  toast_messages: ^3.0.0

  # Optional: offline caching for previously generated recommendations
  hive: ^2.2.4
  hive_flutter: ^1.1.0
```

Add `flutter_gen` export for Lottie assets and icons.

### Backend (Node.js example)
If using Node.js + Express for moderation/recommendation/search endpoints:

```json
// package.json dependencies
"@anthropic/claude-kit": "^1.0.0", // official Anthropic Node SDK
"axios": "^1.7.0", // alternative to kit if you prefer manual HTTP
"zod": "^3.23.0", // validate responses before sending to frontend
"redis": "^4.6.7", // for caching recommendations (24h TTL)
"pg": "^8.11.0", // PostgreSQL client for actual DB queries
"winston": "^3.9.0", // structured logging (no PII!)
```

Python FastAPI alternative would use `anthropic` Python SDK + `uv-httpx` + `sqlalchemy`.

### Cost Estimate at MVP (1,000 MAU, 200 active users/day per feature)

| Feature | Queries/day | Daily cost (USD) | Monthly cost (USD) | Yearly cost (USD) |
|---------|-------------|------------------|-------------------|-------------------|
| Scoring/recommendation (Opus) | 200 | ~$3.00 | ~$90 | ~$1,100 |
| Content moderation (Sonnet) | 500 | ~$2.00 | ~$60 | ~$720 |
| Bookmark/search (Haiku) | 300 | ~$0.50 | ~$15 | ~$180 |
| **TOTAL** | **~1,000** | **~$5.50** | **~$165** | **~$2,000/year** |

At 10k MAU, scale linearly (~$20k/year total). All features worth the investment for Jakarta golfers who value quality over cheap clones. These costs assume moderate token usage (~500 input + 100 output tokens per call). Actual could vary ±30%.

---

## Critical Implementation Rules (Non-Negotiable)

1. **All AI responses must pass through a backend validator.** Never send Anthropic output directly to Flutter. Validate JSON schema with Zod (Node) or pydantic (Python). Fail closed if invalid.

2. **Never send raw PII to external LLMs.** Mask emails, phones, addresses before constructing prompts. Use hashing for identifiers in logs.

3. **Cache aggressively.** Recommendations, moderation verdicts, and search results for the same user + params within a 1-hour window should hit Redis/Cache before calling the API again.

4. **Track and log every call with metadata (not PII).** log_timestamp, model_used, input_token_count, output_token_count, decision_value. Essential for cost monitoring and debugging drift.

5. **Build an exit ramp.** All three features must degrade gracefully when the AI service is unavailable. Show a toast: "AI assistance temporarily unavailable. Showing basic results." Continue core functionality uninterrupted.

6. **Review quarterly.** Retrain/fine-tune nothing — just swap models if pricing changes. By 2027, expect better, cheaper alternatives (Claude 5? Gemini Ultra?). Monitor and be ready to switch Haiku ↔ Sonnet ↔ Opus assignments based on actual cost/performance data.

---

*Last updated: 2026-07-28*  
*Designed by: Hermes (Windah)*
