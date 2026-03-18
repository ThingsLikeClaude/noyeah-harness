# State Management

> Extracted from CLAUDE.md for noyeah-harness

All runtime state lives under `.harness/`:

```
.harness/
  state/                          # Mode lifecycle state
    ralph-state.json              # Ralph loop state
    autopilot-state.json          # Autopilot lifecycle
    ultrawork-state.json          # Parallel dispatch state
    ralplan-state.json            # Planning state
    ultraqa-state.json            # QA cycling state
    team-state.json               # Team coordination
    ecomode-state.json            # Eco modifier state
    visual-verdicts.json          # Visual QA scores
  context/                        # Pre-context snapshots
    {slug}-{timestamp}.md         # Task context documents
    interview-{slug}-{ts}.md      # Deep interview results
  plans/                          # Approved plans & specs
    plan-{slug}.md                # Implementation plans
    prd-{slug}.md                 # Product requirements
    spec-{slug}.md                # Test specifications
  memory/                         # Cross-session persistence
    project-memory.json           # Decisions, patterns, learnings
  notepad/                        # Session scratchpad
    notes.md                      # Freeform notes
  codebase-map/                   # Project structure
    map.md                        # Structural overview
  logs/                           # Execution history
    harness-YYYY-MM-DD.jsonl      # Timestamped log entries
  sessions/                       # Session tracking
```

## State Phase Vocabularies (Frozen Contracts)

| Mode | Phases |
|------|--------|
| Ralph | `starting` -> `executing` -> `verifying` -> `fixing` -> `complete` / `failed` / `cancelled` |
| Autopilot | `intake` -> `planning` -> `executing` -> `qa` -> `validation` -> `complete` / `cancelled` |
| UltraQA | `running_checks` -> `diagnosing` -> `fixing` -> `complete` / `failed` / `cancelled` |
| Ralplan | `planner_proposing` -> `architect_reviewing` -> `critic_validating` -> `approved` / `revision` |

See `docs/contracts/noyeah-ralph-state-contract.md` and `docs/contracts/noyeah-cancel-contract.md` for full specs.
