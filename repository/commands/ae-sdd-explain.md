---
description: Explain SDD concepts and workflow
---

# Explain SDD

## Required Skills (Must Load)

You MUST load and follow these skills before doing anything else:

- `spec-format`
- `sdd-state-management`
- `research`

If any required skill content is missing or not available in context, you MUST stop and ask the user to re-run the command or otherwise provide the missing skill content. Do NOT proceed without them.

Explain SDD concepts, workflow, or specific phases to help users understand the system.

## Inputs

- Topic to explain (optional). Ask the user if they want a specific topic.

## Instructions

### FIRST: Check for a Specific Topic

**If the user requests a specific topic**: Skip directly to "Specific Topic" section below. Do NOT output the full overview.

**If no specific topic is requested**: Output the full overview below.

---

### Full Overview (only when no argument provided)

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

```text
changes/
  add-user-auth/           # Change set directory
    state.md               # Lane, phase, phase status, notes, pending
    proposal.md            # What we're building and why (authored outside SDD, read when present)
    specs/                 # Change-set specs (full lane only; `kind: new|delta`)
      api.md
      components.md
    tasks.md               # Ordered implementation tasks
    plans/                 # Per-task implementation plans
      01.md
      02.md
```

#### Three Lanes

| Lane | When to Use | Flow |
|------|-------------|------|
| **Full** | New features, architectural changes | Specs first, then implement |
| **Vibe** | Prototypes, experiments, quick enhancements | Implement first, specs later (if keeping) |
| **Bug** | Defect fixes | Fix first, spec impact assessed at reconcile |

The key insight: **Full lane** writes specs before implementation. **Vibe/Bug lanes** invert this - implement first, capture specs from the diff at reconcile (if the work is worth keeping).

#### Phase Progression

**Full Lane** (specs drive implementation):

```text
init -> proposal -> specs -> discovery -> tasks -> plan -> implement -> reconcile -> finish
```

Ideation and proposal artifacts are often created outside SDD. SDD simply tracks the phase and reads `seed.md`/`proposal.md` if they exist.

**Vibe Lane** (freedom to explore):

```text
/sdd/fast/vibe <context> -> plan -> implement -> [reconcile -> finish]
```

**Bug Lane** (fix with triage):

```text
/sdd/fast/bug <context> -> plan -> implement -> [reconcile -> finish]
```

Vibe/Bug lanes have optional completion - if throwing away the work, stop after implement. If keeping, reconcile captures specs from what was built.

#### Key Commands

| Command | Purpose |
|---------|---------|
| `/sdd/init <name>` | Start a new change set (full lane) |
| `/sdd/fast/vibe <context>` | Start vibe lane - exploration mode |
| `/sdd/fast/bug <context>` | Start bug lane - fix with triage |
| `/sdd/specs` | Write change-set specifications (full lane) |
| `/sdd/discovery` | Verify specs fit repo architecture |
| `/sdd/tasks` | Generate implementation tasks (full lane) |
| `/sdd/plan` | Create implementation plan |
| `/sdd/implement` | Execute current plan |
| `/sdd/reconcile` | Verify implementation, capture specs if needed |
| `/sdd/finish` | Close the change set |
| `/sdd/status` | Show current state |

#### Example: Vibe Lane Flow

```text
User: /sdd/fast/vibe "I want to try a new caching approach for the API layer"
      [Creates context.md with freeform exploration context]

User: /sdd/plan
      [Creates single plan.md combining research + implementation steps]

User: /sdd/implement
      [Executes plan, makes changes, iterates freely]

# If throwing away: DONE - no further steps needed

# If keeping the work:
User: /sdd/reconcile
      [Reviews diff, captures change-set specs from implementation]

User: /sdd/finish
      [Change set closed; `kind: new` specs moved, `kind: delta` specs merged to canonical]
```

#### Example: Bug Lane Flow

```text
User: /sdd/fast/bug "Users are seeing 500 errors when submitting forms with special characters"
      [Triages: actual bug or behavioral change?]
      [If behavioral change -> redirects to full lane]
      [If bug -> researches, creates context.md with root cause]

User: /sdd/plan
      [Creates single plan.md with fix approach]

User: /sdd/implement
      [Applies fix, validates]

# If one-off fix: DONE

# If keeping for spec update:
User: /sdd/reconcile
      [Assesses spec impact, updates if warranted]

User: /sdd/finish
```

#### Example: Full Lane Flow

```text
User: /sdd/init add-plugin-system
User: (Drafts proposal.md using preferred method)
      "Add a plugin architecture to allow extending functionality"

User: /sdd/specs
      [Forge writes change-set specs defining interfaces, behaviors]

User: /sdd/discovery
      [Uses architecture-fit-check skill to verify specs fit existing architecture]

User: /sdd/tasks
      [Generates tasks from change-set specs]

User: /sdd/plan -> /sdd/implement (for each task)

User: /sdd/reconcile
      [Verifies implementation satisfies all spec requirements]

User: /sdd/finish
```

---

### Specific Topic (when a topic is requested)

When the user provides a topic, explain **only that topic** in depth. Do not output the full overview above.

Use this format for the topic:

1. **What it is** - Clear definition
2. **Why it exists** - The problem it solves
3. **How it works** - Mechanics and structure
4. **Example** - Concrete illustration
5. **Common questions** - Anticipate confusion points

#### Known Topics

| Topic | What to Explain |
|-------|-----------------|
| `phases` | Each phase in detail, what happens, gates between them |
| `lanes` | Full vs vibe vs bug - when to use each, spec relationship |
| `specs` | Change-set spec format (`kind: new|delta`), EARS syntax, Before/After blocks |
| `tasks` | Task format, checkboxes, requirements sections (full lane) |
| `plans` | Plan structure - per-task for full lane, single plan.md for vibe/bug |
| `reconcile` | What reconciliation checks, spec capture for vibe/bug |
| `state` | state.md structure (lane, phase, phase status, notes), flexible progression |
| `commands` | All available commands and when to use them |
| `forge` | How Forge works as SDD workshop |
| `tools` | `/sdd/tools/*` commands for critique, scenario testing, taxonomy |
| `skills` | Architecture-fit-check and architecture-workshop frameworks |

If the topic doesn't match a known topic exactly, interpret the user's intent and explain the relevant concept.

### Research if Needed

If the user asks about something implementation-specific (e.g., "how does reconciliation actually compare specs to code?"), use the `research` skill to investigate the codebase for accurate details rather than guessing.
