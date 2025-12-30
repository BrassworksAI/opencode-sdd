# OpenCode SDD

Spec-Driven Development (SDD) process for [OpenCode](https://opencode.ai).

SDD is a structured approach to implementing features and changes through explicit phases: ideation, proposal, discovery, specs, tasks, planning, and implementation. It ensures architectural consistency and produces traceable, reviewable artifacts at each step.

## Installation

### macOS / Linux

```sh
curl -fsSL https://raw.githubusercontent.com/BrassworksAI/opencode-sdd/main/install.sh | sh
```

### Windows (PowerShell)

```powershell
curl -fsSL https://raw.githubusercontent.com/your-username/opencode-sdd/main/install.ps1 | powershell -NoProfile -ExecutionPolicy Bypass -Command -
```

## What Gets Installed

The installer will prompt you to choose:

1. **Global install** (`~/.config/opencode`) - SDD commands available in all projects
2. **Local install** (`<repo>/.opencode`) - SDD commands available only in the current repository

The following are installed:

- **Agents** - SDD phase agents (forge, proposer, specsmith, tasker, planner, implementer, etc.) plus supporting agents (librarian, search/scout, search/code)
- **Commands** - SDD slash commands (`/sdd/init`, `/sdd/proposal`, `/sdd/specs`, `/sdd/tasks`, `/sdd/plan`, `/sdd/implement`, etc.)
- **Skills** - Format specifications for SDD artifacts (delta specs, tasks, plans, loop ledgers)

## Conflict Handling

If any files already exist at the destination, the installer will:

1. List the conflicting files
2. Ask for confirmation before overwriting
3. Only proceed if you explicitly approve

Back up any customized files before confirming overwrites.

## Usage

After installation, start a new SDD change in OpenCode:

```
/sdd/init my-feature-name
```

Or use the orchestrator to guide you through the process:

```
/sdd/continue
```

## Development Install (Contributors)

If you've cloned the repo and want to edit files while having them active in OpenCode:

```bash
git clone git@github.com:BrassworksAI/opencode-sdd.git
cd opencode-sdd
./dev-install.sh
```

This creates symlinks instead of copying files. Edits in ~/.config/opencode modify the repo directly, so you can commit and push changes.
macOS/Linux only.

## Uninstalling

To remove SDD, delete the installed directories:

**Global:**
```sh
rm -rf ~/.config/opencode/agent/sdd
rm -rf ~/.config/opencode/agent/search
rm ~/.config/opencode/agent/librarian.md
rm ~/.config/opencode/agent/archimedes.md
rm -rf ~/.config/opencode/command/sdd
rm -rf ~/.config/opencode/skill/sdd-*
```

**Local:**
```sh
rm -rf .opencode/agent/sdd
rm -rf .opencode/agent/search
rm .opencode/agent/librarian.md
rm .opencode/agent/archimedes.md
rm -rf .opencode/command/sdd
rm -rf .opencode/skill/sdd-*
```
