---
name: noyeah-ralplan
description: Consensus planning via Planner -> Architect -> Critic
---
# RALPLAN - Consensus Planning with Deliberation

## Purpose

Structured planning that produces high-quality, adversarially-reviewed plans.
Three roles deliberate sequentially: Planner proposes, Architect challenges,
Critic validates. The result is an approved plan with Architecture Decision Records.

## Use When

- User says "ralplan", "plan consensus", "deliberate", "plan carefully"
- Complex feature requiring multi-file changes
- Architectural decisions that need explicit tradeoff analysis
- Before starting a `/noyeah-ralph` or `/noyeah-autopilot` run

## Do Not Use When

- Simple bug fix or typo (just fix it)
- User already has a clear plan
- Time-critical hotfix

## RALPLAN-DR Process (Sequential, Never Parallel)

### Round 1: Planner Proposes

Spawn a planner agent (THOROUGH tier):

```
Agent(
  name: "ralplan-planner",
  model: "opus",
  prompt: "Read agents/planner.md for your role. Create a plan for: {task}.
    Follow your Methodology Classification and Domain Modeling protocols:
    1. Classify task_type, tdd_mode, ddd_mode — output in ## Methodology section
    2. If ddd_mode: applied — model the domain and output in ## Domain Model section
    3. Align implementation steps to the domain model where applicable
    Output a structured plan with:
    - Problem statement
    - Methodology section (always required)
    - Domain Model section (when ddd_mode: applied)
    - 3-6 implementation steps with acceptance criteria
    - File list with estimated changes
    - Risk assessment
    - Testing strategy
    Save to .harness/plans/plan-{slug}.md"
)
```

### Round 2: Architect Challenges

Spawn an architect agent (THOROUGH tier):

```
Agent(
  name: "ralplan-architect",
  model: "opus",
  prompt: "Read agents/architect.md for your role. Review the plan at .harness/plans/plan-{slug}.md.
    You MUST provide:
    1. Antithesis: strongest argument AGAINST the proposed approach
    2. Steelman: best alternative approach the planner didn't consider
    3. Tradeoff tension: what does this plan sacrifice?
    4. Verdict: APPROVE / REVISE / REJECT with specific reasons
    Append your review to the plan file under '## Architect Review'"
)
```

### Round 3: Critic Validates

Spawn a critic agent (THOROUGH tier):

```
Agent(
  name: "ralplan-critic",
  model: "opus",
  prompt: "Read agents/critic.md for your role. Review the plan AND architect review at .harness/plans/plan-{slug}.md.
    Reject if:
    - Alternatives are shallow or strawman
    - Verification criteria are weak
    - Risks are hand-waved
    Output:
    - ADR (Architecture Decision Record) summary
    - Final verdict: APPROVED / NEEDS REVISION
    Append under '## Critic Verdict'"
)
```

### Resolution

- **All approve**: Plan is ready. Proceed to `/noyeah-ralph` or `/noyeah-autopilot`.
- **Revision needed**: Planner revises based on feedback. Re-run rounds 2-3.
- **Max 3 revision rounds.** If no consensus after 3 rounds, present options to user.

## Output Format

The final plan at `.harness/plans/plan-{slug}.md`:

```markdown
# Plan: {Feature Name}

## Problem Statement
{what and why}

## Methodology
- task_type: {feature|bugfix|refactor|config|docs}
- tdd_mode: {enforce|optional|skip}
- ddd_mode: {applied|skipped}
- reasoning: {one sentence}

## Domain Model (when ddd_mode: applied)

### Core Entities
- **{Entity}**: {responsibility}

### Value Objects
- **{VO}**: {what it represents}

### Module Boundaries
- **{Module}**: {what it owns}

### Business Rules
- {invariant in plain language}

## Implementation Steps
1. {step} — Acceptance: {criteria}
2. ...

## File Changes
- `path/to/file.ts` — {what changes}

## Risk Assessment
- {risk}: {mitigation}

## Testing Strategy
- {what to test and how}

## Architect Review
- Antithesis: ...
- Steelman: ...
- Tradeoffs: ...
- Verdict: APPROVE/REVISE/REJECT

## Critic Verdict
- ADR Summary: ...
- Verdict: APPROVED/NEEDS REVISION

## Status: APPROVED | REVISION {N}
```

## State Management

Write to `.harness/state/noyeah-ralplan-state.json`:

```json
{
  "active": true,
  "round": 1,
  "status": "planner_proposing",
  "plan_path": ".harness/plans/plan-{slug}.md",
  "revisions": 0,
  "started_at": "{ISO timestamp}"
}
```

## Original Task

$ARGUMENTS
