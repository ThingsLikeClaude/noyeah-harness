---
name: noyeah-deep-interview
description: Socratic requirements gathering through structured questioning
---
# Deep Interview - Requirements Discovery

## Purpose

Structured Socratic interview that closes requirement gaps before planning or execution.
Prevents the "I assumed you wanted X" problem by surfacing assumptions explicitly.

## Use When

- Vague or ambiguous task description
- User says "interview", "clarify", "what do I need?"
- Before `/noyeah-ralplan` or `/noyeah-autopilot` for complex features
- When multiple valid interpretations exist

## Do Not Use When

- Requirements are already clear and specific
- Simple bug fix with obvious solution
- User has already provided detailed spec

## Modes

### Quick Mode (Default)

5 targeted questions covering:
1. **Context**: What problem are we solving?
2. **Goals**: What does success look like?
3. **Scope**: What's in and what's out?
4. **Constraints**: Technical limitations, timeline, dependencies?
5. **Validation**: How will we know it's done?

```
/noyeah-deep-interview "build a notification system"
/noyeah-deep-interview --quick "add caching"
```

### Full Mode

Comprehensive requirements pass with up to 15 questions:

```
/noyeah-deep-interview --full "redesign the authentication flow"
```

Additional areas:
6. **Users**: Who uses this? What are their skill levels?
7. **Edge cases**: What happens when X fails?
8. **Performance**: Expected load, latency requirements?
9. **Security**: Sensitive data involved? Compliance needs?
10. **Integration**: What existing systems does this touch?

## Interview Protocol

### 1. Explore First

Before asking ANY questions, explore the codebase:
- Glob for related files
- Grep for related patterns
- Read key files to understand current state

This prevents asking questions the codebase already answers.

### 2. Ask Smart Questions

Present questions as a numbered list. For each:
- State what you already know from the codebase
- Ask what you genuinely can't determine from code
- Offer your default assumption if the user doesn't answer

### 3. Record Output

Save interview results to `.harness/context/interview-{slug}-{timestamp}.md`:

```markdown
# Interview: {task description}
Date: {ISO date}

## Context
{answers about the problem}

## Goals
{answers about success criteria}

## Scope
- In scope: {list}
- Out of scope: {list}

## Constraints
{technical and non-technical constraints}

## Validation Criteria
{how to verify completion}

## Assumptions Made
{assumptions that were confirmed or defaulted}

## Open Questions
{questions that remain unanswered}
```

### 4. Transition

After interview:
- If part of autopilot: proceed to `/noyeah-ralplan`
- If standalone: present summary and ask user what's next
- Always save the interview file for reference

## Constraints

- Never ask questions the codebase already answers
- Max 5 questions in quick mode, 15 in full mode
- Each question must include your current assumption
- Don't block on unanswered questions -- use stated defaults

## Original Task

$ARGUMENTS
