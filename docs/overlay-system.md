# Overlay System

## Concept

The overlay system provides runtime context composition for agents and skills.
Rather than dynamically injecting context into a shared prompt file, noyeah-harness
uses a read-on-demand approach: CLAUDE.md is static, and runtime state is read
from `.harness/` files when needed.

## Runtime Context Sources

When a skill or agent needs context, it reads from these sources:

### 1. Active Mode State

```bash
cat .harness/state/ralph-state.json  # Current phase, iteration, etc.
```

### 2. Codebase Map

```bash
cat .harness/codebase-map/map.md  # Project structure overview
```

Generated via `/codebase-map` or on first exploration.

### 3. Project Memory

```bash
cat .harness/memory/project-memory.json  # Cross-session learnings
```

### 4. Session Notepad

```bash
cat .harness/notepad/notes.md  # Current session notes
```

### 5. Context Snapshot

```bash
cat .harness/context/{active-snapshot}.md  # Task-specific context
```

## Why Read-On-Demand?

Claude Code's CLAUDE.md is read once at session start and doesn't support
runtime modification. noyeah-harness works with this constraint:

- Skills read state files directly when they need context
- Agents receive context through their prompt parameter
- The leader (you, Claude) composes context when dispatching agents

This approach avoids token waste from injecting everything into every agent.

## Context Composition for Agent Dispatch

When dispatching an agent, compose its context:

```
Agent(
  name: "worker-1",
  model: "sonnet",
  prompt: "
    Role: Read agents/executor.md
    Context: {paste relevant context from state files}
    Codebase: {key file paths from codebase map}
    Task: {specific task}
    Constraints: {from plan or context snapshot}
  "
)
```

This manual composition gives you control over exactly what each agent sees,
keeping prompts focused and token-efficient.

## Contract-Aware Dispatch

Core chained agents — planner, architect, critic, executor, and verifier — each have
embedded Input and Output Contracts defined in their agent files (`agents/*.md`). When
dispatching these agents, the prompt you compose must satisfy their Input Contract and you
must parse their Output Contract to pass results to the next agent in the chain.

Other agents (debugger, build-fixer, test-engineer, explorer, writer) use dispatch
templates from `docs/contracts/dispatch-templates.md` to ensure consistent handoff structure.

Always pass the `model` parameter explicitly when delegating (see Delegation Rules in
`CLAUDE.md`). Mismatched tiers are a common source of quality regressions — a LOW-tier
agent dispatched for an architectural task will underperform silently.

## Learning Injection

At dispatch time, before composing the final prompt, read relevant learnings from
`project-memory.json` and insert them as a `PAST LEARNINGS` block. Full selection
criteria, decay rules, and format are defined in `docs/learning-injection.md`. The
routing table that maps agent roles to learning categories is in `docs/project-memory.md`.

### Example: Dispatching an executor with injected learnings

Given `project-memory.json` contains:

```json
{
  "id": "mem-004",
  "type": "learning",
  "category": "implementation",
  "confidence": 0.8,
  "times_seen": 3,
  "content": "Mocking the database hides migration bugs",
  "applicable_when": "Testing database-related features with mocked connections",
  "recommendation": "Prefer real DB connections in integration tests over mocks",
  "tags": ["testing", "database", "mocking"]
}
```

Filter: `category == "implementation"` matches executor's routing categories
(`implementation`, `build`, `tooling`). `confidence 0.8 >= 0.6`, `times_seen 3 >= 1`.
Entry qualifies. Format and inject:

```
Agent(
  name: "worker-1",
  model: "sonnet",
  prompt: "
    Role: Read agents/executor.md
    Context: {paste relevant context from state files}
    Codebase: {key file paths from codebase map}

    ## PAST LEARNINGS (auto-injected, 1 relevant entry)

    These are lessons from previous runs. Apply them if relevant to your current task.

    1. [confidence: 0.8, seen: 3x] **Mocking DB hides migration bugs**
       When: Testing database-related features with mocked connections
       Do: Prefer real DB connections in integration tests over mocks

    Task: {specific task}
    Constraints: {from plan or context snapshot}
  "
)
```

If no learnings pass the filter (wrong category, low confidence, or none stored yet),
omit the `PAST LEARNINGS` block entirely — do not inject an empty section.
