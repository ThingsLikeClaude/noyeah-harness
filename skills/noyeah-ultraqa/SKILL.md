---
name: noyeah-ultraqa
description: Autonomous QA cycling loop with architect diagnosis
---
# UltraQA - Autonomous QA Cycling

## Purpose

Automated QA loop that runs verification, diagnoses failures with an architect,
fixes issues, and repeats until all checks pass or max cycles reached.

## Use When

- User says "ultraqa", "qa loop", "fix all tests", "make everything pass"
- Multiple test/build/lint failures need systematic fixing
- Post-implementation QA sweep

## Do Not Use When

- Single known bug (use debugger directly)
- Need planning first (use `/noyeah-ralplan`)
- Full lifecycle needed (use `/noyeah-autopilot`)

## QA Cycle (Max 5 Rounds)

```
For each cycle (1..5):
  1. RUN all checks:
     - Tests: npm test / pytest / etc.
     - Build: npm run build / etc.
     - Lint: npm run lint / etc.
     - Typecheck: tsc --noEmit / etc.

  2. CHECK results:
     - All pass? -> EXIT with success report
     - Failures? -> Continue to step 3

  3. DIAGNOSE with architect (STANDARD tier):
     Agent(
       name: "qa-diagnosis-{cycle}",
       model: "sonnet",
       prompt: "Analyze these failures and categorize by root cause: {failures}"
     )

  4. FIX with executor (STANDARD tier):
     Agent(
       name: "qa-fix-{cycle}",
       model: "sonnet",
       prompt: "Fix these categorized issues: {diagnosis}"
     )

  5. REPEAT from step 1
```

## Exit Conditions

| Condition | Action |
|-----------|--------|
| All checks pass | Report success with evidence |
| 5 cycles reached | Report remaining failures |
| Same failure 3x | Escalate as fundamental problem |

## Supported Check Types

Configure which checks to run:

```
/noyeah-ultraqa --tests --build --lint --typecheck    # All (default)
/noyeah-ultraqa --tests                                # Tests only
/noyeah-ultraqa --build --typecheck                    # Build + types only
/noyeah-ultraqa --custom "npm run e2e"                 # Custom command
```

## State Management

Write to `.harness/state/noyeah-ultraqa-state.json`:

```json
{
  "active": true,
  "cycle": 1,
  "max_cycles": 5,
  "phase": "running_checks",
  "checks": ["tests", "build", "lint", "typecheck"],
  "started_at": "{ISO timestamp}",
  "history": [
    {
      "cycle": 1,
      "failures": ["3 test failures", "2 lint errors"],
      "fixes_applied": ["Fixed auth test mock", "Added missing semicolons"]
    }
  ]
}
```

Phase vocabulary: `running_checks` -> `diagnosing` -> `fixing` -> `complete` | `failed` | `cancelled`

## Original Task

$ARGUMENTS
