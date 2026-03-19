# Keyword Detection (Auto-Skill Activation)

> Extracted from CLAUDE.md for noyeah-harness

| Keywords | Skill | Description |
|----------|-------|-------------|
| ralph, don't stop, must complete, keep going, finish this | `/noyeah-ralph` | Persistence loop |
| autopilot, ship it, end to end, build from scratch | `/noyeah-autopilot` | Full pipeline |
| ultrawork, parallel, fan out, simultaneously | `/noyeah-ultrawork` | Parallel dispatch |
| ralplan, plan consensus, deliberate, plan carefully | `/noyeah-ralplan` | Consensus planning |
| eco, cheap, budget, save tokens | `/noyeah-ecomode` | Cost modifier |
| ultraqa, qa loop, fix all tests, make everything pass | `/noyeah-ultraqa` | QA cycling |
| team, coordinate, multi-agent | `/noyeah-team` | Team execution |
| interview, clarify, what do I need | `/noyeah-deep-interview` | Requirements gathering |
| visual check, does this look right, match this design | `/noyeah-visual-verdict` | Screenshot QA |
| retro, retrospective, what did we learn | `/noyeah-retro` | Post-completion learnings |
| init, initialize, setup harness, bootstrap | `/noyeah-init` | Project initialization |
| cancel, stop, abort | `/noyeah-cancel` | Clean termination |
| status, what's running, active modes | `/noyeah-status` | State dashboard |
| resume, continue, pick up | `/noyeah-resume` | Resume interrupted work |
| start, help, how do I, what should I use, where do I begin | (guided routing) | Guided skill selection for new users |

## Research Auto-Detection

Trigger research phase when ALL conditions are met:

1. **Creation verb present**: "만들어줘", "build", "create", "make", "develop", "구현", "개발"
2. **Domain noun present**: "app", "platform", "system", "tool", "service", "site", "dashboard", "앱", "플랫폼", "시스템"
3. **Greenfield context**: task does NOT reference an existing file path or module (i.e., building something new)

### Domain Mapping for Search Queries

| Keywords | Category | Example Searches |
|----------|----------|-----------------|
| collaboration, team, project, 협업, 팀 | PM/Collab | "team collaboration app features 2026" |
| e-commerce, shop, store, 쇼핑, 상점 | E-commerce | "e-commerce platform architecture" |
| social, feed, follow, 소셜, 피드 | Social | "social media app architecture patterns" |
| chat, messaging, real-time, 채팅, 메시징 | Communication | "real-time chat architecture" |
| analytics, dashboard, 분석, 대시보드 | Analytics | "analytics dashboard patterns" |
| CRM, customer, 고객관리 | CRM | "CRM system features comparison" |
| LMS, learning, course, 학습, 강의 | Education | "LMS platform architecture" |

### Override Flags

- Skip research: `/noyeah-autopilot --no-research "task"`
- Force research: `/noyeah-autopilot --research "task"`
- Research only: dispatch researcher agent directly

## Guided Routing Protocol

When triggered by the keywords above (e.g., "help", "where do I begin"), follow this protocol:

1. Ask the user what they want to accomplish in 1 sentence
2. Based on the response, suggest the most appropriate skill with a WHY explanation
3. Offer 1-2 alternatives: "If you want more control, try `/noyeah-ralplan` first"
4. Default to `/noyeah-autopilot` for genuinely ambiguous requests (safest full-lifecycle option)
5. For complete beginners, link to `docs/tutorial.md`
