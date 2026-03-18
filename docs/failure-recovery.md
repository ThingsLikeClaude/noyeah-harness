# Failure Recovery Guide

> When a workflow doesn't complete, this guide helps you understand why and what to do next.
> Each section covers a specific failure mode with symptoms, causes, and step-by-step resolution.

---

## 1. Ralph Hit 10 Iterations

**Symptom**: Ralph state shows `"current_phase": "failed"` after iteration 10.

**Likely root causes**:
- **Scope too large** — The task requires more changes than a single Ralph run can handle.
  Each iteration makes progress, but the full task exceeds 10 cycles of implement-verify-fix.
- **Missing test infrastructure** — The project has no test framework configured, so
  verification keeps failing on the "run tests" step.
- **Circular dependency** — Fixing issue A breaks B, fixing B breaks A. The loop cannot
  converge because the fixes conflict with each other.

**Step-by-step resolution**:
1. Run `/noyeah-cancel` to clean up the failed state
2. Run `/noyeah-status` to confirm all modes are inactive
3. Analyze what was accomplished: check the files Ralph changed (use `git diff`)
4. Split the task into smaller pieces using `/noyeah-ralplan`
5. Execute each smaller piece with its own `/noyeah-ralph` run

**Prevention**: For tasks touching more than 10 files, use `/noyeah-ralplan` first to break the
work into phases. Run Ralph on each phase separately.

---

## 2. UltraQA Hit 5 Cycles

**Symptom**: UltraQA state shows `"current_phase": "failed"` after cycle 5.

**Likely root causes**:
- **Flaky tests** — Tests pass sometimes and fail other times due to timing, network,
  or random data. UltraQA fixes one failure, but another appears non-deterministically.
- **Environment issue** — Missing environment variables, wrong Node version, or missing
  system dependencies that the fixer cannot install.
- **Fundamental design flaw** — The code structure makes it impossible to pass all tests
  without an architectural change that UltraQA's fix-and-retry approach cannot discover.

**Step-by-step resolution**:
1. Run `/noyeah-cancel` to stop the QA loop
2. Check which tests keep failing: look at the UltraQA output for recurring failures
3. If tests are flaky: fix the flaky tests first (stabilize timing, mock external services)
4. If environment issue: fix the environment manually, then re-run `/noyeah-ultraqa`
5. If design flaw: step back and run `/noyeah-ralplan` to rethink the approach

**Prevention**: Ensure your test suite passes locally before running UltraQA.
Fix known flaky tests before adding new ones.

---

## 3. Architect Rejected 3+ Times

**Symptom**: Ralph keeps looping through "fixing" phase because the architect review returns
REVISE or REJECTED repeatedly.

**Likely root causes**:
- **Fundamental approach is wrong** — The plan needs structural rework, not incremental fixes.
  Each revision addresses symptoms but not the underlying design issue.
- **Missing requirements** — The architect is rejecting because the implementation doesn't
  meet requirements that were never clearly stated.

**Step-by-step resolution**:
1. Run `/noyeah-cancel` to stop the loop
2. Read the architect's rejection reasons carefully (in the Ralph output)
3. Run `/noyeah-deep-interview "clarify requirements for {task}"` to discover missing requirements
4. Run `/noyeah-ralplan "{task}"` to create a new plan that addresses the architect's concerns
5. Execute the new plan with `/noyeah-ralph`

**Prevention**: Always run `/noyeah-ralplan` for tasks involving 3+ files. The consensus planning
process catches design issues before implementation begins.

---

## 4. Build Keeps Failing

**Symptom**: Build commands return non-zero exit codes. Executor or build-fixer cannot resolve.

**Likely root causes**:
- **Missing dependencies** — A package was added to imports but not installed.
- **Type errors** — TypeScript/Flow/Go type mismatches from incomplete refactoring.
- **Wrong runtime version** — Node.js, Python, or Go version incompatibility.

**Step-by-step resolution**:
1. Read the build error output carefully — the error message usually points to the exact file and line
2. Check if dependencies are installed: `npm install` / `pip install -r requirements.txt`
3. Check your runtime version: `node -v` / `python --version`
4. If the build-fixer agent couldn't fix it, the error may require manual intervention
5. Fix the issue manually, then resume with `/noyeah-resume`

**Prevention**: Keep your `package.json` / `requirements.txt` up to date. Run the build
locally before starting a harness workflow.

---

## 5. State is Corrupted

**Symptom**: `/noyeah-status` shows unexpected values, skills refuse to start, or error messages
mention state file issues.

**Likely root causes**:
- **Interrupted session** — Claude Code was closed while a workflow was mid-execution,
  leaving state files in an intermediate phase.
- **Manual editing** — State files were edited by hand with invalid JSON or wrong phase names.

**Step-by-step resolution**:
1. Run `/noyeah-cancel --force` — this resets ALL state files to their terminal states
2. Run `/noyeah-status` to confirm everything shows as inactive
3. Start your workflow fresh

**Prevention**: Let workflows complete naturally. If you need to stop, use `/noyeah-cancel`
instead of closing the terminal.

---

## 6. Session Interrupted Mid-Run

**Symptom**: You closed Claude Code or lost connection while a workflow was running.
When you return, the workflow is not active but work was partially completed.

**Likely root causes**:
- **Terminal closed** — The session ended unexpectedly.
- **Network disconnection** — Connection to Claude was lost.

**Step-by-step resolution**:
1. Open a new Claude Code session in your project
2. Run `/noyeah-status` to see what state was saved
3. Run `/noyeah-resume` — this detects the interrupted workflow and continues from the last phase
4. If `/noyeah-resume` cannot recover, run `/noyeah-cancel --force` and start the task again

**Prevention**: Use stable network connections for long-running workflows. The harness
saves state at every phase transition, so most interruptions are recoverable.

---

## Good to Know

- **Ecomode does not affect security reviews** — they always use THOROUGH tier regardless
  of ecomode settings. Your security reviews are never downgraded.
- **State files are in `.harness/state/`** — you can read them directly to understand what
  happened: `cat .harness/state/noyeah-ralph-state.json`
- **Plans are preserved** — even after failure, your plans remain at `.harness/plans/`
  for reference. They are never deleted by `/noyeah-cancel`.
- **Project memory persists** — learnings from failed attempts are saved in
  `.harness/memory/project-memory.json` and help future workflows avoid the same mistakes.
