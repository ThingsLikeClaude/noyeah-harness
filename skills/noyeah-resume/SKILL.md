---
name: noyeah-resume
description: Resume an interrupted harness mode from saved state
---
# Resume - Continue Interrupted Work

## Purpose

Pick up where you left off after a session interruption. Reads saved state
and continues the active mode from the last phase.

## Usage

```
/noyeah-resume           # Auto-detect and resume the most recent active mode
/noyeah-resume ralph     # Resume Ralph specifically
/noyeah-resume autopilot # Resume Autopilot specifically
```

## Protocol

### 1. Detect State

Read all state files in `.harness/state/`:

```bash
cat .harness/state/noyeah-autopilot-state.json 2>/dev/null
cat .harness/state/noyeah-ralph-state.json 2>/dev/null
cat .harness/state/noyeah-ultrawork-state.json 2>/dev/null
cat .harness/state/noyeah-team-state.json 2>/dev/null
```

### 2. Find Resumable Mode

A mode is resumable if:
- `active: true` in its state file
- `current_phase` is NOT `complete`, `failed`, or `cancelled`

Priority order: autopilot > ralph > team > ultrawork

### 3. Restore Context

1. Read the context snapshot referenced in state
2. Read any active plan
3. Read project memory (`.harness/memory/project-memory.json`)
4. Read notepad (`.harness/notepad/notes.md`)

### 4. Continue from Last Phase

| Mode | Phase | Resume Action |
|------|-------|---------------|
| Autopilot | planning | Re-run `/noyeah-ralplan` |
| Autopilot | executing | Re-enter `/noyeah-ralph` |
| Autopilot | qa | Continue QA cycling |
| Autopilot | validation | Re-run architect reviews |
| Ralph | executing | Continue delegation loop |
| Ralph | verifying | Re-run verification |
| Ralph | fixing | Apply pending fixes |
| Team | dispatching | Re-launch failed workers |
| Team | monitoring | Check worker status |

### 5. Report Resume

```
RESUMED: {mode} from phase "{phase}" (iteration {N}/{max})
Context: {snapshot path}
Plan: {plan path}
Continuing from: {description of where we left off}
```

## Constraints

- Only one mode can be resumed at a time (highest priority wins)
- If state is corrupted, report and suggest `/noyeah-cancel --force`
- Autopilot preserves state for resume; Ralph/Ultrawork do not by default

## Original Task

$ARGUMENTS
