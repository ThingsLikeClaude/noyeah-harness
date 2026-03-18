# Core Contracts

Core I/O Contract Schemas for the five chained agents in noyeah-harness. Orchestrators use this document for structured workflow dispatch and output parsing. For non-core agent dispatch templates, see `dispatch-templates.md`.

---

## Part 1: Universal I/O Contract Schema

Every agent interaction has two sides: what the caller must provide and what the agent guarantees to produce. The schemas below define these boundaries for the five core chained agents (planner, architect, critic, executor, verifier). Non-core agents use the dispatch templates in Part 2.

### 1.1 Input Contract Schema

An input contract describes what an agent requires to begin work. Fields marked REQUIRED must be present. Fields marked OPTIONAL improve quality but are not blocking.

```
INPUT CONTRACT
==============
Agent: {agent name}
Mode: {context in which the agent is being called, e.g. "ralplan review", "ralph iteration N"}

Required fields:
- task: {plain-language description of what the agent must do}
- {other required fields specific to this agent}

Optional context:
- plan_path: path to .harness/plans/plan-{slug}.md (if a plan was written)
- memory_path: path to .harness/memory/project-memory.json
- codebase_map_path: path to .harness/codebase-map/map.md
- prior_output: output from the preceding agent in the chain
- constraints: any caller-imposed limits (file scope, time, model tier)
```

### 1.2 Output Contract Schema

An output contract describes what an agent guarantees to produce. The orchestrator may parse these fields to determine next actions.

```
OUTPUT CONTRACT
===============
Agent: {agent name}

Outputs:
- {section name}: {what this section contains}
- verdict: {terminal state — one of the agent's defined verdict tokens}

Verdict tokens: {pipe-separated list of all valid verdicts}
Escalation trigger: {condition under which the agent signals "escalate upward"}
```

### 1.3 Core Agent I/O Contracts

The five core chained agents follow these contracts verbatim.

---

#### Planner

```
INPUT CONTRACT
==============
Agent: planner
Mode: initial planning | phase re-planning

Required fields:
- task: description of the feature or change to plan

Optional context:
- memory_path: .harness/memory/project-memory.json
- codebase_map_path: .harness/codebase-map/map.md
- constraints: known limitations (e.g. "only touch src/auth/", "no schema changes")
- interview_path: .harness/context/interview-{slug}-{ts}.md (if deep-interview was run)

OUTPUT CONTRACT
===============
Agent: planner

Outputs:
- problem_statement: description of what is being solved and why
- implementation_steps: 3–6 ordered steps, each with "What", "Files", "Acceptance"
- file_changes: table of file path, action (Create/Modify/Delete), and description
- risk_assessment: table of risk, likelihood, impact, mitigation
- testing_strategy: unit / integration / manual coverage descriptions
- plan_file: written to .harness/plans/plan-{slug}.md

Verdict tokens: (none — planner produces a plan, not a pass/fail verdict)
Escalation trigger: requirements are genuinely ambiguous after codebase exploration; planner
  will surface max 5 targeted questions before producing the plan
```

---

#### Architect

```
INPUT CONTRACT
==============
Agent: architect
Mode: plan review (ralplan) | implementation review (ralph completion)

Required fields:
- task: what to review ("review this plan" or "review this implementation")
- subject: the plan text, file paths, or git diff to review

Optional context:
- plan_path: .harness/plans/plan-{slug}.md
- mode_context: "ralplan" if in consensus planning, "ralph" if reviewing executor output
- prior_output: planner output (ralplan mode) or executor evidence (ralph mode)

OUTPUT CONTRACT
===============
Agent: architect

Outputs:
- correctness: PASS or ISSUE with file:line references
- security: PASS or ISSUE with file:line references
- performance: PASS or ISSUE with file:line references
- maintainability: PASS or ISSUE with file:line references
- completeness: PASS or ISSUE with file:line references
- ralplan_extras (ralplan mode only):
    antithesis: strongest argument against the proposed approach
    steelman: best alternative the planner did not consider
    tradeoff_tension: what the plan sacrifices
    decision_drivers: what factors should determine the choice
- verdict: APPROVED | REVISE | REJECTED
- reason: concise justification for the verdict

Verdict tokens: APPROVED | REVISE | REJECTED
Escalation trigger: SECURITY finding of any severity — surface to caller immediately
  regardless of overall verdict
```

---

#### Critic

```
INPUT CONTRACT
==============
Agent: critic
Mode: ralplan validation | implementation review

Required fields:
- task: what to critique ("validate this plan and architect review")
- plan_text: the plan produced by planner
- architect_review: the output from architect

Optional context:
- plan_path: .harness/plans/plan-{slug}.md
- mode_context: "ralplan" if in consensus planning, "implementation" if reviewing completed work
- prior_verdicts: any earlier REVISE cycles and their resolutions

OUTPUT CONTRACT
===============
Agent: critic

Outputs:
- adr: Architecture Decision Record with Status, Context, Decision,
        Alternatives Considered, and Consequences (positive/negative/risks)
- evaluation:
    alternatives_genuine: whether alternatives considered are real or strawman
    criteria_testable: whether acceptance criteria can be objectively measured
    risks_mitigated: whether risks are addressed, not merely listed
    architect_antithesis_real: whether architect provided genuine challenge
    plan_complete: whether all steps are present and ordered
- verdict: APPROVED | NEEDS_REVISION
- issues: list of specific, actionable issues (empty if APPROVED)

Verdict tokens: APPROVED | NEEDS_REVISION
Escalation trigger: plan requires structural rework after two revision cycles — critic
  will recommend escalating to user rather than looping again
```

---

#### Executor

```
INPUT CONTRACT
==============
Agent: executor
Mode: implementation | iteration N of ralph loop

Required fields:
- task: what to implement
- plan_path: path to .harness/plans/plan-{slug}.md (or inline plan text)

Optional context:
- memory_path: .harness/memory/project-memory.json
- codebase_map_path: .harness/codebase-map/map.md
- iteration: current ralph iteration number (if in loop)
- prior_failure: verifier or build-fixer output from previous iteration

OUTPUT CONTRACT
===============
Agent: executor

Outputs:
- files_changed: list of file paths modified, created, or deleted
- verification:
    tests: command run -> X passed, Y failed
    build: command run -> exit code
    lint: command run -> error count
- verdict: PASS | FAIL

Verdict tokens: PASS | FAIL
Escalation trigger: architectural decision required that is not covered by the plan —
  executor stops and surfaces the question rather than guessing
```

---

#### Verifier

```
INPUT CONTRACT
==============
Agent: verifier
Mode: ralph completion check | standalone verification

Required fields:
- task: what was supposed to be implemented
- plan_path: path to .harness/plans/plan-{slug}.md (or inline requirements list)

Optional context:
- executor_output: the VERIFICATION block from the executor's output
- iteration: which ralph iteration this verifies

OUTPUT CONTRACT
===============
Agent: verifier

Outputs:
- requirements_check: per-requirement verdict — PASS, FAIL, or INCOMPLETE — each with
    the command run and its output as evidence
- automated_checks:
    tests: command -> output summary -> PASS/FAIL
    build: command -> output summary -> PASS/FAIL
    types: command -> output summary -> PASS/FAIL
    lint: command -> output summary -> PASS/FAIL
- final_verdict: PASS | FAIL | INCOMPLETE
- details: list of what must be fixed (empty if PASS)

Verdict tokens: PASS | FAIL | INCOMPLETE
Escalation trigger: INCOMPLETE after executor has already attempted a fix —
  verifier surfaces the unresolved gap to the ralph orchestrator
```

---

## Part 3: Contract-Aware Dispatch Guide

### When to use embedded I/O contracts (5 core chained agents)

Use the I/O contracts from Part 1 when the agent is part of a structured workflow chain:

| Workflow | Agent chain |
|----------|-------------|
| `/noyeah-ralplan` | planner -> architect -> critic |
| `/noyeah-ralph` | executor -> verifier (-> debugger or build-fixer on failure) |
| `/noyeah-autopilot` | planner -> architect -> critic -> executor -> verifier |

In these chains the output of each agent becomes the `prior_output` input field of the next. The orchestrator reads the `verdict` field to decide whether to proceed, loop, or escalate. Parse verdict tokens exactly as defined — do not infer intent from prose.

The I/O contracts are not prompts. They are parsing schemas. The agent's system prompt comes from its agent file; the contract tells the orchestrator which fields to extract from the response.

### When to use dispatch templates (6 non-core agents)

Use the dispatch templates from Part 2 when dispatching to debugger, build-fixer, test-engineer, security-reviewer, writer, or explorer. These agents are invoked situationally rather than in a fixed chain:

| Trigger | Agent to dispatch |
|---------|------------------|
| Build fails after executor run | build-fixer |
| Test suite fails and root cause is unclear | debugger |
| New feature needs test coverage | test-engineer |
| Bug fix needs regression test | test-engineer |
| Pre-commit or pre-merge security gate | security-reviewer |
| New public API or module needs docs | writer |
| Orchestrator needs to locate a function or pattern | explorer |

Dispatch templates are complete prompts. Copy the example, substitute the bracketed fields, and pass it as the `prompt` parameter to `Agent()`.

### How to compose context for agent dispatch

Follow this order when building context for any agent call:

1. **Task description** — what the agent must do, in plain language. Always first.

2. **Plan or requirements** — if a plan exists at `.harness/plans/plan-{slug}.md`, include its path or paste the relevant steps.

3. **Memory** — if the project has a memory file at `.harness/memory/project-memory.json`, note any decisions or constraints relevant to the task.

4. **Codebase map** — if the agent needs orientation, include the relevant section from `.harness/codebase-map/map.md`. Do not paste the entire map; extract the modules the agent will touch.

5. **Prior agent output** — if this dispatch follows another agent, paste that agent's output block (BUG REPORT, VERIFICATION REPORT, etc.) so the receiving agent has the full evidence chain.

6. **Constraints** — any caller-imposed limits: file scope restrictions, model tier, iteration number, time budget.

Omit fields that are empty or irrelevant. A focused prompt with three fields outperforms a padded prompt with eight.

#### Context composition example

```
Agent(
  model="claude-sonnet-4-5",
  prompt="""
You are the executor agent. Read agents/executor.md for your full protocol.

Task: Implement step 2 of the plan — add email uniqueness validation to the
  user registration endpoint.

Plan: .harness/plans/plan-user-registration.md (step 2 only)

Memory note: The project uses Zod for all input validation (recorded decision,
  2026-03-10). Do not introduce a second validation library.

Codebase map (relevant section):
  src/api/users.ts   — registration endpoint
  src/services/user-service.ts — DB queries
  src/schemas/user.ts — Zod schemas (add uniqueness rule here)

This is ralph iteration 1. No prior failure to report.

After implementing, run the full test suite and build. Output your VERIFICATION
block and your VERDICT (PASS or FAIL).
"""
)
```

See also: [`dispatch-templates.md`](dispatch-templates.md) for copy-paste dispatch templates for non-core agents.
