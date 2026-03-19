---
name: noyeah-ralph
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

- User wants full autonomous pipeline (idea to code) -> use `/noyeah-autopilot`
- User wants to explore/plan first -> use `/noyeah-ralplan`
- Quick one-shot fix -> delegate directly to executor
- User wants manual control -> use `/noyeah-ultrawork`

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

Write to `.harness/state/noyeah-ralph-state.json`:

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

4. **Security gate (after GREEN/implementation)**: If the task involves auth, user input,
   API endpoints, or database operations, dispatch security-reviewer IN PARALLEL with
   the next iteration prep:

   ```
   Agent(
     name: "security-gate",
     model: "opus",
     prompt: "Read agents/security-reviewer.md. Review these changes: {files_changed}.
       Focus on: {auth|input-validation|API|DB} aspects.
       Output SECURITY REVIEW with verdict: BLOCK | FIX_BEFORE_MERGE | ACCEPTABLE",
     run_in_background: true
   )
   ```

   **Verdict handling:**
   - `BLOCK` → pause execution, surface findings to user immediately
   - `FIX_BEFORE_MERGE` → add security fixes to next iteration TODO
   - `ACCEPTABLE` → log findings and continue

   This gate is **non-blocking**: execution proceeds while security review runs in background.

5. **Debugger auto-escalation**: Track `error_signature` → count in ralph-state.json
   under `failure_tracking`:

   ```json
   "failure_tracking": {
     "error_abc123": { "signature": "Cannot read property 'id'", "count": 2, "files": ["src/api/users.ts"] }
   }
   ```

   - Same error appearing **2+ times** → dispatch debugger(sonnet) INSTEAD of executor:
     ```
     Agent(
       name: "debugger-escalation",
       model: "sonnet",
       prompt: "Read agents/debugger.md. This error has recurred {count} times.
         Error: {signature}. Affected files: {files}.
         Follow your 5-step protocol: REPRODUCE → GATHER → HYPOTHESIZE → FIX → VERIFY."
     )
     ```
   - Reset count after successful fix
   - Build failures do NOT count toward debugger escalation (handled separately)

6. **Build-fixer auto-dispatch**: On build failure, dispatch build-fixer IN PARALLEL:

   ```
   Agent(
     name: "build-fix",
     model: "sonnet",
     prompt: "Read agents/build-fixer.md. Build command: {cmd}. Output: {error_output}.
       Apply minimal fixes only.",
     run_in_background: true
   )
   ```

   Executor continues non-build tasks while build-fixer works.

7. **Delegate in parallel**: Route to specialist agents at appropriate tiers
   - Simple lookups: LOW tier (model: haiku)
   - Standard work: STANDARD tier (model: sonnet)
   - Complex analysis: THOROUGH tier (model: opus)
8. **Run long operations in background**: Builds, installs, test suites
9. **Update state**: Write current iteration and phase to ralph-state.json

### 3. Verify Completion (via Verifier Agent)

Instead of inline verification, dispatch the verifier agent:

```
Agent(
  name: "ralph-verifier",
  model: "sonnet",
  prompt: "Read agents/verifier.md. Verify completion of: {task}.
    Plan: {plan_path}. Iteration: {N}.
    Run fresh tests, build, lint. Check all requirements.
    Output structured VERIFICATION REPORT with verdict: PASS | FAIL | INCOMPLETE"
)
```

**On verdict:**
- `PASS` → proceed to Step 4 (Architect Verification)
- `FAIL` or `INCOMPLETE` → add unresolved items to next iteration TODO → loop to Step 2
- Benefit: executor can prep the next iteration WHILE verifier checks current work

### 4. 4-Agent Validation Panel

Replace single architect review with a parallel 4-agent panel:

```
// All 4 dispatched simultaneously
Agent(
  name: "panel-architect",
  model: "sonnet",  // or "opus" for >20 files or security/architectural changes
  prompt: "Read agents/architect.md. Review for correctness and completeness. {changes}"
)
Agent(
  name: "panel-critic",
  model: "opus",
  prompt: "Read agents/critic.md. Review for plan adherence, tradeoffs, and ADR. {plan_path} {changes}"
)
Agent(
  name: "panel-security",
  model: "opus",
  prompt: "Read agents/security-reviewer.md. Final security scan of all changes. {changes}"
)
Agent(
  name: "panel-writer-check",
  model: "haiku",
  prompt: "Read agents/writer.md. Check if documentation updates are needed for these changes.
    Report: which docs need updating, what's missing. Advisory only — do not write docs yet. {changes}"
)
```

**Approval rules:**
- `architect` + `critic` + `security-reviewer` must ALL approve → proceed to Step 5
- Any rejection → fix issues → re-verify at same tier → loop to Step 3
- `writer-check` findings are noted for Step 5.5 (advisory, not blocking)

**Ralph floor: architect always at least STANDARD, even for small changes.**

| Scope | Architect Tier |
|-------|---------------|
| <5 files, <100 lines, full tests | STANDARD (sonnet) |
| Standard changes | STANDARD (sonnet) |
| >20 files or security/architectural | THOROUGH (opus) |

### 5. On Approval

1. Update state: `{ "active": false, "current_phase": "complete", "completed_at": "{now}" }`
2. Run `/noyeah-retro` to capture learnings from this run
3. Run `/noyeah-cancel` for clean state cleanup
4. Report completion with evidence summary

### 5.5. Auto Writer (Non-Blocking)

If the writer-check in Step 4 found documentation updates needed:

```
Agent(
  name: "ralph-writer",
  model: "haiku",
  prompt: "Read agents/writer.md. Update documentation based on these findings: {writer_check_findings}.
    Source files: {files_changed}. Write/update docs as needed.",
  run_in_background: true
)
```

- Non-blocking: completion proceeds regardless of writer output
- Writer results are logged but do not gate the Ralph outcome

### 6. On Rejection

1. Update state: `{ "current_phase": "fixing", "iteration": N+1 }`
2. Fix the issues raised
3. Re-verify at the same tier
4. Loop back to Step 3

## Escalation & Stop Conditions

- **Stop and report**: Missing credentials, unclear requirements, external service down
- **Stop on user request**: "stop", "cancel", "abort" -> run `/noyeah-cancel`
- **Continue**: When iteration produces progress
- **Escalate**: Same issue recurs across 3+ iterations -> report as fundamental problem

## State Updates

Update `.harness/state/noyeah-ralph-state.json` at each phase transition:

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
