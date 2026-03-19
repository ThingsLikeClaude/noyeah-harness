---
name: noyeah-ultrawork
description: Parallel agent dispatch for independent tasks
---
# Ultrawork - Parallel Execution Engine

## Purpose

Dispatch multiple specialist agents simultaneously for independent tasks.
This is the composable execution primitive -- Ralph wraps it with persistence,
Autopilot wraps Ralph with lifecycle management.

**Ultrawork is parallelism. Ralph is orchestration.**

## Use When

- Multiple independent tasks can run simultaneously
- User says "ultrawork", "parallel", "fan out"
- Tasks don't depend on each other's results

## Do Not Use When

- Tasks have sequential dependencies (run them in order)
- User needs guaranteed completion (use `/noyeah-ralph`)
- Full lifecycle needed (use `/noyeah-autopilot`)

## Execution Rules

### 1. Break Down Tasks

Analyze the request and identify independent work units.

### 2. Assign Tiers

For each task, determine the appropriate tier:

| Task Type | Tier | Model |
|-----------|------|-------|
| File search, type export, simple rename | LOW | haiku |
| Implementation, bug fix, test writing | STANDARD | sonnet |
| Architecture review, security analysis | THOROUGH | opus |

### 3. Dispatch Simultaneously

Use Claude Code's Agent tool to launch all independent tasks in a **single message**:

```
// GOOD: All in one message block
Agent(name: "task-1", model: "haiku", prompt: "Add type export for UserConfig")
Agent(name: "task-2", model: "sonnet", prompt: "Implement caching layer")
Agent(name: "task-3", model: "sonnet", prompt: "Write integration tests for auth")
```

```
// BAD: Sequential when unnecessary
Agent(task-1) -> wait -> Agent(task-2) -> wait -> Agent(task-3)
```

### 4. Collect & Merge Results

After all agents complete:
1. Review each result for conflicts
2. If file overlaps are detected between agent outputs, dispatch the integrator agent to resolve conflicts before verification:
   ```
   Agent(name: "integrator", model: "sonnet", prompt: "Read agents/integrator.md. {agent_outputs} {file_manifest} {task_context}")
   ```
   If no file appears in 2+ agent outputs, skip the integrator and proceed directly to verification.
3. **Semantic conflict detection** (even without file overlaps):
   The integrator also checks for:
   - **Shared state assumptions**: Do agents assume compatible data shapes for shared state (DB, cache, store)?
   - **API boundary alignment**: Do function signatures, types, and return values match at module boundaries?
   - **Naming/typing conflicts**: Are there conflicting names for the same concept across modules?

   ```
   TRIVIAL conflicts (naming, import order) → integrator auto-resolves
   COMPLEX conflicts (incompatible assumptions, API mismatch) → escalate to architect
   ```

   Dispatch integrator for semantic checks when agents touched related modules, even if no file overlap exists:
   ```
   Agent(
     name: "integrator-semantic",
     model: "sonnet",
     prompt: "Read agents/integrator.md. Check for semantic conflicts across these agent outputs.
       Focus on: shared state compatibility, API boundary alignment, naming consistency.
       {agent_outputs} {module_boundaries}"
   )
   ```
4. Run verification (test, build, lint)

## State Management

Write to `.harness/state/noyeah-ultrawork-state.json`:

```json
{
  "active": true,
  "tasks": [
    { "id": 1, "description": "...", "tier": "LOW", "status": "in_progress" },
    { "id": 2, "description": "...", "tier": "STANDARD", "status": "in_progress" }
  ],
  "started_at": "{ISO timestamp}",
  "linked_to_ralph": false
}
```

## Original Task

$ARGUMENTS
