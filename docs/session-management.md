# Session Management

## Session Lifecycle

Each Claude Code session within the harness has:

```
Session Start
  -> Load CLAUDE.md (orchestration brain)
  -> Check for active modes (/noyeah-status)
  -> If resumable mode found: offer /noyeah-resume
  -> If not: ready for new work

Session Active
  -> Skills manage state in .harness/state/
  -> Context snapshots in .harness/context/
  -> Plans in .harness/plans/
  -> Memory persists in .harness/memory/
  -> Notes in .harness/notepad/

Session End
  -> Active modes remain in state files
  -> Resume possible in next session via /noyeah-resume
  -> Memory and plans persist
```

## Session State Detection

On session start, check:

```bash
# Any active modes?
ls .harness/state/*.json 2>/dev/null

# Active context?
ls .harness/context/*.md 2>/dev/null | tail -1

# Active plans?
ls .harness/plans/*.md 2>/dev/null
```

## Cross-Session Persistence

| What | Where | Survives Session? |
|------|-------|------------------|
| Mode state | `.harness/state/*.json` | Yes (for resume) |
| Context snapshots | `.harness/context/*.md` | Yes |
| Plans | `.harness/plans/*.md` | Yes |
| Project memory | `.harness/memory/project-memory.json` | Yes |
| Notepad | `.harness/notepad/notes.md` | Yes |
| Logs | `.harness/logs/*.jsonl` | Yes |
| Codebase map | `.harness/codebase-map/map.md` | Yes (refresh on demand) |

## Stale State Cleanup

State files older than 24 hours with `active: true` are likely stale.
On detection:

```
WARNING: Found stale Ralph state from 2026-03-12 (26 hours ago).
This was likely interrupted. Options:
  /noyeah-resume ralph  -- Continue from where it left off
  /noyeah-cancel        -- Clean up and start fresh
```
