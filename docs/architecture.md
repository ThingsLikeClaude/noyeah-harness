# noyeah-harness Architecture

## Composition Model

```
/autopilot (full lifecycle)
  |
  ├── /ralplan (consensus planning)
  │     ├── planner (opus) -- proposes
  │     ├── architect (opus) -- challenges
  │     └── critic (opus) -- validates
  │
  ├── /ralph (persistent execution loop)
  │     ├── /ultrawork (parallel dispatch)
  │     │     ├── executor (sonnet) -- implements
  │     │     ├── debugger (sonnet) -- fixes
  │     │     ├── explorer (haiku) -- searches
  │     │     └── integrator (sonnet) -- merges parallel outputs
  │     │
  │     └── verifier (sonnet) -- proves completion
  │           └── architect (sonnet/opus) -- final review
  │
  └── QA cycling (up to 5 rounds)
        └── Multi-perspective validation (3 parallel reviews)
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
intake → planning → executing → qa → validation → complete
                                 │                    │
                                 └── (loop max 5x)    └── cancelled
```

## Design Decisions

Key architectural choices in noyeah-harness:

- **File-based state**: JSON files under `.harness/state/` for simplicity and portability — no external MCP servers or databases required
- **Subagent delegation**: Claude Code's native Agent tool with explicit `model` parameter for tier-based routing (haiku/sonnet/opus)
- **Prompt-driven orchestration**: CLAUDE.md as the central brain, with `agents/*.md` role definitions injected via prompt composition
- **Skill composition**: `skills/*/SKILL.md` files loaded on demand, composable into pipelines (ultrawork -> ralph -> autopilot)
