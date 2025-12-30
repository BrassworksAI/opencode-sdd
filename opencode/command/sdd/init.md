---
description: Initialize a new SDD change set folder
agent: sdd/forge
---

Initialize an SDD change set.

## Usage

- `/sdd/init <change-name>`

## Requirements

- `<change-name>` is required.
- `<change-name>` must be a safe folder name (recommend kebab-case). Reject path separators.

## What to do (forge)

1. Create the folder structure:
   - `changes/<change-name>/`
   - `changes/<change-name>/specs/`
   - `changes/<change-name>/thoughts/`
   - `changes/<change-name>/plans/`
   - `changes/<change-name>/loops/`

2. Create `changes/<change-name>/state.md` with:

```markdown
# SDD State: <change-name>

## Phase

initialized

## Lane

full

## Run Mode

manual

## Current Task

none

## Proposal

- Status: draft

## Reconcile

- Required: yes
- Status: pending

## Pointers

- Proposal: `proposal.md`
- Specs: `specs/**`
- Discovery: `thoughts/**`
- Tasks: `tasks.md`
- Plans: `plans/**`

## Taxonomy Decisions


## Architecture Decisions


## Finish Status

not-ready

## Notes


```

3. Report the next recommended command: `/sdd/proposal <change-name>`.
