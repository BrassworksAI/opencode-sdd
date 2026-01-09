# Semantic CSS emitter guidance

Goal: produce stable `tokens.snapshot.css` output from `theme.snapshot.json`.

This is not code; it’s a deterministic set of rules the agent should follow.

## Inputs

- `theme.snapshot.json` contains semantic tokens for:
  - `themes.light`
  - `themes.dark`

Each semantic token is a W3C-style token object with `$type` and `$value`.

## Output

- `tokens.snapshot.css` exports **semantic tokens only**.
- It must contain exactly two blocks:
  - `:root[data-theme="light"] { ... }`
  - `:root[data-theme="dark"] { ... }`

## Variable naming

Convert token paths into CSS var names:

- Split on `.` and camelCase boundaries.
- Lowercase all segments.
- Join with `-` and prefix with `--`.

Examples:

- `color.text.default` -> `--color-text-default`
- `color.action.primary.bg` -> `--color-action-primary-bg`
- `component.button.primary.bgHover` -> `--component-button-primary-bg-hover`

## Value emission

- If `$value` is a direct CSS literal (hex, px, rem, etc.), emit as-is.
- If `$value` is an alias like `{color.neutral.950}`:
  - Resolve the alias against `tokens.snapshot.json` primitives if available.
  - If primitives are not present or resolution is ambiguous, keep the alias as a CSS var reference to the *semantic* token source (see “No primitive vars” below).

## No primitive vars

`tokens.snapshot.css` should not export primitive variables.

That means aliases cannot rely on `--color-neutral-950` existing.

Preferred approach:

- Resolve semantic aliases to concrete values during emission.

Fallback approach (only if necessary):

- Keep semantic-to-semantic aliasing by emitting a reference to another semantic var.
  - Example: if `color.surface.1` is aliased to `color.bg.canvas`, emit:
    - `--color-surface-1: var(--color-bg-canvas);`

Do not emit references to non-existent primitive vars.

## Ordering rules (stability)

Emit variables in a stable, predictable order:

1. Sort by top-level group:
   - `color.*`
   - `font.*`
   - `space.*`
   - `radius.*`
   - `shadow.*`
   - `duration.*`
   - `easing.*`
   - `component.*`
2. Within each group, sort token paths lexicographically.

## Comment header (optional but helpful)

At the top of the file, include a comment:

```css
/* Generated from theme.snapshot.json. Semantic tokens only. */
```

## Minimal validation checklist

Before finalizing `tokens.snapshot.css`, ensure:

- Both theme blocks exist.
- Every semantic token path exists in both themes.
- No emitted value references a primitive CSS var.
