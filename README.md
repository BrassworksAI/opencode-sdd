# Agent Extensions for AI Coding Assistants

**Speed without direction is just chaos with velocity.**

AI writes the code now. SDD (Spec-Driven Development) makes sure it's the right code—capturing intent before implementation so you don't lose track of what's actually in your codebase.

## Supported Tools

- **[OpenCode](https://opencode.ai)** - The open-source AI coding assistant
- **[Augment](https://www.augmentcode.com/)** (Auggie) - The Augment CLI agent

Both tools get the same SDD workflow, adapted to their respective conventions.

## How It Works

SDD breaks work into phases: proposal, specs, discovery, tasks, planning, implementation, reconciliation. Sounds heavy. In practice, an AI agent handles each phase—you're reviewing and steering in conversation, not writing documents.

Everything happens in the chat. Don't like what the agent produced? Just say so. It revises the artifacts while keeping them clean. No feedback sections cluttering your specs, no special syntax to learn. The conversation is the feedback loop.

The system catches drift before it ships. Discovery flags architecture conflicts before you've written code. Reconciliation at the end validates that what got built actually matches what you intended. If the implementation wandered, you'll know—and you'll have specs to point at.

You stay in control without doing the busywork. The agent handles the decomposition, the planning, the implementation. You handle the "is this actually what we want?" question. That's the job now.

## Think Bigger

Scrum taught us to think small. Break everything into bite-sized tickets because that's all a human can safely hold. Keep changes tiny because big changes are terrifying when three people understand the system.

AI doesn't have that limitation. Through this process, agents can reason about entire features—see patterns that only make sense when you're looking at the whole picture, even as context flows across phases.

SDD lets you work at the capability level, not the ticket level. Describe what you want the system to do—the agents figure out how to break it down, what order to build it, which files to touch. You're not managing a backlog of micro-tasks. You're defining outcomes and validating that they landed correctly.

This is vibe coding's ambition with enterprise rigor. Think big, stay traceable.

## Installation

### Prerequisites

Install at least one of:
- [OpenCode](https://opencode.ai/docs/#install)
- [Augment CLI](https://www.augmentcode.com/)

### macOS / Linux

```sh
curl -fsSL https://raw.githubusercontent.com/BrassworksAI/agent-extensions/main/install.sh | sh
```

The installer will ask which tool(s) to install for (OpenCode, Augment, or both) and where to install (global or local to current repo).

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/BrassworksAI/agent-extensions/main/install.ps1 | iex
```

### Install Locations

| Tool | Global | Local |
|------|--------|-------|
| OpenCode | `~/.config/opencode/` | `.opencode/` |
| Augment | `~/.augment/` | `.augment/` |

### Uninstall

```sh
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/BrassworksAI/agent-extensions/main/uninstall.sh | sh
```

```powershell
# Windows
irm https://raw.githubusercontent.com/BrassworksAI/agent-extensions/main/uninstall.ps1 | iex
```

The uninstaller removes only the exact files installed by agent-extensions, leaving your other customizations intact.

## Getting Started

After installation, run your AI coding assistant and try:

```
/sdd/explain
```

This walks you through the full workflow, what each phase produces, and how to get started. You can also run `/sdd/explain <phase>` for details on any specific phase.

Or jump straight in:

```
/sdd/init my-feature            # Start a new feature (full lane)
/sdd/fast/bug fix-login         # Fast lane for bug fixes
/sdd/fast/vibe try-something    # Rapid prototyping
```

## Three Lanes

| Lane | When to Use | Flow |
|------|-------------|------|
| **Full** | New features, architectural changes | Specs first, then implement |
| **Vibe** | Prototypes, experiments | Implement first, capture specs later (if keeping) |
| **Bug** | Defect fixes | Fix first, assess spec impact at reconcile |

## Commands

### Core Workflow

| Command | Description |
|---------|-------------|
| `/sdd/init <name>` | Start a new change set (full lane) |
| `/sdd/proposal <name>` | Draft or refine the proposal |
| `/sdd/specs <name>` | Write delta specifications |
| `/sdd/discovery <name>` | Review specs against architecture |
| `/sdd/tasks <name>` | Generate implementation tasks |
| `/sdd/plan <name>` | Plan current task |
| `/sdd/implement <name>` | Execute the plan |
| `/sdd/reconcile <name>` | Verify implementation matches specs |
| `/sdd/finish <name>` | Close the change set |

### Fast Lanes

| Command | Description |
|---------|-------------|
| `/sdd/fast/vibe <context>` | Quick prototyping - skip specs, start building |
| `/sdd/fast/bug <context>` | Bug investigation and fix |

### Utilities

| Command | Description |
|---------|-------------|
| `/sdd/status [name]` | Show status of change sets |
| `/sdd/continue <name>` | Resume work on existing change set |
| `/sdd/explain [topic]` | Explain SDD concepts |
| `/sdd/brainstorm <name>` | Explore problem space |

### Tools

| Command | Description |
|---------|-------------|
| `/sdd/tools/critique [target]` | Critique proposal, specs, or plan |
| `/sdd/tools/scenario-test [name]` | Roleplay as user to stress-test design |
| `/sdd/tools/taxonomy-map <name>` | Map intents to spec paths |
| `/sdd/tools/prime-specs <name>` | Load specs into context |

### Meta

| Command | Description |
|---------|-------------|
| `/create/agent <spec>` | Create a new agent |
| `/create/command <spec>` | Create a new command |

## Development Install

For contributors who want to edit files while having them active:

```sh
git clone git@github.com:BrassworksAI/agent-extensions.git && cd agent-extensions
./dev-install.sh
```

Creates symlinks so edits to the repo files are immediately reflected. macOS/Linux only.

## Repository Structure

```
agent-extensions/
├── opencode/           # OpenCode extensions
│   ├── agent/          # Agent definitions
│   ├── command/        # Command definitions
│   └── skill/          # Skill definitions
├── augment/            # Augment extensions
│   ├── agents/         # Agent definitions
│   ├── commands/       # Command definitions
│   └── skills/         # Skill files
├── install.sh          # macOS/Linux installer
├── install.ps1         # Windows installer
├── dev-install.sh      # Development symlink installer
├── uninstall.sh        # macOS/Linux uninstaller
└── uninstall.ps1       # Windows uninstaller
```

## Learn More

Read [THE_CASE_FOR_SPECS.md](./THE_CASE_FOR_SPECS.md) for the story of how an AI came to understand why it needed the harness.
