---
description: Create high-quality git commits with clear Conventional Commit messages
---

# Commit Work

Create clean, reviewable commits from staged/unstaged changes with minimal back‑and‑forth.

## Goal

Make commits that are easy to review and safe to ship, while acting decisively:

- only intended changes are included
- default to the fewest logical commits; split only when there is a clear risk or review benefit
- commit messages describe what changed and why
- only involve the user when safety, ambiguity, or policy risk requires it

## Workflow (Checklist)

1) Inspect the working tree before staging
   - `git status`
   - `git diff` (unstaged)
   - If many changes: `git diff --stat`
2) Decide commit boundaries (default to one commit)
   - Make a single commit unless there is a strong reason to split (e.g., unrelated changes, risky refactors mixed with cosmetic churn, or separate deploy units).
   - Only ask the user to confirm boundaries when the intent is unclear or the risk of a wrong split is high.
   - If changes are mixed in one file and a split is required, plan to use patch staging.
3) Stage only what belongs in the next commit
   - Prefer patch staging for mixed changes: `git add -p`
   - To unstage a hunk/file: `git restore --staged -p` or `git restore --staged <path>`
4) Review what will actually be committed
   - `git diff --cached`
   - Sanity checks:
     - no secrets or tokens
     - no accidental debug logging
     - no unrelated formatting churn
5) Describe the staged change in 1-2 sentences (before writing the message)
   - "What changed?" + "Why?"
   - If you cannot describe it cleanly, the commit is probably too big or mixed; go back to step 2.
6) Write the commit message
   - Use Conventional Commits (required):
     - `type(scope): short summary`
     - blank line
     - body (what/why, not implementation diary)
     - footer (BREAKING CHANGE) if needed
   - Prefer an editor for multi-line messages: `git commit -v`
   - Use the template below if helpful.
7) Run the smallest relevant verification
   - Run the repo's fastest meaningful check (unit tests, lint, or build) before moving on.
8) Repeat for the next commit until the working tree is clean

## Commit Message Template (Conventional Commits)

```text
<type>(<scope>): <summary>

<What changed.>
<Why it changed.>
```

Notes:

- Keep the summary imperative and specific ("Add", "Fix", "Remove", "Refactor").
- Avoid implementation minutiae; focus on behavior and intent.

## Deliverable

Provide:

- Run `git log --oneline -5` to verify and prove work
