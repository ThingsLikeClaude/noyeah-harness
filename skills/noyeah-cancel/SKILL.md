---
name: noyeah-cancel
description: Cancel any active harness mode and clean up state
---
# Cancel - Clean Mode Termination

## Purpose

Detect and cancel the active harness mode, cleaning up state files properly.

## Usage

Say "cancel", "stop", or "abort", or invoke `/noyeah-cancel`.

## Detection & Cleanup Order

Check and cancel in dependency order:

### 1. Check Autopilot

```bash
cat .harness/state/noyeah-autopilot-state.json 2>/dev/null
```

If active:
- Cancel linked ralph first
- Cancel linked ultrawork
- Mark autopilot as `{ "active": false, "phase": "cancelled", "cancelled_at": "{now}" }`
- Preserve state for potential resume

### 2. Check Ralph

```bash
cat .harness/state/noyeah-ralph-state.json 2>/dev/null
```

If active:
- Cancel linked ultrawork if `linked_ultrawork: true`
- Set ralph state: `{ "active": false, "current_phase": "cancelled", "completed_at": "{now}" }`
- Remove ralph verification artifacts

### 3. Check Ultrawork (standalone)

```bash
cat .harness/state/noyeah-ultrawork-state.json 2>/dev/null
```

If active and NOT linked to ralph:
- Set ultrawork state: `{ "active": false }`

### 4. Check Ralplan

```bash
cat .harness/state/noyeah-ralplan-state.json 2>/dev/null
```

If active:
- Set ralplan state: `{ "active": false, "status": "cancelled" }`

### 5. No Active Modes

Report: "No active harness modes detected."

## Force Clear

With `--force` flag, delete ALL state files:

```bash
rm -f .harness/state/*.json
```

Report: "All harness modes cleared. Fresh start."

## Messages

| Mode | Message |
|------|---------|
| Autopilot | "Autopilot cancelled at phase: {phase}. State preserved for resume." |
| Ralph | "Ralph cancelled. Persistence loop deactivated." |
| Ultrawork | "Ultrawork cancelled. Parallel execution stopped." |
| Ralplan | "Ralplan cancelled. Planning session ended." |
| Force | "All harness modes cleared. Fresh start." |
| None | "No active harness modes detected." |

## Original Task

$ARGUMENTS
