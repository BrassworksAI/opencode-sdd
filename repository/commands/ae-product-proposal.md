---
description: Draft and refine a proposal document
---

# Proposal

Draft and refine a proposal document.

## Required Skills (Must Load)

You MUST load and follow these skills before doing anything else:

- `research`

If any required skill content is missing or not available in context, you MUST stop and ask the user to re-run the command or otherwise provide the missing skill content. Do NOT proceed without them.

## Inputs

- Target location for `proposal.md`. Ask the user for a folder or file path. If they provide a folder, use `<target>/proposal.md`. If they provide a file path, use that file. If they provide nothing, default to `proposal.md` in the current working directory.
- Seed location (optional). If the proposal path is `<dir>/proposal.md`, use `<dir>/seed.md` as `<seed-path>`. If that file doesn't exist, skip it.

## Instructions

### Setup

Run:

- `cat <seed-path> 2>/dev/null || echo "No seed found"`
- `cat <proposal-path> 2>/dev/null || echo "No proposal found"`

### Research Phase (Recommended)

For non-trivial proposals, use the `research` skill:

1. **Investigate the codebase** to understand:
   - Does similar functionality already exist?
   - What would this change interact with?
   - Are there existing patterns or constraints to respect?

2. **Inform the proposal** with findings:
   - Reference existing code/patterns in approach
   - Note integration points
   - Identify potential risks based on codebase structure

### Collaborative Refinement

This is a dialogue, not a generation task. The user brings whatever definition they have—a half-formed idea, a detailed vision, a conversation summary—and you help them refine it into something complete enough for specs.

**The user is the domain expert.** They have tribal knowledge about users, business context, past decisions, and constraints that isn't written anywhere. Your job is to help them externalize and articulate it, not to invent it.

**Ask, don't assume.** When there's a gap, surface it as a question: "What happens if the upload fails mid-stream?" Don't fill gaps with guesses.

**Recommend, don't decide.** If you see a pattern in the codebase that might apply: "Based on how similar features work, you might want to handle this as X—does that fit?" Let the user decide.

**Surface logic gaps.** When the described behavior has holes: "You mentioned auto-save, but what happens if the user is offline? Is that something we need to handle?" Ask if it should be considered, then let them answer.

Capture key decisions and progress directly in the proposal as you go.

### Proposal Content

A proposal describes **how the system works**—written so anyone could read it and understand the feature.

**Start with the problem.** One or two sentences on what pain exists today. This anchors everything that follows.

**Cover the full behavior.** Write in narrative prose. Be specific and concrete.

- What does the user do? What happens in response?
- What does the system do automatically? When and why?
- What happens when things go wrong? How does the system recover or report?
- If there are different modes or states, how do they differ?

**Leave nothing implied.** If there's behavior the user is picturing but hasn't written down, it won't make it to specs. The proposal is the complete source of truth for what gets built.

**Stay affirmative.** Describe what the system does, not what it doesn't do. Scope exclusions, future considerations, and hedged commitments ("if time permits...") dilute focus and create noise for the specs phase. If you need to track these, put them in `boundaries.md` or `future.md`—not in the proposal.

### Structure Sensing

As the user describes the feature, notice when natural boundaries emerge:

**Capability boundaries.** "It sounds like there are two distinct capabilities here: the edit flow itself, and the validation that happens before saving. Am I reading that right?"

**Domain awareness.** "So this would live under notifications, or is it more of a user-preferences thing?" Ask rather than decide—help the user identify where this belongs.

Don't force structure prematurely. The goal is to surface what's emerging and check if your framing matches the user's mental model. This makes the specs phase easier without imposing a taxonomy.

### Readiness

A proposal is ready for specs when you can answer "how does the system handle..." for any scenario using only what's written.

### Critique (Recommended)

If the user wants analytical critique, offer a focused review:

- Identifies contradictions, gaps, and risks
- Challenges unstated assumptions
- Provides honest assessment of proposal quality

Address any serious issues raised before proceeding.

### Scenario Testing (Recommended)

If the user wants user-perspective validation, offer a scenario walk-through:

- Tests proposal by inhabiting a realistic user persona
- Identifies gaps, friction points, and ambiguities
- Reports whether a user could actually accomplish their goals

Address blocking issues before proceeding; note friction points for consideration.

### Completion

When they explicitly approve the proposal:

1. Save the finalized proposal to `<proposal-path>`
2. Suggest drafting specs or a delivery plan next, depending on their process
