---
name: team
description: Coordinated multi-agent team with leader-worker protocol
---
# Team - Coordinated Multi-Agent Execution

## Purpose

Launch multiple specialist agents as a coordinated team with a leader-worker protocol.
Unlike `/ultrawork` (simple fan-out), Team provides:
- Shared task tracking
- Worker status monitoring
- Leader coordination
- Graceful shutdown

## Use When

- User says "team", "coordinate", "multi-agent"
- Tasks share context or have dependencies between workers
- Blockers between tasks need real-time coordination
- Need durable runtime control over parallel workers

## Do Not Use When

- Tasks are fully independent (use `/ultrawork`)
- Single-agent task (delegate directly)
- Need full lifecycle (use `/autopilot`)

## Team Launch

```
/team {count}:{role} "task description"
```

Examples:
```
/team 3:executor "implement auth, payments, and notifications modules"
/team 2:executor "frontend and backend for user dashboard"
/team ralph 3:executor "implement with Ralph verification after team"
```

## Execution Protocol

### 1. Planning Phase

Leader (you) breaks the task into worker assignments:

```json
{
  "team_name": "{slug}",
  "workers": [
    { "id": 1, "role": "executor", "task": "Implement auth module", "status": "pending" },
    { "id": 2, "role": "executor", "task": "Implement payments", "status": "pending" },
    { "id": 3, "role": "executor", "task": "Implement notifications", "status": "pending" }
  ]
}
```

### 2. Dispatch Phase

Launch all workers simultaneously using Agent tool:

```
Agent(
  name: "worker-1-auth",
  model: "sonnet",
  prompt: "Read agents/executor.md. Your task: Implement auth module. {context}",
  run_in_background: true
)
Agent(
  name: "worker-2-payments",
  model: "sonnet",
  prompt: "Read agents/executor.md. Your task: Implement payments. {context}",
  run_in_background: true
)
Agent(
  name: "worker-3-notif",
  model: "sonnet",
  prompt: "Read agents/executor.md. Your task: Implement notifications. {context}",
  run_in_background: true
)
```

### 3. Monitoring Phase

As workers complete:
- Update task status in state file
- Check for conflicts between worker outputs
- Resolve merge conflicts if any

### 4. Verification Phase

After all workers complete:
1. If any file appears in 2+ worker outputs, dispatch the integrator agent to resolve conflicts before verification:
   ```
   Agent(name: "integrator", model: "sonnet", prompt: "Read agents/integrator.md. {worker_outputs} {file_manifest} {task_context}")
   ```
   If no file overlaps exist across worker outputs, skip the integrator and proceed directly to verification.
2. Run full test suite
3. Run build
4. Check for integration issues between modules
5. Architect review of combined changes

### 5. Team + Ralph (Linked Launch)

When `/team ralph` is used:
- After team completion, automatically enter Ralph loop
- Ralph verifies the combined team output
- Linked state: team state records `linked_ralph: true`

## State Management

Write to `.harness/state/team-state.json`:

```json
{
  "active": true,
  "team_name": "{slug}",
  "started_at": "{ISO timestamp}",
  "linked_ralph": false,
  "workers": [
    {
      "id": 1,
      "role": "executor",
      "task": "Implement auth module",
      "status": "in_progress",
      "agent_id": "worker-1-auth"
    }
  ],
  "completed_workers": 0,
  "total_workers": 3
}
```

Worker status vocabulary: `pending` -> `in_progress` -> `completed` | `failed` | `blocked`

## Shutdown Protocol

### Graceful Shutdown
1. Wait for all in_progress workers to complete (timeout: 60s)
2. Collect results
3. Clean up state

### Force Shutdown
```
/cancel --force
```
Immediately terminates all workers.

## Constraints

- Max 6 concurrent workers (Claude Code subagent limit)
- Workers should be independent where possible
- Leader (you) coordinates -- workers don't communicate directly
- If a worker is blocked, leader reassigns or unblocks

## Original Task

$ARGUMENTS
