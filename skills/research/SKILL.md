---
name: research
description: When and how to research the codebase via the librarian agent
---

# Research - Codebase Discovery via Librarian

This skill covers when and how to use the librarian agent for codebase research and discovery.

## When to Research

Research the codebase when you need to:

- **Understand existing patterns** before proposing new ones
- **Find integration points** for new functionality
- **Locate relevant files** for a change
- **Understand how something works** before modifying it
- **Verify assumptions** about codebase structure
- **Find similar implementations** to follow established patterns

## The Librarian

The `librarian` agent is the universal research agent. It:

- Clarifies what you're looking for
- Performs fast reconnaissance and deep codebase analysis exhaustively
- Returns structured, comprehensive findings
- Determines when research is complete

When doing SDD work, prefer using the `librarian` agent for codebase research so you follow existing patterns and avoid missed context.

## How to Consult Librarian

Consult the `librarian` agent with a clear research prompt (the runtime will route this appropriately):

```
<your research question>
```

### Good Research Prompts

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

### What Librarian Returns

Librarian provides:

1. **Summary** - Direct answer to your question
2. **Key Sources** - Important file paths with annotations
3. **Explanation** - How pieces connect
4. **Evidence** - Specific citations (`path/file:line`)
5. **Next Steps** - What to investigate further (if needed)

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

## Iterating with Librarian

If librarian's first response doesn't fully answer your question:

1. **Ask a follow-up** - Be more specific about what's missing
2. **Narrow the scope** - Focus on one aspect at a time
3. **Provide context** - Share what you learned so far

Example iteration:

```
# First query
"How does authentication work in this codebase?"

# Librarian returns high-level overview

# Follow-up query
"Thanks. Now specifically, how are JWT tokens validated? I need to add a new claim check."
```

## When NOT to Research

Skip librarian when:

- You already know the file paths and patterns
- The change is isolated and well-understood
- You're following an existing plan that already did the research
- The task is purely about SDD artifacts (state.md, proposal.md, etc.)

## Research First, Then Act

For any non-trivial codebase change:

1. **Research first** - Understand before modifying
2. **Document findings** - Capture relevant paths and patterns in your plan
3. **Then implement** - With confidence about where and how
