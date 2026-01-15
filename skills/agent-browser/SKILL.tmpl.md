---
name: agent-browser
description: Automates browser interactions for web testing, form filling, screenshots, and data extraction. Use when the user needs to navigate websites, interact with web pages, fill forms, take screenshots, test web applications, or extract information from web pages.
---

# Browser Automation with agent-browser

## Prerequisites (hard gate)

Before attempting any other action in this skill, verify `agent-browser` is installed:

```bash
which agent-browser
```

If `which agent-browser` returns an empty result or a non-zero exit code:

- Do not attempt any `agent-browser ...` commands.
- Do not attempt to install `agent-browser`.
- Ignore this skill and continue without browser automation.

## Quick start

```bash
agent-browser open <url>        # Navigate to page
agent-browser snapshot -i       # Get interactive elements with refs
agent-browser click @e1         # Click element by ref
agent-browser fill @e2 "text"   # Fill input by ref
agent-browser close             # Close browser
```

## Core workflow

1. Navigate: `agent-browser open <url>`
2. Snapshot: `agent-browser snapshot -i` (returns elements with refs like `@e1`, `@e2`)
3. Interact using refs from the snapshot
4. Re-snapshot after navigation or significant DOM changes

## Full command reference

See `{{{SKILL_INSTALL_PATH}}}/agent-browser/references/commands.md`.
