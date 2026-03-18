---
name: noyeah-status
description: Show active harness modes and current state
---
# Status - Harness State Dashboard

## Purpose

Display what's currently active, iteration progress, and phase information.
Designed for at-a-glance comprehension, including for users new to noyeah-harness.

## Usage

```
/noyeah-status
```

## Display Format

Read all state files from `.harness/state/` and render a visual dashboard.

### Status Labels

Use these ASCII text labels consistently (replaces Unicode circles for terminal compatibility):

| Label | Meaning |
|-------|---------|
| `[ACTIVE]` | Mode is currently running |
| `[DONE]` | Mode completed successfully |
| `[FAIL]` | Mode failed (see failure summary) |
| `[OFF]` | Mode is not active |

### Progress Bars (iteration-based modes)

For Ralph and UltraQA, show progress as a bar:

```
Ralph:    [=========>    ] 7/10 iterations (executing)
UltraQA:  [=====>        ] 3/5 cycles (fixing)
```

Bar width: 15 characters. Fill with `=`, current position with `>`, remaining with spaces.
Calculate fill: `round(current / max * 14)` characters of `=`, then `>`.

### Autopilot Step Checklist

When autopilot is active, show pipeline progress:

```
Autopilot Pipeline:
  [x] 1. Requirements gathering
  [x] 2. Consensus planning (RALPLAN)
  [>] 3. Execution (Ralph, iteration 7/10)
  [ ] 4. QA cycling (UltraQA)
  [ ] 5. Multi-perspective validation
  [ ] 6. Cleanup & report
```

Map autopilot phases to steps:
- `intake` -> step 1
- `planning` -> step 2
- `executing` -> step 3
- `qa` -> step 4
- `validation` -> step 5
- `complete`/`cancelled` -> step 6

### Failure Summary

When any mode has `"current_phase": "failed"`, display actionable guidance:

```
ATTENTION: Ralph failed at iteration 10/10
  Last phase: verifying
  Suggestion: Run /noyeah-cancel, then try splitting the task with /noyeah-ralplan
  See: docs/failure-recovery.md
```

Failure suggestions by mode:
- **Ralph failed**: "Run /noyeah-cancel, then try splitting the task with /noyeah-ralplan"
- **UltraQA failed**: "Run /noyeah-cancel. Check for flaky tests or environment issues"
- **Ralplan revision limit**: "Consider running /noyeah-deep-interview to clarify requirements"

### Memory & Context Summary

Show project memory and active context:

```
Memory: 12 entries (4 decisions, 3 patterns, 5 learnings)
Context: .harness/context/oauth-20260317.md
Plan: .harness/plans/plan-oauth.md
```

Count entries by `type` field in project-memory.json. Exclude entries with `"type": "template"`.

## Full Dashboard Example

```
noyeah-harness Status
=================

Modes:
  Autopilot:  [ACTIVE] (executing phase)
  Ralph:      [ACTIVE] iter 7/10 [=========>    ] (executing)
  Ultrawork:  [OFF]
  Ralplan:    [DONE]
  UltraQA:    [OFF]
  Team:       [OFF]
  Ecomode:    [OFF]

Autopilot Pipeline:
  [x] 1. Requirements gathering
  [x] 2. Consensus planning (RALPLAN)
  [>] 3. Execution (Ralph, iteration 7/10)
  [ ] 4. QA cycling (UltraQA)
  [ ] 5. Multi-perspective validation
  [ ] 6. Cleanup & report

Memory: 8 entries (2 decisions, 1 pattern, 4 learnings, 1 constraint)
Context: .harness/context/user-auth-20260317.md
Plan: .harness/plans/plan-user-auth.md
```

## Implementation

Check each state file:

```bash
for mode in autopilot ralph ultrawork ralplan ultraqa team ecomode; do
  cat .harness/state/${mode}-state.json 2>/dev/null
done
```

For each mode:
1. If state file missing or `"active": false` with no terminal phase -> `[OFF]`
2. If `"active": true` -> `[ACTIVE]` with phase details
3. If `"active": false` and `"current_phase": "complete"` -> `[DONE]`
4. If `"active": false` and `"current_phase": "failed"` -> `[FAIL]` with failure summary

Also read:
- `.harness/memory/project-memory.json` for memory summary (count by type, exclude "template")
- `.harness/context/` for most recent context snapshot
- `.harness/plans/` for most recent plan
- `.harness/notepad/notes.md` for notepad preview (first 3 lines)

Graceful degradation: if any file is missing or unreadable, show `[OFF]` or omit the section.
Never show an error message in the dashboard.

## Original Task

$ARGUMENTS
