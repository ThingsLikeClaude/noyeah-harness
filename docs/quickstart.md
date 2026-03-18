# noyeah-harness Quickstart

> **New to noyeah-harness?** Start with the [Tutorial](tutorial.md) for a step-by-step walkthrough.
> This page is a quick reference for experienced users.

## Setup (30 seconds)

```bash
cd ~/noyeah-harness
claude
```

That's it. Claude Code reads `CLAUDE.md` and loads the harness automatically.

## Initialize a Target Project

To use noyeah-harness in your own project:

```
/noyeah-init ~/my-project
```

This will:
1. Create `.harness/` directory structure in your project
2. Copy hook scripts (retro-check, learning-remind) to `.harness/hooks/`
3. Merge hook configuration into `.claude/settings.json` (preserves existing settings)
4. Add a noyeah-harness reference block to your project's `CLAUDE.md`

Re-running `/noyeah-init` on an already initialized project safely updates hooks and settings without touching your data.

## Basic Usage

### Ralph - "Don't stop until it's done"

```
/noyeah-ralph "implement OAuth callback with full error handling and tests"
```

Ralph will:
1. Create a context snapshot
2. Explore the codebase
3. Implement in parallel where possible
4. Run verification (tests, build, lint)
5. Get architect review
6. Loop until approved or max 10 iterations

### Autopilot - "Ship it end to end"

```
/noyeah-autopilot "build a REST API for user management with CRUD operations"
```

Autopilot will:
1. Run consensus planning (RALPLAN)
2. Execute via Ralph
3. QA cycle (up to 5 rounds)
4. Multi-perspective validation
5. Clean up and report

### Ultrawork - "Do these in parallel"

```
/noyeah-ultrawork "1. Add type exports for all models 2. Write tests for auth module 3. Update API docs"
```

Dispatches all independent tasks simultaneously.

### Ralplan - "Plan carefully before coding"

```
/noyeah-ralplan "redesign the caching layer to support Redis and in-memory"
```

Sequential deliberation: Planner -> Architect -> Critic.

### Cancel - "Stop everything"

```
/noyeah-cancel
/noyeah-cancel --force  # clear all state
```

## Tier Quick Reference

| I need... | Tier | Model | Example |
|-----------|------|-------|---------|
| Quick lookup | LOW | haiku | "What does this function return?" |
| Implementation | STANDARD | sonnet | "Add error handling to auth module" |
| Architecture review | THOROUGH | opus | "Review the database schema design" |

## How It Works Under the Hood

| Component | Implementation | Why |
|-----------|---------------|-----|
| Agent dispatch | Claude Code `Agent` tool | Native subagent support with model routing |
| State backend | File-based (`.harness/`) | Portable, no external dependencies |
| Model routing | Agent tool `model` param | Explicit tier control (haiku/sonnet/opus) |
| Team mode | Agent tool with `run_in_background` | Up to 6 concurrent workers |
| Skills | `skills/*/SKILL.md` | Composable, loaded on demand |
