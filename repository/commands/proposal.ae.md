---
description: Draft and refine a product proposal document through collaborative dialogue
---

# Product Proposal

Help the user externalize and articulate their vision into a complete product proposal.

## Required Skills

- `research`

## Inputs

> [!IMPORTANT]
> You must ask the user for the following information; do not assume CLI arguments are provided.

- **Target Path**: Folder or file path for `proposal.md` (default: `./proposal.md`).

## Instructions

The proposal is the source of truth for "how the system works." Your goal is to help the user articulate their tribal knowledge into concrete narrative prose.

1. **Research First**: Use the `research` skill to identify existing patterns, similar features, and integration points. Use these findings to anchor the proposal in the existing codebase.
2. **Collaborative Dialogue**: Ask targeted questions to fill logic gaps (e.g., "What happens if the network drops?") rather than guessing. Recommend patterns; don't decide for the user.
3. **Narrative Prose**: Write specific, concrete behavior. Describe what the system *does*, not what it *doesn't* do. Avoid hedging (e.g., "if time permits").
4. **Identify Boundaries**: Surface natural capability boundaries as they emerge to simplify the upcoming specs phase.

## Success Criteria

- Proposal includes a clear problem statement (1-2 sentences).
- Full system behavior is described in narrative prose.
- Error handling and recovery paths are explicitly defined.
- Finalized document is saved to the target path.

## Usage Examples

### Do

- "Based on the `auth` module, should we handle session expiration like this...?"
- "What is the expected behavior if a user tries to delete a locked record?"

### Don't

- Assume implementation details like database schemas or specific API endpoints.
- Include scope exclusions or "future work" in the main proposal body.
