---
description: Prime LLM with all spec files for a change
argument-hint: <change-set-name>
---

# Spec Context for Change: $1

Load all spec files for the given change set to provide planning context.

## Instructions

1. Use `view` to read all spec files in `changes/$1/specs/` directory
2. Display each file with its path as a header
3. After loading, respond "Got it." to confirm the specs are in context

## Usage

This command primes the conversation with spec context before planning or implementation. Run it when:

- Starting `/sdd/plan` for a change that has specs
- Resuming work on a change set with existing specs
- Needing to reference specs during implementation

## Example

```
/sdd/tools/prime-specs add-user-auth
```

This loads all specs from `changes/add-user-auth/specs/` into the conversation context.
