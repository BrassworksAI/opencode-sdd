---
description: Install SDD system from global config into current project
agent: general
---

Install the SDD system into the current project by copying agents, commands, and skills from your global config (`~/.config/opencode/`) to the local project (`.opencode/`).

Use this when you want to add SDD to a new project, or to update a project with your latest global SDD config.

## Usage

`/sdd/install`

## What Gets Installed

### Agents

**SDD Agents** (`~/.config/opencode/agent/sdd/` → `.opencode/agent/sdd/`):
- `forge.md`
- `proposer.md`
- `specsmith.md`
- `discoverer.md`
- `tasker.md`
- `quick-tasker.md`
- `planner.md`
- `implementer.md`
- `reconciler.md`
- `finisher.md`
- `cartographer.md`
- `steward.md`
- `daedalus.md`
- `ideator.md`

**Supporting Agents** (`~/.config/opencode/agent/` → `.opencode/agent/`):
- `archimedes.md`
- `librarian.md`

**Search Agents** (`~/.config/opencode/agent/search/` → `.opencode/agent/search/`):
- `scout.md`
- `code.md`

### Commands

**SDD Commands** (`~/.config/opencode/command/sdd/` → `.opencode/command/sdd/`):
- `init.md`
- `status.md`
- `proposal.md`
- `specs.md`
- `discovery.md`
- `tasks.md`
- `plan.md`
- `implement.md`
- `bug.md`
- `quick.md`
- `reconcile.md`
- `finish.md`
- `export.md`
- `install.md`
- `explain.md`
- `brainstorm.md`
- `continue.md`

### Skills

**SDD Skills** (`~/.config/opencode/skill/` → `.opencode/skill/`):
- `sdd-delta-format/SKILL.md`
- `sdd-task-format/SKILL.md`
- `sdd-quick-task-format/SKILL.md`
- `sdd-plan-format/SKILL.md`
- `sdd-loop-ledger-format/SKILL.md`



## Process

1. Check that we're in a project directory (not in `~/.config/opencode`)
2. Create `.opencode/` structure if it doesn't exist:
   - `.opencode/agent/`
   - `.opencode/agent/sdd/`
   - `.opencode/agent/search/`
   - `.opencode/command/`
   - `.opencode/command/sdd/`
   - `.opencode/skill/`
   - `.opencode/skill/sdd-delta-format/`
   - `.opencode/skill/sdd-task-format/`
   - `.opencode/skill/sdd-quick-task-format/`
   - `.opencode/skill/sdd-plan-format/`
   - `.opencode/skill/sdd-loop-ledger-format/`
3. Copy each file from global to local, preserving directory structure
4. Report what was installed

## Conflict Handling

- If a file already exists locally, **skip it** and report "skipped (exists)"
- Use `--force` argument to overwrite existing files

## Output

Report a summary:
```
SDD Install Complete

Installed to .opencode/:
  agent/sdd/forge.md
  agent/sdd/proposer.md
  agent/archimedes.md
  agent/librarian.md
  agent/search/scout.md
  command/sdd/init.md
  command/sdd/export.md
  skill/sdd-delta-format/SKILL.md
  skill/sdd-task-format/SKILL.md

  ...

Skipped (already exist):
  agent/archimedes.md
  ...

Next: Run /sdd/init <name> to start a new change set
```
