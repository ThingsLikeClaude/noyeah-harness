# Notepad

## Concept

The notepad is a lightweight scratchpad for the current session. Use it to
track thoughts, observations, and quick notes during work. Unlike memory
(which is structured and permanent), the notepad is freeform and ephemeral.

## Storage

`.harness/notepad/notes.md`:

```markdown
# Session Notes

## 2026-03-13

- Auth module has a circular dependency with user module
- TODO: Ask user about rate limiting requirements
- The Redis client is initialized in 3 different places -- needs consolidation
- Test coverage is 45% -- needs to reach 80%
```

## Usage

During any harness mode, append notes:

```bash
echo "- Found circular dependency in auth" >> .harness/notepad/notes.md
```

Or read notes for context:

```bash
cat .harness/notepad/notes.md
```

## When to Use

- Quick observations during codebase exploration
- TODO items that don't fit in the plan
- Questions to ask the user later
- Debugging breadcrumbs
- Coordination notes between team workers

## Notepad vs Memory vs State

| | Notepad | Memory | State |
|---|---------|--------|-------|
| Structure | Freeform markdown | Typed JSON entries | Mode-specific JSON |
| Lifespan | Per session | Indefinite | Until mode completes |
| Purpose | Quick notes | Learnings/decisions | Mode tracking |
