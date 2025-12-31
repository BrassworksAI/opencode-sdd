---
name: spec-format
description: How to write SDD specifications - delta format, SHALL language, requirement structure
---

# Spec Format

This skill covers how to write and structure SDD specifications.

## Spec File Structure

Specs live in `specs/` at the repository root, organized by domain:

```
specs/
  <domain>/
    <subdomain>/
      <capability>.md
```

## Capability Spec Format

Each capability spec follows this structure:

```markdown
# <Capability Name>

## Overview

Brief description of what this capability does and why it exists.

## Requirements

### <REQ-ID>: <Requirement Title>

The system SHALL <requirement in active voice>.

**Rationale:** Why this requirement exists.

**Acceptance Criteria:**
- <Testable criterion>
- <Testable criterion>
```

## Delta Spec Format

When modifying specs during a change set, create delta specs in `changes/<name>/specs/`:

```
changes/<name>/specs/
  <domain>/
    <capability>.md
```

Delta specs use Before/After blocks to show changes:

### Adding a New Requirement

```markdown
### <REQ-ID>: <New Requirement Title>

> **ADDED**

The system SHALL <new requirement>.

**Rationale:** <Why this is needed>

**Acceptance Criteria:**
- <Criterion>
```

### Modifying an Existing Requirement

```markdown
### <REQ-ID>: <Requirement Title>

> **MODIFIED**

**Before:**
The system SHALL <old text>.

**After:**
The system SHALL <new text>.

**Rationale:** <Why the change>
```

### Removing a Requirement

```markdown
### <REQ-ID>: <Requirement Title>

> **REMOVED**

**Reason:** <Why this requirement is being removed>
```

## SHALL Language

Requirements use RFC 2119 language:

- **SHALL** - Absolute requirement
- **SHALL NOT** - Absolute prohibition
- **SHOULD** - Recommended but not required
- **SHOULD NOT** - Discouraged but not prohibited
- **MAY** - Optional

Prefer SHALL for most requirements. Use SHOULD/MAY sparingly and with clear rationale.

## Requirement IDs

Format: `<DOMAIN>-<NUMBER>`

Examples:
- `AUTH-001`: First auth requirement
- `PAY-042`: 42nd payment requirement

IDs are stable - never reuse a removed ID.

## Writing Good Requirements

1. **One requirement per SHALL** - Don't combine multiple requirements
2. **Active voice** - "The system SHALL validate" not "Validation shall be performed"
3. **Testable** - Every requirement must have clear acceptance criteria
4. **Implementation-agnostic** - Describe WHAT, not HOW
5. **No ambiguity** - Avoid words like "appropriate", "reasonable", "user-friendly"

## Flat vs Grouped Delta Specs

**Flat:** One delta file per modified capability (default)
```
changes/<name>/specs/auth/login.md
changes/<name>/specs/auth/logout.md
```

**Grouped:** Multiple related changes in one file (for tightly coupled changes)
```
changes/<name>/specs/auth/session-management.md  # covers login + logout + refresh
```

Use grouped only when changes are truly interdependent and reviewing separately would lose context.
