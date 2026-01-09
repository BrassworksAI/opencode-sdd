---
name: design-case-study-generator
description: Designs product concepts as vibe-first pitch options, then generates a versioned design case study with W3C-style tokens and a vanilla HTML/CSS/JS demo.
---

# Design Case Study Generator

## Core idea

Each run:

1. Ask for a scope (greenfield app / feature / page / flow / component) and a minimal set of constraints.
2. Present **3 vibe-first pitch cards**.
3. User chooses **exactly 1** option.
4. Generate a **versioned run**.
   - Exploratory default: **demo-first** (vanilla HTML/CSS/JS + debug panel). Minimal extra files.
   - If approved, optionally **codify** the direction (tokens + decisions + case study) for reuse.

This skill optimizes for ideation speed and repeatable artifacts ("Figma replacement" via runnable docs).

## Hard constraints

- Vanilla only: **no build tools**, no bundlers, no frameworks.
- Always pitch 3 options; **generate artifacts for only the chosen option**.
- Default mode is **Exploratory**: generate **demo-only by default**; do not update any canonical token files unless the user explicitly asks.
- “Deterministic output” means: within a single run, emit files from the chosen option in a predictable format/order. It does **not** mean preserving decisions across versions.

## Inputs (ask these up front)

Ask the user for:

1. **Scope**: greenfield app | new feature | single page | single flow | component
2. **What is it?**: 1–3 sentences describing the idea and why it matters
3. **Primary user + job**: who it’s for and what they’re trying to do
4. **Platform**: web (default) / mobile / desktop
5. **Constraints**: accessibility bar, performance, any “no-go” patterns
6. **Vibe axis**: 2–4 adjectives (e.g., bold/edgy, airy/light, quiet/luxury)
7. **Reference links** (optional): competitors, inspirations, existing brand
8. **Behavior**: visual-only (default) vs interaction/motion

If the user is greenfield and has no answers, propose reasonable defaults and confirm.

## Generate 3 pitch options (vibe-first)

Produce 3 options as short cards. The goal is to sell the vibe and how it works.

Use the exact card format from `references/pitch-card-template.md`.

After pitching:

- Assume **zero prior design decisions** unless the user explicitly says they want to continue a previous vibe/version.
- Ask the user to pick **Option A / B / C**.
- If the user asks for a blend, treat it as a new option and confirm before generating.

## Slugging + versioning

All outputs go under `design-system/runs/`.

### Revisions (copy-forward)

If the user is **editing an existing direction** (a revision/iteration), use a **copy-forward version**.

Treat the request as a revision when the user:
- References the current run/version (e.g. “in v3…”, “the last demo…”, “keep everything but…”)
- Asks for adjustments/tweaks/iterations (e.g. “revise”, “iterate”, “tweak”, “make X bigger”, “change the header”, “swap the accent color”)
- Implies continuity (e.g. “same vibe, but…”, “don’t change the structure, just…”)

Treat the request as a new run (no copy-forward) when the user:
- Picks a different pitch option / asks for a different vibe direction
- Changes the scope entirely (different page/flow/component)
- Changes the series slug
- Requests a “hard reset” / “start over” / “from scratch”

If it’s ambiguous, ask a 1-line clarifier:

> “Is this a revision of the previous version (copy-forward), or a new direction (fresh run)?”

When doing a revision:

1. Identify the most recent version `vN` for the current series slug.
2. Create `v(N+1)` by copying the entire folder from `vN`.
3. Apply edits *in-place* in `v(N+1)` so we retain a full history.

Use this helper command (Bun required):

```bash
bun run opencode/skill/design-case-study-generator/scripts/copy-version.ts -- --slug <series-slug> --from vN
```

It prints the created directory path (e.g. `design-system/runs/<slug>/v3`).

### Series slug

- Propose a **semantic series slug** (kebab-case) based on what’s being generated.
  - Example patterns:
    - `landing-page-bold-noir`
    - `calendar-editorial-minimal`
    - `checkout-flow-quiet-luxury`
- Ensure uniqueness against existing folders under `design-system/runs/`.
  - If the slug exists, append `-2`, `-3`, etc.
- Always ask the user to confirm/edit the slug.

### Version number

- Under the series slug, create the next available version directory: `v1`, `v2`, ...
- Never overwrite an existing version.
- If this is a **revision** of the previous version, prefer **copy-forward** (see “Revisions (copy-forward)”).

## Modes: Exploratory vs consolidation

### Exploratory (default)

- Each version (`vN`) is allowed to be radically different.
- Do not attempt to keep tokens or UI consistent across versions.
- Only reference earlier runs to:
  - avoid slug collisions
  - choose the next version number

If the user says **“hard reset”** (or similar), do not reference earlier runs for inspiration or continuity.

### Consolidation (opt-in)

Only when the user explicitly asks to stabilize the system:

- Propose updates to canonical files under `design-system/tokens/`.
- Treat canonical changes as intentional and reviewable (summarize deltas and rationale).

## Output contract

### Exploratory output (default: demo-only)

Create exactly this structure:

- `design-system/runs/<series-slug>/vN/`
  - `demo/`
    - `index.html`
    - `styles.css`
    - `app.js` (required for the hideable debug shelf; also used for any interaction/motion)

Notes:

- In Exploratory mode, do **not** create case study files or token JSON snapshots by default.
- Style tokens should be **embedded inline** in the demo (typically as a `<style>` block containing semantic CSS variables for light/dark).

After generating the demo, ask:

> “Do you want to approve this direction and codify it into tokens + decisions + a case study?”

If the user says yes, proceed with “Codified output”.

### Codified output (only when approved)

When approved, add these files under the same `vN/`:

- `decisions.json`
- `tokens.snapshot.json`
- `theme.snapshot.json`
- `tokens.snapshot.css`
- `case-study.md`

### Case study

Use the structure in `references/case-study-template.md`.

Keep it concrete and tied to the demo:

- What the user does
- What screens/states exist
- What tokens/components are implied
- What you would test/measure

### Tokens (only when codifying)

Only generate token snapshot files after the user approves the direction.

- Token snapshots are W3C-style (`$value`, `$type`, aliases).
- `tokens.snapshot.json` contains primitives and any shared foundations.
- `theme.snapshot.json` maps semantic tokens for **light + dark**.
- `tokens.snapshot.css` exports **semantic only** CSS variables for both themes.

Use `references/token-schema-guidance.md` for naming rules and minimal required token sets.
Use `references/tokens-css-emitter.md` for stable, deterministic `tokens.snapshot.css` emission.

### Demo (vanilla)

- `index.html` must run via double-click (file://) with no tooling.
- The demo must always include a **hideable debug shelf** (right-side drawer, hidden by default) to toggle:
  - theme: light/dark
  - key state(s) relevant to the scope (loading/error/empty/success, or component states)
- JavaScript is optional.
  - Always allowed: a tiny JS snippet to toggle the debug shelf open/closed.
  - When interaction/motion is part of what’s being evaluated, write whatever vanilla JS is needed (animations, scroll effects, dynamic state, etc.) as long as it stays dependency-free and build-tool-free.

Use `references/demo-skeleton.md` as the base structure for `index.html`, `styles.css`, and `app.js` so demos stay consistent **structurally** (not aesthetically) run-to-run.

In Exploratory mode, tokens are embedded inline in the demo (no extra token files).
When codified, the demo must import `../tokens.snapshot.css` and use semantic CSS vars from there.

## Interaction style

- Keep questions minimal, but do not guess critical constraints.
- Prefer small, reversible design moves.
- Explain tradeoffs briefly.

## If the user asks to “make it real”

If the user wants to move from exploratory to a more stable design system, ask whether to:

- keep generating run snapshots only, or
- start updating canonical files under `design-system/tokens/`.

Do not create or update canonical token files unless explicitly requested.
