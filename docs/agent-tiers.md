# Agent Tier System

## Three Dimensions

### 1. Tiers (Depth / Cost)

| Tier | Model | When |
|------|-------|------|
| **LOW** | haiku | Fast lookups, narrow checks, style review, documentation |
| **STANDARD** | sonnet | Implementation, debugging, testing, verification |
| **THOROUGH** | opus | Architecture, security, complex multi-file analysis, planning |

### 2. Postures (Operating Style)

| Posture | Behavior | Roles |
|---------|----------|-------|
| **frontier-orchestrator** | Delegates, verifies, judges | planner, architect, critic |
| **deep-worker** | Implements, fixes, tests directly | executor, debugger, verifier |
| **fast-lane** | Quick triage, concise output | explorer, writer |

### 3. Roles (Agent Identity)

| Role | Default Tier | Posture | File | Auto-Trigger |
|------|-------------|---------|------|-------------|
| executor | STANDARD | deep-worker | agents/executor.md | - |
| architect | THOROUGH | frontier-orchestrator | agents/architect.md | - |
| planner | THOROUGH | frontier-orchestrator | agents/planner.md | - |
| verifier | STANDARD | deep-worker | agents/verifier.md | Ralph Step 3 (replaces inline) |
| debugger | STANDARD | deep-worker | agents/debugger.md | 2x same error in Ralph |
| critic | THOROUGH | frontier-orchestrator | agents/critic.md | Ralph 4-agent panel |
| security-reviewer | THOROUGH | frontier-orchestrator | agents/security-reviewer.md | After GREEN in Ralph, final panel |
| build-fixer | STANDARD | deep-worker | agents/build-fixer.md | Build failure in Ralph |
| test-engineer | STANDARD | deep-worker | agents/test-engineer.md | TDD phases |
| writer | LOW | fast-lane | agents/writer.md | Ralph Step 5.5 (post-completion) |
| explorer | LOW | fast-lane | agents/explorer.md | During deep-interview Q&A |
| integrator | STANDARD | deep-worker | agents/integrator.md | File overlaps + semantic conflicts |
| researcher | STANDARD | deep-worker | agents/researcher.md | Greenfield tasks in autopilot |

## Selection Rules

1. **Start at STANDARD** for most code changes
2. **Use LOW** only for bounded, read-only, non-invasive tasks
3. **Escalate to THOROUGH** when:
   - Security or authentication code is involved
   - Architectural decisions are being made
   - Changes span >10 files
   - Complex multi-system integration
4. **Ralph floor**: Completion verification always uses at least STANDARD architect
5. **Integrator floor**: Integration/merge verification always uses at least STANDARD

## Claude Code Agent Tool Mapping

```javascript
// LOW tier
Agent(name: "task", model: "haiku", prompt: "...")

// STANDARD tier
Agent(name: "task", model: "sonnet", prompt: "...")

// THOROUGH tier
Agent(name: "task", model: "opus", prompt: "...")
```

## Eco Mode (Optional Modifier)

When running with eco constraints, shift tiers down by one:
- THOROUGH -> STANDARD
- STANDARD -> LOW
- LOW -> LOW (floor)

This reduces cost while maintaining structure.

Exceptions to tier shift:
- Security reviews: always THOROUGH
- Ralph completion verification: always at least STANDARD architect
- Integrator merge resolution: always at least STANDARD
