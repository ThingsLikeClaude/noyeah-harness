---
name: retro
description: Post-completion retrospective analysis that extracts learnings
---
# Retro - Post-Completion Retrospective

## Purpose

Runs after Ralph or Autopilot completion to analyze the run and extract structured
learnings into `project-memory.json`. Turns execution history into durable knowledge
that improves future runs.

Think of it as the debrief after a mission: what happened, what worked, what to do
differently next time.

## Use When

- After `/ralph` completes (called automatically in Step 5)
- After `/autopilot` completes (called automatically in Phase 5)
- User says "retro", "retrospective", "what did we learn", "capture learnings"
- Any time you want to extract structured learnings from a recent run

## Do Not Use When

- Mid-execution (retro reads terminal state, not in-progress state)
- As a substitute for verification (retro records facts, does not verify correctness)

---

## Analysis Protocol

### Step 1: Read State Files

Read all three state files. Treat missing files as absent (not an error):

- `.harness/state/ralph-state.json`
- `.harness/state/autopilot-state.json`
- `.harness/state/ultrawork-state.json`

### Step 2: Read Harness Log

Attempt to read `.harness/logs/harness-{today}.jsonl` (where `{today}` is today's date
in `YYYY-MM-DD` format). This file may not exist -- that is normal.

### Step 3: Extract Guaranteed Facts (from State Files)

The following fields are guaranteed by the frozen Ralph state contract and MUST be
reported when ralph-state.json exists:

| Fact | Source Field |
|------|-------------|
| Total iterations used | `iteration` |
| Total elapsed time | `completed_at` - `started_at` |
| Terminal outcome | `current_phase` (`complete` / `failed` / `cancelled`) |
| Whether ultrawork was linked | `linked_ultrawork` |
| Whether team was linked | `linked_team` |
| Task description | `task` |

For autopilot-state.json, extract when present:

| Fact | Source Field |
|------|-------------|
| Ralph iterations | `ralph_iterations` |
| QA cycles used | `qa_cycles` |
| Reviews passed | `reviews_passed` |
| Final phase | `phase` |

### Step 4: Extract Conditional Facts (from Harness Log)

Only when the log file exists and contains relevant entries:

- **Phase distribution**: How much time was spent in each phase (`executing`, `verifying`, `fixing`)
- **Failure patterns**: Recurring error types across iterations
- **Escalation events**: Times the same issue appeared 3+ times (3-strike escalation)
- **Parallel efficiency**: Whether ultrawork/team delegation reduced iteration count

If the log file does not exist, note "log unavailable" for these fields -- do not invent data.

### Step 5: Data Integrity Note

> The retro skill reports on best-available data. Missing data is noted, not invented.

Never fabricate iteration counts, timings, or failure patterns. If a field is absent from
state files, report it as "not recorded" and omit it from learnings evidence.

### Step 6: Extract Learnings

From the available facts, identify actionable learnings. Each learning must meet:
- It describes a repeatable pattern, not a one-off coincidence
- It has a clear recommendation (what to do differently)
- It has concrete evidence from this run

Format each learning as a `project-memory.json` entry of type `"learning"` with all
extended fields:

```json
{
  "id": "mem-{next-sequential-id}",
  "type": "learning",
  "timestamp": "{ISO timestamp of now}",
  "content": "{concise description of the pattern observed}",
  "context": "{which run, which phase, what happened}",
  "tags": ["{relevant tags}"],
  "category": "{testing|build|architecture|security|delegation|tooling|implementation}",
  "confidence": 0.7,
  "times_seen": 1,
  "evidence": "{specific iteration/phase/event from this run}",
  "applicable_when": "{conditions under which this learning applies}",
  "recommendation": "{what to do differently next time}"
}
```

Valid categories: `testing`, `build`, `architecture`, `security`, `delegation`, `tooling`, `implementation`

### Step 7: Deduplicate Against Existing Entries

Follow the Structured Write Protocol from `docs/project-memory.md`:

1. Read the entire `project-memory.json` (create it with `{"entries": []}` if it does not exist)
2. For each new learning, check for existing entries with similar content + category:
   - **Similar exists**: increment `times_seen`, update `confidence` (nudge up by 0.05, max 1.0), merge `evidence` field
   - **New**: append as new entry with next sequential id

### Step 8: Housekeeping

Apply these rules to ALL existing learning entries (not just the new ones):

| Rule | Condition | Action |
|------|-----------|--------|
| Confidence decay | Entry is older than 90 days AND `times_seen == 1` | Halve `confidence` |
| Pruning | `confidence < 0.1` | Remove entry |
| Hard cap | Total `"learning"` entries > 200 | Remove lowest-confidence entries until count == 200 |

### Step 9: Write project-memory.json

Write the full updated `project-memory.json` (complete file replacement, not partial update).

### Step 10: Report to User

Output a retro summary in this format:

```
## Retro Summary

**Run**: {task description}
**Outcome**: {complete | failed | cancelled}
**Iterations**: {N} of {max}
**Elapsed**: {HH:MM:SS or "not recorded"}
**Ultrawork linked**: {yes | no}
**Team linked**: {yes | no}

### Learnings Extracted: {N}

{For each learning:}
- [{category}] {content}
  - Evidence: {evidence}
  - Recommendation: {recommendation}

### Deduplication
- {N} new entries added
- {N} existing entries updated (times_seen incremented)
- {N} entries pruned (confidence < 0.1)

### Data Availability
- State files: {which were present}
- Harness log: {present | not found}
- {Any specific fields that were unavailable}
```

---

## Constraints

1. **Never invent data.** If a field is missing from state or log, report it as unavailable.
2. **Read before write.** Always read the full `project-memory.json` before writing.
3. **Surgical write.** Only update the `entries` array -- do not restructure the file.
4. **No side effects.** Retro does not modify state files, plans, or context snapshots.
5. **Idempotent.** Running retro twice on the same completed run should update `times_seen` on the second run, not create duplicates.

---

## Examples

### Good: Reporting unavailable data honestly

```
**Elapsed**: not recorded (completed_at was null in state file)
**Harness log**: not found -- phase distribution unavailable
```

### Bad: Inventing data

```
**Elapsed**: approximately 45 minutes  ← fabricated, state file had null
**Failure patterns**: likely test timeouts  ← speculative, no log
```

### Good: Extracting a learning with evidence

```json
{
  "content": "Build cache invalidation required manual flush after dependency updates",
  "evidence": "Ralph run 2026-03-17 iteration 4: build failed until cache cleared",
  "recommendation": "Add cache-clear step before build when package.json changes"
}
```

### Bad: Vague learning without recommendation

```json
{
  "content": "Build had issues",
  "evidence": "it failed",
  "recommendation": "be careful"
}
```

---

## Original Task

$ARGUMENTS
