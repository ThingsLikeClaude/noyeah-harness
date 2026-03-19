# noyeah-harness — Autonomous Execution Engine

> No? Yeah. 시키면 끝까지 한다.

## Core Concept

noyeah-harness turns Claude Code into an **operational runtime** for multi-step, verified work.
It adds persistence loops, tier-based agent routing, consensus planning, state management,
project memory, team coordination, and visual QA on top of Claude Code's native capabilities.

## Architecture

```
User
  -> noyeah-harness (this project)
    -> Claude Code (execution engine)
    -> CLAUDE.md (orchestration brain - this file)
    -> skills/ (14 workflow definitions)
    -> agents/ (13 role prompts for subagents)
    -> .harness/ (runtime state, plans, context, memory, logs)
    -> docs/ (contracts, workflows, system design)
```

## Composition Model

```
/noyeah-autopilot (full lifecycle: idea -> verified code)
  |
  ├── /noyeah-deep-interview (requirements gathering)
  │     └── explorer (haiku) -- parallel codebase search during Q&A
  │
  ├── researcher (sonnet) -- competitive intelligence [auto: greenfield tasks]
  │
  ├── /noyeah-ralplan (consensus planning)
  │     ├── planner (opus) ──┐
  │     ├── architect (opus) ─┘── parallel, then reconcile
  │     └── critic (opus) -- validates
  │
  ├── /noyeah-ralph (persistent execution loop, max 10 iterations)
  │     ├── /noyeah-ultrawork (parallel dispatch)
  │     │     ├── executor (sonnet) -- implements
  │     │     ├── debugger (sonnet) -- fixes [auto: 2x same error]
  │     │     ├── test-engineer (sonnet) -- tests
  │     │     ├── build-fixer (sonnet) -- repairs builds [auto: build fail]
  │     │     ├── explorer (haiku) -- searches
  │     │     ├── writer (haiku) -- documents [auto: post-completion]
  │     │     └── integrator (sonnet) -- merges + semantic conflict check
  │     │
  │     ├── security-reviewer (opus) -- security gate [auto: after GREEN]
  │     ├── /noyeah-visual-verdict (screenshot QA, when visual)
  │     ├── verifier (sonnet) -- proves completion [replaces inline verification]
  │     └── 4-agent validation panel:
  │           ├── architect (sonnet/opus) -- correctness
  │           ├── critic (opus) -- plan adherence + ADR
  │           ├── security-reviewer (opus) -- final security scan
  │           └── writer (haiku) -- doc update check (advisory)
  │
  ├── /noyeah-ultraqa (agent-based QA cycling, up to 5 rounds)
  │     ├── verifier (sonnet) -- check
  │     ├── debugger (sonnet) -- diagnose
  │     └── executor (sonnet) -- fix
  │
  └── Multi-perspective validation (4 parallel reviews)

/noyeah-team (coordinated multi-agent execution)
  ├── Leader (you) coordinates
  ├── Worker agents (background, up to 6)
  └── Optional: /noyeah-team ralph (linked lifecycle)

/noyeah-ecomode (cost modifier, shifts tiers down by one)
  └── Combines with: ralph, ultrawork, autopilot

/noyeah-cancel (clean termination of any active mode)
/noyeah-status (dashboard of active modes)
/noyeah-resume (continue interrupted work)
```

---

## Available Skills (14)

| Skill | Type | Description | Invocation |
|-------|------|-------------|------------|
| ralph | Loop | Persistence loop until architect-verified completion | `/noyeah-ralph "task"` |
| autopilot | Pipeline | Full lifecycle: interview -> plan -> execute -> verify | `/noyeah-autopilot "task"` |
| ultrawork | Dispatch | Parallel agent dispatch for independent tasks | `/noyeah-ultrawork "tasks"` |
| ralplan | Planning | Consensus: Planner -> Architect -> Critic -> ADR | `/noyeah-ralplan "goal"` |
| ecomode | Modifier | Shift tiers down by one for cost savings | `/noyeah-ecomode on` / `eco ralph` |
| ultraqa | Loop | QA cycling: run checks -> diagnose -> fix -> repeat (5x) | `/noyeah-ultraqa` |
| team | Coordination | Multi-agent team with leader-worker protocol | `/noyeah-team 3:executor "task"` |
| deep-interview | Discovery | Socratic requirements gathering (quick/full) | `/noyeah-deep-interview "task"` |
| visual-verdict | QA | Screenshot comparison with structured scoring | `/noyeah-visual-verdict` |
| retro | Analysis | Post-completion retrospective, extracts learnings | `/noyeah-retro` |
| init | Setup | Initialize target project with harness runtime and hooks | `/noyeah-init ~/my-project` |
| cancel | Cleanup | Cancel any active mode, clean up state | `/noyeah-cancel` / `/noyeah-cancel --force` |
| status | Info | Show active modes and current state | `/noyeah-status` |
| resume | Recovery | Continue interrupted work from saved state | `/noyeah-resume` |

---

## Available Agent Roles (13)

| Role | Tier | Posture | File | Purpose | Auto-Trigger |
|------|------|---------|------|---------|-------------|
| executor | STANDARD | deep-worker | agents/executor.md | Implementation with verification | - |
| architect | THOROUGH | frontier-orchestrator | agents/architect.md | Read-only strategic analysis | - |
| planner | THOROUGH | frontier-orchestrator | agents/planner.md | Planning and breakdown | - |
| verifier | STANDARD | deep-worker | agents/verifier.md | Completion evidence specialist | Ralph Step 3 |
| debugger | STANDARD | deep-worker | agents/debugger.md | Root-cause analysis (5-step protocol) | 2x same error |
| critic | THOROUGH | frontier-orchestrator | agents/critic.md | Adversarial review with ADR | Ralph 4-agent panel |
| security-reviewer | THOROUGH | frontier-orchestrator | agents/security-reviewer.md | OWASP Top 10, read-only | After GREEN + final panel |
| build-fixer | STANDARD | deep-worker | agents/build-fixer.md | Minimal-diff build repair | Build failure |
| test-engineer | STANDARD | deep-worker | agents/test-engineer.md | TDD enforcement, testing pyramid | TDD phases |
| writer | LOW | fast-lane | agents/writer.md | Technical documentation | Ralph Step 5.5 |
| explorer | LOW | fast-lane | agents/explorer.md | Fast codebase search | Deep-interview Q&A |
| integrator | STANDARD | deep-worker | agents/integrator.md | Merge + semantic conflict check | File/semantic overlaps |
| researcher | STANDARD | deep-worker | agents/researcher.md | Competitive intelligence via MCP | Greenfield tasks |

---

## Quick Rules

1. **Explore first, ask last** — Read codebase before asking questions
2. **Smallest viable diff** — Change only what's needed
3. **No scope reduction** — Implement everything requested
4. **Evidence required** — No completion without fresh verification output
5. **Tier discipline** — Always use appropriate tier for each agent (see `docs/agent-tiers.md`)
6. **State hygiene** — Update state files at every phase transition
7. **Memory writes** — Save decisions/learnings after significant work
8. **3-strike escalation** — Same issue 3+ times = escalate
9. **Cancel cleans up** — All state files terminalized (not deleted) on cancel
10. **Context composition** — Include relevant memory/map/state when dispatching agents

---

## Documentation Index

| Document | Purpose |
|----------|---------|
| `docs/agent-tiers.md` | Tier system: LOW/STANDARD/THOROUGH |
| `docs/architecture.md` | Overall architecture and composition model |
| `docs/quickstart.md` | 30-second setup guide |
| `docs/tutorial.md` | Step-by-step beginner guide |
| `docs/failure-recovery.md` | Troubleshooting for workflow failures |
| `docs/workflows.md` | Recommended skill chains for common tasks |
| `docs/session-management.md` | Session lifecycle and cross-session persistence |
| `docs/overlay-system.md` | Runtime context composition for agents |
| `docs/hook-system.md` | Event model and Claude Code hooks integration |
| `docs/project-memory.md` | Cross-session memory system |
| `docs/notepad.md` | Session scratchpad |
| `docs/codebase-map.md` | Project structure overview |
| `docs/contracts/noyeah-ralph-state-contract.md` | Ralph state schema (frozen) |
| `docs/contracts/noyeah-cancel-contract.md` | Cancellation protocol |
| `docs/contracts/core-contracts.md` | I/O contract schemas for 5 core chained agents |
| `docs/contracts/dispatch-templates.md` | Dispatch templates for 7 non-core agents |
| `docs/contracts/research-contract.md` | Research agent I/O schema |
| `docs/research-phase.md` | Research phase documentation |
| `docs/learning-injection.md` | Learning auto-injection protocol |

---

Detailed rules are in `rules/` directory (auto-loaded by Claude Code).
