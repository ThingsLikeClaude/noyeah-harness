# Hook System

## Concept

Hooks are event-driven triggers that fire on specific Claude Code lifecycle events.
noyeah-harness uses two complementary approaches for hooks, each serving a different purpose.

## Two Categories of Hooks

### Core Loop Logic (Prompt-Driven)

Ralph's persistence, completion checking, idle detection, and state transitions are
encoded directly in skill prompts. This logic is the heart of the harness runtime and
stays inside SKILL.md definitions. No external scripts are needed because:

- The logic requires full LLM reasoning (deciding whether to continue, what to fix next)
- Skill prompts have direct access to conversation context
- No script execution failures can interrupt the loop
- The logic is easier to maintain in one place (the skill definition)

Examples: Ralph iteration loop, autopilot lifecycle, UltraQA cycling.

### Observability Nudges (Script-Driven)

Lightweight reminder scripts that fire via Claude Code's native hook system. These are
optional behavioral nudges, not enforcement gates. They:

- Never block or crash (exit 0 on any error)
- Provide contextual reminders at the right moment (session start, post-write)
- Are deterministic (they fire every time the event occurs, unlike prompt instructions)
- Are distributed to target projects via `/noyeah-init`

Examples: retro-check (reminds to run /noyeah-retro after Ralph completion),
learning-remind (reminds about learning injection at session start).

## Why This Is Not a Contradiction

The original design philosophy favored prompt-driven logic over external scripts.
That principle still holds for **core loop logic** -- the LLM-driven decision-making
that constitutes the harness runtime. Observability nudges are a separate concern:
they do not make decisions, they surface information. A nudge script that says
"consider running /noyeah-retro" is categorically different from a script that tries to
implement Ralph's iteration logic. The former is a reminder; the latter would be
fighting Claude Code's architecture.

## Claude Code Hook Configuration

Configure in `.claude/settings.json` (project-level) or `.claude/settings.local.json` (user-level):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "node .harness/hooks/noyeah-retro-check.js"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "node .harness/hooks/learning-remind.js"
          }
        ]
      }
    ]
  }
}
```

**Schema**: Each event type key maps to an array of entries. Each entry has an
optional `matcher` (regex matched against tool name) and a required `hooks` array.
Each hook in the array has a `type` (`"command"`) and a `command` (shell command string).

## Harness Hook Scripts (Distributed via /noyeah-init)

### retro-check.js

- **Event**: PostToolUse (matcher: `Write|Edit`)
- **Trigger**: Fires on every Write/Edit tool use
- **Behavior**: Checks if `ralph-state.json` was just written with `current_phase === "complete"`. If so, checks if any learning entry in `project-memory.json` has a timestamp within the last 5 minutes. If no recent learning exists, outputs a reminder to run `/noyeah-retro`.
- **On error**: Exits 0 silently (graceful no-op)

### learning-remind.js

- **Event**: SessionStart (no matcher)
- **Trigger**: Fires once at the beginning of every session
- **Behavior**: Reads `project-memory.json`, counts entries where `type === "learning"`, outputs a reminder with the count if any exist.
- **On error**: Exits 0 silently (graceful no-op)

## Prompt-Driven Hooks (Built into Skills)

| Concern | Where It Lives | Why |
|---------|---------------|-----|
| Ralph iteration loop | `skills/noyeah-ralph/SKILL.md` | Requires LLM reasoning to decide next action |
| Completion checking | `skills/noyeah-ralph/SKILL.md` | Needs conversation context to verify |
| Idle continuation | `skills/noyeah-ralph/SKILL.md` | Prompt instructs Claude to continue |
| Autopilot lifecycle | `skills/noyeah-autopilot/SKILL.md` | Multi-phase pipeline with LLM decisions |
| State transitions | Skill prompts + state files | LLM reads/writes state as part of workflow |

## Event Model

| Event | Approach | Category |
|-------|----------|----------|
| session-start | learning-remind.js (hook script) | Observability nudge |
| post-write (ralph complete) | retro-check.js (hook script) | Observability nudge |
| turn-complete (ralph loop) | Skill prompt continuation logic | Core loop logic |
| session-idle (ralph) | Skill prompt continuation logic | Core loop logic |
| session-end | State files persist for `/noyeah-resume` | Persistence |
| pre-tool-use | Available for future enforcement hooks | Reserved |
| post-tool-use | Available for future enforcement hooks | Reserved |

## Distribution

Hook scripts (`retro-check.js`, `learning-remind.js`) and hook configuration
(`settings-template.json`) live in the noyeah-harness `hooks/` directory. They are
distributed to target projects via `/noyeah-init`, which:

1. Copies the scripts to `$TARGET/.harness/hooks/` (always overwrites on re-init)
2. Merges hook entries into `$TARGET/.claude/settings.json` (preserves user settings)

To update hooks in a target project after upgrading noyeah-harness, re-run `/noyeah-init`.
