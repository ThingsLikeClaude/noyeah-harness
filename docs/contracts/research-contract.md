# Research Contract

I/O contract schema for the researcher agent.

---

## Input Contract

```
INPUT CONTRACT
==============
Agent: researcher
Mode: autopilot research phase | standalone research

Required fields:
- task: description of what is being built (plain language)
- domain: detected category (PM/Collab, E-commerce, Social, etc.)

Optional context:
- interview_path: .harness/context/interview-{slug}-{ts}.md (if deep-interview was run)
- constraints: known limitations (e.g. "focus on open-source competitors only")
- specific_competitors: known competitors to include in analysis
```

## Output Contract

```
OUTPUT CONTRACT
===============
Agent: researcher

Outputs:
- competitors: table of discovered competitors with URL, differentiator, relevance
- competitor_details: per-competitor breakdown (features, UX, tech, strengths, gaps)
- architecture_patterns: patterns found with descriptions and tradeoffs
- feature_matrix: cross-comparison table across competitors
- ux_patterns: notable UX approaches with where they were observed
- technical_recommendations: evidence-based suggestions with rationale
- summary: 500-token synthesis for prompt injection
- report_file: written to .harness/context/research-{slug}-{timestamp}.md

Verdict tokens: (none — researcher produces a report, not a pass/fail verdict)
Escalation trigger: domain too niche for meaningful results — researcher notes gaps
  and recommends user input for competitor identification
```

## Dispatch Template

```
Agent(
  model="claude-sonnet-4-5",
  prompt="""
You are the researcher agent. Read agents/researcher.md for your full protocol.

Task: Research competitors and architecture patterns for: {task description}
Domain: {detected domain category}

Follow your 6-step protocol:
1. Parse task → extract domain keywords
2. Competitor discovery (max 4 Exa searches)
3. Architecture patterns (max 2 Exa searches)
4. Deep-read top 3 competitor pages (Jina Reader)
5. Implementation patterns (max 2 Exa code context searches)
6. Synthesize → structured report

Cost limits: max 8 web searches, max 3 Jina reads.
Output to .harness/context/research-{slug}-{timestamp}.md
"""
)
```

## Integration with Core Contracts

The researcher's output integrates with the planner input contract via a new optional field:

```
Optional context (additions to planner input):
- research_path: .harness/context/research-{slug}-{ts}.md
- research_summary: 500-token synthesis from researcher output
```

The same fields are injected into the architect input contract when research is available.

---

See also: [`core-contracts.md`](core-contracts.md) for core agent I/O schemas,
[`dispatch-templates.md`](dispatch-templates.md) for non-core agent dispatch templates.
