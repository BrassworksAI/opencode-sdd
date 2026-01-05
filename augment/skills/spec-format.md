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

## Access

Optional section declaring access level for capabilities that have access control.

> Authenticated

or

> Public

## Dependencies

Optional section listing dependencies on other specs or external systems.

## Entry

Optional section describing how users/systems arrive at this capability.

> **ADDED**

- WHEN a user navigates to <destination> the system SHALL <action>.

## Requirements

Requirements as a bulleted list. Optional grouping headings for organization.

### <Optional Group>

- The system SHALL <requirement in active voice>.
- WHEN <trigger> the system SHALL <action>.

## Exit

Optional section describing how the capability completes or where users end up.

> **ADDED**

- WHEN <action> completes the system SHALL redirect to <destination>.
```

## EARS Syntax

Requirements use EARS (Easy Approach to Requirements Syntax) patterns:

| Pattern | Template | Use When |
|---------|----------|----------|
| Ubiquitous | The system SHALL `<action>`. | Fundamental system properties, always true |
| Event-driven | WHEN `<trigger>` the system SHALL `<action>`. | Response to a specific event |
| State-driven | WHILE `<state>` the system SHALL `<action>`. | Behavior during a particular state |
| Unwanted behavior | IF `<condition>` THEN the system SHALL `<action>`. | Handling errors, failures, edge cases |
| Optional feature | WHERE `<feature>` is present the system SHALL `<action>`. | Behavior tied to optional features |
| Complex | WHEN `<trigger>` IF `<condition>` THEN the system SHALL `<action>`. | Combining patterns |

### Examples

- The system SHALL validate all user input before processing.
- WHEN the user clicks submit the system SHALL save the form data.
- WHILE in maintenance mode the system SHALL reject new connections.
- IF the database connection fails THEN the system SHALL retry with exponential backoff.
- WHERE two-factor auth is enabled the system SHALL require a verification code.

## Delta Spec Format

When modifying specs during a change set, create delta specs in `changes/<name>/specs/`:

```
changes/<name>/specs/
  <domain>/
    <capability>.md
```

Delta specs use markers to show changes:

### Adding New Requirements

```markdown
### <Group>

> **ADDED**

- The system SHALL <new requirement>.
- WHEN <trigger> the system SHALL <action>.
```

### Modifying an Existing Requirement

```markdown
### <Group>

> **MODIFIED**

**Before:**
- The system SHALL <old text>.

**After:**
- The system SHALL <new text>.
```

### Removing a Requirement

```markdown
### <Group>

> **REMOVED**

- The system SHALL <requirement being removed>.

**Reason:** <Why this requirement is being removed>
```

## RFC 2119 Keywords

Requirements use RFC 2119 language:

- **SHALL** - Absolute requirement
- **SHALL NOT** - Absolute prohibition
- **SHOULD** - Recommended but not required
- **SHOULD NOT** - Discouraged but not prohibited
- **MAY** - Optional

Prefer SHALL for most requirements. Use SHOULD/MAY sparingly.

## Writing Good Requirements

1. **One requirement per bullet** - Don't combine multiple requirements
2. **Active voice** - "The system SHALL validate" not "Validation shall be performed"
3. **Testable** - Requirements should be verifiable
4. **Implementation-agnostic** - Describe WHAT, not HOW
5. **No ambiguity** - Avoid words like "appropriate", "reasonable", "user-friendly"
6. **Use EARS patterns** - Pick the appropriate pattern for the requirement type

## Referencing Requirements

Tasks, plans, and reconciliation reference requirements by quoting the exact EARS line from the spec.

Example in tasks.md:
```markdown
**Requirements:**
- "WHEN the user clicks submit the system SHALL save the form data."
- "IF validation fails THEN the system SHALL display error messages."
```
