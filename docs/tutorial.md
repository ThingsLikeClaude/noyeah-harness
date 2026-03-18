# noyeah-harness Tutorial: Your First Steps

> New to noyeah-harness? This guide walks you through everything step by step.
> No prior experience with multi-agent systems is required.

---

## 1. What is noyeah-harness?

Imagine a **factory floor** with specialized workers: one plans the work, another builds it,
a third inspects it, and a supervisor makes sure everything meets quality standards. If the
inspector finds a problem, the builder fixes it and the inspector checks again — automatically,
until the job is done right.

noyeah-harness does exactly this for software development inside Claude Code. It's an **operational
runtime** — a set of workflows and specialized agents (AI assistants with specific roles) that
work together to plan, build, test, and verify your code.

**Key terms you'll see throughout this guide:**

| Term | What it means |
|------|---------------|
| **Skill** | A workflow you can invoke with a slash command (e.g., `/ralph`). Think of it as a recipe that tells Claude what steps to follow. |
| **Agent** | A specialized AI assistant with a specific job (e.g., "executor" builds code, "architect" reviews it). Agents are dispatched automatically by skills. |
| **Tier** | The power level of an agent: LOW (quick lookups), STANDARD (normal work), THOROUGH (deep analysis). Higher tiers use more capable models. |
| **Phase** | A step in a workflow's lifecycle (e.g., "executing", "verifying", "complete"). |
| **Mode** | An active workflow (e.g., "Ralph is running" means the Ralph persistence loop is active). |
| **State** | Saved progress of a running workflow, stored as JSON files in `.harness/state/`. |
| **Plan** | A structured implementation proposal reviewed by multiple agents before coding begins. |

---

## 2. Before You Start

You need two things:

1. **Claude Code installed** — If you can run `claude` in your terminal, you're ready.
2. **A project folder** — Any folder with code you want to work on.

That's it. No databases, no servers, no configuration files to edit.

### Setting up noyeah-harness in your project

```
cd ~/noyeah-harness
claude
```

Then in the Claude session:

```
/init ~/my-project
```

This creates the `.harness/` directory in your project with everything noyeah-harness needs.

---

## 3. Your First Task with Ralph

Ralph is a **persistence loop** — it keeps working on your task until it's verified complete.
The name comes from the idea of never giving up: like pushing a boulder uphill until it reaches
the top.

### Try it

Open Claude Code in your project and type:

```
/ralph "add a README.md with project description, setup instructions, and usage examples"
```

### What happens

1. **Context snapshot** — Ralph saves a record of what you asked for
2. **Exploration** — It reads your project to understand the codebase
3. **Implementation** — An executor agent creates the README
4. **Verification** — A verifier agent checks that all requirements are met
5. **Architect review** — An architect agent reviews the quality
6. **Completion** — If approved, Ralph reports success with evidence

If the architect finds issues, Ralph automatically fixes them and re-verifies. This can repeat
up to 10 times (iterations), though most tasks complete in 1-3 iterations.

### When to use Ralph

- You have a clear task and want guaranteed completion
- The task might need multiple rounds of fixing
- You want an architect to verify the result

---

## 4. Planning Before Building

For larger tasks, it's wise to plan first. **Ralplan** (consensus planning) has three agents
deliberate on the approach before any code is written:

1. **Planner** — proposes an implementation plan with steps and acceptance criteria
2. **Architect** — challenges the plan: "What could go wrong? Is there a better way?"
3. **Critic** — validates the plan: "Are the alternatives real? Are the risks addressed?"

### Try it

```
/ralplan "add user authentication with email and password"
```

### What happens

The three agents discuss your task in sequence. If they disagree, the planner revises the plan
and the cycle repeats (up to 3 rounds). The result is a reviewed plan saved at
`.harness/plans/plan-{name}.md`.

Once approved, you can execute the plan with Ralph:

```
/ralph "execute the approved auth plan"
```

### When to use Ralplan

- The task involves 3 or more files
- You want multiple perspectives before coding
- Architectural decisions need explicit tradeoff analysis

---

## 5. Full Autopilot

For end-to-end delivery, **Autopilot** chains everything together:

```
/autopilot "build a REST API for user management with CRUD operations"
```

### What happens

Autopilot runs a complete pipeline automatically:

1. **Requirements gathering** — asks clarifying questions if needed
2. **Consensus planning** — runs Ralplan (planner + architect + critic)
3. **Execution** — runs Ralph (implementation + verification loop)
4. **QA cycling** — runs UltraQA (up to 5 rounds of test/fix)
5. **Multi-perspective validation** — 3 parallel reviews for final quality check
6. **Cleanup** — reports results and archives state

### When to use Autopilot

- You want to go from idea to verified code without manual intervention
- The task is large or complex (10+ files)
- You don't want to manage the workflow yourself

---

## 6. When Things Go Wrong

Sometimes workflows don't complete successfully. This is normal — it usually means the task
needs to be approached differently.

See **[Failure Recovery Guide](failure-recovery.md)** for specific troubleshooting steps
organized by failure type.

### Quick fixes for common situations

| Situation | What to do |
|-----------|------------|
| Everything is stuck | `/cancel` to stop, then start fresh |
| State files are corrupted | `/cancel --force` to clear all state |
| Session was interrupted | `/resume` to continue from where you left off |
| Want to see what's running | `/status` to view the dashboard |

---

## 7. Quick Reference Card

**"I want to..."** — use this skill:

| I want to... | Skill | Command |
|--------------|-------|---------|
| Fix a bug | Ralph | `/ralph "fix the login error"` |
| Build a feature | Ralplan + Ralph | `/ralplan "add search"` then `/ralph "execute plan"` |
| Do everything automatically | Autopilot | `/autopilot "build user profiles"` |
| Do multiple things at once | Ultrawork | `/ultrawork "1. Add types 2. Write tests 3. Update docs"` |
| Figure out requirements | Deep Interview | `/deep-interview "what does the auth system need?"` |
| Check visual design | Visual Verdict | `/visual-verdict` |
| Save tokens / reduce cost | Ecomode | `eco ralph "implement caching"` |
| Coordinate a team | Team | `/team 3:executor "build auth, payments, notifications"` |
| Review what we learned | Retro | `/retro` |
| Stop everything | Cancel | `/cancel` |
| See current status | Status | `/status` |
| Continue interrupted work | Resume | `/resume` |

---

## What's Next?

- **[Quickstart Guide](quickstart.md)** — Concise reference card for experienced users
- **[Failure Recovery Guide](failure-recovery.md)** — Troubleshooting for when things go wrong
- **[Recommended Workflows](workflows.md)** — Battle-tested skill chains for common tasks
- **[Architecture Overview](architecture.md)** — How the system is designed
