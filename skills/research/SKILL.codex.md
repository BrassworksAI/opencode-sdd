---
name: research
description: Research the codebase using Codex tools (no subagents)
---

# Research - Codebase Discovery (Codex)

This skill covers how to research the codebase directly using Codex tools.

## When to Research

Research the codebase when you need to:

- **Understand existing patterns** before proposing new ones
- **Find integration points** for new functionality
- **Locate relevant files** for a change
- **Understand how something works** before modifying it
- **Verify assumptions** about codebase structure
- **Find similar implementations** to follow established patterns

## How to Research (Codex)

Use available Codex tools to inspect the repository directly. Do not rely on background agents.

1. **Clarify the question**: restate what you're looking for and any constraints.
2. **Locate candidates**:
   - Use ripgrep (`rg`) to find symbols, filenames, or patterns.
   - Use `rg --files` or `find` to scan for relevant file types.
3. **Read the sources**:
   - Open the most relevant files and read only what you need.
   - Prefer primary sources in the repo over inference.
4. **Synthesize findings**:
   - Summarize the pattern and list key file paths with short notes.
   - Quote or cite exact paths and lines if the runtime supports it.

## Good Research Prompts

Be specific about what you need:

```
# Finding files/locations
"Where are the authentication handlers in this codebase?"

# Understanding patterns
"How does this codebase handle error responses? Show me the pattern."

# Finding integration points
"I need to add a new API endpoint for user preferences. Where should it go and what patterns should it follow?"

# Understanding flows
"Trace how a request flows from the API route to the database for user creation."

# Finding similar implementations
"Find examples of form validation in this codebase so I can follow the same pattern."
```

## Research Patterns by Phase

### During Proposal

Research to understand:
- Does similar functionality exist?
- What would this change interact with?
- Are there patterns to follow or constraints to respect?

### During Specs

Research to understand:
- Where do existing specs live?
- What's the current spec taxonomy?
- Are there related capabilities already specified?

### During Discovery

Research to understand:
- How does the proposed change fit existing architecture?
- What code will be affected?
- Are there conflicts with existing patterns?

### During Planning

Research to understand:
- Exact file paths for changes
- Current implementation details
- Test patterns to follow
- Integration points

### During Implementation

Research when you encounter:
- Unexpected code structure
- Need to understand a dependency
- Unclear how to integrate with existing code

## Iterating

If your first pass doesn't fully answer the question:

1. **Ask a follow-up** - Be more specific about what's missing
2. **Narrow the scope** - Focus on one aspect at a time
3. **Provide context** - Share what you learned so far

Example iteration:

```
# First query
"How does authentication work in this codebase?"

# Follow-up query
"Thanks. Now specifically, how are JWT tokens validated? I need to add a new claim check."
```

## When NOT to Research

Skip research when:

- You already know the file paths and patterns
- The change is isolated and well-understood
- You're following an existing plan that already did the research
- The task is purely about SDD artifacts (state.md, proposal.md, etc.)

## Research First, Then Act

For any non-trivial codebase change:

1. **Research first** - Understand before modifying
2. **Document findings** - Capture relevant paths and patterns in your plan
3. **Then implement** - With confidence about where and how
