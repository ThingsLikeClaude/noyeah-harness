---
name: noyeah-init
description: Initialize a target project with noyeah-harness runtime and hooks
---
# init - Initialize a Project with noyeah-harness

## Purpose

Bootstrap a target project with the noyeah-harness runtime: create the `.harness/` directory
structure, install hook scripts, merge Claude Code hook settings, and add the harness
reference block to `CLAUDE.md`.

Run this once when adopting noyeah-harness in a new project, or again to update hook scripts
and settings after upgrading noyeah-harness.

## Use When

- Setting up noyeah-harness in a new project for the first time
- Updating hook scripts after upgrading noyeah-harness
- Re-applying harness settings to a project after a fresh clone
- User says "init", "initialize", "setup harness", or "bootstrap"

## Do Not Use When

- The current working directory IS the noyeah-harness repo itself (self-init is blocked)
- The target directory does not exist
- You want to run the harness in a project that is already initialized (idempotent re-run is safe, but confirm intent if unexpected)

## Usage

```
/noyeah-init ~/my-project
/noyeah-init C:\Users\me\my-project
/noyeah-init .                        # initialize current directory
```

## Keyword Detection

Triggers on: "init", "initialize", "setup harness", "bootstrap"

---

## Steps

### Phase 0: Validate

1. Verify `$TARGET_PATH` exists and is a directory. If not, abort:
   > "Error: Target path '$TARGET_PATH' does not exist or is not a directory."

2. Verify noyeah-harness root is accessible by checking that the current working directory
   contains `CLAUDE.md`, `hooks/`, and `skills/`. If not, abort:
   > "Error: Cannot find noyeah-harness root. Run /noyeah-init from the noyeah-harness directory."

3. Read noyeah-harness version from `.claude-plugin/plugin.json`:
   - If the file exists and is valid JSON with a `version` field: use that value
   - If the file is missing, unparseable, or has no `version` field: use `"unknown"` and warn:
     > "Warning: Could not read noyeah-harness version from plugin.json -- using 'unknown'"

4. If `$TARGET_PATH` resolves to the same path as noyeah-harness root, abort:
   > "Error: Cannot init noyeah-harness inside itself."

---

### Phase 1: Create .harness/ Directory Structure

1. Create the following directories (mkdir -p, no-op if they exist):
   - `.harness/state/`
   - `.harness/context/`
   - `.harness/plans/`
   - `.harness/memory/`
   - `.harness/notepad/`
   - `.harness/logs/`
   - `.harness/sessions/`
   - `.harness/codebase-map/`
   - `.harness/hooks/`

2. If `.harness/memory/project-memory.json` does not exist:
   - If noyeah-harness `.harness/templates/project-memory-seed.json` exists, copy it as
     `$TARGET_PATH/.harness/memory/project-memory.json`
   - Otherwise, create a bare file: `{ "entries": [] }`

   The seed template contains example entries with `"type": "template"` that are invisible
   to the learning injection pipeline. Users should delete these entries after reading them.

3. Create or update `.harness/.gitignore` using comment markers:

   The harness gitignore block:
   ```
   # noyeah-harness:begin
   # Ephemeral state -- regenerated each session
   state/
   logs/
   sessions/
   notepad/
   # noyeah-harness:end
   ```

   - If `.harness/.gitignore` does not exist: create it with the block above
   - If `.harness/.gitignore` exists:
     - Search for `# noyeah-harness:begin` and `# noyeah-harness:end` markers independently
     - If **both** markers found: replace the content between them (inclusive of markers) with the new block
     - If **neither** marker found: append a blank line followed by the block at the end
     - If **only one** marker found (orphaned): warn the user:
       > "Warning: Found orphaned noyeah-harness marker in .harness/.gitignore -- please verify the file manually."
       Then append a blank line followed by the block at the end (do not attempt partial replacement)
   - Never remove existing non-harness entries

   Directories NOT ignored (shareable across team via git):
   - `hooks/` -- noyeah-harness-managed hook scripts
   - `memory/` -- cross-session learnings (team-sharable decisions and patterns)
   - `context/` -- pre-context snapshots for tasks
   - `plans/` -- implementation plans from /noyeah-ralplan
   - `codebase-map/` -- project structure overview

4. Report:
   > "{N} directories created, {M} already existed. .gitignore {'created' | 'updated' | 'already current'}"

---

### Phase 2: Copy Hook Scripts

1. Read each hook script from noyeah-harness `hooks/` directory:
   - `hooks/noyeah-retro-check.js`
   - `hooks/learning-remind.js`

2. Write each to `$TARGET_PATH/.harness/hooks/` (always overwrite, unconditionally -- no hash check, no skip logic)

3. Report:
   > "Copied 2 hook scripts (retro-check.js, learning-remind.js)"

---

### Phase 3: Merge Settings

1. Create `$TARGET_PATH/.claude/` directory if it does not exist

2. Read existing `$TARGET_PATH/.claude/settings.json` if present, or start with `{}`

3. Read `hooks/settings-template.json` from noyeah-harness

4. For each hook event type in the template (e.g., `PostToolUse`, `SessionStart`):
   - If the event type key does not exist in target settings: add it entirely from the template
   - If the event type key exists, iterate the template's hook entries:
     - For each template entry, search target entries for one whose `command` field contains the **full relative path** `.harness/hooks/{script-filename}` (e.g., `.harness/hooks/noyeah-retro-check.js`)
     - If no match found: append the template entry to the target's array for that event type
     - If match found: replace the matched entry with the template version

   **Matching rule**: Match on `.harness/hooks/{filename}` (full path), NOT bare filename.
   This prevents false matches against user hooks that reference a different file with
   the same basename (e.g., `scripts/noyeah-retro-check.js` must NOT match).

5. Preserve all non-hook keys in settings.json (permissions, allowedTools, etc.)

6. Write the merged `settings.json` (formatted with 2-space indentation)

7. Report:
   > "Merged {N} hook entries into .claude/settings.json ({M} new, {K} updated)"

---

### Phase 4: Update CLAUDE.md

Search for the noyeah-harness marker block in `$TARGET_PATH/CLAUDE.md`:

1. Search for `<!-- noyeah-harness:begin -->` marker
2. Search for `<!-- noyeah-harness:end -->` marker
3. If **both** markers found: replace the entire block (inclusive of markers) with the new block below
4. If **neither** marker found and CLAUDE.md exists: append a blank line followed by the new block at the end
5. If **only one** marker found (orphaned): warn the user:
   > "Warning: Found orphaned noyeah-harness marker in CLAUDE.md at line {N}. Appending a fresh block at the end. Please manually remove the orphaned marker and its surrounding content."
   Then append the new block at the end
6. If CLAUDE.md does not exist: create it with the block as the entire content

**The noyeah-harness reference block to write**:

```markdown
<!-- noyeah-harness:begin -->
## noyeah-harness Runtime

This project uses [noyeah-harness](https://github.com/{user}/noyeah-harness) for structured agent orchestration.

### Directory Structure

`.harness/` contains runtime state, plans, memory, and hooks:
- `state/` -- Active mode state (ralph, autopilot, etc.) [gitignored]
- `context/` -- Pre-context snapshots for tasks
- `plans/` -- Implementation plans from /noyeah-ralplan
- `memory/project-memory.json` -- Cross-session learnings
- `hooks/` -- Claude Code hook scripts (auto-managed by noyeah-harness)
- `logs/` -- Execution history [gitignored]
- `sessions/` -- Session tracking [gitignored]
- `notepad/notes.md` -- Session scratchpad [gitignored]
- `codebase-map/map.md` -- Project structure overview

### Active Hooks

Two hooks run automatically via `.claude/settings.json`:

1. **retro-check** (PostToolUse: Write|Edit): After Ralph completes, reminds to run `/noyeah-retro` if no recent learnings exist.
2. **learning-remind** (SessionStart): On session start, reminds to inject learnings when dispatching agents.

### Updating

Run `/noyeah-init` from noyeah-harness to update hook scripts and settings.
<!-- noyeah-harness:end -->
```

---

## Completion Report

After all phases complete, output a summary:

```
h-init complete (noyeah-harness v{version})
  Target: {absolute path to target}
  Phase 1: {N} dirs created, {M} existed -- .gitignore {created|updated|already current}
  Phase 2: 2 hook scripts copied
  Phase 3: {N} hook entries merged ({M} new, {K} updated)
  Phase 4: CLAUDE.md {created|updated|appended}

Next step: Open a new Claude Code session in {target} to activate the hooks.
```

---

## Original Task

$ARGUMENTS
