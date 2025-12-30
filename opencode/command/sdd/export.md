---
description: Export SDD system from current project into global OpenCode config
agent: general
---

Export the SDD system from the current project's `.opencode/` folder into your global OpenCode config (`~/.config/opencode/`).

Use this when you've cloned a repo that has SDD and want to adopt it globally, or when you've made improvements to SDD in a project and want to propagate them to your global config.

## Usage

`/sdd/export`

## What Gets Exported

### Agents

**SDD Agents** (`.opencode/agent/sdd/` → `~/.config/opencode/agent/sdd/`):
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

**Supporting Agents** (`.opencode/agent/` → `~/.config/opencode/agent/`):
- `archimedes.md`
- `librarian.md`

**Search Agents** (`.opencode/agent/search/` → `~/.config/opencode/agent/search/`):
- `scout.md`
- `code.md`

### Commands

**SDD Commands** (`.opencode/command/sdd/` → `~/.config/opencode/command/sdd/`):
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

**SDD Skills** (`.opencode/skill/` → `~/.config/opencode/skill/`):
- `sdd-delta-format/SKILL.md`
- `sdd-task-format/SKILL.md`
- `sdd-quick-task-format/SKILL.md`
- `sdd-plan-format/SKILL.md`
- `sdd-loop-ledger-format/SKILL.md`



## Process

1. Check that we're in a project directory with `.opencode/` containing SDD files
2. Verify the source files exist before copying
3. Create target directories in `~/.config/opencode/` if they don't exist:
   - `~/.config/opencode/agent/`
   - `~/.config/opencode/agent/sdd/`
   - `~/.config/opencode/agent/search/`
   - `~/.config/opencode/command/`
   - `~/.config/opencode/command/sdd/`
   - `~/.config/opencode/skill/`
   - `~/.config/opencode/skill/sdd-delta-format/`
   - `~/.config/opencode/skill/sdd-task-format/`
   - `~/.config/opencode/skill/sdd-quick-task-format/`
   - `~/.config/opencode/skill/sdd-plan-format/`
   - `~/.config/opencode/skill/sdd-loop-ledger-format/`
4. Copy each file from project to global, preserving directory structure
5. Report what was exported

## Conflict Handling

- If a file already exists in global config, **skip it** and report "skipped (exists)"
- Use `--force` argument to overwrite existing files

## Output

Report a summary:
```
SDD Export Complete

Exported to ~/.config/opencode/:
  agent/sdd/forge.md
  agent/sdd/proposer.md
  agent/archimedes.md
  agent/librarian.md
  agent/search/scout.md
  command/sdd/init.md
  skill/sdd-delta-format/SKILL.md

  ...

Skipped (already exist):
  agent/archimedes.md
  ...

Global SDD system updated. Changes will apply to all projects.
```
