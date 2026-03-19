# Research Phase

## Overview

The research phase is an optional, auto-triggered step in the autopilot pipeline that gathers
competitive intelligence and architecture patterns before planning begins. It uses the
`researcher` agent with MCP tools (Exa web search, Jina Reader, Exa code context) to produce
a structured report that informs both the planner and architect.

## When Research Triggers

Research auto-detection fires when ALL conditions are met:

1. **Creation verb**: "만들어줘", "build", "create", "make", "develop", "구현"
2. **Domain noun**: "app", "platform", "system", "tool", "service", "site", "dashboard"
3. **Greenfield context**: task does NOT reference an existing file/path

See `rules/keyword-detection.md` for the full detection rules and domain mapping table.

## Context Flow

```
User request: "팀 협업앱 만들어줘"
  │
  ├─ Auto-detect: creation verb (만들어줘) + domain noun (앱) + no existing path
  │
  ├─ Dispatch researcher(sonnet)
  │    ├─ Exa web search: competitors (max 4 searches)
  │    ├─ Exa web search: architecture patterns (max 2 searches)
  │    ├─ Jina deep-read: top 3 competitor pages
  │    └─ Exa code context: implementation patterns (max 2 searches)
  │
  ├─ Output: .harness/context/research-team-collab-{ts}.md
  │
  ├─ Extract: research_summary (500 tokens from ## Summary)
  │
  └─ Inject into:
       ├─ planner prompt (informed plan)
       ├─ architect prompt (informed review)
       └─ autopilot-state.json (research_path, research_summary)
```

## Cost Budget

| Resource | Limit | Typical Usage |
|----------|-------|---------------|
| Exa web searches | 8 max | 4-6 |
| Jina deep reads | 3 max | 2-3 |
| Exa code context | 2 max | 1-2 |

Total estimated cost per research run: ~$0.10-0.30 depending on result volume.

## Override Flags

| Flag | Effect |
|------|--------|
| `--no-research` | Skip research even if auto-detection triggers |
| `--research` | Force research even if auto-detection doesn't trigger |
| Direct dispatch | `Agent(model: "sonnet", prompt: "Read agents/researcher.md...")` |

## Output Format

See `agents/researcher.md` for the full output template. Key sections:

- **Competitors**: table with name, URL, differentiator, relevance
- **Architecture Patterns**: patterns found with tradeoffs
- **Feature Matrix**: cross-comparison table
- **UX Patterns**: notable UX approaches
- **Technical Recommendations**: evidence-based suggestions
- **Summary**: 500-token synthesis for prompt injection

## Integration Points

| System | How Research Integrates |
|--------|----------------------|
| Autopilot | Phase 0.5 between intake and planning |
| Ralplan | Injected into planner + architect prompts |
| Ralph | Research report path available for executor on-demand |
| Deep Interview | Can trigger research if interview reveals greenfield context |

## Limitations

- Research quality depends on web search results — niche domains may yield sparse data
- Competitor analysis is based on publicly available information only
- Research adds ~30-60 seconds to the autopilot pipeline
- Cost limits may truncate research before all angles are covered
