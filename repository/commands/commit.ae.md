---
description: Create high-quality git commits with clear Conventional Commit messages
---

# Commit Work

Create clean, reviewable commits from staged/unstaged changes with minimal back‑and‑forth.

## Goal

Make commits that are easy to review and safe to ship. Commit messages must describe behavior and intent.

## Workflow

1. **Inspect**: Check state with `git status` and `git diff`.
2. **Boundary**: Group changes into logical units. Default to one commit; split only for clear review benefit or risk isolation.
3. **Stage**: Use `git add -p` for mixed files. Review with `git diff --cached` to ensure no secrets or debug logs.
4. **Verify**: Run the fastest relevant check (tests/lint) before committing.
5. **Commit**: Use `git commit -v` with Conventional Commits.
    - `type(scope): short summary` (imperative, what + why)
    - Body (rationale)
    - Footer (breaking changes)

## Usage Examples

- **Do**: `feat(auth): add login rate limiting to prevent brute force`
- **Don't**: `update login.js` or `fix some bugs`
- **Do**: Split a risky database migration from a cosmetic UI fix.
- **Don't**: Mix 15 unrelated file changes into a single "cleanup" commit.

## Success Criteria

- [ ] Working tree is clean.
- [ ] Commit history is linear and logical.
- [ ] Messages follow Conventional Commits.
- [ ] Verification steps passed.

## Deliverable

Run `git log --oneline -5` to verify and prove work.
