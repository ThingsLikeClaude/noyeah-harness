# Recommended Workflows

Battle-tested skill chains for common tasks.

## Quick Reference

| Task | Workflow | When |
|------|----------|------|
| Bug fix | executor directly | Known bug, obvious fix |
| Complex bug | debugger -> executor | Root cause unknown |
| Small feature | ralplan -> ralph | 3-10 files |
| Large feature | autopilot | 10+ files, full lifecycle |
| Parallel tasks | ultrawork | Independent work units |
| Team project | team -> ralph | Shared context, blockers |
| Visual task | ralph + visual-verdict | UI matching design |
| Budget run | ecomode + ralph | Cost-conscious |

## Workflow Details

### 1. Simple Bug Fix

```
User: "Fix the 404 on /api/users"
-> Debugger agent (STANDARD) finds root cause
-> Executor agent (STANDARD) applies minimal fix
-> Verifier agent (STANDARD) confirms with fresh evidence
```

### 2. Planned Feature (Recommended Default)

```
/ralplan "add user profile editing"
  -> Planner (THOROUGH) creates plan
  -> Architect (THOROUGH) challenges
  -> Critic (THOROUGH) validates
  -> Plan approved

/ralph "execute the approved plan"
  -> Iteration 1: Executor implements (STANDARD)
  -> Iteration 2: Verifier checks (STANDARD)
  -> Iteration 3: Architect reviews (STANDARD/THOROUGH)
  -> Complete
```

**This is the strongest workflow for most features.**

### 3. Full Autopilot

```
/autopilot "build a REST API for user management"
  -> Deep interview (quick mode)
  -> Ralplan consensus planning
  -> Ralph execution loop
  -> UltraQA cycling (up to 5 rounds)
  -> Multi-perspective validation (3 parallel reviews)
  -> Cleanup and report
```

### 4. Parallel Fan-Out

```
/ultrawork "1. Add type exports 2. Write auth tests 3. Update API docs"
  -> Explorer (LOW) x1: type scan
  -> Executor (STANDARD) x1: auth tests
  -> Writer (LOW) x1: API docs
  All dispatched simultaneously
```

### 5. Team Coordination

```
/team 3:executor "implement auth, payments, and notifications"
  -> Worker 1 (STANDARD): auth module
  -> Worker 2 (STANDARD): payments module
  -> Worker 3 (STANDARD): notifications module
  -> Leader coordinates and resolves conflicts
  -> Integration verification
```

### 6. Team + Ralph (Strongest Combo)

```
/team ralph 3:executor "implement the approved plan"
  -> Team executes in parallel
  -> Ralph verifies the combined output
  -> Architect reviews the integration
  -> Loop until verified
```

### 7. Eco Budget Run

```
eco ralph "implement caching layer"
  -> All tiers shifted down by one
  -> THOROUGH -> STANDARD, STANDARD -> LOW
  -> Same workflow, lower cost
```

### 8. Visual Task

```
/ralph "match this design" -i reference.png
  -> Each iteration:
    1. Implement changes
    2. Take screenshot
    3. Visual verdict (score against reference)
    4. If score < 90: fix differences and repeat
    5. If score >= 90: architect review -> complete
```

### 9. Security Audit

```
Security Reviewer (THOROUGH) -> reads all code, produces report
  -> If CRITICAL findings: stop and fix immediately
  -> Executor (STANDARD) fixes HIGH/MEDIUM findings
  -> Security Reviewer (THOROUGH) re-reviews
```

## Anti-Patterns (Don't Do This)

| Anti-Pattern | Why It's Bad | Do This Instead |
|-------------|-------------|-----------------|
| Ralph for a typo fix | Overkill, wastes iterations | Fix directly |
| Ultrawork with dependent tasks | Race conditions, conflicts | Team mode or sequential |
| Autopilot without clear goal | Wanders, scope creep | Deep interview first |
| Skipping ralplan for large feature | No adversarial review | Always plan for 10+ files |
| Eco mode for security review | Security needs full depth | Always THOROUGH for security |
