---
name: noyeah-autopilot
description: Full autonomous pipeline from idea to verified implementation
---
# Autopilot - End-to-End Autonomous Pipeline

## Purpose

Takes a 2-3 line product idea and delivers a verified implementation through 6 phases.
This is the highest-level orchestration mode -- it composes `/noyeah-ralplan` for planning
and `/noyeah-ralph` for persistent execution.

## Use When

- User says "autopilot", "ship it", "end to end", "build this from scratch"
- Task needs full lifecycle: plan -> implement -> test -> verify
- User wants hands-off execution with quality guarantees

## Do Not Use When

- Task is a simple bug fix (use executor directly)
- User wants to control planning manually (use `/noyeah-ralplan` then `/noyeah-ralph`)
- User wants parallel fan-out only (use `/noyeah-ultrawork`)

## Phases

### Phase 0: Pre-Context Intake

1. Create context snapshot at `.harness/context/noyeah-autopilot-{slug}-{timestamp}.md`
2. If request is vague, explore codebase first, then run brief Socratic interview (max 5 questions)
3. Run `/noyeah-skill-scout` to detect and install project-relevant skills from skills.sh
   - If tech stack detected from manifest files → auto mode
   - If empty project → use context snapshot or interview results for stack
   - If skill-scout fails or no stack detected → warn and continue (non-blocking)
4. Do not proceed until context snapshot exists

### Phase 0.5: Research (Conditional)

Triggered automatically when research auto-detection fires (see `rules/keyword-detection.md`):

1. **Check trigger conditions**: creation verb + domain noun + greenfield context
2. **Dispatch researcher**:
   ```
   Agent(
     name: "autopilot-researcher",
     model: "sonnet",
     prompt: "Read agents/researcher.md. Research competitors and architecture for: {task}.
       Domain: {detected_domain}. Output to .harness/context/research-{slug}-{timestamp}.md"
   )
   ```
3. **Extract summary**: Read the `## Summary` section (500 tokens) from the research report
4. **Store in state**: Add `research_path` and `research_summary` to autopilot-state.json
5. **Pass to Phase 1**: Both planner and architect receive the research summary as context

**Override flags:**
- `--no-research`: Skip even if auto-detection triggers
- `--research`: Force research even if auto-detection doesn't trigger

### Phase 1: Planning (via /noyeah-ralplan)

1. Invoke `/noyeah-ralplan` with the task description
2. Output: approved plan at `.harness/plans/plan-{slug}.md`
3. Gate: implementation is blocked until plan exists and is approved

### Phase 2: Execution (via /noyeah-ralph)

1. Invoke `/noyeah-ralph` with the approved plan
2. Ralph handles: parallel delegation, iteration, persistence
3. State tracked in `.harness/state/noyeah-ralph-state.json`

### Phase 3: Agent-Based QA Cycling (up to 5 cycles)

After Ralph reports completion, use dedicated agents per cycle:

```
For each QA cycle (max 5):
  1. Dispatch verifier(sonnet):
     Agent(
       name: "qa-verifier-{cycle}",
       model: "sonnet",
       prompt: "Read agents/verifier.md. Run full verification: tests, build, lint, typecheck.
         Plan: {plan_path}. Output structured VERIFICATION REPORT."
     )
  2. If verifier reports PASS -> proceed to Phase 4
  3. If verifier reports FAIL:
     a. Dispatch debugger(sonnet) to diagnose:
        Agent(name: "qa-debugger", model: "sonnet",
          prompt: "Read agents/debugger.md. Diagnose: {failure_details}")
     b. Dispatch executor(sonnet) to fix based on debugger's diagnosis
     c. Repeat cycle
  4. Same failure 3x -> escalate to user with debugger's analysis
```

### Phase 4: Multi-Perspective Validation (4 reviewers)

Spawn 4 parallel reviews:

```
Agent(name: "review-correctness", model: "opus",
  prompt: "Read agents/architect.md. Review for correctness.
    Does this implementation meet all requirements in {plan_path}?")
Agent(name: "review-security", model: "opus",
  prompt: "Read agents/security-reviewer.md. Review for security.
    Check OWASP Top 10, secrets, dependency vulnerabilities.")
Agent(name: "review-maintainability", model: "sonnet",
  prompt: "Read agents/architect.md. Review for maintainability.
    Code quality, naming, structure, test coverage?")
Agent(name: "review-critic", model: "opus",
  prompt: "Read agents/critic.md. Review for plan adherence and tradeoffs.
    Plan: {plan_path}. Are all planned features implemented? Any scope drift?
    Output ADR if architectural decisions were made during implementation.")
```

All four must approve. Any rejection -> fix and re-review.

### Phase 5: Cleanup & Report

1. Update state to `complete`
2. Run `/noyeah-retro` to capture learnings from this run
3. Run `/noyeah-cancel` for clean state cleanup
4. Report: what was built, evidence of completion, any caveats

## State Management

Write to `.harness/state/noyeah-autopilot-state.json`:

```json
{
  "active": true,
  "phase": "planning",
  "started_at": "{ISO timestamp}",
  "task": "{task description}",
  "plan_path": null,
  "ralph_iterations": 0,
  "qa_cycles": 0,
  "reviews_passed": [],
  "research_path": null,
  "research_summary": null,
  "skills_scouted": false,
  "skills_installed": []
}
```

Update `phase` at each transition: `intake` -> `research` -> `planning` -> `executing` -> `qa` -> `validation` -> `complete`

## Cancellation

On cancel, autopilot cleans up in order:
1. Cancel ralph (if active)
2. Cancel ultrawork (if linked)
3. Mark autopilot as inactive (preserve state for resume)

## Original Task

$ARGUMENTS
