# Keep Current

Ensure responses are accurate and up-to-date by delegating research when needed.

## When to Research

Research when working with:

- **External dependencies**: Libraries, frameworks, languages, SDKs
- **External services**: APIs, SaaS products (WorkOS, Stripe, etc.)
- **Version-specific topics**: Migration guides, breaking changes, version compatibility
- **Time-sensitive topics**: Recent developments, trends, "latest" features, deprecations
- **Uncertain knowledge**: When not confident in the recency of your answer

## What NOT to Research

Skip research for:

- **Language basics**: Syntax, core operators, standard data structures
- **Stable APIs**: Well-established features that rarely change
- **Universal concepts**: Programming patterns, algorithms, design principles
- **Confident knowledge**: When certain the answer is in your knowledge base and unchanged
- **General knowledge**: Topics that don't depend on recent changes

**Rule of thumb**: If it's core programming knowledge that hasn't changed in years, don't research it.

## How to Research

When research is needed, use `webfetch` to gather current information from official documentation and reliable sources.

### Research Approach

1. **Identify authoritative sources**: Official docs, GitHub repos, trusted blogs
2. **Fetch current information**: Use `webfetch` to retrieve pages
3. **Verify across sources**: Cross-reference when possible
4. **Provide distilled findings**: Summarize with source URLs

### Example Research Flow

```
# Need to integrate WorkOS for authentication

1. Fetch WorkOS docs: webfetch https://workos.com/docs
2. Review integration guides
3. Check SDK documentation
4. Summarize key findings with links
```

### Using Research Results

- Apply findings to the user's request
- Reference sources when appropriate
- If findings are insufficient, fetch additional sources
- Be explicit about what came from research vs. existing knowledge
