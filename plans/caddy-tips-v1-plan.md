# kbvs_golf_flutter — Development Blueprint

## Scope: Caddy Tips v1.0 Only
No auth, no Firebase, no Hive yet. Focus: hitting golf club distances via caddy app.
Features limited to: distance input → caddy fee calculation → result display.

## Skill Frameworks
- **Superpowers**: all development process discipline
- **Emil Kowalski**: design/polish layer (UI/UX standards)
- **Hermes Agent**: tool usage conventions (Plane tickets, MCP, etc.)

## Development Phases

---
### PHASE 1: SPEC & PLAN — Use `superpowers:writing-plans` + `emil-kowalski:architecture-diagram`

**Objective:** Create formal implementation plan before touching code artifacts beyond prototype.

**Activities:**
1. Extract functional requirements from user conversation → `superpowers:brainstorming` chunking + consensus
2. Define scope boundaries explicitly: what's IN, what's OUT (e.g., "API integration is OUT for v1")
3. Generate architecture diagram (vertical slice: Home screen → state → utility functions) → `emil-kowalski:architecture-diagram` skill
4. Write multi-step plan document with tasks, constraints, acceptance criteria → `superpowers:writing-plans` output
5. Review plan against Emil taste-AI principles for feature prioritization → `emil-kowalski:taste-over-AI`

**Deliverable:** `plans/caddy-tips-v1-plan.md` (single source of truth)

**Milestone check:** Plan approved by human partner BEFORE any task dispatch. No implementation until here.

---
### PHASE 2: IMPLEMENTATION — Use `superpowers:subagent-driven-development` OR `superpowers:executing-plans`

**Choice logic:**
- Tasks independent? → subagent-driven-faster iteration, less context switch overhead  
- Parallel execution needed? → executing-plans (separate sessions)

**For v1 caddy tips (small scope):** Likely sequential, manageable via single session → use `subagent-driven-development` pattern manually without full agent orchestration, OR simply execute sequentially with verification checkpoints.

**Task breakdown (from Phase 1 plan):**

**T1: Core calculator logic**
- Skil: `superpowers:test-driven-development`
- Implementation: separate pure Dart function(s), first write failing tests → red → green → refactor
- Verification: test suite passes at 100% coverage for edge cases (zero distance, negative input max cap)

**T2: Home UI scaffold**
- Skill: `emil-kowalski:architecture-diagram` (wireframe → actual) → `emil-kowalski:apple-design` (material/ios consistency) → `emil-kowalski:pickle-ui-library` (appropriate widget choices)
- UI components: TextField for input, Button to calculate, Result text display
- Follow Emil spacing/scale system (8px baseline grid), typography hierarchy, color tokens

**T3: State management integration**
- Provider pattern (current project setup)
- ChangeNotifier on model → Consumer in UI
- Verify reactivity: input change triggers recalculation

**T4: Local persistence (in-memory only for v1)**
- No DB/file persist yet — keep simple
- If adding later, phase out as separate milestone

**T5: Self-review & fix loop**
- Internal review per task (as implemented by implementer)
- Critical/Important findings enter fix loop per `subagent-driven-development` protocol

**Deliverable:** Working Flutter project with fully tested caddy fee calculator

---
### PHASE 3: DESIGN POLISH — Use `emil-kowalski:` suite

**When to trigger:** After implementation phase, TDD green, lint clean.

**Activities:**
1. `emil-kowalski:pick-ui-library` — verify all widgets appropriate for material/approach
2. `emil-kowalski:improve-animations` — add entrance/feedback motions where appropriate (button press, result fade-in)
3. `emil-kowalski:review-animations` — run against high-craft checklist (timing curves, layering, perceptual clarity)
4. `emil-kowalski:design-an-interface` — one-off polish pass: alignment, spacing, typography consistency check
5. `emil-kowalski:cavecrew-decision` — if uncertain on visual direction, fast heuristic decision framework

**Goal:** Design polish that doesn't change functionality but elevates perceived quality.

---
### PHASE 4: VERIFICATION & FINISH — Use `superpowers:verification-before-completion` + `superpowers:finishing-a-development-branch`

**Verification checklist (non-negotiable):**
- [ ] All TDD tests pass (`flutter test`)
- [ ] Lint clean (`flutter analyze --no-fatal-infos --no-fatal-warnings`)
- [ ] Build success (`flutter build apk` / `flutter build ios`)
- [ ] Manual QA: input validation, edge cases, device rotation
- [ ] Emil design polish checklist complete
- [ ] Documentation: README updated with how-to-run

**Final branch process:**
1. Create feature branch (`git checkout -b feat/caddy-tips-v1`)
2. Commit each logical unit with atomic messages
3. Final whole-branch review per `requesting-code-review` pattern
4. Merge to main via PR/manual push

---
### OUT OF SCOPE (Explicitly Postponed)

These are NOT part of v1. Adding them triggers new plan revision:

- Firebase / Auth
- API connection to KBVS CRM
- Shot logging / historical data
- Dark mode (if not in initial design)
- Localization
- Push notifications
- AI suggestions

Any future request involving these → redirect to new planning phase with explicit scope approval.

---
### VERSION CONTROL CONVENTIONS

- Branch names: `feat/<description>`, `fix/<description>`, `docs/<description>`
- Commit messages: imperative mood, short subject + body if needed (50 char limit subject)
- PR descriptions link to relevant plan section from `caddy-tips-v1-plan.md`
- No direct commits to main — always PR/review

---
### SKILL REFERENCE INDEX

| Skill | Purpose | Usage Point |
|-------|---------|-------------|
| `superpowers:writing-plans` | Create structured plans before coding | Phase 1 |
| `superpowers:brainstorming` | Extract intent/requirements | Phase 1 |
| `superpowers:test-driven-development` | Red/green/refactor workflow | Phase 2 T1 |
| `superpowers:subagent-driven-development` | Task delegation + review gating | Phase 2 (optional/automated) |
| `superpowers:verification-before-completion` | Evidence before declaring done | Phase 4 |
| `superpowers:finishing-a-development-branch` | Final branch cleanup + merge | Phase 4 |
| `emil-kowalski:architecture-diagram` | Visual system architecture | Phase 1 |
| `emil-kowalski:apple-design` | Apple-style fluid motion/UI patterns | Phase 3 |
| `emil-kowalski:pick-ui-library` | Choose right library for task | Phase 2 T2 |
| `emil-kowalski:improve-animations` | Add motion where beneficial | Phase 3 |
| `emil-kowalski:review-animations` | Craft motion audit | Phase 3 |
| `emil-kowalski:design-an-interface` | One-off design polish | Phase 3 |
| `emil-kowalski:taste-over-AI` | Prioritize features by user value | Phase 1 |
