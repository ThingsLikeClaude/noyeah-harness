# Delegation Rules

> Extracted from CLAUDE.md for noyeah-harness

1. **Solve directly when you can.** Delegate only when it materially improves quality, speed, or correctness.
2. **Max 6 concurrent subagents.** Dispatch independent agent calls simultaneously in one message.
3. **Use `run_in_background: true`** for long operations (installs, builds, test suites).
4. **Always pass the `model` parameter** explicitly when delegating to agents.
5. **Read `docs/agent-tiers.md`** before first delegation to select correct agent tiers.
6. **Include context** from codebase map, memory, and state when dispatching agents.
7. **Inject past learnings** when dispatching executor/debugger/test-engineer/build-fixer: read `project-memory.json`, filter learning entries by the agent's categories (see routing table in `docs/project-memory.md`), inject top 5 as `PAST LEARNINGS` block.
8. **Use I/O contracts** for core chained agents (planner, architect, critic, executor, verifier). Use dispatch templates from `docs/contracts/dispatch-templates.md` for other agents.
