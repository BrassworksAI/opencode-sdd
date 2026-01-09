# Vanilla demo skeleton

Goal: every generated demo is consistent, runnable via `file://`, and easy to iterate with a small “Figma-like” debug panel.

## Folder layout (per run)

- `demo/index.html`
- `demo/styles.css`
- `demo/app.js`
- `tokens.snapshot.css` (sibling of `demo/`)

## `index.html` skeleton

Requirements:

- Must load CSS in this order:
  1) `../tokens.snapshot.css` (semantic token variables)
  2) `styles.css` (demo-specific styles)
- Must default to `data-theme="light"` on `:root`.
- Must include a `#debug` panel with:
  - theme toggle
  - state selector (freeform list; run decides which states exist)
- Must have a single app root element: `#app`.

Template:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Design System Demo</title>

    <link rel="stylesheet" href="../tokens.snapshot.css" />
    <link rel="stylesheet" href="./styles.css" />
  </head>
  <body>
    <div id="debug" class="debug" role="complementary" aria-label="Debug panel">
      <div class="debug__row">
        <label class="debug__label" for="debug-theme">Theme</label>
        <select id="debug-theme">
          <option value="light">Light</option>
          <option value="dark">Dark</option>
        </select>
      </div>

      <div class="debug__row">
        <label class="debug__label" for="debug-state">State</label>
        <select id="debug-state">
          <option value="default">Default</option>
        </select>
      </div>
    </div>

    <main id="app" class="app" role="main"></main>

    <script src="./app.js"></script>
  </body>
</html>
```

## `styles.css` skeleton

Requirements:

- Use semantic tokens only (CSS vars).
- Provide readable defaults and clear focus states.
- Keep debug panel visually separate and non-destructive.

Starter:

```css
:root {
  color-scheme: light dark;
}

body {
  margin: 0;
  font-family: var(--font-family-sans, system-ui);
  background: var(--color-bg-canvas);
  color: var(--color-text-default);
}

.app {
  padding: var(--space-6);
}

.debug {
  position: fixed;
  top: var(--space-4);
  right: var(--space-4);
  width: 280px;
  padding: var(--space-4);
  border-radius: var(--radius-md);
  background: var(--color-surface-2);
  border: 1px solid var(--color-border-default);
  box-shadow: var(--shadow-md);
}

.debug__row {
  display: grid;
  grid-template-columns: 80px 1fr;
  gap: var(--space-3);
  align-items: center;
  margin-bottom: var(--space-3);
}

.debug__label {
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
}

select {
  width: 100%;
  padding: var(--space-2) var(--space-3);
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border-default);
  background: var(--component-input-bg, var(--color-surface-1));
  color: var(--component-input-fg, var(--color-text-default));
}

select:focus {
  outline: 2px solid var(--color-action-primary-bg);
  outline-offset: 2px;
}
```

## `app.js` skeleton

Requirements:

- No dependencies.
- Theme toggle updates `document.documentElement.dataset.theme`.
- State toggle updates `document.documentElement.dataset.state`.
- Provide `window.__demo` hooks for manual poking (optional but nice).

Starter:

```js
const root = document.documentElement;

const themeSelect = document.getElementById('debug-theme');
const stateSelect = document.getElementById('debug-state');

function setTheme(theme) {
  root.dataset.theme = theme;
}

function setState(state) {
  root.dataset.state = state;
}

themeSelect?.addEventListener('change', (e) => {
  setTheme(e.target.value);
});

stateSelect?.addEventListener('change', (e) => {
  setState(e.target.value);
});

setTheme(themeSelect?.value || 'light');
setState(stateSelect?.value || 'default');

window.__demo = { setTheme, setState };
```

## State naming guidance

- Prefer a small, consistent set:
  - `default`, `loading`, `empty`, `error`, `success`
- For component-focused demos, consider:
  - `default`, `hover`, `focus`, `disabled`, `error`, `loading`

## Accessibility guardrails

- Do not rely on color alone for state.
- Provide visible focus indicators.
- Ensure text contrast is acceptable in both themes.
