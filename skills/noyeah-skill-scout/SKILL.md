---
name: noyeah-skill-scout
description: Auto-detect project tech stack and discover/install relevant skills from skills.sh
---
# Skill Scout - Auto-Discover and Install Project-Relevant Skills

## Purpose

Automatically detect the project's tech stack, search skills.sh for relevant community skills,
skip anything already installed globally, and install new finds at the project level.
Records all installations for cross-session reuse.

## Use When

- Autopilot Phase 0 calls this automatically
- User says "skill scout", "find skills", "discover skills", "what skills do I need"
- Setting up a new project and want optimal skill coverage
- After changing tech stack significantly

## Do Not Use When

- User wants to manually search skills.sh (use `npx skills find` directly)
- Offline environment with no network access
- User explicitly opts out of auto-discovery

## Modes

### Mode A: Auto-Detect (existing project)
```
/noyeah-skill-scout
```
Scans file system for package.json, requirements.txt, etc. to detect tech stack.

### Mode B: Explicit Stack (empty project or override)
```
/noyeah-skill-scout "react, supabase, tailwind"
```
Accepts comma-separated tech stack as argument.

### Mode C: Context File (within autopilot)
Reads `.harness/context/interview-*.md` files for tech stack info when no manifest files exist.

## Execution Protocol

### Phase 0: Detect Tech Stack

1. Glob for manifest files in the project root and common subdirectories:

   | File | Stack Signal |
   |------|-------------|
   | `package.json` | Read `dependencies` + `devDependencies` keys |
   | `requirements.txt` | Python packages, one per line |
   | `pyproject.toml` | Python project dependencies |
   | `pom.xml` | Java/Maven |
   | `build.gradle` | Java/Gradle |
   | `go.mod` | Go modules |
   | `Cargo.toml` | Rust crates |
   | `*.csproj` | C#/.NET |
   | `composer.json` | PHP |
   | `Gemfile` | Ruby |
   | `pubspec.yaml` | Dart/Flutter |

2. If no manifest files found:
   - Read the most recent `.harness/context/interview-*.md` file
   - Look for tech stack mentions (frameworks, languages, libraries)

3. If still nothing and `$ARGUMENTS` provided:
   - Parse comma-separated stack from arguments
   - Example: `"react, supabase, tailwind"` → `["react", "supabase", "tailwind"]`

4. If no stack detected at all:
   - Report: "No tech stack detected. Provide stack explicitly: /noyeah-skill-scout 'react, tailwind'"
   - Exit gracefully

### Phase 1: Map Stack to Search Keywords

Convert detected technologies to skills.sh search keywords.
**Limit to max 5 keywords** (prioritize: framework > library > tool).

| Detected Dependency | Search Keyword |
|-------------------|----------------|
| react, react-dom | react |
| next | nextjs |
| vue | vue |
| angular | angular |
| svelte | svelte |
| tailwindcss | tailwind |
| typescript | typescript |
| express, koa, nestjs, fastify | {name} |
| flask, django, fastapi | {name} |
| supabase | supabase |
| prisma | prisma |
| docker (Dockerfile exists) | docker |
| playwright | playwright |
| jest, vitest, mocha | testing |
| react-native, expo | react-native |
| flutter | flutter |

If more than 5 keywords, keep the top 5 by priority:
1. Primary framework (react, vue, nextjs, django, etc.)
2. Backend/BaaS (supabase, prisma, express)
3. Styling (tailwind)
4. Testing (playwright, jest)
5. Tooling (docker, typescript)

### Phase 2: Search skills.sh

For each keyword, run:
```bash
npx skills find {keyword}
```

Parse results to extract skill packages. Expected format:
```
owner/repo@skill-name
└ https://skills.sh/owner/repo/skill-name
```

Collect all unique candidates into a list.

If `npx skills` is not available or network fails:
- Warn: "Skills CLI unavailable. Skipping skill discovery."
- Exit gracefully (do NOT block autopilot)

### Phase 3: Filter Duplicates

For each candidate skill:

1. Extract skill name (the part after `@`, e.g., `vercel-react-best-practices`)

2. **Check global install**: Does `~/.claude/skills/{skill-name}/` exist?
   - Yes → SKIP with note: "Already installed globally: {name}"

3. **Check project install**: Does `.claude/skills/{skill-name}/` exist?
   - Yes → SKIP with note: "Already installed in project: {name}"

4. **Check install record**: Is the skill in `.harness/memory/skills-installed.json`?
   - Yes → SKIP with note: "Previously installed: {name}"

Only skills passing all 3 checks proceed to installation.

### Phase 4: Install

For each skill that passed filtering:
```bash
npx skills add {owner/repo@skill-name} -y
```

**No `-g` flag** — install at project level only.

If installation fails for a specific skill:
- Warn: "Failed to install {name}, continuing..."
- Do NOT abort the entire process

### Phase 5: Record

Update (or create) `.harness/memory/skills-installed.json`:

```json
{
  "installed": [
    {
      "name": "vercel-react-best-practices",
      "package": "vercel-labs/agent-skills@vercel-react-best-practices",
      "installed_at": "2026-03-19T09:30:00Z",
      "detected_stack": ["react", "nextjs"],
      "source": "skills.sh"
    }
  ],
  "last_scan": "2026-03-19T09:30:00Z",
  "detected_stack": ["react", "typescript", "tailwindcss"]
}
```

If the file exists, merge new entries (don't overwrite existing ones).
Update `last_scan` and `detected_stack` on every run.

### Phase 6: Report

Output a completion summary:

```
skill-scout complete
  Detected stack: react, typescript, tailwindcss, supabase
  Searched: 4 keywords
  Found: 6 candidates
  Skipped: 2 (already installed globally)
  Installed: 3 skills
    - vercel-react-best-practices
    - nextjs-supabase-auth
    - tailwind-theme-builder
  Record: .harness/memory/skills-installed.json updated
```

If nothing was installed:
```
skill-scout complete
  Detected stack: react, typescript
  Searched: 2 keywords
  Found: 3 candidates
  Skipped: 3 (all already installed)
  No new skills to install.
```

## Constraints

- Max 5 search keywords per run (prevents excessive API calls)
- Network required — graceful skip if offline
- Installation failures are non-blocking warnings
- No user confirmation needed (project-level install is safe)
- Do NOT install skills that are already present globally or in the project

## Original Task

$ARGUMENTS
