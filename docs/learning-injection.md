# Learning Injection

## Concept

Learning injection inserts relevant past learnings from `project-memory.json` into agent
dispatch prompts at composition time. This gives agents the benefit of accumulated project
knowledge without requiring them to read memory files themselves.

## When to Inject

At agent dispatch time, before composing the final prompt. Learning injection is part of
context composition (see `docs/overlay-system.md` — Learning Injection section).

## Selection Criteria

Filter learnings from `project-memory.json` using these rules in order:

1. **Type filter**: `type == "learning"` only. Non-learning entries are excluded.
2. **Category match**: Category must match the target agent's role (see routing table in `docs/project-memory.md`).
3. **Quality gate**: `confidence >= 0.6` AND `times_seen >= 1`. Entries below either threshold are excluded.
4. **Tag overlap** (bonus, not required): Learnings whose `tags` overlap with keywords in the task description are ranked higher.
5. **Ranking**: Sort by `times_seen` descending, then `confidence` descending.
6. **Cap**: Take the top 5 entries (~500 tokens maximum).

If fewer than 5 learnings pass the filter, inject only those that qualify. If zero pass, omit the `PAST LEARNINGS` block entirely.

## Injection Format

Insert the following block into the agent prompt, before the Task section:

```
## PAST LEARNINGS (auto-injected, {N} relevant entries)

These are lessons from previous runs. Apply them if relevant to your current task.

1. [confidence: 0.9, seen: 3x] **Mocking DB hides migration bugs**
   When: Testing database-related features
   Do: Prefer real DB connections in integration tests over mocks

2. [confidence: 0.7, seen: 1x] **Build fails silently on missing env vars**
   When: CI/CD or build step
   Do: Add env var validation at build entry point
```

Each entry maps to learning fields as follows:

| Injection field | Source field |
|----------------|--------------|
| `[confidence: X]` | `confidence` |
| `[seen: Nx]` | `times_seen` |
| Bold title | Derived from `content` (first clause) |
| `When:` | `applicable_when` |
| `Do:` | `recommendation` |

If `applicable_when` or `recommendation` are absent, use `content` as a single-line summary instead.

## Decay Rules

Before selecting learnings, apply decay to stale entries:

- **Age calculation**: `days_old = today - timestamp` (in days)
- **Decay trigger**: `days_old > 90`
- **Decay formula**: `confidence = confidence * 0.5` (halved once per 90-day period)
- **Prune threshold**: If decayed `confidence < 0.1`, exclude from injection (treat as pruned)

Decay is applied at read time for injection purposes only. It does not permanently modify `project-memory.json`. Permanent pruning is handled by the `/retro` write protocol.

## Confidence Calibration Caveat

`confidence` is an LLM self-assessment without external calibration. It reflects the
writing agent's subjective estimate of reliability at observation time. Do not treat it
as a statistically validated probability.

`times_seen` is the primary reliability indicator. A learning observed 3+ times is more
trustworthy than a single high-confidence observation. When `times_seen >= 3`, the
learning is considered well-established regardless of the `confidence` value (as long as
`confidence >= 0.6`).

## Routing Table Reference

The agent-to-category mapping that governs which learnings reach which agents is defined
in `docs/project-memory.md` under the "Learning-to-Agent Routing Table" section.

Data source: `.harness/memory/project-memory.json`

## Full Injection Algorithm (Pseudocode)

```
function inject_learnings(agent_role, task_description, memory_path):
  entries = read_json(memory_path).entries
  learnings = filter(entries, type == "learning")

  today = current_date()
  for each L in learnings:
    days_old = (today - L.timestamp).days
    if days_old > 90:
      L.confidence = L.confidence * 0.5

  target_categories = routing_table[agent_role]  # from docs/project-memory.md
  filtered = filter(learnings,
    L.category in target_categories
    AND L.confidence >= 0.6
    AND L.times_seen >= 1
    AND L.confidence >= 0.1  # post-decay prune threshold
  )

  # Bonus: rank higher if tags overlap task_description keywords
  ranked = sort(filtered,
    primary:   L.times_seen DESC,
    secondary: L.confidence DESC,
    bonus:     tag_overlap(L.tags, task_description) DESC
  )

  top5 = ranked[:5]

  if len(top5) == 0:
    return ""  # omit block entirely

  return format_past_learnings_block(top5)
```
