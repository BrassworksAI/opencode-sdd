# Agent Extensions: Maintenance Rules

This repository ships agent/command/skill payloads for multiple tools.

## Installer / Uninstaller Maintenance

Any time you add, rename, or remove any file under:
- `opencode/`
- `augment/`
- `codex/`
- `skills/` (these get installed into OpenCode/Codex payloads)

You MUST:
1. Evaluate both uninstall scripts (`uninstall.sh`, `uninstall.ps1`) to ensure they remove the exact payload files.
2. Run `bun scripts/validate-uninstall.ts` and ensure it exits with status 0.
3. If new leaf directories are introduced/removed, update the directory cleanup lists in uninstall scripts.
4. Re-run `bun scripts/validate-uninstall.ts` after updates and verify it reports `OK` for all tools.

Notes:
- Global installs use symlinks; leaving a single untracked file/symlink behind will prevent the directory cleanup from removing that folder.
- This repo intentionally does not remove user-owned OpenCode config (e.g. `~/.config/opencode/opencode.json`). Only the payload under the tool directories is in scope.
