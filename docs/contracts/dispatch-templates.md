# Dispatch Templates

Dispatch Templates for 7 non-core agents in noyeah-harness. Copy the template, substitute bracketed fields, and pass as the `prompt` parameter to `Agent()`. For core chained agent I/O contracts, see `core-contracts.md`.

---

## Part 2: Dispatch Templates for 7 Non-Core Agents

Non-core agents are dispatched as-needed rather than chained in a fixed sequence. Use these templates to construct dispatch prompts. Each template specifies required context fields, expected output format, and a concrete example.

---

### 2.1 Debugger

**Tier**: STANDARD | **Model**: sonnet | **Posture**: deep-worker

#### Required context fields

| Field | Description |
|-------|-------------|
| `symptom` | What the user or test sees (error message, wrong output, crash) |
| `reproduction_command` | The exact command or test that triggers the bug |
| `affected_files` | File paths known or suspected to be involved |
| `recent_changes` | Git log or description of what changed before the bug appeared |

#### Expected output format

```
BUG REPORT
==========
Symptom: {what the user sees}
Root Cause: {actual cause with file:line}
Fix: {what was changed and why}
Evidence: {command output proving the fix works}
Regression Risk: {what else could break}
```

If three hypotheses all fail, the debugger outputs:

```
ESCALATION
==========
Hypotheses tried: {list}
Findings: {what was discovered}
Recommended next step: {architect review / user clarification}
```

#### Dispatch prompt example

```
Agent(
  model="claude-sonnet-4-5",
  prompt="""
You are the debugger agent. Read agents/debugger.md for your full protocol.

Symptom: The `POST /api/users` endpoint returns 500 with message
  "Cannot read properties of undefined (reading 'id')" when email is missing.

Reproduction command:
  curl -X POST http://localhost:3000/api/users -H 'Content-Type: application/json' -d '{}'

Affected files:
  src/api/users.ts
  src/services/user-service.ts

Recent changes:
  git log --oneline: a3f1c2 "add email validation middleware" (2 hours ago)

Follow your 5-step protocol: REPRODUCE -> GATHER EVIDENCE -> HYPOTHESIZE -> FIX -> VERIFY.
Output your BUG REPORT in the specified format.
"""
)
```

---

### 2.2 Build Fixer

**Tier**: STANDARD | **Model**: sonnet | **Posture**: deep-worker

#### Required context fields

| Field | Description |
|-------|-------------|
| `build_command` | The exact command that is failing |
| `build_output` | Full error output captured from the failed build |
| `project_type` | Detected project type (Node.js/TypeScript, Rust, Go, Python, Make) |

#### Expected output format

```
BUILD FIX REPORT
================
Initial errors: {N}
Errors fixed: {X}/{N}

Fixes applied:
- {file}:{line}: {what was wrong} -> {what was fixed}
- ...

Build status: PASSING | STILL_FAILING ({remaining} errors)
```

#### Dispatch prompt example

```
Agent(
  model="claude-sonnet-4-5",
  prompt="""
You are the build-fixer agent. Read agents/build-fixer.md for your full protocol.

Project type: Node.js/TypeScript
Build command: npx tsc --noEmit

Build output:
  src/auth/token.ts(42,18): error TS2345: Argument of type 'string | undefined'
    is not assignable to parameter of type 'string'.
  src/auth/token.ts(57,5): error TS2304: Cannot find name 'JwtPayload'.

Apply minimal fixes only. Do not refactor or rename. Track progress as X/Y errors fixed.
Output your BUILD FIX REPORT in the specified format.
"""
)
```

---

### 2.3 Test Engineer

**Tier**: STANDARD | **Model**: sonnet | **Posture**: deep-worker

#### Required context fields

| Field | Description |
|-------|-------------|
| `task` | What to test: "write tests for X", "harden flaky test Y", "verify red-green for bug fix Z" |
| `target_files` | Source files or modules under test |
| `test_framework` | Test framework in use (Jest, Vitest, pytest, etc.) |
| `existing_test_path` | Path to existing test files for convention reference |

#### Expected output format

```
TEST REPORT
===========
Tests written: {N}
Coverage impact: {before}% -> {after}%
TDD cycle: RED -> GREEN -> REFACTOR verified

New tests:
- {test file}: {test name} - {what it tests}
- ...

Coverage gaps identified:
- {module}: {what's untested}
```

#### Dispatch prompt example

```
Agent(
  model="claude-sonnet-4-5",
  prompt="""
You are the test-engineer agent. Read agents/test-engineer.md for your full protocol.

Task: Write unit tests for the new password-reset flow.

Target files:
  src/auth/password-reset.ts
  src/services/email-service.ts

Test framework: Jest (TypeScript)
Existing test conventions: see src/__tests__/auth/login.test.ts

Follow TDD: write failing tests first (RED), then verify they pass after implementation (GREEN).
Cover: happy path, invalid token, expired token, already-used token.
Output your TEST REPORT in the specified format.
"""
)
```

---

### 2.4 Security Reviewer

**Tier**: THOROUGH | **Model**: opus | **Posture**: frontier-orchestrator

#### Required context fields

| Field | Description |
|-------|-------------|
| `scope` | Files, endpoints, or modules to review |
| `change_description` | What was changed or added (plain language or git diff) |
| `entry_points` | Known HTTP routes, input handlers, or auth boundaries in scope |

#### Expected output format

```
SECURITY REVIEW
===============

Summary: {X findings: N critical, N high, N medium, N low}

CRITICAL:
- [OWASP-ID] {description} in {file}:{line}
  Attack: {how to exploit}
  Impact: {what an attacker gains}
  Fix: {recommended fix}

HIGH:
- [OWASP-ID] {description} in {file}:{line}
  ...

Dependencies:
- {package}@{version}: {CVE} - {severity}

Secrets:
- {file}:{line}: Possible hardcoded {type}

VERDICT: BLOCK | FIX_BEFORE_MERGE | ACCEPTABLE
```

#### Dispatch prompt example

```
Agent(
  model="claude-opus-4-5",
  prompt="""
You are the security-reviewer agent. Read agents/security-reviewer.md for your full protocol.

Scope: the new file upload feature
Files: src/api/upload.ts, src/middleware/multer-config.ts, src/services/storage.ts

Change description:
  Added multipart file upload endpoint at POST /api/upload.
  Files are saved to ./uploads/ and served at GET /api/files/:filename.

Entry points:
  POST /api/upload — accepts multipart/form-data, no auth currently
  GET /api/files/:filename — serves files from disk by filename param

Run your OWASP Top 10 scan and secrets scan. You are read-only; do not edit files.
Output your SECURITY REVIEW in the specified format.
CRITICAL findings must be surfaced immediately in your response header.
"""
)
```

---

### 2.5 Writer

**Tier**: LOW | **Model**: haiku | **Posture**: fast-lane

#### Required context fields

| Field | Description |
|-------|-------------|
| `task` | Documentation task: "write API docs for X", "update README section Y", "add inline comments to Z" |
| `source_files` | Files the writer must read before writing (for accuracy) |
| `output_file` | Where to write the documentation |

#### Expected output format

Writer produces documentation files (`.md` or inline comments) directly. For API docs:

```markdown
## `functionName(param1: Type, param2: Type): ReturnType`

Brief description.

### Parameters
| Name | Type | Required | Description |

### Returns
`ReturnType` - Description

### Example
```code```

### Throws
- `ErrorType` - When {condition}
```

For all output types the writer confirms at the end:

```
WRITER SUMMARY
==============
Files written: {list}
Code examples verified: {yes/no, with method}
```

#### Dispatch prompt example

```
Agent(
  model="claude-haiku-4-5",
  prompt="""
You are the writer agent. Read agents/writer.md for your full protocol.

Task: Write API documentation for the authentication module.

Source files to read first:
  src/auth/auth.ts
  src/auth/token.ts
  src/auth/password-reset.ts

Output file: docs/api/auth.md

Read each source file, verify all function signatures and examples actually work,
then write the documentation. Use active voice. No filler words.
Confirm code examples are verified in your WRITER SUMMARY.
"""
)
```

---

### 2.6 Explorer

**Tier**: LOW | **Model**: haiku | **Posture**: fast-lane

#### Required context fields

| Field | Description |
|-------|-------------|
| `query` | The specific question to answer about the codebase |
| `search_hints` | Known file patterns, function names, or module names to start from (optional but speeds up search) |

#### Expected output format

```
EXPLORATION RESULT
==================
Query: {what was asked}
Found: {concise answer in 2–5 sentences}
Files: {relevant file paths}
Evidence: {key line numbers or code snippets}
Confidence: HIGH | MEDIUM | LOW
Escalation: {if LOW confidence, suggest architect review}
```

#### Dispatch prompt example

```
Agent(
  model="claude-haiku-4-5",
  prompt="""
You are the explorer agent. Read agents/explorer.md for your full protocol.

Query: Where is the rate limiting middleware applied and which routes does it cover?

Search hints: look for "rateLimit", "rate-limit", "express-rate-limit" in src/

Be concise. Output your EXPLORATION RESULT in the specified format.
If you find the answer is more complex than expected, set Confidence to LOW and
recommend architect review.
"""
)
```

---

---

### 2.7 Researcher

**Tier**: STANDARD | **Model**: sonnet | **Posture**: deep-worker

#### Required context fields

| Field | Description |
|-------|-------------|
| `task` | What is being built (plain language description) |
| `domain` | Detected category (PM/Collab, E-commerce, Social, Communication, Analytics, CRM, Education) |

#### Expected output format

```
# Research: {task}
Date: {ISO date}
Searches: {count}/8 web, {count}/3 deep-read, {count}/2 code

## Competitors ({N} found)
| Name | URL | Key Differentiator | Relevance |

## Architecture Patterns
- {pattern}: {description, tradeoffs}

## Feature Matrix
| Feature | Comp 1 | Comp 2 | Comp 3 | Our Priority |

## UX Patterns
- {pattern}: {where seen, why effective}

## Technical Recommendations
1. {recommendation}: {rationale}

## Summary
{500-token synthesis for prompt injection}
```

#### Dispatch prompt example

```
Agent(
  model="claude-sonnet-4-5",
  prompt="""
You are the researcher agent. Read agents/researcher.md for your full protocol.

Task: Research competitors and architecture for building a team collaboration app.
Domain: PM/Collab

Follow your 6-step protocol:
1. Parse task → extract domain keywords
2. Competitor discovery (max 4 Exa searches)
3. Architecture patterns (max 2 Exa searches)
4. Deep-read top 3 competitor pages (Jina Reader)
5. Implementation patterns (max 2 Exa code context searches)
6. Synthesize → structured report

Cost limits: max 8 web searches, max 3 Jina reads.
Output to .harness/context/research-team-collab-20260319T100000Z.md
"""
)
```

---

See also: [`core-contracts.md`](core-contracts.md) for I/O contract schemas used in structured workflow chains (ralplan, ralph, autopilot). [`research-contract.md`](research-contract.md) for the full researcher I/O contract.
