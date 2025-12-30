---
name: sdd-delta-format
description: Exact rules for writing SDD delta specs (heading levels, Before/After, flat vs grouped)
---

# Delta Spec Format

Delta specs express changes to canonical specs. They live in `changes/<change-name>/specs/**` and mirror the canonical taxonomy path.

## Core Rules

1. Delta files contain ONLY sections being changed (not a full copy of the canonical spec).
2. Delta files use explicit operation headings: `Added`, `Modified`, `Removed`.
3. You never edit canonical specs directly; all changes go through deltas.

## Heading Levels by Context

| Canonical Shape | Target Section | Operation Heading Level |
|-----------------|----------------|-------------------------|
| Flat requirements | `## Requirements` | `### Added/Modified/Removed` |
| Grouped requirements | `### <Group>` | `#### Added/Modified/Removed` |

## Flat Requirements Delta

Use when the canonical spec has flat `## Requirements` (no `### <Group>` subheadings).

```markdown
## Requirements

### Added

- THE SYSTEM SHALL do new thing A.
- THE SYSTEM SHALL do new thing B.

### Modified

- Before: THE SYSTEM SHALL do old behavior X.
  - After: THE SYSTEM SHALL do new behavior X.

### Removed

- THE SYSTEM SHALL no longer do deprecated thing.
```

## Grouped Requirements Delta

Use when the canonical spec has grouped requirements like `### Entry Points`, `### Exit Points`, etc.

```markdown
## Requirements

### Entry Points

#### Added

- THE SYSTEM SHALL accept new input method.

#### Modified

- Before: THE SYSTEM SHALL read from stdin.
  - After: THE SYSTEM SHALL read from stdin or from --input file.

### Exit Points

#### Added

- THE SYSTEM SHALL exit with status 2 on warning.

#### Removed

- THE SYSTEM SHALL exit with status 99 on legacy error.
```

## New Spec (Greenfield) Delta

When creating a brand-new capability spec:

- `## Overview` is REQUIRED.
- Only `Added` entries allowed (no Modified/Removed — there's nothing to modify).

```markdown
## Overview

<Overview paragraph for the new capability.>

## Requirements

### Added

- THE SYSTEM SHALL do X.
- THE SYSTEM SHALL do Y.
```

Or with groups:

```markdown
## Overview

<Overview paragraph.>

## Requirements

### Entry Points

#### Added

- THE SYSTEM SHALL accept input via API.

### Exit Points

#### Added

- THE SYSTEM SHALL return success with payload.
```

## Modified Entry Format (Critical)

Each modification MUST include exact `Before` and `After` text:

```markdown
- Before: <Exact existing requirement line from canonical spec>
  - After: <Replacement requirement line>
```

Rules:
- `Before` must match EXACTLY one line in the canonical target section.
- If `Before` is not found → sync error.
- If `Before` matches multiple lines → sync error (ambiguous).
- Whitespace and punctuation must match exactly.

## Overview Changes

If you need to change the Overview section, include the entire replacement:

```markdown
## Overview

<New overview text that will REPLACE the canonical overview entirely.>
```

Omit `## Overview` if you're not changing it.

## Common Mistakes to Avoid

1. Using `### Added` inside a grouped spec (should be `#### Added` under the group).
2. Using `#### Added` in a flat spec (should be `### Added` directly under `## Requirements`).
3. Forgetting to include exact `Before:` text for modifications.
4. Including sections that aren't changing (keep deltas minimal).
5. Creating a new spec without `## Overview`.
6. Using Modified/Removed in a greenfield delta.

## Checklist Before Finishing

- [ ] Heading levels match canonical structure (flat vs grouped)
- [ ] Every `Modified` has exact `Before:` / `- After:` pair
- [ ] Greenfield deltas have `## Overview` and only `Added`
- [ ] No unchanged sections included
- [ ] Path mirrors canonical taxonomy: `changes/<name>/specs/<domain>/<capability>.md`
