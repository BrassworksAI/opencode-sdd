---
description: Prime LLM with all spec files for a change
---

# Spec Context for Change: <change-set-name>

## Inputs

- Change set name. Resolve it by running `ls -1 changes` and ignoring `archive/`. If exactly one directory remains, use it as `<change-set-name>`. Otherwise ask the user which change set to use.

The following spec files are loaded for planning context:

## Spec Files

Run:

- `find changes/<change-set-name>/specs -name "*.md" -exec sh -c 'echo "=== {} ===" && cat "{}"' \; 2>/dev/null`

---

Use this context to inform your planning and implementation decisions for the `<change-set-name>` change. Respond "Got it." if you understand.
