---
name: sdd-loop-ledger-format
description: Standardized format for SDD loop ledger files (changes/<name>/loops/*.md)
---

# Loop Ledger Format

Loop ledgers are append-only turn logs that enable multi-turn collaboration across agent invocations. They serve as a bridge for subagent conversations and provide audit trails.

## Purpose

- **Stateless handoffs**: Context for re-runs and session resumption
- **Audit trail**: Record of decisions and iterations
- **User feedback bridge**: Mechanism for user to guide iterations without direct subagent chat

## File Locations

| Phase | Loop Ledger Path |
|-------|------------------|
| Ideation | `changes/<name>/loops/ideation.md` |
| Proposal | `changes/<name>/loops/proposal.md` |
| Specs | `changes/<name>/loops/specs.md` |
| Discovery | `changes/<name>/loops/discovery.md` |
| Tasks | `changes/<name>/loops/tasks.md` |
| Plan (per task) | `changes/<name>/loops/plan-<NN>.md` |
| Implement (per task) | `changes/<name>/loops/implement-<NN>.md` |
| Reconcile | `changes/<name>/loops/reconcile.md` |

## Invariants (Required)

Every loop ledger entry MUST end with:

1. **User Feedback section** — A place for the user to write guidance
2. **Separator** — `---` to delimit turns

```markdown
## User Feedback

(Leave blank to continue. Write notes here to guide the next iteration.)

---
```

This is the contract that enables `/sdd/continue` to work: the user edits the feedback section, then reruns the phase.

## Structure (Flexible)

Within each turn, agents MAY structure their content however is useful:
- Summaries of work done
- Questions for the user
- Archimedes critique (if invoked)
- Decisions made
- Open issues

There is **no required internal structure** beyond the User Feedback + separator invariants.

### Example Turn (Freeform)

```markdown
# Ideation Loop

## Turn 1

Explored the core problem space. You're building a habit tracker with offline-first as a hard constraint.

Key things I heard:
- Privacy is non-negotiable (no cloud sync of personal data)
- You want streaks but are worried about the "guilt trap" pattern
- Mobile-first, but needs to work on desktop too

Questions I have:
- How important is cross-device sync if we can't use cloud? Local network only?
- What's your take on notifications? Helpful reminders vs annoying nags?

I consulted Archimedes on the offline-first constraint — he thinks it's solid but flagged that conflict resolution gets tricky if you ever add sync later. Worth keeping in mind.

## User Feedback

(Leave blank to continue. Write notes here to guide the next iteration.)

---
```

### Example Turn (Structured Critique)

If an agent wants to record structured critique (e.g., from Archimedes), that's fine:

```markdown
## Turn 2

Revised the proposal based on your feedback about notification preferences.

### Archimedes Critique

**Contradictions**: None  
**Missing Cases**: What happens if user misses multiple days?  
**Risk Flags**: Streak reset logic could feel punishing  
**Suggestions**: Consider "grace days" or degraded streaks instead of hard reset

### Changes Made

- Added grace day concept to goals
- Softened streak reset language

## User Feedback

(Leave blank to continue. Write notes here to guide the next iteration.)

---
```

## Boundedness Policy

Loop ledgers themselves are unbounded — you can have as many turns as needed.

**Internal critique/revision cycles** (agent self-revising before asking for user feedback) should be bounded to prevent runaway loops:

| Run Mode | Internal Cycle Cap | Behavior |
|----------|-------------------|----------|
| `manual` | Soft guidance: 2-3 | Agent uses judgment; can do more if genuinely improving |
| `auto` | Hard cap: 3 | Must stop after 3 internal cycles and either accept current state or escalate |

This cap applies to *internal* iterations (agent revising before writing a turn), not to the total number of turns in the ledger.

## Re-run Context

When a phase is re-run after user feedback:

1. Agent reads existing `loops/<phase>.md`
2. Finds the most recent `## User Feedback` section
3. Uses that feedback to guide the next iteration
4. Appends a new turn (does not overwrite previous turns)

## Implementation-Specific Ledgers

For `implement-<NN>.md`, include execution details:

```markdown
# Implementation: Task <NN>

## Changes Made

| File | Change |
|------|--------|
| `path/to/file.ts` | Added function X |
| `path/to/test.ts` | Added 3 test cases |

## Validation Results

```bash
$ npm run build
✓ Build succeeded

$ npm test
✓ 47 tests passed
```

## Deviations from Plan

- <deviation and reason, or "None">

## Result

SUCCESS | PARTIAL | FAILED

## User Feedback

(Leave blank to continue. Write notes here to guide the next iteration.)

---
```

## What This Skill Does NOT Require

- ❌ Numbered "Round 1/2" headings
- ❌ PASS/FAIL verdicts as section headers
- ❌ Rigid critique structure
- ❌ Maximum turn counts

Agents should write what's useful. The only hard requirement is the User Feedback + separator contract.
