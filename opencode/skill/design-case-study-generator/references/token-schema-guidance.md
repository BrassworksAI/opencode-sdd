# Token schema guidance (W3C-style)

This skill produces W3C-style token JSON snapshots.

## Conventions

- Use `$value` and `$type`.
- Use aliases where possible: `{color.neutral.950}`.
- Prefer stable, scale-based primitives.

## Minimal required primitives (tokens.snapshot.json)

### Color

- `color.neutral.<scale>` (at least 50..950)
- `color.brand.<scale>` (at least 50..900)
- Optional: `color.success.<scale>`, `color.warning.<scale>`, `color.danger.<scale>`

All colors must be valid CSS colors (hex preferred).

### Typography

- `font.family.sans`
- `font.family.mono`
- `font.size.<xs|sm|md|lg|xl|2xl|3xl>`
- `font.weight.<regular|medium|semibold|bold>`
- `lineHeight.<tight|normal|relaxed>`

### Spacing + radius

- `space.<1..12>` in `px` or `rem`
- `radius.<sm|md|lg|xl|pill>`

### Shadow + motion

- `shadow.<sm|md|lg>` (CSS box-shadow strings)
- `duration.<fast|normal|slow>`
- `easing.<standard|emphasized>`

## Minimal required semantics (theme.snapshot.json)

Must exist for both `light` and `dark` themes.

### Color semantics

- `color.bg.canvas`
- `color.surface.1`
- `color.surface.2`
- `color.text.default`
- `color.text.muted`
- `color.text.inverse`
- `color.border.default`
- `color.action.primary.bg`
- `color.action.primary.fg`
- `color.action.secondary.bg`
- `color.action.secondary.fg`
- `color.status.success`
- `color.status.warning`
- `color.status.danger`

### Component semantics (starter)

- `component.button.primary.bg`
- `component.button.primary.fg`
- `component.button.primary.bgHover`
- `component.input.bg`
- `component.input.fg`
- `component.input.border`
- `component.card.bg`
- `component.card.border`

## CSS export rules (tokens.snapshot.css)

- Export **semantic tokens only** as CSS variables.
- Use `:root[data-theme="light"]` and `:root[data-theme="dark"]` blocks.
- Variable naming:
  - Token path `color.text.default` -> `--color-text-default`
  - Token path `component.button.primary.bgHover` -> `--component-button-primary-bg-hover`
