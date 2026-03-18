---
name: noyeah-ecomode
description: Cost-efficient modifier that shifts agent tiers down
---
# Ecomode - Token-Efficient Execution Modifier

## Purpose

Ecomode is a **modifier**, not a standalone mode. It overrides model routing to prefer
cheaper tiers, reducing cost while maintaining structured execution.

Ecomode can combine with ANY other mode: `eco ralph`, `eco ultrawork`, `eco autopilot`.

## Tier Shifting

| Normal Tier | Eco Tier | Model Change |
|-------------|----------|-------------|
| THOROUGH | STANDARD | opus -> sonnet |
| STANDARD | LOW | sonnet -> haiku |
| LOW | LOW | haiku -> haiku (floor) |

## Use When

- Budget-conscious execution
- Tasks that don't require maximum reasoning depth
- User says "eco", "cheap", "budget", "save tokens"
- Iterative work where early passes can be cheaper

## Do Not Use When

- Security-critical code (always needs THOROUGH)
- Architecture decisions (always needs THOROUGH)
- Final verification (keep original tier)

## Activation

Say any of:
```
/noyeah-ecomode on          # Enable eco modifier
eco ralph "task"     # Ralph with eco tiers
eco autopilot "task" # Autopilot with eco tiers
/noyeah-ecomode off         # Disable eco modifier
```

## State Management

Write to `.harness/state/noyeah-ecomode-state.json`:

```json
{
  "active": true,
  "started_at": "{ISO timestamp}",
  "linked_mode": "ralph",
  "original_tiers": {
    "executor": "STANDARD",
    "architect": "THOROUGH"
  },
  "eco_tiers": {
    "executor": "LOW",
    "architect": "STANDARD"
  }
}
```

## Implementation

When ecomode is active, all agent dispatches read the eco tier table:

```javascript
// Before dispatching any agent, check ecomode
function getModel(role, ecoActive) {
  const tierMap = {
    executor:  ecoActive ? "haiku"  : "sonnet",
    debugger:  ecoActive ? "haiku"  : "sonnet",
    verifier:  ecoActive ? "haiku"  : "sonnet",
    architect: ecoActive ? "sonnet" : "opus",
    planner:   ecoActive ? "sonnet" : "opus",
    critic:    ecoActive ? "sonnet" : "opus",
    explorer:  "haiku",  // always haiku
    writer:    "haiku",  // always haiku
  }
  return tierMap[role]
}
```

## Constraints

- Ecomode NEVER applies to:
  - Security reviews (always THOROUGH)
  - Final Ralph architect verification (minimum STANDARD)
  - Cancel/cleanup operations
- When eco + ralph: architect verification stays at STANDARD minimum (not shifted to LOW)

## Original Task

$ARGUMENTS
