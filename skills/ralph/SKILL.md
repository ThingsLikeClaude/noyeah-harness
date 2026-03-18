---
name: ralph
description: Persistence loop until task completion with architect verification
---
# Ralph - Persistence Loop for Claude Code

Your previous attempt did not output the completion promise. Continue working on the task.

## Purpose

Ralph is a persistence loop that keeps working until a task is **fully complete and architect-verified**.
It wraps parallel execution with automatic retry, state tracking, and mandatory verification.

Think of Sisyphus: the boulder never stops rolling until it reaches the top.

## Use When

- Task requires guaranteed completion with verification
- User says "ralph", "don't stop", "must complete", "keep going until done"
- Work may span multiple iterations and needs persistence
- Task benefits from parallel execution with architect sign-off

## Do Not Use When

- User wants full autonomous pipeline (idea to code) -> use `/autopilot`
- User wants to explore/plan first -> use `/ralplan`
- Quick one-shot fix -> delegate directly to executor
- User wants manual control -> use `/ultrawork`

## Execution Policy

- Dispatch independent agent calls simultaneously -- never wait sequentially for independent work
- Use `run_in_background: true` for long operations (installs, builds, test suites)
- Always pass the `model` parameter explicitly when delegating
- Deliver full implementation: no scope reduction, no partial completion
- Continue through clear, low-risk, reversible steps automatically
- Ask only when the next step is materially branching, destructive, or preference-dependent

## Steps

### 0. Pre-Context Intake (Required)

Before starting, create a context snapshot at `.harness/context/{task-slug}-{timestamp}.md`:

```markdown
# Context: {task description}
- **Task**: {what needs to be done}
- **Desired Outcome**: {what success looks like}
- **Known Facts**: {what we know}
- **Constraints**: {limitations}
- **Unknowns**: {open questions}
- **Touchpoints**: {files/modules likely affected}
```

If ambiguous, explore the codebase first, then ask targeted clarifying questions.

### 1. Initialize State

Write to `.harness/state/ralph-state.json`:

```json
{
  "active": true,
  "iteration": 1,
  "max_iterations": 10,
  "current_phase": "starting",
  "started_at": "{ISO timestamp}",
  "task": "{task description}",
  "context_path": ".harness/context/{slug}.md"
}
```

### 1.5. Read Methodology (After Initialize State)

Determine the TDD/DDD mode for this task:

**If a plan file exists** (from prior Ralplan): read the `## Methodology` section from
the plan. It contains `tdd_mode` and `ddd_mode` set by the planner.

**If no plan file exists** (standalone Ralph): dispatch a lightweight classification agent:

```
Agent(model: "haiku", prompt: "Classify this task for methodology selection.
  Task: {task description}
  Return: task_type (feature/bugfix/refactor/config/docs),
          tdd_mode (enforce/optional/skip),
          ddd_mode (applied/skipped).
  Rules: feature/bugfix/refactor-with-logic = enforce, config/docs = skip,
         fewer than 2 domain entities = ddd skipped.")
```

**Ecomode interaction rules:**
- Ecomode can downgrade `tdd_mode: enforce` → `optional`, but NEVER → `skip`
- When `tdd_mode: enforce`: test-engineer tier floor is STANDARD (sonnet), even under ecomode
- Security-related TDD (auth, crypto, input validation) always remains `enforce` regardless of ecomode
- Team mode: TDD discipline applies per-worker based on the plan's methodology section

### 2. Execute (Loop)

For each iteration:

1. **Review progress**: Check TODO list and prior iteration state
2. **Continue from where you left off**: Pick up incomplete tasks
3. **Apply TDD discipline** based on the methodology classification:

   **When `tdd_mode: enforce` (TDD-driven execution):**
   ```
   a. Test Framework Bootstrap: if no test framework detected, dispatch executor/build-fixer
      to install one (test-engineer recommends which framework, executor installs)
   b. RED phase: dispatch test-engineer to write failing tests + minimal stub files
      - Stubs contain type signatures with `throw new Error('Not implemented')` bodies
      - Tests must fail for assertion reasons, not compilation errors
      - Message to user: "TDD RED phase: writing failing tests first. These failures are
        expected and define the specification."
   c. GREEN phase: dispatch executor with plan + test files
      - Instruction: "Make these tests pass. Replace stub implementations with real code.
        Do not modify test files unless they contain actual bugs."
   d. REFACTOR: run tests to verify all green, then refactor if needed
   ```

   **When `tdd_mode: optional` (executor-first, tests after):**
   ```
   a. Dispatch executor to implement
   b. Dispatch test-engineer to write tests for the implementation
   c. Verify tests pass
   ```

   **When `tdd_mode: skip` (no tests):**
   ```
   a. Dispatch executor to implement directly
   b. Skip test-engineer dispatch
   ```

4. **Delegate in parallel**: Route to specialist agents at appropriate tiers
   - Simple lookups: LOW tier (model: haiku)
   - Standard work: STANDARD tier (model: sonnet)
   - Complex analysis: THOROUGH tier (model: opus)
5. **Run long operations in background**: Builds, installs, test suites
6. **Update state**: Write current iteration and phase to ralph-state.json

### 3. Verify Completion

**All of these must pass before claiming completion:**

a. Identify what command proves the task is complete
b. Run verification (test, build, lint) -- **fresh output, not cached**
c. Read the output -- confirm it actually passed
d. Check: zero pending/in_progress TODO items

### 4. Architect Verification (Tiered)

Spawn an architect agent for review:

| Scope | Minimum Tier |
|-------|-------------|
| <5 files, <100 lines, full tests | STANDARD (sonnet) |
| Standard changes | STANDARD (sonnet) |
| >20 files or security/architectural | THOROUGH (opus) |

**Ralph floor: always at least STANDARD, even for small changes.**

Use the Agent tool:

```
Agent(
  name: "architect-review",
  prompt: "Review these changes as an architect. Read agents/architect.md for your role definition. {details of changes}",
  model: "sonnet",  // or "opus" for THOROUGH
  subagent_type: "general-purpose"
)
```

### 5. On Approval

1. Update state: `{ "active": false, "current_phase": "complete", "completed_at": "{now}" }`
2. Run `/retro` to capture learnings from this run
3. Run `/cancel` for clean state cleanup
4. Report completion with evidence summary

### 6. On Rejection

1. Update state: `{ "current_phase": "fixing", "iteration": N+1 }`
2. Fix the issues raised
3. Re-verify at the same tier
4. Loop back to Step 3

## Escalation & Stop Conditions

- **Stop and report**: Missing credentials, unclear requirements, external service down
- **Stop on user request**: "stop", "cancel", "abort" -> run `/cancel`
- **Continue**: When iteration produces progress
- **Escalate**: Same issue recurs across 3+ iterations -> report as fundamental problem

## State Updates

Update `.harness/state/ralph-state.json` at each phase transition:

```javascript
// Phase transitions:
// starting -> executing -> verifying -> complete
//                       -> fixing -> executing (loop)
//                       -> failed
//                       -> cancelled
```

## Final Checklist

Before declaring complete:

- [ ] All requirements from original task are met (no scope reduction)
- [ ] Zero pending or in_progress TODO items
- [ ] Fresh test run output shows all tests pass
- [ ] Fresh build output shows success
- [ ] Architect verification passed (STANDARD minimum)
- [ ] State file updated to `complete`

## Examples

### Good: Correct parallel delegation

```
Agent(name: "impl-auth", model: "sonnet", prompt: "Implement OAuth callback handler")
Agent(name: "impl-tests", model: "sonnet", prompt: "Write integration tests for auth flow")
Agent(name: "impl-types", model: "haiku", prompt: "Add TypeScript type exports for UserConfig")
// All three dispatched simultaneously
```

### Good: Correct verification

```
1. Run: npm test           -> "42 passed, 0 failed"
2. Run: npm run build      -> "Build succeeded"
3. Run: npx tsc --noEmit   -> 0 errors
4. Architect review        -> "APPROVED"
5. State -> complete
```

### Bad: Claiming without evidence

"All the changes look good, the implementation should work correctly."
// Uses "should" and "look good" -- no fresh output, no architect review

## Original Task

$ARGUMENTS
