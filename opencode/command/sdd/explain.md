---
name: sdd/explain
description: Explain SDD concepts and workflow
agent: sdd/forge
---

# Explain SDD

<skill>spec-format</skill>
<skill>sdd-state-management</skill>
<skill>counsel</skill>
<skill>research</skill>

Explain SDD concepts, workflow, or specific phases to help users understand the system.

## Arguments

- `$ARGUMENTS` - Topic to explain (optional)

## Instructions

### No Arguments - Full Overview

Provide a comprehensive explanation of SDD:

---

**Spec-Driven Development (SDD)** is a disciplined approach where specifications drive implementation. The core principle: *define what you're building before building it*.

#### Why SDD?

- **Clarity**: Specs force you to think through requirements before coding
- **Traceability**: Every implementation decision traces back to a spec
- **Verification**: Reconciliation ensures code matches intent
- **Collaboration**: Specs are a shared contract between human and AI

#### The Change Set

Everything in SDD revolves around a **change set** - a named collection of files tracking one logical change:

```
changes/
  add-user-auth/           # Change set directory
    state.md               # Current phase, lane, gates passed
    proposal.md            # What we're building and why
    specs/                 # Delta specs (full lane only)
      api.md
      components.md
    tasks.md               # Ordered implementation tasks
    plans/                 # Per-task implementation plans
      01.md
      02.md
```

#### Three Lanes

| Lane | When to Use | What's Required |
|------|-------------|-----------------|
| **Full** | New features, architectural changes | Proposal -> Specs -> Tasks -> Plans -> Implement -> Reconcile |
| **Quick** | Small enhancements, refactors | Proposal -> Tasks -> Plans -> Implement |
| **Bug** | Defect fixes | Proposal -> Tasks -> Plans -> Implement |

#### Phase Progression

**Full Lane:**
```
init -> proposal -> specs -> discovery -> tasks -> plan -> implement -> reconcile -> finish
```

**Quick/Bug Lane:**
```
init -> proposal -> tasks -> plan -> implement -> finish
```

#### Key Commands

| Command | Purpose |
|---------|---------|
| `/sdd/init <name>` | Start a new change set |
| `/sdd/brainstorm` | Explore problem space before proposing |
| `/sdd/proposal` | Draft/refine the proposal |
| `/sdd/specs` | Write delta specifications (full lane) |
| `/sdd/discovery` | Verify specs fit repo architecture |
| `/sdd/tasks` | Generate implementation tasks |
| `/sdd/plan` | Create plan for current task |
| `/sdd/implement` | Execute current plan |
| `/sdd/reconcile` | Verify implementation matches specs |
| `/sdd/finish` | Close the change set |
| `/sdd/status` | Show current state |
| `/sdd/continue` | Resume where you left off |

#### Example: Quick Lane Flow

```
User: /sdd/init improve-error-messages
User: /sdd/proposal
      "I want to improve error messages in the CLI to be more helpful"
      [Forge helps draft proposal.md, sets lane: quick]

User: /sdd/tasks
      [Forge generates tasks.md with ordered checkboxes]

User: /sdd/plan
      [Forge writes plans/01.md for first unchecked task]

User: /sdd/implement
      [Forge executes plan, edits code, marks task complete]

User: /sdd/plan -> /sdd/implement (repeat for remaining tasks)

User: /sdd/finish
      [Change set closed]
```

#### Example: Full Lane Flow

```
User: /sdd/init add-plugin-system
User: /sdd/proposal
      "Add a plugin architecture to allow extending functionality"
      [Forge helps draft proposal.md, sets lane: full]

User: /sdd/specs
      [Forge writes delta specs defining interfaces, behaviors]

User: /sdd/discovery
      [Forge + Steward verify specs fit existing architecture]

User: /sdd/tasks
      [Forge generates tasks from delta specs]

User: /sdd/plan -> /sdd/implement (for each task)

User: /sdd/reconcile
      [Forge verifies implementation satisfies all spec requirements]

User: /sdd/finish
```

---

### Specific Topics

When user asks about a specific topic, explain in depth:

| Topic | What to Explain |
|-------|-----------------|
| `phases` | Each phase in detail, what happens, gates between them |
| `lanes` | Full vs quick vs bug - when to use each, what's skipped |
| `specs` | Delta spec format, SHALL requirements, Before/After blocks |
| `tasks` | Task format, checkboxes, requirements sections, validation |
| `plans` | Plan structure, context, steps, verification |
| `reconcile` | What reconciliation checks, how drift is detected |
| `state` | state.md structure, gates, how progression works |
| `commands` | All available commands and when to use them |
| `forge` | How Forge works as the SDD workshop |
| `specialists` | When Archimedes/Steward/Daedalus/Cartographer are consulted |

### Response Format

For any topic:
1. **What it is** - Clear definition
2. **Why it exists** - The problem it solves
3. **How it works** - Mechanics and structure
4. **Example** - Concrete illustration
5. **Common questions** - Anticipate confusion points

### Research if Needed

If the user asks about something implementation-specific (e.g., "how does reconciliation actually compare specs to code?"), use librarian to research the codebase for accurate details rather than guessing.
