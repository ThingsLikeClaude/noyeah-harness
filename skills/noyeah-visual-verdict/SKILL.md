---
name: noyeah-visual-verdict
description: Visual QA verification using screenshots
---
# Visual Verdict - Screenshot-Based QA

## Purpose

When a task depends on visual fidelity, Visual Verdict compares the current state
(screenshot) against reference images or design requirements and produces a
structured quality score.

## Use When

- UI implementation that must match a design
- User provides reference screenshots
- User says "visual check", "does this look right?", "match this design"
- During Ralph loop for visual tasks (run before each edit iteration)

## Do Not Use When

- No visual component (backend, CLI, API)
- No reference image or visual criteria available

## Protocol

### 1. Capture Current State

Take a screenshot of the current implementation:

```
Agent(
  name: "screenshot",
  prompt: "Navigate to {URL} and take a screenshot using Playwright MCP tools",
  model: "sonnet"
)
```

Or if the user provides a screenshot path, read it directly.

### 2. Compare

Read both the reference image(s) and current screenshot.
Analyze across these dimensions:

| Category | Weight | Description |
|----------|--------|-------------|
| Layout | 30% | Structure, spacing, alignment |
| Typography | 20% | Font size, weight, hierarchy |
| Colors | 20% | Palette, contrast, consistency |
| Components | 20% | Button styles, form elements, cards |
| Responsiveness | 10% | Viewport adaptation |

### 3. Score & Verdict

Output structured JSON:

```json
{
  "score": 85,
  "verdict": "PASS",
  "category_match": {
    "layout": 90,
    "typography": 85,
    "colors": 80,
    "components": 85,
    "responsiveness": 80
  },
  "differences": [
    "Header padding is 16px instead of 24px",
    "Button border-radius should be 8px not 4px"
  ],
  "suggestions": [
    "Increase header padding to 24px",
    "Update button border-radius to 8px"
  ],
  "reasoning": "Layout structure matches well but spacing details need refinement"
}
```

### 4. Pass/Fail Threshold

- **Score >= 90**: PASS -- proceed
- **Score 70-89**: CONDITIONAL -- fix critical differences, then re-check
- **Score < 70**: FAIL -- significant rework needed

## Integration with Ralph

During Ralph loop for visual tasks:
1. Run `/noyeah-visual-verdict` **before every edit iteration**
2. Record score in `.harness/state/noyeah-ralph-state.json` under `visual_scores[]`
3. Ralph stops when visual score >= 90

## State Tracking

Append to `.harness/state/noyeah-visual-verdicts.json`:

```json
{
  "verdicts": [
    {
      "iteration": 1,
      "timestamp": "{ISO}",
      "score": 72,
      "verdict": "CONDITIONAL",
      "differences_count": 5
    }
  ]
}
```

## Original Task

$ARGUMENTS
