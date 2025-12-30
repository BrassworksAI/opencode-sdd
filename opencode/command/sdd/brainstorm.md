---
description: "Start or resume ideation — explore the problem space and produce a seed document"
agent: sdd/forge
args:
  - name: name
    description: "Project/change name (kebab-case, e.g. 'habit-tracker')"
    required: true
---

# /sdd/brainstorm

Launches or resumes the ideation phase for a greenfield project. This is Phase 0 — before you have a feature-shaped intent, before proposal.

## What This Does

Opens a collaborative dialogue to explore:
- What problem you're solving and why it matters
- Core invariants and non-negotiables
- MVP scope and explicit non-goals
- Architectural leanings and early technical intuitions
- Future horizons that influence early decisions
- Risks and open questions

## Output

Produces `changes/<name>/seed.md` — a lightweight document that captures the project's DNA and feeds into `/sdd/proposal`.

The seed is only written when you explicitly tell the ideator to write it.

## Usage

```
/sdd/brainstorm habit-tracker
```

Then iterate:
```
/sdd/continue habit-tracker
```

Edit `## User Feedback` in `loops/ideation.md` to guide the conversation, then run `/sdd/continue` to get the ideator's response.

When you're satisfied, tell the ideator to "write the seed" or "finalize the seed".

## What to do (forge)

### If folder doesn't exist

1. Create folder structure (same as `/sdd/init`):
   - `changes/<name>/`
   - `changes/<name>/specs/`
   - `changes/<name>/thoughts/`
   - `changes/<name>/plans/`
   - `changes/<name>/loops/`

2. Create `changes/<name>/state.md` with:
   - `Phase: ideation`
   - `Lane: full`
   - `Run Mode: manual`

3. Ensure `changes/<name>/loops/ideation.md` exists.

4. Delegate to `sdd/ideator`.

### If folder exists

1. Read `changes/<name>/state.md`.

2. Check `Phase`:
   - If `initialized`, `ideation`, or `proposal`: proceed (pull back to ideation)
   - If `specs` or later: STOP and warn: "Change has progressed beyond proposal. Cannot return to ideation without losing work."

3. Update `state.md`:
   - `Phase: ideation`
   - Preserve other fields

4. Ensure `changes/<name>/loops/ideation.md` exists.

5. Delegate to `sdd/ideator`.

### Delegation prompt

```
Task(sdd/ideator):
  Mission: Explore the problem space and help the user develop their idea.
  
  Change name: <name>
  
  Inputs:
  - changes/<name>/state.md
  - changes/<name>/loops/ideation.md (read existing turns)
  - changes/<name>/seed.md (if exists — may be revising)
  
  Outputs:
  - Append to changes/<name>/loops/ideation.md
  - Write changes/<name>/seed.md ONLY when user explicitly requests
  
  Constraints:
  - Append turns to loop file, do not overwrite previous turns
  - End every turn with ## User Feedback section and --- separator
  - Do NOT write seed.md unless user explicitly says to finalize/write the seed
  - Do NOT update Phase — forge already set it to ideation
```

### After ideator returns

Report:
- Summary of what was discussed
- "Edit `## User Feedback` in `loops/ideation.md` and run `/sdd/continue <name>` to keep iterating."
- "When you're ready to finalize, tell the ideator to write the seed, then run `/sdd/proposal <name>`."

## Pulling Back to Ideation

If you've already started a proposal but realize you need more exploration, `/sdd/brainstorm <name>` will pull the state back to ideation (as long as you haven't progressed past proposal).

This lets you step back and rethink without losing your work — the proposal and other artifacts remain, and you can incorporate them into your seed if useful.

## When to Use

- Starting a brand new project from scratch
- Exploring a problem space before committing to a solution
- When you have an idea but haven't shaped it yet
- When you realize your proposal was premature and want to step back

## Next Step

Once you have a seed (`changes/<name>/seed.md` exists), run `/sdd/proposal <name>` — the proposer will read your seed and draft a concrete proposal.
