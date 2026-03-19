# Ralph State Contract (Frozen)

This contract defines the canonical Ralph state schema. Changes to this schema
require explicit versioning and migration.

## Schema

```json
{
  "active": true,
  "iteration": 1,
  "max_iterations": 10,
  "current_phase": "executing",
  "started_at": "2026-03-13T14:30:00Z",
  "completed_at": null,
  "task": "Implement OAuth callback",
  "context_path": ".harness/context/oauth-20260313T143000Z.md",
  "linked_ultrawork": false,
  "linked_team": false,
  "visual_scores": [],
  "failure_tracking": {},
  "state": {
    "context_snapshot_path": ".harness/context/oauth-20260313T143000Z.md"
  }
}
```

## Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| active | boolean | Yes | Whether Ralph is currently running |
| iteration | number | Yes | Current iteration (1-indexed) |
| max_iterations | number | Yes | Maximum iterations before stopping (default: 10) |
| current_phase | string | Yes | Current phase (frozen vocabulary below) |
| started_at | ISO string | Yes | When Ralph was activated |
| completed_at | ISO string | No | When Ralph finished (null while active) |
| task | string | Yes | Original task description |
| context_path | string | No | Path to context snapshot |
| linked_ultrawork | boolean | No | Whether ultrawork is linked |
| linked_team | boolean | No | Whether team mode is linked |
| visual_scores | array | No | Visual verdict scores per iteration |
| failure_tracking | object | No | Error signature → count map for debugger auto-escalation. Schema: `{ "sig_hash": { "signature": "error text", "count": N, "files": ["path"] } }` |

## Phase Vocabulary (Frozen)

These are the ONLY valid values for `current_phase`:

| Phase | Meaning | Transitions To |
|-------|---------|---------------|
| `starting` | Initial setup, context snapshot creation | `executing` |
| `executing` | Active implementation/delegation | `verifying`, `failed` |
| `verifying` | Running verification checks | `complete`, `fixing` |
| `fixing` | Addressing verification failures | `executing` |
| `complete` | All checks passed, architect approved | (terminal) |
| `failed` | Max iterations or fundamental blocker | (terminal) |
| `cancelled` | User requested cancellation | (terminal) |

## Terminal States

A Ralph run is terminal when `current_phase` is one of:
`complete`, `failed`, `cancelled`

Terminal states MUST set:
- `active: false`
- `completed_at: "{ISO timestamp}"`

## Cancellation Post-Conditions

When Ralph is cancelled:
1. State is terminalized: `active=false`, `current_phase='cancelled'`, `completed_at` set
2. If `linked_ultrawork=true`: ultrawork state also terminalized
3. If `linked_team=true`: team cancellation occurs first, then Ralph terminal propagation
4. Unrelated sessions are never mutated

## State File Location

Primary: `.harness/state/noyeah-ralph-state.json`

## Invariants

1. `iteration` is always >= 1 and <= `max_iterations`
2. `active=true` implies `completed_at=null`
3. `active=false` implies `completed_at` is set
4. Phase transitions follow the graph above (no skipping)
5. Only one Ralph instance can be active at a time
