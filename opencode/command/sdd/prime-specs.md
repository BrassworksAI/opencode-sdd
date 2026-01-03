---
description: Prime LLM with all spec files for a change
---

# Spec Context for Change: $1

The following spec files are loaded for planning context:

## Spec Files

!`find changes/$1/specs -name "*.md" -exec sh -c 'echo "=== {} ===" && cat "{}"' \; 2>/dev/null`

---

Use this context to inform your planning and implementation decisions for the `$1` change.
