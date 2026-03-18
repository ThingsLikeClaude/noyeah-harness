---
name: autopilot
description: Full autonomous pipeline from idea to verified implementation
---
# Autopilot - End-to-End Autonomous Pipeline

## Purpose

Takes a 2-3 line product idea and delivers a verified implementation through 6 phases.
This is the highest-level orchestration mode -- it composes `/ralplan` for planning
and `/ralph` for persistent execution.

## Use When

- User says "autopilot", "ship it", "end to end", "build this from scratch"
- Task needs full lifecycle: plan -> implement -> test -> verify
- User wants hands-off execution with quality guarantees

## Do Not Use When

- Task is a simple bug fix (use executor directly)
- User wants to control planning manually (use `/ralplan` then `/ralph`)
- User wants parallel fan-out only (use `/ultrawork`)

## Phases

### Phase 0: Pre-Context Intake

1. Create context snapshot at `.harness/context/autopilot-{slug}-{timestamp}.md`
2. If request is vague, explore codebase first, then run brief Socratic interview (max 5 questions)
3. Do not proceed until context snapshot exists

### Phase 1: Planning (via /ralplan)

1. Invoke `/ralplan` with the task description
2. Output: approved plan at `.harness/plans/plan-{slug}.md`
3. Gate: implementation is blocked until plan exists and is approved

### Phase 2: Execution (via /ralph)

1. Invoke `/ralph` with the approved plan
2. Ralph handles: parallel delegation, iteration, persistence
3. State tracked in `.harness/state/ralph-state.json`

### Phase 3: QA Cycling (up to 5 cycles)

After Ralph reports completion:

```
For each QA cycle (max 5):
  1. Run full test suite
  2. Run build
  3. Run linter/typecheck
  4. If all pass -> proceed to Phase 4
  5. If failures -> fix and repeat
  6. If same failure 3x -> escalate to user
```

### Phase 4: Multi-Perspective Validation

Spawn 3 parallel architect reviews:

```
Agent(name: "review-correctness", model: "opus",
  prompt: "Review for correctness. Does this implementation meet all requirements?")
Agent(name: "review-security", model: "opus",
  prompt: "Review for security. Any OWASP Top 10 vulnerabilities?")
Agent(name: "review-maintainability", model: "sonnet",
  prompt: "Review for maintainability. Code quality, naming, structure?")
```

All three must approve. Any rejection -> fix and re-review.

### Phase 5: Cleanup & Report

1. Update state to `complete`
2. Run `/retro` to capture learnings from this run
3. Run `/cancel` for clean state cleanup
4. Report: what was built, evidence of completion, any caveats

## State Management

Write to `.harness/state/autopilot-state.json`:

```json
{
  "active": true,
  "phase": "planning",
  "started_at": "{ISO timestamp}",
  "task": "{task description}",
  "plan_path": null,
  "ralph_iterations": 0,
  "qa_cycles": 0,
  "reviews_passed": []
}
```

Update `phase` at each transition: `intake` -> `planning` -> `executing` -> `qa` -> `validation` -> `complete`

## Cancellation

On cancel, autopilot cleans up in order:
1. Cancel ralph (if active)
2. Cancel ultrawork (if linked)
3. Mark autopilot as inactive (preserve state for resume)

## Original Task

$ARGUMENTS
