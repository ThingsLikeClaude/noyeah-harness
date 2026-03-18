# Codebase Map

## Concept

A compact structural overview of the project being worked on. Generated once
and refreshed on demand. Agents reference it for quick orientation.

## Storage

`.harness/codebase-map/map.md`

## Generation

On first exploration or when requested, generate by:

1. List top-level files and directories
2. Identify key entry points (package.json, main files, etc.)
3. Map module boundaries
4. Note key patterns (monorepo, framework conventions)

## Format

```markdown
# Codebase Map: {project-name}

## Structure
```
src/
  api/          # REST endpoints
  services/     # Business logic
  models/       # Data models
  utils/        # Shared utilities
tests/
  unit/         # Unit tests
  integration/  # Integration tests
public/         # Static assets
```

## Entry Points
- `src/index.ts` — Application bootstrap
- `src/api/routes.ts` — Route definitions
- `package.json` — Dependencies and scripts

## Key Modules
| Module | Purpose | Key Files |
|--------|---------|-----------|
| Auth | Authentication/authorization | `src/services/auth.ts`, `src/api/auth.ts` |
| Users | User management | `src/services/users.ts`, `src/models/user.ts` |

## Conventions
- Framework: Next.js 15
- Testing: Vitest
- Styling: Tailwind CSS v4
- State: Zustand

## Scripts
| Script | Command |
|--------|---------|
| Dev | `npm run dev` |
| Build | `npm run build` |
| Test | `npm test` |
| Lint | `npm run lint` |
```

## When to Generate

- First time working in a new project
- When project structure changes significantly
- When an agent needs orientation (include path in agent prompt)

## When to Reference

- Include relevant sections in agent dispatch prompts
- Before `/noyeah-ralplan` to inform planning
- Before `/noyeah-team` to assign worker boundaries
