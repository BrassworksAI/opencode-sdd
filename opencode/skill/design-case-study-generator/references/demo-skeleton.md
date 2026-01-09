# Vanilla demo skeleton

Goal: every generated demo is consistent, runnable via `file://`, and easy to iterate with a small “Figma-like” debug panel.

## Folder layout (per run)

- `demo/index.html`
- `demo/styles.css`
- `demo/app.js`

Exploratory default:

- No token files. Keep semantic CSS variables embedded inline in `demo/index.html`.

Codified:

- `tokens.snapshot.css` (sibling of `demo/`)

## `index.html` skeleton

Requirements:

- Must load CSS in this order:
  - Exploratory: inline `<style>` with semantic tokens first, then `styles.css`.
  - Codified: `../tokens.snapshot.css` (semantic token variables) first, then `styles.css`.
- Must default to `data-theme="light"` on `:root`.
- Must include a **hideable debug shelf** (right-side drawer) that is **hidden by default**.
  - Must not affect page layout (fixed overlay).
  - Includes theme toggle + state selector.
- Must have a single app root element: `#app`.

Template:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Design System Demo</title>

    <!-- Exploratory default: embed tokens inline as a <style> block here. -->
    <!-- Codified: load semantic tokens from ../tokens.snapshot.css. -->
    <!-- <link rel="stylesheet" href="../tokens.snapshot.css" /> -->

    <link rel="stylesheet" href="./styles.css" />
  </head>
  <body>
    <button id="debug-toggle" class="debugToggle" type="button" aria-controls="debug" aria-expanded="false">
      Debug
    </button>

    <aside id="debug" class="debug" role="complementary" aria-label="Debug panel" aria-hidden="true">
      <div class="debug__header">
        <div class="debug__title">Debug</div>
        <button id="debug-close" class="debug__close" type="button" aria-controls="debug" aria-expanded="true">
          Close
        </button>
      </div>

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
    </aside>

    <main id="app" class="app" role="main"></main>

    <!-- Include app.js when either:
         1) you want the debug shelf hidden-by-default behavior, or
         2) the demo needs interaction/motion behavior.

         If you truly want zero JS, you can omit this script and accept the shelf being always closed.
    -->
    <!-- <script src="./app.js"></script> -->
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

.debugToggle {
  position: fixed;
  top: var(--space-4);
  right: var(--space-4);
  z-index: 1000;
  padding: var(--space-2) var(--space-3);
  border-radius: var(--radius-pill);
  border: 1px solid var(--color-border-default);
  background: var(--color-surface-2);
  color: var(--color-text-default);
  box-shadow: var(--shadow-sm);
}

.debugToggle:focus {
  outline: 2px solid var(--color-action-primary-bg);
  outline-offset: 2px;
}

.debug {
  position: fixed;
  top: 0;
  right: 0;
  height: 100vh;
  width: 320px;
  padding: var(--space-4);
  background: var(--color-surface-2);
  border-left: 1px solid var(--color-border-default);
  box-shadow: var(--shadow-lg);
  z-index: 1100;

  transform: translateX(100%);
  transition: transform var(--duration-normal) var(--easing-standard);
}

.debug[data-open="true"] {
  transform: translateX(0);
}

.debug__header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--space-4);
}

.debug__title {
  font-size: var(--font-size-md);
  font-weight: var(--font-weight-semibold);
}

.debug__close {
  padding: var(--space-2) var(--space-3);
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border-default);
  background: var(--color-surface-1);
  color: var(--color-text-default);
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

## Optional JS

JavaScript is allowed in two tiers:

- Always allowed: minimal JS for the debug shelf open/close.
- When interaction/motion is part of what’s being evaluated: add whatever vanilla JS is needed (animations, scroll effects, dynamic state, etc.), dependency-free.

If JS is included, use `app.js` with these requirements:

- No dependencies.
- Theme toggle updates `document.documentElement.dataset.theme`.
- State toggle updates `document.documentElement.dataset.state`.
- Debug shelf is **hidden by default** and toggled by JS (open/close).
- Provide `window.__demo` hooks for manual poking (optional but nice).

Starter:

```js
const root = document.documentElement;

const debug = document.getElementById('debug');
const debugToggle = document.getElementById('debug-toggle');
const debugClose = document.getElementById('debug-close');

const themeSelect = document.getElementById('debug-theme');
const stateSelect = document.getElementById('debug-state');

function setTheme(theme) {
  root.dataset.theme = theme;
}

function setState(state) {
  root.dataset.state = state;
}

function setDebugOpen(open) {
  if (!debug) return;
  debug.dataset.open = open ? 'true' : 'false';
  debug.setAttribute('aria-hidden', open ? 'false' : 'true');
  debugToggle?.setAttribute('aria-expanded', open ? 'true' : 'false');
}

debugToggle?.addEventListener('click', () => setDebugOpen(true));
debugClose?.addEventListener('click', () => setDebugOpen(false));

themeSelect?.addEventListener('change', (e) => {
  setTheme(e.target.value);
});

stateSelect?.addEventListener('change', (e) => {
  setState(e.target.value);
});

setTheme(themeSelect?.value || 'light');
setState(stateSelect?.value || 'default');
setDebugOpen(false);

window.__demo = { setTheme, setState, setDebugOpen };
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
