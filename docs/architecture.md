# noyeah-harness Architecture

## Composition Model

```
/noyeah-autopilot (full lifecycle)
  |
  ├── researcher (sonnet) -- competitive intelligence [auto: greenfield tasks]
  │
  ├── /noyeah-ralplan (consensus planning)
  │     ├── planner (opus) ──┐
  │     ├── architect (opus) ─┘── parallel, then reconcile
  │     └── critic (opus) -- validates
  │
  ├── /noyeah-ralph (persistent execution loop)
  │     ├── /noyeah-ultrawork (parallel dispatch)
  │     │     ├── executor (sonnet) -- implements
  │     │     ├── debugger (sonnet) -- fixes [auto: 2x same error]
  │     │     ├── build-fixer (sonnet) -- repairs builds [auto: build fail]
  │     │     ├── test-engineer (sonnet) -- tests
  │     │     ├── explorer (haiku) -- searches
  │     │     ├── writer (haiku) -- documents [auto: post-completion]
  │     │     └── integrator (sonnet) -- merges + semantic conflict check
  │     │
  │     ├── security-reviewer (opus) -- security gate [auto: after GREEN]
  │     ├── verifier (sonnet) -- proves completion [replaces inline verification]
  │     └── 4-agent validation panel:
  │           ├── architect (sonnet/opus) -- correctness
  │           ├── critic (opus) -- plan adherence + ADR
  │           ├── security-reviewer (opus) -- final security scan
  │           └── writer (haiku) -- doc update check (advisory)
  │
  ├── Agent-based QA cycling (up to 5 rounds)
  │     ├── verifier (sonnet) -- check
  │     ├── debugger (sonnet) -- diagnose failures
  │     └── executor (sonnet) -- fix
  │
  └── Multi-perspective validation (4 parallel reviews)
        ├── correctness (opus)
        ├── security (opus)
        ├── maintainability (sonnet)
        └── critic (opus) -- plan adherence
```

## Skill Relationships

| Skill | Contains | Wrapped By |
|-------|----------|------------|
| ultrawork | - | ralph |
| ralph | ultrawork | autopilot |
| ralplan | - | autopilot |
| autopilot | ralplan + ralph | - |
| cancel | - | - |

## State Flow

```
.harness/
  state/
    autopilot-state.json  ←── autopilot reads/writes
    ralph-state.json      ←── ralph reads/writes
    ultrawork-state.json  ←── ultrawork reads/writes
    ralplan-state.json    ←── ralplan reads/writes
  context/
    {slug}-{ts}.md        ←── pre-context snapshots
  plans/
    plan-{slug}.md        ←── ralplan output
  logs/
    harness-{date}.jsonl  ←── execution logs
```

## Phase Transitions

### Ralph Phases
```
starting ──→ executing ──→ verifying ──→ complete
                ↑              │
                └── fixing ←───┘
                              │
                              ├──→ failed (3x same error)
                              └──→ cancelled (user request)
```

### Autopilot Phases
```
intake → research (optional) → planning → executing → qa → validation → complete
                                 │                    │
                                 └── (loop max 5x)    └── cancelled
```

## Design Decisions

Key architectural choices in noyeah-harness:

- **File-based state**: JSON files under `.harness/state/` for simplicity and portability — no external MCP servers or databases required
- **Subagent delegation**: Claude Code's native Agent tool with explicit `model` parameter for tier-based routing (haiku/sonnet/opus)
- **Prompt-driven orchestration**: CLAUDE.md as the central brain, with `agents/*.md` role definitions injected via prompt composition
- **Skill composition**: `skills/*/SKILL.md` files loaded on demand, composable into pipelines (ultrawork -> ralph -> autopilot)
