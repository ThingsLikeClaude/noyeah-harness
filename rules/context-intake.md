# Pre-Context Intake Gate

> Extracted from CLAUDE.md for noyeah-harness

Before any major workflow (ralph, autopilot, team), create a context snapshot:

```markdown
# Context: {task description}
- **Task**: {what needs to be done}
- **Desired Outcome**: {what success looks like}
- **Known Facts**: {what we know from codebase exploration}
- **Constraints**: {limitations, requirements}
- **Unknowns**: {open questions}
- **Touchpoints**: {files/modules likely affected}
```

Save to `.harness/context/{slug}-{timestamp}.md`

If ambiguity is high: run `/deep-interview --quick` first.
