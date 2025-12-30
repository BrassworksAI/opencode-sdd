---
description: Resume the current phase after editing feedback
agent: sdd/forge
args:
  - name: change-name
    description: "Change name (optional — will infer if possible)"
    required: false
---

# /sdd/continue

Resume the current phase agent after you've edited feedback in a loop file or artifact.

## Usage

```
/sdd/continue [change-name]
```

## When to Use

- After editing `## User Feedback` in a loop file or artifact
- To re-enter a phase and continue iterating
- When you want the current phase agent to read your feedback and respond

## What to do (forge)

### 1. Determine Change Name

If `<change-name>` provided:
- Use it directly.

If `<change-name>` NOT provided:
- Look for `changes/*/state.md` files.
- If exactly one exists: use it.
- If multiple exist: pick the most recently modified, but confirm with user:
  - "I think you mean `<name>` (most recently active). Confirm? (yes/no)"
- If none exist: ask user for change name.

### 2. Read State

Read `changes/<change-name>/state.md` and extract `Phase`.

### 3. Route to Phase Agent

Delegate based on current phase:

| Phase | Agent | Notes |
|-------|-------|-------|
| `ideation` | `sdd/ideator` | Reads/appends `loops/ideation.md` |
| `proposal` | `sdd/proposer` | Reads feedback from `proposal.md` or `loops/proposal.md` |
| `specs` | `sdd/specsmith` | |
| `discovery` | `sdd/discoverer` | |
| `tasks` | `sdd/tasker` (full) or `sdd/quick-tasker` (bug/quick) | Check `Lane` in state |
| `planning` | `sdd/planner` | Pass current task number from state |
| `implementing` | — | Do NOT auto-delegate. Tell user: "Run `/sdd/implement <name> <NN>` to continue implementation." |
| `reconciling` | `sdd/reconciler` | |
| `initialized` | — | Tell user: "Run `/sdd/proposal <name>` to start drafting." |

### 4. Subtask Prompt

Pass to the phase agent:
- Change name
- File paths to read (state, relevant loop file, artifacts)
- Instruction to check `## User Feedback` sections for guidance
- Reminder to append to loop file (not overwrite)

Keep the prompt thin — pass pointers, not content.

### 5. Report Result

After agent returns, summarize what was done and remind user of the feedback loop:
- "Edit `## User Feedback` in `<file>` and run `/sdd/continue` to iterate further."
- Or report next command if phase is complete.

## Example Flow

```
User: /sdd/continue
Forge: I found one active change: `habit-tracker`. Resuming ideation phase.
       [delegates to sdd/ideator]
Ideator: [reads loops/ideation.md, sees user feedback, appends new turn]
Forge: Ideator responded. Review `loops/ideation.md` and edit `## User Feedback` to continue, or ask ideator to write the seed when you're ready.
```

## Gate Enforcement

This command does NOT enforce phase gates — it simply re-runs the current phase. Gate enforcement happens when advancing phases (e.g., `/sdd/proposal` checks for seed if in ideation).
