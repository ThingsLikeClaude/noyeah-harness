# Keyword Detection (Auto-Skill Activation)

> Extracted from CLAUDE.md for noyeah-harness

| Keywords | Skill | Description |
|----------|-------|-------------|
| ralph, don't stop, must complete, keep going, finish this | `/ralph` | Persistence loop |
| autopilot, ship it, end to end, build from scratch | `/autopilot` | Full pipeline |
| ultrawork, parallel, fan out, simultaneously | `/ultrawork` | Parallel dispatch |
| ralplan, plan consensus, deliberate, plan carefully | `/ralplan` | Consensus planning |
| eco, cheap, budget, save tokens | `/ecomode` | Cost modifier |
| ultraqa, qa loop, fix all tests, make everything pass | `/ultraqa` | QA cycling |
| team, coordinate, multi-agent | `/team` | Team execution |
| interview, clarify, what do I need | `/deep-interview` | Requirements gathering |
| visual check, does this look right, match this design | `/visual-verdict` | Screenshot QA |
| retro, retrospective, what did we learn | `/retro` | Post-completion learnings |
| init, initialize, setup harness, bootstrap | `/init` | Project initialization |
| cancel, stop, abort | `/cancel` | Clean termination |
| status, what's running, active modes | `/status` | State dashboard |
| resume, continue, pick up | `/resume` | Resume interrupted work |
| start, help, how do I, what should I use, where do I begin | (guided routing) | Guided skill selection for new users |

## Guided Routing Protocol

When triggered by the keywords above (e.g., "help", "where do I begin"), follow this protocol:

1. Ask the user what they want to accomplish in 1 sentence
2. Based on the response, suggest the most appropriate skill with a WHY explanation
3. Offer 1-2 alternatives: "If you want more control, try `/ralplan` first"
4. Default to `/autopilot` for genuinely ambiguous requests (safest full-lifecycle option)
5. For complete beginners, link to `docs/tutorial.md`
