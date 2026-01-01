---
name: counsel
description: When and how to consult SDD specialist agents (Archimedes, Loki, Steward, Daedalus, Cartographer)
---

# Counsel - Consulting SDD Specialists

This skill covers when and how to consult the five SDD specialist agents.

## The Five Specialists

| Agent | Role | Subagent Type |
|-------|------|---------------|
| **Archimedes** | Thoughtful critic - stress-tests ideas analytically | `archimedes` |
| **Loki** | Scenario roleplayer - stress-tests by inhabiting user personas | `sdd/loki` |
| **Steward** | Architecture fit checker | `sdd/steward` |
| **Daedalus** | Paradigm inventor | `sdd/daedalus` |
| **Cartographer** | Taxonomy mapper | `sdd/cartographer` |

## Consultation Pattern

All consultations are **fire-and-forget**:

1. Prepare context (what they need to know)
2. Send via Task tool with specific question
3. Receive findings
4. Synthesize into your work

## When to Consult Each

### Archimedes (Critic)

**Consult when:**
- Proposal is drafted and needs analytical stress-testing
- Specs are complete and need gap analysis
- You're unsure if an approach has hidden flaws
- User wants their thinking challenged logically

**Example prompt:**
```
Review this proposal for gaps, contradictions, and unstated assumptions:

<proposal content>

Return:
1. Contradictions found
2. Missing cases
3. Risk flags
4. Verdict: PASS/FAIL with required fixes
```

### Loki (Scenario Roleplayer)

**Consult when:**
- Proposal needs validation against realistic user workflows
- You want to test if a design holds up under actual use
- Checking for gaps that logical analysis might miss
- User wants to see how the proposal feels "in practice"

Loki is complementary to Archimedes: Archimedes critiques from the outside (logical analysis), Loki tests from the inside (lived experience as a user). Use both for thorough proposal validation.

**Example prompt:**
```
Scenario-test this proposal by inhabiting a realistic user persona:

<proposal content>

Assume the role of a demanding but fair user at a fictional company. 
Pick a concrete task that touches on this proposal and attempt to complete it.

Return:
1. The persona you inhabited (role, constraints, task)
2. The journey (what you attempted, what worked, where you got stuck)
3. Findings categorized as: Gaps, Friction, Ambiguities, Loopholes, Wins
4. Verdict: Did you complete your task? Can you rest easy, or are you frustrated?
5. Suggestions (if any) for addressing what you found
```

### Steward (Architecture)

**Consult when:**
- Changes might conflict with existing codebase patterns
- Adding new capabilities that must integrate with existing code
- Unsure if proposed approach fits repository conventions
- Discovery phase needs architecture review

**Example prompt:**
```
Review these proposed changes against the repository architecture:

<proposed changes summary>

Analyze:
1. Does this fit existing patterns?
2. Are there conflicts with current conventions?
3. What existing code will this interact with?

Return fit assessment and any concerns.
```

### Daedalus (Paradigm Inventor)

**Consult when:**
- Existing patterns don't fit the problem
- Steward flagged concerns but you still need a solution
- Need to propose new architectural mechanisms
- Facing a novel problem that requires creative structural thinking

**Example prompt:**
```
Existing patterns don't fit this problem:

<problem description>
<why existing patterns fail>

Propose a new mechanism or structural approach that:
1. Solves the problem
2. Could become a reusable pattern
3. Integrates with existing architecture
```

### Cartographer (Taxonomy)

**Consult when:**
- Adding new capabilities and unsure where they belong in spec hierarchy
- Reorganizing spec structure
- Need to understand how a change relates to existing spec taxonomy
- Specs phase needs path determination

**Example prompt:**
```
I'm adding this capability:

<capability description>

Current spec structure:
<relevant parts of specs/ tree>

Where should this capability live in the taxonomy? Return:
1. Recommended path
2. Rationale
3. Related existing capabilities
```

## Consultation Guidelines

1. **Be specific** - Vague questions get vague answers
2. **Provide context** - Include relevant artifacts and background
3. **Ask for structured output** - Specify what format you need back
4. **One concern per consultation** - Don't overload
5. **Trust but verify** - Specialists are advisory; you make final decisions

## When NOT to Consult

- Routine phase transitions (just follow the process)
- Clear-cut decisions (don't consult for validation theater)
- Quick/bug lane unless something seems off
- When user explicitly wants to skip review
