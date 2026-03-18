# noyeah-harness

> No? Yeah. 시키면 끝까지 한다.
> Autonomous execution engine for Claude Code.

## What is this?

noyeah-harness turns Claude Code into an autonomous execution engine.
Unlike tool collections that give you a toolbox, noyeah-harness gives you a **crew** that works until the job is done.
Persistence loops, consensus planning, tier-based agent routing, and file-based state management -- all built in.
시킨 일을 끝낼 때까지 알아서 계획하고, 구현하고, 검증하고, 고친다.

## Quick Install

### macOS / Linux

```bash
git clone https://github.com/ThingsLikeClaude/noyeah-harness.git ~/noyeah-harness
cd ~/noyeah-harness && ./install.sh
```

### Windows

```powershell
git clone https://github.com/ThingsLikeClaude/noyeah-harness.git $env:USERPROFILE\noyeah-harness
cd $env:USERPROFILE\noyeah-harness; .\install.ps1
```

Then restart Claude Code. 설치 후 Claude Code를 재시작하면 바로 사용 가능.

## Core Skills

14개의 워크플로우 스킬. 슬래시 커맨드로 호출한다.

| Skill | Command | Description |
|-------|---------|-------------|
| Ralph | `/ralph` | Persistence loop -- 끝날 때까지 반복 (최대 10회) |
| Autopilot | `/autopilot` | Full lifecycle: 인터뷰 -> 계획 -> 구현 -> 검증 |
| Ultrawork | `/ultrawork` | Parallel dispatch -- 독립 작업 동시 실행 |
| Ralplan | `/ralplan` | Consensus planning: Planner -> Architect -> Critic |
| Ecomode | `/ecomode` | Cost modifier -- 에이전트 티어를 한 단계 낮춤 |
| UltraQA | `/ultraqa` | QA cycling loop (최대 5라운드) |
| Team | `/team` | Multi-agent team coordination |
| Deep Interview | `/deep-interview` | Socratic requirements gathering |
| Visual Verdict | `/visual-verdict` | Screenshot QA -- 디자인 매칭 검증 |
| Retro | `/retro` | Post-completion retrospective |
| Init | `/init` | Target project 초기화 |
| Cancel | `/cancel` | 실행 중인 모드 종료 |
| Status | `/status` | 현재 상태 대시보드 |
| Resume | `/resume` | 중단된 작업 재개 |

## Agents (12)

역할별 전문 에이전트. 스킬이 자동으로 디스패치한다.

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| executor | STANDARD | sonnet | Implementation with verification |
| architect | THOROUGH | opus | Read-only strategic analysis |
| planner | THOROUGH | opus | Planning and breakdown |
| verifier | STANDARD | sonnet | Completion evidence specialist |
| debugger | STANDARD | sonnet | Root-cause analysis (5-step protocol) |
| critic | THOROUGH | opus | Adversarial review with ADR |
| security-reviewer | THOROUGH | opus | OWASP Top 10, read-only |
| build-fixer | STANDARD | sonnet | Minimal-diff build repair |
| test-engineer | STANDARD | sonnet | TDD enforcement, testing pyramid |
| writer | LOW | haiku | Technical documentation |
| explorer | LOW | haiku | Fast codebase search |
| integrator | STANDARD | sonnet | Merge specialist for parallel output |

## How It Works

`/autopilot`이 전체 파이프라인을 오케스트레이션한다:

```
/autopilot (full lifecycle: idea -> verified code)
  |
  ├── /ralplan (consensus planning)
  │     ├── planner (opus) -- proposes
  │     ├── architect (opus) -- challenges
  │     └── critic (opus) -- validates
  │
  ├── /ralph (persistent execution loop, max 10 iterations)
  │     ├── /ultrawork (parallel dispatch)
  │     │     ├── executor (sonnet) -- implements
  │     │     ├── debugger (sonnet) -- fixes
  │     │     ├── explorer (haiku) -- searches
  │     │     └── integrator (sonnet) -- merges
  │     │
  │     └── verifier (sonnet) -- proves completion
  │           └── architect (sonnet/opus) -- final review
  │
  └── /ultraqa (QA cycling, up to 5 rounds)
        └── Multi-perspective validation (3 parallel reviews)
```

각 스킬은 독립 실행도 가능하다. `/ralph`만 돌려도 되고, `/ralplan` + `/ralph` 조합도 된다.

## vs Claude Forge

| | noyeah-harness | Claude Forge |
|---|---|---|
| Positioning | Autonomous execution engine | Developer productivity toolkit |
| Core Feature | Persistence loops + consensus planning | Workflow skills + verification |
| Selling Point | 시키면 끝까지 한다 (crew, not toolbox) | 개발 워크플로우 체계화 |
| State Management | File-based `.harness/` with frozen contracts | Session-scoped |

## Update

```bash
cd ~/noyeah-harness && git pull
```

Windows의 경우 `install.ps1`을 다시 실행한다:

```powershell
cd $env:USERPROFILE\noyeah-harness; .\install.ps1
```

## Uninstall

```bash
cd ~/noyeah-harness && ./uninstall.sh
```

## License

MIT
