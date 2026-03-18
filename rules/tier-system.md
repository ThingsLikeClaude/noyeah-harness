# Agent Tier System

> Extracted from CLAUDE.md for noyeah-harness

All agent delegation MUST use explicit tier routing:

| Tier | Model | Effort | Use For |
|------|-------|--------|---------|
| LOW | haiku | low | Search, lookup, style review, writing, documentation |
| STANDARD | sonnet | medium | Implementation, debugging, testing, verification, build fixing |
| THOROUGH | opus | high | Architecture, security, complex analysis, planning, criticism |

## Tier Selection Rules

1. Start at STANDARD for most code changes
2. Use LOW only for bounded, read-only, non-invasive tasks
3. Escalate to THOROUGH for: security/auth, architectural decisions, >10 file changes
4. Ralph completion verification requires at least STANDARD architect review
5. Ecomode shifts all tiers down by one (THOROUGH->STANDARD, STANDARD->LOW)
6. Security reviews ALWAYS use THOROUGH regardless of ecomode
7. Integrator merge resolution ALWAYS uses at least STANDARD regardless of ecomode

## Postures (Operating Style)

| Posture | Roles | Behavior |
|---------|-------|----------|
| frontier-orchestrator | planner, architect, critic, security-reviewer | Delegates, verifies, judges. Never implements. |
| deep-worker | executor, debugger, test-engineer, verifier, build-fixer, integrator | Implements, fixes, tests directly. Shows evidence. |
| fast-lane | explorer, writer | Quick triage, concise output. Escalates complexity. |
