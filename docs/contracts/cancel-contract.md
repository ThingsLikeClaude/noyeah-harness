# Cancel Contract

Defines the cancellation protocol for all harness modes.

## Dependency Order

Cancellation follows this strict order:

```
1. Autopilot (cleans up linked ralph + ultraqa + ecomode)
2. Ralph (cleans up linked ultrawork or ecomode)
3. Team (cleans up linked ralph)
4. Ultrawork (standalone only)
5. UltraQA (standalone only)
6. Retro (standalone only -- stateless, safe to interrupt)
7. Ecomode (standalone only)
8. Ralplan (standalone only)
```

## Post-Conditions

For ANY mode cancellation:

1. State file exists and is terminalized (NOT deleted):
   - `active: false`
   - Appropriate terminal phase set
   - `completed_at` or `cancelled_at` timestamp set
2. Linked modes are also terminalized
3. Unrelated modes are untouched

## Linked Mode Cleanup

| Active Mode | Linked Mode | Cleanup |
|-------------|-------------|---------|
| Autopilot | Ralph | Cancel ralph first, then autopilot |
| Autopilot | UltraQA | Cancel ultraqa, then autopilot |
| Ralph | Ultrawork | Cancel ultrawork (if `linked_to_ralph=true`) |
| Ralph | Ecomode | Cancel ecomode |
| Team | Ralph | Cancel team first, then ralph |
| Ralph | Retro | If retro is running during Ralph cancel: interrupt retro (stateless, no cleanup needed -- writes to project-memory.json are atomic per-entry) |

## Force Mode

`/noyeah-cancel --force` deletes ALL state files without terminalization:
- `rm -f .harness/state/*.json`
- Reports: "All harness modes cleared. Fresh start."

## State Preservation

| Mode | State Preserved After Cancel? | Resume Possible? |
|------|-------------------------------|-----------------|
| Autopilot | Yes (phase, plan paths) | Yes (`/noyeah-resume autopilot`) |
| Ralph | No | No |
| Ultrawork | No | No |
| Team | No | No |
| UltraQA | No | No |
| Ecomode | No | No |
| Ralplan | Yes (plan file preserved) | Manual only |
