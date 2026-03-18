# Project Memory

## Concept

Project memory stores cross-session learnings, decisions, and patterns discovered
during harness execution. Unlike session state (which tracks active modes), memory
persists indefinitely and informs future work.

## Storage

`.harness/memory/project-memory.json`:

```json
{
  "entries": [
    {
      "id": "mem-001",
      "type": "decision",
      "timestamp": "2026-03-13T14:30:00Z",
      "content": "Chose Redis over Memcached for caching because we need persistence",
      "context": "ralplan consensus on caching layer redesign",
      "tags": ["architecture", "caching"]
    },
    {
      "id": "mem-002",
      "type": "pattern",
      "timestamp": "2026-03-13T15:00:00Z",
      "content": "Auth middleware always needs rate limiting -- 3 incidents without it",
      "context": "security review finding",
      "tags": ["security", "auth"]
    },
    {
      "id": "mem-003",
      "type": "learning",
      "timestamp": "2026-03-13T16:00:00Z",
      "content": "Integration tests catch auth bugs that unit tests miss",
      "context": "ralph iteration 3 failure was only caught by integration test",
      "tags": ["testing", "auth"]
    }
  ]
}
```

## Memory Types

| Type | Description | Example |
|------|-------------|---------|
| `decision` | Architectural or design decision | "Chose PostgreSQL over MongoDB" |
| `pattern` | Recurring code pattern or convention | "All API routes use zod validation" |
| `learning` | Lesson learned from past work | "Mocking DB hides migration bugs" |
| `constraint` | Known limitation or requirement | "Must support Node 18+" |
| `preference` | User's stated preference | "Prefers functional style over OOP" |

## When to Write Memory

- After `/noyeah-ralplan` completes: save key decisions and ADRs
- After `/noyeah-ralph` encounters a recurring issue: save the learning
- After security review: save findings as patterns
- When user states a preference: save it immediately

## When to Read Memory

- Before `/noyeah-ralplan`: check for relevant past decisions
- Before agent dispatch: include relevant patterns in context
- Before security review: check for known vulnerability patterns
- At session start: scan for relevant context

## Extended Learning Fields

Entries of type `"learning"` support these additional optional fields:

```json
{
  "id": "mem-004",
  "type": "learning",
  "timestamp": "2026-03-17T14:30:00Z",
  "content": "Mocking the database hides migration bugs -- integration tests with real DB caught the issue",
  "context": "ralph iteration 7 failure on OAuth callback task",
  "tags": ["testing", "database", "mocking"],
  "category": "testing",
  "confidence": 0.8,
  "times_seen": 1,
  "evidence": "Ralph run on 2026-03-17, iteration 7: test suite passed with mocks but failed with real DB due to missing migration",
  "applicable_when": "Testing database-related features with mocked connections",
  "recommendation": "Prefer real DB connections in integration tests over mocks for features involving schema changes"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `category` | string | Classification: `testing`, `build`, `architecture`, `security`, `delegation`, `tooling`, `implementation` |
| `confidence` | number (0.0-1.0) | Rough reliability signal. **Caveat**: LLM self-assessment without external calibration. Treat as approximate. `times_seen` is more reliable. |
| `times_seen` | number | How many times this pattern has been observed. **Primary reliability signal.** |
| `evidence` | string | Specific iteration/phase/event where this was observed |
| `applicable_when` | string | Conditions under which this learning applies |
| `recommendation` | string | What to do differently next time |

Existing fields (`id`, `type`, `timestamp`, `content`, `context`, `tags`) remain unchanged. Entries of types other than `"learning"` are unaffected.

## Structured Write Protocol (Retro)

When `/noyeah-retro` writes learnings to `project-memory.json`:

1. **READ** the entire `project-memory.json` file
2. **CHECK** for existing learning entries with similar content + category
   - If similar exists: increment `times_seen`, update `confidence`, merge `evidence`
   - If new: append as new entry with next sequential id
3. **WRITE** the updated `project-memory.json` (full file replacement)
4. **Hard cap**: max 200 entries of type `"learning"`. If exceeded, prune lowest-confidence entries first.

## Structured Read Protocol (Injection)

When dispatching agents, read learnings from `project-memory.json`:

1. **READ** `project-memory.json`
2. **FILTER** entries where `type == "learning"`
3. **SELECT** by category matching the target agent role (see Routing Table below)
4. **RANK** by: `times_seen` (descending), then `confidence` (descending)
5. **TAKE** top 5 entries (max ~500 tokens)
6. **FORMAT** as `PAST LEARNINGS` block (see `docs/learning-injection.md`)
7. **INJECT** into agent dispatch prompt

## Learning-to-Agent Routing Table

| Agent Role | Receives Learning Categories |
|------------|------------------------------|
| executor | `implementation`, `build`, `tooling` |
| debugger | `implementation`, `testing`, `build` |
| test-engineer | `testing`, `implementation` |
| build-fixer | `build`, `tooling` |
| architect | `architecture`, `security`, `delegation` |
| planner | `architecture`, `delegation` |
| security-reviewer | `security` |
| integrator | `build`, `implementation` |
| verifier | `testing`, `build` |

## Memory vs State

| | Memory | State |
|---|--------|-------|
| Lifespan | Indefinite | Until mode completes |
| Purpose | Cross-session learnings | Active mode tracking |
| Location | `.harness/memory/` | `.harness/state/` |
| Cleanup | Manual or on project end | On `/noyeah-cancel` |
